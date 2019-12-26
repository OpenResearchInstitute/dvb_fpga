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

  procedure create_file (constant length : positive) is
    type file_type is file of character;
    file fd             : file_type;
    variable write_rand : RandomPType;
    -- Not really unsigned, just to make converting to string easier
    variable data       : unsigned(DATA_WIDTH - 1 downto 0);
    variable byte       : unsigned(7 downto 0);
  begin
    write_rand.InitSeed(0);
    info("Creating test file: " & FILE_NAME);
    file_open(fd, FILE_NAME, write_mode);

    for word_cnt in 0 to length loop
      data := write_rand.RandUnsigned(DATA_WIDTH);
      -- Data is little endian, write MSB first
      for byte_index in (DATA_WIDTH + 7) / 8 - 1 downto 0 loop
        byte := data(8*(byte_index + 1) - 1 downto 8*byte_index);

        if not BYTES_ARE_BITS then
          write(fd, character'val(to_integer(byte)));
        else
          for i in 7 downto 0 loop
            -- When BYTES_ARE_BITS is set to True, each bit on a word becomes a byte
            if byte(i) = '1' then
              write(fd, character'val(1));
            else
              write(fd, character'val(0));
            end if;
            -- write(fd, character'val(to_integer(unsigned'(0 downto 0 => byte(i)))));
          end loop;
        end if;

      end loop;
    end loop;

    file_close(fd);
  end procedure create_file;

  ---------------
  -- Constants --
  ---------------
  constant CLK_PERIOD : time := 5 ns;

  -------------
  -- Signals --
  -------------
  signal clk                : std_logic := '0';
  signal rst                : std_logic;
  signal start              : std_logic;
  signal completed          : std_logic;
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
      rst                => rst,
      -- Config and status
      start              => start,
      completed          => completed,
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
  test_runner_watchdog(runner, REPEAT_CNT * 5 ms);

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

    procedure trigger_and_wait (variable duration : out time) is
      variable start_time : time;
    begin
      for i in 0 to REPEAT_CNT - 1 loop
        start <= '1';
        walk(1);
        start_time := now;
        start <= '0';
        wait until s_tvalid = '1' and s_tready = '1' and s_tlast = '1' and rising_edge(clk);
        duration := now - start_time;
      end loop;
      walk(4);
    end procedure trigger_and_wait;

    --
    variable test_duration : time;

    procedure test_tvalid_probability is
      variable baseline       : time;
      variable tvalid_half    : time;
      variable tvalid_quarter : time;
    begin
      rst <= '1'; walk(4); rst <= '0';
      tvalid_probability <= 1.0;
      trigger_and_wait(baseline);

      rst <= '1'; walk(4); rst <= '0';
      tvalid_probability <= 0.5;
      trigger_and_wait(tvalid_half);

      rst <= '1'; walk(4); rst <= '0';
      tvalid_probability <= 0.25;
      trigger_and_wait(tvalid_quarter);

      -- Check time taken is the expected +/- 10%
      check_true((baseline * 0.9 * 2 < tvalid_half) and (tvalid_half < baseline * 1.1 * 2));
      check_true((baseline * 0.9 * 4 < tvalid_quarter) and (tvalid_quarter < baseline * 1.1 * 4));

    end procedure test_tvalid_probability;

  begin

    create_file(256);

    start <= '0';

    test_runner_setup(runner, runner_cfg);
    show_all(display_handler);

    while test_suite loop
      tvalid_probability <= 1.0;
      tready_probability <= 1.0;
      start              <= '0';

      rst <= '1';
      walk(4);
      rst <= '0';
      walk(4);

      if run("back_to_back") then
        trigger_and_wait(test_duration);
      elsif run("slow_read") then
        tready_probability <= 0.5;
        walk(4);
        trigger_and_wait(test_duration);

      elsif run("slow_write") then
        test_tvalid_probability;
      end if;

      walk(16);

    end loop;

    test_runner_cleanup(runner);
    wait;

  end process main;

  -- Generate a tready enable with the configured probability
  s_tready_gen : process
    variable tready_rand : RandomPType;
    variable check_rand  : RandomPType;
    variable word_cnt    : integer := 0;
    variable frame_cnt   : integer := 0;
    variable expected    : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
  begin

    while True loop
      if rst = '1' then
        check_rand.InitSeed(0);
      else
        if completed = '1' then
          check_true(s_tvalid = '0' and s_tlast = '0',
                     "tvalid and tlast should be '0' when completed is asserted");
        end if;
      end if;
      s_tready <= '0';
      if tready_rand.RandReal(1.0) <= tready_probability then
        s_tready <= '1';
      end if;
      if s_tready = '1' and s_tvalid = '1' then
        expected := check_rand.RandSlv(DATA_WIDTH);
        check_equal(s_tdata, expected, sformat("Expected %r, got %r", fo(expected), fo(s_tdata)));

        word_cnt := word_cnt + 1;

        if s_tlast = '1' then
          info(sformat("Received frame %d with %d words", fo(frame_cnt), fo(word_cnt)));
          frame_cnt := frame_cnt + 1;
          word_cnt  := 0;
          -- Frames will repeat, reinitialize seed
          check_rand.InitSeed(0);
        end if;
      end if;

      wait until rising_edge(clk);
    end loop;
  end process;

end axi_file_reader_tb;
