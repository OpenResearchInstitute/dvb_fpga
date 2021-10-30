--
-- DVB FPGA
--
-- Copyright 2019 by suoto <andre820@gmail.com>
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
use fpga_cores.common_pkg.all;
use fpga_cores.axi_pkg.all;

use work.dvb_utils_pkg.all;

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
    clk             : in  std_logic;
    rst             : in  std_logic;
    -- Mapping RAM config
    ram_wren        : in  std_logic;
    ram_addr        : in  std_logic_vector(5 downto 0);
    ram_wdata       : in  std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0);
    ram_rdata       : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0);
    -- AXI data input
    s_constellation : in  constellation_t;
    s_tready        : out std_logic;
    s_tvalid        : in  std_logic;
    s_tlast         : in  std_logic;
    s_tdata         : in  std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0);
    s_tid           : in  std_logic_vector(TID_WIDTH - 1 downto 0);
    -- AXI output
    m_tready        : in  std_logic;
    m_tvalid        : out std_logic;
    m_tlast         : out std_logic;
    m_tdata         : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0);
    m_tid           : out std_logic_vector(TID_WIDTH - 1 downto 0));
end axi_constellation_mapper;

architecture axi_constellation_mapper of axi_constellation_mapper is

  constant CONFIG_INPUT_WIDTHS: fpga_cores.common_pkg.integer_vector_t := (
    0 => CONSTELLATION_WIDTH,
    1 => TID_WIDTH);

  constant TUSER_WIDTH : integer := sum(CONFIG_INPUT_WIDTHS);

  -------------
  -- Signals --
  -------------
  signal s_tid_internal       : std_logic_vector(TUSER_WIDTH - 1 downto 0);
  signal mux_sel              : std_logic_vector(3 downto 0);
  signal conv_tready          : std_logic_vector(3 downto 0);
  signal conv_tvalid          : std_logic_vector(3 downto 0);

  signal axi_qpsk             : axi_stream_bus_t(tdata(1 downto 0), tuser(sum(CONFIG_INPUT_WIDTHS) - 1 downto 0));
  signal axi_8psk             : axi_stream_bus_t(tdata(2 downto 0), tuser(sum(CONFIG_INPUT_WIDTHS) - 1 downto 0));
  signal axi_16apsk           : axi_stream_bus_t(tdata(3 downto 0), tuser(sum(CONFIG_INPUT_WIDTHS) - 1 downto 0));
  signal axi_32apsk           : axi_stream_bus_t(tdata(4 downto 0), tuser(sum(CONFIG_INPUT_WIDTHS) - 1 downto 0));

  signal addr_qpsk            : std_logic_vector(5 downto 0);
  signal addr_8psk            : std_logic_vector(5 downto 0);
  signal addr_16apsk          : std_logic_vector(5 downto 0);
  signal addr_32apsk          : std_logic_vector(5 downto 0);

  signal map_addr             : std_logic_vector(5 downto 0);
  signal map_data             : std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0);
  signal map_cfg              : std_logic_vector(sum(CONFIG_INPUT_WIDTHS) - 1 downto 0);

  -- ROM side config, so won't need to wait until an entire frame goes through
  signal egress_constellation : constellation_t;
  signal egress_tid           : std_logic_vector(TID_WIDTH - 1 downto 0);
  signal egress_tid_reg       : std_logic_vector(TID_WIDTH - 1 downto 0);

  signal adapter_wr_en        : std_logic;
  signal adapter_full         : std_logic;
  signal adapter_wr_last      : std_logic;

begin

  -------------------
  -- Port mappings --
  -------------------
  -- Mux the input data stream to the appropriate width converter
  input_mux_u : entity fpga_cores.axi_stream_demux
    generic map (
      INTERFACES => 4,
      DATA_WIDTH => 0)
    port map (
      selection_mask => mux_sel,

      s_tvalid       => s_tvalid,
      s_tready       => s_tready,
      s_tdata        => (others => 'U'),

      m_tvalid       => conv_tvalid,
      m_tready       => conv_tready,
      m_tdata        => open);

  -- Width converter is little endian but DVB-S2 requires mapping MSB of the data, so we
  -- mirror data in then mirror data out
  width_converter_qpsk_u : entity fpga_cores.axi_stream_width_converter
  generic map (
    INPUT_DATA_WIDTH  => INPUT_DATA_WIDTH,
    OUTPUT_DATA_WIDTH => 2,
    AXI_TID_WIDTH     => sum(CONFIG_INPUT_WIDTHS),
    IGNORE_TKEEP      => True)
  port map (
    -- Usual ports
    clk      => clk,
    rst      => rst,
    -- AXI stream input
    s_tready => conv_tready(0),
    s_tdata  => mirror_bits(s_tdata),
    s_tid    => s_tid_internal,
    s_tvalid => conv_tvalid(0),
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
    AXI_TID_WIDTH     => sum(CONFIG_INPUT_WIDTHS),
    IGNORE_TKEEP      => True)
  port map (
    -- Usual ports
    clk      => clk,
    rst      => rst,
    -- AXI stream input
    s_tready => conv_tready(1),
    s_tdata  => mirror_bits(s_tdata),
    s_tid    => s_tid_internal,
    s_tvalid => conv_tvalid(1),
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
    AXI_TID_WIDTH     => sum(CONFIG_INPUT_WIDTHS),
    IGNORE_TKEEP      => True)
  port map (
    -- Usual ports
    clk      => clk,
    rst      => rst,
    -- AXI stream input
    s_tready => conv_tready(2),
    s_tdata  => mirror_bits(s_tdata),
    s_tid    => s_tid_internal,
    s_tvalid => conv_tvalid(2),
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
    AXI_TID_WIDTH     => sum(CONFIG_INPUT_WIDTHS),
    IGNORE_TKEEP      => True)
  port map (
    -- Usual ports
    clk      => clk,
    rst      => rst,
    -- AXI stream input
    s_tready => conv_tready(3),
    s_tdata  => mirror_bits(s_tdata),
    s_tid    => s_tid_internal,
    s_tvalid => conv_tvalid(3),
    s_tlast  => s_tlast,
    -- AXI stream output
    m_tready => axi_32apsk.tready,
    m_tdata  => axi_32apsk.tdata,
    m_tid    => axi_32apsk.tuser,
    m_tvalid => axi_32apsk.tvalid,
    m_tlast  => axi_32apsk.tlast);

  -- QPSK and 8 PSK values are constant but 16 APSK and 32 APSK depend on the coding
  -- rate. Currently we're supporting any number of QPSK and/or 8 PSK streams, but 16 APSK
  -- and 32 APSK are both limited to a single stream
  mapping_table_u : entity fpga_cores.ram_inference
    generic map (
      ADDR_WIDTH   => 6,
      DATA_WIDTH   => OUTPUT_DATA_WIDTH,
      RAM_TYPE     => auto,
      OUTPUT_DELAY => 1)
    port map (
      -- Port A
      clk_a     => clk,
      clken_a   => '1',
      wren_a    => ram_wren,
      addr_a    => ram_addr,
      wrdata_a  => ram_wdata,
      rddata_a  => ram_rdata,
      -- Port B
      clk_b     => clk,
      clken_b   => '1',
      addr_b    => map_addr,
      rddata_b  => map_data);

  output_adapter_block : block
    signal agg_data_in : std_logic_vector(TID_WIDTH + OUTPUT_DATA_WIDTH - 1 downto 0);
    signal agg_data_out : std_logic_vector(TID_WIDTH + OUTPUT_DATA_WIDTH - 1 downto 0);
  begin
    -- map data comes with 1 cycle of latency, compensate for that
    output_adapter_u : entity fpga_cores.axi_stream_master_adapter
      generic map (
        MAX_SKEW_CYCLES => 1,
        TDATA_WIDTH     => OUTPUT_DATA_WIDTH + TID_WIDTH)
      port map (
        -- Usual ports
        clk      => clk,
        reset    => rst,
        -- wanna-be AXI interface
        wr_en    => adapter_wr_en,
        wr_full  => adapter_full,
        wr_empty => open,
        wr_data  => agg_data_in,
        wr_last  => adapter_wr_last,
        -- AXI master
        m_tvalid => m_tvalid,
        m_tready => m_tready,
        m_tdata  => agg_data_out,
        m_tlast  => m_tlast);

    agg_data_in <= egress_tid_reg & map_data;
    m_tdata     <= agg_data_out(OUTPUT_DATA_WIDTH - 1 downto 0);
    m_tid       <= agg_data_out(OUTPUT_DATA_WIDTH + TID_WIDTH - 1 downto OUTPUT_DATA_WIDTH);
  end block;

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  mux_sel(0) <= '1' when s_constellation = mod_qpsk or s_constellation = not_set else '0';
  mux_sel(1) <= '1' when s_constellation = mod_8psk or s_constellation = not_set else '0';
  mux_sel(2) <= '1' when s_constellation = mod_16apsk or s_constellation = not_set else '0';
  mux_sel(3) <= '1' when s_constellation = mod_32apsk or s_constellation = not_set else '0';

  -- Addr CONSTELLATION_ROM offsets to the width converter output. Each table starts
  -- immediatelly after the previous
  --
  -- Also, a reminder that the width converter is little endian but our data is big
  -- endian. We mirrored the data going in now need to mirror the output as well
  addr_qpsk   <= "0000" & mirror_bits(axi_qpsk.tdata);
  addr_8psk   <= std_logic_vector("000" & unsigned(mirror_bits(axi_8psk.tdata)) + 4);            -- 8 PSK starts after QPSK
  addr_16apsk <= std_logic_vector( "00" & unsigned(mirror_bits(axi_16apsk.tdata)) + 4 + 8);      -- 16 APSK starts after QPSK + 8 PSK
  addr_32apsk <= std_logic_vector(  "0" & unsigned(mirror_bits(axi_32apsk.tdata)) + 4 + 8 + 16); -- 32 APSK starts after QPSK + 8 PSK + 16 APSK

  -- Only one will be active at a time
  map_addr <= (addr_qpsk   and (5 downto 0 => axi_qpsk.tvalid)) or
              (addr_8psk   and (5 downto 0 => axi_8psk.tvalid)) or
              (addr_16apsk and (5 downto 0 => axi_16apsk.tvalid)) or
              (addr_32apsk and (5 downto 0 => axi_32apsk.tvalid));

  -- Select the config from the active channel (only one will be writing at a time)
  map_cfg <= (axi_qpsk.tuser   and (sum(CONFIG_INPUT_WIDTHS) - 1 downto 0 => axi_qpsk.tvalid)) or
             (axi_8psk.tuser   and (sum(CONFIG_INPUT_WIDTHS) - 1 downto 0 => axi_8psk.tvalid)) or
             (axi_16apsk.tuser and (sum(CONFIG_INPUT_WIDTHS) - 1 downto 0 => axi_16apsk.tvalid)) or
             (axi_32apsk.tuser and (sum(CONFIG_INPUT_WIDTHS) - 1 downto 0 => axi_32apsk.tvalid));

  egress_constellation <= decode(get_field(map_cfg, 0, CONFIG_INPUT_WIDTHS));
  egress_tid           <= get_field(map_cfg, 1, CONFIG_INPUT_WIDTHS);

  axi_qpsk.tready      <= not adapter_full when egress_constellation = mod_qpsk else '0';
  axi_8psk.tready      <= not adapter_full when egress_constellation = mod_8psk else '0';
  axi_16apsk.tready    <= not adapter_full when egress_constellation = mod_16apsk else '0';
  axi_32apsk.tready    <= not adapter_full when egress_constellation = mod_32apsk else '0';

  s_tid_internal    <= s_tid & encode(s_constellation);

  ---------------
  -- Processes --
  ---------------
  process(clk)
  begin
    if rising_edge(clk) then
      adapter_wr_en   <= '0';
      adapter_wr_last <= '0';
      egress_tid_reg  <= egress_tid;
      if not adapter_full then
        adapter_wr_en   <= (axi_qpsk.tvalid or axi_8psk.tvalid or axi_16apsk.tvalid or axi_32apsk.tvalid)
                       and (axi_qpsk.tready or axi_8psk.tready or axi_16apsk.tready or axi_32apsk.tready);
        adapter_wr_last <= axi_qpsk.tlast or axi_8psk.tlast or axi_16apsk.tlast or axi_32apsk.tlast;
      end if;

    end if;
  end process;

end axi_constellation_mapper;
