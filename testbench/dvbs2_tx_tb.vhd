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
use work.dvbs2_tx_wrapper_regmap_regs_pkg.all;

-- ghdl translate_off
library modelsim_lib;
use modelsim_lib.util.all;
-- ghdl translate_on

entity dvbs2_tx_tb is
  generic (
    RUNNER_CFG            : string;
    TEST_CFG              : string := "";
    NUMBER_OF_TEST_FRAMES : integer := 1);
end dvbs2_tx_tb;

architecture dvbs2_tx_tb of dvbs2_tx_tb is

  ---------------
  -- Constants --
  ---------------
  constant configs    : config_array_t := get_test_cfg(TEST_CFG);
  constant CLK_PERIOD : time := 5 ns;


--   constant COEFFS : std_logic_array_t := (
--   x"FFFF", x"FFFB", x"0005", x"0001", x"FFF9", x"0002", x"0006", x"FFFA" ,
-- x"FFFE", x"0008", x"FFFE", x"FFF9", x"0007", x"0002", x"FFF6", x"0003" ,
-- x"0009", x"FFF7", x"FFFC", x"000C", x"FFFD", x"FFF6", x"000B", x"0003" ,
-- x"FFF0", x"0006", x"000F", x"FFF0", x"FFF9", x"0015", x"FFFB", x"FFEE" ,
-- x"0013", x"0006", x"FFE3", x"000C", x"001C", x"FFE1", x"FFF1", x"002A" ,
-- x"FFF7", x"FFDB", x"0028", x"000B", x"FFBE", x"001F", x"0049", x"FFAE" ,
-- x"FFD1", x"0077", x"FFED", x"FF91", x"0081", x"0015", x"FEEA", x"00C7" ,
-- x"01C0", x"FD93", x"FD96", x"056E", x"02FB", x"F42E", x"FCA3", x"2823" ,
-- x"4381", x"2823", x"FCA3", x"F42E", x"02FB", x"056E", x"FD96", x"FD93" ,
-- x"01C0", x"00C7", x"FEEA", x"0015", x"0081", x"FF91", x"FFED", x"0077" ,
-- x"FFD1", x"FFAE", x"0049", x"001F", x"FFBE", x"000B", x"0028", x"FFDB" ,
-- x"FFF7", x"002A", x"FFF1", x"FFE1", x"001C", x"000C", x"FFE3", x"0006" ,
-- x"0013", x"FFEE", x"FFFB", x"0015", x"FFF9", x"FFF0", x"000F", x"0006" ,
-- x"FFF0", x"0003", x"000B", x"FFF6", x"FFFD", x"000C", x"FFFC", x"FFF7" ,
-- x"0009", x"0003", x"FFF6", x"0002", x"0007", x"FFF9", x"FFFE", x"0008" ,
-- x"FFFE", x"FFFA", x"0006", x"0002", x"FFF9", x"0001", x"0005", x"FFFB");

--   constant COEFFS : std_logic_array_t := (
--   x"FFAE", x"FFE1", x"0057", x"0086", x"0018", x"FF7A", x"FF86", x"007E" ,
-- x"015B", x"007E", x"FD9B", x"FAFE", x"FC9D", x"0502", x"127B", x"1F20" ,
-- x"244E", x"1F20", x"127B", x"0502", x"FC9D", x"FAFE", x"FD9B", x"007E" ,
-- x"015B", x"007E", x"FF86", x"FF7A", x"0018", x"0086", x"0057", x"FFE1" );

--   constant COEFFS : std_logic_array_t := (
--   x"FFEC", x"0000", x"001A", x"FFFF", x"FFDC", x"0001", x"0034", x"FFFD" ,
-- x"FFAF", x"0007", x"0091", x"FFEB", x"FEB5", x"0063", x"056E", x"F26C" ,
-- x"9178", x"F26C", x"056E", x"0063", x"FEB5", x"FFEB", x"0091", x"0007" ,
-- x"FFAF", x"FFFD", x"0034", x"0001", x"FFDC", x"FFFF", x"001A", x"0000");

  constant COEFFS : std_logic_array_t  := (
    x"FFE8", x"003B", x"FFF6", x"FFC8", x"0040", x"000A", x"FF75", x"0063",
    x"00DF", x"FEC9", x"FECB", x"02B6", x"017D", x"FA18", x"FE52", x"140B",
    x"21B5", x"140B", x"FE52", x"FA18", x"017D", x"02B6", x"FECB", x"FEC9",
    x"00DF", x"0063", x"FF75", x"000A", x"0040", x"FFC8", x"FFF6", x"003B",
    x"FFE8");

-- x"FFD8", x"0023", x"0003", x"FFD8", x"0048", x"FFBD", x"FFF6", x"0051" ,
-- x"FF5B", x"00AF", x"0031", x"FF0B", x"02B7", x"FB34", x"F937", x"2505" ,
-- x"48B8", x"2505", x"F937", x"FB34", x"02B7", x"FF0B", x"0031", x"00AF" ,
-- x"FF5B", x"0051", x"FFF6", x"FFBD", x"0048", x"FFD8", x"0003", x"0023");


  constant DATA_WIDTH : integer := 32;

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
  signal s_data_valid       : std_logic;

  signal axi_slave          : axi_checker_t(axi(tdata(DATA_WIDTH - 1 downto 0)), expected_tdata(DATA_WIDTH - 1 downto 0));
  signal axi_slave_tdata    : std_logic_vector(DATA_WIDTH - 1 downto 0);


  signal dbg_recv           : complex;
  signal dbg_expected       : complex;

  signal dbg_expected_i : signed(15 downto 0);
  signal dbg_expected_q : signed(15 downto 0);
  signal dbg_input_i    : signed(15 downto 0);
  signal dbg_input_q    : signed(15 downto 0);
  signal dbg_recv_i     : signed(15 downto 0);
  signal dbg_recv_q     : signed(15 downto 0);

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

  dut : entity work.dvbs2_tx
    generic map ( DATA_WIDTH => DATA_WIDTH )
    port map (
      -- Usual ports
      clk               => clk,
      rst               => rst,

      -- AXI4 lite
      --write address channel
      s_axi_awvalid     => axi_cfg.awvalid,
      s_axi_awready     => axi_cfg.awready,
      s_axi_awaddr      => axi_cfg.awaddr,
      -- write data channel
      s_axi_wvalid      => axi_cfg.wvalid,
      s_axi_wready      => axi_cfg.wready,
      s_axi_wdata       => axi_cfg.wdata,
      s_axi_wstrb       => axi_cfg.wstrb,
      --read address channel
      s_axi_arvalid     => axi_cfg.arvalid,
      s_axi_arready     => axi_cfg.arready,
      s_axi_araddr      => axi_cfg.araddr,
      --read data channel
      s_axi_rvalid      => axi_cfg.rvalid,
      s_axi_rready      => axi_cfg.rready,
      s_axi_rdata       => axi_cfg.rdata,
      s_axi_rresp       => axi_cfg.rresp,
      --write response channel
      s_axi_bvalid      => axi_cfg.bvalid,
      s_axi_bready      => axi_cfg.bready,
      s_axi_bresp       => axi_cfg.bresp,

      -- AXI input
      cfg_constellation => encode(cfg_constellation),
      cfg_frame_type    => encode(cfg_frame_type),
      cfg_code_rate     => encode(cfg_code_rate),
      s_tvalid          => axi_master.tvalid,
      s_tdata           => axi_master.tdata,
      s_tkeep           => axi_master.tkeep,
      s_tlast           => axi_master.tlast,
      s_tready          => axi_master.tready,
      -- AXI output
      m_tready          => axi_slave.axi.tready,
      m_tvalid          => axi_slave.axi.tvalid,
      m_tlast           => axi_slave.axi.tlast,
      m_tdata           => axi_slave.axi.tdata);

  -- Can't check against expected data directly because of rounding errors, so use a file
  -- reader to get the contents
  output_ref_data_u : entity fpga_cores_sim.axi_file_reader
    generic map (
      READER_NAME => "output_ref",
      DATA_WIDTH  => DATA_WIDTH)
    port map (
      -- Usual ports
      clk                => clk,
      rst                => rst,
      -- Config and status
      completed          => open,
      tvalid_probability => 1.0,
      -- Data output
      m_tready           => axi_slave.axi.tready and axi_slave.axi.tvalid,
      m_tdata            => axi_slave.expected_tdata,
      -- m_tid              => axi_slave.axi.tuser,
      m_tvalid           => open,
      m_tlast            => open);

  axi_slave.axi.tready <= '1';

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  clk <= not clk after CLK_PERIOD/2;

  test_runner_watchdog(runner, 300 ms);

  m_data_valid <= axi_master.tvalid and axi_master.tready;
  s_data_valid <= axi_slave.axi.tvalid and axi_slave.axi.tready;

  axi_slave_tdata <= axi_slave.axi.tdata(23 downto 16) & axi_slave.axi.tdata(31 downto 24) & axi_slave.axi.tdata(7 downto 0) & axi_slave.axi.tdata(15 downto 8);

  cfg_constellation <= decode(axi_master.tuser).constellation;
  cfg_frame_type    <= decode(axi_master.tuser).frame_type;
  cfg_code_rate     <= decode(axi_master.tuser).code_rate;

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

    signal pl_frame          : axi_stream_bus_t(tdata(DATA_WIDTH - 1 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));

    -- signal constellation_mapper      : axi_stream_bus_t(tdata(DATA_WIDTH - 1 downto 0), tuser(ENCODED_CONFIG_WIDTH - 1 downto 0));
    -- signal constellation_mapper_info : file_compare_info_t(expected_tdata(DATA_WIDTH  - 1 downto 0));

  begin

    -- dbg_input_i   <= signed(pl_frame.tdata(23 downto 16)) & signed(pl_frame.tdata(31 downto 24));
    -- dbg_input_q   <= signed(pl_frame.tdata(7 downto 0)) & signed(pl_frame.tdata(15 downto 8));
    dbg_input_i   <= signed(pl_frame.tdata(31 downto 16));
    dbg_input_q   <= signed(pl_frame.tdata(15 downto 0));

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

    -- FIXME: Removing for now as the file has different endianess, which requires us to
    -- make the checking outside. Need to find a way to properly fix this
    -- constellation_mapper_checker_u : entity fpga_cores_sim.axi_file_compare -- {{
    --   generic map (
    --     READER_NAME     => "constellation_mapper",
    --     ERROR_CNT_WIDTH => 8,
    --     REPORT_SEVERITY => Error,
    --     DATA_WIDTH      => DATA_WIDTH)
    --   port map (
    --     -- Usual ports
    --     clk                => clk,
    --     rst                => rst,
    --     -- Config and status
    --     tdata_error_cnt    => constellation_mapper_info.tdata_error_cnt,
    --     tlast_error_cnt    => constellation_mapper_info.tlast_error_cnt,
    --     error_cnt          => constellation_mapper_info.error_cnt,
    --     tready_probability => 1.0,
    --     -- Debug stuff
    --     expected_tdata     => constellation_mapper_info.expected_tdata,
    --     expected_tlast     => constellation_mapper_info.expected_tlast,
    --     -- Data input
    --     s_tready           => open,
    --     s_tdata            => constellation_mapper_info.axi.tdata,
    --     s_tvalid           => constellation_mapper_info.axi.tvalid and constellation_mapper_info.axi.tready,
    --     s_tlast            => constellation_mapper_info.axi.tlast); -- }}

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
      mirror_signal("/dvbs2_tx_tb/dut/bb_scrambler", "/dvbs2_tx_tb/signal_spy_block/bb_scrambler");
      mirror_signal("/dvbs2_tx_tb/dut/bch_encoder",  "/dvbs2_tx_tb/signal_spy_block/bch_encoder");
      mirror_signal("/dvbs2_tx_tb/dut/ldpc_encoder", "/dvbs2_tx_tb/signal_spy_block/ldpc_encoder");
      -- mirror_signal("/dvbs2_tx_tb/dut/pl_frame",     "/dvbs2_tx_tb/signal_spy_block/pl_frame");
      -- init_signal_spy("/dvbs2_tx_tb/dut/constellation_mapper",  "/dvbs2_tx_tb/signal_spy_block/constellation_mapper",  0);
      wait;
    end process;
  end block signal_spy_block; -- }} ----------------------------------------------------
  -- ghdl translate_on

  ---------------
  -- Processes --
  ---------------
  main : process -- {{ -----------------------------------------------------------------
    constant self                 : actor_t       := new_actor("main");
    variable input_stream         : file_reader_t := new_file_reader("input_stream");
    variable output_ref           : file_reader_t := new_file_reader("output_ref");

      -- ghdl translate_off
    variable bb_scrambler_checker : file_reader_t := new_file_reader("bb_scrambler");
    variable bch_encoder_checker  : file_reader_t := new_file_reader("bch_encoder");
    variable ldpc_encoder_checker : file_reader_t := new_file_reader("ldpc_encoder");
      -- ghdl translate_on

    variable prev_config          : config_t;

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
      info("Waiting for test completion");
      wait_all_read(net, input_stream);
      wait_all_read(net, output_ref);
      -- ghdl translate_off
      wait_all_read(net, bb_scrambler_checker);
      wait_all_read(net, bch_encoder_checker);
      wait_all_read(net, ldpc_encoder_checker);
      -- ghdl translate_on

      wait until rising_edge(clk) and axi_slave.axi.tvalid = '0' for 1 ms;

      walk(1);
    end procedure wait_for_completion; -- }} -------------------------------------------

    procedure axi_cfg_write (
      constant addr      : unsigned(axi_cfg.awaddr'range);
      constant data      : std_logic_vector(axi_cfg.wdata'range)) is
      variable addr_ack  : boolean := False;
      variable data_ack  : boolean := False;
      variable resp_recv : boolean := False;
    begin
      info(sformat("axi_cfg_write: %r, %r", fo(addr), fo(data)));
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

    procedure write_ram ( -- {{ --------------------------------------------------------
      constant addr : in integer;
      constant data : in std_logic_vector(DATA_WIDTH - 1 downto 0)) is
    begin
      axi_cfg_write(BIT_MAPPER_RAM_OFFSET + 4*addr, data);
    end procedure; -- }} ---------------------------------------------------------------

    -- Write the exact value so we know data was picked up correctly without having to
    -- convert into IQ
    procedure update_mapping_ram ( -- {{ -----------------------------------------------
      constant initial_addr : integer;
      constant path         : string) is
      file file_handler     : text;
      variable L            : line;
      variable r0, r1       : real;
      variable addr         : integer := initial_addr;
      variable index        : unsigned(5 downto 0) := (others => '0');
    begin
      info(sformat("Updating mapping RAM from '%s' (initial address is %d)", fo(path), fo(initial_addr)));

      file_open(file_handler, path, read_mode);
      while not endfile(file_handler) loop
        readline(file_handler, L);
        read(L, r0);
        readline(file_handler, L);
        read(L, r1);
        info(
          sformat(
            "[%b] Writing RAM: %2d => %13s (%r) / %13s (%r)",
            fo(index),
            fo(addr),
            real'image(r0),
            fo(to_fixed_point(r0, DATA_WIDTH/2)),
            real'image(r1),
            fo(to_fixed_point(r1, DATA_WIDTH/2))
          )
        );

        write_ram(
          addr,
          std_logic_vector(to_fixed_point(r0, DATA_WIDTH/2)) &
          std_logic_vector(to_fixed_point(r1, DATA_WIDTH/2))
        );
        addr := addr + 1;
        index := index + 1;
      end loop;
      file_close(file_handler);
    end procedure; -- }} ---------------------------------------------------------------

    procedure update_coefficients ( constant c : std_logic_array_t ) is
    begin
      info("Updating polyphase filter coefficients with " & to_string(c));

      for i in c'range loop
        axi_cfg_write(POLYPHASE_FILTER_COEFFICIENTS_OFFSET + 4*i, c(i) & c(i));
      end loop;
    end procedure;

    procedure run_test ( -- {{ ---------------------------------------------------------
      constant config           : config_t;
      constant number_of_frames : in positive) is
      variable file_reader_msg  : msg_t;
      constant data_path        : string := strip(config.base_path, chars => (1 to 1 => nul));
      variable initial_addr     : integer := 0;
      constant config_tuple     : config_tuple_t := (code_rate => config.code_rate,
                                                     constellation => config.constellation,
                                                     frame_type => config.frame_type);
    begin

      info("Running test with:");
      info(" - constellation  : " & constellation_t'image(config.constellation));
      info(" - frame_type     : " & frame_type_t'image(config.frame_type));
      info(" - code_rate      : " & code_rate_t'image(config.code_rate));
      info(" - data path      : " & data_path);

      -- Only update the mapping RAM if the config actually requires that
      if config /= prev_config then
        wait_for_completion;
        case config.constellation is
          when mod_qpsk => initial_addr := 0;
          when mod_8psk => initial_addr := 4;
          when mod_16apsk => initial_addr := 12;
          when mod_32apsk => initial_addr := 28;
          when others => null;
        end case;
        update_mapping_ram(initial_addr, data_path & "/modulation_table.bin");
        prev_config := config;
      end if;

      for i in 0 to number_of_frames - 1 loop
        file_reader_msg        := new_msg;
        file_reader_msg.sender := self;

        read_file(net, input_stream, data_path & "/bb_header_output_packed.bin", encode(config_tuple));
        -- read_file(net, output_ref, data_path & "/plframe_pilots_off_fixed_point.bin");
        read_file(net, output_ref, data_path & "/modulated_pilots_off_fixed_point.bin");

        -- ghdl translate_off
        read_file(net, bb_scrambler_checker, data_path & "/bb_scrambler_output_packed.bin");
        read_file(net, bch_encoder_checker, data_path & "/bch_encoder_output_packed.bin");
        read_file(net, ldpc_encoder_checker, data_path & "/ldpc_output_packed.bin");
        -- ghdl translate_on

      end loop;

    end procedure run_test; -- }} ------------------------------------------------------

  begin

    test_runner_setup(runner, RUNNER_CFG);
    show(display_handler, debug);
    -- hide(get_logger("file_reader_t(input_stream)"), display_handler, debug, True);
    -- hide(get_logger("file_reader_t(output_ref_data)"), display_handler, debug, True);

    -- show(get_logger("input_stream"), display_handler, (trace, debug), True);

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

      update_coefficients(COEFFS);

      if run("back_to_back") then
        data_probability <= 1.0;
        tready_probability <= 1.0;

        for i in configs'range loop
          run_test(configs(i), number_of_frames => NUMBER_OF_TEST_FRAMES);
        end loop;

      end if;

      wait_for_completion;
      info("All BFMs have now completed");
      check_equal(axi_slave.axi.tvalid, '0', "axi_slave.axi.tvalid should be '0'");

      walk(32);

    end loop;

    test_runner_cleanup(runner);
    wait;
  end process; -- }} -------------------------------------------------------------------

  receiver_p : process -- {{ -----------------------------------------------------------
    constant logger      : logger_t := get_logger("receiver");
    variable word_cnt    : natural  := 0;
    variable frame_cnt   : natural  := 0;

    function to_real ( constant v : signed ) return real is
      constant width : integer := v'length;
    begin
      return real(to_integer(v)) / real(2**(width - 1));
    end;

    function to_complex ( constant v : std_logic_vector ) return complex is
      constant width : integer := v'length;
    begin
      return complex'(
        re => to_real(signed(v(width - 1 downto width/2))),
        im => to_real(signed(v(width/2 - 1 downto 0)))
      );
    end function;

    constant TOLERANCE        : real := 0.10;
    -- Recv/expected in rect coords
    variable recv_rect        : complex;
    variable expected_rect    : complex;
    -- Recv/expected in polar coords
    variable recv_pol         : complex_polar;
    variable expected_pol     : complex_polar;

    variable error_cnt        : integer := 0;
    variable expected_lendian : std_logic_vector(DATA_WIDTH - 1 downto 0);

  begin
    wait until axi_slave.axi.tvalid = '1' and axi_slave.axi.tready = '1' and rising_edge(clk);
    expected_lendian := axi_slave.expected_tdata(23 downto 16)
                      & axi_slave.expected_tdata(31 downto 24)
                      & axi_slave.expected_tdata(7 downto 0)
                      & axi_slave.expected_tdata(15 downto 8);

    recv_rect      := to_complex(axi_slave.axi.tdata);
    expected_rect  := to_complex(expected_lendian);

    dbg_recv       <= recv_rect;
    dbg_expected   <= expected_rect;

    dbg_expected_i <= signed(expected_lendian(31 downto 16));
    dbg_expected_q <= signed(expected_lendian(15 downto 0));

    dbg_recv_i     <= signed(axi_slave.axi.tdata(31 downto 16));
    dbg_recv_q     <= signed(axi_slave.axi.tdata(15 downto 0));

    recv_pol       := complex_to_polar(recv_rect);
    expected_pol   := complex_to_polar(expected_rect);

    -- if axi_slave.axi.tdata /= expected_lendian then
    --   if    (recv_pol.mag >= 0.0 xor expected_pol.mag >= 0.0)
    --      or (recv_pol.arg >= 0.0 xor expected_pol.arg >= 0.0)
    --      or abs(recv_pol.mag) < abs(expected_pol.mag) * (1.0 - TOLERANCE)
    --      or abs(recv_pol.mag) > abs(expected_pol.mag) * (1.0 + TOLERANCE)
    --      or abs(recv_pol.arg) < abs(expected_pol.arg) * (1.0 - TOLERANCE)
    --      or abs(recv_pol.arg) > abs(expected_pol.arg) * (1.0 + TOLERANCE) then
    --     warning(
    --       logger,
    --       sformat(
    --         "[%d, %d] Comparison failed. " & lf &
    --         "Got      %r rect(%s, %s) / polar(%s, %s)" & lf &
    --         "Expected %r rect(%s, %s) / polar(%s, %s)",
    --         fo(frame_cnt),
    --         fo(word_cnt),
    --         fo(axi_slave.axi.tdata),
    --         real'image(recv_rect.re), real'image(recv_rect.im),
    --         real'image(recv_pol.mag), real'image(recv_pol.arg),
    --         fo(expected_lendian),
    --         real'image(expected_rect.re), real'image(expected_rect.im),
    --         real'image(expected_pol.mag), real'image(expected_pol.arg)
    --       ));
    --     error_cnt := error_cnt + 1;
    --   end if;
    -- end if;

    -- assert error_cnt < 256 report "Too many errors" severity Failure;

    word_cnt := word_cnt + 1;
    if axi_slave.axi.tlast = '1' then
      info(logger, sformat("Received frame %d with %d words", fo(frame_cnt), fo(word_cnt)));
      word_cnt  := 0;
      frame_cnt := frame_cnt + 1;
    end if;
  end process; -- }} -------------------------------------------------------------------
end dvbs2_tx_tb;
