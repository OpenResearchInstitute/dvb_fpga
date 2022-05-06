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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpga_cores;
use fpga_cores.common_pkg.all;
-- use fpga_cores.axi_pkg.all;

use work.dvb_utils_pkg.all;
use work.ldpc_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity ldpc_input_sync is
  generic (
    INPUT_DATA_WIDTH  : integer := 8;
    TID_WIDTH         : integer := 0
  );
  port (
    -- Usual ports
    clk             : in  std_logic;
    rst             : in  std_logic;
    -- AXI LDPC table input
    s_ldpc_tready   : out std_logic;
    s_ldpc_tvalid   : in  std_logic;
    s_ldpc_offset   : in  std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);
    s_ldpc_next     : in  std_logic;
    s_ldpc_tuser    : in  std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);
    s_ldpc_tlast    : in  std_logic;
    -- AXI data input
    s_tready        : out std_logic;
    s_tvalid        : in  std_logic;
    s_tlast         : in  std_logic;
    s_tdata         : in  std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0);
    s_tid           : in  std_logic_vector(TID_WIDTH - 1 downto 0);
    -- AXI data output
    m_tready        : in  std_logic;
    m_tvalid        : out std_logic;
    m_tlast         : out std_logic;
    m_tid           : out std_logic_vector(TID_WIDTH - 1 downto 0);
    m_tdata         : out std_logic;
    m_ldpc_offset   : out std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);
    m_ldpc_tuser    : out std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0));
end ldpc_input_sync;

architecture ldpc_input_sync of ldpc_input_sync is

  -----------
  -- Types --
  -----------
  type axi_out_t is record
    tdata  : std_logic;
    tid    : std_logic_vector(TID_WIDTH - 1 downto 0);
    tvalid : std_logic;
    tready : std_logic;
    tlast  : std_logic;
  end record;


  -------------
  -- Signals --
  -------------
  signal s_ldpc_tready_i : std_logic;
  signal axi_out           : axi_out_t;
  signal m_tvalid_i        : std_logic;
  signal bit_count         : unsigned(15 downto 0);

begin

  -------------------
  -- Port mappings --
  -------------------
  input_width_conversion_u : entity fpga_cores.axi_stream_width_converter
    generic map (
      INPUT_DATA_WIDTH  => INPUT_DATA_WIDTH,
      OUTPUT_DATA_WIDTH => 1,
      AXI_TID_WIDTH     => TID_WIDTH,
      IGNORE_TKEEP      => True)
    port map (
      -- Usual ports
      clk        => clk,
      rst        => rst,
      -- AXI stream input
      s_tready   => s_tready,
      s_tdata    => mirror_bits(s_tdata),
      s_tid      => s_tid,
      s_tvalid   => s_tvalid,
      s_tlast    => s_tlast,
      -- AXI stream output
      m_tready   => axi_out.tready,
      m_tdata(0) => axi_out.tdata,
      m_tid      => axi_out.tid,
      m_tvalid   => axi_out.tvalid,
      m_tlast    => axi_out.tlast);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  m_tvalid        <= m_tvalid_i;
  s_ldpc_tready   <= s_ldpc_tready_i;

  m_tvalid_i      <= axi_out.tvalid and s_ldpc_tvalid;
  s_ldpc_tready_i <= axi_out.tvalid and m_tready;

  axi_out.tready  <= m_tready and s_ldpc_tvalid and s_ldpc_next;

  m_tlast         <= s_ldpc_tlast; --axi_out.tlast;
  m_ldpc_offset   <= s_ldpc_offset when m_tvalid_i else (others => 'U');
  m_ldpc_tuser    <= s_ldpc_tuser when m_tvalid_i else (others => 'U');
  m_tdata         <= axi_out.tdata when m_tvalid_i else 'U';
  m_tid           <= axi_out.tid when m_tvalid_i else (others => 'U');

  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
  begin
    if rst then
      bit_count       <= (others => '0');
      -- s_ldpc_tready_i <= '0';
    elsif rising_edge(clk) then
      if s_ldpc_tvalid and s_ldpc_next then --and completed_data then
        -- s_ldpc_tready_i <= '0';
      end if;
      -- if s_ldpc_tvalid and s_ldpc_tready_i and s_ldpc_tlast then
      -- end if;

      if axi_out.tvalid then
        -- s_ldpc_tready_i <= '1';
      end if;

      if m_tvalid_i and m_tready then
        bit_count <= bit_count + 1;
      end if;
    end if;
  end process;

end ldpc_input_sync;

