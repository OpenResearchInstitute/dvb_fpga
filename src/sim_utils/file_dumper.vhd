--
-- hdl_lib -- A(nother) HDL library
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
-- In addition to the GNU General Public License terms and conditions,
-- under the section 7 - Additional Terms, include the following:
--    g) All files of this work contain lines identifying the original
--    author and release date. This line SHOULD NOT be removed or
--    changed for any reason unless explicitly allowed by the author in
--    the form of writing. Note that this seeks to prevent this work
--    from being misused. Misuse includes but doesn't limits to code
--    evaluation of candidates from employers. All remaining GNU
--    General Public License terms still apply.
--
-- hdl_lib is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- You should have received a copy of the GNU General Public License
-- along with hdl_lib.  If not, see <http://www.gnu.org/licenses/>.
--
-- Author: Andre Souto (github.com/suoto) [DO NOT REMOVE]
-- Date: 2016/04/18 [DO NOT REMOVE]
---------------
-- Libraries --
---------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

------------------------
-- Entity declaration --
------------------------
entity file_dumper is
    generic (
        FILENAME   : string := "output.bin";
        DATA_WIDTH : integer := 32);
    port (
        -- Usual ports
        clk     : in  std_logic;
        clken   : in  std_logic;
        rst     : in  std_logic;

        -- Data input
        tdata   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        tvalid  : in  std_logic;
        tready  : in  std_logic);
end entity file_dumper;

architecture file_dumper of file_dumper is

    -----------
    -- Types --
    -----------
    type int_file is file of integer;

begin

    ---------------
    -- Processes --
    ---------------
    process
        file dump_file : int_file;
    begin
        file_open(dump_file, FILENAME, write_mode);
        wait until rst = '0';
        while True loop
            wait until clk'event and clk = '1' and clken = '1';
            if tvalid = '1' and tready = '1' then
                write(dump_file, to_integer(unsigned(tdata)));
            end if;
        end loop;
    end process;

end file_dumper;

