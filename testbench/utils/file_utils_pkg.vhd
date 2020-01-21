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
    filename : line;
    ratio    : ratio_t;
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

  impure function to_std_logic_vector(s : string) return std_logic_vector;

  -----------------
  -- Subprograms --
  -----------------
  function parse_data_ratio (
    constant s               : string;
    constant base_data_width : in positive := 1) return ratio_t;

  procedure push(msg : msg_t; value : ratio_t);
  impure function pop(msg : msg_t) return ratio_t;

  procedure push(msg : msg_t; variable value : file_reader_cfg_t);
  impure function pop(msg : msg_t) return file_reader_cfg_t;

  alias push_data_ratio is push[msg_t, ratio_t];
  alias push_file_reader_cfg is push[msg_t, file_reader_cfg_t];

  procedure push(
    msg               : msg_t;
    constant filename : string;
    constant ratio    : ratio_t);

end file_utils_pkg;

package body file_utils_pkg is

  function parse_data_ratio (
    constant s               : string;
    constant base_data_width : in positive := 1) return ratio_t is
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

  procedure push(msg : msg_t; value : ratio_t) is
  begin
    push(msg, value.first);
    push(msg, value.second);
  end;

  procedure push(
    msg               : msg_t;
    constant filename : string;
    constant ratio    : ratio_t) is
    variable cfg      : file_reader_cfg_t;
  begin
    write(cfg.filename, filename);
    cfg.ratio := ratio;
    push(msg, cfg);
  end;

  procedure push(msg : msg_t; variable value : file_reader_cfg_t) is
  begin
    push(msg, value.filename.all);
    push(msg, value.ratio);
  end;

  impure function pop(msg : msg_t) return ratio_t is
  begin
    return (first => pop(msg),
            second => pop(msg));
  end;

  impure function pop(msg : msg_t) return file_reader_cfg_t is
  begin
    return (new string'(pop_string(msg)),
            pop(msg));
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
    push(msg, filename, ratio);
    file_reader.outstanding := file_reader.outstanding + 1;
    send(net, file_reader.reader, msg);
    debug(file_reader.logger,
          sformat("Enqueued %s, outstanding transfers: %d", quote(filename), fo(file_reader.outstanding)));
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
    debug(file_reader.logger, sformat("Waiting for all files to be read. Outstanding now: %d", fo(file_reader.outstanding)));
    if file_reader.outstanding /= 0 then
      while file_reader.outstanding /= 0 loop
        wait_file_read ( net, file_reader);
      end loop;
    end if;
  end;

  impure function to_std_logic_vector(s : string) return std_logic_vector is
    variable result : std_logic_vector(4 * s'length - 1 downto 0);
  begin
    for i in s'range loop
      result(4*i - 1 downto 4*(i - 1))
        := std_logic_vector(to_unsigned(character'pos(s(i)), 4));
    end loop;
    return result;
  end;

  impure function decode_std_logic_vector_array(
    constant s          : string;
    constant data_width : integer) return std_logic_vector_array is
    variable items      : lines_t := split(s, "|");
    variable data       : std_logic_vector_array(0 to items'length - 1)(data_width - 1 downto 0);
  begin
    debug("decoding => '" & s & "'");
    for i in items'range loop
      data(i) := to_std_logic_vector(items(0).all);
    end loop;
    debug("done");
    return data;
  end;

end package body;
