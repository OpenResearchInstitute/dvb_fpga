--
-- hdl_lib -- An HDL core library
--
-- Copyright 2014-2016 by Andre Souto (suoto)
--
-- This file is part of hdl_lib.
-- 
-- hdl_lib is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- hdl_lib is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with hdl_lib.  If not, see <http://www.gnu.org/licenses/>.

library	ieee;
    use ieee.std_logic_1164.all;  

-- Synchronizes a data bus between different clock domains
entity synchronizer is
    generic (
        SYNC_STAGES  : positive := 2;
        DATA_WIDTH   : integer  := 1);
    port (
        -- Usual ports
        clk     : in  std_logic;
        clken   : in  std_logic := '1';

        -- Block specifics
        din     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        dout    : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end synchronizer;

architecture synchronizer of synchronizer is

    -----------
    -- Types --
    -----------
    type din_t is array (natural range <>) of std_logic_vector(DATA_WIDTH - 1 downto 0);

    -------------
    -- Signals --
    -------------
    signal din_sr   : din_t(SYNC_STAGES - 1 downto 0);

    ----------------
    -- Attributes --
    ----------------
    -- Synplify Pro: disable shift-register LUT (SRL) extraction
    attribute syn_srlstyle : string;
    attribute syn_srlstyle of din_sr : signal is "registers";

    -- Xilinx XST: disable shift-register LUT (SRL) extraction
    attribute shreg_extract : string;
    attribute shreg_extract of din_sr : signal is "no";

    -- Disable X propagation during timing simulation. In the event of 
    -- a timing violation, the previous value is retained on the output instead 
    -- of going unknown (see Xilinx UG625)
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of din_sr : signal is "TRUE";

begin

    -------------------
    -- Port mappings --
    -------------------

    ------------------------------
    -- Asynchronous assignments --
    ------------------------------
    dout   <= din_sr(SYNC_STAGES - 1);

    ---------------
    -- Processes --
    ---------------
    process(clk)
    begin
        if clk'event and clk = '1' then
            if clken = '1' then
                din_sr <= din_sr(SYNC_STAGES - 2 downto 0) & din;
            end if;
        end if;
    end process;


end synchronizer;

