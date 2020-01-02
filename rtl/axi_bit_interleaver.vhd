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
    clk              : in  std_logic;
    rst              : in  std_logic;

    cfg_modulation   : in  modulation_type;
    cfg_frame_length : in  frame_length_type;
    cfg_ldpc_code    : in  ldpc_code_type;

    -- AXI input
    s_tvalid         : in  std_logic;
    s_tdata          : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    s_tlast          : in  std_logic;
    s_tready         : out std_logic;

    -- AXI output
    m_tready         : in  std_logic;
    m_tvalid         : out std_logic;
    m_tlast          : out std_logic;
    m_tdata          : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end axi_bit_interleaver;

architecture axi_bit_interleaver of axi_bit_interleaver is

  ---------------
  -- Constants --
  ---------------
  constant MAX_ROWS    : integer := 21_600 / DATA_WIDTH;
  constant MAX_COLUMNS : integer := 5;

  impure function get_max_row_ptr (
    constant modulation   : in modulation_type;
    constant frame_length : in frame_length_type) return integer is
    variable result     : integer := -1;
  begin
    if frame_length = normal then
      if modulation = mod_8_psk then
        result := 21_600;
      elsif modulation = mod_16_psk then
        result := 16_200;
      elsif modulation = mod_32_psk then
        result := 12_960;
      end if;
    elsif frame_length = short then
      if modulation = mod_8_psk then
        result := 5_400;
      elsif modulation = mod_16_psk then
        result := 4_050;
      elsif modulation = mod_32_psk then
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
    if modulation = mod_8_psk then
      result := 3;
    elsif modulation = mod_16_psk then
      result := 4;
    elsif modulation = mod_32_psk then
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
  signal modulation     : modulation_type;
  signal frame_length   : frame_length_type;
  signal ldpc_code      : ldpc_code_type;

  signal s_axi_dv       : std_logic;
  signal s_tready_i     : std_logic;

  signal m_axi_dv       : std_logic;
  signal m_tvalid_i     : std_logic := '0';
  signal m_tlast_i      : std_logic := '0';

  signal wr_row_ptr_max : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal wr_col_ptr_max : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);

  signal wr_row_ptr     : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal wr_col_ptr     : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal wr_ram_ptr     : unsigned(1 downto 0);

  signal ram_wren       : std_logic_vector(MAX_COLUMNS - 1 downto 0);
  signal ram_wraddr     : std_logic_vector(numbits(MAX_ROWS) downto 0);
  signal ram_wrdata     : std_logic_vector(DATA_WIDTH - 1 downto 0);

  signal rd_row_ptr_max : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal rd_col_ptr_max : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);
  signal rd_ram_ptr     : unsigned(1 downto 0);

  signal rd_row_ptr     : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal rd_col_ptr     : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);

  signal ram_rdaddr     : std_logic_vector(numbits(MAX_ROWS) downto 0);
  signal ram_rddata     : data_array_type(0 to MAX_COLUMNS - 1);

  signal rd_data_sr     : std_logic_vector(MAX_COLUMNS*DATA_WIDTH - 1 downto 0);

  signal interleaved_3_columns : std_logic_vector(3*DATA_WIDTH - 1 downto 0);
  signal interleaved_4_columns : std_logic_vector(4*DATA_WIDTH - 1 downto 0);
  signal interleaved_5_columns : std_logic_vector(5*DATA_WIDTH - 1 downto 0);

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

  -- Assign the interleaved data statically
  iter_rows : for row in 0 to DATA_WIDTH - 1 generate
    iter_columns : for column in 0 to 5 generate

      interleaved_columns_3 : if column < 3 generate
        interleaved_3_columns(3*DATA_WIDTH - (3 * row + column) - 1)
          <= ram_rddata(column)(DATA_WIDTH - row - 1);
      end generate interleaved_columns_3;

      interleaved_columns_4 : if column < 4 generate
        interleaved_4_columns(4*DATA_WIDTH - (4 * row + column) - 1) <=
          ram_rddata(column)(DATA_WIDTH - row - 1);
      end generate interleaved_columns_4;

      interleaved_columns_5 : if column < 5 generate
        interleaved_5_columns(5*DATA_WIDTH - (5 * row + column) - 1) <=
          ram_rddata(column)(DATA_WIDTH - row - 1);
      end generate interleaved_columns_5;

    end generate iter_columns;
  end generate iter_rows;

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  s_axi_dv <= '1' when s_tready_i = '1' and s_tvalid = '1' else '0';
  m_axi_dv <= '1' when m_tready = '1' and m_tvalid_i = '1' else '0';

  s_tready_i <= m_tready when wr_ram_ptr - rd_ram_ptr < 2 else '0';

  m_tvalid   <= m_tvalid_i;

  -- Assign internals
  s_tready <= s_tready_i;
  m_tvalid <= m_tvalid_i;
  m_tlast  <= m_tlast_i;

  ram_rdaddr <= rd_ram_ptr(0) & std_logic_vector(rd_row_ptr);

  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
    variable rd_data_sr_next : std_logic_vector(MAX_COLUMNS * DATA_WIDTH - 1 downto 0);
  begin
    if rst = '1' then
      wr_row_ptr     <= (others => '0');
      wr_col_ptr     <= (others => '0');
      wr_ram_ptr     <= (others => '0');

      rd_row_ptr_max <= (others => '1');
      rd_col_ptr_max <= (others => '1');

      rd_row_ptr     <= (others => '0');
      rd_col_ptr     <= (others => '0');
      rd_ram_ptr     <= (others => '0');
    elsif clk'event and clk = '1' then

      ram_wren <= (others => '0');

      -- Handle write side pointers
      if s_axi_dv = '1' then
        ram_wren(to_integer(wr_col_ptr)) <= '1';

        ram_wrdata <= s_tdata;
        ram_wraddr <= wr_ram_ptr(0) & std_logic_vector(wr_row_ptr);

        if wr_row_ptr = wr_row_ptr_max then
          wr_row_ptr <= (others => '0');

          if wr_col_ptr = wr_col_ptr_max then
            wr_col_ptr <= (others => '0');
          else
            wr_col_ptr <= wr_col_ptr + 1;
          end if;
        else
          wr_row_ptr <= wr_row_ptr + 1;
        end if;

        -- When the frame ends, hand over the parameters to the read side
        if s_tlast = '1' then
          wr_ram_ptr     <= wr_ram_ptr + 1;
          rd_row_ptr_max <= to_unsigned(get_max_row_ptr(modulation,
                                                        frame_length),
                                        numbits(MAX_ROWS));
          rd_col_ptr_max <= to_unsigned(get_max_column_ptr(modulation),
                                        numbits(MAX_COLUMNS));

          -- -- rd_col_ptr_max is the number of columns - 1
          -- if wr_col_ptr_max = 2 then -- 3 columns
          --   rd_data_sr_next := (2*DATA_WIDTH - 1 downto 0 => 'U')
          --     & swap_bytes(interleaved_3_columns);
          -- elsif wr_col_ptr_max = 3 then -- 4 columns
          --   rd_data_sr_next := (DATA_WIDTH - 1 downto 0 => 'U')
          --     & swap_bytes(interleaved_4_columns);
          -- elsif wr_col_ptr_max = 4 then -- 5 columns
          --   rd_data_sr_next := swap_bytes(interleaved_5_columns);
          -- end if;

          -- rd_data_sr <= rd_data_sr_next;

          -- m_tdata    <= rd_data_sr_next(DATA_WIDTH - 1 downto 0);
          -- m_tvalid_i <= '1';

        end if;
      end if;


      -- Handle read side pointers
      if rd_ram_ptr /= wr_ram_ptr then

        if rd_col_ptr = 0 then
          -- rd_col_ptr_max is the number of columns - 1
          if rd_col_ptr_max = 2 then -- 3 columns
            rd_data_sr_next := (2*DATA_WIDTH - 1 downto 0 => 'U')
              & swap_bytes(interleaved_3_columns);
          elsif rd_col_ptr_max = 3 then -- 4 columns
            rd_data_sr_next := (DATA_WIDTH - 1 downto 0 => 'U')
              & swap_bytes(interleaved_4_columns);
          elsif rd_col_ptr_max = 4 then -- 5 columns
            rd_data_sr_next := swap_bytes(interleaved_5_columns);
          end if;
        else
          rd_data_sr_next := (DATA_WIDTH - 1 downto 0 => 'U')
            & rd_data_sr(rd_data_sr'length - 1 downto DATA_WIDTH);
        end if;

        m_tdata    <= rd_data_sr_next(DATA_WIDTH - 1 downto 0);
        m_tvalid_i <= '1';

        rd_data_sr <= rd_data_sr_next;

        if rd_col_ptr = rd_col_ptr_max then
          rd_col_ptr <= (others => '0');

          if rd_row_ptr = rd_row_ptr_max then
            rd_row_ptr <= (others => '0');
            rd_ram_ptr <= rd_ram_ptr + 1;
          else
            rd_row_ptr <= rd_row_ptr + 1;
          end if;

        else
          rd_col_ptr <= rd_col_ptr + 1;
        end if;
      end if;

    end if;
  end process;

  -- The BCH code is valid at the first word of the frame, but we must not rely on the
  -- user keeping it unchanged. Hide this on a block to leave the core code a bit cleaner
  config_sample_block : block
    signal modulation_ff   : modulation_type;
    signal frame_length_ff : frame_length_type;
    signal ldpc_code_ff    : ldpc_code_type;
    signal first_word      : std_logic;
  begin

    modulation   <= cfg_modulation when first_word = '1' else modulation_ff;
    frame_length <= cfg_frame_length when first_word = '1' else frame_length_ff;
    ldpc_code    <= cfg_ldpc_code when first_word = '1' else ldpc_code_ff;

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
            modulation_ff   <= cfg_modulation;
            frame_length_ff <= cfg_frame_length;
            ldpc_code_ff    <= cfg_ldpc_code;

            wr_row_ptr_max  <= to_unsigned(get_max_row_ptr(cfg_modulation,
                                                           cfg_frame_length),
                                           numbits(MAX_ROWS));
            wr_col_ptr_max  <= to_unsigned(get_max_column_ptr(cfg_modulation),
                                           numbits(MAX_COLUMNS));
          end if;

        end if;
      end if;
    end process;
  end block config_sample_block;

end axi_bit_interleaver;

