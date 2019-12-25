--
-- DVB FPGA
--
-- Copyright 2019 by Andre Souto (suoto)
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

---------------------------------
-- Block name and description --
--------------------------------

---------------
-- Libraries --
---------------
library	ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library vunit_lib;
    context vunit_lib.vunit_context;

library osvvm;
    use osvvm.RandomPkg.all;

library str_format;
    use str_format.str_format_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_file_reader_tb is
  generic (
    runner_cfg     : string;
    DATA_WIDTH     : integer;
    FILE_NAME      : string;
    BYTES_ARE_BITS : boolean;
    REPEAT_CNT     : positive);
end axi_file_reader_tb;

architecture axi_file_reader_tb of axi_file_reader_tb is

  ---------------
  -- Constants --
  ---------------
  constant CLK_PERIOD : time := 5 ns;

  -------------
  -- Signals --
  -------------
  signal clk                : std_logic := '0';
  signal start_reading      : std_logic;
  signal end_of_file        : std_logic;
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
      FILE_NAME      => FILE_NAME,
      DATA_WIDTH     => DATA_WIDTH,
      -- GNU Radio does not have bit format, so most blocks use 1 bit per byte. Set this to
      -- True to use the LSB to form a data word
      BYTES_ARE_BITS => BYTES_ARE_BITS,
      -- Repeat the frame whenever reaching EOF
      REPEAT_CNT     => REPEAT_CNT)
    port map (
      -- Usual ports
      clk                => clk,
      -- Config and status
      start_reading      => start_reading,
      end_of_file        => end_of_file,
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
  test_runner_watchdog(runner, 10 ms);

  ---------------
  -- Processes --
  ---------------
  main : process
    procedure walk(constant steps : natural) is
    begin
      if steps /= 0 then
        for step in 0 to steps - 1 loop
          wait until rising_edge(clk);
        end loop;
      end if;
    end procedure walk;

  begin

    start_reading <= '0';

    test_runner_setup(runner, runner_cfg);
    show_all(display_handler);

    while test_suite loop
      tvalid_probability <= 1.0;
      tready_probability <= 1.0;

      start_reading <= '0';
      walk(16);

      if run("back_to_back") then

        start_reading <= '1';
        walk(1);
        start_reading <= '0';

        for i in 0 to REPEAT_CNT - 1 loop
          wait until end_of_file = '1';
        end loop;

        walk(16);

      elsif run("slow_read") then
        tready_probability <= 0.5;

        walk(4);

        start_reading <= '1';
        walk(1);
        start_reading <= '0';

        for i in 0 to REPEAT_CNT - 1 loop
          wait until end_of_file = '1';
        end loop;
        walk(16);

      elsif run("slow_write") then
        tvalid_probability <= 0.5;

        walk(4);

        start_reading <= '1';
        walk(1);
        start_reading <= '0';

        for i in 0 to REPEAT_CNT - 1 loop
          wait until end_of_file = '1';
        end loop;
        walk(16);

      end if;

      walk(16);

    end loop;

    test_runner_cleanup(runner);
    wait;

  end process main;

  -- Generate a tready enable with the configured probability
  s_tready_gen : process(clk)
    variable rand      : RandomPType;
    variable word_cnt  : integer := 0;
    variable frame_cnt : integer := 0;
    variable expected  : unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
  begin
    if rising_edge(clk) then
      s_tready <= '0';
      if rand.RandReal(1.0) <= tready_probability then
        s_tready <= '1';
      end if;
      if s_tready = '1' and s_tvalid = '1' then
        -- info(sformat("(%d) Got %r", fo(word_cnt), fo(s_tdata)));
        check_equal(s_tdata, expected);
        expected := expected + 1;
        if s_tlast = '1' then
          info(sformat("Received frame %d with %d words", fo(frame_cnt), fo(word_cnt)));
          frame_cnt := frame_cnt + 1;
          word_cnt  := 0;
        end if;
      end if;
    end if;
  end process;


end axi_file_reader_tb;
