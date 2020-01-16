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
  constant MAX_ROWS    : integer := 21_600;
  constant MAX_COLUMNS : integer := 5;

  type cnt_cfg_t is record
    row_max    : integer;
    column_max : integer;
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

    return cfg;

  end function get_cnt_cfg;

  -- Read data is an array
  type data_array_t is array (natural range <>)
    of std_logic_vector(DATA_WIDTH - 1 downto 0);

  type column_array_t is array (natural range <>)
    of std_logic_vector(MAX_COLUMNS - 1 downto 0);

  -- We'll need to control RAMs somewhat independently, so pack the write port stuff on
  -- a record
  type ram_write_if_t is record
    addr : unsigned(numbits(MAX_ROWS) downto 0);
    data : std_logic_vector(DATA_WIDTH - 1 downto 0);
    en   : std_logic;
  end record;

  type ram_write_if_array_t is array (natural range <>) of ram_write_if_t;

  -------------
  -- Signals --
  -------------
  -- Write side config
  signal wr_cfg_modulation     : modulation_t;
  signal wr_cfg_frame_type     : frame_type_t;
  signal wr_cfg_code_rate      : code_rate_t;

  signal s_axi_dv              : std_logic;
  signal s_tready_i            : std_logic;
  signal s_tdata_prev          : std_logic_vector(DATA_WIDTH - 1 downto 0);

  signal cfg_wr_rows           : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal cfg_wr_column_cnt_max : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);

  signal wr_row_rem_bits       : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal wr_remainder          : unsigned(DATA_WIDTH - 1 downto 0);
  signal wr_remainder_prev     : unsigned(DATA_WIDTH - 1 downto 0);
  -- Using integer to make it easier to use as an index. Because the range has limits set,
  -- it should be synthesizable just like an unsigned whose width is numbits(MAX_ROWS) - 1
  signal wr_column_cnt         : natural range 0 to MAX_ROWS - 1;
  signal wr_column_cnt_prev    : natural range 0 to MAX_ROWS - 1;
  signal wr_ram_ptr            : unsigned(1 downto 0);

  -- Late RAM write
  signal wr_append_en          : std_logic;
  signal wr_append_start       : integer;

  -- Per RAM write interface
  signal ram_wr                : ram_write_if_array_t(0 to MAX_COLUMNS);

  signal wr_data_shift         : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal wr_data_shift_prev    : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal dbg_ram_wrdata        : data_array_t(0 to 3);

  signal rd_column_cnt_max     : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);
  signal rd_ram_ptr            : unsigned(1 downto 0);

  signal rd_row_cnt            : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal rd_column_cnt         : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);
  signal rd_column_cnt_prev    : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);

  signal ram_rdaddr            : unsigned(numbits(MAX_ROWS) downto 0);
  signal ram_rddata            : data_array_t(0 to MAX_COLUMNS - 1);

  -- Read side config
  signal rd_cfg_modulation     : modulation_t;
  signal rd_cfg_frame_type     : frame_type_t;
  signal rd_cfg_code_rate      : code_rate_t;

  signal rd_data_sr            : std_logic_vector(MAX_COLUMNS*DATA_WIDTH - 1 downto 0);

  signal interleaved_3c        : std_logic_vector(3*DATA_WIDTH - 1 downto 0);
  signal interleaved_4c        : std_logic_vector(4*DATA_WIDTH - 1 downto 0);
  signal interleaved_5c        : std_logic_vector(5*DATA_WIDTH - 1 downto 0);

  signal m_wr_en               : std_logic := '0';
  signal m_wr_en_prev          : std_logic := '0';
  signal m_wr_full             : std_logic;
  signal m_wr_data             : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal m_wr_last             : std_logic := '0';
  signal m_wr_last_prev        : std_logic := '0';

  signal first_word            : std_logic; -- To sample config

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
        wren_a    => ram_wr(column).en,
        addr_a    => std_logic_vector(ram_wr(column).addr),
        wrdata_a  => ram_wr(column).data,
        rddata_a  => open,

        -- Port B
        clk_b     => clk,
        clken_b   => '1',
        addr_b    => std_logic_vector(ram_rdaddr),
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
      wr_en    => m_wr_en_prev,
      wr_full  => m_wr_full,
      wr_data  => m_wr_data,
      wr_last  => m_wr_last_prev,
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
    iter_3_columns : for column in 0 to 2 generate
      interleaved_3c(3*DATA_WIDTH - (3 * row + column) - 1) <= ram_rddata(column)(DATA_WIDTH - row - 1);
    end generate;

    iter_4_columns : for column in 0 to 3 generate
      interleaved_4c(4*DATA_WIDTH - (4 * row + column) - 1) <= ram_rddata(column)(DATA_WIDTH - row - 1);
    end generate iter_4_columns;

    iter_5_columns : for column in 0 to 4 generate
      interleaved_5c(5*DATA_WIDTH - (5 * row + column) - 1) <= ram_rddata(column)(DATA_WIDTH - row - 1);
    end generate iter_5_columns;
  end generate iter_rows;


  s_axi_dv <= '1' when s_tready_i = '1' and s_tvalid = '1' else '0';

  s_tready_i <= m_tready when wr_ram_ptr - rd_ram_ptr < 2 else '0';

  -- Assign internals
  s_tready <= s_tready_i;

  -- Debug
  dbg_ram_wrdata <= (
                    0 => s_tdata,
                    1 => s_tdata_prev(DATA_WIDTH - 3 downto 0) & s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH - 2),
                    2 => s_tdata_prev(DATA_WIDTH - 5 downto 0) & s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH - 4),
                    3 => s_tdata_prev(DATA_WIDTH - 7 downto 0) & s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH - 6));

  wr_data_shift <= s_tdata when wr_remainder = 0 else
                   s_tdata_prev(DATA_WIDTH - to_integer(wr_remainder) - 1 downto 0)
                   & s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH - to_integer(wr_remainder));

  wr_data_shift_prev <= s_tdata when wr_remainder_prev = 0 else
                        s_tdata_prev(DATA_WIDTH - to_integer(wr_remainder_prev) - 1 downto 0)
                        & s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH - to_integer(wr_remainder_prev));

  --------------------------------
  -- Handle write side pointers --
  --------------------------------
  write_side_p : process(clk, rst)
    variable cnt_cfg        : cnt_cfg_t;
    variable data_slice_ptr : integer; -- Just an alias to make stuff more visible
  begin
    if rst = '1' then
      cfg_wr_rows       <= (others => '0');

      wr_column_cnt     <= 0;
      wr_row_rem_bits   <= (others => '1');
      wr_remainder      <= (others => '0');
      wr_ram_ptr        <= (others => '0');


      first_word        <= '1';
      cfg_wr_column_cnt_max <= (others => '1');

      for column in ram_wr'range loop
        ram_wr(column).addr <= (others => '0');
      end loop;


    elsif rising_edge(clk) then
      wr_remainder_prev  <= wr_remainder;
      wr_append_en <= '0';


      for column in ram_wr'range loop
        ram_wr(column).en   <= '0';
        if ram_wr(column).en = '1' then
          ram_wr(column).addr <= ram_wr(column).addr + 1;
        end if;
        ram_wr(column).data <= wr_data_shift;
      end loop;


      -- FIXME: this might not work if AXI data is not back to back!
      if wr_append_en = '1' then
         ram_wr(wr_column_cnt_prev).en   <= '1';
         ram_wr(wr_column_cnt_prev).data <= (others => '0');
         ram_wr(wr_column_cnt_prev).data(wr_append_start - 1 downto 0) <= wr_data_shift_prev(DATA_WIDTH - 1 downto DATA_WIDTH - wr_append_start);
      end if;


      if s_axi_dv = '1' then
        first_word         <= s_tlast;

        s_tdata_prev       <= s_tdata;
        wr_column_cnt_prev <= wr_column_cnt;

        ram_wr(wr_column_cnt).en <= '1';

        -- When the number of rows is not an integer multiple of DATA_WIDTH, the remaining
        -- bits will fall somewhere between 0 and DATA_WIDTH. In those cases, there'll be
        -- specific handling
        if wr_row_rem_bits > DATA_WIDTH then
          wr_row_rem_bits  <= wr_row_rem_bits - DATA_WIDTH;
       else
         -- Track how many partial bits we've handled - the actual data will need to be
         -- shifted differently each time
         wr_remainder <= wr_remainder + wr_row_rem_bits(DATA_WIDTH - 1 downto 0);

         -- Handle the last word of a column whose number of rows is not an integer
         -- multiple of the DATA_WIDTH - write the remainder MSB bits of the data to the
         -- column RAM.
         if wr_remainder = 0 then
           data_slice_ptr := to_integer(wr_row_rem_bits(DATA_WIDTH - 1 downto 0));

           -- Mark the MSB as undefined to track this on simulation
           ram_wr(wr_column_cnt).data <= (DATA_WIDTH - 1 downto data_slice_ptr => 'U') &
                                         wr_data_shift(DATA_WIDTH - 1 downto DATA_WIDTH - data_slice_ptr);
         else
           -- For every end of column after the first one, we do not have the data needed
           -- to fill in the RAM. In this case, schedule a write to the next cycle where
           -- there is incoming data
           wr_append_en    <= '1';
           wr_append_start <= to_integer(wr_row_rem_bits(DATA_WIDTH - 1 downto 0));
         end if;

          -- Chain counters
          wr_row_rem_bits <= cfg_wr_rows;
          if wr_column_cnt /= cfg_wr_column_cnt_max then
            wr_column_cnt <= wr_column_cnt + 1;
          else
            wr_column_cnt <= 0;
            wr_ram_ptr    <= wr_ram_ptr + 1;
          end if;

        end if;

      end if;

      -- Sample config. Limits are set to out of bounds and there will never be 1 or
      -- 2 cycle frames, so we don't need to be very
      if s_axi_dv = '1' and first_word = '1' then
        wr_cfg_modulation  <= cfg_modulation;
        wr_cfg_frame_type  <= cfg_frame_type;
        wr_cfg_code_rate   <= cfg_code_rate;

        cnt_cfg               := get_cnt_cfg(cfg_modulation, cfg_frame_type);
        cfg_wr_rows           <= to_unsigned(cnt_cfg.row_max - DATA_WIDTH, numbits(MAX_ROWS));
        cfg_wr_column_cnt_max <= to_unsigned(cnt_cfg.column_max - 1, numbits(MAX_COLUMNS));
        wr_row_rem_bits       <= to_unsigned(cnt_cfg.row_max - DATA_WIDTH, numbits(MAX_ROWS));
      end if;

    end if;
  end process write_side_p;

  -------------------------------
  -- Handle read side pointers --
  -------------------------------
  read_side_p : process(clk, rst)
    variable cnt_cfg : cnt_cfg_t;
  begin
    if rst = '1' then
      rd_row_cnt        <= (others => '1');
      rd_column_cnt     <= (others => '0');
      rd_ram_ptr        <= (others => '0');

      rd_column_cnt_max <= (others => '1');

    elsif clk'event and clk = '1' then

      if s_axi_dv = '1' and s_tlast = '1' then
        cnt_cfg           := get_cnt_cfg(wr_cfg_modulation, wr_cfg_frame_type);
        rd_row_cnt        <= to_unsigned(cnt_cfg.row_max, numbits(MAX_ROWS));
        rd_column_cnt_max <= to_unsigned(cnt_cfg.column_max - 1, numbits(MAX_COLUMNS));

          -- This will be used for the reading side
        rd_cfg_modulation <= wr_cfg_modulation;
        rd_cfg_frame_type <= wr_cfg_frame_type;
        rd_cfg_code_rate  <= wr_cfg_code_rate;

        ram_rdaddr <= rd_ram_ptr(0) & (numbits(MAX_ROWS) - 1 downto 0 => '0');

      end if;

      m_wr_en   <= '0';
      m_wr_last <= '0';

      -- Data comes out of the RAMs 1 cycle after the address has changed, need to keep
      -- track of the actual value being handled
      rd_column_cnt_prev <= rd_column_cnt;
      m_wr_en_prev       <= m_wr_en;
      m_wr_last_prev     <= m_wr_last;

      if m_wr_full = '0' and rd_ram_ptr /= wr_ram_ptr then

        -- If pointers are different and the AXI adapter has space, keep writing
        m_wr_en <= '1';

        -- Read pointers control logic
        if rd_column_cnt /= rd_column_cnt_max then
          rd_column_cnt <= rd_column_cnt + 1;
        else
          rd_column_cnt <= (others => '0');

          if rd_row_cnt > DATA_WIDTH then
            rd_row_cnt <= rd_row_cnt - DATA_WIDTH;
            ram_rdaddr <= ram_rdaddr + 1;
          else
            rd_row_cnt <= (others => '1');

            rd_ram_ptr <= rd_ram_ptr + 1;
            m_wr_last  <= '1';
          end if;
        end if;
      end if;

      if m_wr_en = '1' then
        if rd_column_cnt_prev = 0 then
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

end axi_bit_interleaver;
