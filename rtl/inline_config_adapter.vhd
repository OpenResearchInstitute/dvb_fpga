--
-- DVB FPGA
--
-- Copyright 2022 by Suoto <andre820@gmail.com>
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

library fpga_cores;

------------------------
-- Entity declaration --
------------------------
entity inline_config_adapter is
  generic ( INPUT_DATA_WIDTH : integer := 32);
  port (
    clk             : in  std_logic;
    rst             : in  std_logic;
    -- Input data where the first 4-byte word is interpreted as configuration
    s_tvalid        : in  std_logic;
    s_tready        : out std_logic;
    s_tlast         : in  std_logic;
    s_tkeep         : in  std_logic_vector(INPUT_DATA_WIDTH/8 - 1 downto 0);
    s_tdata         : in  std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0);
    -- Output data
    m_frame_type    : out frame_type_t;
    m_constellation : out constellation_t;
    m_code_rate     : out code_rate_t;
    m_tvalid        : out std_logic;
    m_tready        : in  std_logic;
    m_tlast         : out std_logic;
    m_tdata         : out std_logic_vector(15 downto 0);
    m_tkeep         : out std_logic_vector(1 downto 0));
end inline_config_adapter;

architecture inline_config_adapter of inline_config_adapter is

  signal axi_first_word    : std_logic;
  signal axi_tvalid        : std_logic;
  signal axi_tlast         : std_logic;
  signal axi_tready        : std_logic;
  signal axi_tkeep         : std_logic_vector(1 downto 0);
  signal axi_tdata         : std_logic_vector(15 downto 0);

  signal config_word_valid : std_logic;
  signal config_word       : std_logic_vector(15 downto 0);

  signal m_tvalid_i        : std_logic;
  signal m_tdata_i         : std_logic_vector(15 downto 0);
  signal m_tkeep_i         : std_logic_vector(1 downto 0);
  signal m_tlast_i         : std_logic;

  signal cfg               : config_tuple_t;

begin

  -- Config word takes 1 16 word, so we force input data to 16 first to make
  -- it easier to select only the first word. The encoder will further convert the stream
  -- to 8 bits so we're not losing anything by the way.
  width_converter_u : entity fpga_cores.axi_stream_width_converter
    generic map (
      INPUT_DATA_WIDTH    => INPUT_DATA_WIDTH,
      OUTPUT_DATA_WIDTH   => 16,
      AXI_TID_WIDTH       => 0,
      IGNORE_TKEEP        => False)
    port map (
      -- Usual ports
      clk      => clk,
      rst      => rst,
      -- AXI stream input
      s_tready => s_tready,
      s_tdata  => s_tdata,
      s_tkeep  => s_tkeep,
      s_tvalid => s_tvalid,
      s_tlast  => s_tlast,

      -- AXI stream output
      m_tready => axi_tready,
      m_tdata  => axi_tdata,
      m_tkeep  => axi_tkeep,
      m_tvalid => axi_tvalid,
      m_tlast  => axi_tlast);

  demux_block : block
    signal tdata_add_in   : std_logic_vector(18 downto 0);
    signal tdata0_agg_out : std_logic_vector(18 downto 0);
    signal tdata1_agg_out : std_logic_vector(18 downto 0);
  begin

    demux_interface_selection_p : process(clk, rst)
    begin
      if rst = '1' then
        axi_first_word <= '1';
      elsif rising_edge(clk) then
        if axi_tvalid = '1' and axi_tready = '1' then
          axi_first_word <= axi_tlast;
        end if;
      end if;
    end process;

    tdata_add_in <= axi_tlast & axi_tkeep & axi_tdata;

    m_tdata_i   <= tdata1_agg_out(15 downto 0);
    m_tkeep_i   <= tdata1_agg_out(17 downto 16);
    m_tlast_i   <= tdata1_agg_out(18);

    config_word <= tdata0_agg_out(15 downto 0);

    config_demux_u : entity fpga_cores.axi_stream_demux
      generic map (
        INTERFACES => 2,
        DATA_WIDTH => 19)
      port map (
        selection_mask => not axi_first_word & axi_first_word,

        s_tvalid    => axi_tvalid,
        s_tready    => axi_tready,
        s_tdata     => tdata_add_in,

        m_tvalid(0) => config_word_valid,
        m_tvalid(1) => m_tvalid_i,
        m_tready(0) => '1', -- config word is sampled every first word, without backpressure
        m_tready(1) => m_tready,

        m_tdata(0)  => tdata0_agg_out,
        m_tdata(1)  => tdata1_agg_out
      );
  end block;

  config_ff : process(clk, rst)
  begin
    if rst = '1' then
      cfg <= (unknown, unknown, unknown, 'U');
    elsif rising_edge(clk) then
      if config_word_valid = '1' then
        cfg <= decode(config_word(7 downto 0));
      end if;
    end if;
  end process;

  -- Assign outputs
  m_frame_type    <= cfg.frame_type when m_tvalid_i else unknown;
  m_constellation <= cfg.constellation when m_tvalid_i else unknown;
  m_code_rate     <= cfg.code_rate when m_tvalid_i else unknown;

  m_tvalid        <= m_tvalid_i;
  m_tdata         <= m_tdata_i when m_tvalid_i else (others => 'U');
  m_tkeep         <= m_tkeep_i when m_tvalid_i else (others => 'U');
  m_tlast         <= m_tlast_i when m_tvalid_i else 'U';

end architecture inline_config_adapter;
