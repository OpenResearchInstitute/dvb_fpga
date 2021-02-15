--
-- DVB IP
--
-- Copyright 2019 by Andre Souto (suoto)
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

library fpga_cores;
use fpga_cores.axi_pkg.all;
use fpga_cores.common_pkg.all;

use work.dvb_utils_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity dvbs2_tx is
  generic ( DATA_WIDTH : positive := 32 );
  port (
    -- Usual ports
    clk               : in  std_logic;
    rst               : in  std_logic;
    -- Static config
    cfg_enable_dummy_frames : in  std_logic;
    -- Per frame config input
    cfg_constellation : in  std_logic_vector(CONSTELLATION_WIDTH - 1 downto 0);
    cfg_frame_type    : in  std_logic_vector(FRAME_TYPE_WIDTH - 1 downto 0);
    cfg_code_rate     : in  std_logic_vector(CODE_RATE_WIDTH - 1 downto 0);
    -- Mapping RAM config
    ram_wren          : in  std_logic;
    ram_addr          : in  std_logic_vector(5 downto 0);
    ram_wdata         : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    ram_rdata         : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    -- AXI input
    s_tvalid          : in  std_logic;
    s_tdata           : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    s_tkeep           : in  std_logic_vector(DATA_WIDTH/8 - 1 downto 0);
    s_tlast           : in  std_logic;
    s_tready          : out std_logic;
    -- AXI output
    m_tready          : in  std_logic;
    m_tvalid          : out std_logic;
    m_tlast           : out std_logic;
    m_tdata           : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end dvbs2_tx;

architecture dvbs2_tx of dvbs2_tx is

  -----------
  -- Types --
  -----------
  -- tvalid/tready pair for control only buses
  type axi_stream_ctrl_t is record
    tvalid : std_logic;
    tready : std_logic;
  end record;

  -------------
  -- Signals --
  -------------
  signal s_tid                    : std_logic_vector(ENCODED_CONFIG_WIDTH - 1 downto 0);

  signal mux_sel                  : std_logic_vector(1 downto 0);

  signal width_conv               : axi_stream_bus_t(tdata(7 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
  signal bb_scrambler             : axi_stream_bus_t(tdata(7 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
  signal bch_encoder              : axi_stream_bus_t(tdata(7 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
  signal ldpc_encoder             : axi_stream_bus_t(tdata(7 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
  signal ldpc_fifo                : axi_stream_bus_t(tdata(7 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
  signal fork_bit_interleaver     : axi_stream_ctrl_t;
  signal fork_ldpc_fifo           : axi_stream_ctrl_t;
  signal bit_interleaver          : axi_stream_bus_t(tdata(7 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
  signal constellation_mapper_in  : axi_stream_bus_t(tdata(7 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
  signal constellation_mapper_out : axi_stream_bus_t(tdata(DATA_WIDTH - 1 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));

  signal ldpc_fifo_entries        : std_logic_vector(numbits(max(DVB_N_LDPC)) downto 0);
  signal ldpc_fifo_empty          : std_logic;
  signal ldpc_fifo_full           : std_logic;

begin

  -------------------
  -- Port mappings --
  -------------------
  force_8_bit_u : entity fpga_cores.axi_stream_width_converter
    generic map (
      INPUT_DATA_WIDTH  => DATA_WIDTH,
      OUTPUT_DATA_WIDTH => 8,
      AXI_TID_WIDTH     => ENCODED_CONFIG_WIDTH,
      ENDIANNESS        => LEFT_FIRST,
      IGNORE_TKEEP      => False)
    port map (
      -- Usual ports
      clk      => clk,
      rst      => rst,
      -- AXI stream input
      s_tready => s_tready,
      s_tdata  => s_tdata,
      s_tkeep  => s_tkeep,
      s_tid    => s_tid,
      s_tvalid => s_tvalid,
      s_tlast  => s_tlast,
      -- AXI stream output
      m_tready => width_conv.tready,
      m_tdata  => width_conv.tdata,
      m_tkeep  => open,
      m_tid    => width_conv.tuser,
      m_tvalid => width_conv.tvalid,
      m_tlast  => width_conv.tlast);

  bb_scrambler_u : entity work.axi_baseband_scrambler
    generic map (
      TDATA_WIDTH => 8,
      TID_WIDTH   => ENCODED_CONFIG_WIDTH)
    port map (
      -- Usual ports
      clk      => clk,
      rst      => rst,
      -- AXI input
      s_tvalid => width_conv.tvalid,
      s_tdata  => width_conv.tdata,
      s_tlast  => width_conv.tlast,
      s_tready => width_conv.tready,
      s_tid    => width_conv.tuser,
      -- AXI output
      m_tready => bb_scrambler.tready,
      m_tvalid => bb_scrambler.tvalid,
      m_tlast  => bb_scrambler.tlast,
      m_tdata  => bb_scrambler.tdata,
      m_tid    => bb_scrambler.tuser);

  bch_encoder_u : entity work.axi_bch_encoder
    generic map (
      TID_WIDTH   => ENCODED_CONFIG_WIDTH
    )
    port map (
      -- Usual ports
      clk            => clk,
      rst            => rst,
      -- Per frame config input
      cfg_frame_type => decode(bb_scrambler.tuser).frame_type,
      cfg_code_rate  => decode(bb_scrambler.tuser).code_rate,
      -- AXI input
      s_tvalid       => bb_scrambler.tvalid,
      s_tlast        => bb_scrambler.tlast,
      s_tready       => bb_scrambler.tready,
      s_tdata        => bb_scrambler.tdata,
      s_tid          => bb_scrambler.tuser,
      -- AXI output
      m_tready       => bch_encoder.tready,
      m_tvalid       => bch_encoder.tvalid,
      m_tlast        => bch_encoder.tlast,
      m_tdata        => bch_encoder.tdata,
      m_tid          => bch_encoder.tuser);

  ldpc_encoder_u : entity work.axi_ldpc_encoder
    generic map ( TID_WIDTH   => ENCODED_CONFIG_WIDTH )
    port map (
      -- Usual ports
      clk               => clk,
      rst               => rst,
      -- Per frame config input
      cfg_frame_type    => decode(bch_encoder.tuser).frame_type,
      cfg_code_rate     => decode(bch_encoder.tuser).code_rate,
      cfg_constellation => decode(bch_encoder.tuser).constellation,
      -- AXI input
      s_tready          => bch_encoder.tready,
      s_tvalid          => bch_encoder.tvalid,
      s_tlast           => bch_encoder.tlast,
      s_tdata           => bch_encoder.tdata,
      s_tid             => bch_encoder.tuser,
      -- AXI output
      m_tready          => ldpc_encoder.tready,
      m_tvalid          => ldpc_encoder.tvalid,
      m_tlast           => ldpc_encoder.tlast,
      m_tdata           => ldpc_encoder.tdata,
      m_tid             => ldpc_encoder.tuser);

  mux_sel <= "10" when decode(ldpc_encoder.tuser).constellation = mod_qpsk else "01";

  -- Bit interleaver is not needed for QPSK
  bit_interleaver_demux_u : entity fpga_cores.axi_stream_demux
    generic map (
      INTERFACES => 2,
      DATA_WIDTH => 8)
    port map (
      selection_mask => mux_sel,

      s_tvalid       => ldpc_encoder.tvalid,
      s_tready       => ldpc_encoder.tready,
      s_tdata        => ldpc_encoder.tdata,

      m_tvalid(0)    => fork_bit_interleaver.tvalid,
      m_tvalid(1)    => fork_ldpc_fifo.tvalid,

      m_tready(0)    => fork_bit_interleaver.tready,
      m_tready(1)    => fork_ldpc_fifo.tready,

      m_tdata        => open);

  bit_interleaver_u : entity work.axi_bit_interleaver
    generic map (
      TDATA_WIDTH => 8,
      TID_WIDTH   => ENCODED_CONFIG_WIDTH
    )
    port map (
      -- Usual ports
      clk               => clk,
      rst               => rst,
      -- Per frame config input
      cfg_frame_type    => decode(ldpc_encoder.tuser).frame_type,
      cfg_constellation => decode(ldpc_encoder.tuser).constellation,
      cfg_code_rate     => decode(ldpc_encoder.tuser).code_rate,
      -- AXI input
      s_tready          => fork_bit_interleaver.tready,
      s_tvalid          => fork_bit_interleaver.tvalid,
      s_tlast           => ldpc_encoder.tlast,
      s_tdata           => ldpc_encoder.tdata,
      s_tid             => ldpc_encoder.tuser,
      -- AXI output
      m_tready          => bit_interleaver.tready,
      m_tvalid          => bit_interleaver.tvalid,
      m_tlast           => bit_interleaver.tlast,
      m_tdata           => bit_interleaver.tdata,
      m_tid             => bit_interleaver.tuser);

  ldpc_fifo_block : block
    signal tdata_agg_in  : std_logic_vector(ENCODED_CONFIG_WIDTH + 7 downto 0);
    signal tdata_agg_out : std_logic_vector(ENCODED_CONFIG_WIDTH + 7 downto 0);
  begin
    ldpc_fifo_u : entity fpga_cores.axi_stream_frame_fifo
      generic map (
        FIFO_DEPTH => max(DVB_N_LDPC),
        DATA_WIDTH => ENCODED_CONFIG_WIDTH + 8,
        RAM_TYPE   => auto)
      port map (
        -- Usual ports
        clk     => clk,
        rst     => rst,
        -- status
        entries  => ldpc_fifo_entries,
        empty    => ldpc_fifo_empty,
        full     => ldpc_fifo_full,
        -- Write side
        s_tvalid => fork_ldpc_fifo.tvalid,
        s_tready => fork_ldpc_fifo.tready,
        s_tdata  => tdata_agg_in,
        s_tlast  => ldpc_encoder.tlast,
        -- Read side
        m_tvalid => ldpc_fifo.tvalid,
        m_tready => ldpc_fifo.tready,
        m_tdata  => tdata_agg_out,
        m_tlast  => ldpc_fifo.tlast);

    tdata_agg_in    <= ldpc_encoder.tuser & ldpc_encoder.tdata;
    ldpc_fifo.tdata <= tdata_agg_out(7 downto 0);
    ldpc_fifo.tuser <= tdata_agg_out(ENCODED_CONFIG_WIDTH + 7 downto 8);
  end block;

  pre_constellaion_mapper_arbiter_block : block
    signal tdata_in0 : std_logic_vector(8 + ENCODED_CONFIG_WIDTH - 1 downto 0);
    signal tdata_in1 : std_logic_vector(8 + ENCODED_CONFIG_WIDTH - 1 downto 0);
    signal tdata_out : std_logic_vector(8 + ENCODED_CONFIG_WIDTH - 1 downto 0);
  begin

    tdata_in0 <= ldpc_encoder.tuser & ldpc_encoder.tdata;
    tdata_in1 <= bit_interleaver.tuser & bit_interleaver.tdata;

    constellation_mapper_in.tdata <= tdata_out(8 - 1 downto 0);
    constellation_mapper_in.tuser <= tdata_out(ENCODED_CONFIG_WIDTH + 8 - 1 downto 8);

    -- Merge LDPC encoder and bit interleaver streams to feed into the constellation mapper
    pre_constellaion_mapper_arbiter_u : entity fpga_cores.axi_stream_arbiter
      generic map (
        MODE            => "ROUND_ROBIN", -- ROUND_ROBIN, INTERLEAVED, ABSOLUTE
        INTERFACES      => 2,
        DATA_WIDTH      => 8 + ENCODED_CONFIG_WIDTH,
        REGISTER_INPUTS => True)
      port map (
        -- Usual ports
        clk              => clk,
        rst              => rst,

        selected         => open,
        selected_encoded => open,

        -- AXI slave input
        s_tvalid(0)      => ldpc_fifo.tvalid,
        s_tvalid(1)      => bit_interleaver.tvalid,

        s_tready(0)      => ldpc_fifo.tready,
        s_tready(1)      => bit_interleaver.tready,

        s_tlast(0)       => ldpc_fifo.tlast,
        s_tlast(1)       => bit_interleaver.tlast,

        s_tdata(0)       => tdata_in0,
        s_tdata(1)       => tdata_in1,

        -- AXI master output
        m_tvalid         => constellation_mapper_in.tvalid,
        m_tready         => constellation_mapper_in.tready,
        m_tdata          => tdata_out,
        m_tlast          => constellation_mapper_in.tlast);
  end block;

  constellation_mapper_u : entity work.axi_constellation_mapper
    generic map (
      INPUT_DATA_WIDTH  => 8,
      OUTPUT_DATA_WIDTH => DATA_WIDTH,
      TID_WIDTH         => ENCODED_CONFIG_WIDTH
    )
    port map (
      -- Usual ports
      clk               => clk,
      rst               => rst,
      -- Mapping RAM config
      ram_wren          => ram_wren,
      ram_addr          => ram_addr,
      ram_wdata         => ram_wdata,
      ram_rdata         => ram_rdata,
      -- Per frame config input
      cfg_constellation => decode(constellation_mapper_in.tuser).constellation,
      -- AXI input
      s_tvalid          => constellation_mapper_in.tvalid,
      s_tlast           => constellation_mapper_in.tlast,
      s_tready          => constellation_mapper_in.tready,
      s_tdata           => constellation_mapper_in.tdata,
      s_tid             => constellation_mapper_in.tuser,
      -- AXI output
      m_tvalid          => constellation_mapper_out.tvalid,
      m_tlast           => constellation_mapper_out.tlast,
      m_tready          => constellation_mapper_out.tready,
      m_tdata           => constellation_mapper_out.tdata,
      m_tid             => constellation_mapper_out.tuser);

  physical_layer_framer_u : entity work.axi_physical_layer_framer
    generic map (
      TDATA_WIDTH => DATA_WIDTH,
      TID_WIDTH   => 0)
    port map (
      -- Usual ports
      clk                 => clk,
      rst                 => rst,
      -- Static config
      cfg_enable_dummy_frames => cfg_enable_dummy_frames,
      -- Per frame config
      cfg_constellation   => decode(constellation_mapper_out.tuser).constellation,
      cfg_frame_type      => decode(constellation_mapper_out.tuser).frame_type,
      cfg_code_rate       => decode(constellation_mapper_out.tuser).code_rate,
      -- AXI input
      s_tvalid            => constellation_mapper_out.tvalid,
      s_tlast             => constellation_mapper_out.tlast,
      s_tready            => constellation_mapper_out.tready,
      s_tdata             => constellation_mapper_out.tdata,
      s_tid               => (others => 'U'),
      -- AXI output
      m_tready            => m_tready,
      m_tvalid            => m_tvalid,
      m_tlast             => m_tlast,
      m_tdata             => m_tdata,
      m_tid               => open);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  s_tid <= encode((frame_type    => decode(cfg_frame_type),
                   constellation => decode(cfg_constellation),
                   code_rate     => decode(cfg_code_rate)));

end dvbs2_tx;
