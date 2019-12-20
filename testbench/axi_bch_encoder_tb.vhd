--
-- lib IP
--
-- Copyright 2019 by Andre Souto (suoto)
--
-- This file is part of lib IP.
-- 
-- lib IP is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- lib IP is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with lib IP.  If not, see <http://www.gnu.org/licenses/>.

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

-- library common_lib;
--     use common_lib.common_pkg.all;

library vunit_lib;
    context vunit_lib.vunit_context;

library osvvm;
    use osvvm.RandomPkg.all;

library str_format;
    use str_format.str_format_pkg.all;

library lib;
    use lib.bch_encoder_pkg.all;

entity axi_bch_encoder_tb is
    generic (
        runner_cfg    : string
    );
end axi_bch_encoder_tb;

architecture axi_bch_encoder_tb of axi_bch_encoder_tb is

    -----------
    -- Types --
    -----------
    type std_logic_vector_array is array (natural range <>) of std_logic_vector;

    ---------------
    -- Constants --
    ---------------
    constant CLK_PERIOD : time := 5 ns;
    constant TDATA_WIDTH : integer  := 8;

    -------------
    -- Signals --
    -------------
    -- Usual ports
    signal clk     : std_logic := '1';
    signal rst     : std_logic;

    signal cfg_bch_code : std_logic_vector(1 downto 0);

    -- AXI input
    signal m_tready : std_logic;
    signal m_tvalid : std_logic;
    signal m_tdata  : std_logic_vector(TDATA_WIDTH - 1 downto 0);
    signal m_tlast  : std_logic;

    -- AXI output
    signal s_cfg    : bch_encoder_cfg;
    signal s_tvalid : std_logic;
    signal s_tdata  : std_logic_vector(TDATA_WIDTH - 1 downto 0);
    signal s_tlast  : std_logic;
    signal s_tready : std_logic;

    shared variable master_gen : RandomPType;
    shared variable slave_gen  : RandomPType;
    shared variable rand       : RandomPType;

    signal tvalid_probability  : real := 1.0;
    signal tready_probability  : real := 1.0;

    signal m_tvalid_wr : std_logic;
    signal m_tvalid_en : std_logic;

    signal m_data_valid        : boolean;
    signal s_data_valid        : boolean;
    signal wr_cnt              : integer;
    signal rd_cnt              : integer;

begin

    -------------------
    -- Port mappings --
    -------------------
    dut : entity lib.axi_bch_encoder
        generic map (
            TDATA_WIDTH => TDATA_WIDTH
        )
        port map (
            -- Usual ports
            clk     => clk,
            rst     => rst,

            cfg_bch_code => cfg_bch_code,

            -- AXI input
            s_tvalid => m_tvalid,
            s_tdata  => m_tdata,
            s_tlast  => m_tlast,
            s_tready => m_tready,

            -- AXI output
            m_tready => s_tready,
            m_tvalid => s_tvalid,
            m_tlast  => s_tlast,
            m_tdata  => s_tdata);


    ------------------------------
    -- Asynchronous assignments --
    ------------------------------
    clk <= not clk after CLK_PERIOD/2;

    test_runner_watchdog(runner, 1 ms);

    m_tvalid     <= m_tvalid_wr and m_tvalid_en;

    m_data_valid <= m_tvalid = '1' and m_tready = '1';
    s_data_valid <= s_tvalid = '1' and s_tready = '1';

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
    procedure write_word (
        constant data     : std_logic_vector(TDATA_WIDTH - 1 downto 0);
        constant is_last  : boolean := False) is
    begin
        m_tvalid_wr <= '1';
        m_tdata     <= data;
        if is_last then
            m_tlast <= '1';
        else
            m_tlast  <= '0';
        end if;

        wait until m_tvalid = '1' and m_tready = '1' and rising_edge(clk);

        m_tlast     <= '0';
        m_tvalid_wr <= '0';
        m_tdata     <= (others => 'U');
    end procedure write_word;

    procedure write_frame (
        constant data : std_logic_vector_array;
        constant code : integer range 0 to 2) is
    begin

        cfg_bch_code <= std_logic_vector(to_unsigned(code, 2));

        for i in data'range loop
            write_word(data(i), is_last => i = data'length - 1);
            cfg_bch_code <= (others => 'U');
        end loop;

    end procedure write_frame;

    variable normal_frame : std_logic_vector_array(0 to BCH_NORMAL_FRAME_SIZE/TDATA_WIDTH - 1)(TDATA_WIDTH - 1 downto 0);
    variable short_frame : std_logic_vector_array(0 to 16008/TDATA_WIDTH - 1)(TDATA_WIDTH - 1 downto 0);

    begin

        m_tvalid_wr <= '0';
        m_tlast     <= '0';

        test_runner_setup(runner, runner_cfg);
        -- Start both wr and rd data random generators with the same seed so
        -- we get the same sequence
        -- wr_data_gen.InitSeed("some_seed");
        -- rd_data_gen.InitSeed("some_seed");

        while test_suite loop
            rst <= '1';
            walk(16);
            rst <= '0';
            walk(16);

            normal_frame := (others => (others => '0'));
            short_frame := (others => (others => '0'));

            tvalid_probability <= 0.5;
            tready_probability <= 0.5;

            if run("basic_normal_frame") then

                normal_frame(0) := (TDATA_WIDTH - 1 => '1', others => '0');

                walk(1);

                write_frame(normal_frame, code => BCH_POLY_12);
                wait until s_tvalid = '1' and s_tready = '1' and s_tlast = '1' and rising_edge(clk);

                info("Done");
            elsif run("basic_short_frame") then

                short_frame(0) := (TDATA_WIDTH - 1 => '1', others => '0');
                walk(1);
                write_frame(short_frame, code => BCH_POLY_12);
                write_frame(short_frame, code => BCH_POLY_12);
                wait until s_tvalid = '1' and s_tready = '1' and s_tlast = '1' and rising_edge(clk);

                info("Done");
            end if;

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
                -- check_equal(s_tdata, slave_gen.RandSlv(TDATA_WIDTH));
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

end axi_bch_encoder_tb;
