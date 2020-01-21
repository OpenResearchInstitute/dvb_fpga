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
use work.testbench_utils_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_file_reader_tb is
  generic (
    runner_cfg : string;
    DATA_WIDTH : integer;
    test_cfg   : string);
end axi_file_reader_tb;

architecture axi_file_reader_tb of axi_file_reader_tb is

  type config_t is record
    ratio          : ratio_t;
    input_file     : line;
    reference_file : line;
  end record;

  type config_ptr_t is access config_t;
  type config_array_t is array (natural range <>) of config_t;
  type config_array_ptr_t is access config_array_t;

  impure function decode_line (
    constant s     : in string) return config_t is
    constant div_0 : integer := find(s, ",");
    constant div_1 : integer := find(s(div_0 + 1 to s'length), ",");
  begin

    return (
      parse_data_ratio(s(1 to div_0 - 1)),
      new string'(s(div_0 + 1 to div_1 - 1)),
      new string'(s(div_1 + 1 to s'length)));

    end;

  impure function get_config (
    constant s        : in string) return config_array_t is
    constant num_cfgs : integer := count(s, "|") + 1;
    variable cfg_list : config_array_t(0 to num_cfgs - 1);
    variable lines    : lines_t := split(s, "|");
  begin

    for i in lines'range loop
      info(sformat("%d => decoding '%s'", fo(i), lines(i).all));
      cfg_list(i) := decode_line(lines(i).all);
    end loop;

    return cfg_list;
  end;


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

    variable config_list : config_array_ptr_t;
    variable file_reader : file_reader_t := new_file_reader(READER_NAME);
    constant check_p     : actor_t := find("check_p");

    procedure walk(constant steps : natural) is
    begin
      if steps /= 0 then
        for step in 0 to steps - 1 loop
          wait until rising_edge(clk);
        end loop;
      end if;
    end procedure walk;
    ------------------------------------------------------------------------------------

    procedure run_test is
      variable cfg : config_ptr_t;
      variable msg : msg_t;
    begin
      for i in config_list'range loop
        cfg := new config_t'(config_list(i));
        -- Notify the DUT
        enqueue_file(net, file_reader, cfg.input_file.all, cfg.ratio);
        -- Notify the TB check process
        msg := new_msg;
        push(msg, cfg.reference_file.all);
        send(net, check_p, msg);
      end loop;

      info("Notifications sent, waiting for files to be read");
      wait_all_read(net, file_reader);
      wait until s_tvalid = '1' and s_tready = '1' and s_tlast = '1' and rising_edge(clk);
      info("All files have now been read");
    end procedure run_test;
    ------------------------------------------------------------------------------------

    procedure test_tvalid_probability is
      variable start          : time;
      variable baseline       : integer;
      variable tvalid_half    : integer;
      variable tvalid_quarter : integer;
    begin
      rst <= '1'; walk(4); rst <= '0';
      tvalid_probability <= 1.0;
      start := now;
      run_test;
      baseline := (now - start) / CLK_PERIOD;

      rst <= '1'; walk(4); rst <= '0';
      tvalid_probability <= 0.5;
      start := now;
      run_test;
      tvalid_half := (now - start) / CLK_PERIOD;

      rst <= '1'; walk(4); rst <= '0';
      tvalid_probability <= 0.25;
      start := now;
      run_test;
      tvalid_quarter := (now - start) / CLK_PERIOD;

      -- Check time taken is the expected +/- 10%
      info(sformat("baseline=%d, half=%d (%d), quarter=%d (%d)",
                   fo(baseline), fo(tvalid_half), fo(tvalid_half/2),
                   fo(tvalid_quarter), fo(tvalid_quarter/4)));

      -- Check that time taken is what we expect with a 20% margin
      check_true(real(tvalid_half) / 2.0 / real(baseline) > 0.85);
      check_true(real(tvalid_half) / 2.0 / real(baseline) < 1.15);

      check_true(real(tvalid_quarter) / 4.0 / real(baseline) > 0.85);
      check_true(real(tvalid_quarter) / 4.0 / real(baseline) < 1.15);

    end procedure test_tvalid_probability;
    ------------------------------------------------------------------------------------


  begin

    test_runner_setup(runner, runner_cfg);
    show(display_handler, debug);

    -- Extract the config
    config_list := new config_array_t'(get_config(test_cfg));

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

      end if;

      walk(4);

    end loop;

    test_runner_cleanup(runner);
    wait;

  end process main;

  -- Generate a tready enable with the configured probability
  s_tready_gen : process
    constant self           : actor_t := new_actor("check_p");
    variable tready_rand    : RandomPType;
    variable msg            : msg_t;
    variable word_cnt       : integer := 0;
    variable frame_cnt      : integer := 0;
    variable expected       : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    variable expected_tlast : std_logic;

    type file_status_t is (opened, closed, unknown);
    variable file_status : file_status_t := unknown;
    file file_handler    : text;
    variable L           : line;

  begin

    while True loop
      if rst = '1' and file_status = opened then
        info("Forcing file close due to reset");
        file_close(file_handler);
        file_status := closed;
      end if;

      s_tready <= '0';

      if file_status /= opened and has_message(self) then
        receive(net, self, msg);
        info("Opening file");
        file_open(file_handler, pop(msg), read_mode);
        info("Opening worked");
        file_status  := opened;
      end if;

      if file_status = opened then
        if tready_rand.RandReal(1.0) <= tready_probability then
          s_tready <= '1';
        end if;
        if s_tready = '1' and s_tvalid = '1' then
          word_cnt := word_cnt + 1;

          readline(file_handler, L);

          expected_tlast := '0';

          if endfile(file_handler) then
            info("Closing file");
            file_close(file_handler);
            file_status    := closed;
            expected_tlast := '1';
          end if;

          hread(L, expected);

          check_equal(s_tdata, expected,
                      sformat("Frame %d, word %d: Expected %r, got %r",
                      fo(frame_cnt), fo(word_cnt), fo(expected), fo(s_tdata)));

          check_equal(s_tlast, expected_tlast,
                      sformat("Frame %d, word %d: Expected tlast to be %r but got %r",
                      fo(frame_cnt), fo(word_cnt), fo(expected_tlast), fo(s_tlast)));

          if s_tlast = '1' then
            info(sformat("Received frame %d with %d words", fo(frame_cnt), fo(word_cnt)));
            frame_cnt := frame_cnt + 1;
            word_cnt  := 0;
          end if;
        end if;
      end if;

      wait until rising_edge(clk);
    end loop;
  end process;

end axi_file_reader_tb;
