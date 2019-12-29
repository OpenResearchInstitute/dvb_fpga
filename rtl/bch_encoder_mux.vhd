--
-- DVB FPGA
--
-- Copyright 2019 by Andre Souto (suoto)
--
-- This file is part of DVB FPGA.
--
-- DVB FPGA is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- DVB FPGA is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DVB FPGA.  If not, see <http://www.gnu.org/licenses/>.

---------------
-- Libraries --
---------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bch_encoder_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity bch_encoder_mux is
  generic  ( DATA_WIDTH : integer := 8);
  port (
    clk              : in std_logic;
    rst              : in std_logic;
    --
    cfg_bch_code_in  : in  std_logic_vector(1 downto 0);
    first_word       : in std_logic; -- First data. 1: SEED is used (initialise and calculate), 0: Previous CRC is used (continue and calculate)
    wr_en            : in std_logic; -- New Data. wr_data input has a valid data. Calculate new CRC
    wr_data          : in std_logic_vector(DATA_WIDTH - 1 downto 0);  -- Data in

    --
    cfg_bch_code_out : out std_logic_vector(1 downto 0);
    crc_rdy          : out std_logic;
    crc              : out std_logic_vector(191 downto 0);
    data_out         : out std_logic_vector(DATA_WIDTH - 1 downto 0) -- Data output
  );
end bch_encoder_mux;

architecture bch_encoder_mux of bch_encoder_mux is

  ---------------
  -- Constants --
  ---------------
  constant NUMBER_OF_ENTRIES : integer := 3;
  constant CRC_WIDTH         : integer := 192;

  -----------
  -- Types --
  -----------
  type data_array_type is array(natural range <>) of std_logic_vector(DATA_WIDTH - 1 downto 0);
  type crc_array_type is array(natural range <>) of std_logic_vector(CRC_WIDTH - 1 downto 0);

  -------------
  -- Signals --
  -------------
  signal in_mux_ptr         : integer range 0 to 2;
  signal out_mux_ptr        : integer range 0 to 2;

  signal cfg_bch_code_out_i : std_logic_vector(1 downto 0);
  signal wr_en_array        : std_logic_vector(NUMBER_OF_ENTRIES - 1 downto 0);

  signal crc_rdy_array      : std_logic_vector(NUMBER_OF_ENTRIES - 1 downto 0);
  signal data_out_array     : data_array_type(NUMBER_OF_ENTRIES - 1 downto 0);
  signal crc_out_array      : crc_array_type(NUMBER_OF_ENTRIES - 1 downto 0);

begin

  -------------------
  -- Port mappings --
  -------------------
  -- Data gets ready after a couple of cycles, need to index them independently
  mux_ptr_delay_u : entity work.sr_delay
    generic map (
      DELAY_CYCLES  => 3,
      DATA_WIDTH    => 2,
      EXTRACT_SHREG => True)
    port map (
      clk     => clk,
      clken   => '1',

      din     => cfg_bch_code_in,
      dout    => cfg_bch_code_out_i);

  -- instantiate BCH blocks for DATA_WIDTH = 8
  g_dw_8 : if DATA_WIDTH = 8 generate
    signal crc_192_ulogic      : std_ulogic_vector(191 downto 0);
    signal data_out_192_ulogic : std_ulogic_vector(7 downto 0);
    
    signal crc_160_ulogic      : std_ulogic_vector(159 downto 0);
    signal data_out_160_ulogic : std_ulogic_vector(7 downto 0);

    signal crc_128_ulogic      : std_ulogic_vector(127 downto 0);
    signal data_out_128_ulogic : std_ulogic_vector(7 downto 0);

  begin
    bch_192_u : entity work.bch_192x8
      generic map (SEED => (others => '0'))
      port map (
        clk   => clk,
        reset => rst,
        fd    => first_word,
        nd    => wr_en_array(BCH_POLY_12),
        rdy   => crc_rdy_array(BCH_POLY_12),
        d     => std_ulogic_vector(wr_data),
        c     => crc_192_ulogic,
        -- CRC output
        o     => data_out_192_ulogic);

    bch_160_u : entity work.bch_160x8
      generic map (SEED => (others => '0'))
      port map (
        clk   => clk,
        reset => rst,
        fd    => first_word,
        nd    => wr_en_array(BCH_POLY_10),
        rdy   => crc_rdy_array(BCH_POLY_10),
        d     => std_ulogic_vector(wr_data),
        c     => crc_160_ulogic,
        -- CRC output
        o     => data_out_160_ulogic);

    bch_128_u : entity work.bch_128x8
      generic map (SEED => (others => '0'))
      port map (
        clk   => clk,
        reset => rst,
        fd    => first_word,
        nd    => wr_en_array(BCH_POLY_8),
        rdy   => crc_rdy_array(BCH_POLY_8),
        d     => std_ulogic_vector(wr_data),
        c     => crc_128_ulogic,
        -- CRC output
        o     => data_out_128_ulogic);

    -- Assign vector outpus
    crc_out_array(BCH_POLY_12)               <= std_logic_vector(crc_192_ulogic);
    data_out_array(BCH_POLY_12)              <= std_logic_vector(data_out_192_ulogic);

    crc_out_array(BCH_POLY_10)(159 downto 0) <= std_logic_vector(crc_160_ulogic);
    data_out_array(BCH_POLY_10)              <= std_logic_vector(data_out_160_ulogic);

    crc_out_array(BCH_POLY_8)(127 downto 0)  <= std_logic_vector(crc_128_ulogic);
    data_out_array(BCH_POLY_8)               <= std_logic_vector(data_out_128_ulogic);

  end generate;


  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  cfg_bch_code_out <= cfg_bch_code_out_i;

  in_mux_ptr       <= to_integer(unsigned(cfg_bch_code_in));
  out_mux_ptr      <= to_integer(unsigned(cfg_bch_code_out_i));

  wr_en_array(BCH_POLY_8)  <= wr_en when in_mux_ptr = BCH_POLY_8 else '0';
  wr_en_array(BCH_POLY_10) <= wr_en when in_mux_ptr = BCH_POLY_10 else '0';
  wr_en_array(BCH_POLY_12) <= wr_en when in_mux_ptr = BCH_POLY_12 else '0';

  crc_rdy  <= crc_rdy_array(out_mux_ptr);
  crc      <= crc_out_array(out_mux_ptr);
  data_out <= data_out_array(out_mux_ptr);

    ---------------
    -- Processes --
    ---------------
    -- process(clk, rst)
    -- begin
    --     if rst = '1' then
    --         null;
    --     elsif clk'event and clk = '1' then
    --         if clken = '1' then

    --         end if;
    --     end if;
    -- end process;


end bch_encoder_mux;
