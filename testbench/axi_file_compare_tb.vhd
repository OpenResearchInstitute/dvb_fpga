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
    runner_cfg : string;
    FILE_NAME  : string := "/tmp/compare.bin");
end axi_file_compare_tb;

architecture axi_file_compare_tb of axi_file_compare_tb is

  constant READER_NAME : string   := "dut";
  constant TEST_DEPTH  : positive := 256;
  constant DATA_WIDTH  : positive := 32;

  -- Generates data for when BYTES_ARE_BITS is set to False
  impure function generate_regular_data ( constant length : positive)
  return std_logic_vector_array is
    variable data       : std_logic_vector_array(0 to length - 1)(DATA_WIDTH - 1 downto 0);
    variable write_rand : RandomPType;
  begin
    write_rand.InitSeed(0);

    for word_cnt in 0 to length - 1 loop
      data(word_cnt) := write_rand.RandSlv(DATA_WIDTH);
    end loop;

    return data;

  end function generate_regular_data;

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
    DATA_WIDTH      => DATA_WIDTH,
    BYTES_ARE_BITS  => False)
  port map (
    -- Usual ports
    clk                => clk,
    rst                => rst,
    -- Config and status
    tdata_error_cnt    => tdata_error_cnt,
    tlast_error_cnt    => tlast_error_cnt,
    error_cnt          => error_cnt,
    tready_probability => tready_probability,
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
    procedure setup_file (constant filename : in string ) is
      variable msg    : msg_t := new_msg;
      variable reply  : boolean;
      variable reader : actor_t := find(READER_NAME);
      variable start  : time;
    begin
      push_string(msg, filename);
      send(net, reader, msg);
    end procedure setup_file;

    ------------------------------------------------------------------------------------
    procedure test_no_errors_detected is
      variable rand   : RandomPType;
    begin
      setup_file(FILE_NAME);

      rand.InitSeed(0);
      for i in 0 to TEST_DEPTH - 1 loop
        write_word(rand.RandSlv(DATA_WIDTH), is_last => i = TEST_DEPTH - 1);
      end loop;

      walk(1);

      check_equal(tdata_error_cnt, 0);
      check_equal(tlast_error_cnt, 0);
      check_equal(error_cnt, 0);

    end procedure test_no_errors_detected;

    ------------------------------------------------------------------------------------
    procedure test_tlast_error is
      variable rand : RandomPType;
    begin
      setup_file(FILE_NAME);

      rand.InitSeed(0);
      -- Tlast errors should be detected in any position
      for i in 0 to TEST_DEPTH - 1 loop
        write_word(rand.RandSlv(DATA_WIDTH), is_last => i = 0);
      end loop;

      walk(4);

      check_equal(tdata_error_cnt, 0);
      check_equal(tlast_error_cnt, 2);
      check_equal(error_cnt, 2);

    end procedure test_tlast_error;

    ------------------------------------------------------------------------------------
    procedure test_tdata_error is
      variable rand : RandomPType;
      variable data : std_logic_vector(DATA_WIDTH - 1 downto 0);
    begin
      setup_file(FILE_NAME);

      rand.InitSeed(0);
      -- Tlast errors should be detected in any position
      for i in 0 to TEST_DEPTH - 1 loop
        -- Need to waste a sample, otherwise everything will be offset
        data := rand.RandSlv(DATA_WIDTH);
        if i = TEST_DEPTH / 2 then
          data := (others => 'U');
        end if;
        write_word(data, is_last => i = TEST_DEPTH - 1);
      end loop;

      walk(1);

      check_equal(tdata_error_cnt, 1);
      check_equal(tlast_error_cnt, 0);
      check_equal(error_cnt, 1);

    end procedure test_tdata_error;

    ------------------------------------------------------------------------------------
    procedure test_auto_reset is
      variable rand : RandomPType;
      variable data : std_logic_vector(DATA_WIDTH - 1 downto 0);
    begin
      -- Setup the AXI reader first to avoid glitches on m_tvalid
      for iter in 0 to 9 loop
        setup_file(FILE_NAME);
      end loop;

      for iter in 0 to 9 loop
        rand.InitSeed(0);
        -- Insert a couple of tlast errors so that we ensure checking didn't stop after
        -- the first frame
        for i in 0 to TEST_DEPTH - 1 loop
          if iter = 7 then
            write_word(rand.RandSlv(DATA_WIDTH), is_last => false);
          else
            write_word(rand.RandSlv(DATA_WIDTH), is_last => i = TEST_DEPTH - 1);
          end if;
        end loop;

      end loop;

      walk(1);

      check_equal(tdata_error_cnt, 0);
      check_equal(tlast_error_cnt, 1);
      check_equal(error_cnt, 1);

    end procedure test_auto_reset ;

  begin

    write_binary_file(FILE_NAME, generate_regular_data(TEST_DEPTH));

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
        test_tdata_error;

      elsif run("test_tdata_error_slow_rate") then
        tvalid_probability <= 0.8;
        test_tdata_error;

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

