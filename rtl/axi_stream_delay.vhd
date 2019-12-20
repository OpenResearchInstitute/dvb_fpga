--
-- DVP IP
--
-- Copyright 2019 by Andre Souto (suoto)
--
-- This file is part of DVP IP.
-- 
-- DVP IP is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- DVP IP is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DVP IP.  If not, see <http://www.gnu.org/licenses/>.

---------------------------------
-- Block name and description --
--------------------------------

---------------
-- Libraries --
---------------
library	ieee;
    use ieee.std_logic_1164.all;  
    use ieee.numeric_std.all;

------------------------
-- Entity declaration --
------------------------
entity axi_stream_delay is
    generic (
        DELAY_CYCLES : positive := 1;
        TDATA_WIDTH  : integer  := 8);
    port (
        -- Usual ports
        clk     : in  std_logic;
        rst     : in  std_logic;

        -- AXI slave input
        s_tvalid : in std_logic;
        s_tready : out std_logic;
        s_tdata  : in std_logic_vector(TDATA_WIDTH - 1 downto 0);

        -- AXI master output
        m_tvalid : out std_logic;
        m_tready : in std_logic;
        m_tdata  : out std_logic_vector(TDATA_WIDTH - 1 downto 0));
end axi_stream_delay;

architecture axi_stream_delay of axi_stream_delay is

    -----------
    -- Types --
    -----------
    type tdata_t is array (natural range <>) of std_logic_vector(TDATA_WIDTH - 1 downto 0);

    -------------
    -- Signals --
    -------------
    signal tdata_pipe  : tdata_t(DELAY_CYCLES downto 0);
    signal tvalid_pipe : std_logic_vector(DELAY_CYCLES downto 0);
    signal tready_pipe : std_logic_vector(DELAY_CYCLES downto 0);

begin

    -------------------
    -- Port mappings --
    -------------------
    g_skid_buffers : for i in 0 to DELAY_CYCLES - 1 generate
        dut : entity work.skidbuffer
            generic map (
                OPT_LOWPOWER    => False,
                OPT_OUTREG      => True,
                OPT_PASSTHROUGH => False,
                DW              => TDATA_WIDTH)
            port map (
                i_clk    => clk,
                i_reset  => rst,

                i_valid  => tvalid_pipe(i),
                o_ready  => tready_pipe(i),
                i_data   => tdata_pipe(i),

                o_valid => tvalid_pipe(i + 1),
                i_ready => tready_pipe(i + 1),
                o_data  => tdata_pipe(i + 1));
    end generate g_skid_buffers;

    ------------------------------
    -- Asynchronous assignments --
    ------------------------------
    tvalid_pipe(0) <= s_tvalid;
    tdata_pipe(0)  <= s_tdata;
    s_tready       <= tready_pipe(0);

    m_tvalid                  <= tvalid_pipe(DELAY_CYCLES);
    m_tdata                   <= tdata_pipe(DELAY_CYCLES);
    tready_pipe(DELAY_CYCLES) <= m_tready;

end axi_stream_delay;
