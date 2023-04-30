-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
--
-- DVB FPGA
--
-- Copyright 2020-2022 by suoto <andre820@gmail.com>
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

-- Authors: Anshul Makkar <anshulmakkar@gmail.com>, suoto <andre820@gmail.com>

---------------
-- Libraries --
---------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.MATH_PI;

library fpga_cores;
use fpga_cores.common_pkg.all;

use work.dvb_utils_pkg.all;
use work.plframe_header_pkg.all;

-- Creates PLFRAME headers from a set of config parameters. Please note pilots ARE NOT
-- SUPPORTED yet!
--
-- PLS codes and modulation values are pre-calculated and stored in ROMs. The code to
-- create both ROM's contents are pretty much an implementation of GNU Radio's C code in
-- VHDL. Relevant files are:
-- https://github.com/gnuradio/gnuradio/blob/master/gr-dtv/lib/dvbs2/dvbs2_physical_cc_impl.cc
-- https://github.com/gnuradio/gnuradio/blob/master/gr-dtv/lib/dvbs2/dvbs2_physical_cc_impl.h
--

------------------------
-- Entity declaration --
------------------------
entity axi_physical_layer_header is
  generic (
    DATA_WIDTH : integer := 8
  );
  port (
    -- Usual ports
    clk             : in  std_logic;
    rst             : in  std_logic;
    -- AXI data input
    s_constellation : in  constellation_t;
    s_frame_type    : in  frame_type_t;
    s_code_rate     : in  code_rate_t;
    s_pilots        : in  std_logic;
    s_tready        : out std_logic;
    s_tvalid        : in  std_logic;
    -- AXI output
    m_tready        : in  std_logic;
    m_tvalid        : out std_logic;
    m_tlast         : out std_logic;
    m_tdata         : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end axi_physical_layer_header;

architecture axi_physical_layer_header of axi_physical_layer_header is

  ---------------
  -- Constants --
  ---------------
  constant MOD_8PSK_MAP : std_logic_array_t(0 to 7)(DATA_WIDTH - 1 downto 0) := (
    0 => std_logic_vector(sin(      MATH_PI / 4.0, DATA_WIDTH/2) & cos(      MATH_PI / 4.0, DATA_WIDTH/2)),
    1 => std_logic_vector(sin(5.0 * MATH_PI / 4.0, DATA_WIDTH/2) & cos(5.0 * MATH_PI / 4.0, DATA_WIDTH/2)),
    2 => std_logic_vector(sin(      MATH_PI / 4.0, DATA_WIDTH/2) & cos(5.0 * MATH_PI / 4.0, DATA_WIDTH/2)),
    3 => std_logic_vector(sin(5.0 * MATH_PI / 4.0, DATA_WIDTH/2) & cos(      MATH_PI / 4.0, DATA_WIDTH/2)),
    4 => std_logic_vector(sin(      MATH_PI / 4.0, DATA_WIDTH/2) & cos(5.0 * MATH_PI / 4.0, DATA_WIDTH/2)),
    5 => std_logic_vector(sin(5.0 * MATH_PI / 4.0, DATA_WIDTH/2) & cos(      MATH_PI / 4.0, DATA_WIDTH/2)),
    6 => std_logic_vector(sin(5.0 * MATH_PI / 4.0, DATA_WIDTH/2) & cos(5.0 * MATH_PI / 4.0, DATA_WIDTH/2)),
    7 => std_logic_vector(sin(      MATH_PI / 4.0, DATA_WIDTH/2) & cos(      MATH_PI / 4.0, DATA_WIDTH/2))
  );

  -- SOF is the same for all configs, so we'll only store the PLS
  constant PLS_ROM       : std_logic_array_t := get_pls_rom;
  constant PLS_ROM_DEPTH : integer           := PLS_ROM'length;

  -------------
  -- Signals --
  -------------
  signal s_tready_i       : std_logic;
  signal modulation_index : std_logic;
  signal modulation_addr  : std_logic_vector(2 downto 0);
  signal pls_rom_addr     : std_logic_vector(numbits(PLS_ROM_DEPTH) - 1 downto 0);
  signal pls_code         : std_logic_vector(63 downto 0);
  signal header           : std_logic_vector(89 downto 0);

  signal m_tdata_i        : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal m_tvalid_i       : std_logic;
  signal m_tlast_i        : std_logic;
  signal header_sr        : std_logic_vector(89 downto 0);
  signal header_sr_cnt    : unsigned(numbits(90) - 1 downto 0);

begin

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  m_tlast   <= m_tlast_i and m_tvalid_i;
  m_tvalid  <= m_tvalid_i;
  s_tready  <= s_tready_i;

  m_tlast_i <= '1' when header_sr_cnt = 89 else '0';

  pls_rom_addr    <= (others => 'U') when get_pls_rom_addr(s_constellation, s_frame_type, s_code_rate, s_pilots = '1') = -1 else
                     std_logic_vector(to_unsigned(get_pls_rom_addr(s_constellation, s_frame_type, s_code_rate, s_pilots = '1'), numbits(PLS_ROM_DEPTH)));

  header          <= SOF & pls_code;
  modulation_addr <= '0' & modulation_index & header_sr(89);

  -------------------
  -- Port Mappings --
  -------------------
  pls_rom_u : entity fpga_cores.rom_inference
  generic map (
    ROM_DATA     => PLS_ROM,
    ROM_TYPE     => lut,
    OUTPUT_DELAY => 0)
  port map (
    clk    => clk,
    clken  => '1',
    addr   => pls_rom_addr,
    rddata => pls_code);

  modulation_rom_u : entity fpga_cores.rom_inference
  generic map (
    ROM_DATA     => MOD_8PSK_MAP,
    ROM_TYPE     => lut, -- To allow same cycle reading
    OUTPUT_DELAY => 0)
  port map (
    clk    => clk,
    clken  => '1',
    addr   => modulation_addr,
    rddata => m_tdata_i);

  m_tdata   <= m_tdata_i when m_tvalid_i = '1' else (others => 'U');

  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
  begin
    if rst = '1' then
      modulation_index <= 'U';
      s_tready_i       <= '1';
      m_tvalid_i       <= '0';
      header_sr        <= (others => 'U');
      header_sr_cnt    <= (others => 'U');
    elsif rising_edge(clk) then
      if s_tready_i and s_tvalid then
        s_tready_i       <= '0';
        header_sr        <= header;
        m_tvalid_i       <= '1';
        modulation_index <= '0';
        header_sr_cnt    <= (others => '0');
      end if;

      if m_tvalid_i and m_tready then
        header_sr        <= header_sr(88 downto 0) & '0';
        header_sr_cnt    <= header_sr_cnt + 1;
        modulation_index <= not modulation_index;
        if m_tlast_i then
          modulation_index <= '0';
          m_tvalid_i <= '0';
          s_tready_i <= '1';
        end if;
      end if;
    end if;
  end process;

end axi_physical_layer_header;
