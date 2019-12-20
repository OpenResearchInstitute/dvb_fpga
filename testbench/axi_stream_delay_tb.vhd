--
-- DVB IP
--
-- Copyright 2019 by Andre Souto (suoto)
--
-- This file is part of DVB IP.
--
-- DVB IP is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- DVB IP is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DVB IP.  If not, see <http://www.gnu.org/licenses/>.

-- vunit: run_all_in_same_sim

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library vunit_lib;
    context vunit_lib.vunit_context;

library osvvm;
    use osvvm.RandomPkg.all;

library str_format;
    use str_format.str_format_pkg.all;

library lib;

entity axi_stream_delay_tb is
    generic (
        RUNNER_CFG   : string;
        DELAY_CYCLES : integer := 1);
end axi_stream_delay_tb;

architecture axi_stream_delay_tb of axi_stream_delay_tb is

    -----------
    -- Types --
    -----------
    type std_logic_vector_array is array (natural range <>) of std_logic_vector;

    ---------------
    -- Constants --
    ---------------
    constant CLK_PERIOD  : time := 5 ns;
    constant TDATA_WIDTH : integer  := 8;

    -------------
    -- Signals --
    -------------
    -- Usual ports
    signal clk                 : std_logic := '1';
    signal rst                 : std_logic;

    -- AXI master input
    signal m_tvalid            : std_logic;
    signal m_tready            : std_logic;
    signal m_tdata             : std_logic_vector(TDATA_WIDTH - 1 downto 0);

    -- AXI slave output
    signal s_tvalid            : std_logic;
    signal s_tready            : std_logic := '0';
    signal s_tdata             : std_logic_vector(TDATA_WIDTH - 1 downto 0);


    shared variable master_gen : RandomPType;
    shared variable slave_gen  : RandomPType;
    shared variable rand       : RandomPType;

    signal tvalid_probability  : real := 1.0;
    signal tready_probability  : real := 1.0;

    signal m_tvalid_en         : std_logic;
    signal m_tvalid_actual     : std_logic;

    signal m_data_valid        : boolean;
    signal s_data_valid        : boolean;
    signal wr_cnt              : integer;
    signal rd_cnt              : integer;

begin
    
    m_data_valid <= m_tvalid_actual = '1' and m_tready = '1';
    s_data_valid <= s_tvalid = '1' and s_tready = '1';

    -------------------
    -- Port mappings --
    -------------------
    dut : entity lib.axi_stream_delay
        generic map (
            DELAY_CYCLES => DELAY_CYCLES,
            TDATA_WIDTH  => TDATA_WIDTH)
        port map (
            -- Usual ports
            clk     => clk,
            rst     => rst,

            -- AXI slave input
            s_tvalid => m_tvalid_actual,
            s_tready => m_tready,
            s_tdata  => m_tdata,

            -- AXI master output
            m_tvalid => s_tvalid,
            m_tready => s_tready,
            m_tdata  => s_tdata);

    ------------------------------
    -- Asynchronous assignments --
    ------------------------------
    clk <= not clk after CLK_PERIOD/2;

    m_tvalid_actual <= m_tvalid and m_tvalid_en;

    test_runner_watchdog(runner, 1 ms);

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

    -- Writes a single word to the AXI slave
    procedure write_word ( constant data : std_logic_vector(TDATA_WIDTH - 1 downto 0)) is
    begin
        m_tvalid <= '1';
        m_tdata  <= data;

        wait until m_tvalid_actual = '1' and m_tready = '1' and rising_edge(clk);

        m_tvalid <= '0';
        m_tdata  <= (others => 'U');
    end procedure write_word;

    procedure write_frame (constant data : std_logic_vector_array) is
    begin
        for i in data'range loop
            write_word(data(i));
        end loop;
    end procedure write_frame;

    impure function random_frame (constant length, data_width : natural)
    return std_logic_vector_array is
        variable frame : std_logic_vector_array(0 to length - 1)(data_width - 1 downto 0);
    begin
        for i in 0 to length - 1 loop
            frame(i) := master_gen.RandSlv(data_width);
        end loop;
        return frame;
    end function random_frame;

    begin

        m_tvalid <= '0';

        -- Start both wr and rd data random generators with the same seed so we get the
        -- same sequence
        master_gen.InitSeed("some_seed");
        slave_gen.InitSeed("some_seed");

        test_runner_setup(runner, RUNNER_CFG);

        while test_suite loop
            rst <= '1';
            walk(8);
            rst <= '0';
            walk(8);

            tvalid_probability <= 1.0;
            tready_probability <= 1.0;

            if run("single_word") then
                tready_probability <= 1.0;
                write_word(master_gen.RandSlv(TDATA_WIDTH));
                walk(4);
            elsif run("back_to_back_frame") then
                tready_probability <= 1.0;
                write_frame(random_frame(16, TDATA_WIDTH));
            elsif run("slow_slave") then
                tready_probability <= 0.20;
                write_frame(random_frame(16, TDATA_WIDTH));
            elsif run("slow_master") then
                tvalid_probability <= 0.20;
                write_frame(random_frame(16, TDATA_WIDTH));
            elsif run("slow_master_and_slave") then
                tvalid_probability <= 0.50;
                tready_probability <= 0.50;
                write_frame(random_frame(16, TDATA_WIDTH));
            end if;

            if wr_cnt /= rd_cnt then
                wait until wr_cnt = rd_cnt;
            end if;
            -- Make sure both sides are on the same page
            check_equal(master_gen.RandSlv(TDATA_WIDTH), slave_gen.RandSlv(TDATA_WIDTH));

            info("Done");
            walk(16);

        end loop;

        test_runner_cleanup(runner);
        wait;
    end process;

    axi_slave_p : process(clk)
    begin
        if rising_edge(clk) then
            s_tready <= '0';

            if rand.RandReal(1.0) < tready_probability then
                s_tready <= '1';
            end if;

            if s_tready = '1' and s_tvalid = '1' then
                info(sformat("Received %r", fo(s_tdata)));
                check_equal(s_tdata, slave_gen.RandSlv(TDATA_WIDTH));
            end if;

        end if;
    end process;

    tvalid_rnd_gen : process
    begin
        m_tvalid_en <= '0';
        wr_cnt      <= 0;
        rd_cnt      <= 0;
        wait until rst = '0';
        while True loop
            wait until rising_edge(clk);
            m_tvalid_en <= '0';
            if rand.RandReal(1.0) < tvalid_probability then
                m_tvalid_en <= '1';
            end if;

            if m_data_valid then
                wr_cnt <= wr_cnt + 1;
            end if;
            if s_data_valid then
                rd_cnt <= rd_cnt + 1;
            end if;

        end loop;
    end process;

end axi_stream_delay_tb;

