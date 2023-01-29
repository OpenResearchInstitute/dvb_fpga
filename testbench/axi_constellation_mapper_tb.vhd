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
use fpga_cores.common_pkg.all;

library fpga_cores_sim;
context fpga_cores_sim.sim_context;

use work.dvb_sim_utils_pkg.all;
use work.dvb_utils_pkg.all;
use work.constellation_mapper_pkg.all;

-- ghdl translate_off
library modelsim_lib;
use modelsim_lib.util.all;
-- ghdl translate_on

entity axi_constellation_mapper_tb is
  generic (
    RUNNER_CFG            : string;
    TEST_CFG              : string;
    NUMBER_OF_TEST_FRAMES : integer := 8;
    SEED                  : integer);
end axi_constellation_mapper_tb;

architecture axi_constellation_mapper_tb of axi_constellation_mapper_tb is

  ---------------
  -- Constants --
  ---------------
  constant configs           : config_array_t := get_test_cfg(TEST_CFG);

  constant INPUT_DATA_WIDTH  : integer := 8;
  constant OUTPUT_DATA_WIDTH : integer := 32;

  constant CLK_PERIOD        : time    := 5 ns;

  -------------
  -- Signals --
  -------------
  signal clk                : std_logic := '1';
  signal rst                : std_logic;

    -- Mapping RAM config
  signal iq_ram_wren        : std_logic;
  signal iq_ram_addr        : std_logic_vector(5 downto 0);
  signal iq_ram_wdata       : std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0);
  signal iq_ram_rdata       : std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0);
      -- Mapping RAM config (optional, default values should work)
  signal radius_ram_wren    : std_logic;
  signal radius_ram_addr    : std_logic_vector(numbits(RADIUS_TABLE_DEPTH) - 1 downto 0);
  signal radius_ram_wdata   : std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0);
  signal radius_ram_rdata   : std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0);

  signal data_probability   : real range 0.0 to 1.0 := 1.0;
  signal tready_probability : real range 0.0 to 1.0 := 1.0;

  signal m_data_valid       : boolean;
  signal s_data_valid       : boolean;

  -- AXI input
  signal axi_master         : axi_stream_bus_t(tdata(INPUT_DATA_WIDTH - 1 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
  -- AXI output
  signal axi_slave          : axi_stream_bus_t(tdata(OUTPUT_DATA_WIDTH - 1 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
  signal expected_tdata     : std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0);

begin

  -------------------
  -- Port mappings --
  -------------------
  input_data_u : entity fpga_cores_sim.axi_file_reader
    generic map (
      READER_NAME => "input_data",
      DATA_WIDTH  => INPUT_DATA_WIDTH,
      TID_WIDTH   => ENCODED_CONFIG_WIDTH,
      SEED        => SEED)
    port map (
      -- Usual ports
      clk                => clk,
      rst                => rst,
      -- Config and status
      completed          => open,
      tvalid_probability => data_probability,

      -- Data output
      m_tready           => axi_master.tready,
      m_tdata            => axi_master.tdata,
      m_tid              => axi_master.tuser,
      m_tvalid           => axi_master.tvalid,
      m_tlast            => axi_master.tlast);

  dut : entity work.axi_constellation_mapper
    generic map (
      INPUT_DATA_WIDTH  => INPUT_DATA_WIDTH,
      OUTPUT_DATA_WIDTH => OUTPUT_DATA_WIDTH,
      TID_WIDTH         => ENCODED_CONFIG_WIDTH)
    port map (
      -- Usual ports
      clk             => clk,
      rst             => rst,

      s_frame_type    => decode(axi_master.tuser).frame_type,
      s_constellation => decode(axi_master.tuser).constellation,
      s_code_rate     => decode(axi_master.tuser).code_rate,

      -- AXI input
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
      m_tid           => axi_slave.tuser,

      -- IQ mapping RAM config (optional, default values should work)
      iq_ram_wren      => iq_ram_wren,
      iq_ram_addr      => iq_ram_addr,
      iq_ram_wdata     => iq_ram_wdata,
      iq_ram_rdata     => iq_ram_rdata,
      -- Mapping RAM config (optional, default values should work)
      radius_ram_wren  => radius_ram_wren,
      radius_ram_addr  => radius_ram_addr,
      radius_ram_wdata => radius_ram_wdata,
      radius_ram_rdata => radius_ram_rdata
    );


  output_checker_u : entity work.axi_file_compare_complex
    generic map (
      READER_NAME         => "output_checker",
      DATA_WIDTH          => OUTPUT_DATA_WIDTH,
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
      expected_tlast     => open,
      -- Data input
      s_tready           => axi_slave.tready,
      s_tdata            => axi_slave.tdata,
      s_tvalid           => axi_slave.tvalid,
      s_tlast            => axi_slave.tlast);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  clk <= not clk after CLK_PERIOD/2;

  test_runner_watchdog(runner, 10 ms);

  m_data_valid <= axi_master.tvalid = '1' and axi_master.tready = '1';
  s_data_valid <= axi_slave.tvalid = '1' and axi_slave.tready = '1';

  ---------------
  -- Processes --
  ---------------
  main : process -- {{
    constant self           : actor_t       := new_actor("main");
    constant logger         : logger_t      := get_logger("main");
    variable input_data     : file_reader_t := new_file_reader("input_data");
    variable output_checker : file_reader_t := new_file_reader("output_checker");

    procedure walk(constant steps : natural) is -- {{ ----------------------------------
    begin
      if steps /= 0 then
        for step in 0 to steps - 1 loop
          wait until rising_edge(clk);
        end loop;
      end if;
    end procedure walk; -- }} ----------------------------------------------------------

    procedure wait_for_completion is -- {{ ---------------------------------------------
      variable msg : msg_t;
    begin
      info(logger, "Waiting for all frames to be read");
      wait_all_read(net, input_data);
      wait_all_read(net, output_checker);
      info(logger, "All data has now been read");
      walk(8);
      wait until rising_edge(clk) and axi_slave.tvalid = '0' for 100 us;
      walk(1);
    end procedure wait_for_completion; -- }} -------------------------------------------

    procedure write_radius_ram ( -- {{ --------------------------------------------------------
      constant addr : in integer;
      constant data : in std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0)) is
    begin
      radius_ram_wren  <= '1';
      radius_ram_addr  <= std_logic_vector(to_unsigned(addr, radius_ram_addr'length));
      radius_ram_wdata <= data;
      walk(1);
      radius_ram_wren  <= '0';
      radius_ram_addr  <= (others => 'U');
      radius_ram_wdata <= (others => 'U');
    end procedure; -- }} ---------------------------------------------------------------

    procedure write_iq_ram ( -- {{ --------------------------------------------------------
      constant addr : in integer;
      constant data : in std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0)) is
    begin
      iq_ram_wren  <= '1';
      iq_ram_addr  <= std_logic_vector(to_unsigned(addr, iq_ram_addr'length));
      iq_ram_wdata <= data;
      walk(1);
      iq_ram_wren  <= '0';
      iq_ram_addr  <= (others => 'U');
      iq_ram_wdata <= (others => 'U');
    end procedure; -- }} ---------------------------------------------------------------

    procedure run_test ( -- {{ ---------------------------------------------------------
      constant config           : config_t;
      constant number_of_frames : in positive) is
      constant data_path        : string := strip(config.base_path, chars => (1 to 1 => nul));
      variable initial_addr     : integer := 0;
      variable msg              : msg_t;
      variable config_tuple     : config_tuple_t;
    begin
      info(logger, "Running test with:");
      info(logger, " - constellation  : " & constellation_t'image(config.constellation));
      info(logger, " - frame_type     : " & frame_type_t'image(config.frame_type));
      info(logger, " - code_rate      : " & code_rate_t'image(config.code_rate));
      info(logger, " - pilots         : " & std_logic'image(config.pilots));
      info(logger, " - data path      : " & data_path);

      config_tuple := (code_rate     => config.code_rate,
                       constellation => config.constellation,
                       frame_type    => config.frame_type,
                       pilots        => config.pilots);

      -- Only update the mapping RAM if the config actually requires that
      case config.constellation is
        when mod_qpsk => initial_addr := 0;
        when mod_8psk => initial_addr := 4;
        when mod_16apsk => initial_addr := 12;
        when mod_32apsk => initial_addr := 28;
        when others => null;
      end case;

      for i in 0 to number_of_frames - 1 loop
        debug(logger, "Setting up frame #" & to_string(i));

        -- Update the expected TID
        msg := new_msg;
        push(msg, encode(config_tuple));
        send(net, find("tid_check"), msg);
        -- Setup file reader
        read_file(net, input_data, data_path & "/bit_interleaver_output_packed.bin", encode(config_tuple));
        -- Setup file checker
        read_file(net, output_checker, data_path & "/bit_mapper_output_fixed_point.bin");

      end loop;

    end procedure run_test; -- }} ------------------------------------------------------

  begin

    test_runner_setup(runner, RUNNER_CFG);
    show(display_handler, debug);
    hide(get_logger("file_reader_t(input_data)"), display_handler, debug, True);
    hide(get_logger("file_reader_t(output_checker)"), display_handler, debug, True);
    hide(get_logger("file_reader_t(input_data)"), display_handler, info, True);
    hide(get_logger("file_reader_t(output_checker)"), display_handler, info, True);

    while test_suite loop
      rst                <= '1';
      data_probability   <= 1.0;
      tready_probability <= 1.0;

      walk(32);

      rst <= '0';

      walk(16);

      set_timeout(runner, configs'length * 10 ms);

      if run("back_to_back") then
        data_probability   <= 1.0;
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("data=0.5,slave=1.0") then
        data_probability   <= 0.5;
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("data=1.0,slave=0.5") then
        data_probability   <= 1.0;
        tready_probability <= 0.5;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("data=0.75,slave=0.75") then
        data_probability   <= 0.75;
        tready_probability <= 0.75;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;
      end if;

      wait_for_completion;

      check_equal(axi_slave.tvalid, '0', "axi_slave.tvalid should be '0'");

      walk(32);

    end loop;

    test_runner_cleanup(runner);
    wait;
  end process; -- }}

  axi_slave_tready_gen : process(clk, rst)
    variable tready_rand : RandomPType;
  begin
    if rst then
      tready_rand.InitSeed("axi_slave_tready_gen" & integer'image(SEED) & time'image(now));
    elsif rising_edge(clk) then
      -- Generate a tready enable with the configured probability
      axi_slave.tready <= '0';
      if tready_rand.RandReal(1.0) <= tready_probability then
        axi_slave.tready <= '1';
      end if;
    end if;
  end process;

  tid_check_p : process -- {{ ----------------------------------------------------------
    constant self         : actor_t  := new_actor("tid_check");
    constant logger       : logger_t := get_logger("tid_check");
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
        info(logger, sformat("[%d / %d] Updated expected TID to %r", fo(frame_cnt), fo(word_cnt), fo(expected_tid)));
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
        info(logger, sformat("[%d / %d] Setting first word", fo(frame_cnt), fo(word_cnt)));
        frame_cnt  := frame_cnt + 1;
        word_cnt   := 0;
        first_word := True;
      end if;
    end loop;
  end process; -- }} -------------------------------------------------------------------

end axi_constellation_mapper_tb;
