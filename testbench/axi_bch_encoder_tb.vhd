--
-- DVB FPGA
--
-- Copyright 2019 by Andre Souto (suoto)
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

use work.bch_encoder_pkg.all;

entity axi_bch_encoder_tb is
  generic (
    runner_cfg : string);
end axi_bch_encoder_tb;

architecture axi_bch_encoder_tb of axi_bch_encoder_tb is

    -----------
    -- Types --
    -----------
    type std_logic_vector_array is array (natural range <>) of std_logic_vector;

    ---------------
    -- Constants --
    ---------------
    constant PATH_TO_TEST_FILES : string := "/home/souto/phase4ground/bch_tests/";
    constant CLK_PERIOD         : time := 5 ns;
    constant TDATA_WIDTH        : integer := 8;
    constant ERROR_CNT_WIDTH    : integer := 8;

    -------------
    -- Signals --
    -------------
    -- Usual ports
    signal clk                : std_logic := '1';
    signal rst                : std_logic;

    signal cfg_bch_code       : std_logic_vector(1 downto 0);

    -- AXI input
    signal m_tready           : std_logic;
    signal m_tvalid           : std_logic;
    signal m_tdata            : std_logic_vector(TDATA_WIDTH - 1 downto 0);
    signal m_tlast            : std_logic;

    -- AXI output
    signal s_tvalid           : std_logic;
    signal s_tdata            : std_logic_vector(TDATA_WIDTH - 1 downto 0);
    signal s_tlast            : std_logic;
    signal s_tready           : std_logic;

    signal tvalid_probability : real := 1.0;
    signal tready_probability : real := 1.0;

    signal m_data_valid       : boolean;
    signal s_data_valid       : boolean;

    signal tdata_error_cnt    : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
    signal tlast_error_cnt    : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
    signal error_cnt          : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);

    --
    signal cfg_input_file     : string(1 to 15 + PATH_TO_TEST_FILES'length); -- := "input_16008.bin";
    signal cfg_reference_file : string(1 to 19 + PATH_TO_TEST_FILES'length); -- := "reference_16008.bin";
    signal read_start         : std_logic;
    signal read_completed     : std_logic;
    signal compare_start      : std_logic;

begin

    -------------------
    -- Port mappings --
    -------------------
    dut : entity work.axi_bch_encoder
        generic map (
            TDATA_WIDTH => TDATA_WIDTH
        )
        port map (
            -- Usual ports
            clk          => clk,
            rst          => rst,

            cfg_bch_code => cfg_bch_code,

            -- AXI input
            s_tvalid     => m_tvalid,
            s_tdata      => m_tdata,
            s_tlast      => m_tlast,
            s_tready     => m_tready,

            -- AXI output
            m_tready     => s_tready,
            m_tvalid     => s_tvalid,
            m_tlast      => s_tlast,
            m_tdata      => s_tdata);


  -- AXI file read
  axi_file_reader_u : entity work.axi_file_reader
    generic map (
      DATA_WIDTH     => TDATA_WIDTH,
      BYTES_ARE_BITS => True)
    port map (
      -- Usual ports
      clk                => clk,
      rst                => rst,
      -- Config and status
      file_name          => cfg_input_file,
      start              => read_start,
      completed          => read_completed,
      tvalid_probability => tvalid_probability,

      -- Data output
      m_tready           => m_tready,
      m_tdata            => m_tdata,
      m_tvalid           => m_tvalid,
      m_tlast            => m_tlast);

  axi_file_compare_u : entity work.axi_file_compare
    generic map (
      ERROR_CNT_WIDTH => ERROR_CNT_WIDTH,
      REPORT_SEVERITY => Warning,
      DATA_WIDTH      => TDATA_WIDTH,
      BYTES_ARE_BITS  => True)
    port map (
      -- Usual ports
      clk                => clk,
      rst                => rst,
      -- Config and status
      start              => compare_start,
      file_name          => cfg_reference_file,
      tdata_error_cnt    => tdata_error_cnt,
      tlast_error_cnt    => tlast_error_cnt,
      error_cnt          => error_cnt,
      tready_probability => tready_probability,

      -- Data input
      s_tready           => s_tready,
      s_tdata            => s_tdata,
      s_tvalid           => s_tvalid,
      s_tlast            => s_tlast);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  clk <= not clk after CLK_PERIOD/2;

  test_runner_watchdog(runner, 3 ms);

  m_data_valid <= m_tvalid = '1' and m_tready = '1';
  s_data_valid <= s_tvalid = '1' and s_tready = '1';

  ---------------
  -- Processes --
  ---------------
  main : process
    constant main             : actor_t := new_actor("main");
    constant file_reader      : actor_t := find("file_reader");
    constant file_checker     : actor_t := find("file_checker");
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
      constant bch_code         : in integer;
      constant input_file       : in string;
      constant reference_file   : in string;
      constant number_of_frames : in positive) is
      variable file_reader_msg  : msg_t;
      variable file_checker_msg : msg_t;
    begin

      for i in 0 to number_of_frames - 1 loop
        file_reader_msg := new_msg;
        file_checker_msg := new_msg;

        push_string(file_reader_msg, input_file);
        push_integer(file_reader_msg, bch_code);
        push_string(file_checker_msg, reference_file);


        send(net, file_reader, file_reader_msg);
        send(net, file_checker, file_checker_msg);
      end loop;

    end procedure run_test;

    procedure wait_for_transfers is
      variable msg : msg_t;
    begin
      while has_message(file_reader) loop
        walk(1);
      end loop;

      warning("File reader finished");

      while has_message(file_checker) loop
        walk(1);
      end loop;

      warning("File checker finished");

      receive(net, main, msg);
      info("got an ack...");
      receive(net, main, msg);
      info("Got all acks");

    end procedure wait_for_transfers;

  begin

    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      rst <= '1';
      walk(16);
      rst <= '0';
      walk(16);

      tvalid_probability <= 1.0;
      tready_probability <= 1.0;

      if run("run_192_16008_back_to_back") then
        tvalid_probability <= 1.0;
        tready_probability <= 1.0;
        run_test(BCH_POLY_12, "input_16008.bin", "reference_16008.bin", 4);
        wait_for_transfers;

      elsif run("run_192_16008_slow_master") then
        tvalid_probability <= 0.5;
        tready_probability <= 1.0;
        run_test(BCH_POLY_12, "input_16008.bin", "reference_16008.bin", 4);
        wait_for_transfers;
      elsif run("run_192_16008_slow_slave") then
        tvalid_probability <= 1.0;
        tready_probability <= 0.5;
        run_test(BCH_POLY_12, "input_16008.bin", "reference_16008.bin", 4);
        wait_for_transfers;
      elsif run("run_192_16008_slow_overall") then
        tvalid_probability <= 0.75;
        tready_probability <= 0.75;
        run_test(BCH_POLY_12, "input_16008.bin", "reference_16008.bin", 4);
        wait_for_transfers;

      -- Test other encodings
      elsif run("run_160_53840_back_to_back") then
        tvalid_probability <= 1.0;
        tready_probability <= 1.0;
        run_test(BCH_POLY_10, "input_53840.bin", "reference_53840.bin", 4);
        wait_for_transfers;

      -- Test other encodings
      elsif run("run_128_58192_back_to_back") then
        tvalid_probability <= 1.0;
        tready_probability <= 1.0;
        run_test(BCH_POLY_8, "input_58192.bin", "reference_58192.bin", 4);
        wait_for_transfers;

      elsif run("test_switching_encodings") then
        tvalid_probability <= 1.0;
        tready_probability <= 1.0;
        run_test(BCH_POLY_12, "input_16008.bin", "reference_16008.bin", 1);
        run_test(BCH_POLY_10, "input_53840.bin", "reference_53840.bin", 1);
        run_test(BCH_POLY_8, "input_58192.bin", "reference_58192.bin", 1);
        run_test(BCH_POLY_12, "input_16008.bin", "reference_16008.bin", 1);
        run_test(BCH_POLY_10, "input_53840.bin", "reference_53840.bin", 1);
        run_test(BCH_POLY_8, "input_58192.bin", "reference_58192.bin", 1);

        wait_for_transfers;
      end if;

      walk(1);

      check_false(has_message(file_reader));
      check_false(has_message(file_checker));

      check_equal(error_cnt, 0);

      walk(4);

    end loop;

    test_runner_cleanup(runner);
    wait;
  end process;

  file_reader_cfg_p : process
    constant main        : actor_t := find("main");
    constant file_reader : actor_t := new_actor("file_reader");
    variable msg         : msg_t;
  begin
    read_start     <= '0';
    receive(net, file_reader, msg);
    -- Keep the config stuff active for a single cycle to make sure blocks use the correct
    -- values
    cfg_input_file <= PATH_TO_TEST_FILES & pop_string(msg);
    cfg_bch_code   <= std_logic_vector(to_unsigned(pop_integer(msg), 2));
    read_start     <= '1';
    wait until m_data_valid and m_tlast = '0' and rising_edge(clk);
    wait until m_data_valid and m_tlast = '0' and rising_edge(clk);
    read_start     <= '0';
    cfg_input_file <= (others => ' ');
    cfg_bch_code   <= (others => 'U');

    wait until m_data_valid and m_tlast = '1';

    if not has_message(file_reader) then
      info("Sending ack");
      msg := new_msg;
      push_boolean(msg, True);
      send(net, main, msg);
    end if;
    check_equal(error_cnt, 0);
  end process;

  file_checker_cfg_p : process
    constant main         : actor_t := find("main");
    constant file_checker : actor_t := new_actor("file_checker");
    variable msg          : msg_t;
  begin
    compare_start      <= '0';
    receive(net, file_checker, msg);
    -- Keep the config stuff active for a single cycle to make sure blocks use the correct
    -- values
    cfg_reference_file <= PATH_TO_TEST_FILES & pop_string(msg);
    compare_start      <= '1';
    wait until s_data_valid and s_tlast = '0' and rising_edge(clk);

    cfg_reference_file <= (others => ' ');
    compare_start      <= '0';

    wait until s_data_valid and s_tlast = '1' and rising_edge(clk);

    if not has_message(file_checker) then
      info("Sending ack");
      msg := new_msg;
      push_boolean(msg, True);
      send(net, main, msg);
    end if;
    check_equal(error_cnt, 0);
  end process;

end axi_bch_encoder_tb;
