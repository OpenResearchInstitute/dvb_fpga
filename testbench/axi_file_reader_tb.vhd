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
entity axi_file_reader_tb is
  generic (
    runner_cfg : string;
    DATA_WIDTH : integer;
    FILE_NAME  : string);
end axi_file_reader_tb;

architecture axi_file_reader_tb of axi_file_reader_tb is

  constant DATA_RATIO : ratio_t := parse_data_ratio("1:8", DATA_WIDTH);

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

  -- Generates data for when BYTES_ARE_BITS is set to True
  impure function generate_unpacked_data (constant length : positive)
  return std_logic_vector_array is
    constant NUMBER_OF_WORDS : integer := length * DATA_RATIO.first / DATA_RATIO.second;
    variable data            : std_logic_vector_array(0 to NUMBER_OF_WORDS - 1)(7 downto 0);
    variable word            : std_logic_vector(DATA_WIDTH - 1 downto 0);
    variable byte            : std_logic_vector(7 downto 0);
    variable index           : natural := 0;
    variable write_rand      : RandomPType;
  begin
    info(sformat("Generating vector with %d x %d = %d",
                 fo(data'length), fo(data(0)'length), fo(data'length * data(0)'length)));

    write_rand.InitSeed(0);

    for word_cnt in 0 to length - 1 loop
      debug(sformat("word_cnt=%d", fo(word_cnt)));
      word := write_rand.RandSlv(DATA_WIDTH);

      -- Data is little endian, write MSB first
      for byte_index in (DATA_WIDTH + 7) / 8 - 1 downto 0 loop
        byte := word(8*(byte_index + 1) - 1 downto 8*byte_index);

        for i in 7 downto 0 loop
          -- When BYTES_ARE_BITS is set to True, each bit on a word becomes a byte
          if byte(i) = '1' then
            data(index) := x"01";
          else
            data(index) := x"00";
          end if;
          index := index + 1;
        end loop;

      end loop;
    end loop;

    return data;
  end function generate_unpacked_data;

  procedure create_file (constant length : positive) is
  begin
    -- if BYTES_ARE_BITS then
    --   write_binary_file(FILE_NAME, generate_unpacked_data(length));
    -- else
      write_binary_file(FILE_NAME, generate_regular_data(length));
    -- end if;
  end procedure create_file;

  ---------------
  -- Constants --
  ---------------
  constant READER_NAME : string := "dut";
  constant CLK_PERIOD  : time := 5 ns;

  -------------
  -- Signals --
  -------------
  signal clk                : std_logic := '0';
  signal rst                : std_logic;
  signal completed          : std_logic;
  signal s_tready           : std_logic;
  signal s_tdata            : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal s_tvalid           : std_logic;
  signal s_tlast            : std_logic;

  signal tvalid_probability : real range 0.0 to 1.0 := 1.0;
  signal tready_probability : real range 0.0 to 1.0 := 1.0;

begin

  -------------------
  -- Port mappings --
  -------------------
  dut : entity work.axi_file_reader
    generic map (
      READER_NAME    => READER_NAME,
      DATA_WIDTH     => DATA_WIDTH)
    port map (
      -- Usual ports
      clk                => clk,
      rst                => rst,
      -- Config and status
      completed          => completed,
      tvalid_probability => tvalid_probability,
      -- Data output
      m_tready           => s_tready,
      m_tdata            => s_tdata,
      m_tvalid           => s_tvalid,
      m_tlast            => s_tlast);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  clk <= not clk after CLK_PERIOD/2;
  test_runner_watchdog(runner, 2 ms);

  ---------------
  -- Processes --
  ---------------
  main : process
    procedure walk(constant steps : natural) is
    begin
      if steps /= 0 then
        for step in 0 to steps - 1 loop
          wait until rising_edge(clk);
        end loop;
      end if;
    end procedure walk;
    ------------------------------------------------------------------------------------

    procedure run_test (constant frames : in integer := 1) is
      variable msg       : msg_t;
      variable reply_msg : msg_t;
      variable reader    : actor_t := find(READER_NAME);
      variable start     : time;
    begin
      start := now;
      for i in 0 to frames - 1 loop
        msg := new_msg;
        push_string(msg, FILE_NAME);
        send(net, reader, msg);
        receive_reply(net, msg, reply_msg);
      end loop;

      wait until s_tlast = '1' and s_tready = '1' and s_tvalid = '1' and rising_edge(clk);

      warning(sformat("Took %d cycles", fo((now - start) / CLK_PERIOD)));
    end procedure run_test;
    ------------------------------------------------------------------------------------

    procedure test_tvalid_probability is
      variable start          : time;
      variable baseline       : time;
      variable tvalid_half    : time;
      variable tvalid_quarter : time;
    begin
      rst <= '1'; walk(4); rst <= '0';
      tvalid_probability <= 1.0;
      start := now;
      run_test;
      baseline := now - start;

      rst <= '1'; walk(4); rst <= '0';
      tvalid_probability <= 0.5;
      start := now;
      run_test;
      tvalid_half := now - start;

      rst <= '1'; walk(4); rst <= '0';
      tvalid_probability <= 0.25;
      start := now;
      run_test;
      tvalid_quarter := now - start;

      -- Check time taken is the expected +/- 10%
      check_true((baseline * 0.9 * 2 < tvalid_half) and (tvalid_half < baseline * 1.1 * 2));
      check_true((baseline * 0.9 * 4 < tvalid_quarter) and (tvalid_quarter < baseline * 1.1 * 4));

    end procedure test_tvalid_probability;
    ------------------------------------------------------------------------------------

  begin

    test_runner_setup(runner, runner_cfg);
    show(display_handler, debug);

    create_file(256);


    while test_suite loop
      tvalid_probability <= 1.0;
      tready_probability <= 1.0;

      rst <= '1';
      walk(4);
      rst <= '0';
      walk(4);

      if run("back_to_back") then
        tvalid_probability <= 1.0;
        tready_probability <= 1.0;
        run_test;

      elsif run("slow_read") then
        tvalid_probability <= 1.0;
        tready_probability <= 0.5;
        run_test;

      elsif run("slow_write") then
        test_tvalid_probability;

      elsif run("multiple_frames") then
        run_test(4);
      end if;

      walk(4);

    end loop;

    test_runner_cleanup(runner);
    wait;

  end process main;

  -- Generate a tready enable with the configured probability
  s_tready_gen : process
    variable tready_rand : RandomPType;
    variable check_rand  : RandomPType;
    variable word_cnt    : integer := 0;
    variable frame_cnt   : integer := 0;
    variable expected    : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
  begin

    while True loop
      if rst = '1' then
        check_rand.InitSeed(0);
      else
        if completed = '1' then
          -- check_true(s_tvalid = '0' and s_tlast = '0',
          --            "tvalid and tlast should be '0' when completed is asserted");
        end if;
      end if;
      s_tready <= '0';
      if tready_rand.RandReal(1.0) <= tready_probability then
        s_tready <= '1';
      end if;
      if s_tready = '1' and s_tvalid = '1' then
        expected := check_rand.RandSlv(DATA_WIDTH);
        check_equal(s_tdata, expected,
                    sformat("Expected %r, got %r", fo(expected), fo(s_tdata)));

        word_cnt := word_cnt + 1;

        if s_tlast = '1' then
          info(sformat("Received frame %d with %d words", fo(frame_cnt), fo(word_cnt)));
          frame_cnt := frame_cnt + 1;
          word_cnt  := 0;
          -- Frames will repeat, reinitialize seed
          check_rand.InitSeed(0);
        end if;
      end if;

      wait until rising_edge(clk);
    end loop;
  end process;

end axi_file_reader_tb;
