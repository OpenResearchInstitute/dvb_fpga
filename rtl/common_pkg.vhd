--
-- DVB IP
--
-- Copyright 2019 by Suoto <andre820@gmail.com>
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
use ieee.math_real.all;

package common_pkg is

  -- Calculates the number of bits required to represent a given value
  function numbits (constant v : natural) return natural;

  function mirror_bytes (constant v : std_logic_vector) return std_logic_vector;
  function mirror_bits (constant v : std_logic_vector) return std_logic_vector;

  --
  type integer_array_t is array (natural range <>) of integer;
  function minimum(constant a, b : integer) return integer;
  function minimum(constant values : integer_array_t) return integer;
  function to_boolean( v : std_ulogic) return boolean;

end common_pkg;

package body common_pkg is

    ------------------------------------------------------------------------------------
    -- Calculates the number of bits required to represent a given value
    function numbits (
        constant v : natural) return natural is
    begin
      if v <= 1 then
        return 1;
      end if;

      return integer(ceil(log2(real(v))));
    end function numbits;

    ------------------------------------------------------------------------------------
    function mirror_bytes (
        constant v           : std_logic_vector)
    return std_logic_vector is
        constant byte_number : natural := v'length / 8;
        variable result      : std_logic_vector(v'range);
    begin
        assert byte_number * 8 = v'length
            report "Can't swap bytes with a non-integer number of bytes. " &
                   "Argument has " & integer'image(v'length)
            severity Failure;

        for byte in 0 to byte_number - 1 loop
            result((byte_number - byte) * 8 - 1 downto (byte_number - byte - 1) * 8) := v((byte + 1) * 8 - 1 downto byte * 8);
        end loop;
        return result;
    end function mirror_bytes;

    ------------------------------------------------------------------------------------
    function mirror_bits (constant v : std_logic_vector) return std_logic_vector is
      variable result : std_logic_vector(v'range);
    begin
      for i in v'range loop
        result(v'length - i - 1) := v(i);
      end loop;

      return result;
    end;

    ------------------------------------------------------------------------------------
    function minimum(constant a, b : integer) return integer is
    begin
      return minimum(integer_array_t'(a, b));
    end;

    ------------------------------------------------------------------------------------
    function minimum(constant values : integer_array_t) return integer is
      variable result : integer;
    begin
      for index in values'range loop

        if values(index) < result then
          result := values(index);
        end if;

      end loop;

      return result;

    end;

  --------------------------------------------------------------------------------------
  function to_boolean( v : std_ulogic) return boolean is begin
    case v is
      when '0' | 'L'   => return (false);
      when '1' | 'H'   => return (true);
      when others      => return (false);
    end case;
  end to_boolean;
end package body;

