--
-- DVB FPGA
--
-- Copyright 2019-2021 by Suoto <andre820@gmail.com>
--
-- This source describes Open Hardware and is licensed under the CERN-OHL-W v2.
--
-- You may redistribute and modify this source and make products using it under
-- the terms of the CERN-OHL-W v2 (https://ohwr.org/cern_ohl_w_v2.txt).
--
-- This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING
-- OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.
-- Please see the CERN-OHL-W v2 for applicable conditions.
--
-- Source location: https://github.com/phase4ground/dvb_fpga
--
-- As per CERN-OHL-W v2 section 4.1, should You produce hardware based on this
-- source, You must maintain the Source Location visible on the external case of
-- the DVB Encoder or other products you make using this source.
---------------
-- Libraries --
---------------
library	ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpga_cores;
use fpga_cores.common_pkg.all;
use fpga_cores.axi_pkg.all;

use work.dvb_utils_pkg.all;
use work.ldpc_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_ldpc_encoder is
  generic ( TID_WIDTH : integer := 0 );
  port (
    -- Usual ports
    clk             : in  std_logic;
    rst             : in  std_logic;

    -- AXI data input
    s_constellation : in  constellation_t;
    s_frame_type    : in  frame_type_t;
    s_code_rate     : in  code_rate_t;

    s_tready        : out std_logic;
    s_tvalid        : in  std_logic;
    s_tlast         : in  std_logic;
    s_tdata         : in  std_logic_vector(7 downto 0);
    s_tid           : in  std_logic_vector(TID_WIDTH - 1 downto 0);

    -- AXI output
    m_tready        : in  std_logic;
    m_tvalid        : out std_logic;
    m_tlast         : out std_logic;
    m_tdata         : out std_logic_vector(7 downto 0);
    m_tid           : out std_logic_vector(TID_WIDTH - 1 downto 0));
end axi_ldpc_encoder;

architecture axi_ldpc_encoder of axi_ldpc_encoder is

  -------------
  -- Signals --
  -------------
  signal s_tready_i   : std_logic;
  signal first_word   : std_logic;
  signal cfg_tready   : std_logic;
  signal cfg_tvalid   : std_logic;

  signal table_tready : std_logic;
  signal table_tvalid : std_logic;
  signal table_offset : std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);
  signal table_next   : std_logic;
  signal table_tuser  : std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);
  signal table_tlast  : std_logic;



begin

  table_u : entity work.axi_ldpc_table
    port map (
      -- Usual ports
      clk          => clk,
      rst          => rst,

      -- Parameter input
      s_frame_type => s_frame_type,
      s_code_rate  => s_code_rate,
      s_tready     => cfg_tready,
      s_tvalid     => cfg_tvalid,

      -- Config out
      m_tready     => table_tready,
      m_tvalid     => table_tvalid,
      m_offset     => table_offset,
      m_next       => table_next,
      m_tuser      => table_tuser,
      m_tlast      => table_tlast);

  encoder_u : entity work.axi_ldpc_encoder_core
    generic map ( TID_WIDTH => TID_WIDTH )
    port map (
      -- Usual ports
      clk              => clk,
      rst              => rst,

      -- AXI LDPC table input
      s_ldpc_tready    => table_tready,
      s_ldpc_tvalid    => table_tvalid,
      s_ldpc_offset    => table_offset,
      s_ldpc_next      => table_next,
      s_ldpc_tuser     => table_tuser,
      s_ldpc_tlast     => table_tlast,

      -- AXI data input
      s_constellation  => s_constellation,
      s_frame_type     => s_frame_type,
      s_code_rate      => s_code_rate,
      s_tready         => s_tready_i,
      s_tvalid         => s_tvalid,
      s_tlast          => s_tlast,
      s_tdata          => s_tdata,
      s_tid            => s_tid,

      -- AXI output
      m_tready         => m_tready,
      m_tvalid         => m_tvalid,
      m_tlast          => m_tlast,
      m_tdata          => m_tdata,
      m_tid            => m_tid);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  s_tready   <= s_tready_i;
  cfg_tvalid <= s_tvalid and cfg_tready when first_word = '1' else '0';

  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
  begin
    if rst = '1' then
      first_word <= '1';
    elsif rising_edge(clk) then
      -- Clear flag when config has been written
      if cfg_tvalid = '1' and cfg_tready = '1' then
        first_word <= '0';
      end if;

      if s_tvalid = '1' and s_tready_i = '1' then
        first_word <= s_tlast;
      end if;
    end if;
  end process;

end axi_ldpc_encoder;

-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
