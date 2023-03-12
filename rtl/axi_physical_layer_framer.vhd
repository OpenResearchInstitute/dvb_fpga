-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
--
-- DVB FPGA
--
-- Copyright 2019-2021 by suoto <andre820@gmail.com>
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
---------------------------------
-- Block name and description --
--------------------------------

---------------
-- Libraries --
---------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpga_cores;
use fpga_cores.axi_pkg.all;
use fpga_cores.common_pkg.all;

use work.dvb_utils_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_physical_layer_framer is
  generic (
    TDATA_WIDTH : natural := 1;
    TID_WIDTH   : natural := 1);
  port (
    -- Usual ports
    clk             : in  std_logic;
    rst             : in  std_logic;

    -- This takes effect for the following frame
    cfg_shift_reg_init      : in  std_logic_vector(17 downto 0) := (0 => '1', others => '0');
    cfg_enable_dummy_frames : in  std_logic;

    -- AXI input
    s_constellation : in  constellation_t;
    s_frame_type    : in  frame_type_t;
    s_code_rate     : in  code_rate_t;
    s_pilots        : in  std_logic;

    s_tvalid        : in  std_logic;
    s_tready        : out std_logic;
    s_tlast         : in  std_logic;
    s_tdata         : in  std_logic_vector(TDATA_WIDTH - 1 downto 0);
    s_tid           : in  std_logic_vector(TID_WIDTH - 1 downto 0);

    -- AXI output
    m_tready        : in  std_logic;
    m_tvalid        : out std_logic;
    m_tlast         : out std_logic;
    m_tdata         : out std_logic_vector(TDATA_WIDTH - 1 downto 0);
    m_tid           : out std_logic_vector(TID_WIDTH - 1 downto 0));
end axi_physical_layer_framer;

architecture axi_physical_layer_framer of axi_physical_layer_framer is

  -------------
  -- Signals --
  -------------
  signal s_tready_i              : std_logic;
  signal m_tvalid_i              : std_logic;
  signal m_tlast_i               : std_logic;
  signal s_first_word            : std_logic;
  signal s_tready_header         : std_logic;
  signal s_tvalid_header         : std_logic;
  signal arbiter_tlast           : std_logic;
  signal selected                : std_logic_vector(1 downto 0);
  signal has_pilots              : std_logic;
  signal sampled                 : axi_stream_bus_t(tdata(TDATA_WIDTH - 1 downto 0), tuser(TID_WIDTH - 1 downto 0));
  signal sampled_no_pilots       : axi_stream_bus_t(tdata(TDATA_WIDTH - 1 downto 0), tuser(TID_WIDTH - 1 downto 0));
  signal sampled_pilots          : axi_stream_bus_t(tdata(TDATA_WIDTH - 1 downto 0), tuser(TID_WIDTH - 1 downto 0));
  signal pilots                  : axi_stream_bus_t(tdata(TDATA_WIDTH - 1 downto 0), tuser(TID_WIDTH - 1 downto 0));
  signal scrambler_input         : axi_stream_bus_t(tdata(TDATA_WIDTH - 1 downto 0), tuser(TID_WIDTH - 1 downto 0));
  signal axi_header_out          : axi_stream_bus_t(tdata(TDATA_WIDTH - 1 downto 0), tuser(TID_WIDTH - 1 downto 0));
  signal scrambled               : axi_stream_bus_t(tdata(TDATA_WIDTH - 1 downto 0), tuser(TID_WIDTH - 1 downto 0));
  signal plframe                 : axi_stream_bus_t(tdata(TDATA_WIDTH - 1 downto 0), tuser(TID_WIDTH - 1 downto 0));
  signal dummy_frame_gen         : axi_stream_data_bus_t(tdata(TDATA_WIDTH - 1 downto 0));

  signal output_arbiter_selected : std_logic_vector(1 downto 0);

begin

  input_delay_block : block
    signal tdata_agg_in : std_logic_vector(TDATA_WIDTH + TID_WIDTH + 1 downto 0);
    signal tdata_agg_out : std_logic_vector(TDATA_WIDTH + TID_WIDTH + 1 downto 0);
  begin
    tdata_agg_in <= s_pilots & s_tlast & s_tid & s_tdata;

    input_delay_u : entity fpga_cores.axi_stream_delay
      generic map (
        DELAY_CYCLES => 1,
        TDATA_WIDTH  => TDATA_WIDTH + TID_WIDTH + 2)
      port map (
        clk      => clk,
        rst      => rst,

        -- AXI slave input
        s_tvalid => s_tvalid,
        s_tready => s_tready_i,
        s_tdata  => tdata_agg_in,

        -- AXI master output
        m_tvalid => sampled.tvalid,
        m_tready => sampled.tready,
        m_tdata  => tdata_agg_out);

      sampled.tdata <= tdata_agg_out(TDATA_WIDTH - 1 downto 0);
      sampled.tuser <= tdata_agg_out(TDATA_WIDTH + TID_WIDTH - 1 downto TDATA_WIDTH);
      sampled.tlast <= tdata_agg_out(TDATA_WIDTH + TID_WIDTH);
      has_pilots    <= tdata_agg_out(TDATA_WIDTH + TID_WIDTH + 1);

    end block;

  plframe_header_gen_u : entity work.axi_physical_layer_header
    generic map ( DATA_WIDTH => TDATA_WIDTH)
    port map (
      clk             => clk,
      rst             => rst,
      -- AXI data input
      s_constellation => s_constellation,
      s_frame_type    => s_frame_type,
      s_code_rate     => s_code_rate,
      s_pilots        => s_pilots,
      s_tready        => s_tready_header,
      s_tvalid        => s_tvalid_header,
      -- AXI output
      m_tready        => axi_header_out.tready,
      m_tvalid        => axi_header_out.tvalid,
      m_tlast         => axi_header_out.tlast,
      m_tdata         => axi_header_out.tdata);

  pilots_mux : block
    signal tdata_agg_in : std_logic_vector(TDATA_WIDTH + TID_WIDTH downto 0);
    signal tdata0_agg_out : std_logic_vector(TDATA_WIDTH + TID_WIDTH downto 0);
    signal tdata1_agg_out : std_logic_vector(TDATA_WIDTH + TID_WIDTH downto 0);
  begin
    tdata_agg_in <= sampled.tlast & sampled.tuser & sampled.tdata;

    pilots_mux_u : entity fpga_cores.axi_stream_demux
      generic map (
        INTERFACES => 2,
        DATA_WIDTH => TDATA_WIDTH + TID_WIDTH + 1)
      port map (
        selection_mask(0) => not has_pilots,
        selection_mask(1) => has_pilots,

        s_tvalid          => sampled.tvalid,
        s_tready          => sampled.tready,
        s_tdata           => tdata_agg_in,

        m_tvalid(0)       => sampled_no_pilots.tvalid,
        m_tvalid(1)       => sampled_pilots.tvalid,

        m_tready(0)       => sampled_no_pilots.tready,
        m_tready(1)       => sampled_pilots.tready,

        m_tdata(0)        => tdata0_agg_out,
        m_tdata(1)        => tdata1_agg_out);

      sampled_no_pilots.tdata <= tdata0_agg_out(TDATA_WIDTH - 1 downto 0);
      sampled_no_pilots.tuser <= tdata0_agg_out(TDATA_WIDTH + TID_WIDTH - 1 downto TDATA_WIDTH);
      sampled_no_pilots.tlast <= tdata0_agg_out(TDATA_WIDTH + TID_WIDTH);

      sampled_pilots.tdata    <= tdata1_agg_out(TDATA_WIDTH - 1 downto 0);
      sampled_pilots.tuser    <= tdata1_agg_out(TDATA_WIDTH + TID_WIDTH - 1 downto TDATA_WIDTH);
      sampled_pilots.tlast    <= tdata1_agg_out(TDATA_WIDTH + TID_WIDTH);
  end block;

  plframe_pilots_gen_u : entity work.axi_physical_layer_pilots
    generic map (
      TDATA_WIDTH => TDATA_WIDTH,
      TID_WIDTH   => TID_WIDTH)
    port map (
      clk             => clk,
      rst             => rst,
      -- AXI input
      s_tvalid        => sampled_pilots.tvalid,
      s_tready        => sampled_pilots.tready,
      s_tlast         => sampled_pilots.tlast,
      s_tdata         => sampled_pilots.tdata,
      s_tid           => sampled_pilots.tuser,

      -- AXI output
      m_tready        => pilots.tready,
      m_tvalid        => pilots.tvalid,
      m_tlast         => pilots.tlast,
      m_tdata         => pilots.tdata,
      m_tid           => pilots.tuser);

  physical_layer_scrambler_arbiter : block
    signal tdata_agg_out : std_logic_vector(TDATA_WIDTH + TID_WIDTH - 1 downto 0);
    signal tdata0_agg_in : std_logic_vector(TDATA_WIDTH + TID_WIDTH - 1 downto 0);
    signal tdata1_agg_in : std_logic_vector(TDATA_WIDTH + TID_WIDTH - 1 downto 0);
  begin
    tdata0_agg_in <= sampled_no_pilots.tuser & sampled_no_pilots.tdata;
    tdata1_agg_in <= pilots.tuser & pilots.tdata;

    physical_layer_scrambler_arbiter_u : entity fpga_cores.axi_stream_arbiter
      generic map (
          MODE            => "ROUND_ROBIN",
          INTERFACES      => 2,
          DATA_WIDTH      => TDATA_WIDTH + TID_WIDTH,
          REGISTER_INPUTS => False)
        port map (
          -- Usual ports
          clk              => clk,
          rst              => rst,

          selected         => open,
          selected_encoded => open,

          -- AXI slave input
          s_tvalid(0)      => sampled_no_pilots.tvalid,
          s_tvalid(1)      => pilots.tvalid,

          s_tready(0)      => sampled_no_pilots.tready,
          s_tready(1)      => pilots.tready,

          s_tdata(0)       => tdata0_agg_in,
          s_tdata(1)       => tdata1_agg_in,

          s_tlast(0)       => sampled_no_pilots.tlast,
          s_tlast(1)       => pilots.tlast,

          -- AXI master output
          m_tvalid         => scrambler_input.tvalid,
          m_tready         => scrambler_input.tready,
          m_tdata          => tdata_agg_out,
          m_tlast          => scrambler_input.tlast);

        scrambler_input.tdata <= tdata_agg_out(TDATA_WIDTH - 1 downto 0);
        scrambler_input.tuser <= tdata_agg_out(TDATA_WIDTH + TID_WIDTH - 1 downto TDATA_WIDTH);
  end block;

  physical_layer_scrambler : entity work.axi_physical_layer_scrambler
    generic map (
      TDATA_WIDTH => TDATA_WIDTH,
      TID_WIDTH   => TID_WIDTH)
    port map (
      clk               => clk,
      rst               => rst,

      cfg_shift_reg_init => cfg_shift_reg_init,

      -- AXI input
      s_tvalid          => scrambler_input.tvalid,
      s_tready          => scrambler_input.tready,
      s_tlast           => scrambler_input.tlast,
      s_tdata           => scrambler_input.tdata,
      s_tid             => scrambler_input.tuser,

      -- AXI output
      m_tready          => scrambled.tready,
      m_tvalid          => scrambled.tvalid,
      m_tlast           => scrambled.tlast,
      m_tdata           => scrambled.tdata,
      m_tid             => scrambled.tuser);


  arbiter_header_payload : block
    signal tdata0_agg_in : std_logic_vector(TDATA_WIDTH + TID_WIDTH - 1 downto 0);
    signal tdata1_agg_in : std_logic_vector(TDATA_WIDTH + TID_WIDTH - 1 downto 0);
    signal tdata_agg_out : std_logic_vector(TDATA_WIDTH + TID_WIDTH - 1 downto 0);
  begin
    tdata0_agg_in <= axi_header_out.tuser & axi_header_out.tdata;
    tdata1_agg_in <= scrambled.tuser & scrambled.tdata;

    arbiter_header_payload_u : entity fpga_cores.axi_stream_arbiter
      generic map (
        MODE            => "INTERLEAVED",
        INTERFACES      => 2,
        DATA_WIDTH      => TDATA_WIDTH + TID_WIDTH,
        REGISTER_INPUTS => False)
      port map (
        clk              => clk,
        rst              => rst,

        selected         => selected,
        selected_encoded => open,

        -- AXI slave input
        s_tvalid(0)      => axi_header_out.tvalid,
        s_tvalid(1)      => scrambled.tvalid,

        s_tready(0)      => axi_header_out.tready,
        s_tready(1)      => scrambled.tready,

        s_tdata(0)       => tdata0_agg_in,
        s_tdata(1)       => tdata1_agg_in,

        s_tlast(0)       => axi_header_out.tlast,
        s_tlast(1)       => scrambled.tlast,

        -- AXI master output
        m_tvalid         => plframe.tvalid,
        m_tready         => plframe.tready,
        m_tdata          => tdata_agg_out,
        m_tlast          => arbiter_tlast);

      (plframe.tuser, plframe.tdata) <= tdata_agg_out;

  end block;

  dummy_frame_generator_u : entity work.dummy_frame_generator
    generic map ( TDATA_WIDTH => TDATA_WIDTH )
    port map (
      clk            => clk,
      rst            => rst,
      -- Pulse to trigger generating a dummy frame
      generate_frame => cfg_enable_dummy_frames,
      -- AXI output
      m_tready       => dummy_frame_gen.tready,
      m_tvalid       => dummy_frame_gen.tvalid,
      m_tlast        => dummy_frame_gen.tlast,
      m_tdata        => dummy_frame_gen.tdata);

  -- Always prioritize data from the scrambler. If there's nothing to send then allow
  -- a dummy frame to go through
  dummy_frame_arbiter_block : block
    signal tdata0_agg_in : std_logic_vector(TDATA_WIDTH + TID_WIDTH - 1 downto 0);
    signal tdata1_agg_in : std_logic_vector(TDATA_WIDTH + TID_WIDTH - 1 downto 0);
    signal tdata_agg_out : std_logic_vector(TDATA_WIDTH + TID_WIDTH - 1 downto 0);
  begin
    dummy_frame_arbiter_u : entity fpga_cores.axi_stream_arbiter
      generic map (
        MODE            => "ABSOLUTE", -- Actual data will always have precedence
        INTERFACES      => 2,
        DATA_WIDTH      => TDATA_WIDTH + TID_WIDTH,
        REGISTER_INPUTS => False)
      port map (
        clk              => clk,
        rst              => rst,

        selected         => output_arbiter_selected,
        selected_encoded => open,
        -- AXI slave input
        s_tvalid(0)      => plframe.tvalid,
        s_tvalid(1)      => dummy_frame_gen.tvalid,

        s_tready(0)      => plframe.tready,
        s_tready(1)      => dummy_frame_gen.tready,

        s_tdata(0)       => tdata0_agg_in,
        s_tdata(1)       => tdata1_agg_in,

        s_tlast(0)       => plframe.tlast,
        s_tlast(1)       => dummy_frame_gen.tlast,
        -- AXI master output
        m_tvalid         => m_tvalid_i,
        m_tready         => m_tready,
        m_tdata          => tdata_agg_out,
        m_tlast          => m_tlast_i);

      tdata0_agg_in <= plframe.tuser & plframe.tdata;
      tdata1_agg_in <= (TID_WIDTH - 1 downto 0 => '0') & dummy_frame_gen.tdata; -- GHDL fails if this is done in the port map
      m_tdata       <= tdata_agg_out(TDATA_WIDTH - 1 downto 0);
      m_tid         <= tdata_agg_out(TDATA_WIDTH + TID_WIDTH - 1 downto TDATA_WIDTH);
  end block;

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  s_tready        <= s_tready_i;
  s_tvalid_header <= s_tvalid and s_first_word;

  -- Suppress tlast from plframe header and let s_tlast pass through
  plframe.tlast   <= arbiter_tlast and selected(1);

  m_tlast  <= m_tlast_i and m_tvalid_i;
  m_tvalid <= m_tvalid_i;

  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
  begin
    if rst = '1' then
      s_first_word <= '1';
    elsif clk'event and clk = '1' then
      if s_tvalid = '1' and s_tready_i = '1' then
        s_first_word  <= s_tlast;
        axi_header_out.tuser <= s_tid;
        -- plframe.tuser        <= s_tid;
      end if;
    end if;
  end process;

end axi_physical_layer_framer;
