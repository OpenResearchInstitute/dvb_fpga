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
use fpga_cores_sim.axi_stream_bfm_pkg.all;
use fpga_cores_sim.testbench_utils_pkg.all;

use work.dvb_sim_utils_pkg.all;
use work.dvb_utils_pkg.all;
use work.ldpc_pkg.all;

-- ghdl translate_off
library modelsim_lib;
use modelsim_lib.util.all;
-- ghdl translate_on

entity axi_ldpc_table_tb is
  generic (
    RUNNER_CFG            : string;
    TEST_CFG              : string;
    SEED                  : integer;
    NUMBER_OF_TEST_FRAMES : integer := 8);
end axi_ldpc_table_tb;

architecture axi_ldpc_table_tb of axi_ldpc_table_tb is

  ---------------
  -- Constants --
  ---------------
  constant configs           : config_array_t := get_test_cfg(TEST_CFG);

  constant DATA_WIDTH        : integer := 8;

  constant CLK_PERIOD        : time    := 5 ns;

  constant CONFIG_INPUT_WIDTHS: fpga_cores.common_pkg.integer_vector_t := (
    0 => FRAME_TYPE_WIDTH,
    1 => CONSTELLATION_WIDTH,
    2 => CODE_RATE_WIDTH);

  -------------
  -- Signals --
  -------------
  -- Usual ports
  signal clk                : std_logic := '1';
  signal rst                : std_logic;

  signal m_constellation    : constellation_t;
  signal m_frame_type       : frame_type_t;
  signal m_code_rate        : code_rate_t;
  signal m_tvalid           : std_logic;
  signal m_tready           : std_logic;

  signal bfm_tdata          : std_logic_vector(sum(CONFIG_INPUT_WIDTHS) - 1 downto 0);

  signal tready_probability : real range 0.0 to 1.0 := 1.0;

  signal axi_slave          : axi_stream_data_bus_t(tdata(2*numbits(max(DVB_N_LDPC)) - 0 downto 0));

  -- AXI input
  signal axi_master         : axi_stream_data_bus_t(tdata(DATA_WIDTH - 1 downto 0));
  -- AXI output
  signal m_data_valid       : boolean;
  signal s_data_valid       : boolean;

  signal axi_slave_offset   : std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);
  signal axi_slave_next     : std_logic;
  signal axi_slave_tuser    : std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);

begin

  -------------------
  -- Port mappings --
  -------------------
  -- AXI stream BFM for the config input
  axi_config_input_u : entity fpga_cores_sim.axi_stream_bfm
    generic map (
      NAME        => "axi_config_input_u",
      SEED        => SEED,
      TDATA_WIDTH => sum(CONFIG_INPUT_WIDTHS))
    port map (
      -- Usual ports
      clk      => clk,
      rst      => rst,
      -- AXI stream output
      m_tready => m_tready,
      m_tdata  => bfm_tdata,
      m_tuser  => open,
      m_tkeep  => open,
      m_tid    => open,
      m_tvalid => m_tvalid,
      m_tlast  => open);

  m_frame_type    <= decode(get_field(bfm_tdata, 0, CONFIG_INPUT_WIDTHS));
  m_constellation <= decode(get_field(bfm_tdata, 1, CONFIG_INPUT_WIDTHS));
  m_code_rate     <= decode(get_field(bfm_tdata, 2, CONFIG_INPUT_WIDTHS));

  dut : entity work.axi_ldpc_table
    port map (
      -- Usual ports
      clk               => clk,
      rst               => rst,

      s_frame_type    => m_frame_type,
      s_code_rate     => m_code_rate,
      s_tvalid        => m_tvalid,
      s_tready        => m_tready,

      -- AXI output
      m_tready        => axi_slave.tready,
      m_tvalid        => axi_slave.tvalid,
      m_offset        => axi_slave_offset,
      m_tuser         => axi_slave_tuser,
      m_next          => axi_slave_next,
      m_tlast         => axi_slave.tlast);

  axi_slave.tdata <= axi_slave_next & axi_slave_tuser & axi_slave_offset;

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
    constant self             : actor_t          := new_actor("main");
    constant logger           : logger_t         := get_logger("main");
    constant ldpc_table_check : actor_t          := find("ldpc_table_check");
    variable config_bfm       : axi_stream_bfm_t := create_bfm("axi_config_input_u");

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
      join(net, config_bfm);
      while has_message(self) loop
        receive(net, self, msg);
      end loop;
      walk(4);
      wait until rising_edge(clk) and axi_slave.tvalid = '0' for 1 ms;
      check_equal(axi_slave.tvalid, '0', "axi_slave.tvalid should be '0'");
      walk(1);
    end procedure wait_for_completion; -- }} --------------------------------------------

    procedure run_test ( -- {{ -----------------------------------------------------------
      constant config           : config_t;
      constant number_of_frames : in positive) is
      constant data_path        : string := strip(config.base_path, chars => (1 to 1 => nul));
      variable msg              : msg_t;

      -- GHDL doens't play well with anonymous vectors, so let's be explicit
      subtype bfm_data_t is std_logic_array_t(0 to 0)(FRAME_TYPE_WIDTH + CONSTELLATION_WIDTH + CODE_RATE_WIDTH - 1 downto 0);
      constant bfm_data : std_logic_vector := encode(config.code_rate) & encode(config.constellation) & encode(config.frame_type);
    begin

      info("Running test with:");
      info(" - constellation  : " & constellation_t'image(config.constellation));
      info(" - frame_type     : " & frame_type_t'image(config.frame_type));
      info(" - code_rate      : " & code_rate_t'image(config.code_rate));
      info(" - data path      : " & data_path);

      for i in 0 to number_of_frames - 1 loop
        debug(logger, "Setting up frame #" & to_string(i));

        msg := new_msg(sender => self);
        push(msg, data_path & "/ldpc_table.bin");
        send(net, ldpc_table_check, msg);

        axi_bfm_write(net,
          bfm         => config_bfm,
          data        => bfm_data_t'(0 => bfm_data),
          probability => 1.0,
          blocking    => False);
      end loop;

      info(logger, "Waiting for acks..");
      for i in 0 to number_of_frames - 1 loop
        receive(net, self, msg);
        info(logger, sformat("Received ack for frame %d", fo(i)));
      end loop;

    end procedure run_test; -- }} --------------------------------------------------------

  begin

    test_runner_setup(runner, RUNNER_CFG);
    show(display_handler, debug);
    show(get_logger("ldpc_table_check"), display_handler, debug, True);


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

      elsif run("slow_master") then
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("slow_slave") then
        tready_probability <= 0.5;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("slow_master,slow_slave") then
        tready_probability <= 0.75;

        for i in configs'range loop
          for frame in 0 to NUMBER_OF_TEST_FRAMES - 1 loop
            run_test(configs(i), number_of_frames => 1);
            wait_for_completion;
          end loop;
        end loop;
      end if;

      wait_for_completion;
      check_false(has_message(ldpc_table_check));

      walk(32);

    end loop;

    test_runner_cleanup(runner);
    wait;
  end process; -- }}

  ldpc_table_check_p : process -- {{ ---------------------------------------------------
    constant self   : actor_t := new_actor("ldpc_table_check");
    constant logger : logger_t := get_logger("ldpc_table_check");
    variable msg    : msg_t;

    procedure check_filename ( constant path : string ) is
      file file_handler  : text;
      variable lineno    : integer := 0;
      variable L         : line;
      variable fields    : lines_t;
      variable offset    : integer;
      variable is_next   : std_logic;
      variable bit_index : integer;
    begin
      info(logger, sformat("Reading '%s'", path));
      file_open(file_handler, path, read_mode);
      while not endfile(file_handler) loop
        readline(file_handler, L);
        trace(logger, sformat("[%d, %s] %s", fo(lineno), fo(endfile(file_handler)), L.all));
        lineno := lineno + 1;
        if L.all(1) = '#' then
          trace(logger, sformat("Ignoring %s", L.all));
          next;
        end if;

        fields := split(L.all, ",");
        trace(logger, sformat("fields(0).all = '%s'", fields(0).all));
        read(fields.all(0), offset);
        trace(logger, sformat("fields(1).all = '%s'", fields(1).all));
        read(fields.all(1), is_next);
        trace(logger, sformat("fields(2).all = '%s'", fields(2).all));
        read(fields.all(2), bit_index);
        trace(logger, sformat("Expecting offset=%d, is_next=%d, bit_index=%d", fo(offset), fo(is_next), fo(bit_index)));

        wait until axi_slave.tvalid = '1' and axi_slave.tready = '1' and rising_edge(clk);

        if   unsigned(axi_slave_offset) /= offset
          or unsigned(axi_slave_tuser) /= bit_index
          or axi_slave_next /= is_next then
          error(
            logger,
            sformat(
              "Expected (%d, %d, %d), got (%d, %d, %d)",
              fo(offset),
              fo(is_next),
              fo(bit_index),
              fo(axi_slave_offset),
              fo(axi_slave_next),
              fo(axi_slave_tuser)));
        end if;

        if endfile(file_handler) then
          check_equal(axi_slave.tlast, '1', "TLAST error, expected '1' but got '0'");
          exit;
        end if;
      end loop;

      file_close(file_handler);
      info(logger, sformat("Finished reading '%s'", path));
    end procedure;

  begin
    receive(net, self, msg);
    check_filename(pop(msg));
    -- Acknowledge so the sender knows we're done
    acknowledge(net, msg);
  end process; -- }} -------------------------------------------------------------------

  axi_slave_tready_gen : process -- {{ -------------------------------------------------
    variable tready_rand : RandomPType;
  begin
    info("Random seed: " & integer'image(SEED));
    tready_rand.InitSeed(SEED);
    wait until rst = '0';
    while True loop
      wait until rising_edge(clk);
      -- Generate a tready enable with the configured probability
      axi_slave.tready <= '0';
      if tready_rand.RandReal(1.0) <= tready_probability then
        axi_slave.tready <= '1';
      end if;
    end loop;
  end process; -- }} -------------------------------------------------------------------


end axi_ldpc_table_tb;
