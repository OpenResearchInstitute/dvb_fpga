--
-- DVB FPGA
--
-- Copyright 2019 by Suoto <andre820@gmail.com>
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
use fpga_cores.common_pkg.all;

library fpga_cores_sim;
use fpga_cores_sim.testbench_utils_pkg.all;
use fpga_cores_sim.file_utils_pkg.all;

use work.dvb_utils_pkg.all;
use work.dvb_sim_utils_pkg.all;

entity axi_bch_encoder_tb is
  generic (
    RUNNER_CFG            : string;
    TEST_CFG              : string;
    NUMBER_OF_TEST_FRAMES : integer := 8);
end axi_bch_encoder_tb;

architecture axi_bch_encoder_tb of axi_bch_encoder_tb is

  ---------------
  -- Constants --
  ---------------
  constant configs           : config_array_t := get_test_cfg(TEST_CFG);

  constant CLK_PERIOD        : time := 5 ns;
  constant DATA_WIDTH        : integer := 8;
  constant ERROR_CNT_WIDTH   : integer := 8;

  -------------
  -- Signals --
  -------------
  -- Usual ports
  signal clk                : std_logic := '1';
  signal rst                : std_logic;

  signal cfg_frame_type     : frame_type_t;
  signal cfg_code_rate      : code_rate_t;

  -- AXI input
  signal m_tready           : std_logic;
  signal m_tvalid           : std_logic;
  signal m_tdata            : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal m_tlast            : std_logic;

  -- AXI output
  signal s_tvalid           : std_logic;
  signal s_tdata            : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal s_tlast            : std_logic;
  signal s_tready           : std_logic;

  signal tvalid_probability : real range 0.0 to 1.0 := 1.0;
  signal tready_probability : real range 0.0 to 1.0 := 1.0;

  signal m_data_valid       : boolean;
  signal s_data_valid       : boolean;

  signal expected_tdata     : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal expected_tlast     : std_logic;
  signal tdata_error_cnt    : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
  signal tlast_error_cnt    : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
  signal error_cnt          : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);

begin

  -------------------
  -- Port mappings --
  -------------------
  dut : entity work.axi_bch_encoder
    generic map ( DATA_WIDTH => DATA_WIDTH)
    port map (
      -- Usual ports
      clk            => clk,
      rst            => rst,

      cfg_frame_type => cfg_frame_type,
      cfg_code_rate  => cfg_code_rate,

      -- AXI input
      s_tvalid       => m_tvalid,
      s_tdata        => m_tdata,
      s_tlast        => m_tlast,
      s_tready       => m_tready,

      -- AXI output
      m_tready       => s_tready,
      m_tvalid       => s_tvalid,
      m_tlast        => s_tlast,
      m_tdata        => s_tdata);


  axi_file_reader_block : block
    constant CONFIG_INPUT_WIDTHS: fpga_cores.common_pkg.integer_vector_t := (
      0 => FRAME_TYPE_WIDTH,
      1 => CONSTELLATION_WIDTH,
      2 => CODE_RATE_WIDTH);

    signal m_tid : std_logic_vector(sum(CONFIG_INPUT_WIDTHS) - 1 downto 0);
  begin
    axi_file_reader_u : entity fpga_cores_sim.axi_file_reader
      generic map (
        READER_NAME => "axi_file_reader_u",
        DATA_WIDTH  => DATA_WIDTH,
        TID_WIDTH   => sum(CONFIG_INPUT_WIDTHS))
      port map (
        -- Usual ports
        clk                => clk,
        rst                => rst,
        -- Config and status
        completed          => open,
        tvalid_probability => tvalid_probability,

        -- Data output
        m_tready           => m_tready,
        m_tdata            => m_tdata,
        m_tid              => m_tid,
        m_tvalid           => m_tvalid,
        m_tlast            => m_tlast);

    -- Decode the TID field with the actual config types
    cfg_frame_type    <= decode(get_field(m_tid, 0, CONFIG_INPUT_WIDTHS));
    cfg_code_rate     <= decode(get_field(m_tid, 2, CONFIG_INPUT_WIDTHS));
  end block axi_file_reader_block;

  axi_file_compare_u : entity fpga_cores_sim.axi_file_compare
    generic map (
      READER_NAME     => "axi_file_compare_u",
      ERROR_CNT_WIDTH => ERROR_CNT_WIDTH,
      -- REPORT_SEVERITY => Warning,
      DATA_WIDTH      => DATA_WIDTH)
    port map (
      -- Usual ports
      clk                => clk,
      rst                => rst,
      -- Config and status
      tdata_error_cnt    => tdata_error_cnt,
      tlast_error_cnt    => tlast_error_cnt,
      error_cnt          => error_cnt,
      tready_probability => tready_probability,
      -- Debug stuff
      expected_tdata     => expected_tdata,
      expected_tlast     => expected_tlast,
      -- Data input
      s_tready           => s_tready,
      s_tdata            => s_tdata,
      s_tvalid           => s_tvalid,
      s_tlast            => s_tlast);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  clk <= not clk after CLK_PERIOD/2;

  m_data_valid <= m_tvalid = '1' and m_tready = '1';
  s_data_valid <= s_tvalid = '1' and s_tready = '1';

  ---------------
  -- Processes --
  ---------------
  main : process
    constant self         : actor_t       := new_actor("main");
    variable file_reader  : file_reader_t := new_file_reader("axi_file_reader_u");
    variable file_checker : file_reader_t := new_file_reader("axi_file_compare_u");
    ------------------------------------------------------------------------------------
    procedure walk(constant steps : natural) is
    begin
      if steps /= 0 then
        for step in 0 to steps - 1 loop
          wait until rising_edge(clk);
        end loop;
      end if;
    end procedure walk;

    ------------------------------------------------------------------------------------
    procedure run_test (
      constant config           : config_t;
      constant number_of_frames : in positive := NUMBER_OF_TEST_FRAMES) is
      constant data_path        : string := strip(config.base_path, chars => (1 to 1 => nul));
    begin

      info("Running test with:");
      info(" - constellation  : " & constellation_t'image(config.constellation));
      info(" - frame_type     : " & frame_type_t'image(config.frame_type));
      info(" - code_rate      : " & code_rate_t'image(config.code_rate));
      info(" - data path      : " & data_path);

      for i in 0 to number_of_frames - 1 loop
        read_file(net,
          file_reader => file_reader,
          filename    => data_path & "/bch_encoder_input.bin",
          ratio       => "1:8",
          tid         => encode(config.code_rate) & encode(config.constellation) & encode(config.frame_type));

        read_file(net,
          file_reader => file_checker,
          filename    => data_path & "/ldpc_encoder_input.bin",
          ratio       => "1:8");

      end loop;

    end procedure run_test;

    ------------------------------------------------------------------------------------
    procedure wait_for_transfers is
      variable msg : msg_t;
    begin
      info("Waiting for all files to be read");
      wait_all_read(net, file_reader);
      wait_all_read(net, file_checker);
      info("File reader and checker completed reading");

      wait until rising_edge(clk) and s_tvalid = '0' for 1 ms;

      walk(1);
    end procedure wait_for_transfers;
    ------------------------------------------------------------------------------------

  begin

    test_runner_setup(runner, RUNNER_CFG);
    show(display_handler, debug);

    while test_suite loop
      rst <= '1';
      walk(4);
      rst <= '0';
      walk(4);

      tvalid_probability <= 1.0;
      tready_probability <= 1.0;

      set_timeout(runner, configs'length * NUMBER_OF_TEST_FRAMES * 500 us);

      if run("back_to_back") then
        tvalid_probability <= 1.0;
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i));
        end loop;

      elsif run("slow_master") then
        tvalid_probability <= 0.5;
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i));
        end loop;

      elsif run("slow_slave") then
        tvalid_probability <= 0.5;
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i));
        end loop;

      elsif run("both_slow") then
        tvalid_probability <= 0.75;
        tready_probability <= 0.75;

        for i in configs'range loop
          run_test(configs(i));
        end loop;

      end if;

      wait_for_transfers;
      check_equal(s_tvalid, '0', "s_tvalid should be '0'");
      check_equal(error_cnt, 0);

      walk(32);

    end loop;

    check_equal(error_cnt, 0, sformat("Expected 0 errors but got %d", fo(error_cnt)));


    test_runner_cleanup(runner);
    wait;
  end process;

end axi_bch_encoder_tb;
