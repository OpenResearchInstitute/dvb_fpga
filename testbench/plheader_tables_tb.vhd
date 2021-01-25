-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
--
-- DVB FPGA
--
-- Copyright 2019 by Anshul Makkar <anshulmakkar@gmail.com>
--
-- This file is part of DVB FPGA.
--
-- DVB FPGA is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- DVB FPGA is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DVB FPGA.  If not, see <http://www.gnu.org/licenses/>.

-- vunit: run_all_in_same_sim

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

library osvvm;
use osvvm.RandomPkg.all;

library str_format;
use str_format.str_format_pkg.all;

library fpga_cores;
use fpga_cores.axi_pkg.all;
use fpga_cores.common_pkg.all;

library fpga_cores_sim;
use fpga_cores_sim.testbench_utils_pkg.all;

use work.dvb_utils_pkg.all;
use work.ldpc_pkg.all;

-- ghdl translate_off
library modelsim_lib;
use modelsim_lib.util.all;
-- ghdl translate_on

entity plheader_tables_tb is
  generic (
    RUNNER_CFG            : string;
    TEST_CFG              : string;
    NUMBER_OF_TEST_FRAMES : integer := 8);
end plheader_tables_tb;

architecture plheader_tables_tb of plheader_tables_tb is

  ---------------
  -- Constants --
  ---------------
  constant DATA_WIDTH        : integer := 8;

  constant CLK_PERIOD        : time    := 5 ns;

  -------------
  -- Signals --
  -------------
  -- Usual ports
  signal clk                : std_logic := '1';
  signal rst                : std_logic;

  signal m_constellation    : constellation_t;
  signal m_frame_type       : frame_type_t;
  signal m_code_rate        : code_rate_t;
  signal m_tvalid           : std_logic;
  signal m_tready           : std_logic;
  signal axi_slave_tready   : std_logic;
  signal axi_slave_tvalid   : std_logic;
  signal axi_slave_tdata    : std_logic_vector(90 downto 0);
  signal axi_slave_tlast    : std_logic;


  signal axi_slave          : axi_stream_data_bus_t(tdata(2*numbits(max(DVB_N_LDPC)) - 0 downto 0));

  -- AXI input
  signal axi_master         : axi_stream_data_bus_t(tdata(DATA_WIDTH - 1 downto 0));
  -- AXI output
  signal m_data_valid       : boolean;
  signal s_data_valid       : boolean;


  signal axi_slave_offset   : std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);
  signal axi_slave_next     : std_logic;
  signal axi_slave_tuser    : std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);

begin

  -------------------
  -- Port mappings --
  -------------------
  -- AXI stream BFM for the config input

  dut : entity work.axi_plframe_header
    port map (
      -- Usual ports
      clk               => clk,
      rst               => rst,

      s_constellation_type => m_constellation,
      s_frame_type    => m_frame_type,
      s_code_rate    => m_code_rate,

      s_tready        => m_tready,
      s_tvalid        => m_tvalid,

      -- AXI output
      m_tready        => axi_slave_tready,
      m_tvalid        => axi_slave_tvalid,
      m_tdata         => axi_slave_tdata,
      m_tlast         => axi_slave_tlast);

  axi_slave.tdata <= axi_slave_next & axi_slave_tuser & axi_slave_offset;

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  clk <= not clk after CLK_PERIOD/2;

  test_runner_watchdog(runner, 2 ms);

  m_data_valid <= axi_master.tvalid = '1' and axi_master.tready = '1';
  s_data_valid <= axi_slave.tvalid = '1' and axi_slave.tready = '1';

  ---------------
  -- Processes --
  ---------------
  main : process -- {{
    constant self         : actor_t := new_actor("main");
    
    procedure walk(constant steps : natural) is -- {{ ----------------------------------
    begin
      if steps /= 0 then
        for step in 0 to steps - 1 loop
          wait until rising_edge(clk);
        end loop;
      end if;
    end procedure walk; -- }} ----------------------------------------------------------

    procedure run_test (  -- {{ -----------------------------------------------------------
      constant code_rate : code_rate_t;
      constant constellation : constellation_t) is
    begin
      m_tvalid <= '1';
      m_tready <= '1';

      m_constellation <= constellation;
      m_code_rate <= code_rate;
      m_frame_type <= fecframe_normal;

    end procedure run_test;

  begin
    test_runner_setup(runner, RUNNER_CFG);
    rst <= '1';
    m_tvalid <= '0';
    m_tready <= '0';
    walk(32);
    rst <= '0';
    walk(32);
    if run("back_to_back") then
      run_test(C3_5, mod_8psk);
    elsif run("slow_slave") then
      run_test(C3_5, mod_8psk);
    elsif run("slow_master,slow_slave") then
      run_test(C3_5, mod_8psk);
    end if;
    test_runner_cleanup(runner);
  end process; -- }}  

end plheader_tables_tb;
