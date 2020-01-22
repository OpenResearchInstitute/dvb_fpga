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
    clk               : in  std_logic;
    rst               : in  std_logic;

    cfg_constellation : in  constellation_t;
    cfg_frame_type    : in  frame_type_t;
    cfg_code_rate     : in  code_rate_t;

    -- AXI input
    s_tvalid          : in  std_logic;
    s_tdata           : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    s_tlast           : in  std_logic;
    s_tready          : out std_logic;

    -- AXI output
    m_tready          : in  std_logic;
    m_tvalid          : out std_logic;
    m_tlast           : out std_logic;
    m_tdata           : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end axi_bit_interleaver;

architecture axi_bit_interleaver of axi_bit_interleaver is

  ---------------
  -- Constants --
  ---------------
  constant MAX_ROWS    : integer := 21_600 / DATA_WIDTH;
  constant MAX_COLUMNS : integer := 5;

  type cfg_t is record
    rows      : unsigned(numbits(MAX_ROWS) - 1 downto 0);
    columns   : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);
    remainder : unsigned(numbits(DATA_WIDTH) - 1 downto 0);
  end record;

  impure function get_cnt_cfg (
    constant constellation : in constellation_t;
    constant frame_type    : in frame_type_t) return cfg_t is
    variable rows          : natural;
    variable columns       : natural;
    variable remainder     : natural;
  begin

    if frame_type = fecframe_normal then
      if constellation = mod_8psk then
        rows := 21_600;
      elsif constellation = mod_16apsk then
        rows := 16_200;
      elsif constellation = mod_32apsk then
        rows := 12_960;
      end if;
    elsif frame_type = fecframe_short then
      if constellation = mod_8psk then
        rows := 5_400;
      elsif constellation = mod_16apsk then
        rows := 4_050;
      elsif constellation = mod_32apsk then
        rows := 3_240;
      end if;
    end if;

    if constellation = mod_8psk then
      columns := 3;
    elsif constellation = mod_16apsk then
      columns := 4;
    elsif constellation = mod_32apsk then
      columns := 5;
    end if;

    -- We don't handle rows not being an integer multiple of DATA_WIDTH yet
    assert (rows mod DATA_WIDTH) = 0
      report "Frame type '" & frame_type_t'image(frame_type) & "', " &
             "constellation '" & constellation_t'image(constellation) &
             " is not supported yet with DATA_WIDTH " & integer'image(DATA_WIDTH)
      severity Error;

    return (rows      => to_unsigned((rows + DATA_WIDTH - 1 ) / DATA_WIDTH, numbits(MAX_ROWS)),
            columns   => to_unsigned(columns, numbits(MAX_COLUMNS)),
            remainder => to_unsigned(rows mod DATA_WIDTH, numbits(DATA_WIDTH)));

  end function get_cnt_cfg;

  type addr_array_t is array (natural range <>) of unsigned(numbits(MAX_ROWS) downto 0);
  type data_array_t is array (natural range <>) of std_logic_vector(DATA_WIDTH - 1 downto 0);

  -------------
  -- Signals --
  -------------
  signal s_axi_dv             : std_logic;
  signal s_tready_i           : std_logic;

  -- Write side config
  signal cfg_wr_constellation : constellation_t;
  signal cfg_wr_frame_type    : frame_type_t;
  signal cfg_wr_code_rate     : code_rate_t;
  signal cfg_wr_cnt           : cfg_t;
  -- Write side counters
  signal wr_row_cnt           : unsigned(numbits(MAX_ROWS) - 1 downto 0);
  signal wr_column_cnt        : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);
  signal wr_column_cnt_i      : natural range 0 to MAX_COLUMNS - 1;

  signal wr_ram_ptr           : unsigned(1 downto 0);


  signal wr_remainder         : unsigned(numbits(DATA_WIDTH) - 1 downto 0);

  -- RAM write interface
  signal ram_wr_addr          : addr_array_t(MAX_COLUMNS - 1 downto 0);
  signal ram_wr_data          : data_array_t(MAX_COLUMNS - 1 downto 0);
  signal ram_wr_en            : std_logic_vector(MAX_COLUMNS - 1 downto 0);

  -- Read side config
  signal cfg_rd_constellation : constellation_t;
  signal cfg_rd_frame_type    : frame_type_t;
  signal cfg_rd_code_rate     : code_rate_t;

  signal rd_ram_ptr           : unsigned(1 downto 0);

  signal cfg_rd_cnt           : cfg_t;
  signal rd_row_cnt           : unsigned(numbits(MAX_ROWS) - 1 downto 0);

  signal rd_column_cnt        : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);
  signal rd_column_cnt_prev   : unsigned(numbits(MAX_COLUMNS) - 1 downto 0);

  -- RAM read interface
  signal ram_rd_addr          : unsigned(numbits(MAX_ROWS) downto 0);
  signal ram_rd_data          : data_array_t(0 to MAX_COLUMNS - 1);

  signal rd_data_sr           : std_logic_vector(MAX_COLUMNS*DATA_WIDTH - 1 downto 0);

  signal interleaved_3c_012   : std_logic_vector(3*DATA_WIDTH - 1 downto 0);
  signal interleaved_3c_210   : std_logic_vector(3*DATA_WIDTH - 1 downto 0);
  signal interleaved_4c_0123  : std_logic_vector(4*DATA_WIDTH - 1 downto 0);
  signal interleaved_4c_3210  : std_logic_vector(4*DATA_WIDTH - 1 downto 0);
  signal interleaved_5c       : std_logic_vector(5*DATA_WIDTH - 1 downto 0);

  signal m_wr_en              : std_logic := '0';
  signal m_wr_en_prev         : std_logic := '0';
  signal m_wr_full            : std_logic;
  signal m_wr_data            : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal m_wr_last            : std_logic := '0';
  signal m_wr_last_prev       : std_logic := '0';

  signal first_word           : std_logic; -- To sample config

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
        wren_a    => ram_wr_en(column),
        addr_a    => std_logic_vector(ram_wr_addr(column)),
        wrdata_a  => ram_wr_data(column),
        rddata_a  => open,

        -- Port B
        clk_b     => clk,
        clken_b   => '1',
        addr_b    => std_logic_vector(ram_rd_addr),
        rddata_b  => ram_rd_data(column));
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
      -- Wannabe AXI interface
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
  m_wr_data <= mirror_bits(rd_data_sr(DATA_WIDTH - 1 downto 0));

  -- Assign the interleaved data statically
  iter_rows : for row in 0 to DATA_WIDTH - 1 generate
  begin
    iter_3_columns : for column in 0 to 2 generate
      interleaved_3c_012(3*DATA_WIDTH - (3 * row + column) - 1) <= ram_rd_data(column)(DATA_WIDTH - row - 1);
      interleaved_3c_210(3*DATA_WIDTH - (3 * row + column) - 1) <= ram_rd_data(2 - column)(DATA_WIDTH - row - 1);
    end generate;

    iter_4_columns : for column in 0 to 3 generate
      interleaved_4c_0123(4*DATA_WIDTH - (4 * row + column) - 1) <= ram_rd_data(column)(DATA_WIDTH - row - 1);
      interleaved_4c_3210(4*DATA_WIDTH - (4 * row + column) - 1) <= ram_rd_data(3 - column)(DATA_WIDTH - row - 1);
    end generate iter_4_columns;

    iter_5_columns : for column in 0 to 4 generate
      interleaved_5c(5*DATA_WIDTH - (5 * row + column) - 1) <= ram_rd_data(column)(DATA_WIDTH - row - 1);
    end generate iter_5_columns;
  end generate iter_rows;

  s_axi_dv        <= '1' when s_tready_i = '1' and s_tvalid = '1' else '0';
  s_tready_i      <= m_tready when wr_ram_ptr - rd_ram_ptr < 1 else '0';

  -- Assign internals
  s_tready        <= s_tready_i;
  wr_column_cnt_i <= to_integer(wr_column_cnt);

  --------------------------------
  -- Handle write side pointers --
  --------------------------------
  write_side_p : process(clk, rst)
  begin
    if rst = '1' then
      cfg_wr_cnt    <= (others => (others => '1'));

      wr_column_cnt <= (others => '0');
      wr_row_cnt    <= (others => '0');
      wr_remainder  <= (others => '0');
      wr_ram_ptr    <= (others => '0');

      first_word    <= '1';

      ram_wr_addr   <= (others => (others => '0'));

    elsif rising_edge(clk) then

      ram_wr_en         <= (others => '0');
      ram_wr_data(wr_column_cnt_i) <= s_tdata;

      -- Increment RAM addr every time it gets written
      for column in 0 to MAX_COLUMNS - 1 loop
        if ram_wr_en(column) = '1' then
          ram_wr_addr(column) <= ram_wr_addr(column) + 1;
        end if;
      end loop;

      -- Handle incoming AXI data
      if s_axi_dv = '1' then
        first_word                   <= s_tlast;

        ram_wr_en(wr_column_cnt_i)   <= '1';

        if wr_row_cnt < cfg_wr_cnt.rows - 1 then
          wr_row_cnt <= wr_row_cnt + 1;
        else
          wr_row_cnt <= (others => '0');

          if wr_column_cnt < cfg_wr_cnt.columns - 1 then
            wr_column_cnt <= wr_column_cnt + 1;
          else
            wr_column_cnt <= (others => '0');
            wr_ram_ptr    <= wr_ram_ptr + 1;
          end if;

        end if;

        if s_tlast = '1' then
          wr_ram_ptr <= wr_ram_ptr + 1;
        end if;

        if first_word = '1' then
          cfg_wr_cnt           <= get_cnt_cfg(cfg_constellation, cfg_frame_type);
          cfg_wr_constellation <= cfg_constellation;
          cfg_wr_frame_type    <= cfg_frame_type;
          cfg_wr_code_rate     <= cfg_code_rate;

          ram_wr_addr          <= (others => wr_ram_ptr(0) & (numbits(MAX_ROWS) - 1 downto 0 => '0'));
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
      rd_row_cnt      <= (others => '0');
      rd_column_cnt   <= (others => '0');
      rd_ram_ptr      <= (others => '0');
    elsif clk'event and clk = '1' then

      if s_axi_dv = '1' and s_tlast = '1' then
        cfg_rd_cnt           <= get_cnt_cfg(cfg_wr_constellation, cfg_wr_frame_type);

        -- This will be used for the reading side
        cfg_rd_constellation <= cfg_wr_constellation;
        cfg_rd_frame_type    <= cfg_wr_frame_type;
        cfg_rd_code_rate     <= cfg_wr_code_rate;

        ram_rd_addr <= rd_ram_ptr(0) & (numbits(MAX_ROWS) - 1 downto 0 => '0');

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
        if rd_column_cnt < cfg_rd_cnt.columns - 1 then
          rd_column_cnt <= rd_column_cnt + 1;
        else
          rd_column_cnt <= (others => '0');

          if rd_row_cnt < cfg_rd_cnt.rows - 1 then
            rd_row_cnt  <= rd_row_cnt + 1;
            ram_rd_addr <= ram_rd_addr + 1;
          else
            rd_row_cnt  <= (others => '0');
            rd_ram_ptr  <= rd_ram_ptr + 1;
            m_wr_last   <= '1';
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
          if cfg_rd_constellation = mod_8psk then
            if cfg_rd_code_rate = C3_5 then
              rd_data_sr(interleaved_3c_210'range) <= mirror_bits(interleaved_3c_210);
            else
              rd_data_sr(interleaved_3c_012'range) <= mirror_bits(interleaved_3c_012);
            end if;

          elsif cfg_rd_constellation = mod_16apsk then
            -- TODO: DVB-S2 doesn't specify a different interleaving sequence for code
            -- rate 3/5 and 16 APSK, only 8 PSK, check if the DVB-S2 extensions spec
            -- mentions anything. Leave like this for now as this agrees with GNU Radio's
            -- result
            if cfg_rd_code_rate = C3_5 then
              rd_data_sr(interleaved_4c_3210'range) <= mirror_bits(interleaved_4c_3210);
            else
              rd_data_sr(interleaved_4c_0123'range) <= mirror_bits(interleaved_4c_0123);
            end if;

          elsif cfg_rd_constellation = mod_32apsk then
            rd_data_sr <= mirror_bits(interleaved_5c);
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
