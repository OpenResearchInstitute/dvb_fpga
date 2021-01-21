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
  port (
    -- Usual ports
    clk                  : in  std_logic;
    rst                  : in  std_logic;
    -- Parameter input
    -- FIXME: please keep naming convention used in other blocks (cfg_<parameter>). Also,
    -- don't keep parameters that are not used
    s_constellation_type : in  constellation_t;
    s_frame_type         : in  frame_type_t;
    s_code_rate          : in  code_rate_t;

    -- AXI data input
    s_tready             : out std_logic;
    s_tvalid             : in  std_logic;

    -- AXI output
    m_tready             : in  std_logic;
    m_tvalid             : out std_logic;
    m_tlast              : out std_logic;
    -- FIXME: Data with must match the width of the actual data stream to make it easier
    -- to merge header and data streams. The header will be on a ROM but it's width may
    -- differ from the data width, so please use fpga_cores.axi_stream_width_converter to
    -- force it
    m_tdata              : out std_logic_vector(90 downto 0));
end axi_plframe_header;

architecture axi_dvbs2_plinseration of axi_plframe_header is

  function get_plheader_addr(
    constant constellation : constellation_t;
    constant code_rate : code_rate_t) return integer is
    variable addr : integer := 8;
  begin
    if (constellation = mod_8psk) then
      case code_rate is
        when C3_5 => addr := 1;
        when C2_3 => addr := 2;
        when C3_4 => addr := 3;
        when C5_6 => addr := 4;
        when C8_9 => addr := 5;
        when C9_10 => addr := 6;
        when others => addr := 0;
      end case;
    end if;
    if (constellation = mod_16apsk) then
      case code_rate is
        when C3_5 => addr := 7;
        when C2_3 => addr := 8;
        when C3_4 => addr := 9;
        when C5_6 => addr := 10;
        when C8_9 => addr := 11;
        when C9_10 => addr := 12;
        when others => addr := 0;
      end case;
      end if;
    if (constellation = mod_32apsk) then
     case code_rate is
       when C3_5 => addr := 12;
       when C2_3 => addr := 14;
       when C3_4 => addr := 15;
       when C5_6 => addr := 16;
       when C8_9 => addr := 17;
       when C9_10 => addr := 18;
       when others => addr := 0;
     end case;
     end if;
     
    return addr;     
  end function get_plheader_addr;
  
  function get_plheader_table return std_logic_array_t is
    variable result : std_logic_array_t(1 to 10)(PL_HDR_LEN -1 downto 0);
    variable addr : integer;
  begin
    for constellation in constellation_t'left to constellation_t'right loop
      for code_rate in code_rate_t'left to code_rate_t'right loop
        addr := get_plheader_addr(constellation, code_rate);
        result(addr) := build_plheader(constellation, code_rate);
      end loop;
    end loop;
    return result;
  end function get_plheader_table;

  constant TABLE : std_logic_array_t(open)(PL_HDR_LEN -1 downto 0) := get_plheader_table;
  
  --------
  --Types-
  --------
  -- Actual config we have to process
  signal cfg_code_rate            : code_rate_t;
  signal cfg_constellation        : constellation_t;

  signal addr : std_logic_vector(numbits(20) -1 downto 0);
  signal rddata : std_logic_vector(PL_HDR_LEN -1 downto 0);
  
  -----------------
    -- subprograms --
    -----------------

--architecture begin
begin

  addr <= std_logic_vector(to_unsigned(get_plheader_addr(cfg_constellation, cfg_code_rate), numbits(20)));
  
 -- The ROM with the coefficients from the spec
 rom_u : entity fpga_cores.rom_inference
   generic map (
     ROM_DATA     => TABLE,
     ROM_TYPE     => lut,
     OUTPUT_DELAY => 0)
   port map (
     clk    => clk,
     clken  => '1',
     addr   => addr,
     rddata => rddata);
     
  process(clk, rst)
  begin
    if rst = '1' then
      cfg_code_rate <= not_set;
      cfg_constellation <= not_set;
    elsif rising_edge(clk) then
      if m_tready = '1' then
        m_tvalid <= '0';
      end if;
      s_tready <= m_tready;
      if s_tvalid = '1' then
        -- FIXME: This is using sampled config params, meaning the first m_tdata will be
        -- bogus, the 2nd will use the config of the 1st one and so on
        cfg_constellation <= s_constellation_type;
        cfg_code_rate     <= s_code_rate;
        m_tdata           <= rddata;
        --m_tvalid <= 1;
      end if;
    end if;
  end process;
   
end axi_dvbs2_plinseration;
  
-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
