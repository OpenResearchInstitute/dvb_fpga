-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
--
-- DVB FPGA
--
-- Copyright 2019-2022 by suoto <andre820@gmail.com>
--
-- This source describes Open Hardware and is licensed under the CERN-OHL-W v2.
--
-- You may redistribute and modify this source and make products using it under
-- the terms of the CERN-OHL-W v2 (https://ohwr.org/cern_ohl_w_v2.txt).
--
-- This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING
-- OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.
-- Please see the CERN-OHL-W v2 for applicable conditions.
--
-- Source location: https://github.com/phase4ground/dvb_fpga
--
-- As per CERN-OHL-W v2 section 4.1, should You produce hardware based on this
-- source, You must maintain the Source Location visible on the external case of
-- the DVB Encoder or other products you make using this source.
-- vunit: run_all_in_same_sim

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.math_complex.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

library osvvm;
use osvvm.RandomPkg.all;

library str_format;
use str_format.str_format_pkg.all;

library fpga_cores;
use fpga_cores.axi_pkg.all;

library fpga_cores_sim;
context fpga_cores_sim.sim_context;

use work.dvb_utils_pkg.all;
use work.dvb_sim_utils_pkg.all;

entity axi_physical_layer_framer_tb is
  generic (
    RUNNER_CFG            : string;
    TEST_CFG              : string;
    NUMBER_OF_TEST_FRAMES : integer := 8;
    SEED                  : integer);
end axi_physical_layer_framer_tb;

architecture axi_physical_layer_framer_tb of axi_physical_layer_framer_tb is

  ---------------
  -- Constants --
  ---------------
  constant configs     : config_array_t := get_test_cfg(TEST_CFG);

  constant CLK_PERIOD  : time    := 5 ns;
  constant TDATA_WIDTH : integer := 32;

  -------------
  -- Signals --
  -------------
  -- Usual ports
  signal clk                : std_logic := '1';
  signal rst                : std_logic;

  signal tvalid_probability : real range 0.0 to 1.0 := 1.0;
  signal tready_probability : real range 0.0 to 1.0 := 1.0;

  -- AXI input
  signal axi_master         : axi_stream_bus_t(tdata(TDATA_WIDTH - 1 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
  signal m_data_valid       : boolean;

  signal axi_slave          : axi_stream_bus_t(tdata(TDATA_WIDTH - 1 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
  signal s_data_valid       : boolean;

  signal expected_tdata     : std_logic_vector(TDATA_WIDTH - 1 downto 0);
  signal expected_tlast     : std_logic;

  signal dbg_input          : complex;
  signal dbg_recv           : complex;
  signal dbg_expected       : complex;
begin

  -------------------
  -- Port mappings --
  -------------------
  -- AXI file read
  axi_file_reader_u : entity fpga_cores_sim.axi_file_reader
    generic map (
      READER_NAME => "axi_file_reader_u",
      DATA_WIDTH  => TDATA_WIDTH,
      TID_WIDTH   => ENCODED_CONFIG_WIDTH,
      SEED        => SEED)
    port map (
      -- Usual ports
      clk                => clk,
      rst                => rst,
      -- Config and status
      completed          => open,
      tvalid_probability => tvalid_probability,

      -- Data output
      m_tready           => axi_master.tready,
      m_tdata            => axi_master.tdata,
      m_tid              => axi_master.tuser,
      m_tvalid           => axi_master.tvalid,
      m_tlast            => axi_master.tlast);

  dut : entity work.axi_physical_layer_framer
    generic map (
      TDATA_WIDTH => TDATA_WIDTH,
      TID_WIDTH   => ENCODED_CONFIG_WIDTH)
    port map (
      -- Usual ports
      clk             => clk,
      rst             => rst,
      -- Static config
      cfg_enable_dummy_frames  => '0', -- Not supported by the TB yet
      -- AXI input
      s_constellation => decode(axi_master.tuser).constellation,
      s_frame_type    => decode(axi_master.tuser).frame_type,
      s_code_rate     => decode(axi_master.tuser).code_rate,
      s_pilots        => decode(axi_master.tuser).pilots,
      s_tvalid        => axi_master.tvalid,
      s_tlast         => axi_master.tlast,
      s_tready        => axi_master.tready,
      s_tdata         => axi_master.tdata,
      s_tid           => axi_master.tuser,
      -- AXI output
      m_tready        => axi_slave.tready,
      m_tvalid        => axi_slave.tvalid,
      m_tlast         => axi_slave.tlast,
      m_tdata         => axi_slave.tdata,
      m_tid           => axi_slave.tuser);

  ref_data_u : entity work.axi_file_compare_complex
    generic map (
      READER_NAME         => "ref_data_u",
      DATA_WIDTH          => TDATA_WIDTH,
      TOLERANCE           => 4,
      SWAP_BYTE_ENDIANESS => False,
      ERROR_CNT_WIDTH     => 8,
      REPORT_SEVERITY     => Error)
    port map (
      -- Usual ports
      clk                => clk,
      rst                => rst,
      -- Config and status
      tdata_error_cnt    => open,
      tlast_error_cnt    => open,
      error_cnt          => open,
      -- Debug stuff
      expected_tdata     => expected_tdata,
      expected_tlast     => expected_tlast,
      -- Data input
      s_tready           => axi_slave.tready,
      s_tdata            => axi_slave.tdata,
      s_tvalid           => axi_slave.tvalid,
      s_tlast            => axi_slave.tlast);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  clk <= not clk after CLK_PERIOD/2;

  test_runner_watchdog(runner, 3 ms);

  m_data_valid <= axi_slave.tvalid = '1' and axi_slave.tready = '1';
  s_data_valid <= axi_master.tvalid = '1' and axi_master.tready = '1';

  dbg_input    <= to_complex(axi_master.tdata) when axi_master.tvalid = '1';
  dbg_recv     <= to_complex(axi_slave.tdata) when axi_slave.tvalid = '1';
  dbg_expected <= to_complex(expected_tdata) when axi_slave.tvalid and axi_slave.tready;

  ---------------
  -- Processes --
  ---------------
  main : process
    constant self         : actor_t       := new_actor("main");
    constant logger       : logger_t      := get_logger("main");
    variable file_checker : file_reader_t := new_file_reader("ref_data_u");
    variable file_reader  : file_reader_t := new_file_reader("axi_file_reader_u");

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
    procedure run_test ( -- {{ ---------------------------------------------------------
      constant config           : config_t;
      constant number_of_frames : in positive) is
      constant data_path        : string := strip(config.base_path, chars => (1 to 1 => nul));
      variable calc_ldpc_msg    : msg_t;
      variable msg              : msg_t;
      variable config_tuple     : config_tuple_t;
    begin

      info(logger, "Running test with:");
      info(logger, " - constellation  : " & constellation_t'image(config.constellation));
      info(logger, " - frame_type     : " & frame_type_t'image(config.frame_type));
      info(logger, " - code_rate      : " & code_rate_t'image(config.code_rate));
      info(logger, " - pilots         : " & std_logic'image(config.pilots));
      info(logger, " - data path      : " & data_path);

      config_tuple := (
        code_rate     => config.code_rate,
        constellation => config.constellation,
        frame_type    => config.frame_type,
        pilots        => config.pilots);

      for i in 0 to number_of_frames - 1 loop
        debug(logger, "Setting up frame #" & to_string(i));

        read_file(net,
          file_reader => file_reader,
          filename    => data_path & "/bit_mapper_output_fixed_point.bin",
          tid         => encode(config_tuple)
        );

        if config.pilots then
          read_file( net, file_checker, data_path & "/plframe_pilots_on_fixed_point.bin");
        else
          read_file( net, file_checker, data_path & "/plframe_pilots_off_fixed_point.bin");
        end if;

        -- Update the expected TID
        msg := new_msg;
        push(msg, encode(config_tuple));
        send(net, find("tid_check"), msg);

      end loop;

    end procedure run_test; -- }} ------------------------------------------------------

    procedure wait_for_transfers is
    begin
      wait_all_read(net, file_reader);
      wait_all_read(net, file_checker);
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
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

        wait_for_transfers;

      elsif run("slow_master") then
        tvalid_probability <= 0.5;
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;
        wait_for_transfers;

      elsif run("slow_slave") then
        tvalid_probability <= 1.0;
        tready_probability <= 0.5;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;
        wait_for_transfers;

      elsif run("both_slow") then
        tvalid_probability <= 0.75;
        tready_probability <= 0.75;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;
        wait_for_transfers;

      end if;

      walk(8);

    end loop;

    test_runner_cleanup(runner);
    wait;
  end process;

  tid_check_p : process -- {{ ----------------------------------------------------------
    constant self         : actor_t := new_actor("tid_check");
    variable msg          : msg_t;
    variable expected_tid : std_logic_vector(ENCODED_CONFIG_WIDTH - 1 downto 0);
    variable first_word   : boolean;
    variable frame_cnt    : integer := 0;
    variable word_cnt     : integer := 0;
  begin
    first_word := True;
    while true loop
      wait until rising_edge(clk) and axi_slave.tvalid = '1' and axi_slave.tready = '1';
      if first_word then
        check_true(has_message(self), "Expected TID not set");
        receive(net, self, msg);
        expected_tid := pop(msg);
        info(sformat("[%d / %d] Updated expected TID to %r", fo(frame_cnt), fo(word_cnt), fo(expected_tid)));
      end if;

      check_equal(
        axi_slave.tuser,
        expected_tid,
        sformat(
          "[%d / %d] TID check error: got %r, expected %r",
          fo(frame_cnt),
          fo(word_cnt),
          fo(axi_slave.tuser),
          fo(expected_tid)));

      first_word := False;
      word_cnt   := word_cnt + 1;
      if axi_slave.tlast = '1' then
        info(sformat("[%d / %d] Setting first word", fo(frame_cnt), fo(word_cnt)));
        frame_cnt  := frame_cnt + 1;
        word_cnt   := 0;
        first_word := True;
      end if;
    end loop;
  end process; -- }} -------------------------------------------------------------------

  axi_slave_tready_gen : process(clk) -- {{ --------------------------------------------
    variable rand : RandomPType;
  begin
    if rst then
      rand.InitSeed("axi_slave_tready_gen" & integer'image(SEED) & time'image(now));
    elsif rising_edge(clk) then
      -- Generate a tready enable with the configured probability
      axi_slave.tready <= '0';
      if rand.RandReal(1.0) <= tready_probability then
        axi_slave.tready <= '1';
      end if;
    end if;
  end process; -- }} -------------------------------------------------------------------

end axi_physical_layer_framer_tb;
