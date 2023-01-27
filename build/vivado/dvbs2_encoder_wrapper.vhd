--
-- DVB FPGA
--
-- Copyright 2019-2022 by Suoto <andre820@gmail.com>
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
    INPUT_DATA_WIDTH     : integer := 32;
    IQ_WIDTH             : integer := 32
  );
  port (
    -- AXI4 lite
    --Clock and Reset
    clk               : in  std_logic;
    rst_n             : in  std_logic;
    --write address channel
    s_axi_awvalid     : in  std_logic;
    s_axi_awready     : out std_logic;
    s_axi_awaddr      : in  std_logic_vector(12 downto 0);
    s_axi_awprot      : in  std_logic_vector(2 downto 0);
    -- write data channel
    s_axi_wvalid      : in  std_logic;
    s_axi_wready      : out std_logic;
    s_axi_wdata       : in  std_logic_vector(31 downto 0);
    s_axi_wstrb       : in  std_logic_vector(3 downto 0);
    -- read address channel
    s_axi_arvalid     : in  std_logic;
    s_axi_arready     : out std_logic;
    s_axi_araddr      : in  std_logic_vector(12 downto 0);
    s_axi_arprot      : in  std_logic_vector(2 downto 0);
    -- read data channel
    s_axi_rvalid      : out std_logic;
    s_axi_rready      : in  std_logic;
    s_axi_rdata       : out std_logic_vector(31 downto 0);
    s_axi_rresp       : out std_logic_vector(1 downto 0);
    -- write response channel
    s_axi_bvalid      : out std_logic;
    s_axi_bready      : in  std_logic;
    s_axi_bresp       : out std_logic_vector(1 downto 0);
    -- Input data
    s_axis_tvalid     : in  std_logic;
    s_axis_tlast      : in  std_logic;
    s_axis_tready     : out std_logic;
    s_axis_tkeep      : in  std_logic_vector(INPUT_DATA_WIDTH/8 - 1 downto 0);
    s_axis_tdata      : in  std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0);
    -- Output data
    m_axis_tvalid     : out std_logic;
    m_axis_tlast      : out std_logic;
    m_axis_tready     : in  std_logic;
    m_axis_tdata      : out std_logic_vector(IQ_WIDTH - 1 downto 0));
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
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_araddr      : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_arprot      : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_arready     : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_arvalid     : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_awaddr      : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_awprot      : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_awready     : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_awvalid     : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_bready      : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_bresp       : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_bvalid      : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_rdata       : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_rready      : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_rresp       : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_rvalid      : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_wdata       : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_wready      : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_wstrb       : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axi_wvalid      : SIGNAL is "CLK_DOMAIN clk";

  ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_tvalid     : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_tlast      : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_tready     : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_tdata      : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of s_axis_tkeep      : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of m_axis_tvalid     : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of m_axis_tlast      : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of m_axis_tready     : SIGNAL is "CLK_DOMAIN clk";
  ATTRIBUTE X_INTERFACE_PARAMETER of m_axis_tdata      : SIGNAL is "CLK_DOMAIN clk";

  signal rst                   : std_logic;

  signal encoder_frame_type    : frame_type_t;
  signal encoder_constellation : constellation_t;
  signal encoder_code_rate     : code_rate_t;
  signal encoder_pilots        : std_logic;
  signal encoder_tvalid        : std_logic;
  signal encoder_tready        : std_logic;
  signal encoder_tlast         : std_logic;
  signal encoder_tdata         : std_logic_vector(15 downto 0);
  signal encoder_tkeep         : std_logic_vector(1 downto 0);

begin

  inline_config_adapter : entity work.inline_config_adapter
    generic map ( INPUT_DATA_WIDTH => INPUT_DATA_WIDTH )
    port map (
      clk             => clk,
      rst             => rst,
      -- Input data where the first 2-byte word is interpreted as in-band signalling
      s_tvalid        => s_axis_tvalid,
      s_tready        => s_axis_tready,
      s_tlast         => s_axis_tlast,
      s_tkeep         => s_axis_tkeep,
      s_tdata         => s_axis_tdata,
      -- Output data
      m_frame_type    => encoder_frame_type,
      m_constellation => encoder_constellation,
      m_code_rate     => encoder_code_rate,
      m_pilots        => encoder_pilots,
      m_tvalid        => encoder_tvalid,
      m_tready        => encoder_tready,
      m_tlast         => encoder_tlast,
      m_tdata         => encoder_tdata,
      m_tkeep         => encoder_tkeep);

  encoder_u : entity work.dvbs2_encoder
    generic map (
      INPUT_DATA_WIDTH => 16,
      IQ_WIDTH         => IQ_WIDTH
    )
    port map (
      -- Usual ports
      clk             => clk,
      rst             => rst,

      -- AXI4 lite
      -- write address channel
      s_axi_awvalid   => s_axi_awvalid,
      s_axi_awready   => s_axi_awready,
      s_axi_awaddr    => s_axi_awaddr,
      -- write data channel
      s_axi_wvalid    => s_axi_wvalid,
      s_axi_wready    => s_axi_wready,
      s_axi_wdata     => s_axi_wdata,
      s_axi_wstrb     => s_axi_wstrb,
      -- read address channel
      s_axi_arvalid   => s_axi_arvalid,
      s_axi_arready   => s_axi_arready,
      s_axi_araddr    => s_axi_araddr,
      -- read data channel
      s_axi_rvalid    => s_axi_rvalid,
      s_axi_rready    => s_axi_rready,
      s_axi_rdata     => s_axi_rdata,
      s_axi_rresp     => s_axi_rresp,
      -- write response channel
      s_axi_bvalid    => s_axi_bvalid,
      s_axi_bready    => s_axi_bready,
      s_axi_bresp     => s_axi_bresp,

      -- AXI input
      s_constellation => encoder_constellation,
      s_frame_type    => encoder_frame_type,
      s_code_rate     => encoder_code_rate,
      s_pilots        => encoder_pilots,
      s_tvalid        => encoder_tvalid,
      s_tdata         => encoder_tdata,
      s_tkeep         => encoder_tkeep,
      s_tlast         => encoder_tlast,
      s_tready        => encoder_tready,
      -- AXI output
      m_tready        => m_axis_tready,
      m_tvalid        => m_axis_tvalid,
      m_tlast         => m_axis_tlast,
      m_tdata         => m_axis_tdata);

  -- Reset from the AXI Stream FIFOs are a single cycle, extend it to 16 cycles to ensure
  -- DVB encoder is properly reset
  extend_reset_block : block
    signal rst_count  : unsigned(3 downto 0);
  begin
    extend_reset : process(clk, rst_n)
    begin
      if rst_n = '0' then
        rst_count <= (others => '0');
        rst       <= '1';
      elsif rising_edge(clk) then
        if rst_count < 15 then
          rst_count <= rst_count + 1;
        else
          rst       <= '0';
        end if;
      end if;
    end process;
  end block;

end architecture;
