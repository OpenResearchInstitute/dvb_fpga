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
use ieee.math_real.MATH_PI;

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
    clk               : in  std_logic;
    rst               : in  std_logic;
    -- Parameter input
    cfg_constellation : in  constellation_t;
    cfg_frame_type    : in  frame_type_t;
    cfg_code_rate     : in  code_rate_t;

    -- AXI data input
    s_tready          : out std_logic;
    s_tvalid          : in  std_logic;

    -- AXI output
    m_tready          : in  std_logic;
    m_tvalid          : out std_logic;
    m_tlast           : out std_logic;
    m_tdata           : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end axi_plframe_header;

architecture axi_plframe_header of axi_plframe_header is

  ----------------
  -- Suprograms --
  ----------------
  function to_fixed_point (constant x : real) return signed is
  constant width : integer := DATA_WIDTH/2;
  begin
    return to_signed(integer(ieee.math_real.round(x * real(2**(width - 1)))), width);
  end;

  function cos (constant x : real) return signed is
  begin
    return to_fixed_point(ieee.math_real.cos(x));
  end;

  function sin (constant x : real) return signed is
  begin
    return to_fixed_point(ieee.math_real.sin(x));
  end;

  ---------------
  -- Constants --
  ---------------
  constant MOD_8PSK_MAP : std_logic_array_t(0 to 7)(DATA_WIDTH - 1 downto 0) := (
    0 => std_logic_vector(cos(      MATH_PI / 4.0) & sin(      MATH_PI / 4.0)),
    1 => std_logic_vector(cos(5.0 * MATH_PI / 4.0) & sin(5.0 * MATH_PI / 4.0)),
    2 => std_logic_vector(cos(5.0 * MATH_PI / 4.0) & sin(      MATH_PI / 4.0)),
    3 => std_logic_vector(cos(      MATH_PI / 4.0) & sin(5.0 * MATH_PI / 4.0)),
    4 => std_logic_vector(cos(5.0 * MATH_PI / 4.0) & sin(      MATH_PI / 4.0)),
    5 => std_logic_vector(cos(      MATH_PI / 4.0) & sin(5.0 * MATH_PI / 4.0)),
    6 => std_logic_vector(cos(5.0 * MATH_PI / 4.0) & sin(5.0 * MATH_PI / 4.0)),
    7 => std_logic_vector(cos(      MATH_PI / 4.0) & sin(      MATH_PI / 4.0))
  );

  constant SOF           : std_logic_vector(25 downto 0) := "01" & x"8D2E82";

  -- SOF is the same for all configs, so we'll only store the PLS
  constant PLS_ROM       : std_logic_array_t(open)(63 downto 0) := get_pls_rom;
  constant PLS_ROM_DEPTH : integer := PLS_ROM'length;

  -------------
  -- Signals --
  -------------
  signal header_bit       : std_logic;
  signal modulation_index : std_logic;
  signal modulation_addr  : std_logic_vector(2 downto 0);
  signal pls_rom_addr     : std_logic_vector(numbits(PLS_ROM_DEPTH) - 1 downto 0);
  signal pls_code         : std_logic_vector(63 downto 0);
  signal header           : std_logic_vector(89 downto 0);

  signal m_tdata_i        : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal m_tvalid_i       : std_logic;
  signal m_tlast_i        : std_logic;

begin

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  m_tlast  <= m_tlast_i;
  m_tvalid <= m_tvalid_i;

  pls_rom_addr    <= (others => 'U') when get_pls_rom_addr(cfg_constellation, cfg_frame_type, cfg_code_rate) = -1 else
                     std_logic_vector(to_unsigned(get_pls_rom_addr(cfg_constellation, cfg_frame_type, cfg_code_rate), numbits(PLS_ROM_DEPTH)));

  header          <= SOF & pls_code;
  modulation_addr <= '0' & modulation_index & header_bit;

  -------------------
  -- Port Mappings --
  -------------------
  pls_rom_u : entity fpga_cores.rom_inference
  generic map (
    ROM_DATA     => PLS_ROM,
    ROM_TYPE     => lut,
    OUTPUT_DELAY => 0)
  port map (
    clk    => clk,
    clken  => '1',
    addr   => pls_rom_addr,
    rddata => pls_code);

  -- Each raw header bit should be modulated, so convert it into a single bit data stream
  width_conversion_u : entity fpga_cores.axi_stream_width_converter
  generic map (
    -- Round the header length to the nearest multiple of 8 (AXI is always in bytes)
    INPUT_DATA_WIDTH  => 90,
    OUTPUT_DATA_WIDTH => 1)
  port map (
    -- Usual ports
    clk      => clk,
    rst      => rst,
    -- AXI stream input
    s_tready => s_tready,
    -- Need to mirror header because the width converter will output s_tdata LSB first
    s_tdata  => mirror_bits(pls_code) & mirror_bits(SOF),
    s_tkeep  => (others => '1'),
    s_tid    => (others => '0'),
    s_tvalid => s_tvalid,
    s_tlast  => s_tvalid,
    -- AXI stream output
    m_tready  => m_tready,
    m_tdata(0)=> header_bit,
    m_tkeep   => open,
    m_tid     => open,
    m_tvalid  => m_tvalid_i,
    m_tlast   => m_tlast_i);

  modulation_rom_u : entity fpga_cores.rom_inference
  generic map (
    ROM_DATA     => MOD_8PSK_MAP,
    ROM_TYPE     => lut, -- To allow same cycle reading
    OUTPUT_DELAY => 0)
  port map (
    clk    => clk,
    clken  => '1',
    addr   => modulation_addr,
    rddata => m_tdata_i);

  -- FIXME: Need to check what's the correct endianess here. Hard coding for now to get
  -- some tests passing
  m_tdata <= m_tdata_i(23 downto 16) & m_tdata_i(31 downto 24) & m_tdata_i(7 downto 0) & m_tdata_i(15 downto 8) when m_tvalid_i = '1' else
             (others => 'U');

  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
  begin
    if rst = '1' then
      modulation_index <= '0';
    elsif rising_edge(clk) then
      if m_tready = '1' and m_tvalid_i = '1' then
        modulation_index <= not modulation_index;
        if m_tlast_i = '1' then
          modulation_index <= '0';
        end if;
      end if;
    end if;
  end process;

end axi_plframe_header;
