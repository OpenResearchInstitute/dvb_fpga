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

  --------
  --Types-
  --------
  -- Actual config we have to process
  signal cfg_code_rate            : code_Rate_t;
  signal cfg_constellation        : constellation_t;

  shared variable shared_plheader : protected_t;
  
  -----------------
    -- subprograms --
    -----------------


--architecture begin
begin
   
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
        m_tdata           <= shared_plheader.get_plheader(cfg_constellation, cfg_code_rate);
        --m_tvalid <= 1;
      end if;
    end if;
  end process;
  
  --form pl_header whenever master wants to send. 
  -- FIXME: This is unlikely to be synthesizeable
  shared_plheader.build_plheader(cfg_constellation, cfg_code_rate);
  -- not handling C1_4, C1_3, C2_5, C1_2,
   
end axi_dvbs2_plinseration;
  
-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
