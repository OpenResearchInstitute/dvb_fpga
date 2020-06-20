-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
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
use fpga_cores_sim.file_utils_pkg.all;
use fpga_cores_sim.testbench_utils_pkg.all;

use work.dvb_sim_utils_pkg.all;
use work.dvb_utils_pkg.all;
use work.ldpc_pkg.all;

-- ghdl translate_off
library modelsim_lib;
use modelsim_lib.util.all;
-- ghdl translate_on

entity axi_ldpc_encoder_tb is
  generic (
    RUNNER_CFG            : string;
    TEST_CFG              : string;
    NUMBER_OF_TEST_FRAMES : integer := 8);
end axi_ldpc_encoder_tb;

architecture axi_ldpc_encoder_tb of axi_ldpc_encoder_tb is

  ---------------
  -- Constants --
  ---------------
  constant configs           : config_array_t := get_test_cfg(TEST_CFG);

  constant DATA_WIDTH        : integer := 8;

  constant LDPC_READER_NAME  : string  := "ldpc_table";
  constant FILE_READER_NAME  : string  := "file_reader";
  constant FILE_CHECKER_NAME : string  := "file_checker";
  constant CLK_PERIOD        : time    := 5 ns;
  constant ERROR_CNT_WIDTH   : integer := 8;

  constant DBG_CHECK_FRAME_RAM_WRITES : boolean := False;

  -------------
  -- Signals --
  -------------
  -- Usual ports
  signal clk                : std_logic := '1';
  signal rst                : std_logic;

  signal m_frame_cnt        : natural := 0;
  signal m_word_cnt         : natural := 0;
  signal m_bit_cnt          : natural := 0;

  signal s_frame_cnt        : natural := 0;
  signal s_word_cnt         : natural := 0;
  signal s_bit_cnt          : natural := 0;

  signal tdata_error_cnt    : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
  signal tlast_error_cnt    : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
  signal error_cnt          : std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);

  signal cfg_constellation  : constellation_t;
  signal cfg_frame_type     : frame_type_t;
  signal cfg_code_rate      : code_rate_t;

  signal data_probability   : real range 0.0 to 1.0 := 1.0;
  signal table_probability  : real range 0.0 to 1.0 := 1.0;
  signal tready_probability : real range 0.0 to 1.0 := 1.0;

  signal axi_ldpc           : axi_stream_data_bus_t(tdata(2*numbits(max(DVB_N_LDPC)) + 8 - 1 downto 0));

  -- AXI input
  signal axi_master         : axi_stream_data_bus_t(tdata(DATA_WIDTH - 1 downto 0));
  -- AXI output
  signal axi_slave          : axi_stream_data_bus_t(tdata(DATA_WIDTH - 1 downto 0));
  signal m_data_valid       : boolean;
  signal s_data_valid       : boolean;

  signal expected_tdata     : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal expected_tlast     : std_logic;

begin

  -------------------
  -- Port mappings --
  -------------------
  dut : entity work.axi_ldpc_encoder
    port map (
      -- Usual ports
      clk               => clk,
      rst               => rst,

      cfg_constellation => cfg_constellation,
      cfg_frame_type    => cfg_frame_type,
      cfg_code_rate     => cfg_code_rate,

      s_ldpc_offset     => axi_ldpc.tdata(numbits(max(DVB_N_LDPC)) - 1 downto 0),
      s_ldpc_tuser      => axi_ldpc.tdata(2*numbits(max(DVB_N_LDPC)) - 1 downto numbits(max(DVB_N_LDPC)) ),
      s_ldpc_next       => axi_ldpc.tdata(2*numbits(max(DVB_N_LDPC))),
      s_ldpc_tvalid     => axi_ldpc.tvalid,
      s_ldpc_tlast      => axi_ldpc.tlast,
      s_ldpc_tready     => axi_ldpc.tready,

      -- AXI input
      s_tvalid          => axi_master.tvalid,
      s_tdata           => axi_master.tdata,
      s_tlast           => axi_master.tlast,
      s_tready          => axi_master.tready,

      -- AXI output
      m_tready          => axi_slave.tready,
      m_tvalid          => axi_slave.tvalid,
      m_tlast           => axi_slave.tlast,
      m_tdata           => axi_slave.tdata);

  -- Read LDPC tables
  axi_table_u : entity fpga_cores_sim.axi_file_reader
    generic map (
      READER_NAME => LDPC_READER_NAME,
      DATA_WIDTH  => axi_ldpc.tdata'length)
    port map (
      -- Usual ports
      clk                => clk,
      rst                => rst,
      -- Config and status
      completed          => open,
      tvalid_probability => table_probability,
      -- AXI stream output
      m_tready           => axi_ldpc.tready,
      m_tdata            => axi_ldpc.tdata,
      m_tvalid           => axi_ldpc.tvalid,
      m_tlast            => axi_ldpc.tlast);

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
      tvalid_probability => data_probability,

      -- Data output
      m_tready           => axi_master.tready,
      m_tdata            => axi_master.tdata,
      m_tvalid           => axi_master.tvalid,
      m_tlast            => axi_master.tlast);

  axi_file_compare_u : entity fpga_cores_sim.axi_file_compare
    generic map (
      READER_NAME     => FILE_CHECKER_NAME,
      ERROR_CNT_WIDTH => ERROR_CNT_WIDTH,
      REPORT_SEVERITY => Error,
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
    constant self         : actor_t := new_actor("main");
    constant logger       : logger_t := get_logger("main");
    constant input_cfg_p  : actor_t := find("input_cfg_p");
    variable ldpc_table   : file_reader_t := new_file_reader(LDPC_READER_NAME);
    variable file_checker : file_reader_t := new_file_reader(FILE_CHECKER_NAME);

    procedure walk(constant steps : natural) is -- {{ ----------------------------------
    begin
      if steps /= 0 then
        for step in 0 to steps - 1 loop
          wait until rising_edge(clk);
        end loop;
      end if;
    end procedure walk; -- }} ----------------------------------------------------------

    procedure run_test ( -- {{ ---------------------------------------------------------
      constant config           : config_t;
      constant number_of_frames : in positive) is
      constant data_path        : string := strip(config.base_path, chars => (1 to 1 => nul));
      variable file_reader_msg  : msg_t;
      variable calc_ldpc_msg    : msg_t;
    begin

      info("Running test with:");
      info(" - constellation  : " & constellation_t'image(config.constellation));
      info(" - frame_type     : " & frame_type_t'image(config.frame_type));
      info(" - code_rate      : " & code_rate_t'image(config.code_rate));
      info(" - data path      : " & data_path);

      for i in 0 to number_of_frames - 1 loop
        debug(logger, "Setting up frame #" & to_string(i));

        -- File reader message
        file_reader_msg := new_msg(sender => self);

        push(file_reader_msg, data_path & "/ldpc_encoder_input.bin");
        push(file_reader_msg, config.constellation);
        push(file_reader_msg, config.frame_type);
        push(file_reader_msg, config.code_rate);

        -- ghdl translate_off
        calc_ldpc_msg := new_msg(sender => self);
        push(calc_ldpc_msg, config);
        send(net, find("calc_ldpc_p"), calc_ldpc_msg);
        -- ghdl translate_on

        send(net, input_cfg_p, file_reader_msg);

        read_file(
          net,
          file_checker,
          data_path & "/bit_interleaver_input.bin",
          "1:8"
        );

        read_file(net, ldpc_table, data_path & "/ldpc_table.bin");

      end loop;

    end procedure run_test; -- }} ------------------------------------------------------

    procedure wait_for_completion is -- {{ ----------------------------------------------
      variable msg : msg_t;
    begin
      receive(net, self, msg);
      wait_all_read(net, file_checker);

      wait until rising_edge(clk) and axi_slave.tvalid = '0' for 1 ms;

      walk(1);

    end procedure wait_for_completion; -- }} --------------------------------------------

  begin

    test_runner_setup(runner, RUNNER_CFG);
    show(display_handler, debug);
    hide(get_logger("file_reader_t(file_reader)"), display_handler, debug, True);
    hide(get_logger("file_reader_t(file_checker)"), display_handler, debug, True);
    hide(get_logger("file_reader_t(ldpc_table)"), display_handler, debug, True);


    while test_suite loop
      rst                <= '1';
      data_probability   <= 1.0;
      table_probability  <= 1.0;
      tready_probability <= 1.0;

      walk(32);

      rst <= '0';

      walk(32);

      set_timeout(runner, configs'length * 10 ms);

      if run("back_to_back") then
        data_probability   <= 1.0;
        table_probability  <= 1.0;
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("data=0.5,table=1.0,slave=1.0") then
        data_probability   <= 0.5;
        table_probability  <= 1.0;
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("data=1.0,table=1.0,slave=0.5") then
        data_probability   <= 1.0;
        table_probability  <= 1.0;
        tready_probability <= 0.5;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("data=0.75,table=1.0,slave=0.75") then
        data_probability   <= 0.75;
        table_probability  <= 1.0;
        tready_probability <= 0.75;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("data=1.0,table=0.5,slave=1.0") then
        data_probability   <= 1.0;
        table_probability  <= 0.5;
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("data=1.0,table=0.75,slave=0.75") then
        data_probability   <= 1.0;
        table_probability  <= 0.75;
        tready_probability <= 0.75;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      elsif run("data=0.8,table=0.8,slave=0.8") then
        data_probability   <= 0.8;
        table_probability  <= 0.8;
        tready_probability <= 0.8;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      end if;

      wait_for_completion;

      check_false(has_message(input_cfg_p));

      check_equal(axi_slave.tvalid, '0', "axi_slave.tvalid should be '0'");
      check_equal(error_cnt, 0);

      walk(32);

    end loop;

    test_runner_cleanup(runner);
    wait;
  end process; -- }}

  -- FIXME: This can me moved to the main process and use axi_stream_bfm's tuser to
  -- transport the config
  input_cfg_p : process -- {{
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
    wait until m_data_valid and axi_master.tlast = '0' and rising_edge(clk);
    cfg_constellation <= not_set;
    cfg_frame_type    <= not_set;
    cfg_code_rate     <= not_set;

    wait until m_data_valid and axi_master.tlast = '1';

    -- When this is received, the file reader has finished reading the file
    wait_file_read(net, file_reader);

    -- If there's no more messages, notify the main process that we're done here
    if not has_message(self) then
      cfg_msg := new_msg;
      push(cfg_msg, True);
      cfg_msg.sender := self;
      send(net, main, cfg_msg);
    end if;
  end process; -- }}

  cnt_p : process -- {{ ----------------------------------------------------------------
  begin
    wait until rst = '0';
    while True loop
      wait until rising_edge(clk);

      if s_data_valid then
        s_word_cnt <= s_word_cnt + 1;
        s_bit_cnt  <= s_bit_cnt + DATA_WIDTH;

        if axi_slave.tlast = '1' then
          info(
            sformat(
              "AXI Slave: received frame %d with %d words (%d bits)",
              fo(s_frame_cnt),
              fo(s_word_cnt),
              fo(s_bit_cnt)
            )
          );

          s_word_cnt  <= 0;
          s_bit_cnt   <= 0;
          s_frame_cnt <= s_frame_cnt + 1;
        end if;
      end if;

      if m_data_valid then
        m_word_cnt <= m_word_cnt + 1;
        m_bit_cnt  <= m_bit_cnt + DATA_WIDTH;

        if axi_master.tlast = '1' then
          m_word_cnt  <= 0;
          m_bit_cnt   <= 0;
          m_frame_cnt <= m_frame_cnt + 1;
        end if;
      end if;
    end loop;
  end process; -- }} -------------------------------------------------------------------

  -- This will only work on ModelSim
  -- ghdl translate_off
  whitebox_monitor : block -- {{ -------------------------------------------------------
    -- White box checking
    type ram_t is array (0 to 4095) of std_logic_vector(15 downto 0);
    signal dut_ram : ram_t;

    signal dut_extracting_codes_from_ram : std_logic;

  begin

    dbg_ldpc_accumulate : process -- {{ ------------------------------------------------
      constant logger           : logger_t := get_logger("dbg_proc_array");
      constant offset_checker_p : actor_t := find("offset_checker_p");
      constant self             : actor_t := new_actor("calc_ldpc_p");
      variable msg              : msg_t;
      variable frame_cnt        : natural := 0;

      procedure check_frame_ram_write ( -- {{ ------------------------------------------
        constant offset_addr : in natural;
        constant data        : in std_logic_vector(15 downto 0)) is
        variable msg         : msg_t := new_msg;
      begin
        if DBG_CHECK_FRAME_RAM_WRITES then
          push(msg, offset_addr);
          push(msg, data);
          send(net, offset_checker_p, msg);
        end if;
      end procedure; -- }} -------------------------------------------------------------

      procedure handle_config ( -- {{ --------------------------------------------------
        constant config : config_t ) is
        constant table  : ldpc_table_t := get_ldpc_table(config.frame_type, config.code_rate);
        variable mem    : std_logic_vector_2d_t((table.length + 15) / 16 - 1 downto 0)(15 downto 0);

        procedure accumulate_ldpc ( -- {{ ----------------------------------------------
          constant table            : in ldpc_table_t) is

          variable rows             : natural := 0;
          variable offset           : natural := 0;
          variable offset_addr      : natural := 0;
          variable offset_bit       : natural := 0;
          variable input_bit_number : natural := 0;
          variable data_index       : natural := 0;
          variable tdata            : std_logic_vector(DATA_WIDTH - 1 downto 0);
          variable data_bit         : std_logic;
          variable is_last          : boolean := False;
          variable max_offset       : natural := 0;
        begin
          debug(logger, "Accumulating LDPC data");

          mem := (others => (others => '0'));

          for line_no in table.data'range loop
            rows := table.data(line_no)(0);

            for group_cnt in 0 to DVB_LDPC_GROUP_LENGTH - 1 loop

              if data_index = 0 then
                wait until rising_edge(clk) and axi_master.tvalid = '1' and axi_master.tready = '1';
                tdata := axi_master.tdata;
                if axi_master.tlast = '1' then
                  is_last := True;
                end if;
              end if;

              data_bit := tdata(DATA_WIDTH - 1 - data_index);

              if data_index = DATA_WIDTH - 1 then
                data_index := 0;
              else
                data_index := data_index + 1;
              end if;

              for row in 1 to rows loop
                offset := (
                  table.data( line_no )( row ) + ( input_bit_number mod DVB_LDPC_GROUP_LENGTH ) * table.q
                ) mod table.length;

                offset_addr := offset / 16;
                offset_bit  := offset mod 16;

                max_offset := max(offset, max_offset);

                mem(offset_addr)(offset_bit) := data_bit xor mem(offset_addr)(offset_bit);

                check_frame_ram_write(offset_addr, mem(offset_addr));

              end loop;

              if is_last and data_index = 0 then
                debug(
                  logger,
                  sformat(
                    "Last line=%d (out of %d), bit count=%d, last offset=%d, data_index=%d, max_offset=%d",
                    fo(line_no),
                    fo(table.data'length - 1),
                    fo(input_bit_number),
                    fo(offset),
                    fo(data_index),
                    fo(max_offset)
                  )
                );

                -- The DUT will clear the addresses when calculating the final parity bits. Just need to make
                -- sure we round to the next integer in the event the max offset is not an integer multiple
                -- of the frame RAM data width
                for i in 0 to ((max_offset + 15) / 16) - 1 loop
                  check_frame_ram_write(i, (others => '0'));
                end loop;

                return;
              end if;

              input_bit_number := input_bit_number + 1;
            end loop;
          end loop;

        end procedure; -- }} ---------------------------------------------------------------

        impure function post_xor ( -- {{ ---------------------------------------------------
          constant data   : std_logic_vector_2d_t)
          return std_logic_vector_2d_t is
          variable result : std_logic_vector_2d_t((table.length + 15 ) /16 - 1 downto 0)(15 downto 0);
          variable addr   : natural;
          variable offset : natural;
        begin

          result := data;

          for i in 1 to table.length - 1 loop
            addr := i / 16;
            offset := i mod 16;

            result(addr)(offset) := result(addr)(offset) xor result((i - 1) / 16)((i - 1) mod 16);

            -- if addr = 0 then
            --   debug(
            --     logger,
            --     sformat(
            --       "result(%d)(%d) := result(%d)(%d) xor result(%d)(%d) ==> " &
            --       "result(%d)(%d) := %r xor %r => %r",
            --       fo(addr), fo(offset),
            --       fo(addr), fo(offset),
            --       fo((i - 1) / 16), fo((i - 1) mod 16),
            --       fo(addr), fo(offset),
            --       fo(result(addr)(offset)), fo(result((i - 1) / 16)((i - 1) mod 16)),
            --       fo(result(addr)(offset))
            --     )
            --   );
            -- end if;

          end loop;
          return result;
        end function; -- }} ----------------------------------------------------------------

        procedure compare_ram is -- {{ -----------------------------------------------------
          variable errors : natural := 0;
        begin
          debug(logger, "Comparing DUT and expected RAM contents");

          for i in 0 to mem'length - 1 loop
          -- for i in 0 to 7 loop
            if to_01(dut_ram(i)) /= to_01(mem(i)) then
              warning(
                logger,
                sformat(
                  "[frame=%d] address=%4d (%r) => expected %r but found %r",
                  fo(frame_cnt),
                  fo(i),
                  fo(to_unsigned(i, numbits(mem'length))),
                  fo(mem(i)),
                  fo(dut_ram(i))
              )
            );
            errors := errors + 1;
            end if;
          end loop;

          if errors = 0 then
            info(logger, "DUT RAM and TB RAM match");
          else
              error(
                logger,
                sformat(
                  "Frame=%d, DUT RAM and TB RAM have %d / %d (%d \%) differences",
                  fo(frame_cnt),
                  fo(errors),
                  fo(mem'length),
                  fo(100*errors / mem'length)
              )
            );
          end if;

        end procedure; -- }} ---------------------------------------------------------------

        variable addr      : natural;

      begin
        info(logger, sformat("Handling config: %s. Table length is %d", to_string(config), fo(table.length)));

        accumulate_ldpc(table);

        wait until rising_edge(clk) and dut_extracting_codes_from_ram = '1';
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);

        -- compare_ram;

        mem := post_xor(mem);

        -- Debug only to show the contents and compare with reference files
        debug(logger, "Post XOR:");
        for addr in 0 to 7 loop
          info(
            logger,
            sformat(
              "%3d | %r  | %b || mirrored: %r | %b",
              fo(addr),
              fo(mem(addr)),
              fo(mem(addr)),
              fo(mirror_bits(mem(addr))),
              fo(mirror_bits(mem(addr)))
            ));
        end loop;


      end procedure; -- }} ---------------------------------------------------------------

    begin

      wait until rst = '0';

      init_signal_spy("/axi_ldpc_encoder_tb/dut/frame_ram_u/ram_u/ram", "/axi_ldpc_encoder_tb/whitebox_monitor/dut_ram", 0);
      init_signal_spy("/axi_ldpc_encoder_tb/dut/frame_addr_rst_p0", "/axi_ldpc_encoder_tb/whitebox_monitor/dut_extracting_codes_from_ram", 0);

      while True loop
        receive(net, self, msg);
        handle_config(pop(msg));
        frame_cnt := frame_cnt + 1;
      end loop;

    end process; -- }} -------------------------------------------------------------------

    frame_ram_monitor : block -- {{ ------------------------------------------------------
      constant logger            : logger_t := get_logger("frame_ram_monitor");
      signal dut_ram_wren        : std_logic;
      signal dut_encoded_wr_last : std_logic;
      signal dut_ram_wraddr      : std_logic_vector(11 downto 0);
      signal dut_ram_wrdata      : std_logic_vector(15 downto 0);

    begin

      signal_spy_p : process
      begin
        wait until rst = '0';
        init_signal_spy("/axi_ldpc_encoder_tb/dut/frame_ram_u/ram_u/wren_a", "dut_ram_wren", 0);
        init_signal_spy("/axi_ldpc_encoder_tb/dut/frame_ram_u/ram_u/addr_a", "dut_ram_wraddr", 0);
        init_signal_spy("/axi_ldpc_encoder_tb/dut/frame_ram_u/ram_u/wrdata_a", "dut_ram_wrdata", 0);
        init_signal_spy("/axi_ldpc_encoder_tb/dut/encoded_wr_last", "dut_encoded_wr_last", 0);
        wait;
      end process;

      -- FIXME: This works on part of the frame and it's highly dependent on the
      -- processing algorithm. Not sure if it's worth making this behave correctly at all
      -- times, assuming that dbg_proc_array above already checks the integrity of the
      -- frame RAM
      check_p : process -- {{ ------------------------------------------------------------
        constant self      : actor_t := new_actor("offset_checker_p");
        variable msg       : msg_t;
        variable exp_addr  : natural;
        variable exp_data  : std_logic_vector(15 downto 0);
        variable frame_cnt : natural := 0;
        variable word_cnt  : natural := 0;
      begin
        wait until rst = '0';

        if DBG_CHECK_FRAME_RAM_WRITES then
          while True loop
            wait until rising_edge(clk) and dut_ram_wren = '1';

            if not has_message(self) then
              error(
                logger,
                sformat(
                  "[frame=%d] Detected RAM wr (addr=%4dd / %r, data=%r) but got nothing to compare to",
                  fo(frame_cnt),
                  fo(dut_ram_wraddr),
                  fo(dut_ram_wraddr),
                  fo(dut_ram_wrdata)
                )
              );
            else
              receive(net, self, msg);

              exp_addr := pop(msg);
              exp_data := pop(msg);

              if unsigned(dut_ram_wraddr) /= exp_addr or dut_ram_wrdata /= exp_data then
                error(
                  logger,
                  sformat(
                    "[frame=%d, word=%3d] Expected write: (addr=%4dd / %r, data=%r), got (addr=%4d / %r, data=%r)",
                    fo(frame_cnt),
                    fo(word_cnt),
                    fo(exp_addr),
                    fo(to_unsigned(exp_addr, 12)),
                    fo(exp_data),
                    fo(dut_ram_wraddr),
                    fo(dut_ram_wraddr),
                    fo(dut_ram_wrdata)
                  )
                );
              end if;

            end if;

            if dut_encoded_wr_last = '0' then
              word_cnt  := word_cnt + 1;
            else
              WARNING("INCREMENTING FRAME CNT");
              word_cnt  := 0;
              frame_cnt := frame_cnt + 1;
            end if;


          end loop;
        end if;
      end process; -- }}

    end block; -- }}

  end block; -- }}
  -- ghdl translate_on

end axi_ldpc_encoder_tb;
