--
-- DVB IP
--
-- Copyright 2019 by Andre Souto (suoto)
--
-- This file is part of the DVB IP.
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

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package common_pkg is

    -- Calculates the number of bits required to represent a given value
    function numbits (constant v : integer) return integer;

    function swap_bytes (constant v : std_logic_vector) return std_logic_vector;

end common_pkg;

package body common_pkg is

    -- Calculates the number of bits required to represent a given value
    function numbits (
        constant v      : integer) return integer is
        variable result : integer;
    begin
        result := 1;
        while True loop
            if 2**result > v then
                return result;
            end if;
            result := result + 1;
        end loop;
    end function numbits;

    -- Swap bytes
    function swap_bytes (
        constant v           : std_logic_vector) 
    return std_logic_vector is
        constant byte_number : natural := v'length / 8;
        variable result      : std_logic_vector(v'range);
    begin
        assert byte_number * 8 = v'length
            report "Can't swap bytes with a non-integer number of bytes. " &
                   "Argument has " & integer'image(v'length)
            severity Failure;

        report "Number of bytes: "  & integer'image(byte_number);

        for byte in 0 to byte_number - 1 loop
            result((byte_number - byte) * 8 - 1 downto (byte_number - byte - 1) * 8) := v((byte + 1) * 8 - 1 downto byte * 8);
        end loop;
        return result;
    end function swap_bytes;

end package body;

