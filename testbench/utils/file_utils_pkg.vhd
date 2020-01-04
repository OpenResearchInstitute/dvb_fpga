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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

package file_utils_pkg is

  -----------
  -- Types --
  -----------
  type std_logic_vector_array is array (natural range <>) of std_logic_vector;

  type data_ratio_type is record
    output : positive;
    input  : positive;
  end record data_ratio_type;

  type file_reader_cfg_type is record
    filename   : string(1 to 1024);
    data_ratio : data_ratio_type;
  end record;

  -----------------
  -- Subprograms --
  -----------------
  procedure write_binary_file (
    constant name : in string;
    constant data : in std_logic_vector_array);

  function parse_data_ratio (
    constant s               : string;
    constant base_data_width : in positive) return data_ratio_type;

  procedure push(msg : msg_t; value : data_ratio_type);
  impure function pop(msg : msg_t) return data_ratio_type;

  procedure push(msg : msg_t; value : file_reader_cfg_type);
  impure function pop(msg : msg_t) return file_reader_cfg_type;

  alias push_data_ratio is push[msg_t, data_ratio_type];
  alias push_file_reader_cfg is push[msg_t, file_reader_cfg_type];

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

  function parse_data_ratio (
    constant s               : string;
    constant base_data_width : in positive) return data_ratio_type is
    variable input           : line;
    variable output          : line;
    variable is_input        : boolean := True;
  begin
    if s = "" then
      return (base_data_width, base_data_width);
    end if;

    for i in s'range loop
      if s(i) = ':' then
        is_input := False;
      elsif is_input then
        write(input, s(i));
      else
        write(output, s(i));
      end if;
    end loop;

    assert not is_input
      report "Malformed s: '" & s & "'"
      severity Failure;

    return (integer'value(output.all),
            integer'value(input.all));

  end function parse_data_ratio;

  function encode(value : data_ratio_type) return string is
  begin
    return encode(value.output) & encode(value.input);
  end;

  function decode (
    constant code   : string)
    return data_ratio_type is
    variable input  : positive;
    variable output : positive;
    variable index  : positive := code'left;
  begin
    decode(code, index, input);
    decode(code, index, output);

    return (input, output);
  end;

  function decode ( constant code : string) return file_reader_cfg_type is
    variable filename : string(1 to 1024);
    variable input    : positive;
    variable output   : positive;
    variable index    : positive := code'left;
  begin
    decode(code, index, filename);
    decode(code, index, output);
    decode(code, index, input);
    return (filename, (input => input, output => output));
  end;

  function encode(value : file_reader_cfg_type) return string is
  begin
    return encode(value.filename) & encode(value.data_ratio);
  end;


  procedure push(msg : msg_t; value : data_ratio_type) is
  begin
    -- Push value as a string
    push(msg.data, encode(value));
  end;

  impure function pop(msg : msg_t) return data_ratio_type is
  begin
    return decode(pop(msg.data));
  end;

  procedure push(msg : msg_t; value : file_reader_cfg_type) is
  begin
    -- Push value as a string
    push(msg.data, encode(value));
  end;

  impure function pop(msg : msg_t) return file_reader_cfg_type is
  begin
    return decode(pop(msg.data));
  end;

end package body;
