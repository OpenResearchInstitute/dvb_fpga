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

-- use std.textio.all;

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
context fpga_cores_sim.sim_context;

use work.dvb_sim_utils_pkg.all;
use work.dvb_utils_pkg.all;

entity axi_plframe_header_tb is
  generic (
    RUNNER_CFG            : string;
    TEST_CFG              : string;
    NUMBER_OF_TEST_FRAMES : integer := 8);
end axi_plframe_header_tb;

architecture axi_plframe_header_tb of axi_plframe_header_tb is

  ---------------
  -- Constants --
  ---------------
  constant configs             : config_array_t := get_test_cfg(TEST_CFG);
  constant CLK_PERIOD          : time    := 5 ns;
  constant DATA_WIDTH          : integer := 8;
  constant CONFIG_INPUT_WIDTHS : fpga_cores.common_pkg.integer_vector_t := (
    0 => CONSTELLATION_WIDTH,
    1 => CODE_RATE_WIDTH);


  -------------
  -- Signals --
  -------------
  -- Usual ports
  signal clk             : std_logic := '1';
  signal rst             : std_logic;

  signal m_constellation : constellation_t;
  signal m_code_rate     : code_rate_t;

  signal axi_master      : axi_stream_data_bus_t(tdata(sum(CONFIG_INPUT_WIDTHS) - 1 downto 0));
  signal axi_slave       : axi_stream_data_bus_t(tdata(DATA_WIDTH - 1 downto 0));

  signal m_data_valid    : boolean;
  signal s_data_valid    : boolean;


begin

  -------------------
  -- Port mappings --
  -------------------
  -- AXI stream BFM for the config input
  axi_config_input_u : entity fpga_cores_sim.axi_stream_bfm
    generic map (
      NAME        => "axi_config_input_u",
      TDATA_WIDTH => sum(CONFIG_INPUT_WIDTHS))
    port map (
      -- Usual ports
      clk      => clk,
      rst      => rst,
      -- AXI stream output
      m_tready => axi_master.tready,
      m_tdata  => axi_master.tdata,
      m_tuser  => open,
      m_tkeep  => open,
      m_tid    => open,
      m_tvalid => axi_master.tvalid,
      m_tlast  => open);

  m_constellation <= decode(get_field(axi_master.tdata, 0, CONFIG_INPUT_WIDTHS));
  m_code_rate     <= decode(get_field(axi_master.tdata, 1, CONFIG_INPUT_WIDTHS));

  dut : entity work.axi_plframe_header
    port map (
      -- Usual ports
      clk               => clk,
      rst               => rst,

      cfg_constellation => m_constellation,
      cfg_code_rate     => m_code_rate,

      s_tready          => axi_master.tready,
      s_tvalid          => axi_master.tvalid,

      -- AXI output
      m_tready          => axi_slave.tready,
      m_tvalid          => axi_slave.tvalid,
      m_tdata           => axi_slave.tdata,
      m_tlast           => axi_slave.tlast);

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
    constant self   : actor_t          := new_actor("main");
    constant logger : logger_t         := get_logger("main");
    variable dut    : axi_stream_bfm_t := create_bfm("axi_config_input_u");
    -- variable file_checker : file_reader_t := new_file_reader(FILE_CHECKER_NAME);
    -- variable ldpc_table   : file_reader_t := new_file_reader("ldpc_table_u");
    
    procedure walk(constant steps : natural) is -- {{ ----------------------------------
    begin
      if steps /= 0 then
        for step in 0 to steps - 1 loop
          wait until rising_edge(clk);
        end loop;
      end if;
    end procedure walk; -- }} ----------------------------------------------------------

    procedure wait_for_completion is -- {{ ----------------------------------------------
      variable msg : msg_t;
    begin
      join(net, dut);
      -- wait_all_read(net, file_checker);
      -- wait_all_read(net, ldpc_table);
      walk(4);
      wait until rising_edge(clk) and axi_slave.tvalid = '0' for 1 ms;
      check_equal(axi_slave.tvalid, '0', "axi_slave.tvalid should be '0'");
      walk(1);
    end procedure wait_for_completion; -- }} --------------------------------------------

    procedure run_test ( -- {{ -----------------------------------------------------------
      constant config           : config_t;
      constant number_of_frames : in positive) is
      constant data_path        : string := strip(config.base_path, chars => (1 to 1 => nul));
      variable file_reader_msg  : msg_t;
      variable calc_ldpc_msg    : msg_t;

      -- GHDL doens't play well with anonymous vectors, so let's be explicit
      subtype bfm_data_t is std_logic_array_t(0 to 0)(CONSTELLATION_WIDTH + CODE_RATE_WIDTH - 1 downto 0);
      constant bfm_data : std_logic_vector := encode(config.code_rate) & encode(config.constellation);
    begin

      info("Running test with:");
      info(" - constellation  : " & constellation_t'image(config.constellation));
      info(" - frame_type     : " & frame_type_t'image(config.frame_type));
      info(" - code_rate      : " & code_rate_t'image(config.code_rate));
      info(" - data path      : " & data_path);

      for i in 0 to number_of_frames - 1 loop
        debug(logger, "Setting up frame #" & to_string(i));

        axi_bfm_write(net,
          bfm         => dut,
          data        => bfm_data_t'(0 => bfm_data),
          probability => 1.0,
          blocking    => False);

        -- read_file(net, ldpc_table, data_path & "/ldpc_table.bin", ratio);
      end loop;

    end procedure run_test; -- }} --------------------------------------------------------

  begin

    test_runner_setup(runner, RUNNER_CFG);
    show(display_handler, debug);
    hide(get_logger("file_reader_t(file_reader)"), display_handler, debug, True);
    hide(get_logger("file_reader_t(file_checker)"), display_handler, debug, True);
    hide(get_logger("file_reader_t(ldpc_table)"), display_handler, debug, True);


    while test_suite loop
      rst                <= '1';
      -- tready_probability <= 1.0;

      walk(32);
      rst <= '0';
      walk(32);

      set_timeout(runner, configs'length * 10 ms);

      if run("back_to_back") then
        -- tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("slow_master") then
        -- tready_probability <= 1.0;

        for i in configs'range loop
          for frame in 0 to NUMBER_OF_TEST_FRAMES - 1 loop
            run_test(configs(i), number_of_frames => 1);
            wait_for_completion;
          end loop;
        end loop;

      elsif run("slow_slave") then
        -- tready_probability <= 0.5;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("slow_master,slow_slave") then
        -- tready_probability <= 0.75;

        for i in configs'range loop
          for frame in 0 to NUMBER_OF_TEST_FRAMES - 1 loop
            run_test(configs(i), number_of_frames => 1);
            wait_for_completion;
          end loop;
        end loop;
      end if;

      wait_for_completion;
      -- check_false(has_message(input_cfg_p));
      -- check_equal(error_cnt, 0);

      walk(32);

    end loop;

    test_runner_cleanup(runner);
    wait;
  end process; -- }}

end axi_plframe_header_tb;
