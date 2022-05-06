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
use fpga_cores.axi_pkg.all;

use work.dvb_utils_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_bbframe_length_enforcer is
  generic (
    TDATA_WIDTH : integer  := 8;
    TUSER_WIDTH : integer  := 8
  );
  port (
    -- Usual ports
    clk             : in  std_logic;
    rst             : in  std_logic;

    -- AXI input
    s_frame_type    : in  frame_type_t;
    s_code_rate     : in  code_rate_t;
    s_tvalid        : in  std_logic;
    s_tdata         : in  std_logic_vector(TDATA_WIDTH - 1 downto 0);
    s_tuser         : in  std_logic_vector(TUSER_WIDTH - 1 downto 0);
    s_tlast         : in  std_logic;
    s_tready        : out std_logic;
    -- AXI output
    m_tready        : in  std_logic;
    m_tvalid        : out std_logic;
    m_tlast         : out std_logic;
    m_tdata         : out std_logic_vector(TDATA_WIDTH - 1 downto 0);
    m_tuser         : out std_logic_vector(TUSER_WIDTH - 1 downto 0));
end axi_bbframe_length_enforcer;

architecture axi_bbframe_length_enforcer of axi_bbframe_length_enforcer is

  -- Assign a ROM addr to each config
  function get_rom_addr (
    constant frame_type : frame_type_t;
    constant code_rate  : code_rate_t) return integer is
  begin
    case frame_type is
      when FECFRAME_SHORT =>
        case code_rate is
          when C1_4 => return 0;
          when C1_3 => return 1;
          when C2_5 => return 2;
          when C1_2 => return 3;
          when C3_5 => return 4;
          when C2_3 => return 5;
          when C3_4 => return 6;
          when C4_5 => return 7;
          when C5_6 => return 8;
          when C8_9 => return 9;
          when others => null;
        end case;

      when FECFRAME_NORMAL =>
        case code_rate is
          when C1_4  => return 10;
          when C1_3  => return 11;
          when C2_5  => return 12;
          when C1_2  => return 13;
          when C3_5  => return 14;
          when C2_3  => return 15;
          when C3_4  => return 16;
          when C4_5  => return 17;
          when C5_6  => return 18;
          when C8_9  => return 19;
          when C9_10 => return 20;
          when others => null;
        end case;

        when others => null;
      end case;
      return 0;
  end function;

  constant ROM_DATA_WIDTH : integer := numbits(58_192 / TDATA_WIDTH);

  -- Just a little helper to convert the frame length in bits to frame length in tdata
  -- words as a std logic vector
  function get_value_for_rom ( constant v : integer ) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(v / TDATA_WIDTH, ROM_DATA_WIDTH));
  end function;

  constant FRAME_LENGTH_ROM : std_logic_array_t(0 to 20)(ROM_DATA_WIDTH - 1 downto 0) := (
    0  => get_value_for_rom(3_072),
    1  => get_value_for_rom(5_232),
    2  => get_value_for_rom(6_312),
    3  => get_value_for_rom(7_032),
    4  => get_value_for_rom(9_552),
    5  => get_value_for_rom(10_632),
    6  => get_value_for_rom(11_712),
    7  => get_value_for_rom(12_432),
    8  => get_value_for_rom(13_152),
    9  => get_value_for_rom(14_232),
    10 => get_value_for_rom(16_008),
    11 => get_value_for_rom(21_408),
    12 => get_value_for_rom(25_728),
    13 => get_value_for_rom(32_208),
    14 => get_value_for_rom(38_688),
    15 => get_value_for_rom(43_040),
    16 => get_value_for_rom(48_408),
    17 => get_value_for_rom(51_648),
    18 => get_value_for_rom(53_840),
    19 => get_value_for_rom(57_472),
    20 => get_value_for_rom(58_192)
  );

  signal rom_addr      : unsigned(numbits(FRAME_LENGTH_ROM'length) - 1 downto 0);
  signal frame_length  : std_logic_vector(ROM_DATA_WIDTH - 1 downto 0);

  signal delay_output  : axi_stream_bus_t(tdata(TDATA_WIDTH - 1 downto 0), tuser(TUSER_WIDTH - 1 downto 0));
  signal slicer_output : axi_stream_bus_t(tdata(TDATA_WIDTH - 1 downto 0), tuser(TUSER_WIDTH - 1 downto 0));

begin

  -------------------
  -- Port mappings --
  -------------------
  rom_addr <= to_unsigned(get_rom_addr(s_frame_type, s_code_rate), numbits(FRAME_LENGTH_ROM'length));

  -- The ROM with the coefficients from the spec
  rom_u : entity fpga_cores.rom_inference
    generic map (
      ROM_DATA     => FRAME_LENGTH_ROM,
      ROM_TYPE     => auto,
      OUTPUT_DELAY => 1)
    port map (
      clk    => clk,
      clken  => '1',
      addr   => std_logic_vector(rom_addr),
      rddata => frame_length);

  -- Delay the incoming AXI stream to match the ROM latency
  delay_block : block
    signal s_tdata_agg : std_logic_vector(TDATA_WIDTH + TUSER_WIDTH downto 0);
    signal m_tdata_agg : std_logic_vector(TDATA_WIDTH + TUSER_WIDTH downto 0);
  begin
    s_tdata_agg <= s_tlast & s_tuser & s_tdata;

    delay_output.tlast <= m_tdata_agg(TDATA_WIDTH + TUSER_WIDTH);
    delay_output.tuser <= m_tdata_agg(TUSER_WIDTH + TDATA_WIDTH - 1 downto TDATA_WIDTH);
    delay_output.tdata <= m_tdata_agg(TDATA_WIDTH - 1 downto 0);

    delay_u : entity fpga_cores.axi_stream_delay
      generic map (
        DELAY_CYCLES => 1,
        TDATA_WIDTH  => TDATA_WIDTH + TUSER_WIDTH + 1)
      port map (
        -- Usual ports
        clk     => clk,
        rst     => rst,

        -- AXI slave input
        s_tvalid => s_tvalid,
        s_tready => s_tready,
        s_tdata  => s_tdata_agg,

        -- AXI master output
        m_tvalid => delay_output.tvalid,
        m_tready => delay_output.tready,
        m_tdata  => m_tdata_agg);
  end block;

  -- Slicer and padder insert no latency, so we can extract tuser right after the
  -- axi_stream_delay
  m_tuser <= delay_output.tuser;

  -- Trim bigger frames first
  slicer_u : entity fpga_cores.axi_stream_frame_slicer
    generic map (
      FRAME_LENGTH_WIDTH => ROM_DATA_WIDTH,
      TDATA_WIDTH        => TDATA_WIDTH)
    port map (
      -- Usual ports
      clk          => clk,
      rst          => rst,

      frame_length => frame_length,

      -- Input stream
      s_tvalid     => delay_output.tvalid,
      s_tready     => delay_output.tready,
      s_tdata      => delay_output.tdata,
      s_tlast      => delay_output.tlast,

      -- Output stream
      m_tvalid     => slicer_output.tvalid,
      m_tready     => slicer_output.tready,
      m_tdata      => slicer_output.tdata,
      m_tlast      => slicer_output.tlast);

  -- Pad frames after slicing
  padder_u : entity fpga_cores.axi_stream_frame_padder
    generic map (
      FRAME_LENGTH_WIDTH => ROM_DATA_WIDTH,
      TDATA_WIDTH        => TDATA_WIDTH)
    port map (
      -- Usual ports
      clk          => clk,
      rst          => rst,

      frame_length => frame_length,

      -- Input stream
      s_tvalid     => slicer_output.tvalid,
      s_tready     => slicer_output.tready,
      s_tdata      => slicer_output.tdata,
      s_tlast      => slicer_output.tlast,

      -- Output stream
      m_tvalid     => m_tvalid,
      m_tready     => m_tready,
      m_tdata      => m_tdata,
      m_tlast      => m_tlast);

end axi_bbframe_length_enforcer;
