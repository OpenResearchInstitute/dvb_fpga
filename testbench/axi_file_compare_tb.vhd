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

---------------
-- Libraries --
---------------
use std.textio.all;

library	ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library vunit_lib;
  context vunit_lib.vunit_context;
  context vunit_lib.com_context;

library osvvm;
  use osvvm.RandomPkg.all;

library str_format;
  use str_format.str_format_pkg.all;

use work.file_utils_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_file_compare_tb is
  generic (
    runner_cfg              : string;
    input_file              : string;
    reference_file          : string;
    tdata_single_error_file : string;
    tdata_two_errors_file   : string);
end axi_file_compare_tb;

architecture axi_file_compare_tb of axi_file_compare_tb is

  constant READER_NAME : string   := "dut";
  constant DATA_WIDTH  : positive := 32;

  ---------------
  -- Constants --
  ---------------
  constant CLK_PERIOD : time := 5 ns;
  constant ERROR_CNT_WIDTH : natural := 8;

  -------------
  -- Signals --
  -------------
  -- Usual ports
  signal clk                : std_logic := '0';
  signal rst                : std_logic;
  -- Config and status
  signal tdata_error_cnt    : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
  signal tlast_error_cnt    : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
  signal error_cnt          : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
  signal tvalid_probability : real range 0.0 to 1.0 := 1.0;
  signal tready_probability : real range 0.0 to 1.0 := 1.0;
  -- Data input
  signal m_tready           : std_logic;
  signal m_tdata            : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal m_tvalid           : std_logic;
  signal m_tlast            : std_logic;

  signal expected_tdata     : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal expected_tlast     : std_logic;

  signal m_tvalid_wr        : std_logic := '0';
  signal m_tvalid_en        : std_logic := '0';

  signal axi_data_valid     : boolean;


begin

  -------------------
  -- Port mappings --
  -------------------
  dut : entity work.axi_file_compare
  generic map (
    READER_NAME     => READER_NAME,
    ERROR_CNT_WIDTH => ERROR_CNT_WIDTH,
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
    s_tready           => m_tready,
    s_tdata            => m_tdata,
    s_tvalid           => m_tvalid,
    s_tlast            => m_tlast);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  clk <= not clk after CLK_PERIOD/2;
  test_runner_watchdog(runner, 2 ms);

  m_tvalid       <= m_tvalid_wr and m_tvalid_en;
  axi_data_valid <= m_tvalid = '1' and m_tready = '1';

  ---------------
  -- Processes --
  ---------------
  main : process
    variable reader : file_reader_t := new_file_reader(READER_NAME);

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
    -- Writes a single word to the AXI slave
    procedure write_word (
        constant data     : std_logic_vector(DATA_WIDTH - 1 downto 0);
        constant is_last  : boolean := False) is
    begin
        m_tvalid_wr <= '1';
        m_tdata     <= data;
        if is_last then
            m_tlast <= '1';
        else
            m_tlast  <= '0';
        end if;

        wait until m_tvalid = '1' and m_tready = '1' and rising_edge(clk);

        m_tlast     <= '0';
        m_tvalid_wr <= '0';
        m_tdata     <= (others => 'U');
    end procedure write_word;

    ------------------------------------------------------------------------------------
    procedure write_data_from_file (
      constant filename    : string;
      constant tlast_every : integer := -1) is
      file file_handler    : text;
      variable L           : line;
      variable data        : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
      variable cnt         : natural := 0;
    begin
        file_open(file_handler, filename, read_mode);

        while not endfile(file_handler) loop
          readline(file_handler, L);
          hread(L, data);

          if tlast_every = -1 then
            write_word(data, is_last => endfile(file_handler));
          else
            write_word(data, is_last => cnt = tlast_every);
          end if;

          cnt := cnt + 1;

        end loop;

        file_close(file_handler);

    end;

    ------------------------------------------------------------------------------------
    procedure test_no_errors_detected is
    begin
      enqueue_file(net, reader, input_file);
      write_data_from_file(reference_file);
      wait_all_read(net, reader);

      walk(1);

      check_equal(tdata_error_cnt, 0);
      check_equal(tlast_error_cnt, 0);
      check_equal(error_cnt, 0);

    end procedure test_no_errors_detected;

    ------------------------------------------------------------------------------------
    procedure test_tlast_error is
    begin
      info("Starting tlast error");
      enqueue_file(net, reader, input_file);
      info("Enqueued file");
      write_data_from_file(reference_file, tlast_every => 1e9);
      info("Wrote frame");
      wait_all_read(net, reader);
      info("Got reply");

      walk(1);

      check_equal(tdata_error_cnt, 0);
      check_equal(tlast_error_cnt, 1);
      check_equal(error_cnt, 1);

    end procedure test_tlast_error;

    ------------------------------------------------------------------------------------
    procedure test_tdata_single_error is
    begin
      enqueue_file(net, reader, input_file);
      write_data_from_file(tdata_single_error_file);
      wait_all_read(net, reader);

      walk(1);

      check_equal(tdata_error_cnt, 1);
      check_equal(tlast_error_cnt, 0);
      check_equal(error_cnt, 1);

    end procedure test_tdata_single_error;

    ------------------------------------------------------------------------------------
    procedure test_tdata_2_errors is
      constant tdata_errors : integer := to_integer(unsigned(tdata_error_cnt));
    begin
      enqueue_file(net, reader, input_file);
      write_data_from_file(tdata_two_errors_file);
      wait_all_read(net, reader);

      walk(1);

      check_equal(tdata_error_cnt, tdata_errors + 2);
      check_equal(tlast_error_cnt, 0);
      check_equal(error_cnt, tdata_errors + 2);

    end procedure test_tdata_2_errors;

    ------------------------------------------------------------------------------------
    procedure test_auto_reset is
      variable rand : RandomPType;
      variable data : std_logic_vector(DATA_WIDTH - 1 downto 0);
    begin
      -- Setup the AXI reader first to avoid glitches on m_tvalid
      for iter in 0 to 9 loop
        enqueue_file(net, reader, input_file);
      end loop;

      for iter in 0 to 9 loop
        write_data_from_file(reference_file);
      end loop;

      walk(1);

      check_equal(tdata_error_cnt, 0);
      check_equal(tlast_error_cnt, 0);
      check_equal(error_cnt, 0);

      wait_all_read(net, reader);

    end procedure test_auto_reset ;

  begin

    test_runner_setup(runner, runner_cfg);
    show_all(display_handler);

    while test_suite loop
      tready_probability <= 1.0;

      rst <= '1';
      walk(4);
      rst <= '0';
      walk(4);

      tvalid_probability <= 1.0;

      if run("test_no_errors_detected_back_to_back") then
        tvalid_probability <= 1.0;
        test_no_errors_detected;

      elsif run("test_no_errors_detected_slow_write") then
        tvalid_probability <= 0.5;
        test_no_errors_detected;

      elsif run("test_tlast_error_back_to_back") then
        tvalid_probability <= 1.0;
        test_tlast_error;

      elsif run("test_tlast_error_slow_write") then
        tvalid_probability <= 0.4;
        test_tlast_error;

      elsif run("test_tdata_error_back_to_back") then
        tvalid_probability <= 1.0;
        test_tdata_single_error;
        test_tdata_2_errors;

      elsif run("test_tdata_error_slow_rate") then
        tvalid_probability <= 0.8;
        test_tdata_single_error;
        test_tdata_2_errors;

      elsif run("test_auto_reset") then
        tvalid_probability <= 1.0;
        test_auto_reset;

      end if;

      walk(4);

    end loop;

    test_runner_cleanup(runner);
    wait;

  end process main;

  tvalid_rnd_gen : process
    variable tvalid_rand : RandomPType;
  begin
    m_tvalid_en <= '0';
    wait until rst = '0';
    while True loop
      wait until rising_edge(clk);
      m_tvalid_en <= '0';
      if tvalid_rand.RandReal(1.0) < tvalid_probability then
        m_tvalid_en <= '1';
      end if;

    end loop;
  end process;

end axi_file_compare_tb;

