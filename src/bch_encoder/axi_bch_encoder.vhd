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

---------------------------------
-- Block name and description --
--------------------------------

---------------
-- Libraries --
---------------
library	ieee;
    use ieee.std_logic_1164.all;  
    use ieee.numeric_std.all;

use work.common_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_bch_encoder is
    generic (
        MAX_FRAME_LENGTH_BITS : positive := 64_800;
        TDATA_WIDTH           : integer  := 1
    );
    port (
        -- Usual ports
        clk     : in  std_logic;
        rst     : in  std_logic;

        -- Config
        cfg_frame_length : in std_logic_vector(numbits(MAX_FRAME_LENGTH_BITS) - 1 downto 0);
        -- t-error correction
        cfg_bch_poly : in (a, b);

        -- AXI input
        s_tvalid : in  std_logic;
        s_tdata  : in  std_logic_vector(TDATA_WIDTH - 1 downto 0);
        s_tready : out std_logic;

        -- AXI output
        m_tready : in  std_logic;
        m_tvalid : out std_logic;
        m_tdata  : out std_logic_vector(TDATA_WIDTH - 1 downto 0));
end axi_bch_encoder;

architecture axi_bch_encoder of axi_bch_encoder is

    -----------
    -- Types --
    -----------
    type din_t is array (natural range <>) of std_logic_vector(TDATA_WIDTH - 1 downto 0);

    -------------
    -- Signals --
    -------------
    signal din_sr   : din_t(DELAY_CYCLES - 1 downto 0);

begin

    -------------------
    -- Port mappings --
    -------------------

    ------------------------------
    -- Asynchronous assignments --
    ------------------------------

    ---------------
    -- Processes --
    ---------------
    process(clk, rst)
    begin
        if rst = '1' then
            null;
        elsif clk'event and clk = '1' then
            if clken = '1' then

            end if;
        end if;
    end process;


end axi_bch_encoder;


