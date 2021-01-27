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
    cfg_frame_type       : in  frame_type_t;
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
  -- constant HEADER_ROM                       : std_logic_array_t := get_plframe_header_rom;
  -- constant ROM_DATA_WIDTH                   : integer := HEADER_ROM(HEADER_ROM'left)'length;

  -------------
  -- Signals --
  -------------
  -- signal addr   : std_logic_vector(numbits(HEADER_ROM'length) - 1 downto 0);
  signal header : std_logic_vector(360*8 - 1 downto 0);

begin

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  -- addr <= (others => 'U') when get_rom_addr(cfg_constellation, cfg_frame_type, cfg_code_rate) = -1 else
  --         std_logic_vector(to_unsigned(get_rom_addr(cfg_constellation, cfg_frame_type, cfg_code_rate), numbits(HEADER_ROM'length)));

  header <= (others => 'U') when get_rom_addr(cfg_constellation, cfg_frame_type, cfg_code_rate) = -1 else
            get_plframe_header(cfg_constellation, cfg_frame_type, cfg_code_rate);

  -------------------
  -- Port Mappings --
  -------------------
  -- header_rom_u : entity fpga_cores.rom_inference
  -- generic map (
  --   ROM_DATA     => HEADER_ROM,
  --   ROM_TYPE     => lut,
  --   OUTPUT_DELAY => 0)
  -- port map (
  --   clk    => clk,
  --   clken  => '1',
  --   addr   => addr,
  --   rddata => header);

  width_conversion_u : entity fpga_cores.axi_stream_width_converter
  generic map (
    INPUT_DATA_WIDTH  => 360*8,
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
    s_tlast  => s_tvalid,
    -- AXI stream output
    m_tready  => m_tready,
    m_tdata   => m_tdata,
    m_tkeep   => open,
    m_tid     => open,
    m_tvalid  => m_tvalid,
    m_tlast   => m_tlast);

  process(clk)
  begin
    if rising_edge(clk) then
      if s_tready = '1' and s_tvalid = '1' then
        for i in 0 to 3 loop
          for j in 0 to 1 loop
            info(sformat("MOD_8PSK_MAP(%d, %d) = %r", fo(i), fo(j), fo(MOD_8PSK_MAP(i, j))));
          end loop;
        end loop;
        debug(sformat("header = %r", fo(header)));
      end if;
    end if;
  end process;

end axi_plframe_header;
