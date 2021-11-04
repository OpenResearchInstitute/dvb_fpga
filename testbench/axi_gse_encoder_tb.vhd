--
-- DVB FPGA
--
-- Copyright 2021 by Suoto <andre820@gmail.com>
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
context fpga_cores_sim.sim_context;

use work.dvb_utils_pkg.all;
use work.dvb_sim_utils_pkg.all;

entity axi_gse_encoder_tb is
  generic ( RUNNER_CFG : string );
end axi_gse_encoder_tb;

architecture axi_gse_encoder_tb of axi_gse_encoder_tb is

  ---------------
  -- Constants --
  ---------------
  constant CLK_PERIOD     : time    := 5 ns;
  constant TDATA_WIDTH    : integer := 8;
  constant TKEEP_WIDTH    : integer := (TDATA_WIDTH + 7) / 8;

  constant MAX_PDU_LENGTH : integer := 64 * 1024;
  constant MAX_GSE_LENGTH : integer := 4 * 1024;
  constant GSE_START_HEADER_LEN : integer := 10;
  constant GSE_END_HEADER_LEN : integer := 10;
  constant TID_WIDTH      : integer := numbits(MAX_PDU_LENGTH) + 8;

  subtype axi_t is axi_stream_qualified_data_t(tdata(TDATA_WIDTH - 1 downto 0), tkeep(TKEEP_WIDTH - 1 downto 0), tuser(TID_WIDTH - 1 downto 0));

  -------------
  -- Signals --
  -------------
  shared variable random       : RandomPType;
  -- Usual ports
  signal clk                   : std_logic := '1';
  signal rst                   : std_logic;

  signal tready_probability    : real range 0.0 to 1.0 := 1.0;

  -- AXI input
  signal axi_master            : axi_t;
  signal axi_slave_pdu_length : std_logic_vector(15 downto 0);
  signal m_data_valid          : boolean;

  signal axi_slave             : axi_t;
  signal s_data_valid          : boolean;

begin

  -------------------
  -- Port mappings --
  -------------------
  -- AXI file read
  axi_stream_bfm_u : entity fpga_cores_sim.axi_stream_bfm
    generic map (
      TDATA_WIDTH => TDATA_WIDTH,
      TID_WIDTH   => TID_WIDTH)
    port map (
      -- Usual ports
      clk      => clk,
      rst      => rst,
      -- AXI stream output
      m_tready => axi_master.tready,
      m_tdata  => axi_master.tdata,
      m_tuser  => open,
      m_tkeep  => axi_master.tkeep,
      m_tid    => axi_master.tuser,
      m_tvalid => axi_master.tvalid,
      m_tlast  => axi_master.tlast);

  -- axi_master_pdu_length <= axi_master.tuser(15 downto 0);

  dut : entity work.gse_encoder
    generic map ( DATA_WIDTH => 8)
    port map (
        -- Usual ports
        clk           => clk,
        rst           => rst,

        -- Frame MODCOD configuration -- will take effect once the current baseband frame is
        -- completed
        cfg_frame_type    => FECFRAME_NORMAL,
        cfg_constellation => MOD_QPSK,
        cfg_code_rate     => C1_4,

        -- AXI input
        s_pdu_byte_length => std_logic_vector(to_unsigned(256, 16)),
        s_tvalid          => axi_master.tvalid,
        s_tready          => axi_master.tready,
        s_tdata           => axi_master.tdata,
        s_tlast           => axi_master.tlast,

        -- Read side
        m_constellation   => open,
        m_frame_type      => open,
        m_code_rate       => open,
        m_tvalid          => open,
        m_tready          => '1',
        m_tdata           => open,
        m_tlast           => open);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  --axi_slave.tready <= '1';
  clk <= not clk after CLK_PERIOD/2;

  test_runner_watchdog(runner, 3 ms);

  m_data_valid <= axi_master.tvalid = '1' and axi_master.tready = '1';
  s_data_valid <= axi_slave.tvalid = '1' and axi_slave.tready = '1';

  ---------------
  -- Processes --
  ---------------
  main : process
    constant logger         : logger_t         := get_logger("main");
    constant self           : actor_t          := new_actor("main");
    constant checker        : actor_t          := new_actor("checker");
    variable axi_master_bfm : axi_stream_bfm_t := create_bfm;
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
    impure function generate_frame ( constant length : integer ) return std_logic_array_t is
      variable frame : std_logic_array_t(0 to length - 1)(TDATA_WIDTH - 1 downto 0);
    begin
      for i in 0 to length - 1 loop
        --frame(i) := x"FE"; --random.RandSlv(TDATA_WIDTH);
        frame(i) := random.RandSlv(TDATA_WIDTH);
      end loop;

      return frame;
    end function;

    ------------------------------------------------------------------------------------
    impure function get_expected_output (
      constant data             : std_logic_array_t(open)(TDATA_WIDTH - 1 downto 0)) return std_logic_array_t is
      constant pdu_byte_length  : integer := (data'length * TDATA_WIDTH + 7) / 8;
      constant gse_frame_length : integer :=
        2 + -- sof/eof/00/gse_length
        1 + -- frag id
        2 + -- total length
        2 + -- protocol type
        3 + -- label
        pdu_byte_length; -- +
        --4;  -- CRC

      constant gse_length_field : unsigned(11 downto 0) := to_unsigned(gse_frame_length - 2, 12);
      constant total_length_field : unsigned(15 downto 0) := to_unsigned(pdu_byte_length, 16);

      variable frame : std_logic_array_t(0 to gse_frame_length - 1)(TDATA_WIDTH - 1 downto 0);
      variable gse_length : std_logic_vector(3 downto 0) := std_logic_vector(gse_length_field(11 downto 8));

    begin

      frame(0) := (7 => '1', -- SOF
                   6 => '1', -- EOF
                   5 downto 4 => "11", -- label type
                   3 downto 0 => gse_length);

      frame(1) := std_logic_vector(gse_length_field(7 downto 0));

      frame(2) := x"00"; -- Frag ID
      frame(3) := std_logic_vector(total_length_field(15 downto 8));
      frame(4) := std_logic_vector(total_length_field(7 downto 0));

      frame(5) := (x"08"); -- Protocol type
      frame(6) := (x"00"); -- Protocol type
      frame(7) := (x"00"); -- Label type
      frame(8) := (x"00"); -- Label type
      frame(9) := (x"00"); -- Label type  -- 10 byte header

      info(logger, sformat("data length %s", to_string(pdu_byte_length))); -- 256
      info(logger, sformat("data length1 %s", to_string(data'length)));

      for i in 0 to pdu_byte_length - 1 loop
        --starting reading from 10th byte onwards.
        frame(i + 10) := data(i);
       end loop;

      -- CRC
      --frame(gse_frame_length - 4) := (x"00"); -- 4 byte CRC
      --frame(gse_frame_length - 3) := (x"00");
      --frame(gse_frame_length - 2) := (x"00");
      --frame(gse_frame_length - 1) := (x"00");

      return reinterpret(frame, TDATA_WIDTH);
    end function;

    ------------------------------------------------------------------------------------
    procedure run_test ( constant pdu_length : integer ) is
      constant data       : std_logic_array_t := generate_frame(pdu_length);
      constant expected   : std_logic_array_t := get_expected_output(data);
      variable tid        : std_logic_vector(TID_WIDTH - 1 downto 0);

      variable msg        : msg_t;
      variable received   : std_logic_vector(TDATA_WIDTH downto 0);
    begin
      -- Use TID LSB for the PDU length while the MSB is just random data. Need to unpack
      -- this before going into the DUT
      tid := random.RandSlv(8) & std_logic_vector(to_unsigned(pdu_length, numbits(MAX_PDU_LENGTH)));

      axi_bfm_write(net,
        bfm         => axi_master_bfm,
        data        => data,
        tid         => tid,
        probability => 1.0,
        blocking    => False);
      info(logger, sformat("Input frame: %s", to_string(data)));
      info(logger, sformat("Expected frame: %s", to_string(expected)));
      info(logger, sformat("Expected lenght: %s", to_string(expected'length))); -- 270 = 256 + 10+ 4

      -- we need to check for the header only. PDU can be anything
      -- here we are checking for start header.
      for i in 0 to expected'length - 1  loop -- 0 to 265
        receive(net, self, msg);
        received := pop(msg);
        info(logger, sformat("Received frame: %s", to_string(received)));

        check_equal(received(TDATA_WIDTH - 1 downto 0), expected(i));
        check_equal(received(TDATA_WIDTH), i = expected'length - 1);
        info(logger, sformat("done: %s", to_string(i))); -- 270 = 256 + 10+ 4
      end loop;
      info(logger, sformat("doneee")); -- 270 = 256 + 10+ 4

    end procedure run_test;

    ------------------------------------------------------------------------------------
    procedure wait_for_transfers is
    begin
      -- wait_all_read(net, file_reader);
      -- wait_all_read(net, file_checker);
    end procedure wait_for_transfers;
    ------------------------------------------------------------------------------------
    procedure wait_for_completion is -- {{ ----------------------------------------------
      variable msg : msg_t;
    begin
      --join(net, dut);
      walk(4);
      wait until rising_edge(clk) and axi_slave.tvalid = '0' for 1 ms;
      check_equal(axi_slave.tvalid, '0', "axi_slave.tvalid should be '0'");
      walk(1);
    end procedure wait_for_completion; -- }} --------------------------------------------

  begin

    test_runner_setup(runner, RUNNER_CFG);
    show(display_handler, debug);

    while test_suite loop
      tready_probability <= 0.0;

      rst <= '1';
      walk(4);
      rst <= '0';
      walk(4);

      if run("back_to_back") then
      for i in 0 to 10 loop
        tready_probability <= 1.0;
        run_test(pdu_length => 256);
        wait_for_completion;

        rst <= '1';
        walk(4);
        rst <= '0';
        walk(4);
      end loop;

        --wait_for_transfers;
      end if;

      debug(logger, sformat("Test Complete4"));
      walk(8);
    end loop;

    test_runner_cleanup(runner);
    wait;
  end process;

  checker : process
    constant self        : actor_t := find("checker");
    constant main        : actor_t := find("main");
    constant logger      : logger_t := get_logger("checker");
    variable msg         : msg_t;
    variable word_count  : integer := 0;
    variable frame_count : integer := 0;

  begin

    wait until rst = '0';

    while True loop
      wait until axi_slave.tvalid = '1' and axi_slave.tready = '1' and rising_edge(clk);
      msg := new_msg;
      push(msg, axi_slave.tlast & axi_slave.tdata);
      send(net, main, msg);

      word_count := word_count + 1;

      if axi_slave.tlast = '1' then
        debug(logger, sformat("End of frame %d detected at word %d", fo(frame_count), fo(word_count)));
        frame_count := frame_count + 1;
        word_count  := 0;
      end if;
    end loop;

    wait;
  end process;

  tready_rand : process
  begin
    axi_slave.tready <= '0';
    wait until rst = '0';

    while True loop
      wait until rising_edge(clk);
      if random.RandReal(1.0) < tready_probability then
        axi_slave.tready <= '1';
      else
        axi_slave.tready <= '0';
      end if;
    end loop;
  end process;

end axi_gse_encoder_tb;
