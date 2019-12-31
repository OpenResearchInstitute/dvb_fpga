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

package file_utils_pkg is

  -----------
  -- Types --
  -----------
  type std_logic_vector_array is array (natural range <>) of std_logic_vector;

  -----------------
  -- Subprograms --
  -----------------
  procedure write_binary_file (
    constant name : in string;
    constant data : in std_logic_vector_array);

end file_utils_pkg;

package body file_utils_pkg is

  procedure write_binary_file (
    constant name : in string;
    constant data : in std_logic_vector_array) is
    type file_type is file of character;
    file fd             : file_type;
    -- Not really unsigned, just to make converting to string easier
    constant LENGTH     : integer := data'length;
    constant DATA_WIDTH : integer := data(0)'length;
    variable word       : unsigned(DATA_WIDTH - 1 downto 0);
    variable byte       : unsigned(7 downto 0);
  begin
    report "Writing data to " & name;
    file_open(fd, name, write_mode);

    for word_cnt in 0 to LENGTH - 1 loop
      word := unsigned(data(word_cnt));
      -- Data is little endian, write MSB first
      for byte_index in (DATA_WIDTH + 7) / 8 - 1 downto 0 loop
        byte := word(8*(byte_index + 1) - 1 downto 8*byte_index);
        write(fd, character'val(to_integer(byte)));

      end loop;
    end loop;

    file_close(fd);
  end procedure write_binary_file;

end package body;

