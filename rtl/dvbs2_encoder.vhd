--
-- DVB FPGA
--
-- Copyright 2019-2022 by suoto <andre820@gmail.com>
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

use work.dvb_utils_pkg.all;
use work.dvbs2_encoder_regs_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity dvbs2_encoder is
  generic (
    INPUT_DATA_WIDTH : positive := 8; -- For ease of use only. Internally data will be always converted to 8 bits
    IQ_WIDTH         : positive := 32 -- IQ width of 32 means each component is 16-bit wide
  );
  port (
    -- Usual ports
    clk             : in  std_logic;
    rst             : in  std_logic;

    -- AXI4 lite
    --write address channel
    s_axi_awvalid   : in  std_logic;
    s_axi_awready   : out std_logic;
    s_axi_awaddr    : in  std_logic_vector(12 downto 0);
    -- write data channel
    s_axi_wvalid    : in  std_logic;
    s_axi_wready    : out std_logic;
    s_axi_wdata     : in  std_logic_vector(31 downto 0);
    s_axi_wstrb     : in  std_logic_vector(3 downto 0);
    --read address channel
    s_axi_arvalid   : in  std_logic;
    s_axi_arready   : out std_logic;
    s_axi_araddr    : in  std_logic_vector(12 downto 0);
    --read data channel
    s_axi_rvalid    : out std_logic;
    s_axi_rready    : in  std_logic;
    s_axi_rdata     : out std_logic_vector(31 downto 0);
    s_axi_rresp     : out std_logic_vector(1 downto 0);
    --write response channel
    s_axi_bvalid    : out std_logic;
    s_axi_bready    : in  std_logic;
    s_axi_bresp     : out std_logic_vector(1 downto 0);

    -- AXI input
    s_constellation : in  constellation_t;
    s_frame_type    : in  frame_type_t;
    s_code_rate     : in  code_rate_t;
    s_pilots        : in  std_logic;
    s_tvalid        : in  std_logic;
    s_tdata         : in  std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0);
    s_tkeep         : in  std_logic_vector(INPUT_DATA_WIDTH/8 - 1 downto 0);
    s_tlast         : in  std_logic;
    s_tready        : out std_logic;
    -- AXI output
    m_tready        : in  std_logic;
    m_tvalid        : out std_logic;
    m_tlast         : out std_logic;
    m_tdata         : out std_logic_vector(IQ_WIDTH - 1 downto 0));
end dvbs2_encoder;

architecture dvbs2_encoder of dvbs2_encoder is

  ---------------
  -- Constants --
  ---------------
  constant FRAME_COUNT_WIDTH  : integer := 16;
  constant FRAME_LENGTH_WIDTH : integer := 16;

  -----------
  -- Types --
  -----------
  type data_and_config_t is record
    tdata  : std_logic_vector;
    tid    : std_logic_vector(ENCODED_CONFIG_WIDTH - 1 downto 0);
    tvalid : std_logic;
    tlast  : std_logic;
    tready : std_logic;
  end record;

  -- tvalid/tready pair for control only buses
  type axi_stream_ctrl_t is record
    tvalid : std_logic;
    tready : std_logic;
  end record;

  -------------
  -- Signals --
  -------------
  signal rst_n                    : std_logic;
  signal s_tid                    : std_logic_vector(ENCODED_CONFIG_WIDTH - 1 downto 0);
  signal m_tvalid_i               : std_logic;
  signal m_tlast_i                : std_logic;
  signal s_tready_i               : std_logic;

  signal s_tdata_selected         : std_logic_vector(s_tdata'range);
  signal s_tkeep_selected         : std_logic_vector(s_tkeep'range);

  signal width_conv_reg           : data_and_config_t(tdata(7 downto 0));
  signal width_conv_reg_dbg       : data_and_config_t(tdata(7 downto 0));
  signal frame_resize             : data_and_config_t(tdata(7 downto 0));
  signal bb_scrambler             : data_and_config_t(tdata(7 downto 0));
  signal bb_scrambler_dbg         : data_and_config_t(tdata(7 downto 0));
  signal bch_encoder              : data_and_config_t(tdata(7 downto 0));
  signal bch_encoder_dbg          : data_and_config_t(tdata(7 downto 0));
  signal ldpc_encoder             : data_and_config_t(tdata(7 downto 0));
  signal ldpc_encoder_reg         : data_and_config_t(tdata(7 downto 0));
  signal ldpc_encoder_dbg         : data_and_config_t(tdata(7 downto 0));
  signal fork_bit_interleaver     : axi_stream_ctrl_t;
  signal fork_constellation_mapper: axi_stream_ctrl_t;
  signal bit_interleaver          : data_and_config_t(tdata(7 downto 0));
  signal bit_interleaver_dbg      : data_and_config_t(tdata(7 downto 0));
  signal arbiter_out              : data_and_config_t(tdata(7 downto 0));
  signal constellation_mapper     : data_and_config_t(tdata(IQ_WIDTH - 1 downto 0));
  signal constellation_mapper_dbg : data_and_config_t(tdata(IQ_WIDTH - 1 downto 0));
  signal pl_frame                 : data_and_config_t(tdata(IQ_WIDTH - 1 downto 0));

  signal m_tdata_i                : std_logic_vector(IQ_WIDTH - 1 downto 0);
  signal m_tready_i               : std_logic;

  signal user2regs                : user2regs_t;
  signal regs2user                : regs2user_t;

  signal dbg_frame_type    : std_logic_vector(1 downto 0);
  signal dbg_constellation : std_logic_vector(7 downto 0);
  signal dbg_code_rate     : std_logic_vector(9 downto 0);

  attribute MARK_DEBUG : boolean;
  attribute MARK_DEBUG of dbg_frame_type, dbg_constellation, dbg_code_rate : signal is True;

begin

  ---------------
  -- Debugging --
  ---------------
  dbg_frame_type <= "01" when s_frame_type = fecframe_short else
                    "10" when s_frame_type = fecframe_normal else
                    "00";


  dbg_constellation <= x"04" when s_constellation = mod_qpsk else
                       x"08" when s_constellation  = mod_8psk else
                       x"10" when s_constellation  = mod_16apsk else
                       x"20" when s_constellation  = mod_32apsk else
                       x"00";

  dbg_code_rate <= std_logic_vector(to_unsigned(14, 10)) when s_code_rate = C1_4 else
                   std_logic_vector(to_unsigned(13, 10)) when s_code_rate = C1_3 else
                   std_logic_vector(to_unsigned(25, 10)) when s_code_rate = C2_5 else
                   std_logic_vector(to_unsigned(12, 10)) when s_code_rate = C1_2 else
                   std_logic_vector(to_unsigned(35, 10)) when s_code_rate = C3_5 else
                   std_logic_vector(to_unsigned(23, 10)) when s_code_rate = C2_3 else
                   std_logic_vector(to_unsigned(34, 10)) when s_code_rate = C3_4 else
                   std_logic_vector(to_unsigned(45, 10)) when s_code_rate = C4_5 else
                   std_logic_vector(to_unsigned(56, 10)) when s_code_rate = C5_6 else
                   std_logic_vector(to_unsigned(89, 10)) when s_code_rate = C8_9 else
                   std_logic_vector(to_unsigned(910, 10)) when s_code_rate = C9_10 else
                   (others => '0');

  -------------------
  -- Port mappings --
  -------------------
  s_tdata_selected <= mirror_bytes(s_tdata) when regs2user.config_swap_input_data_byte_endianness(0) else s_tdata;
  s_tkeep_selected <= mirror_bits(s_tkeep) when regs2user.config_swap_input_data_byte_endianness(0) else s_tkeep;

  -- Width converter is little endian but our data is big endian
  g_width_converter : block
    signal tdata_agg_in  : std_logic_vector(ENCODED_CONFIG_WIDTH + 8 downto 0);
    signal tdata_agg_out : std_logic_vector(ENCODED_CONFIG_WIDTH + 8 downto 0);
    signal width_conv    : data_and_config_t(tdata(7 downto 0));

  begin
    force_8_bit_u : entity fpga_cores.axi_stream_width_converter
      generic map (
        INPUT_DATA_WIDTH  => INPUT_DATA_WIDTH,
        OUTPUT_DATA_WIDTH => 8,
        AXI_TID_WIDTH     => ENCODED_CONFIG_WIDTH,
        IGNORE_TKEEP      => False)
      port map (
        -- Usual ports
        clk      => clk,
        rst      => rst,
        -- AXI stream input
        s_tready => s_tready_i,
        s_tdata  => s_tdata,
        s_tkeep  => s_tkeep,
        s_tid    => s_tid,
        s_tvalid => s_tvalid,
        s_tlast  => s_tlast,
        -- AXI stream output
        m_tready => width_conv.tready,
        m_tdata  => width_conv.tdata,
        m_tkeep  => open,
        m_tid    => width_conv.tid,
        m_tvalid => width_conv.tvalid,
        m_tlast  => width_conv.tlast);

    axi_output_reg_u : entity fpga_cores.axi_stream_delay
      generic map (
        DELAY_CYCLES => 2,
        TDATA_WIDTH  => tdata_agg_out'length)
      port map (
        -- Usual ports
        clk     => clk,
        rst     => rst,
        -- Write side
        s_tvalid => width_conv.tvalid,
        s_tready => width_conv.tready,
        s_tdata  => tdata_agg_in,
        -- Read side
        m_tvalid => width_conv_reg.tvalid,
        m_tready => width_conv_reg.tready,
        m_tdata  => tdata_agg_out);

      tdata_agg_in         <= width_conv.tlast & width_conv.tid & width_conv.tdata;

      width_conv_reg.tlast <= tdata_agg_out(ENCODED_CONFIG_WIDTH + 8);
      width_conv_reg.tid   <= tdata_agg_out(ENCODED_CONFIG_WIDTH + 7 downto 8);
      width_conv_reg.tdata <= tdata_agg_out(7 downto 0);

  end block;

  width_conv_dbg_u : entity fpga_cores.axi_stream_debug
    generic map (
      TDATA_WIDTH        => 8,
      TID_WIDTH          => ENCODED_CONFIG_WIDTH,
      FRAME_COUNT_WIDTH  => FRAME_COUNT_WIDTH,
      FRAME_LENGTH_WIDTH => FRAME_LENGTH_WIDTH)
    port map (
      -- Usual ports
      clk                        => clk,
      rst                        => rst,
      -- Control and status
      cfg.block_data             => regs2user.axi_debug_input_width_converter_cfg_block_data(0),
      cfg.allow_word             => regs2user.axi_debug_input_width_converter_cfg_allow_word(0),
      cfg.allow_frame            => regs2user.axi_debug_input_width_converter_cfg_allow_frame(0),

      cfg.clear_max_frame_length => regs2user.axi_debug_input_width_converter_min_max_frame_length_strobe,
      cfg.clear_min_frame_length => regs2user.axi_debug_input_width_converter_min_max_frame_length_strobe,
      cfg.clear_s_tvalid         => regs2user.axi_debug_input_width_converter_strobes_strobe,
      cfg.clear_s_tready         => regs2user.axi_debug_input_width_converter_strobes_strobe,
      cfg.clear_m_tvalid         => regs2user.axi_debug_input_width_converter_strobes_strobe,
      cfg.clear_m_tready         => regs2user.axi_debug_input_width_converter_strobes_strobe,

      sts.frame_count            => user2regs.axi_debug_input_width_converter_frame_count_value,
      sts.word_count             => user2regs.axi_debug_input_width_converter_word_count_value,
      sts.s_tvalid               => user2regs.axi_debug_input_width_converter_strobes_s_tvalid(0),
      sts.s_tready               => user2regs.axi_debug_input_width_converter_strobes_s_tready(0),
      sts.m_tvalid               => user2regs.axi_debug_input_width_converter_strobes_m_tvalid(0),
      sts.m_tready               => user2regs.axi_debug_input_width_converter_strobes_m_tready(0),
      sts.last_frame_length      => user2regs.axi_debug_input_width_converter_last_frame_length_value,
      sts.min_frame_length       => user2regs.axi_debug_input_width_converter_min_max_frame_length_min_frame_length,
      sts.max_frame_length       => user2regs.axi_debug_input_width_converter_min_max_frame_length_max_frame_length,
      -- AXI input
      s_tready                   => width_conv_reg.tready,
      s_tvalid                   => width_conv_reg.tvalid,
      s_tlast                    => width_conv_reg.tlast,
      s_tdata                    => width_conv_reg.tdata,
      s_tid                      => width_conv_reg.tid,
      -- AXI output
      m_tready                   => width_conv_reg_dbg.tready,
      m_tvalid                   => width_conv_reg_dbg.tvalid,
      m_tlast                    => width_conv_reg_dbg.tlast,
      m_tdata                    => width_conv_reg_dbg.tdata,
      m_tid                      => width_conv_reg_dbg.tid);

  -- TODO: Add debug after resizing and plug it into the register map
  frame_resize_u : entity work.axi_bbframe_length_enforcer
    generic map (
      TDATA_WIDTH => 8,
      TUSER_WIDTH => ENCODED_CONFIG_WIDTH)
    port map (
      -- Usual ports
      clk          => clk,
      rst          => rst,

      s_frame_type => decode(width_conv_reg_dbg.tid).frame_type,
      s_code_rate  => decode(width_conv_reg_dbg.tid).code_rate,

      s_tvalid     => width_conv_reg_dbg.tvalid,
      s_tlast      => width_conv_reg_dbg.tlast,
      s_tready     => width_conv_reg_dbg.tready,
      s_tdata      => width_conv_reg_dbg.tdata,
      s_tuser      => width_conv_reg_dbg.tid,
      -- AXI output
      m_tready     => frame_resize.tready,
      m_tvalid     => frame_resize.tvalid,
      m_tlast      => frame_resize.tlast,
      m_tdata      => frame_resize.tdata,
      m_tuser      => frame_resize.tid);


  bb_scrambler_u : entity work.axi_baseband_scrambler
    generic map (
      TDATA_WIDTH => 8,
      TID_WIDTH   => ENCODED_CONFIG_WIDTH)
    port map (
      -- Usual ports
      clk      => clk,
      rst      => rst,
      -- AXI input
      s_tvalid => frame_resize.tvalid,
      s_tdata  => frame_resize.tdata,
      s_tlast  => frame_resize.tlast,
      s_tready => frame_resize.tready,
      s_tid    => frame_resize.tid,
      -- AXI output
      m_tready => bb_scrambler.tready,
      m_tvalid => bb_scrambler.tvalid,
      m_tlast  => bb_scrambler.tlast,
      m_tdata  => bb_scrambler.tdata,
      m_tid    => bb_scrambler.tid);

  bb_scrambler_dbg_u : entity fpga_cores.axi_stream_debug
    generic map (
      TDATA_WIDTH        => 8,
      TID_WIDTH          => ENCODED_CONFIG_WIDTH,
      FRAME_COUNT_WIDTH  => FRAME_COUNT_WIDTH,
      FRAME_LENGTH_WIDTH => FRAME_LENGTH_WIDTH)
    port map (
      -- Usual ports
      clk                        => clk,
      rst                        => rst,
      -- Control and status
      cfg.block_data             => regs2user.axi_debug_bb_scrambler_cfg_block_data(0),
      cfg.allow_word             => regs2user.axi_debug_bb_scrambler_cfg_allow_word(0),
      cfg.allow_frame            => regs2user.axi_debug_bb_scrambler_cfg_allow_frame(0),

      cfg.clear_max_frame_length => regs2user.axi_debug_bb_scrambler_min_max_frame_length_strobe,
      cfg.clear_min_frame_length => regs2user.axi_debug_bb_scrambler_min_max_frame_length_strobe,
      cfg.clear_s_tvalid         => regs2user.axi_debug_bb_scrambler_strobes_strobe,
      cfg.clear_s_tready         => regs2user.axi_debug_bb_scrambler_strobes_strobe,
      cfg.clear_m_tvalid         => regs2user.axi_debug_bb_scrambler_strobes_strobe,
      cfg.clear_m_tready         => regs2user.axi_debug_bb_scrambler_strobes_strobe,

      sts.frame_count            => user2regs.axi_debug_bb_scrambler_frame_count_value,
      sts.word_count             => user2regs.axi_debug_bb_scrambler_word_count_value,
      sts.s_tvalid               => user2regs.axi_debug_bb_scrambler_strobes_s_tvalid(0),
      sts.s_tready               => user2regs.axi_debug_bb_scrambler_strobes_s_tready(0),
      sts.m_tvalid               => user2regs.axi_debug_bb_scrambler_strobes_m_tvalid(0),
      sts.m_tready               => user2regs.axi_debug_bb_scrambler_strobes_m_tready(0),
      sts.last_frame_length      => user2regs.axi_debug_bb_scrambler_last_frame_length_value,
      sts.min_frame_length       => user2regs.axi_debug_bb_scrambler_min_max_frame_length_min_frame_length,
      sts.max_frame_length       => user2regs.axi_debug_bb_scrambler_min_max_frame_length_max_frame_length,
      -- AXI input
      s_tready                   => bb_scrambler.tready,
      s_tvalid                   => bb_scrambler.tvalid,
      s_tlast                    => bb_scrambler.tlast,
      s_tdata                    => bb_scrambler.tdata,
      s_tid                      => bb_scrambler.tid,
      -- AXI output
      m_tready                   => bb_scrambler_dbg.tready,
      m_tvalid                   => bb_scrambler_dbg.tvalid,
      m_tlast                    => bb_scrambler_dbg.tlast,
      m_tdata                    => bb_scrambler_dbg.tdata,
      m_tid                      => bb_scrambler_dbg.tid);

  bch_encoder_u : entity work.axi_bch_encoder
    generic map (
      TID_WIDTH   => ENCODED_CONFIG_WIDTH
    )
    port map (
      -- Usual ports
      clk          => clk,
      rst          => rst,
      -- AXI input
      s_frame_type => decode(bb_scrambler_dbg.tid).frame_type,
      s_code_rate  => decode(bb_scrambler_dbg.tid).code_rate,
      s_tvalid     => bb_scrambler_dbg.tvalid,
      s_tlast      => bb_scrambler_dbg.tlast,
      s_tready     => bb_scrambler_dbg.tready,
      s_tdata      => bb_scrambler_dbg.tdata,
      s_tid        => bb_scrambler_dbg.tid,
      -- AXI output
      m_tready     => bch_encoder.tready,
      m_tvalid     => bch_encoder.tvalid,
      m_tlast      => bch_encoder.tlast,
      m_tdata      => bch_encoder.tdata,
      m_tid        => bch_encoder.tid);

  bch_encoder_dbg_u : entity fpga_cores.axi_stream_debug
    generic map (
      TDATA_WIDTH        => 8,
      TID_WIDTH          => ENCODED_CONFIG_WIDTH,
      FRAME_COUNT_WIDTH  => FRAME_COUNT_WIDTH,
      FRAME_LENGTH_WIDTH => FRAME_LENGTH_WIDTH)
    port map (
      -- Usual ports
      clk                        => clk,
      rst                        => rst,
      -- Control and status
      cfg.block_data             => regs2user.axi_debug_bch_encoder_cfg_block_data(0),
      cfg.allow_word             => regs2user.axi_debug_bch_encoder_cfg_allow_word(0),
      cfg.allow_frame            => regs2user.axi_debug_bch_encoder_cfg_allow_frame(0),

      cfg.clear_max_frame_length => regs2user.axi_debug_bch_encoder_min_max_frame_length_strobe,
      cfg.clear_min_frame_length => regs2user.axi_debug_bch_encoder_min_max_frame_length_strobe,
      cfg.clear_s_tvalid         => regs2user.axi_debug_bch_encoder_strobes_strobe,
      cfg.clear_s_tready         => regs2user.axi_debug_bch_encoder_strobes_strobe,
      cfg.clear_m_tvalid         => regs2user.axi_debug_bch_encoder_strobes_strobe,
      cfg.clear_m_tready         => regs2user.axi_debug_bch_encoder_strobes_strobe,

      sts.frame_count            => user2regs.axi_debug_bch_encoder_frame_count_value,
      sts.word_count             => user2regs.axi_debug_bch_encoder_word_count_value,
      sts.s_tvalid               => user2regs.axi_debug_bch_encoder_strobes_s_tvalid(0),
      sts.s_tready               => user2regs.axi_debug_bch_encoder_strobes_s_tready(0),
      sts.m_tvalid               => user2regs.axi_debug_bch_encoder_strobes_m_tvalid(0),
      sts.m_tready               => user2regs.axi_debug_bch_encoder_strobes_m_tready(0),
      sts.last_frame_length      => user2regs.axi_debug_bch_encoder_last_frame_length_value,
      sts.min_frame_length       => user2regs.axi_debug_bch_encoder_min_max_frame_length_min_frame_length,
      sts.max_frame_length       => user2regs.axi_debug_bch_encoder_min_max_frame_length_max_frame_length,
      -- AXI input
      s_tready                   => bch_encoder.tready,
      s_tvalid                   => bch_encoder.tvalid,
      s_tlast                    => bch_encoder.tlast,
      s_tdata                    => bch_encoder.tdata,
      s_tid                      => bch_encoder.tid,
      -- AXI output
      m_tready                   => bch_encoder_dbg.tready,
      m_tvalid                   => bch_encoder_dbg.tvalid,
      m_tlast                    => bch_encoder_dbg.tlast,
      m_tdata                    => bch_encoder_dbg.tdata,
      m_tid                      => bch_encoder_dbg.tid);

  ldpc_encoder_u : entity work.axi_ldpc_encoder
    generic map ( TID_WIDTH   => ENCODED_CONFIG_WIDTH )
    port map (
      -- Usual ports
      clk             => clk,
      rst             => rst,
      -- Per frame config input
      -- AXI input
      s_frame_type    => decode(bch_encoder_dbg.tid).frame_type,
      s_code_rate     => decode(bch_encoder_dbg.tid).code_rate,
      s_constellation => decode(bch_encoder_dbg.tid).constellation,
      s_tready        => bch_encoder_dbg.tready,
      s_tvalid        => bch_encoder_dbg.tvalid,
      s_tlast         => bch_encoder_dbg.tlast,
      s_tdata         => bch_encoder_dbg.tdata,
      s_tid           => bch_encoder_dbg.tid,
      -- AXI output
      m_tready        => ldpc_encoder.tready,
      m_tvalid        => ldpc_encoder.tvalid,
      m_tlast         => ldpc_encoder.tlast,
      m_tdata         => ldpc_encoder.tdata,
      m_tid           => ldpc_encoder.tid);

  -- Using ldpc_encoder_dbg.tid as control for the demux makes it so that
  -- ldpc_encoder_dbg.tvalid affects ldpc_encoder_dbg.tready. Because the
  -- axi_stream_replicate inside axi_ldpc_encoder_core does the complement to that
  -- (m_tvalid forward depends on m_tready) it creates a combinatorial loop. To avoid this
  -- we'll sample the output of LDPC's AXI stream debug
  ldpc_encoder_reg_block : block
    signal tdata_agg_in  : std_logic_vector(ENCODED_CONFIG_WIDTH + 8 downto 0);
    signal tdata_agg_out : std_logic_vector(ENCODED_CONFIG_WIDTH + 8 downto 0);
  begin
    ldpc_encoder_reg_u : entity fpga_cores.axi_stream_delay
      generic map (
        DELAY_CYCLES => 1,
        TDATA_WIDTH  => ENCODED_CONFIG_WIDTH + 9)
      port map (
        -- Usual ports
        clk     => clk,
        rst     => rst,
        -- Write side
        s_tvalid => ldpc_encoder.tvalid,
        s_tready => ldpc_encoder.tready,
        s_tdata  => tdata_agg_in,
        -- Read side
        m_tvalid => ldpc_encoder_reg.tvalid,
        m_tready => ldpc_encoder_reg.tready,
        m_tdata  => tdata_agg_out);

    tdata_agg_in           <= ldpc_encoder.tlast & ldpc_encoder.tid & ldpc_encoder.tdata;
    ldpc_encoder_reg.tdata <= tdata_agg_out(7 downto 0);
    ldpc_encoder_reg.tid   <= tdata_agg_out(ENCODED_CONFIG_WIDTH + 7 downto 8);
    ldpc_encoder_reg.tlast <= tdata_agg_out(ENCODED_CONFIG_WIDTH + 8);
  end block;

  ldpc_encoder_dbg_u : entity fpga_cores.axi_stream_debug
    generic map (
      TDATA_WIDTH        => 8,
      TID_WIDTH          => ENCODED_CONFIG_WIDTH,
      FRAME_COUNT_WIDTH  => FRAME_COUNT_WIDTH,
      FRAME_LENGTH_WIDTH => FRAME_LENGTH_WIDTH)
    port map (
      -- Usual ports
      clk                        => clk,
      rst                        => rst,
      -- Control and status
      cfg.block_data             => regs2user.axi_debug_ldpc_encoder_cfg_block_data(0),
      cfg.allow_word             => regs2user.axi_debug_ldpc_encoder_cfg_allow_word(0),
      cfg.allow_frame            => regs2user.axi_debug_ldpc_encoder_cfg_allow_frame(0),

      cfg.clear_max_frame_length => regs2user.axi_debug_ldpc_encoder_min_max_frame_length_strobe,
      cfg.clear_min_frame_length => regs2user.axi_debug_ldpc_encoder_min_max_frame_length_strobe,
      cfg.clear_s_tvalid         => regs2user.axi_debug_ldpc_encoder_strobes_strobe,
      cfg.clear_s_tready         => regs2user.axi_debug_ldpc_encoder_strobes_strobe,
      cfg.clear_m_tvalid         => regs2user.axi_debug_ldpc_encoder_strobes_strobe,
      cfg.clear_m_tready         => regs2user.axi_debug_ldpc_encoder_strobes_strobe,

      sts.frame_count            => user2regs.axi_debug_ldpc_encoder_frame_count_value,
      sts.word_count             => user2regs.axi_debug_ldpc_encoder_word_count_value,
      sts.s_tvalid               => user2regs.axi_debug_ldpc_encoder_strobes_s_tvalid(0),
      sts.s_tready               => user2regs.axi_debug_ldpc_encoder_strobes_s_tready(0),
      sts.m_tvalid               => user2regs.axi_debug_ldpc_encoder_strobes_m_tvalid(0),
      sts.m_tready               => user2regs.axi_debug_ldpc_encoder_strobes_m_tready(0),
      sts.last_frame_length      => user2regs.axi_debug_ldpc_encoder_last_frame_length_value,
      sts.min_frame_length       => user2regs.axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length,
      sts.max_frame_length       => user2regs.axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length,
      -- AXI input
      s_tready                   => ldpc_encoder_reg.tready,
      s_tvalid                   => ldpc_encoder_reg.tvalid,
      s_tlast                    => ldpc_encoder_reg.tlast,
      s_tdata                    => ldpc_encoder_reg.tdata,
      s_tid                      => ldpc_encoder_reg.tid,
      -- AXI output
      m_tready                   => ldpc_encoder_dbg.tready,
      m_tvalid                   => ldpc_encoder_dbg.tvalid,
      m_tlast                    => ldpc_encoder_dbg.tlast,
      m_tdata                    => ldpc_encoder_dbg.tdata,
      m_tid                      => ldpc_encoder_dbg.tid);


  bit_interleaver_flow_control : block
    signal demux_sel         : std_logic_vector(1 downto 0);
    signal demux_sel_reg     : std_logic_vector(1 downto 0);
    signal frames_in_transit : unsigned(2 downto 0); -- Shouldn't really exceed 2 but it's cheap to leave some margin
    signal frame_in          : std_logic;
    signal frame_out         : std_logic;
  begin

    frame_in  <= fork_bit_interleaver.tvalid and fork_bit_interleaver.tready and ldpc_encoder_dbg.tlast;
    frame_out <= bit_interleaver.tvalid and bit_interleaver.tready and bit_interleaver.tlast;

    process(clk, rst)
    begin
      if rst then
        frames_in_transit  <= (others => '0');
        demux_sel_reg      <= (others => 'U');
      elsif rising_edge(clk) then
        demux_sel_reg <= demux_sel;

        -- Count frames in transit through the bit interleaver
        if frame_in and not frame_out then
          frames_in_transit <= frames_in_transit + 1;
        elsif not frame_in and frame_out then
          frames_in_transit <= frames_in_transit - 1;
        end if;

      end if;
    end process;

    -- Interface 0 of the demux connects to the bit interleaver, interface 1 connects to
    -- the frame FIFO
    demux_sel <= "00" when frames_in_transit > 0 and decode(ldpc_encoder_dbg.tid).constellation = mod_qpsk else
                 "10" when decode(ldpc_encoder_dbg.tid).constellation = mod_qpsk else
                 "01" when decode(ldpc_encoder_dbg.tid).constellation = mod_8psk else
                 "01" when decode(ldpc_encoder_dbg.tid).constellation = mod_16apsk else
                 "01" when decode(ldpc_encoder_dbg.tid).constellation = mod_32apsk else
                 demux_sel_reg;

    -- Bit interleaver is not needed for QPSK
    bit_interleaver_demux_u : entity fpga_cores.axi_stream_demux
      generic map (
        INTERFACES => 2,
        DATA_WIDTH => 8)
      port map (
        selection_mask => demux_sel,

        s_tvalid       => ldpc_encoder_dbg.tvalid,
        s_tready       => ldpc_encoder_dbg.tready,
        s_tdata        => ldpc_encoder_dbg.tdata,

        m_tvalid(0)    => fork_bit_interleaver.tvalid,
        m_tvalid(1)    => fork_constellation_mapper.tvalid,

        m_tready(0)    => fork_bit_interleaver.tready,
        m_tready(1)    => fork_constellation_mapper.tready,

        m_tdata        => open);
  end block bit_interleaver_flow_control;

  bit_interleaver_u : entity work.axi_bit_interleaver
    generic map (
      TDATA_WIDTH => 8,
      TID_WIDTH   => ENCODED_CONFIG_WIDTH
    )
    port map (
      -- Usual ports
      clk             => clk,
      rst             => rst,
      -- AXI input
      s_frame_type    => decode(ldpc_encoder_dbg.tid).frame_type,
      s_constellation => decode(ldpc_encoder_dbg.tid).constellation,
      s_code_rate     => decode(ldpc_encoder_dbg.tid).code_rate,
      s_tready        => fork_bit_interleaver.tready,
      s_tvalid        => fork_bit_interleaver.tvalid,
      s_tlast         => ldpc_encoder_dbg.tlast,
      s_tdata         => ldpc_encoder_dbg.tdata,
      s_tid           => ldpc_encoder_dbg.tid,
      -- AXI output
      m_tready        => bit_interleaver.tready,
      m_tvalid        => bit_interleaver.tvalid,
      m_tlast         => bit_interleaver.tlast,
      m_tdata         => bit_interleaver.tdata,
      m_tid           => bit_interleaver.tid);

  bit_interleaver_dbg_u : entity fpga_cores.axi_stream_debug
    generic map (
      TDATA_WIDTH        => 8,
      TID_WIDTH          => ENCODED_CONFIG_WIDTH,
      FRAME_COUNT_WIDTH  => FRAME_COUNT_WIDTH,
      FRAME_LENGTH_WIDTH => FRAME_LENGTH_WIDTH)
    port map (
      -- Usual ports
      clk                        => clk,
      rst                        => rst,
      -- Control and status
      cfg.block_data             => regs2user.axi_debug_bit_interleaver_cfg_block_data(0),
      cfg.allow_word             => regs2user.axi_debug_bit_interleaver_cfg_allow_word(0),
      cfg.allow_frame            => regs2user.axi_debug_bit_interleaver_cfg_allow_frame(0),

      cfg.clear_max_frame_length => regs2user.axi_debug_bit_interleaver_min_max_frame_length_strobe,
      cfg.clear_min_frame_length => regs2user.axi_debug_bit_interleaver_min_max_frame_length_strobe,
      cfg.clear_s_tvalid         => regs2user.axi_debug_bit_interleaver_strobes_strobe,
      cfg.clear_s_tready         => regs2user.axi_debug_bit_interleaver_strobes_strobe,
      cfg.clear_m_tvalid         => regs2user.axi_debug_bit_interleaver_strobes_strobe,
      cfg.clear_m_tready         => regs2user.axi_debug_bit_interleaver_strobes_strobe,

      sts.frame_count            => user2regs.axi_debug_bit_interleaver_frame_count_value,
      sts.word_count             => user2regs.axi_debug_bit_interleaver_word_count_value,
      sts.s_tvalid               => user2regs.axi_debug_bit_interleaver_strobes_s_tvalid(0),
      sts.s_tready               => user2regs.axi_debug_bit_interleaver_strobes_s_tready(0),
      sts.m_tvalid               => user2regs.axi_debug_bit_interleaver_strobes_m_tvalid(0),
      sts.m_tready               => user2regs.axi_debug_bit_interleaver_strobes_m_tready(0),
      sts.last_frame_length      => user2regs.axi_debug_bit_interleaver_last_frame_length_value,
      sts.min_frame_length       => user2regs.axi_debug_bit_interleaver_min_max_frame_length_min_frame_length,
      sts.max_frame_length       => user2regs.axi_debug_bit_interleaver_min_max_frame_length_max_frame_length,
      -- AXI input
      s_tready                   => bit_interleaver.tready,
      s_tvalid                   => bit_interleaver.tvalid,
      s_tlast                    => bit_interleaver.tlast,
      s_tdata                    => bit_interleaver.tdata,
      s_tid                      => bit_interleaver.tid,
      -- AXI output
      m_tready                   => bit_interleaver_dbg.tready,
      m_tvalid                   => bit_interleaver_dbg.tvalid,
      m_tlast                    => bit_interleaver_dbg.tlast,
      m_tdata                    => bit_interleaver_dbg.tdata,
      m_tid                      => bit_interleaver_dbg.tid);

  pre_constellaion_mapper_arbiter_block : block
    signal tdata_in0 : std_logic_vector(8 + ENCODED_CONFIG_WIDTH - 1 downto 0);
    signal tdata_in1 : std_logic_vector(8 + ENCODED_CONFIG_WIDTH - 1 downto 0);
    signal tdata_out : std_logic_vector(8 + ENCODED_CONFIG_WIDTH - 1 downto 0);
  begin

    tdata_in0 <= ldpc_encoder_dbg.tid & ldpc_encoder_dbg.tdata;
    tdata_in1 <= bit_interleaver_dbg.tid & bit_interleaver_dbg.tdata;

    arbiter_out.tdata <= tdata_out(8 - 1 downto 0);
    arbiter_out.tid <= tdata_out(ENCODED_CONFIG_WIDTH + 8 - 1 downto 8);

    -- Merge LDPC encoder and bit interleaver streams to feed into the constellation mapper
    pre_constellaion_mapper_arbiter_u : entity fpga_cores.axi_stream_arbiter
      generic map (
        MODE            => "ROUND_ROBIN",
        INTERFACES      => 2,
        DATA_WIDTH      => 8 + ENCODED_CONFIG_WIDTH,
        REGISTER_INPUTS => True)
      port map (
        -- Usual ports
        clk              => clk,
        rst              => rst,

        selected         => user2regs.ldpc_fifo_status_arbiter_selected,
        selected_encoded => open,

        -- AXI slave input
        s_tvalid(0)      => fork_constellation_mapper.tvalid,
        s_tvalid(1)      => bit_interleaver_dbg.tvalid,

        s_tready(0)      => fork_constellation_mapper.tready,
        s_tready(1)      => bit_interleaver_dbg.tready,

        s_tlast(0)       => ldpc_encoder_dbg.tlast,
        s_tlast(1)       => bit_interleaver_dbg.tlast,

        s_tdata(0)       => tdata_in0,
        s_tdata(1)       => tdata_in1,

        -- AXI master output
        m_tvalid         => arbiter_out.tvalid,
        m_tready         => arbiter_out.tready,
        m_tdata          => tdata_out,
        m_tlast          => arbiter_out.tlast);
  end block;

  constellation_mapper_u : entity work.axi_constellation_mapper
    generic map (
      INPUT_DATA_WIDTH  => 8,
      OUTPUT_DATA_WIDTH => IQ_WIDTH,
      TID_WIDTH         => ENCODED_CONFIG_WIDTH
    )
    port map (
      -- Usual ports
      clk              => clk,
      rst              => rst,
      -- Per frame config input
      -- AXI input
      s_frame_type     => decode(arbiter_out.tid).frame_type,
      s_constellation  => decode(arbiter_out.tid).constellation,
      s_code_rate      => decode(arbiter_out.tid).code_rate,
      s_tvalid         => arbiter_out.tvalid,
      s_tlast          => arbiter_out.tlast,
      s_tready         => arbiter_out.tready,
      s_tdata          => arbiter_out.tdata,
      s_tid            => arbiter_out.tid,
      -- AXI output
      m_tvalid         => constellation_mapper.tvalid,
      m_tlast          => constellation_mapper.tlast,
      m_tready         => constellation_mapper.tready,
      m_tdata          => constellation_mapper.tdata,
      m_tid            => constellation_mapper.tid,
      -- IQ mapping RAM config
      radius_ram_wren  => or(regs2user.constellation_map_radius_ram_wen),
      radius_ram_addr  => regs2user.constellation_map_radius_ram_addr,
      radius_ram_wdata => regs2user.constellation_map_radius_ram_wdata,
      radius_ram_rdata => user2regs.constellation_map_radius_ram_rdata,
      -- Mapping RAM config
      iq_ram_wren      => or(regs2user.constellation_map_iq_ram_wen),
      iq_ram_addr      => regs2user.constellation_map_iq_ram_addr,
      iq_ram_wdata     => regs2user.constellation_map_iq_ram_wdata,
      iq_ram_rdata     => user2regs.constellation_map_iq_ram_rdata);

  constellation_mapper_dbg_u : entity fpga_cores.axi_stream_debug
    generic map (
      TDATA_WIDTH        => IQ_WIDTH,
      TID_WIDTH          => ENCODED_CONFIG_WIDTH,
      FRAME_COUNT_WIDTH  => FRAME_COUNT_WIDTH,
      FRAME_LENGTH_WIDTH => FRAME_LENGTH_WIDTH)
    port map (
      -- Usual ports
      clk                        => clk,
      rst                        => rst,
      -- Control and status
      cfg.block_data             => regs2user.axi_debug_constellation_mapper_cfg_block_data(0),
      cfg.allow_word             => regs2user.axi_debug_constellation_mapper_cfg_allow_word(0),
      cfg.allow_frame            => regs2user.axi_debug_constellation_mapper_cfg_allow_frame(0),

      cfg.clear_max_frame_length => regs2user.axi_debug_constellation_mapper_min_max_frame_length_strobe,
      cfg.clear_min_frame_length => regs2user.axi_debug_constellation_mapper_min_max_frame_length_strobe,
      cfg.clear_s_tvalid         => regs2user.axi_debug_constellation_mapper_strobes_strobe,
      cfg.clear_s_tready         => regs2user.axi_debug_constellation_mapper_strobes_strobe,
      cfg.clear_m_tvalid         => regs2user.axi_debug_constellation_mapper_strobes_strobe,
      cfg.clear_m_tready         => regs2user.axi_debug_constellation_mapper_strobes_strobe,

      sts.frame_count            => user2regs.axi_debug_constellation_mapper_frame_count_value,
      sts.word_count             => user2regs.axi_debug_constellation_mapper_word_count_value,
      sts.s_tvalid               => user2regs.axi_debug_constellation_mapper_strobes_s_tvalid(0),
      sts.s_tready               => user2regs.axi_debug_constellation_mapper_strobes_s_tready(0),
      sts.m_tvalid               => user2regs.axi_debug_constellation_mapper_strobes_m_tvalid(0),
      sts.m_tready               => user2regs.axi_debug_constellation_mapper_strobes_m_tready(0),
      sts.last_frame_length      => user2regs.axi_debug_constellation_mapper_last_frame_length_value,
      sts.min_frame_length       => user2regs.axi_debug_constellation_mapper_min_max_frame_length_min_frame_length,
      sts.max_frame_length       => user2regs.axi_debug_constellation_mapper_min_max_frame_length_max_frame_length,
      -- AXI input
      s_tready                   => constellation_mapper.tready,
      s_tvalid                   => constellation_mapper.tvalid,
      s_tlast                    => constellation_mapper.tlast,
      s_tdata                    => constellation_mapper.tdata,
      s_tid                      => constellation_mapper.tid,
      -- AXI output
      m_tready                   => constellation_mapper_dbg.tready,
      m_tvalid                   => constellation_mapper_dbg.tvalid,
      m_tlast                    => constellation_mapper_dbg.tlast,
      m_tdata                    => constellation_mapper_dbg.tdata,
      m_tid                      => constellation_mapper_dbg.tid);

  physical_layer_framer_u : entity work.axi_physical_layer_framer
    generic map (
      TDATA_WIDTH => IQ_WIDTH,
      TID_WIDTH   => ENCODED_CONFIG_WIDTH)
    port map (
      -- Usual ports
      clk               => clk,
      rst               => rst,
      -- Static config
      cfg_shift_reg_init      => regs2user.config_physical_layer_scrambler_shift_reg_init,
      cfg_enable_dummy_frames => regs2user.config_enable_dummy_frames(0),
      -- AXI input
      s_constellation   => decode(constellation_mapper_dbg.tid).constellation,
      s_frame_type      => decode(constellation_mapper_dbg.tid).frame_type,
      s_code_rate       => decode(constellation_mapper_dbg.tid).code_rate,
      s_pilots          => decode(constellation_mapper_dbg.tid).pilots,
      s_tvalid          => constellation_mapper_dbg.tvalid,
      s_tlast           => constellation_mapper_dbg.tlast,
      s_tready          => constellation_mapper_dbg.tready,
      s_tdata           => constellation_mapper_dbg.tdata,
      s_tid             => constellation_mapper_dbg.tid,
      -- AXI output
      m_tready          => pl_frame.tready,
      m_tvalid          => pl_frame.tvalid,
      m_tlast           => pl_frame.tlast,
      m_tdata           => pl_frame.tdata,
      m_tid             => pl_frame.tid);

  plframe_dbg_u : entity fpga_cores.axi_stream_debug
    generic map (
      TDATA_WIDTH        => IQ_WIDTH,
      TID_WIDTH          => ENCODED_CONFIG_WIDTH,
      FRAME_COUNT_WIDTH  => FRAME_COUNT_WIDTH,
      FRAME_LENGTH_WIDTH => FRAME_LENGTH_WIDTH)
    port map (
      -- Usual ports
      clk                        => clk,
      rst                        => rst,
      -- Control and status
      cfg.block_data             => regs2user.axi_debug_plframe_cfg_block_data(0),
      cfg.allow_word             => regs2user.axi_debug_plframe_cfg_allow_word(0),
      cfg.allow_frame            => regs2user.axi_debug_plframe_cfg_allow_frame(0),

      cfg.clear_max_frame_length => regs2user.axi_debug_plframe_min_max_frame_length_strobe,
      cfg.clear_min_frame_length => regs2user.axi_debug_plframe_min_max_frame_length_strobe,
      cfg.clear_s_tvalid         => regs2user.axi_debug_plframe_strobes_strobe,
      cfg.clear_s_tready         => regs2user.axi_debug_plframe_strobes_strobe,
      cfg.clear_m_tvalid         => regs2user.axi_debug_plframe_strobes_strobe,
      cfg.clear_m_tready         => regs2user.axi_debug_plframe_strobes_strobe,

      sts.frame_count            => user2regs.axi_debug_plframe_frame_count_value,
      sts.word_count             => user2regs.axi_debug_plframe_word_count_value,
      sts.s_tvalid               => user2regs.axi_debug_plframe_strobes_s_tvalid(0),
      sts.s_tready               => user2regs.axi_debug_plframe_strobes_s_tready(0),
      sts.m_tvalid               => user2regs.axi_debug_plframe_strobes_m_tvalid(0),
      sts.m_tready               => user2regs.axi_debug_plframe_strobes_m_tready(0),
      sts.last_frame_length      => user2regs.axi_debug_plframe_last_frame_length_value,
      sts.min_frame_length       => user2regs.axi_debug_plframe_min_max_frame_length_min_frame_length,
      sts.max_frame_length       => user2regs.axi_debug_plframe_min_max_frame_length_max_frame_length,
      -- AXI input
      s_tready                   => pl_frame.tready,
      s_tvalid                   => pl_frame.tvalid,
      s_tlast                    => pl_frame.tlast,
      s_tdata                    => pl_frame.tdata,
      s_tid                      => pl_frame.tid,
      -- AXI output
      m_tready                   => m_tready_i,
      m_tvalid                   => m_tvalid_i,
      m_tlast                    => m_tlast_i,
      m_tdata                    => m_tdata_i,
      m_tid                      => open);

  m_tdata <= mirror_bytes(m_tdata_i) when regs2user.config_swap_output_data_byte_endianness(0) else m_tdata_i;

  -- Register map decoder
  regmap_block : block
    signal s_axi_awaddr_32 : std_logic_vector(31 downto 0) := (others => '0');
    signal s_axi_araddr_32 : std_logic_vector(31 downto 0) := (others => '0');
  begin
    s_axi_awaddr_32(s_axi_awaddr'range) <= s_axi_awaddr;
    s_axi_araddr_32(s_axi_araddr'range) <= s_axi_araddr;

    regmap_u : entity work.dvbs2_encoder_regs
      generic map (
        AXI_ADDR_WIDTH => 32,
        BASEADDR       => (others => '0'))
      port map (
        -- Clock and Reset
        axi_aclk    => clk,
        axi_aresetn => rst_n,
        -- AXI Write Address Channel
        s_axi_awaddr  => s_axi_awaddr_32,
        s_axi_awprot  => (others => '0'),
        s_axi_awvalid => s_axi_awvalid,
        s_axi_awready => s_axi_awready,
        -- AXI Write Data Channel
        s_axi_wdata   => s_axi_wdata,
        s_axi_wstrb   => s_axi_wstrb,
        s_axi_wvalid  => s_axi_wvalid,
        s_axi_wready  => s_axi_wready,
        -- AXI Read Address Channel
        s_axi_araddr  => s_axi_araddr_32,
        s_axi_arprot  => (others => '0'),
        s_axi_arvalid => s_axi_arvalid,
        s_axi_arready => s_axi_arready,
        -- AXI Read Data Channel
        s_axi_rdata   => s_axi_rdata,
        s_axi_rresp   => s_axi_rresp,
        s_axi_rvalid  => s_axi_rvalid,
        s_axi_rready  => s_axi_rready,
        -- AXI Write Response Channel
        s_axi_bresp   => s_axi_bresp,
        s_axi_bvalid  => s_axi_bvalid,
        s_axi_bready  => s_axi_bready,
        -- User Ports
        user2regs     => user2regs,
        regs2user     => regs2user);
  end block regmap_block;


  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  rst_n <= not rst;

  s_tid <= encode((frame_type    => s_frame_type,
                   constellation => s_constellation,
                   code_rate     => s_code_rate,
                   pilots        => s_pilots));

  m_tlast  <= m_tlast_i and m_tvalid_i;
  s_tready <= s_tready_i;

  -- Disconnect from output for debugging
  m_tvalid   <= m_tvalid_i and not regs2user.config_force_output_ready(0);
  m_tready_i <= m_tready or regs2user.config_force_output_ready(0);

  ---------------
  -- Processes --
  ---------------
  status_block : block
    signal s_first_word       : std_logic;
    signal frame_in_transit_i : unsigned(7 downto 0);
  begin
    user2regs.frames_in_transit_value <= std_logic_vector(frame_in_transit_i);

    process(clk, rst)
    begin
      if rst = '1' then
        frame_in_transit_i <= (others => '0');
        s_first_word       <= '1';
      elsif rising_edge(clk) then
        if s_tvalid and s_tready_i then
          s_first_word <= s_tlast;
        end if;

        -- Only increment if only one is active
        if (s_tvalid and s_tready_i and s_first_word) xor (m_tvalid_i and m_tready_i and m_tlast_i) then
          if (s_tvalid and s_tready_i and s_first_word) then
            frame_in_transit_i <= frame_in_transit_i + 1;
          end if;
          if (m_tvalid_i and m_tready_i and m_tlast_i) then
            frame_in_transit_i <= frame_in_transit_i - 1;
          end if;
        end if;
      end if;
    end process;
  end block;

end dvbs2_encoder;
