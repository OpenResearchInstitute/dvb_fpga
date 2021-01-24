-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
--
-- DVB IP
--
-- Copyright 2020 by Anshul Makkar <anshulmakkar@gmail.com>
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.math_real.MATH_PI;

library fpga_cores;
use fpga_cores.common_pkg.all;
use fpga_cores.axi_pkg.all;

use work.dvb_utils_pkg.all;
use work.ldpc_pkg.all;
use work.plheader_tables_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_plframe_header is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    -- Usual ports
    clk                  : in  std_logic;
    rst                  : in  std_logic;
    -- Parameter input
    cfg_constellation    : in  constellation_t;
    cfg_code_rate        : in  code_rate_t;

    -- AXI data input
    s_tready             : out std_logic;
    s_tvalid             : in  std_logic;

    -- AXI output
    m_tready             : in  std_logic;
    m_tvalid             : out std_logic;
    m_tlast              : out std_logic;
    m_tdata              : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end axi_plframe_header;

architecture axi_plframe_header of axi_plframe_header is

  ---------------
  -- Constants --
  ---------------
  constant HEADER_ROM : std_logic_array_t := get_plframe_header_rom;

  -------------
  -- Signals --
  -------------
  signal addr   : std_logic_vector(numbits(HEADER_ROM'length) - 1 downto 0);
  signal header : std_logic_vector(PL_HDR_LEN -1 downto 0);

begin

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  addr <= (others => 'U') when get_modcode(cfg_constellation, cfg_code_rate) = -1 else
          std_logic_vector(to_unsigned(get_modcode(cfg_constellation, cfg_code_rate), numbits(HEADER_ROM'length)));

  -------------------
  -- Port Mappings --
  -------------------
  header_rom_u : entity fpga_cores.rom_inference
  generic map (
    ROM_DATA     => HEADER_ROM,
    ROM_TYPE     => lut,
    OUTPUT_DELAY => 0)
  port map (
    clk    => clk,
    clken  => '1',
    addr   => addr,
    rddata => header);

  width_conversion_u : entity fpga_cores.axi_stream_width_converter
  generic map (
    INPUT_DATA_WIDTH  => PL_HDR_LEN,
    OUTPUT_DATA_WIDTH => DATA_WIDTH)
  port map (
    -- Usual ports
    clk      => clk,
    rst      => rst,
    -- AXI stream input
    s_tready => s_tready,
    s_tdata  => header,
    s_tkeep  => (others => '1'),
    s_tid    => (others => '0'),
    s_tvalid => s_tvalid,
    s_tlast  => '1',
    -- AXI stream output
    m_tready  => m_tready,
    m_tdata   => m_tdata,
    m_tkeep   => open,
    m_tid     => open,
    m_tvalid  => m_tvalid,
    m_tlast   => m_tlast);

end axi_plframe_header;
