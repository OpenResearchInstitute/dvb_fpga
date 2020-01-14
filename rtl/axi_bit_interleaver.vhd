--
-- DVB IP
--
-- Copyright 2019 by Suoto <andre820@gmail.com>
--
-- This file is part of DVB IP.
--
-- DVB IP is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- DVB IP is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DVB IP.  If not, see <http://www.gnu.org/licenses/>.

---------------
-- Libraries --
---------------
library	ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library str_format;
use str_format.str_format_pkg.all;

use work.common_pkg.all;
use work.dvb_utils_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_bit_interleaver is
  generic (DATA_WIDTH : positive := 8);
  port (
    -- Usual ports
    clk            : in  std_logic;
    rst            : in  std_logic;

    cfg_modulation : in  modulation_t;
    cfg_frame_type : in  frame_type_t;
    cfg_code_rate  : in  code_rate_t;

    -- AXI input
    s_tvalid       : in  std_logic;
    s_tdata        : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    s_tlast        : in  std_logic;
    s_tready       : out std_logic;

    -- AXI output
    m_tready       : in  std_logic;
    m_tvalid       : out std_logic;
    m_tlast        : out std_logic;
    m_tdata        : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end axi_bit_interleaver;

architecture axi_bit_interleaver of axi_bit_interleaver is

  ---------------
  -- Constants --
  ---------------
  constant MAX_ROWS    : integer := 21_600 / DATA_WIDTH;
  constant MAX_COLUMNS : integer := 5;

  type cnt_cfg_t is record
    row_max       : integer;
    row_remainder : integer;
    column_max    : integer;
  end record;

  impure function get_cnt_cfg (
    constant modulation : in modulation_t;
    constant frame_type : in frame_type_t) return cnt_cfg_t is
    variable cfg        : cnt_cfg_t;
  begin

    if frame_type = fecframe_normal then
      if modulation = mod_8psk then
        cfg.row_max := 21_600;
      elsif modulation = mod_16apsk then
        cfg.row_max := 16_200;
      elsif modulation = mod_32apsk then
        cfg.row_max := 12_960;
      end if;
    elsif frame_type = fecframe_short then
      if modulation = mod_8psk then
        cfg.row_max := 5_400;
      elsif modulation = mod_16apsk then
        cfg.row_max := 4_050;
      elsif modulation = mod_32apsk then
        cfg.row_max := 3_240;
      end if;
    end if;

    if modulation = mod_8psk then
      cfg.column_max := 3;
    elsif modulation = mod_16apsk then
      cfg.column_max := 4;
    elsif modulation = mod_32apsk then
      cfg.column_max := 5;
    end if;

    cfg.row_remainder := cfg.row_max rem DATA_WIDTH;
    -- cfg.row_max := cfg.row_max / DATA_WIDTH;
    cfg.row_max := (cfg.row_max + DATA_WIDTH - 1) / DATA_WIDTH;

    -- report "cfg.row_remainder = " & integer'image(cfg.row_remainder)
    --   severity note;

    return cfg;

  end function get_cnt_cfg;

  -- Read data is an array
  type data_array_t is array (natural range <>)
    of std_logic_vector(DATA_WIDTH - 1 downto 0);

  type column_array_t is array (natural range <>)
    of std_logic_vector(MAX_COLUMNS - 1 downto 0);

  -------------
  -- Signals --
  -------------
  -- Write side config
  signal wr_cfg_modulation   : modulation_t;
  signal wr_cfg_frame_type   : frame_type_t;
  signal wr_cfg_code_rate    : code_rate_t;

  signal s_axi_dv            : std_logic;
  signal s_tready_i          : std_logic;
  signal s_tdata_0           : std_logic_vector(DATA_WIDTH - 1 downto 0);

  signal wr_row_cnt_max      : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal wr_remainder_max    : unsigned(numbits(DATA_WIDTH) - 1 downto 0);
  signal wr_column_cnt_max   : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);
  signal row_rem_acc         : integer;

  signal wr_row_cnt          : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal wr_column_cnt       : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal wr_remainder_cnt    : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal wr_ram_ptr          : unsigned(1 downto 0);

  signal ram_wren            : std_logic_vector(MAX_COLUMNS - 1 downto 0);
  signal ram_wraddr          : std_logic_vector(numbits(MAX_ROWS) downto 0);
  signal ram_wrdata          : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal dbg_ram_wrdata_2    : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal dbg_ram_wrdata_4    : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal dbg_ram_wrdata_6    : std_logic_vector(DATA_WIDTH - 1 downto 0);

  signal rd_row_cnt_max      : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal rd_remainder_max    : unsigned(numbits(DATA_WIDTH) - 1 downto 0);
  signal rd_column_cnt_max   : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);
  signal rd_ram_ptr          : unsigned(1 downto 0);

  signal rd_row_cnt          : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal rd_column_cnt       : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);
  signal rd_column_cnt_delay : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);

  signal ram_rdaddr          : std_logic_vector(numbits(MAX_ROWS) downto 0);
  signal ram_rddata          : data_array_t(0 to MAX_COLUMNS - 1);

  -- Read side config
  signal rd_cfg_modulation   : modulation_t;
  signal rd_cfg_frame_type   : frame_type_t;
  signal rd_cfg_code_rate    : code_rate_t;

  signal rd_data_sr          : std_logic_vector(MAX_COLUMNS*DATA_WIDTH - 1 downto 0);

  signal interleaved_3c      : std_logic_vector(3*DATA_WIDTH - 1 downto 0);
  signal interleaved_4c      : std_logic_vector(4*DATA_WIDTH - 1 downto 0);
  signal interleaved_5c      : std_logic_vector(5*DATA_WIDTH - 1 downto 0);

  signal m_wr_en             : std_logic := '0';
  signal m_wr_en_0           : std_logic := '0';
  signal m_wr_full           : std_logic;
  signal m_wr_data           : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal m_wr_last           : std_logic := '0';
  signal m_wr_last_0         : std_logic := '0';

  signal tready_bubble       : std_logic;
  signal first_word          : std_logic;

begin

  -------------------
  -- Port mappings --
  -------------------
  -- Generate 1 RAM for each column, each one gets written sequentially
  generate_rams : for column in 0 to MAX_COLUMNS - 1 generate
    ram : entity work.ram_inference
      generic map (
        ADDR_WIDTH          => numbits(MAX_ROWS) + 1,
        DATA_WIDTH          => DATA_WIDTH,
        RAM_INFERENCE_STYLE => "auto",
        EXTRA_OUTPUT_DELAY  => 0)
      port map (
        -- Port A
        clk_a     => clk,
        clken_a   => '1',
        wren_a    => ram_wren(column),
        addr_a    => ram_wraddr,
        wrdata_a  => ram_wrdata,
        rddata_a  => open,

        -- Port B
        clk_b     => clk,
        clken_b   => '1',
        addr_b    => ram_rdaddr,
        rddata_b  => ram_rddata(column));
  end generate generate_rams;

  -- Interleaved data takes 1 cycle after the address has changed, add support for
  -- a couple of cycles to stop the pipeline
  axi_master_adapter_u : entity work.axi_stream_master_adapter
    generic map (
      MAX_SKEW_CYCLES => 2,
      TDATA_WIDTH     => DATA_WIDTH)
    port map (
      -- Usual ports
      clk      => clk,
      reset    => rst,
      -- wanna-be AXI interface
      wr_en    => m_wr_en_0,
      wr_full  => m_wr_full,
      wr_data  => m_wr_data,
      wr_last  => m_wr_last_0,
      -- AXI master
      m_tvalid => m_tvalid,
      m_tready => m_tready,
      m_tdata  => m_tdata,
      m_tlast  => m_tlast);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  m_wr_data <= rd_data_sr(DATA_WIDTH - 1 downto 0);

  -- Assign the interleaved data statically
  iter_rows : for row in 0 to DATA_WIDTH - 1 generate
    iter_columns : for column in 0 to 5 generate

      interleaved_columns_3 : if column < 3 generate
        interleaved_3c(3*DATA_WIDTH - (3 * row + column) - 1)
          <= ram_rddata(column)(DATA_WIDTH - row - 1);
      end generate interleaved_columns_3;

      interleaved_columns_4 : if column < 4 generate
        interleaved_4c(4*DATA_WIDTH - (4 * row + column) - 1)
          <= ram_rddata(column)(DATA_WIDTH - row - 1);
      end generate interleaved_columns_4;

      interleaved_columns_5 : if column < 5 generate
        interleaved_5c(5*DATA_WIDTH - (5 * row + column) - 1)
          <= ram_rddata(column)(DATA_WIDTH - row - 1);
      end generate interleaved_columns_5;

    end generate iter_columns;
  end generate iter_rows;


  s_axi_dv <= '1' when s_tready_i = '1' and s_tvalid = '1' else '0';

  s_tready_i <= '0' when tready_bubble = '1' else
                m_tready when wr_ram_ptr - rd_ram_ptr < 2 else '0';

  -- Assign internals
  s_tready <= s_tready_i;

  ram_rdaddr <= rd_ram_ptr(0) & std_logic_vector(rd_row_cnt);

  -- ram_wrdata <= s_tdata_0(DATA_WIDTH - 3 downto 0) & s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH - 2) when row_rem_acc = 2 else
  --               s_tdata_0(DATA_WIDTH - 5 downto 0) & s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH - 4) when row_rem_acc = 4 else
  --               s_tdata_0(DATA_WIDTH - 7 downto 0) & s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH - 6) when row_rem_acc = 6 else
  --               s_tdata;

  dbg_ram_wrdata_2 <= s_tdata_0(DATA_WIDTH - 3 downto 0) & s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH - 2);
  dbg_ram_wrdata_4 <= s_tdata_0(DATA_WIDTH - 5 downto 0) & s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH - 4);
  dbg_ram_wrdata_6 <= s_tdata_0(DATA_WIDTH - 7 downto 0) & s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH - 6);

  --------------------------------
  -- Handle write side pointers --
  --------------------------------
  write_side_p : process(clk, rst)
    variable cnt_cfg : cnt_cfg_t;
  begin
    if rst = '1' then
      wr_row_cnt        <= (others => '0');
      wr_column_cnt     <= (others => '0');
      wr_remainder_cnt  <= (others => '0');
      wr_ram_ptr        <= (others => '0');


      first_word        <= '1';
      wr_row_cnt_max    <= (others => '1');
      wr_remainder_max  <= (others => '1');
      wr_column_cnt_max <= (others => '1');

      rd_row_cnt_max    <= (others => '1');
      rd_column_cnt_max <= (others => '1');

      row_rem_acc       <= 0;

    elsif clk'event and clk = '1' then

      ram_wren   <= (others => '0');
      ram_wraddr <= wr_ram_ptr(0) & std_logic_vector(wr_row_cnt);

      if row_rem_acc = 2 then
        ram_wrdata <= s_tdata_0(DATA_WIDTH - 3 downto 0) & s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH - 2);
      elsif row_rem_acc = 4 then
        ram_wrdata <= s_tdata_0(DATA_WIDTH - 5 downto 0) & s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH - 4);
      elsif row_rem_acc = 6 then
        ram_wrdata <= s_tdata_0(DATA_WIDTH - 7 downto 0) & s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH - 6);
      else
        ram_wrdata <= s_tdata;
      end if;


      tready_bubble <= '0';

      if s_axi_dv = '1' or tready_bubble = '1' then
        first_word <= s_tlast;
        s_tdata_0  <= s_tdata;

        ram_wren(to_integer(wr_column_cnt)) <= '1';

        if wr_row_cnt /= wr_row_cnt_max then
          -- At this point we need to write the
          if wr_remainder_max /= 0 and wr_row_cnt = wr_row_cnt_max - 1 then
            row_rem_acc <= row_rem_acc + to_integer(wr_remainder_max);
          end if;
          wr_row_cnt    <= wr_row_cnt + 1;
        -- elsif wr_remainder_cnt /= wr_remainder_max then
        --   wr_remainder_cnt <= wr_remainder_cnt + 2;
        --   tready_bubble    <= '1';
        --   wr_row_cnt       <= (others => '0');
        --   wr_column_cnt <= wr_column_cnt + 1;
        else
          -- Only 
          if wr_remainder_max /= 0 and wr_column_cnt = 0 then
            wr_row_cnt_max <= wr_row_cnt_max - 1;
          end if;

          wr_row_cnt    <= (others => '0');

          if wr_column_cnt /= wr_column_cnt_max then
            wr_column_cnt <= wr_column_cnt + 1;
          else
            wr_column_cnt      <= (others => '0');

            wr_ram_ptr       <= wr_ram_ptr + 1;
          end if;
        end if;

        -- When the frame ends, hand over the parameters to the read side
        if s_tlast = '1' then
          ram_wren   <= (others => '0');
          -- Update the config
          cnt_cfg           := get_cnt_cfg(wr_cfg_modulation, wr_cfg_frame_type);
          rd_row_cnt_max    <= to_unsigned(cnt_cfg.row_max - 1, numbits(MAX_ROWS));
          rd_remainder_max  <= to_unsigned(cnt_cfg.row_remainder, numbits(DATA_WIDTH));
          rd_column_cnt_max <= to_unsigned(cnt_cfg.column_max - 1, numbits(MAX_COLUMNS));

          -- This will be used for the reading side
          rd_cfg_modulation <= wr_cfg_modulation;
          rd_cfg_frame_type <= wr_cfg_frame_type;
          rd_cfg_code_rate  <= wr_cfg_code_rate;

        end if;
      end if;

      -- Sample config
      if s_axi_dv = '1' and first_word = '1' then
        wr_cfg_modulation  <= cfg_modulation;
        wr_cfg_frame_type  <= cfg_frame_type;
        wr_cfg_code_rate   <= cfg_code_rate;

        cnt_cfg           := get_cnt_cfg(cfg_modulation, cfg_frame_type);
        wr_row_cnt_max    <= to_unsigned(cnt_cfg.row_max - 1, numbits(MAX_ROWS));
        wr_remainder_max  <= to_unsigned(cnt_cfg.row_remainder, numbits(DATA_WIDTH));
        wr_column_cnt_max <= to_unsigned(cnt_cfg.column_max - 1, numbits(MAX_COLUMNS));
      end if;

    end if;
  end process write_side_p;

  -------------------------------
  -- Handle read side pointers --
  -------------------------------
  read_side_p : process(clk, rst)
  begin
    if rst = '1' then
      rd_row_cnt <= (others => '0');
      rd_column_cnt <= (others => '0');
      rd_ram_ptr <= (others => '0');
    elsif clk'event and clk = '1' then

      m_wr_en   <= '0';
      m_wr_last <= '0';

      -- Data comes out of the RAMs 1 cycle after the address has changed, need to keep
      -- track of the actual value being handled
      rd_column_cnt_delay <= rd_column_cnt;
      m_wr_en_0           <= m_wr_en;
      m_wr_last_0         <= m_wr_last;

      if m_wr_full = '0' and rd_ram_ptr /= wr_ram_ptr then

        -- If pointers are different and the AXI adapter has space, keep writing
        m_wr_en <= '1';

        -- Read pointers control logic
        if rd_column_cnt /= rd_column_cnt_max then
          rd_column_cnt <= rd_column_cnt + 1;
        else
          rd_column_cnt <= (others => '0');

          if rd_row_cnt /= rd_row_cnt_max then
            rd_row_cnt <= rd_row_cnt + 1;
          else
            rd_row_cnt <= (others => '0');
            rd_ram_ptr <= rd_ram_ptr + 1;
            m_wr_last  <= '1';
          end if;
        end if;
      end if;

      if m_wr_en = '1' then
        if rd_column_cnt_delay = 0 then
          -- Assign to undefined so we can track in simulation the parts that we not
          -- assigned
          rd_data_sr <= (others => 'U');

          -- We'll swap byte ordering (e.g ABCD becomes DCBA) because it's easier to
          -- assign the write data from the shift register's LSB
          if rd_cfg_modulation = mod_8psk then
            if rd_cfg_code_rate = C3_5 then
              rd_data_sr(interleaved_3c'range) <= swap_bytes(interleaved_3c);
            else
              rd_data_sr(interleaved_3c'range) <= swap_bytes(interleaved_3c);
            end if;
          elsif rd_cfg_modulation = mod_16apsk then
            rd_data_sr(interleaved_4c'range) <= swap_bytes(interleaved_4c);
          elsif rd_cfg_modulation = mod_32apsk then
            rd_data_sr <= swap_bytes(interleaved_5c);
          end if;
        else
          -- We'll write the LSB, shift data right
          rd_data_sr <= (DATA_WIDTH - 1 downto 0 => 'U')
            & rd_data_sr(rd_data_sr'length - 1 downto DATA_WIDTH);
        end if;

      end if;

    end if;
  end process read_side_p;

  -- The config ports are valid at the first word of the frame, but we must not rely on
  -- the user keeping it unchanged. Hide this on a block to leave the core code a bit
  -- cleaner
  -- config_sample_block : block
  --   signal modulation_ff : modulation_t;
  --   signal frame_type_ff : frame_type_t;
  --   signal code_rate_ff  : code_rate_t;
  --   signal first_word    : std_logic;
  -- begin

  --   wr_cfg_modulation <= cfg_modulation when first_word = '1' else modulation_ff;
  --   wr_cfg_frame_type <= cfg_frame_type when first_word = '1' else frame_type_ff;
  --   wr_cfg_code_rate  <= cfg_code_rate when first_word = '1' else code_rate_ff;

  --   process(clk, rst)
  --     variable cnt_cfg : cnt_cfg_t;
  --   begin
  --     if rst = '1' then
  --       first_word  <= '1';
  --       wr_row_cnt_max <= (others => '1');
  --       wr_column_cnt_max <= (others => '1');
  --     elsif rising_edge(clk) then
  --       if s_axi_dv = '1' then
  --         first_word <= s_tlast;

  --         -- Sample the BCH code used on the first word
  --         if first_word = '1' then
  --           modulation_ff  <= cfg_modulation;
  --           frame_type_ff  <= cfg_frame_type;
  --           code_rate_ff   <= cfg_code_rate;

  --           cnt_cfg        := get_cnt_cfg(cfg_modulation, cfg_frame_type);
  --           wr_row_cnt_max   <= to_unsigned(cnt_cfg.row_max - 1, numbits(MAX_ROWS));
  --           wr_remainder_max <= to_unsigned(cnt_cfg.row_remainder, numbits(DATA_WIDTH));
  --           wr_column_cnt_max   <= to_unsigned(cnt_cfg.column_max - 1, numbits(MAX_COLUMNS));

  --         end if;

  --       end if;
  --     end if;
  --   end process;
  -- end block config_sample_block;


  -- process(clk, rst)
  -- begin
  --   if rst = '1' then
  --     row_rem_acc <= 0;
  --   elsif rising_edge(clk) then
  --     if ram_wren /= (MAX_COLUMNS - 1 downto 0 => '0') then
  --     end if;
  --   end if;
  -- end process;

end axi_bit_interleaver;

