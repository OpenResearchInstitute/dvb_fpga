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

-- use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

library str_format;
use str_format.str_format_pkg.all;

library fpga_cores;
use fpga_cores.axi_pkg.all;
use fpga_cores.common_pkg.all;

library fpga_cores_sim;
context fpga_cores_sim.sim_context;

use work.dvb_sim_utils_pkg.all;
use work.dvb_utils_pkg.all;

entity axi_physical_layer_header_tb is
  generic (
    RUNNER_CFG            : string;
    TEST_CFG              : string;
    NUMBER_OF_TEST_FRAMES : integer := 8;
    SEED                  : integer);
end axi_physical_layer_header_tb;

architecture axi_physical_layer_header_tb of axi_physical_layer_header_tb is

  ---------------
  -- Constants --
  ---------------
  constant configs    : config_array_t := get_test_cfg(TEST_CFG);
  constant CLK_PERIOD : time    := 5 ns;
  constant DATA_WIDTH : integer := 32;

  -------------
  -- Signals --
  -------------
  signal clk             : std_logic := '1';
  signal rst             : std_logic;

  signal axi_master      : axi_stream_data_bus_t(tdata(sum(CONFIG_TUPLE_WIDTHS) - 1 downto 0));
  signal axi_slave       : axi_stream_data_bus_t(tdata(DATA_WIDTH - 1 downto 0));

  signal m_data_valid    : boolean;
  signal s_data_valid    : boolean;


  signal tdata_error_cnt    : std_logic_vector(7 downto 0);
  signal tlast_error_cnt    : std_logic_vector(7 downto 0);
  signal error_cnt          : std_logic_vector(7 downto 0);
  signal tready_probability : real range 0.0 to 1.0;

begin

  -------------------
  -- Port mappings --
  -------------------
  -- AXI stream BFM for the config input
  axi_config_input_u : entity fpga_cores_sim.axi_stream_bfm
    generic map (
      NAME        => "cfg",
      TDATA_WIDTH => sum(CONFIG_TUPLE_WIDTHS),
      SEED        => SEED)
    port map (
      -- Usual ports
      clk      => clk,
      rst      => rst,
      -- AXI stream output
      m_tready => axi_master.tready,
      m_tdata  => axi_master.tdata,
      m_tuser  => open,
      m_tkeep  => open,
      m_tid    => open,
      m_tvalid => axi_master.tvalid,
      m_tlast  => open);

  dut : entity work.axi_physical_layer_header
    generic map (DATA_WIDTH => DATA_WIDTH)
    port map (
      -- Usual ports
      clk             => clk,
      rst             => rst,

      s_constellation => decode(axi_master.tdata).constellation,
      s_frame_type    => decode(axi_master.tdata).frame_type,
      s_code_rate     => decode(axi_master.tdata).code_rate,
      s_pilots        => decode(axi_master.tdata).pilots,

      s_tready        => axi_master.tready,
      s_tvalid        => axi_master.tvalid,

      -- AXI output
      m_tready        => axi_slave.tready,
      m_tvalid        => axi_slave.tvalid,
      m_tdata         => axi_slave.tdata,
      m_tlast         => axi_slave.tlast);

  axi_file_compare_u : entity fpga_cores_sim.axi_file_compare
    generic map (
      READER_NAME     => "axi_file_compare_u",
      ERROR_CNT_WIDTH => 8,
      REPORT_SEVERITY => Error,
      DATA_WIDTH      => axi_slave.tdata'length,
      SEED            => SEED)
    port map (
      -- Usual ports
      clk                => clk,
      rst                => rst,
      -- Config and status
      tdata_error_cnt    => tdata_error_cnt,
      tlast_error_cnt    => tlast_error_cnt,
      error_cnt          => error_cnt,
      tready_probability => 1.0,
      -- Debug stuff
      expected_tdata     => open,
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

  test_runner_watchdog(runner, 2 ms);

  m_data_valid <= axi_master.tvalid = '1' and axi_master.tready = '1';
  s_data_valid <= axi_slave.tvalid = '1' and axi_slave.tready = '1';

  ---------------
  -- Processes --
  ---------------
  main : process -- {{
    constant self        : actor_t          := new_actor("main");
    constant logger      : logger_t         := get_logger("main");
    variable dut         : axi_stream_bfm_t := create_bfm("cfg");
    variable file_reader : file_reader_t    := new_file_reader("axi_file_compare_u");

    procedure walk(constant steps : natural) is -- {{ ----------------------------------
    begin
      if steps /= 0 then
        for step in 0 to steps - 1 loop
          wait until rising_edge(clk);
        end loop;
      end if;
    end procedure walk; -- }} ----------------------------------------------------------

    procedure wait_for_completion is -- {{ ----------------------------------------------
      variable msg : msg_t;
    begin
      join(net, dut);
      wait_all_read(net, file_reader);
      walk(4);
      wait until rising_edge(clk) and axi_slave.tvalid = '0' for 1 ms;
      check_equal(axi_slave.tvalid, '0', "axi_slave.tvalid should be '0'");
      walk(1);
    end procedure wait_for_completion; -- }} --------------------------------------------

    procedure run_test ( -- {{ -----------------------------------------------------------
      constant config           : config_t;
      constant number_of_frames : in positive) is
      constant data_path        : string := strip(config.base_path, chars => (1 to 1 => nul));
      variable file_reader_msg  : msg_t;
      variable calc_ldpc_msg    : msg_t;

      -- GHDL doens't play well with anonymous vectors, so let's be explicit
      subtype bfm_data_t is std_logic_array_t(0 to 0)(ENCODED_CONFIG_WIDTH - 1 downto 0);
      variable config_tuple : config_tuple_t;
    begin

      info("Running test with:");
      info(" - constellation  : " & constellation_t'image(config.constellation));
      info(" - frame_type     : " & frame_type_t'image(config.frame_type));
      info(" - code_rate      : " & code_rate_t'image(config.code_rate));
      info(" - pilots         : " & std_logic'image(config.pilots));
      info(" - data path      : " & data_path);

      config_tuple := (
        code_rate     => config.code_rate,
        constellation => config.constellation,
        frame_type    => config.frame_type,
        pilots        => config.pilots
      );

      for i in 0 to number_of_frames - 1 loop
        debug(logger, "Setting up frame #" & to_string(i));

        axi_bfm_write(net,
          bfm         => dut,
          data        => bfm_data_t'(0 => encode(config_tuple)),
          probability => 1.0,
          blocking    => False);

        if config.pilots then
          read_file(net, file_reader, data_path & "/plframe_header_pilots_on_fixed_point.bin");
        else
          read_file(net, file_reader, data_path & "/plframe_header_pilots_off_fixed_point.bin");
        end if;
      end loop;

      join(net, dut);

    end procedure run_test; -- }} --------------------------------------------------------

  begin

    test_runner_setup(runner, RUNNER_CFG);
    show(display_handler, debug);
    hide(
      logger           => get_logger("axi_stream_bfm_t(cfg)"),
      log_handler      => display_handler,
      log_levels       => (debug, info),
      include_children => True
    );

    while test_suite loop
      rst                <= '1';
      tready_probability <= 1.0;

      walk(32);
      rst <= '0';
      walk(32);

      set_timeout(runner, configs'length * 10 ms);

      if run("back_to_back") then
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("slow_slave") then
        tready_probability <= 0.5;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      end if;

      wait_for_completion;
      check_equal(error_cnt, 0, sformat("Expected 0 errors, got %d", fo(error_cnt)));

      walk(32);

    end loop;

    test_runner_cleanup(runner);
    wait;
  end process; -- }}


  receiver_p : process
    constant logger      : logger_t := get_logger("receiver");
    variable word_cnt    : natural  := 0;
    variable frame_cnt   : natural  := 0;
    variable axi_slave_i : real;
    variable axi_slave_q : real;

    function to_real (
      constant x     : signed) return real is
      constant width : integer := x'length;
    begin
      return real(to_integer(x)) / real(2**(width - 1));
    end;

  begin
    wait until axi_slave.tvalid = '1' and axi_slave.tready = '1' and rising_edge(clk);
    axi_slave_i := to_real(signed(axi_slave.tdata(DATA_WIDTH - 1 downto DATA_WIDTH/2)));
    axi_slave_q := to_real(signed(axi_slave.tdata(DATA_WIDTH/2 - 1 downto 0)));

    -- debug(
    --   logger,
    --   sformat(
    --     "[%d, %d] (%r, %r) = (%d, %d) = (%s, %s)",
    --     fo(frame_cnt),
    --     fo(word_cnt),
    --     fo(signed(axi_slave.tdata(DATA_WIDTH - 1 downto DATA_WIDTH/2))),
    --     fo(signed(axi_slave.tdata(DATA_WIDTH/2 - 1 downto 0))),
    --     fo(signed(axi_slave.tdata(DATA_WIDTH - 1 downto DATA_WIDTH/2))),
    --     fo(signed(axi_slave.tdata(DATA_WIDTH/2 - 1 downto 0))),
    --     real'image(axi_slave_i),
    --     real'image(axi_slave_q)
    --   ));

    word_cnt := word_cnt + 1;
    if axi_slave.tlast = '1' then
      info(logger, sformat("Received frame %d with %d words", fo(frame_cnt), fo(word_cnt)));
      word_cnt  := 0;
      frame_cnt := frame_cnt + 1;
    end if;
  end process;

end axi_physical_layer_header_tb;
