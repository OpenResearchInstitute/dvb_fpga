--
-- lib IP
--
-- Copyright 2019 by Andre Souto (suoto)
--
-- This file is part of lib IP.
-- 
-- lib IP is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- lib IP is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with lib IP.  If not, see <http://www.gnu.org/licenses/>.

-- vunit: run_all_in_same_sim

use std.textio.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library vunit_lib;
  context vunit_lib.vunit_context;

library osvvm;
  use osvvm.RandomPkg.all;

library str_format;
  use str_format.str_format_pkg.all;

library lib;
  use lib.bch_encoder_pkg.all;

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
    constant CLK_PERIOD      : time := 5 ns;
    constant TDATA_WIDTH     : integer := 8;
    constant ERROR_CNT_WIDTH : integer := 8;

    -------------
    -- Signals --
    -------------
    -- Usual ports
    signal clk     : std_logic := '1';
    signal rst     : std_logic;

    signal cfg_bch_code : std_logic_vector(1 downto 0);

    -- AXI input
    signal m_tready : std_logic;
    signal m_tvalid : std_logic;
    signal m_tdata  : std_logic_vector(TDATA_WIDTH - 1 downto 0);
    signal m_tlast  : std_logic;

    -- AXI output
    signal s_tvalid : std_logic;
    signal s_tdata  : std_logic_vector(TDATA_WIDTH - 1 downto 0);
    signal s_tlast  : std_logic;
    signal s_tready : std_logic;

    signal tvalid_probability  : real := 1.0;
    signal tready_probability  : real := 1.0;

    signal m_data_valid        : boolean;
    signal s_data_valid        : boolean;

    signal tdata_error_cnt    : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
    signal tlast_error_cnt    : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
    signal error_cnt          : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);


    -- shared variable read_filename : line;
    constant PATH_TO_TEST_FILES : string := "/home/souto/phase4ground/bch_tests/";
    signal input_file      : string(1 to 15) := "input_16008.bin";
    signal comparison_file : string(1 to 19) := "reference_16008.bin";
    signal read_start      : std_logic;
    signal read_completed  : std_logic;

begin

    -------------------
    -- Port mappings --
    -------------------
    dut : entity lib.axi_bch_encoder
        generic map (
            TDATA_WIDTH => TDATA_WIDTH
        )
        port map (
            -- Usual ports
            clk     => clk,
            rst     => rst,

            cfg_bch_code => cfg_bch_code,

            -- AXI input
            s_tvalid => m_tvalid,
            s_tdata  => m_tdata,
            s_tlast  => m_tlast,
            s_tready => m_tready,

            -- AXI output
            m_tready => s_tready,
            m_tvalid => s_tvalid,
            m_tlast  => s_tlast,
            m_tdata  => s_tdata);


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
      file_name          => PATH_TO_TEST_FILES & input_file,
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
      REPORT_SEVERITY => Error,
      DATA_WIDTH      => TDATA_WIDTH,
      BYTES_ARE_BITS  => True)
    port map (
      -- Usual ports
      clk                => clk,
      rst                => rst,
      -- Config and status
      file_name          => PATH_TO_TEST_FILES & comparison_file,
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
    procedure run_test ( constant number_of_frames : in positive := 1) is
    begin
      cfg_bch_code    <= std_logic_vector(to_unsigned(BCH_POLY_12, 2));
      input_file      <= "input_16008.bin";
      comparison_file <= "reference_16008.bin";

      for i in 0 to number_of_frames - 1 loop
        read_start      <= '1';
        wait until m_data_valid and m_tlast = '1' and rising_edge(clk);
        read_start      <= '0';
      end loop;

      wait until s_data_valid and s_tlast = '1' and rising_edge(clk);

      walk(1);

      check_equal(error_cnt, 0);

    end procedure run_test;

  begin

    read_start <= '0';

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
        run_test(4);
      elsif run("run_192_16008_slow_master") then
        tvalid_probability <= 0.5;
        tready_probability <= 1.0;
        run_test(4);
      elsif run("run_192_16008_slow_slave") then
        tvalid_probability <= 1.0;
        tready_probability <= 0.5;
        run_test(4);
      elsif run("run_192_16008_slow_overall") then
        tvalid_probability <= 0.75;
        tready_probability <= 0.75;
        run_test(4);
      end if;

      walk(16);

    end loop;

    test_runner_cleanup(runner);
    wait;
  end process;

end axi_bch_encoder_tb;
