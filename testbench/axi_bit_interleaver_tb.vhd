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

use work.dvb_utils_pkg.all;
use work.dvb_sim_utils_pkg.all;

library fpga_cores;
use fpga_cores.common_pkg.all;

library fpga_cores_sim;
use fpga_cores_sim.testbench_utils_pkg.all;
use fpga_cores_sim.file_utils_pkg.all;

-- ghdl translate_off
library modelsim_lib;
use modelsim_lib.util.all;
-- ghdl translate_on


entity axi_bit_interleaver_tb is
  generic (
    RUNNER_CFG            : string;
    TEST_CFG              : string;
    DATA_WIDTH            : integer := 8;
    NUMBER_OF_TEST_FRAMES : integer := 8);
end axi_bit_interleaver_tb;

architecture axi_bit_interleaver_tb of axi_bit_interleaver_tb is

  ---------------
  -- Constants --
  ---------------
  constant configs                    : config_array_t := get_test_cfg(TEST_CFG);

  constant FILE_READER_NAME           : string := "file_reader";
  constant FILE_CHECKER_NAME          : string := "file_checker";
  constant CLK_PERIOD                 : time := 5 ns;
  constant ERROR_CNT_WIDTH            : integer := 8;

  constant DBG_CHECK_FRAME_RAM_WRITES : boolean := False;

  function get_checker_data_ratio ( constant constellation : in constellation_t)
  return string is
  begin
    case constellation is
      when   mod_8psk => return "3:8";
      when mod_16apsk => return "4:8";
      when mod_32apsk => return "5:8";
      when others =>
        report "Invalid constellation: " & constellation_t'image(constellation)
        severity Failure;
    end case;

    -- Just to avoid the warning, should never be reached
    return "";

  end;

  -------------
  -- Signals --
  -------------
  -- Usual ports
  signal clk                : std_logic := '1';
  signal rst                : std_logic;

  signal cfg_constellation  : constellation_t;
  signal cfg_frame_type     : frame_type_t;
  signal cfg_code_rate      : code_rate_t;

  signal tvalid_probability : real range 0.0 to 1.0 := 1.0;
  signal tready_probability : real range 0.0 to 1.0 := 1.0;

  -- AXI input
  signal m_tready           : std_logic;
  signal m_tvalid           : std_logic;
  signal m_tdata            : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal m_tlast            : std_logic;
  signal m_data_valid       : boolean;

  -- AXI output
  signal s_tvalid           : std_logic;
  signal s_tdata            : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal s_tlast            : std_logic;
  signal s_tready           : std_logic;
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
  dut : entity work.axi_bit_interleaver
    generic map ( DATA_WIDTH => DATA_WIDTH )
    port map (
      -- Usual ports
      clk               => clk,
      rst               => rst,

      cfg_constellation => cfg_constellation,
      cfg_frame_type    => cfg_frame_type,
      cfg_code_rate     => cfg_code_rate,

      -- AXI input
      s_tvalid          => m_tvalid,
      s_tdata           => m_tdata,
      s_tlast           => m_tlast,
      s_tready          => m_tready,

      -- AXI output
      m_tready          => s_tready,
      m_tvalid          => s_tvalid,
      m_tlast           => s_tlast,
      m_tdata           => s_tdata);


  -- AXI file read
  axi_file_reader_u : entity fpga_cores_sim.axi_file_reader
    generic map (
      READER_NAME => FILE_READER_NAME,
      DATA_WIDTH  => DATA_WIDTH)
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
      m_tvalid           => m_tvalid,
      m_tlast            => m_tlast);

  axi_file_compare_u : entity fpga_cores_sim.axi_file_compare
    generic map (
      READER_NAME     => FILE_CHECKER_NAME,
      ERROR_CNT_WIDTH => ERROR_CNT_WIDTH,
      REPORT_SEVERITY => Warning,
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

  test_runner_watchdog(runner, 3 ms);

  m_data_valid <= m_tvalid = '1' and m_tready = '1';
  s_data_valid <= s_tvalid = '1' and s_tready = '1';

  ---------------
  -- Processes --
  ---------------
  main : process
    constant self         : actor_t := new_actor("main");
    constant input_cfg_p  : actor_t := find("input_cfg_p");
    variable file_checker : file_reader_t := new_file_reader(FILE_CHECKER_NAME);
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
      constant number_of_frames : in positive) is
      variable msg              : msg_t;
      constant data_path        : string := strip(config.base_path, chars => (1 to 1 => nul));
    begin

      info("Running test with:");
      info(" - constellation  : " & constellation_t'image(config.constellation));
      info(" - frame_type     : " & frame_type_t'image(config.frame_type));
      info(" - code_rate      : " & code_rate_t'image(config.code_rate));
      info(" - data path      : " & data_path);

      for i in 0 to number_of_frames - 1 loop
        msg        := new_msg;
        msg.sender := self;

        push(msg, data_path & "/bit_interleaver_input.bin");
        push(msg, config.constellation);
        push(msg, config.frame_type);
        push(msg, config.code_rate);

        send(net, input_cfg_p, msg);

        if DBG_CHECK_FRAME_RAM_WRITES then
          msg        := new_msg;
          msg.sender := self;

          push(msg, config.constellation);
          push(msg, config.frame_type);
          push(msg, config.code_rate);

          send(net, find("whitebox_monitor_p"), msg);
        end if;

        read_file(
          net,
          file_checker,
          data_path & "/bit_interleaver_output.bin",
          get_checker_data_ratio(config.constellation)
        );

      end loop;

    end procedure run_test;

    procedure wait_for_completion is -- {{ ---------------------------------------------
      variable msg : msg_t;
    begin
      info("Waiting for completion");
      receive(net, self, msg);
      wait_all_read(net, file_checker);

      wait until rising_edge(clk) and s_tvalid = '0' for 100 us;

      check_equal(s_tvalid, '0', "s_tvalid should be low after the test");

      walk(1);
    end procedure wait_for_completion; -- }} -------------------------------------------

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

      set_timeout(runner, configs'length * NUMBER_OF_TEST_FRAMES * 4 ms / DATA_WIDTH);

      if run("back_to_back") then
        tvalid_probability <= 1.0;
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("slow_master") then
        tvalid_probability <= 0.1;
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("slow_slave") then
        tvalid_probability <= 1.0;
        tready_probability <= 0.5;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("both_slow") then
        tvalid_probability <= 0.75;
        tready_probability <= 0.75;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      end if;

      wait_for_completion;

      walk(1);

      check_false(has_message(input_cfg_p));

      walk(32);

    end loop;

    test_runner_cleanup(runner);
    wait;
  end process;

  input_cfg_p : process
    constant logger      : logger_t := get_logger("input_cfg_p");
    constant self        : actor_t := new_actor("input_cfg_p");
    constant main        : actor_t := find("main");
    variable cfg_msg     : msg_t;
    variable file_reader : file_reader_t := new_file_reader(FILE_READER_NAME);
  begin

    receive(net, self, cfg_msg);

    -- Configure the file reader
    read_file(net, file_reader, pop(cfg_msg), "1:8");

    wait until rising_edge(clk);

    -- Keep the config stuff active for a single cycle to make sure blocks use the correct
    -- values
    cfg_constellation <= pop(cfg_msg);
    cfg_frame_type    <= pop(cfg_msg);
    cfg_code_rate     <= pop(cfg_msg);
    wait until m_data_valid and m_tlast = '0' and rising_edge(clk);
    cfg_constellation <= not_set;
    cfg_frame_type    <= not_set;
    cfg_code_rate     <= not_set;

    wait until m_data_valid and m_tlast = '1';

    -- When this is received, the file reader has finished reading the file
    wait_file_read(net, file_reader);

    -- If there's no more messages, notify the main process that we're done here
    if not has_message(self) then
      cfg_msg := new_msg;
      push(cfg_msg, True);
      cfg_msg.sender := self;
      debug(logger, "Notifying main process that there is no more data");
      send(net, main, cfg_msg);
    end if;
  end process;

  process
  begin
    wait until rst = '0';
    wait until unsigned(error_cnt) /= 0;
    check_equal(error_cnt, 0, sformat("Expected 0 errors but got %d", fo(error_cnt)));
  end process;

  -- ghdl translate_off
  whitebox_monitor : if DBG_CHECK_FRAME_RAM_WRITES generate

    constant logger : logger_t := get_logger("whitebox_monitor");

    constant whitebox_axi_monitor : actor_t := new_actor("whitebox_monitor_axi_data");
    constant whitebox_ram_monitor : actor_t := new_actor("whitebox_monitor_ram_data");

    signal frame_cnt : integer := 0;

    type cfg_t is record
      row_number    : natural;
      column_number : natural;
      remainder     : natural;
    end record;

    constant RAM_PTR_WIDTH : integer := 2;
    constant MAX_ROWS      : integer := 21_600 / DATA_WIDTH;
    constant MAX_COLUMNS   : integer := 5;

    type addr_array_t is array (natural range <>)
      of unsigned(numbits(MAX_ROWS) + RAM_PTR_WIDTH - 1 downto 0);
    type data_array_t is array (natural range <>) of std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- signal ram_wr_addr               : addr_array_t(MAX_COLUMNS - 1 downto 0);
    -- signal ram_wr_data               : data_array_t(MAX_COLUMNS - 1 downto 0);
    -- signal ram_wr_en                 : std_logic_vector(MAX_COLUMNS - 1 downto 0);

    type ram_wr_t is record
      addr : unsigned(numbits(MAX_ROWS) + RAM_PTR_WIDTH - 1 downto 0);
      data : std_logic_vector(DATA_WIDTH - 1 downto 0);
      en   : std_logic;
    end record;

    type ram_wr_array_t is array (MAX_COLUMNS - 1 downto 0) of ram_wr_t;

    signal ram_wr   : ram_wr_array_t;

    impure function get_interleaver_config ( constant msg : msg_t ) return cfg_t is
      variable constellation : constellation_t;
      variable frame_type    : frame_type_t;
      variable code_rate     : code_rate_t;

      variable rows          : natural;
      variable columns       : natural;
      variable remainder     : natural;
    begin

      constellation := pop(msg);
      frame_type    := pop(msg);
      code_rate     := pop(msg);

      if frame_type = fecframe_normal then
        if constellation = mod_8psk then
          rows := 21_600;
        elsif constellation = mod_16apsk then
          rows := 16_200;
        elsif constellation = mod_32apsk then
          rows := 12_960;
        end if;
      elsif frame_type = fecframe_short then
        if constellation = mod_8psk then
          rows := 5_400;
        elsif constellation = mod_16apsk then
          rows := 4_050;
        elsif constellation = mod_32apsk then
          rows := 3_240;
        end if;
      end if;

      if constellation = mod_8psk then
        columns := 3;
      elsif constellation = mod_16apsk then
        columns := 4;
      elsif constellation = mod_32apsk then
        columns := 5;
      end if;

      return (row_number    => rows / DATA_WIDTH + 1,
              column_number => columns,
              remainder     => rows mod DATA_WIDTH);

    end function get_interleaver_config;

    impure function equal_ignore_x (constant a, b : std_logic_vector) return boolean is
      variable result : boolean := True;
    begin
      assert a'length = b'length;
      -- if a'length /= b'length then
      --   return False;
      -- end if;

      for i in a'range loop
        if a(i) /= 'U' and b(i) /= 'U' then
          if a(i) /= b(i) then
            result := False;
          end if;
        end if;
      end loop;

      if not result then
        warning(sformat("Comparing %b and %b => %r", fo(a), fo(b), fo(result)));
      end if;

      return result;
    end function;

    procedure check_ram_write (
      signal   net           : inout std_logic;
      constant cfg           : cfg_t ) is
      variable msg           : msg_t;

      variable data_sr       : std_logic_vector(2*DATA_WIDTH - 1 downto 0);
      variable is_last       : boolean := False;
      variable bit_cnt       : natural := 0;

      variable expected_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
      variable ram_addr      : unsigned(numbits(MAX_ROWS) - 1 downto 0);
      variable ram_data      : std_logic_vector(DATA_WIDTH - 1 downto 0);
      variable offset        : natural := 0;
    begin

      bit_cnt := 0;
      for column in 0 to cfg.column_number - 1 loop
        for row in 0 to cfg.row_number - 1 loop

          -- Receive AXI data if we need more
          if bit_cnt < DATA_WIDTH and not is_last then
            receive(net, whitebox_axi_monitor, msg);
            data_sr := data_sr(data_sr'length - DATA_WIDTH - 1 downto 0) & std_logic_vector'(pop(msg));
            is_last := pop(msg);
            bit_cnt := bit_cnt + DATA_WIDTH;
          end if;

          -- Receive RAM data
          receive(net, whitebox_ram_monitor, msg);
          -- We're not comparing pointers
          ram_addr := pop(msg)(numbits(MAX_ROWS) - 1 downto 0);
          ram_data := pop(msg);

          -- For the last row we'll only compare the relevant bits
          if row = cfg.row_number - 1 then
            expected_data := data_sr(bit_cnt - 1 downto bit_cnt - cfg.remainder)
                             & (DATA_WIDTH - 1 downto cfg.remainder => 'U');
          else
            expected_data := data_sr(bit_cnt - 1 downto bit_cnt - DATA_WIDTH);
          end if;

          info(
            logger,
            sformat(
              "[frame=%d, column=%d, row=%3d] " &
              "is_last=%r, offset=%d || bit_cnt=%2d || data_sr = %r (%b)  ||  " &
              "expected_data = %r (%b)",
              fo(frame_cnt),
              fo(column),
              fo(row),
              fo(is_last),
              fo(offset),
              fo(bit_cnt),
              fo(data_sr),
              fo(data_sr),
              fo(expected_data),
              fo(expected_data)));

          -- if row /= ram_addr or expected_data /= ram_data then
          if row /= ram_addr or not equal_ignore_x(expected_data, ram_data) then
            if row /= cfg.row_number - 1 then
              error(
                logger,
                sformat(
                  "[frame=%d, column=%d, row=%3d] Expected addr: %r / %d, data: %r, got addr=%r, data=%r",
                  fo(frame_cnt),
                  fo(column),
                  fo(row),
                  fo(to_unsigned(row, numbits(MAX_ROWS))),
                  fo(row),
                  fo(expected_data),
                  fo(ram_addr),
                  fo(ram_data)));
            else
              error(
                logger,
                sformat(
                  "[frame=%d, column=%d, row=%3d] Expected addr: %r / %d, data: %r, got addr=%r, data=%r",
                  fo(frame_cnt),
                  fo(column),
                  fo(row),
                  fo(to_unsigned(row, numbits(MAX_ROWS))),
                  fo(row),
                  fo(expected_data),
                  fo(ram_addr),
                  fo(ram_data)));
            end if;
          end if;

          if row = cfg.row_number - 1 then
            offset  := offset + cfg.remainder;
            bit_cnt := bit_cnt - cfg.remainder;
            data_sr := (data_sr'length - bit_cnt - 1 downto 0 => 'U') & data_sr(bit_cnt - 1 downto 0);
          else
            bit_cnt := bit_cnt - DATA_WIDTH;
          end if;
        end loop;
      end loop;

      assert is_last;

      warning("Exiting check loop");

    end;

  begin
    process
      constant self : actor_t := new_actor("whitebox_monitor_p");
      constant main : actor_t := find("main");
      variable msg  : msg_t;
      variable cfg  : cfg_t;
    begin

      init_signal_spy("../../dut/ram_wr", "ram_wr", 1);

      while True loop
        receive(net, self, msg);
        cfg := get_interleaver_config(msg);
        check_ram_write(net, cfg);
        frame_cnt <= frame_cnt + 1;
      end loop;
      wait;
    end process;

    queue_axi_data_p : process
      constant logger    : logger_t := get_logger("queue_axi_data_p");
      variable msg       : msg_t;
      variable frame_cnt : natural  := 0;
      variable word_cnt  : natural  := 0;
    begin
      wait until m_tvalid = '1' and m_tready = '1' and rising_edge(clk);
      msg := new_msg;
      push(msg, m_tdata);
      if m_tlast = '1' then
        push(msg, True);
      else
        push(msg, False);
      end if;
      debug(logger, sformat("[frame=%d, word=%d] tdata=%r", fo(frame_cnt), fo(word_cnt), fo(m_tdata)));
      send(net, find("whitebox_monitor_axi_data"), msg);
      word_cnt := word_cnt + 1;
      if m_tlast = '1' then
        word_cnt := 0;
        frame_cnt := frame_cnt + 1;
      end if;
    end process;

    queue_ram_data_p : process
      variable msg     : msg_t;
      variable sampled : boolean;
      variable cnt     : natural := 0;
    begin
      wait until rising_edge(clk);
      sampled := False;

      for column in 0 to MAX_COLUMNS - 1 loop
        -- Sample RAM wr data
        if ram_wr(column).en = '1' then
          assert not sampled;
          sampled := True;

          msg := new_msg;
          push(msg, ram_wr(column).addr);
          push(msg, ram_wr(column).data);
          send(net, find("whitebox_monitor_ram_data"), msg);
        end if;
      end loop;
    end process;

  end generate whitebox_monitor;
  -- ghdl translate_on

end axi_bit_interleaver_tb;
