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
use fpga_cores.axi_pkg.all;

use work.dvb_utils_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_physical_layer_pilots is
  generic (
    TDATA_WIDTH : integer := 8;
    TID_WIDTH   : integer := 0
  );
  port (
    -- Usual ports
    clk             : in  std_logic;
    rst             : in  std_logic;
    -- AXI data input
    s_tready        : out std_logic;
    s_tdata         : in  std_logic_vector(TDATA_WIDTH - 1 downto 0);
    s_tid           : in  std_logic_vector(TID_WIDTH - 1 downto 0);
    s_tlast         : in  std_logic;
    s_tvalid        : in  std_logic;

    -- AXI output
    m_tready        : in  std_logic;
    m_tvalid        : out std_logic;
    m_tlast         : out std_logic;
    m_tdata         : out std_logic_vector(TDATA_WIDTH - 1 downto 0);
    m_tid           : out std_logic_vector(TID_WIDTH - 1 downto 0));
end axi_physical_layer_pilots;

architecture axi_physical_layer_pilots of axi_physical_layer_pilots is

  ---------------
  -- Constants --
  ---------------
  constant SYMBOLS_PER_SLOT : integer := 90;
  constant PILOT_SYMBOLS    : integer := 36;

  -------------
  -- Signals --
  -------------
  signal s_tready_i    : std_logic;
  signal m_tvalid_i    : std_logic;
  signal m_dv          : std_logic;
  signal s_tid_reg     : std_logic_vector(TID_WIDTH - 1 downto 0);

  signal slot_count    : unsigned(4 downto 0); -- Count up to 16 (inclusive)
  signal symbol_count  : unsigned(numbits(SYMBOLS_PER_SLOT) - 1 downto 0);

  signal last_symbol   : std_logic;
  signal last_pilot    : std_logic;
  signal insert_pilots : std_logic;

begin

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  m_dv     <= m_tvalid_i and m_tready;
  m_tvalid <= m_tvalid_i;
  s_tready <= s_tready_i;


  insert_pilots <= '1' when slot_count = 16 else
                   '0' when slot_count /= 16 else
                   'U';

  last_symbol <= '1' when insert_pilots = '0' and symbol_count = SYMBOLS_PER_SLOT - 1 else s_tlast;
  last_pilot  <= '1' when insert_pilots = '1' and symbol_count = PILOT_SYMBOLS - 1 else s_tlast;

  -------------------
  -- Port Mappings --
  -------------------
  output_mux_block : block
    signal tdata0_agg_in : std_logic_vector(TDATA_WIDTH + TID_WIDTH downto 0);
    signal tdata1_agg_in : std_logic_vector(TDATA_WIDTH + TID_WIDTH downto 0);
    signal tdata_agg_out : std_logic_vector(TDATA_WIDTH + TID_WIDTH downto 0);
    signal pilots_tdata  : std_logic_vector(TDATA_WIDTH - 1 downto 0);
    signal pilots_tready : std_logic; -- Unused
  begin

    tdata0_agg_in <= s_tlast & s_tid & s_tdata;
    tdata1_agg_in <= '0' & s_tid_reg & pilots_tdata;

    pilots_tdata  <= std_logic_vector(sin(MATH_PI / 4.0, TDATA_WIDTH/2) & cos(MATH_PI / 4.0, TDATA_WIDTH/2));

    output_mux_u : entity fpga_cores.axi_stream_mux
      generic map (
        INTERFACES => 2,
        DATA_WIDTH => TDATA_WIDTH + TID_WIDTH + 1)
      port map (
        selection_mask => (0 => not insert_pilots, 1 => insert_pilots),

        s_tvalid(0)    => s_tvalid,
        s_tvalid(1)    => '1',

        s_tready(0)    => s_tready_i,
        s_tready(1)    => pilots_tready,

        s_tdata(0)     => tdata0_agg_in,
        s_tdata(1)     => tdata1_agg_in,

        m_tvalid       => m_tvalid_i,
        m_tready       => m_tready,
        m_tdata        => tdata_agg_out);

      m_tdata <= tdata_agg_out(TDATA_WIDTH - 1 downto 0);
      m_tid   <= tdata_agg_out(TDATA_WIDTH + TID_WIDTH - 1 downto TDATA_WIDTH);
      m_tlast <= tdata_agg_out(TDATA_WIDTH + TID_WIDTH);
  end block;


  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
  begin
    if rst then
      symbol_count <= (others => '0');
      slot_count   <= (others => '0');
    elsif rising_edge(clk) then
      if s_tvalid then
        s_tid_reg <= s_tid;
      end if;

      if m_dv then
        symbol_count <= symbol_count + 1;
        if last_symbol or last_pilot then
          symbol_count <= (others => '0');
          if last_pilot then
            slot_count   <= (others => '0');
          else
            slot_count   <= slot_count + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

end axi_physical_layer_pilots;
