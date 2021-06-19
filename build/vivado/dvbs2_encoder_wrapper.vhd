--
-- DVB IP
--
-- Copyright 2019 by Suoto <andre820@gmail.com>
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
-- Wrapper to allow instantiating the dvbs2_encoder to a Vivado block diagram

---------------
-- Libraries --
---------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.dvb_utils_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity dvbs2_encoder_wrapper is
  generic (
    -- AXI streaming widths
    AXIS_DATA_WIDTH : integer := 32
  );
  port (
    -- AXI4 lite
    --Clock and Reset
    clk            : in  std_logic;
    rst_n          : in  std_logic;
    --write address channel
    s_axi_awvalid  : in  std_logic;
    s_axi_awready  : out std_logic;
    s_axi_awaddr   : in  std_logic_vector(31 downto 0);
    s_axi_awprot   : in  std_logic_vector(2 downto 0);
    -- write data channel
    s_axi_wvalid   : in  std_logic;
    s_axi_wready   : out std_logic;
    s_axi_wdata    : in  std_logic_vector(31 downto 0);
    s_axi_wstrb    : in  std_logic_vector(3 downto 0);
    --read address channel
    s_axi_arvalid  : in  std_logic;
    s_axi_arready  : out std_logic;
    s_axi_araddr   : in  std_logic_vector(31 downto 0);
    s_axi_arprot   : in  std_logic_vector(2 downto 0);
    --read data channel
    s_axi_rvalid   : out std_logic;
    s_axi_rready   : in  std_logic;
    s_axi_rdata    : out std_logic_vector(31 downto 0);
    s_axi_rresp    : out std_logic_vector(1 downto 0);
    --write response channel
    s_axi_bvalid   : out std_logic;
    s_axi_bready   : in  std_logic;
    s_axi_bresp    : out std_logic_vector(1 downto 0);
    -- Input data
    s_axis_tvalid  : in  std_logic;
    s_axis_tlast   : in  std_logic;
    s_axis_tready  : out std_logic;
    s_axis_tkeep   : in  std_logic_vector(AXIS_DATA_WIDTH/8 - 1 downto 0);
    s_axis_tdata   : in  std_logic_vector(AXIS_DATA_WIDTH - 1 downto 0);
    s_axis_tid     : in  std_logic_vector(7 downto 0);
    -- Output data
    m_axis_tvalid  : out std_logic;
    m_axis_tlast   : out std_logic;
    m_axis_tready  : in  std_logic;
    m_axis_tdata   : out std_logic_vector(AXIS_DATA_WIDTH - 1 downto 0));
end dvbs2_encoder_wrapper;

architecture rtl of dvbs2_encoder_wrapper is

  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO of s_axi_araddr  : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite ARADDR";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_arprot  : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite ARPROT";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_arready : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite ARREADY";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_arvalid : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite ARVALID";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_awaddr  : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite AWADDR";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_awprot  : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite AWPROT";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_awready : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite AWREADY";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_awvalid : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite AWVALID";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_bready  : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite BREADY";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_bresp   : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite BRESP";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_bvalid  : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite BVALID";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_rdata   : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite RDATA";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_rready  : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite RREADY";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_rresp   : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite RRESP";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_rvalid  : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite RVALID";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_wdata   : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite WDATA";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_wready  : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite WREADY";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_wstrb   : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite WSTRB";
  ATTRIBUTE X_INTERFACE_INFO of s_axi_wvalid  : SIGNAL is "xilinx.com:interface:aximm:1.0 s_axi_lite WVALID";

  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_araddr  : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_arprot  : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_arready : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_arvalid : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_awaddr  : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_awprot  : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_awready : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_awvalid : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_bready  : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_bresp   : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_bvalid  : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_rdata   : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_rready  : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_rresp   : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_rvalid  : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_wdata   : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_wready  : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_wstrb   : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_wvalid  : SIGNAL is "CLK_DOMAIN clk";

  ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_tvalid : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_tlast  : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_tready : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_tdata  : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_tid    : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_tkeep  : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of m_axis_tvalid : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of m_axis_tlast  : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of m_axis_tready : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of m_axis_tdata  : SIGNAL is "CLK_DOMAIN clk";

  -- Follow modcodes for the physical layer framer
  function decode_tid ( constant v : std_logic_vector(7 downto 0) ) return config_tuple_t is
    variable cfg : config_tuple_t := (not_set, not_set, not_set);
  begin

    case to_integer(unsigned(v)) is
      when 16#00# => cfg := (frame_type => fecframe_short, constellation => mod_qpsk, code_rate => C1_4);
      when 16#01# => cfg := (frame_type => fecframe_short, constellation => mod_qpsk, code_rate => C1_3);
      when 16#02# => cfg := (frame_type => fecframe_short, constellation => mod_qpsk, code_rate => C2_5);
      when 16#03# => cfg := (frame_type => fecframe_short, constellation => mod_qpsk, code_rate => C1_2);
      when 16#04# => cfg := (frame_type => fecframe_short, constellation => mod_qpsk, code_rate => C3_5);
      when 16#05# => cfg := (frame_type => fecframe_short, constellation => mod_qpsk, code_rate => C2_3);
      when 16#06# => cfg := (frame_type => fecframe_short, constellation => mod_qpsk, code_rate => C3_4);
      when 16#07# => cfg := (frame_type => fecframe_short, constellation => mod_qpsk, code_rate => C4_5);
      when 16#08# => cfg := (frame_type => fecframe_short, constellation => mod_qpsk, code_rate => C5_6);
      when 16#09# => cfg := (frame_type => fecframe_short, constellation => mod_qpsk, code_rate => C8_9);
      when 16#0a# => cfg := (frame_type => fecframe_short, constellation => mod_qpsk, code_rate => C9_10);
      when 16#0b# => cfg := (frame_type => fecframe_short, constellation => mod_8psk, code_rate => C1_4);
      when 16#0c# => cfg := (frame_type => fecframe_short, constellation => mod_8psk, code_rate => C1_3);
      when 16#0d# => cfg := (frame_type => fecframe_short, constellation => mod_8psk, code_rate => C2_5);
      when 16#0e# => cfg := (frame_type => fecframe_short, constellation => mod_8psk, code_rate => C1_2);
      when 16#0f# => cfg := (frame_type => fecframe_short, constellation => mod_8psk, code_rate => C3_5);
      when 16#10# => cfg := (frame_type => fecframe_short, constellation => mod_8psk, code_rate => C2_3);
      when 16#11# => cfg := (frame_type => fecframe_short, constellation => mod_8psk, code_rate => C3_4);
      when 16#12# => cfg := (frame_type => fecframe_short, constellation => mod_8psk, code_rate => C4_5);
      when 16#13# => cfg := (frame_type => fecframe_short, constellation => mod_8psk, code_rate => C5_6);
      when 16#14# => cfg := (frame_type => fecframe_short, constellation => mod_8psk, code_rate => C8_9);
      when 16#15# => cfg := (frame_type => fecframe_short, constellation => mod_8psk, code_rate => C9_10);
      when 16#16# => cfg := (frame_type => fecframe_short, constellation => mod_16apsk, code_rate => C1_4);
      when 16#17# => cfg := (frame_type => fecframe_short, constellation => mod_16apsk, code_rate => C1_3);
      when 16#18# => cfg := (frame_type => fecframe_short, constellation => mod_16apsk, code_rate => C2_5);
      when 16#19# => cfg := (frame_type => fecframe_short, constellation => mod_16apsk, code_rate => C1_2);
      when 16#1a# => cfg := (frame_type => fecframe_short, constellation => mod_16apsk, code_rate => C3_5);
      when 16#1b# => cfg := (frame_type => fecframe_short, constellation => mod_16apsk, code_rate => C2_3);
      when 16#1c# => cfg := (frame_type => fecframe_short, constellation => mod_16apsk, code_rate => C3_4);
      when 16#1d# => cfg := (frame_type => fecframe_short, constellation => mod_16apsk, code_rate => C4_5);
      when 16#1e# => cfg := (frame_type => fecframe_short, constellation => mod_16apsk, code_rate => C5_6);
      when 16#1f# => cfg := (frame_type => fecframe_short, constellation => mod_16apsk, code_rate => C8_9);
      when 16#20# => cfg := (frame_type => fecframe_short, constellation => mod_16apsk, code_rate => C9_10);
      when 16#21# => cfg := (frame_type => fecframe_short, constellation => mod_32apsk, code_rate => C1_4);
      when 16#22# => cfg := (frame_type => fecframe_short, constellation => mod_32apsk, code_rate => C1_3);
      when 16#23# => cfg := (frame_type => fecframe_short, constellation => mod_32apsk, code_rate => C2_5);
      when 16#24# => cfg := (frame_type => fecframe_short, constellation => mod_32apsk, code_rate => C1_2);
      when 16#25# => cfg := (frame_type => fecframe_short, constellation => mod_32apsk, code_rate => C3_5);
      when 16#26# => cfg := (frame_type => fecframe_short, constellation => mod_32apsk, code_rate => C2_3);
      when 16#27# => cfg := (frame_type => fecframe_short, constellation => mod_32apsk, code_rate => C3_4);
      when 16#28# => cfg := (frame_type => fecframe_short, constellation => mod_32apsk, code_rate => C4_5);
      when 16#29# => cfg := (frame_type => fecframe_short, constellation => mod_32apsk, code_rate => C5_6);
      when 16#2a# => cfg := (frame_type => fecframe_short, constellation => mod_32apsk, code_rate => C8_9);
      when 16#2b# => cfg := (frame_type => fecframe_short, constellation => mod_32apsk, code_rate => C9_10);
      when 16#2c# => cfg := (frame_type => fecframe_normal, constellation => mod_qpsk, code_rate => C1_4);
      when 16#2d# => cfg := (frame_type => fecframe_normal, constellation => mod_qpsk, code_rate => C1_3);
      when 16#2e# => cfg := (frame_type => fecframe_normal, constellation => mod_qpsk, code_rate => C2_5);
      when 16#2f# => cfg := (frame_type => fecframe_normal, constellation => mod_qpsk, code_rate => C1_2);
      when 16#30# => cfg := (frame_type => fecframe_normal, constellation => mod_qpsk, code_rate => C3_5);
      when 16#31# => cfg := (frame_type => fecframe_normal, constellation => mod_qpsk, code_rate => C2_3);
      when 16#32# => cfg := (frame_type => fecframe_normal, constellation => mod_qpsk, code_rate => C3_4);
      when 16#33# => cfg := (frame_type => fecframe_normal, constellation => mod_qpsk, code_rate => C4_5);
      when 16#34# => cfg := (frame_type => fecframe_normal, constellation => mod_qpsk, code_rate => C5_6);
      when 16#35# => cfg := (frame_type => fecframe_normal, constellation => mod_qpsk, code_rate => C8_9);
      when 16#36# => cfg := (frame_type => fecframe_normal, constellation => mod_qpsk, code_rate => C9_10);
      when 16#37# => cfg := (frame_type => fecframe_normal, constellation => mod_8psk, code_rate => C1_4);
      when 16#38# => cfg := (frame_type => fecframe_normal, constellation => mod_8psk, code_rate => C1_3);
      when 16#39# => cfg := (frame_type => fecframe_normal, constellation => mod_8psk, code_rate => C2_5);
      when 16#3a# => cfg := (frame_type => fecframe_normal, constellation => mod_8psk, code_rate => C1_2);
      when 16#3b# => cfg := (frame_type => fecframe_normal, constellation => mod_8psk, code_rate => C3_5);
      when 16#3c# => cfg := (frame_type => fecframe_normal, constellation => mod_8psk, code_rate => C2_3);
      when 16#3d# => cfg := (frame_type => fecframe_normal, constellation => mod_8psk, code_rate => C3_4);
      when 16#3e# => cfg := (frame_type => fecframe_normal, constellation => mod_8psk, code_rate => C4_5);
      when 16#3f# => cfg := (frame_type => fecframe_normal, constellation => mod_8psk, code_rate => C5_6);
      when 16#40# => cfg := (frame_type => fecframe_normal, constellation => mod_8psk, code_rate => C8_9);
      when 16#41# => cfg := (frame_type => fecframe_normal, constellation => mod_8psk, code_rate => C9_10);
      when 16#42# => cfg := (frame_type => fecframe_normal, constellation => mod_16apsk, code_rate => C1_4);
      when 16#43# => cfg := (frame_type => fecframe_normal, constellation => mod_16apsk, code_rate => C1_3);
      when 16#44# => cfg := (frame_type => fecframe_normal, constellation => mod_16apsk, code_rate => C2_5);
      when 16#45# => cfg := (frame_type => fecframe_normal, constellation => mod_16apsk, code_rate => C1_2);
      when 16#46# => cfg := (frame_type => fecframe_normal, constellation => mod_16apsk, code_rate => C3_5);
      when 16#47# => cfg := (frame_type => fecframe_normal, constellation => mod_16apsk, code_rate => C2_3);
      when 16#48# => cfg := (frame_type => fecframe_normal, constellation => mod_16apsk, code_rate => C3_4);
      when 16#49# => cfg := (frame_type => fecframe_normal, constellation => mod_16apsk, code_rate => C4_5);
      when 16#4a# => cfg := (frame_type => fecframe_normal, constellation => mod_16apsk, code_rate => C5_6);
      when 16#4b# => cfg := (frame_type => fecframe_normal, constellation => mod_16apsk, code_rate => C8_9);
      when 16#4c# => cfg := (frame_type => fecframe_normal, constellation => mod_16apsk, code_rate => C9_10);
      when 16#4d# => cfg := (frame_type => fecframe_normal, constellation => mod_32apsk, code_rate => C1_4);
      when 16#4e# => cfg := (frame_type => fecframe_normal, constellation => mod_32apsk, code_rate => C1_3);
      when 16#4f# => cfg := (frame_type => fecframe_normal, constellation => mod_32apsk, code_rate => C2_5);
      when 16#50# => cfg := (frame_type => fecframe_normal, constellation => mod_32apsk, code_rate => C1_2);
      when 16#51# => cfg := (frame_type => fecframe_normal, constellation => mod_32apsk, code_rate => C3_5);
      when 16#52# => cfg := (frame_type => fecframe_normal, constellation => mod_32apsk, code_rate => C2_3);
      when 16#53# => cfg := (frame_type => fecframe_normal, constellation => mod_32apsk, code_rate => C3_4);
      when 16#54# => cfg := (frame_type => fecframe_normal, constellation => mod_32apsk, code_rate => C4_5);
      when 16#55# => cfg := (frame_type => fecframe_normal, constellation => mod_32apsk, code_rate => C5_6);
      when 16#56# => cfg := (frame_type => fecframe_normal, constellation => mod_32apsk, code_rate => C8_9);
      when 16#57# => cfg := (frame_type => fecframe_normal, constellation => mod_32apsk, code_rate => C9_10);
      when others => cfg := (frame_type => not_set, constellation => not_set, code_rate => not_set);
    end case;

    return cfg;
  end function;

  signal cfg : config_tuple_t;
  signal rst : std_logic;

begin

  cfg <= decode_tid(s_axis_tid);
  rst <= not rst_n;

  encoder_u : entity work.dvbs2_encoder
    generic map ( DATA_WIDTH => AXIS_DATA_WIDTH)
    port map (
      -- Usual ports
      clk             => clk,
      rst             => rst,

      -- AXI4 lite
      --write address channel
      s_axi_awvalid   => s_axi_awvalid,
      s_axi_awready   => s_axi_awready,
      s_axi_awaddr    => s_axi_awaddr,
      -- write data channel
      s_axi_wvalid    => s_axi_wvalid,
      s_axi_wready    => s_axi_wready,
      s_axi_wdata     => s_axi_wdata,
      s_axi_wstrb     => s_axi_wstrb,
      --read address channel
      s_axi_arvalid   => s_axi_arvalid,
      s_axi_arready   => s_axi_arready,
      s_axi_araddr    => s_axi_araddr,
      --read data channel
      s_axi_rvalid    => s_axi_rvalid,
      s_axi_rready    => s_axi_rready,
      s_axi_rdata     => s_axi_rdata,
      s_axi_rresp     => s_axi_rresp,
      --write response channel
      s_axi_bvalid    => s_axi_bvalid,
      s_axi_bready    => s_axi_bready,
      s_axi_bresp     => s_axi_bresp,

      -- AXI input
      s_constellation => cfg.constellation,
      s_frame_type    => cfg.frame_type,
      s_code_rate     => cfg.code_rate,
      s_tvalid        => s_axis_tvalid,
      s_tdata         => s_axis_tdata,
      s_tkeep         => s_axis_tkeep,
      s_tlast         => s_axis_tlast,
      s_tready        => s_axis_tready,
      -- AXI output
      m_tready        => m_axis_tready,
      m_tvalid        => m_axis_tvalid,
      m_tlast         => m_axis_tlast,
      m_tdata         => m_axis_tdata);

end architecture;
