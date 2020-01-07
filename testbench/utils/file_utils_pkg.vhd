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

library str_format;
use str_format.str_format_pkg.all;

use work.testbench_utils_pkg.all;

package file_utils_pkg is

  -----------
  -- Types --
  -----------
  type std_logic_vector_array is array (natural range <>) of std_logic_vector;

  type ratio_t is record
    first  : positive;
    second : positive;
  end record ratio_t;

  type file_reader_cfg_t is record
    filename   : string(1 to 1024);
    data_ratio : ratio_t;
  end record;

  type file_reader_t is record
    reader : actor_t;
    sender : actor_t;
    outstanding : natural;
    logger : logger_t;
  end record;

  impure function new_file_reader(constant reader_name : in string) return file_reader_t;

  procedure enqueue_file(
    signal net           : inout network_t;
    variable file_reader : inout file_reader_t;
    constant filename    : string;
    constant ratio       : ratio_t := (8, 8);
    constant blocking    : boolean := False);

  procedure enqueue_file(
    signal net           : inout network_t;
    variable file_reader : inout file_reader_t;
    constant filename    : string;
    constant ratio       : string;
    constant blocking    : boolean := False);

  procedure wait_all_read (
    signal net           : inout network_t;
    variable file_reader : inout file_reader_t);

  procedure wait_file_read (
    signal net           : inout network_t;
    variable file_reader : inout file_reader_t);

  -----------------
  -- Subprograms --
  -----------------
  procedure write_binary_file (
    constant name : in string;
    constant data : in std_logic_vector_array);

  function parse_data_ratio (
    constant s               : string;
    constant base_data_width : in positive) return ratio_t;

  procedure push(msg : msg_t; value : ratio_t);
  impure function pop(msg : msg_t) return ratio_t;

  procedure push(msg : msg_t; value : file_reader_cfg_t);
  impure function pop(msg : msg_t) return file_reader_cfg_t;

  alias push_data_ratio is push[msg_t, ratio_t];
  alias push_file_reader_cfg is push[msg_t, file_reader_cfg_t];

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
    constant base_data_width : in positive) return ratio_t is
    variable second          : line;
    variable first           : line;
    variable is_first_char   : boolean := True;
  begin
    if s = "" then
      return (base_data_width, base_data_width);
    end if;

    for i in s'range loop
      if s(i) = ':' then
        is_first_char := False;
      elsif is_first_char then
        write(first, s(i));
      else
        write(second, s(i));
      end if;
    end loop;

    assert not is_first_char
      report "Malformed s: " & quote(s)
      severity Failure;

    return (second => integer'value(second.all),
            first => integer'value(first.all));

  end function parse_data_ratio;

  function encode(value : ratio_t) return string is
  begin
    return encode(value.first) & encode(value.second);
  end;

  function decode (
    constant code   : string)
    return ratio_t is
    variable second : positive;
    variable first  : positive;
    variable index  : positive := code'left;
  begin
    decode(code, index, second);
    decode(code, index, first);

    return (second, first);
  end;

  function decode ( constant code : string) return file_reader_cfg_t is
    variable filename : string(1 to 1024);
    variable second   : positive;
    variable first    : positive;
    variable index    : positive := code'left;
  begin
    decode(code, index, filename);
    decode(code, index, first);
    decode(code, index, second);
    return (filename, (second => second, first => first));
  end;

  function encode(value : file_reader_cfg_t) return string is
  begin
    return encode(value.filename) & encode(value.data_ratio);
  end;


  procedure push(msg : msg_t; value : ratio_t) is
  begin
    -- Push value as a string
    push(msg.data, encode(value));
  end;

  impure function pop(msg : msg_t) return ratio_t is
  begin
    return decode(pop(msg.data));
  end;

  procedure push(msg : msg_t; value : file_reader_cfg_t) is
  begin
    -- Push value as a string
    push(msg.data, encode(value));
  end;

  impure function pop(msg : msg_t) return file_reader_cfg_t is
  begin
    return decode(pop(msg.data));
  end;

  -- -----------------------------------------------------------------------------------
  -- -- Helpers to deal with configuring the file reader -------------------------------
  -- -----------------------------------------------------------------------------------
  impure function new_file_reader(constant reader_name : in string) return file_reader_t is
    variable file_reader : file_reader_t;
    constant sender_name : string := "file_reader_t(" & reader_name & ")";
  begin
    return (reader      => find(reader_name),
            sender      => new_actor(sender_name),
            outstanding => 0,
            logger      => get_logger(sender_name));
  end;


  procedure enqueue_file(
    signal net           : inout network_t;
    variable file_reader : inout file_reader_t;
    constant filename    : string;
    constant ratio       : ratio_t := (8, 8);
    constant blocking    : boolean := False) is
    variable msg         : msg_t := new_msg;
  begin
    msg.sender := file_reader.sender;
    push_file_reader_cfg(msg, (filename, ratio));
    file_reader.outstanding := file_reader.outstanding + 1;
    send(net, file_reader.reader, msg);
    debug(file_reader.logger,
          sformat("Outstanding transfers: %d", fo(file_reader.outstanding)));
  end;

  procedure enqueue_file(
    signal net           : inout network_t;
    variable file_reader : inout file_reader_t;
    constant filename    : string;
    constant ratio       : string;
    constant blocking    : boolean := False) is
  begin
    enqueue_file(net, file_reader, filename, parse_data_ratio(ratio, 8), blocking);
  end;


  procedure wait_file_read (
    signal net           : inout network_t;
    variable file_reader : inout file_reader_t) is
    variable msg         : msg_t := new_msg;
  begin
    receive(net, file_reader.sender, msg);
    file_reader.outstanding := file_reader.outstanding - 1;
    debug(file_reader.logger,
          sformat("Reply received, outstanding transfers: %d", fo(file_reader.outstanding)));
  end;

  procedure wait_all_read (
    signal net           : inout network_t;
    variable file_reader : inout file_reader_t) is
    variable msg         : msg_t := new_msg;
  begin
    while file_reader.outstanding /= 0 loop
      wait_file_read ( net, file_reader);
    end loop;
  end;

end package body;
