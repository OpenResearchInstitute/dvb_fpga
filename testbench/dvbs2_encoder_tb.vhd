-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
--
-- DVB FPGA
--
-- Copyright 2019 by suoto <andre820@gmail.com>
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

use work.dvb_utils_pkg.all;
use work.dvb_sim_utils_pkg.all;
use work.dvbs2_encoder_regs_pkg.all;

-- ghdl translate_off
library modelsim_lib;
use modelsim_lib.util.all;
-- ghdl translate_on

entity dvbs2_encoder_tb is
  generic (
    RUNNER_CFG            : string;
    TEST_CFG              : string := "";
    NUMBER_OF_TEST_FRAMES : integer := 1);
end dvbs2_encoder_tb;

architecture dvbs2_encoder_tb of dvbs2_encoder_tb is

  ---------------
  -- Constants --
  ---------------
  constant configs    : config_array_t := get_test_cfg(TEST_CFG);
  constant CLK_PERIOD : time := 5 ns;

  constant DATA_WIDTH                   : integer  := 32;
  constant POLYPHASE_FILTER_NUMBER_TAPS : positive := 33;
  constant POLYPHASE_FILTER_RATE_CHANGE : positive := 2;

  type axi_checker_t is record
    axi             : axi_stream_data_bus_t;
    tdata_error_cnt : std_logic_vector(7 downto 0);
    tlast_error_cnt : std_logic_vector(7 downto 0);
    error_cnt       : std_logic_vector(7 downto 0);
    expected_tdata  : std_logic_vector;
    expected_tlast  : std_logic;
  end record;

  type axi_mm_t is record
    --write address channel
    awvalid     : std_logic;
    awready     : std_logic;
    awaddr      : std_logic_vector(31 downto 0);
    -- write data channel
    wvalid      : std_logic;
    wready      : std_logic;
    wdata       : std_logic_vector(31 downto 0);
    wstrb       : std_logic_vector(3 downto 0);
    --read address channel
    arvalid     : std_logic;
    arready     : std_logic;
    araddr      : std_logic_vector(31 downto 0);
    --read data channel
    rvalid      : std_logic;
    rready      : std_logic;
    rdata       : std_logic_vector(31 downto 0);
    rresp       : std_logic_vector(1 downto 0);
    --write response channel
    bvalid      : std_logic;
    bready      : std_logic;
    bresp       : std_logic_vector(1 downto 0);
  end record;

  type axi_stream_qualified_data_t is record
    tdata  : std_logic_vector;
    tkeep  : std_logic_vector;
    tuser  : std_logic_vector;
    tvalid : std_logic;
    tready : std_logic;
    tlast  : std_logic;
  end record;

  -------------
  -- Signals --
  -------------
  signal clk                : std_logic := '1';
  signal rst                : std_logic;

  signal data_probability   : real range 0.0 to 1.0 := 1.0;
  signal tready_probability : real range 0.0 to 1.0 := 1.0;

  signal axi_cfg            : axi_mm_t;

  -- AXI input
  signal cfg_constellation  : constellation_t;
  signal cfg_frame_type     : frame_type_t;
  signal cfg_code_rate      : code_rate_t;

  signal axi_master         : axi_stream_qualified_data_t(tdata(DATA_WIDTH - 1 downto 0),
                                                          tkeep(DATA_WIDTH/8 - 1 downto 0),
                                                          tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
  signal m_data_valid       : std_logic;

  -- AXI output
  signal axi_slave          : axi_stream_data_bus_t(tdata(DATA_WIDTH - 1 downto 0));
  signal axi_slave_tvalid   : std_logic; -- Frame sizes don't match, mask off extra samples from RTL
  signal is_trailing_data   : std_logic := '0';
  signal s_data_valid       : std_logic;

  signal expected_tdata     : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal expected_tlast     : std_logic;

  signal recv_r             : complex;
  signal expected_r         : complex;

begin

  -------------------
  -- Port mappings --
  -------------------
  -- AXI file read
  input_stream_u : entity fpga_cores_sim.axi_file_reader
    generic map (
      READER_NAME => "input_stream",
      DATA_WIDTH  => DATA_WIDTH,
      TID_WIDTH   => ENCODED_CONFIG_WIDTH)
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
      m_tkeep            => axi_master.tkeep,
      m_tid              => axi_master.tuser,
      m_tvalid           => axi_master.tvalid,
      m_tlast            => axi_master.tlast);

  dut : entity work.dvbs2_encoder
    generic map (
      DATA_WIDTH                   => DATA_WIDTH,
      POLYPHASE_FILTER_NUMBER_TAPS => POLYPHASE_FILTER_NUMBER_TAPS,
      POLYPHASE_FILTER_RATE_CHANGE => POLYPHASE_FILTER_RATE_CHANGE)
    port map (
      -- Usual ports
      clk             => clk,
      rst             => rst,

      -- AXI4 lite
      --write address channel
      s_axi_awvalid   => axi_cfg.awvalid,
      s_axi_awready   => axi_cfg.awready,
      s_axi_awaddr    => axi_cfg.awaddr(15 downto 0),
      -- write data channel
      s_axi_wvalid    => axi_cfg.wvalid,
      s_axi_wready    => axi_cfg.wready,
      s_axi_wdata     => axi_cfg.wdata,
      s_axi_wstrb     => axi_cfg.wstrb,
      --read address channel
      s_axi_arvalid   => axi_cfg.arvalid,
      s_axi_arready   => axi_cfg.arready,
      s_axi_araddr    => axi_cfg.araddr(15 downto 0),
      --read data channel
      s_axi_rvalid    => axi_cfg.rvalid,
      s_axi_rready    => axi_cfg.rready,
      s_axi_rdata     => axi_cfg.rdata,
      s_axi_rresp     => axi_cfg.rresp,
      --write response channel
      s_axi_bvalid    => axi_cfg.bvalid,
      s_axi_bready    => axi_cfg.bready,
      s_axi_bresp     => axi_cfg.bresp,

      -- AXI input
      s_constellation => decode(axi_master.tuser).constellation,
      s_frame_type    => decode(axi_master.tuser).frame_type,
      s_code_rate     => decode(axi_master.tuser).code_rate,
      s_tvalid        => axi_master.tvalid,
      s_tdata         => axi_master.tdata,
      s_tkeep         => axi_master.tkeep,
      s_tlast         => axi_master.tlast,
      s_tready        => axi_master.tready,
      -- AXI output
      m_tready        => axi_slave.tready,
      m_tvalid        => axi_slave.tvalid,
      m_tlast         => axi_slave.tlast,
      m_tdata         => axi_slave.tdata);

  output_checker_u : entity work.axi_file_compare_complex
    generic map (
      READER_NAME         => "output_checker",
      DATA_WIDTH          => DATA_WIDTH,
      TOLERANCE           => 64,
      SWAP_BYTE_ENDIANESS => True,
      ERROR_CNT_WIDTH     => 8,
      REPORT_SEVERITY     => Error,
      DUMP_FILE_FORMAT    => "actual_output_%d.csv")  -- Leave empty to disable
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
      s_tvalid           => axi_slave_tvalid,
      s_tlast            => expected_tlast);

  -- DUT AXI tready is always set to high in this sim
  axi_slave.tready <= '1';
  -- GNU Radio's tlast will come in before, we'll ignore data after that until dvbs2_encoder's
  -- tlast
  axi_slave_tvalid <= axi_slave.tvalid and not is_trailing_data;
  process(clk)
    variable words : integer;
  begin
    if rising_edge(clk) then
      if axi_slave.tvalid and axi_slave.tready then
        if is_trailing_data then
          words := words + 1;
        end if;

        if (axi_slave.tlast xor expected_tlast) then
          if axi_slave.tlast then
            is_trailing_data <= '0';
            warning(sformat("tlast mismatch, ignored %d samples", fo(words)));
          end if;
          if expected_tlast then
            is_trailing_data <= '1';
            words            := 0;
          end if;
        end if;
      end if;
    end if;
  end process;

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  clk <= not clk after CLK_PERIOD/2;

  test_runner_watchdog(runner, 300 ms);

  m_data_valid <= axi_master.tvalid and axi_master.tready;
  s_data_valid <= axi_slave.tvalid and axi_slave.tready;

  cfg_constellation <= decode(axi_master.tuser).constellation;
  cfg_frame_type    <= decode(axi_master.tuser).frame_type;
  cfg_code_rate     <= decode(axi_master.tuser).code_rate;

  recv_r     <= to_complex(axi_slave.tdata) when axi_slave_tvalid = '1';
  expected_r <= to_complex(expected_tdata);

  -- Inspect inner buses if running on ModelSim
  -- ghdl translate_off
    signal_spy_block : block -- {{ -------------------------------------------------------
    type file_compare_info_t is record
      tdata_error_cnt : std_logic_vector(7 downto 0);
      tlast_error_cnt : std_logic_vector(7 downto 0);
      error_cnt       : std_logic_vector(7 downto 0);
      expected_tdata  : std_logic_vector;
      expected_tlast  : std_logic;
    end record;

    signal bb_scrambler      : axi_stream_bus_t(tdata(7 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
    signal bch_encoder       : axi_stream_bus_t(tdata(7 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
    signal ldpc_encoder      : axi_stream_bus_t(tdata(7 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));

    signal bb_scrambler_info : file_compare_info_t(expected_tdata(7 downto 0));
    signal bch_encoder_info  : file_compare_info_t(expected_tdata(7 downto 0));
    signal ldpc_encoder_info : file_compare_info_t(expected_tdata(7 downto 0));

    signal pl_frame_expected : axi_stream_data_bus_t(tdata(DATA_WIDTH - 1 downto 0));
    signal pl_frame          : axi_stream_bus_t(tdata(DATA_WIDTH - 1 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));

  begin

    bb_scrambler_checker_u : entity fpga_cores_sim.axi_file_compare
      generic map (
        READER_NAME     => "bb_scrambler",
        ERROR_CNT_WIDTH => 8,
        REPORT_SEVERITY => Error,
        DATA_WIDTH      => 8)
      port map (
        -- Usual ports
        clk                => clk,
        rst                => rst,
        -- Config and status
        tdata_error_cnt    => bb_scrambler_info.tdata_error_cnt,
        tlast_error_cnt    => bb_scrambler_info.tlast_error_cnt,
        error_cnt          => bb_scrambler_info.error_cnt,
        tready_probability => 1.0,
        -- Debug stuff
        expected_tdata     => bb_scrambler_info.expected_tdata,
        expected_tlast     => bb_scrambler_info.expected_tlast,
        -- Data input
        s_tready           => open,
        s_tdata            => bb_scrambler.tdata,
        s_tvalid           => bb_scrambler.tvalid and bb_scrambler.tready,
        s_tlast            => bb_scrambler.tlast);

    bch_encoder_checker_u : entity fpga_cores_sim.axi_file_compare
      generic map (
        READER_NAME     => "bch_encoder",
        ERROR_CNT_WIDTH => 8,
        REPORT_SEVERITY => Error,
        DATA_WIDTH      => 8)
      port map (
        -- Usual ports
        clk                => clk,
        rst                => rst,
        -- Config and status
        tdata_error_cnt    => bch_encoder_info.tdata_error_cnt,
        tlast_error_cnt    => bch_encoder_info.tlast_error_cnt,
        error_cnt          => bch_encoder_info.error_cnt,
        tready_probability => 1.0,
        -- Debug stuff
        expected_tdata     => bch_encoder_info.expected_tdata,
        expected_tlast     => bch_encoder_info.expected_tlast,
        -- Data input
        s_tready           => open,
        s_tdata            => bch_encoder.tdata,
        s_tvalid           => bch_encoder.tvalid and bch_encoder.tready,
        s_tlast            => bch_encoder.tlast);

    ldpc_encoder_checker_u : entity fpga_cores_sim.axi_file_compare
      generic map (
        READER_NAME     => "ldpc_encoder",
        ERROR_CNT_WIDTH => 8,
        REPORT_SEVERITY => Error,
        DATA_WIDTH      => 8)
      port map (
        -- Usual ports
        clk                => clk,
        rst                => rst,
        -- Config and status
        tdata_error_cnt    => ldpc_encoder_info.tdata_error_cnt,
        tlast_error_cnt    => ldpc_encoder_info.tlast_error_cnt,
        error_cnt          => ldpc_encoder_info.error_cnt,
        tready_probability => 1.0,
        -- Debug stuff
        expected_tdata     => ldpc_encoder_info.expected_tdata,
        expected_tlast     => ldpc_encoder_info.expected_tlast,
        -- Data input
        s_tready           => open,
        s_tdata            => ldpc_encoder.tdata,
        s_tvalid           => ldpc_encoder.tvalid and ldpc_encoder.tready,
        s_tlast            => ldpc_encoder.tlast);

    physical_layer_checker_u : entity work.axi_file_compare_complex
      generic map (
        READER_NAME         => "pl_framer_checker",
        DATA_WIDTH          => DATA_WIDTH,
        TOLERANCE           => 1200,
        SWAP_BYTE_ENDIANESS => True,
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
        expected_tdata     => open,
        expected_tlast     => open,
        -- Data input
        s_tready           => pl_frame.tready,
        s_tdata            => pl_frame.tdata,
        s_tvalid           => pl_frame.tvalid,
        s_tlast            => pl_frame.tlast);

    process
      procedure mirror_signal ( constant source, dest : string) is
      begin
        init_signal_spy(source & ".tdata",  dest & ".tdata",   0);
        init_signal_spy(source & ".tid",    dest & ".tuser",   0);
        init_signal_spy(source & ".tvalid", dest & ".tvalid",  0);
        init_signal_spy(source & ".tlast",  dest & ".tlast",   0);
        init_signal_spy(source & ".tready", dest & ".tready",  0);
      end procedure;
    begin
      mirror_signal("/dvbs2_encoder_tb/dut/bb_scrambler", "/dvbs2_encoder_tb/signal_spy_block/bb_scrambler");
      mirror_signal("/dvbs2_encoder_tb/dut/bch_encoder", "/dvbs2_encoder_tb/signal_spy_block/bch_encoder");
      mirror_signal("/dvbs2_encoder_tb/dut/ldpc_encoder", "/dvbs2_encoder_tb/signal_spy_block/ldpc_encoder");
      mirror_signal("/dvbs2_encoder_tb/dut/pl_frame", "/dvbs2_encoder_tb/signal_spy_block/pl_frame");
      wait;
    end process;
  end block signal_spy_block; -- }} ----------------------------------------------------
  -- ghdl translate_on

  ---------------
  -- Processes --
  ---------------
  main : process -- {{ -----------------------------------------------------------------
    constant self                 : actor_t       := new_actor("main");
    constant logger               : logger_t      := get_logger("main");
    variable input_stream         : file_reader_t := new_file_reader("input_stream");
    variable output_checker       : file_reader_t := new_file_reader("output_checker");

      -- ghdl translate_off
    variable bb_scrambler_checker : file_reader_t := new_file_reader("bb_scrambler");
    variable bch_encoder_checker  : file_reader_t := new_file_reader("bch_encoder");
    variable ldpc_encoder_checker : file_reader_t := new_file_reader("ldpc_encoder");
    variable pl_framer_checker    : file_reader_t := new_file_reader("pl_framer_checker");
      -- ghdl translate_on

    procedure walk(constant steps : natural) is -- {{ ----------------------------------
    begin
      if steps /= 0 then
        for step in 0 to steps - 1 loop
          wait until rising_edge(clk);
        end loop;
      end if;
    end procedure walk; -- }} ----------------------------------------------------------

    procedure axi_cfg_write (
      constant addr      : unsigned(axi_cfg.awaddr'range);
      constant data      : std_logic_vector(axi_cfg.wdata'range)) is
      variable addr_ack  : boolean := False;
      variable data_ack  : boolean := False;
      variable resp_recv : boolean := False;
    begin
      info(logger, sformat("axi_cfg_write: %r, %r", fo(addr), fo(data)));
      axi_cfg.awvalid <= '1';
      axi_cfg.awaddr  <= std_logic_vector(addr);

      axi_cfg.wvalid  <= '1';
      axi_cfg.wdata   <= data;
      axi_cfg.wstrb   <= (others => '1');

      axi_cfg.bready  <= '1';

      while True loop
        wait until rising_edge(clk);

        if (axi_cfg.awvalid = '1' and axi_cfg.awready = '1') then
          addr_ack        := True;
          axi_cfg.awvalid <= '0';
          axi_cfg.awaddr  <= (others => 'U');
        end if;

        if (axi_cfg.wvalid = '1' and axi_cfg.wready = '1') then
          data_ack       := True;
          axi_cfg.wvalid <= '0';
          axi_cfg.wdata  <= (others => 'U');
          axi_cfg.wstrb  <= (others => 'U');
        end if;

        if (axi_cfg.bvalid = '1' and axi_cfg.bready = '1') then
          resp_recv      := True;
          axi_cfg.bready <= '0';
          check_equal(axi_cfg.bresp, std_logic_vector'("00"), sformat("Expected AXI BRESP OK, got %b", fo(axi_cfg.bresp)));
        end if;

        if addr_ack and data_ack and resp_recv then
          exit;
        end if;

      end loop;
    end procedure;

    procedure axi_cfg_read (
      constant addr      : unsigned(axi_cfg.araddr'range);
      variable data      : out std_logic_vector(axi_cfg.rdata'range)) is
      variable addr_ack  : boolean := False;
      variable data_recv : boolean := False;
    begin
      info(logger, sformat("axi_cfg_read: %r", fo(addr)));
      axi_cfg.arvalid <= '1';
      axi_cfg.araddr  <= std_logic_vector(addr);

      axi_cfg.rready <= '1';

      while True loop
        wait until rising_edge(clk);

        if (axi_cfg.arvalid = '1' and axi_cfg.arready = '1') then
          addr_ack        := True;
          axi_cfg.arvalid <= '0';
          axi_cfg.araddr  <= (others => 'U');
        end if;

        if (axi_cfg.rvalid = '1' and axi_cfg.rready = '1') then
          data_recv      := True;
          axi_cfg.rready <= '0';
          data           := axi_cfg.rdata;
        end if;

        if addr_ack and data_recv then
          exit;
        end if;

      end loop;
    end procedure;

    procedure wait_for_completion is -- {{ ---------------------------------------------
      variable msg : msg_t;
      variable data : std_logic_vector(31 downto 0);
    begin

      info(logger, "Waiting for BFMs to complete");
      wait_all_read(net, input_stream);
      wait_all_read(net, output_checker);
      -- ghdl translate_off
      wait_all_read(net, bb_scrambler_checker);
      wait_all_read(net, bch_encoder_checker);
      wait_all_read(net, ldpc_encoder_checker);
      wait_all_read(net, pl_framer_checker);
      -- ghdl translate_on
      wait until rising_edge(clk) and axi_slave.tvalid = '0' for 1 ms;
      walk(1);
      info(logger, "All BFMs have now completed");
    end procedure wait_for_completion; -- }} -------------------------------------------

    procedure write_ram ( -- {{ --------------------------------------------------------
      constant addr : in integer;
      constant data : in std_logic_vector(DATA_WIDTH - 1 downto 0)) is
    begin
      axi_cfg_write(BIT_MAPPER_RAM_OFFSET + 4*addr, data);
    end procedure; -- }} ---------------------------------------------------------------

    -- Write the exact value so we know data was picked up correctly without having to
    -- convert into IQ
    variable current_mapping_ram : std_logic_array_t(0 to 63)(DATA_WIDTH - 1 downto 0);
    procedure update_mapping_ram_if_needed ( -- {{ -----------------------------------------------
      constant initial_addr : integer;
      constant path         : string) is
      file file_handler     : text;
      variable L            : line;
      variable map_i, map_q : real;
      variable addr         : integer := initial_addr;
      variable index        : unsigned(5 downto 0) := (others => '0');
      variable mapping_ram  : std_logic_array_t(0 to 63)(DATA_WIDTH - 1 downto 0) := current_mapping_ram;
    begin
      file_open(file_handler, path, read_mode);
      while not endfile(file_handler) loop
        readline(file_handler, L);
        read(L, map_i);
        readline(file_handler, L);
        read(L, map_q);
        trace(
          logger,
          sformat(
            "[%b] Writing RAM: %2d => (%13s, %13s) => %13s (%r) / %13s (%r)",
            fo(index),
            fo(addr),
            real'image(map_i),
            real'image(map_q),
            real'image(map_i),
            fo(to_fixed_point(map_i, DATA_WIDTH/2)),
            real'image(map_q),
            fo(to_fixed_point(map_q, DATA_WIDTH/2))
          )
        );

        mapping_ram(addr) := std_logic_vector(to_fixed_point(map_i, DATA_WIDTH/2)) &
                             std_logic_vector(to_fixed_point(map_q, DATA_WIDTH/2));

        addr := addr + 1;
        index := index + 1;
      end loop;
      file_close(file_handler);
      if index = 0 then
        failure(logger, "Failed to update RAM from file");
      end if;

      -- Only update if the tables are different
      if current_mapping_ram = mapping_ram then
        return;
      end if;

      wait_for_completion;
      info(logger, sformat("Updating mapping RAM from '%s' (initial address is %d)", fo(path), fo(initial_addr)));

      for i in mapping_ram'range loop
        -- Only update entries that changed
        if current_mapping_ram(i) /= mapping_ram(i) then
          write_ram(i, mapping_ram(i));
        end if;
      end loop;

      current_mapping_ram := mapping_ram;
    end procedure; -- }} ---------------------------------------------------------------

    variable current_coefficients : real_vector(0 to POLYPHASE_FILTER_NUMBER_TAPS - 1);
    procedure update_coefficients ( constant path : string ) is -- {{ ------------------
      file file_handler     : text;
      variable L            : line;
      variable addr         : integer := 0;
      variable value        : real;
      variable coefficients : real_vector(0 to POLYPHASE_FILTER_NUMBER_TAPS - 1) := current_coefficients;
    begin
      file_open(file_handler, path, read_mode);
      while not endfile(file_handler) loop
        readline(file_handler, L);
        read(L, value);
        trace(logger, sformat("Coefficient %3d: %r => %r", fo(addr), real'image(value), fo(to_fixed_point(value, DATA_WIDTH/2))));
        coefficients(addr) := value;
        addr := addr + 1;
      end loop;

      if current_coefficients = coefficients then
        return;
      end if;

      wait_for_completion;
      info(logger, sformat("Updating polyphase coefficients from '%s'", fo(path)));

      for i in coefficients'range loop
        if current_coefficients(i) /= coefficients(i) then
          axi_cfg_write(
            POLYPHASE_FILTER_COEFFICIENTS_OFFSET + 4*i, 
            std_logic_vector(to_fixed_point(coefficients(i), DATA_WIDTH/2)) &
            std_logic_vector(to_fixed_point(coefficients(i), DATA_WIDTH/2))
          );
        end if;
      end loop;
      current_coefficients := coefficients;
    end procedure; -- }} ---------------------------------------------------------------

    procedure run_test ( -- {{ ---------------------------------------------------------
      constant config           : config_t;
      constant number_of_frames : in positive) is
      variable file_reader_msg  : msg_t;
      constant data_path        : string := strip(config.base_path, chars => (1 to 1 => nul));
      variable initial_addr     : integer := 0;
      variable data             : std_logic_vector(31 downto 0);
      constant config_tuple     : config_tuple_t := (code_rate => config.code_rate,
                                                     constellation => config.constellation,
                                                     frame_type => config.frame_type);
    begin

      info(logger, "Running test with:");
      info(logger, " - constellation  : " & constellation_t'image(config.constellation));
      info(logger, " - frame_type     : " & frame_type_t'image(config.frame_type));
      info(logger, " - code_rate      : " & code_rate_t'image(config.code_rate));
      info(logger, " - data path      : " & data_path);

      update_coefficients(data_path & "/polyphase_coefficients.bin");

      -- Only update the mapping RAM if the config actually requires that
      case config.constellation is
        when mod_qpsk => initial_addr := 0;
        when mod_8psk => initial_addr := 4;
        when mod_16apsk => initial_addr := 12;
        when mod_32apsk => initial_addr := 28;
        when others => null;
      end case;
      update_mapping_ram_if_needed(initial_addr, data_path & "/modulation_table.bin");

      for i in 0 to number_of_frames - 1 loop
        file_reader_msg        := new_msg;
        file_reader_msg.sender := self;

        read_file(net, input_stream, data_path & "/bb_header_output_packed.bin", encode(config_tuple));
        read_file(net, output_checker, data_path & "/modulated_pilots_off_fixed_point.bin");

        -- ghdl translate_off
        read_file(net, bb_scrambler_checker, data_path & "/bb_scrambler_output_packed.bin");
        read_file(net, bch_encoder_checker, data_path & "/bch_encoder_output_packed.bin");
        read_file(net, ldpc_encoder_checker, data_path & "/ldpc_output_packed.bin");
        read_file(net, pl_framer_checker, data_path & "/plframe_pilots_off_fixed_point.bin");
        -- ghdl translate_on
      end loop;
      wait_for_completion;
    end procedure run_test; -- }} ------------------------------------------------------

  begin

    test_runner_setup(runner, RUNNER_CFG);
    show(display_handler, debug);

    axi_cfg.awvalid <= '0';
    axi_cfg.arvalid <= '0';
    axi_cfg.wvalid  <= '0';
    axi_cfg.bready  <= '0';
    axi_cfg.rready  <= '0';

    while test_suite loop
      rst <= '1';
      walk(4);
      rst <= '0';
      walk(4);

      data_probability <= 1.0;
      tready_probability <= 1.0;

      if run("back_to_back") then
        data_probability <= 1.0;
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;
      end if;

      walk(32);
    end loop;

    test_runner_cleanup(runner);
    wait;
  end process; -- }} -------------------------------------------------------------------

end dvbs2_encoder_tb;
