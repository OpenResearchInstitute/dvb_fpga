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

    cfg_modulation : in  modulation_type;
    cfg_frame_type : in  frame_length_type;
    cfg_code_rate  : in  code_rate_type;

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

  impure function get_max_row_ptr (
    constant modulation : in modulation_type;
    constant frame_type : in frame_length_type) return integer is
    variable result     : integer := -1;
  begin
    if frame_type = normal then
      if modulation = mod_8psk then
        result := 21_600;
      elsif modulation = mod_16apsk then
        result := 16_200;
      elsif modulation = mod_32apsk then
        result := 12_960;
      end if;
    elsif frame_type = short then
      if modulation = mod_8psk then
        result := 5_400;
      elsif modulation = mod_16apsk then
        result := 4_050;
      elsif modulation = mod_32apsk then
        result := 3_240;
      end if;
    end if;

    assert result /= -1
      report "Could not determine max row count!"
      severity Failure;

    return (result / DATA_WIDTH) - 1;

  end function get_max_row_ptr;

  impure function get_max_column_ptr (
    constant modulation : in modulation_type) return integer is
    variable result     : integer := -1;
  begin
    if modulation = mod_8psk then
      result := 3;
    elsif modulation = mod_16apsk then
      result := 4;
    elsif modulation = mod_32apsk then
      result := 5;
    end if;

    assert result /= -1
      report "Could not determine max row count!"
      severity Failure;

    return result - 1;

  end function get_max_column_ptr;

  -- Read data is an array
  type data_array_type is array (natural range <>)
    of std_logic_vector(DATA_WIDTH - 1 downto 0);

  type column_array_type is array (natural range <>)
    of std_logic_vector(MAX_COLUMNS - 1 downto 0);

  -------------
  -- Signals --
  -------------
  -- Write side config
  signal wr_cfg_modulation  : modulation_type;
  signal wr_cfg_frame_type  : frame_length_type;
  signal wr_cfg_code_rate   : code_rate_type;

  signal s_axi_dv           : std_logic;
  signal s_tready_i         : std_logic;

  signal wr_row_ptr_max     : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal wr_col_ptr_max     : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);

  signal wr_row_ptr         : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal wr_col_ptr         : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal wr_ram_ptr         : unsigned(1 downto 0);

  signal ram_wren           : std_logic_vector(MAX_COLUMNS - 1 downto 0);
  signal ram_wraddr         : std_logic_vector(numbits(MAX_ROWS) downto 0);
  signal ram_wrdata         : std_logic_vector(DATA_WIDTH - 1 downto 0);

  signal rd_row_ptr_max     : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal rd_col_ptr_max     : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);
  signal rd_ram_ptr         : unsigned(1 downto 0);

  signal rd_row_ptr         : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal rd_col_ptr         : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);
  signal rd_col_ptr_0       : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);

  signal ram_rdaddr         : std_logic_vector(numbits(MAX_ROWS) downto 0);
  signal ram_rddata         : data_array_type(0 to MAX_COLUMNS - 1);

  -- Read side config
  signal rd_cfg_modulation  : modulation_type;
  signal rd_cfg_frame_type  : frame_length_type;
  signal rd_cfg_code_rate   : code_rate_type;

  signal rd_data_sr         : std_logic_vector(MAX_COLUMNS*DATA_WIDTH - 1 downto 0);

  signal interleaved_3_cols : std_logic_vector(3*DATA_WIDTH - 1 downto 0);
  signal interleaved_4_cols : std_logic_vector(4*DATA_WIDTH - 1 downto 0);
  signal interleaved_5_cols : std_logic_vector(5*DATA_WIDTH - 1 downto 0);

  signal m_wr_en            : std_logic := '0';
  signal m_wr_en_0          : std_logic := '0';
  signal m_wr_full          : std_logic;
  signal m_wr_data          : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal m_wr_last          : std_logic := '0';
  signal m_wr_last_0        : std_logic := '0';

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
        interleaved_3_cols(3*DATA_WIDTH - (3 * row + column) - 1)
          <= ram_rddata(column)(DATA_WIDTH - row - 1);
      end generate interleaved_columns_3;

      interleaved_columns_4 : if column < 4 generate
        interleaved_4_cols(4*DATA_WIDTH - (4 * row + column) - 1)
          <= ram_rddata(column)(DATA_WIDTH - row - 1);
      end generate interleaved_columns_4;

      interleaved_columns_5 : if column < 5 generate
        interleaved_5_cols(5*DATA_WIDTH - (5 * row + column) - 1)
          <= ram_rddata(column)(DATA_WIDTH - row - 1);
      end generate interleaved_columns_5;

    end generate iter_columns;
  end generate iter_rows;


  s_axi_dv <= '1' when s_tready_i = '1' and s_tvalid = '1' else '0';

  s_tready_i <= m_tready when wr_ram_ptr - rd_ram_ptr < 2 else '0';

  -- Assign internals
  s_tready <= s_tready_i;

  ram_rdaddr <= rd_ram_ptr(0) & std_logic_vector(rd_row_ptr);

  --------------------------------
  -- Handle write side pointers --
  --------------------------------
  write_side_p : process(clk, rst)
  begin
    if rst = '1' then
      wr_row_ptr     <= (others => '0');
      wr_col_ptr     <= (others => '0');
      wr_ram_ptr     <= (others => '0');

      rd_row_ptr_max <= (others => '1');
      rd_col_ptr_max <= (others => '1');

    elsif clk'event and clk = '1' then

      ram_wren <= (others => '0');

      if s_axi_dv = '1' then
        ram_wren(to_integer(wr_col_ptr)) <= '1';

        ram_wrdata <= s_tdata;
        ram_wraddr <= wr_ram_ptr(0) & std_logic_vector(wr_row_ptr);

        if wr_row_ptr /= wr_row_ptr_max then
          wr_row_ptr <= wr_row_ptr + 1;
        else
          wr_row_ptr <= (others => '0');

          if wr_col_ptr /= wr_col_ptr_max then
            wr_col_ptr <= wr_col_ptr + 1;
          else
            wr_col_ptr <= (others => '0');
          end if;
        end if;

        -- When the frame ends, hand over the parameters to the read side
        if s_tlast = '1' then
          wr_ram_ptr     <= wr_ram_ptr + 1;
          rd_row_ptr_max <= to_unsigned(get_max_row_ptr(wr_cfg_modulation,
                                                        wr_cfg_frame_type),
                                        numbits(MAX_ROWS));
          rd_col_ptr_max <= to_unsigned(get_max_column_ptr(wr_cfg_modulation),
                                        numbits(MAX_COLUMNS));

          -- This will be used for the reading side
          rd_cfg_modulation <= wr_cfg_modulation;
          rd_cfg_frame_type <= wr_cfg_frame_type;
          rd_cfg_code_rate  <= wr_cfg_code_rate;

        end if;
      end if;
    end if;
  end process write_side_p;

  -------------------------------
  -- Handle read side pointers --
  -------------------------------
  read_side_p : process(clk, rst)
  begin
    if rst = '1' then
      rd_row_ptr <= (others => '0');
      rd_col_ptr <= (others => '0');
      rd_ram_ptr <= (others => '0');
    elsif clk'event and clk = '1' then

      m_wr_en   <= '0';
      m_wr_last <= '0';

      -- Data comes out of the RAMs 1 cycle after the address has changed, need to keep
      -- track of the actual value being handled
      rd_col_ptr_0 <= rd_col_ptr;
      m_wr_en_0    <= m_wr_en;
      m_wr_last_0  <= m_wr_last;

      if m_wr_full = '0' and rd_ram_ptr /= wr_ram_ptr then

        -- If pointers are different and the AXI adapter has space, keep writing
        m_wr_en <= '1';

        -- Read pointers control logic
        if rd_col_ptr /= rd_col_ptr_max then
          rd_col_ptr <= rd_col_ptr + 1;
        else
          rd_col_ptr <= (others => '0');

          if rd_row_ptr /= rd_row_ptr_max then
            rd_row_ptr <= rd_row_ptr + 1;
          else
            rd_row_ptr <= (others => '0');
            rd_ram_ptr <= rd_ram_ptr + 1;
            m_wr_last  <= '1';
          end if;
        end if;
      end if;

      if m_wr_en = '1' then
        if rd_col_ptr_0 = 0 then
          -- Assign to undefined so we can track in simulation the parts that we not
          -- assigned
          rd_data_sr <= (others => 'U');

          -- We'll swap byte ordering (e.g ABCD becomes DCBA) because it's easier to
          -- assign the write data from the shift register's LSB
          if rd_cfg_modulation = mod_8psk then
            if rd_cfg_code_rate = C3_5 then
              rd_data_sr(interleaved_3_cols'range)
                <= swap_bytes(swap_bits(interleaved_3_cols));
            else
              rd_data_sr(interleaved_3_cols'range) <= swap_bytes(interleaved_3_cols);
            end if;
          elsif rd_cfg_modulation = mod_16apsk then
            rd_data_sr(interleaved_4_cols'range) <= swap_bytes(interleaved_4_cols);
          elsif rd_cfg_modulation = mod_32apsk then
            rd_data_sr <= swap_bytes(interleaved_5_cols);
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
  config_sample_block : block
    signal modulation_ff : modulation_type;
    signal frame_type_ff : frame_length_type;
    signal code_rate_ff  : code_rate_type;
    signal first_word    : std_logic;
  begin

    wr_cfg_modulation <= cfg_modulation when first_word = '1' else modulation_ff;
    wr_cfg_frame_type <= cfg_frame_type when first_word = '1' else frame_type_ff;
    wr_cfg_code_rate  <= cfg_code_rate when first_word = '1' else code_rate_ff;

    process(clk, rst)
    begin
      if rst = '1' then
        first_word  <= '1';
        wr_row_ptr_max <= (others => '1');
        wr_col_ptr_max <= (others => '1');
      elsif rising_edge(clk) then
        if s_axi_dv = '1' then
          first_word <= s_tlast;

          -- Sample the BCH code used on the first word
          if first_word = '1' then
            modulation_ff  <= cfg_modulation;
            frame_type_ff  <= cfg_frame_type;
            code_rate_ff   <= cfg_code_rate;

            wr_row_ptr_max <= to_unsigned(get_max_row_ptr(cfg_modulation,
                                                          cfg_frame_type),
                                          numbits(MAX_ROWS));
            wr_col_ptr_max <= to_unsigned(get_max_column_ptr(cfg_modulation),
                                          numbits(MAX_COLUMNS));
          end if;

        end if;
      end if;
    end process;
  end block config_sample_block;

end axi_bit_interleaver;

