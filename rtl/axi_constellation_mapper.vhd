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
---------------------------------
-- Block name and description --
--------------------------------

---------------
-- Libraries --
---------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library fpga_cores;
use fpga_cores.common_pkg.all;
use fpga_cores.axi_pkg.all;

use work.dvb_utils_pkg.all;
use work.constellation_mapper_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_constellation_mapper is
  generic (
    INPUT_DATA_WIDTH  : integer := 8;
    OUTPUT_DATA_WIDTH : integer := 32;
    TID_WIDTH         : integer := 0
  );
  port (
    -- Usual ports
    clk              : in  std_logic;
    rst              : in  std_logic;
    -- AXI data input
    s_frame_type     : in  frame_type_t;
    s_constellation  : in  constellation_t;
    s_code_rate      : in  code_rate_t;
    s_tready         : out std_logic;
    s_tvalid         : in  std_logic;
    s_tlast          : in  std_logic;
    s_tdata          : in  std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0);
    s_tid            : in  std_logic_vector(TID_WIDTH - 1 downto 0);
    -- AXI output
    m_tready         : in  std_logic;
    m_tvalid         : out std_logic;
    m_tlast          : out std_logic;
    m_tdata          : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0);
    m_tid            : out std_logic_vector(TID_WIDTH - 1 downto 0);
    -- IQ mapping RAM config (optional, default values should work)
    iq_ram_wren      : in  std_logic  := 'U';
    iq_ram_addr      : in  std_logic_vector(5 downto 0)  := (others => 'U');
    iq_ram_wdata     : in  std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0)  := (others => 'U');
    iq_ram_rdata     : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0);
    -- Mapping RAM config (optional, default values should work)
    radius_ram_wren  : in  std_logic  := 'U';
    radius_ram_addr  : in  std_logic_vector(numbits(RADIUS_TABLE_DEPTH) - 1 downto 0)  := (others => 'U');
    radius_ram_wdata : in  std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0)  := (others => 'U');
    radius_ram_rdata : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0)
);
end axi_constellation_mapper;

architecture axi_constellation_mapper of axi_constellation_mapper is

  constant MAPPING_TABLE : std_logic_array_t                        := get_iq_table(OUTPUT_DATA_WIDTH);
  constant RADIUS_TABLE  : std_logic_array_t                        := get_radius_table(OUTPUT_DATA_WIDTH);
  constant UNIT_RADIUS   : signed(OUTPUT_DATA_WIDTH/2 - 1 downto 0) := to_signed_fixed_point(1.0, OUTPUT_DATA_WIDTH/2);
  constant TUSER_WIDTH   : integer                                  := TID_WIDTH + ENCODED_CONFIG_WIDTH;

  -------------
  -- Signals --
  -------------
  signal s_tready_i        : std_logic;

  signal mux_sel           : std_logic_vector(3 downto 0);
  signal width_conv_tready : std_logic_vector(3 downto 0);
  signal width_conv_tvalid : std_logic_vector(3 downto 0);

  signal s_cfg             : config_tuple_t;
  signal s_tid_internal    : std_logic_vector(TUSER_WIDTH - 1 downto 0);
  signal axi_qpsk          : axi_stream_bus_t(tdata(1 downto 0), tuser(TUSER_WIDTH - 1 downto 0));
  signal axi_8psk          : axi_stream_bus_t(tdata(2 downto 0), tuser(TUSER_WIDTH - 1 downto 0));
  signal axi_16apsk        : axi_stream_bus_t(tdata(3 downto 0), tuser(TUSER_WIDTH - 1 downto 0));
  signal axi_32apsk        : axi_stream_bus_t(tdata(4 downto 0), tuser(TUSER_WIDTH - 1 downto 0));

  signal addr_qpsk         : std_logic_vector(5 downto 0);
  signal addr_8psk         : std_logic_vector(5 downto 0);
  signal addr_16apsk       : std_logic_vector(5 downto 0);
  signal addr_32apsk       : std_logic_vector(5 downto 0);

  signal axi_out           : axi_stream_bus_t(tdata(5 downto 0), tuser(TUSER_WIDTH - 1 downto 0));
  signal axi_out_cfg       : config_tuple_t;

  signal ram_out           : axi_stream_bus_t(tdata(OUTPUT_DATA_WIDTH - 1 downto 0), tuser(TID_WIDTH - 1 downto 0));
  signal ram_out_addr      : std_logic_vector(5 downto 0);
  signal ram_out_offset    : unsigned(5 downto 0);
  signal ram_out_i         : signed(OUTPUT_DATA_WIDTH/2 - 1 downto 0);
  signal ram_out_q         : signed(OUTPUT_DATA_WIDTH/2 - 1 downto 0);

  signal radius_rd_addr    : unsigned(numbits(RADIUS_TABLE_DEPTH) - 1 downto 0);

  signal radius_0          : signed(OUTPUT_DATA_WIDTH/2 - 1 downto 0);
  signal radius_1          : signed(OUTPUT_DATA_WIDTH/2 - 1 downto 0);

  signal radius_out_cfg    : config_tuple_t;

  signal output_multiplier : signed(OUTPUT_DATA_WIDTH/2 - 1 downto 0);
  signal output_i          : signed(OUTPUT_DATA_WIDTH - 1 downto 0);
  signal output_q          : signed(OUTPUT_DATA_WIDTH - 1 downto 0);

  signal dbg_radius_rd_addr_gen_error : std_logic := '0';
  signal dbg_output_multiplier_error  : std_logic := '0';

  attribute MARK_DEBUG : boolean;
  attribute MARK_DEBUG of dbg_radius_rd_addr_gen_error : signal is True;
  attribute MARK_DEBUG of dbg_output_multiplier_error : signal is True;

begin

  s_tready   <= '1' when s_constellation = unknown else s_tready_i;

  -- Mux the input data stream to the appropriate width converter
  mux_sel(0) <= '1' when s_constellation = mod_qpsk else '0';
  mux_sel(1) <= '1' when s_constellation = mod_8psk else '0';
  mux_sel(2) <= '1' when s_constellation = mod_16apsk else '0';
  mux_sel(3) <= '1' when s_constellation = mod_32apsk else '0';

  s_cfg          <= (frame_type => s_frame_type, constellation => s_constellation, code_rate => s_code_rate, pilots => '0');
  s_tid_internal <= s_tid & encode(s_cfg);

  input_mux_u : entity fpga_cores.axi_stream_demux
    generic map (
      INTERFACES => 4,
      DATA_WIDTH => 0)
    port map (
      selection_mask => mux_sel,

      s_tvalid       => s_tvalid,
      s_tready       => s_tready_i,
      s_tdata        => (others => 'U'),

      m_tvalid       => width_conv_tvalid,
      m_tready       => width_conv_tready,
      m_tdata        => open);

  -- Width converter is little endian but DVB-S2 requires mapping MSB of the data, so we
  -- mirror data in then mirror data out
  width_converter_qpsk_u : entity fpga_cores.axi_stream_width_converter
    generic map (
      INPUT_DATA_WIDTH  => INPUT_DATA_WIDTH,
      OUTPUT_DATA_WIDTH => 2,
      AXI_TID_WIDTH     => TUSER_WIDTH,
      IGNORE_TKEEP      => True)
    port map (
      -- Usual ports
      clk      => clk,
      rst      => rst,
      -- AXI stream input
      s_tready => width_conv_tready(0),
      s_tdata  => mirror_bits(s_tdata),
      s_tid    => s_tid_internal,
      s_tvalid => width_conv_tvalid(0),
      s_tlast  => s_tlast,
      -- AXI stream output
      m_tready => axi_qpsk.tready,
      m_tdata  => axi_qpsk.tdata,
      m_tid    => axi_qpsk.tuser,
      m_tvalid => axi_qpsk.tvalid,
      m_tlast  => axi_qpsk.tlast);

  width_converter_8psk_u : entity fpga_cores.axi_stream_width_converter
    generic map (
      INPUT_DATA_WIDTH  => INPUT_DATA_WIDTH,
      OUTPUT_DATA_WIDTH => 3,
      AXI_TID_WIDTH     => TUSER_WIDTH,
      IGNORE_TKEEP      => True)
    port map (
      -- Usual ports
      clk      => clk,
      rst      => rst,
      -- AXI stream input
      s_tready => width_conv_tready(1),
      s_tdata  => mirror_bits(s_tdata),
      s_tid    => s_tid_internal,
      s_tvalid => width_conv_tvalid(1),
      s_tlast  => s_tlast,
      -- AXI stream output
      m_tready => axi_8psk.tready,
      m_tdata  => axi_8psk.tdata,
      m_tid    => axi_8psk.tuser,
      m_tvalid => axi_8psk.tvalid,
      m_tlast  => axi_8psk.tlast);

  width_converter_16apsk_u : entity fpga_cores.axi_stream_width_converter
    generic map (
      INPUT_DATA_WIDTH  => INPUT_DATA_WIDTH,
      OUTPUT_DATA_WIDTH => 4,
      AXI_TID_WIDTH     => TUSER_WIDTH,
      IGNORE_TKEEP      => True)
    port map (
      -- Usual ports
      clk      => clk,
      rst      => rst,
      -- AXI stream input
      s_tready => width_conv_tready(2),
      s_tdata  => mirror_bits(s_tdata),
      s_tid    => s_tid_internal,
      s_tvalid => width_conv_tvalid(2),
      s_tlast  => s_tlast,
      -- AXI stream output
      m_tready => axi_16apsk.tready,
      m_tdata  => axi_16apsk.tdata,
      m_tid    => axi_16apsk.tuser,
      m_tvalid => axi_16apsk.tvalid,
      m_tlast  => axi_16apsk.tlast);

  width_converter_32apsk_u : entity fpga_cores.axi_stream_width_converter
    generic map (
      INPUT_DATA_WIDTH  => INPUT_DATA_WIDTH,
      OUTPUT_DATA_WIDTH => 5,
      AXI_TID_WIDTH     => TUSER_WIDTH,
      IGNORE_TKEEP      => True)
    port map (
      -- Usual ports
      clk      => clk,
      rst      => rst,
      -- AXI stream input
      s_tready => width_conv_tready(3),
      s_tdata  => mirror_bits(s_tdata),
      s_tid    => s_tid_internal,
      s_tvalid => width_conv_tvalid(3),
      s_tlast  => s_tlast,
      -- AXI stream output
      m_tready => axi_32apsk.tready,
      m_tdata  => axi_32apsk.tdata,
      m_tid    => axi_32apsk.tuser,
      m_tvalid => axi_32apsk.tvalid,
      m_tlast  => axi_32apsk.tlast);

  -- Addr CONSTELLATION_ROM offsets to the width converter output. Each table starts
  -- immediatelly after the previous
  --
  -- Also, a reminder that the width converter is little endian but our data is big
  -- endian. We mirrored the data going in now need to mirror the output as well
  addr_qpsk   <= std_logic_vector("0000" & unsigned(mirror_bits(axi_qpsk.tdata)) + BASE_OFFSET_QPSK);
  addr_8psk   <= std_logic_vector( "000" & unsigned(mirror_bits(axi_8psk.tdata)) + BASE_OFFSET_8PSK);            -- 8 PSK starts after QPSK
  addr_16apsk <= std_logic_vector(  "00" & unsigned(mirror_bits(axi_16apsk.tdata)) + BASE_OFFSET_16APSK);      -- 16 APSK starts after QPSK + 8 PSK
  addr_32apsk <= std_logic_vector(   "0" & unsigned(mirror_bits(axi_32apsk.tdata)) + BASE_OFFSET_32APSK); -- 32 APSK starts after QPSK + 8 PSK + 16 APSK

  -- Arbitrate between the outputs of all the width converters
  arbiter_block : block
    signal tdata_agg_in  : std_logic_array_t(3 downto 0)(6 + TUSER_WIDTH - 1 downto 0);
    signal tdata_agg_out : std_logic_vector(TUSER_WIDTH + 6 - 1 downto 0);
  begin

    tdata_agg_in(0) <= axi_qpsk.tuser & addr_qpsk;
    tdata_agg_in(1) <= axi_8psk.tuser & addr_8psk;
    tdata_agg_in(2) <= axi_16apsk.tuser & addr_16apsk;
    tdata_agg_in(3) <= axi_32apsk.tuser & addr_32apsk;

    arbiter_u : entity fpga_cores.axi_stream_arbiter
      generic map (
        MODE            => "ROUND_ROBIN",
        INTERFACES      => 4,
        DATA_WIDTH      => TUSER_WIDTH + 6,
        REGISTER_INPUTS => False)
      port map (
        -- Usual ports
        clk              => clk,
        rst              => rst,

        selected         => open,
        selected_encoded => open,

        -- AXI slave input
        s_tvalid(0)      => axi_qpsk.tvalid,
        s_tvalid(1)      => axi_8psk.tvalid,
        s_tvalid(2)      => axi_16apsk.tvalid,
        s_tvalid(3)      => axi_32apsk.tvalid,

        s_tready(0)      => axi_qpsk.tready,
        s_tready(1)      => axi_8psk.tready,
        s_tready(2)      => axi_16apsk.tready,
        s_tready(3)      => axi_32apsk.tready,

        s_tlast(0)       => axi_qpsk.tlast,
        s_tlast(1)       => axi_8psk.tlast,
        s_tlast(2)       => axi_16apsk.tlast,
        s_tlast(3)       => axi_32apsk.tlast,

        s_tdata          => tdata_agg_in,

        -- AXI master output
        m_tvalid         => axi_out.tvalid,
        m_tready         => axi_out.tready,
        m_tdata          => tdata_agg_out,
        m_tlast          => axi_out.tlast);

      axi_out.tdata <= tdata_agg_out(5 downto 0);
      axi_out.tuser <= tdata_agg_out(axi_out.tuser'length + 6 - 1 downto 6);

  end block;

  axi_out_cfg <= decode(axi_out.tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));

  -- Read the appropriate address of the radius RAM
  process(axi_out.tvalid, axi_out_cfg)
  begin
    radius_rd_addr               <= (others => 'U');
    dbg_radius_rd_addr_gen_error <= '0';

    case axi_out_cfg.frame_type is
      when FECFRAME_SHORT  =>
        case axi_out_cfg.constellation is
          when MOD_16APSK =>
            case axi_out_cfg.code_rate is
              when C2_3   => radius_rd_addr <= to_unsigned(RADIUS_SHORT_16APSK_C2_3,   radius_rd_addr'length);
              when C3_4   => radius_rd_addr <= to_unsigned(RADIUS_SHORT_16APSK_C3_4,   radius_rd_addr'length);
              when C3_5   => radius_rd_addr <= to_unsigned(RADIUS_SHORT_16APSK_C3_5,   radius_rd_addr'length);
              when C4_5   => radius_rd_addr <= to_unsigned(RADIUS_SHORT_16APSK_C4_5,   radius_rd_addr'length);
              when C5_6   => radius_rd_addr <= to_unsigned(RADIUS_SHORT_16APSK_C5_6,   radius_rd_addr'length);
              when C8_9   => radius_rd_addr <= to_unsigned(RADIUS_SHORT_16APSK_C8_9,   radius_rd_addr'length);
              when others => dbg_radius_rd_addr_gen_error <= axi_out.tvalid;
            end case;

          when MOD_32APSK =>
            case axi_out_cfg.code_rate is
              when C3_4   => radius_rd_addr <= to_unsigned(RADIUS_SHORT_32APSK_C3_4,   radius_rd_addr'length);
              when C4_5   => radius_rd_addr <= to_unsigned(RADIUS_SHORT_32APSK_C4_5,   radius_rd_addr'length);
              when C5_6   => radius_rd_addr <= to_unsigned(RADIUS_SHORT_32APSK_C5_6,   radius_rd_addr'length);
              when C8_9   => radius_rd_addr <= to_unsigned(RADIUS_SHORT_32APSK_C8_9,   radius_rd_addr'length);
              when others => dbg_radius_rd_addr_gen_error <= axi_out.tvalid;
            end case;

          when others => dbg_radius_rd_addr_gen_error <= axi_out.tvalid;
        end case;

      when FECFRAME_NORMAL  =>
        case axi_out_cfg.constellation is
          when MOD_16APSK =>
            case axi_out_cfg.code_rate is
              when C2_3   => radius_rd_addr <= to_unsigned(RADIUS_NORMAL_16APSK_C2_3,  radius_rd_addr'length);
              when C3_4   => radius_rd_addr <= to_unsigned(RADIUS_NORMAL_16APSK_C3_4,  radius_rd_addr'length);
              when C3_5   => radius_rd_addr <= to_unsigned(RADIUS_NORMAL_16APSK_C3_5,  radius_rd_addr'length);
              when C4_5   => radius_rd_addr <= to_unsigned(RADIUS_NORMAL_16APSK_C4_5,  radius_rd_addr'length);
              when C5_6   => radius_rd_addr <= to_unsigned(RADIUS_NORMAL_16APSK_C5_6,  radius_rd_addr'length);
              when C8_9   => radius_rd_addr <= to_unsigned(RADIUS_NORMAL_16APSK_C8_9,  radius_rd_addr'length);
              when C9_10  => radius_rd_addr <= to_unsigned(RADIUS_NORMAL_16APSK_C9_10, radius_rd_addr'length);
              when others => dbg_radius_rd_addr_gen_error <= axi_out.tvalid;
            end case;

          when MOD_32APSK =>
            case axi_out_cfg.code_rate is
              when C3_4   => radius_rd_addr <= to_unsigned(RADIUS_NORMAL_32APSK_C3_4,  radius_rd_addr'length);
              when C4_5   => radius_rd_addr <= to_unsigned(RADIUS_NORMAL_32APSK_C4_5,  radius_rd_addr'length);
              when C5_6   => radius_rd_addr <= to_unsigned(RADIUS_NORMAL_32APSK_C5_6,  radius_rd_addr'length);
              when C8_9   => radius_rd_addr <= to_unsigned(RADIUS_NORMAL_32APSK_C8_9,  radius_rd_addr'length);
              when C9_10  => radius_rd_addr <= to_unsigned(RADIUS_NORMAL_32APSK_C9_10, radius_rd_addr'length);
              when others => dbg_radius_rd_addr_gen_error <= axi_out.tvalid;
            end case;

          when others => dbg_radius_rd_addr_gen_error <= axi_out.tvalid;
        end case;

      when others => dbg_radius_rd_addr_gen_error <= axi_out.tvalid;
      end case;
  end process;

  ram_block : block
    signal tag_agg_in     : std_logic_vector(TID_WIDTH downto 0);
    signal tag_agg_out    : std_logic_vector(TID_WIDTH downto 0);
    signal radius_agg     : std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0);
    signal radius_in_tag  : std_logic_vector(ENCODED_CONFIG_WIDTH - 1 downto 0);
    signal radius_out_tag : std_logic_vector(ENCODED_CONFIG_WIDTH - 1 downto 0);
  begin
    -- Remove the encoded code rate from tuser here, we'll use it to address the radius RAM
    tag_agg_in    <= axi_out.tlast & axi_out.tuser(TUSER_WIDTH - 1 downto TUSER_WIDTH - TID_WIDTH);

    ram_out.tuser <= tag_agg_out(TID_WIDTH - 1 downto 0);
    ram_out.tlast <= tag_agg_out(TID_WIDTH);

    iq_map_ram_u : entity fpga_cores.axi_stream_ram
      generic map (
        DEPTH         => MAPPING_TABLE'length,
        DATA_WIDTH    => OUTPUT_DATA_WIDTH,
        INITIAL_VALUE => MAPPING_TABLE,
        TAG_WIDTH     => TID_WIDTH + 1,
        RAM_TYPE      => auto)
      port map (
        clk           => clk,
        rst           => rst,
        -- Write side
        wr_tready     => open,
        wr_tvalid     => iq_ram_wren,
        wr_addr       => iq_ram_addr,
        wr_data_in    => iq_ram_wdata,
        wr_data_out   => iq_ram_rdata,

        -- Read request side
        rd_in_tready  => axi_out.tready,
        rd_in_tvalid  => axi_out.tvalid,
        rd_in_addr    => axi_out.tdata,
        rd_in_tag     => tag_agg_in,

        -- Read response side
        rd_out_tready => ram_out.tready,
        rd_out_tvalid => ram_out.tvalid,
        rd_out_addr   => ram_out_addr,
        rd_out_data   => ram_out.tdata,
        rd_out_tag    => tag_agg_out);

    radius_in_tag  <= encode(axi_out_cfg);
    radius_out_cfg <= decode(radius_out_tag);

    radius_ram_u : entity fpga_cores.axi_stream_ram
      generic map (
        DEPTH         => RADIUS_TABLE_DEPTH,
        DATA_WIDTH    => OUTPUT_DATA_WIDTH,
        INITIAL_VALUE => RADIUS_TABLE,
        TAG_WIDTH     => ENCODED_CONFIG_WIDTH,
        RAM_TYPE      => auto)
      port map (
        clk           => clk,
        rst           => rst,
        -- Write side
        wr_tready     => open,
        wr_tvalid     => radius_ram_wren,
        wr_addr       => radius_ram_addr,
        wr_data_in    => radius_ram_wdata,
        wr_data_out   => radius_ram_rdata,

        -- Read request side
        rd_in_tready  => open,
        rd_in_tvalid  => axi_out.tvalid,
        rd_in_addr    => std_logic_vector(radius_rd_addr),
        rd_in_tag     => radius_in_tag,

        -- Read response side
        rd_out_tready => ram_out.tready,
        rd_out_tvalid => open,
        rd_out_addr   => open,
        rd_out_data   => radius_agg,
        rd_out_tag    => radius_out_tag);

      radius_0 <= signed(radius_agg(OUTPUT_DATA_WIDTH/2 - 1 downto 0));
      radius_1 <= signed(radius_agg(OUTPUT_DATA_WIDTH - 1 downto OUTPUT_DATA_WIDTH/2));
  end block;

  -- Need the raw offset for 16APSK and 32APSK to determine which radius we should use
  ram_out_offset <= unsigned(ram_out_addr) - BASE_OFFSET_16APSK when radius_out_cfg.constellation = mod_16apsk else
                    unsigned(ram_out_addr) - BASE_OFFSET_32APSK when radius_out_cfg.constellation = mod_32apsk else
                    (others => 'U');

  -- -- Select the correct multiplier based on frame length/constellation/code rate *AND*
  -- -- wether the address is outer, middle or inner radius
  -- output_multiplier <= UNIT_RADIUS      when radius_out_cfg.constellation = mod_qpsk or radius_out_cfg.constellation = mod_8psk else
  --                      radius_0         when radius_out_cfg.constellation = mod_16apsk and ram_out_offset < 12 else
  --                      radius_1         when radius_out_cfg.constellation = mod_16apsk and ram_out_offset >= 12 else
  --                      radius_0         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 0 else
  --                      radius_0         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 1 else
  --                      radius_0         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 2 else
  --                      radius_0         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 3 else
  --                      radius_0         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 4 else
  --                      radius_0         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 5 else
  --                      radius_0         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 6 else
  --                      radius_0         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 7 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 8 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 9 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 10 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 11 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 12 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 13 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 14 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 15 else
  --                      radius_0         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 16 else
  --                      radius_1         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 17 else
  --                      radius_0         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 18 else
  --                      radius_1         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 19 else
  --                      radius_0         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 20 else
  --                      radius_1         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 21 else
  --                      radius_0         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 22 else
  --                      radius_1         when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 23 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 24 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 25 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 26 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 27 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 28 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 29 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 30 else
  --                      UNIT_RADIUS      when radius_out_cfg.constellation = mod_32apsk and ram_out_offset = 31 else
  --                      (others => 'U');

  output_multiplier_p : process(radius_out_cfg, ram_out_offset, radius_0, radius_1)
  begin
    output_multiplier           <= (others => 'U');
    dbg_output_multiplier_error <= '0';

    case radius_out_cfg.constellation is
      when mod_qpsk | mod_8psk =>
        output_multiplier <= UNIT_RADIUS;

      when mod_16apsk =>
        if ram_out_offset < 12 then
          output_multiplier <= radius_0;
        else
          output_multiplier <= radius_1;
        end if;

      when mod_32apsk =>
        case to_integer(ram_out_offset) is
          when 0  => output_multiplier <= radius_0;
          when 1  => output_multiplier <= radius_0;
          when 2  => output_multiplier <= radius_0;
          when 3  => output_multiplier <= radius_0;
          when 4  => output_multiplier <= radius_0;
          when 5  => output_multiplier <= radius_0;
          when 6  => output_multiplier <= radius_0;
          when 7  => output_multiplier <= radius_0;
          when 8  => output_multiplier <= UNIT_RADIUS;
          when 9  => output_multiplier <= UNIT_RADIUS;
          when 10 => output_multiplier <= UNIT_RADIUS;
          when 11 => output_multiplier <= UNIT_RADIUS;
          when 12 => output_multiplier <= UNIT_RADIUS;
          when 13 => output_multiplier <= UNIT_RADIUS;
          when 14 => output_multiplier <= UNIT_RADIUS;
          when 15 => output_multiplier <= UNIT_RADIUS;
          when 16 => output_multiplier <= radius_0;
          when 17 => output_multiplier <= radius_1;
          when 18 => output_multiplier <= radius_0;
          when 19 => output_multiplier <= radius_1;
          when 20 => output_multiplier <= radius_0;
          when 21 => output_multiplier <= radius_1;
          when 22 => output_multiplier <= radius_0;
          when 23 => output_multiplier <= radius_1;
          when 24 => output_multiplier <= UNIT_RADIUS;
          when 25 => output_multiplier <= UNIT_RADIUS;
          when 26 => output_multiplier <= UNIT_RADIUS;
          when 27 => output_multiplier <= UNIT_RADIUS;
          when 28 => output_multiplier <= UNIT_RADIUS;
          when 29 => output_multiplier <= UNIT_RADIUS;
          when 30 => output_multiplier <= UNIT_RADIUS;
          when 31 => output_multiplier <= UNIT_RADIUS;
          when others => dbg_output_multiplier_error <= '1';
        end case;

      when others => dbg_output_multiplier_error <= '1';
    end case;
  end process;

  -- Separate IQ components to make multipliying easier
  ram_out_i <= signed(ram_out.tdata(OUTPUT_DATA_WIDTH/2 - 1 downto 0));
  ram_out_q <= signed(ram_out.tdata(OUTPUT_DATA_WIDTH - 1 downto OUTPUT_DATA_WIDTH/2));

  -- Use RAM and radius outputs to make up the final IQ values
  output_i <= ram_out_i * output_multiplier;
  output_q <= ram_out_q * output_multiplier;

  -- Add a FF at the output so that the multiplier doesn't cause timing issues
  output_block : block
    signal tdata_agg_in  : std_logic_vector(OUTPUT_DATA_WIDTH + TID_WIDTH downto 0);
    signal tdata_agg_out : std_logic_vector(OUTPUT_DATA_WIDTH + TID_WIDTH downto 0);
  begin

    tdata_agg_in <= ram_out.tlast
                    & ram_out.tuser
                    & std_logic_vector(output_i(OUTPUT_DATA_WIDTH - 2 downto OUTPUT_DATA_WIDTH/2 - 1))
                    & std_logic_vector(output_q(OUTPUT_DATA_WIDTH - 2 downto OUTPUT_DATA_WIDTH/2 - 1));

    output_delay_u : entity fpga_cores.axi_stream_delay
      generic map (
        DELAY_CYCLES => 1,
        TDATA_WIDTH  => OUTPUT_DATA_WIDTH + TID_WIDTH + 1)
      port map (
        -- Usual ports
        clk     => clk,
        rst     => rst,

        -- AXI slave input
        s_tvalid => ram_out.tvalid,
        s_tready => ram_out.tready,
        s_tdata  => tdata_agg_in,

        -- AXI master output
        m_tvalid => m_tvalid,
        m_tready => m_tready,
        m_tdata  => tdata_agg_out);

        m_tdata <= tdata_agg_out(OUTPUT_DATA_WIDTH - 1 downto 0);
        m_tid   <= tdata_agg_out(OUTPUT_DATA_WIDTH + TID_WIDTH - 1 downto OUTPUT_DATA_WIDTH);
        m_tlast <= tdata_agg_out(OUTPUT_DATA_WIDTH + TID_WIDTH);
  end block;

end axi_constellation_mapper;
