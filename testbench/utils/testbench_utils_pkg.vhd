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

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

use work.dvb_utils_pkg.all;

package testbench_utils_pkg is

  type config_type is record
    modulation : modulation_type;
    frame_type : frame_length_type;
    code_rate : code_rate_type;
    input_file : string(1 to 1024);
    reference_file : string(1 to 1024);
  end record;

  type config_array_type is array (natural range <>) of config_type;

  function to_string( constant config : config_type ) return string;

  -- Add double quotes around a string
  function quote ( constant s : string ) return string;

  impure function get_test_cfg ( constant str : string)
  return config_array_type;

  procedure push(msg : msg_t; value : modulation_type);
  procedure push(msg : msg_t; value : frame_length_type);
  procedure push(msg : msg_t; value : code_rate_type);

  impure function pop(msg : msg_t) return modulation_type;
  impure function pop(msg : msg_t) return frame_length_type;
  impure function pop(msg : msg_t) return code_rate_type;

end testbench_utils_pkg;

package body testbench_utils_pkg is

  procedure push(msg : msg_t; value : modulation_type) is
  begin
    -- Push value as a string
    push(msg.data, modulation_type'image(value));
  end;

  procedure push(msg : msg_t; value : frame_length_type) is
  begin
    -- Push value as a string
    push(msg.data, frame_length_type'image(value));
  end;

  procedure push(msg : msg_t; value : code_rate_type) is
  begin
    -- Push value as a string
    push(msg.data, code_rate_type'image(value));
  end;


  impure function pop(msg : msg_t) return modulation_type is
  begin
    return modulation_type'value(pop(msg.data));
  end;

  impure function pop(msg : msg_t) return frame_length_type is
  begin
    return frame_length_type 'value(pop(msg.data));
  end;

  impure function pop(msg : msg_t) return code_rate_type is
  begin
    return code_rate_type'value(pop(msg.data));
  end;


  -- type config_array_ptr is access config_array_type;

  -- impure function line_number ( constant str : string) return natural is
  --   file fd         : text;
  --   variable L      : line;
  --   variable result : natural := 0;
  -- begin
  --   file_open(fd, str, read_mode);
  --   while not endfile(fd) loop
  --     readline(fd, L);
  --     result := result + 1;
  --   end loop;
  --   file_close(fd);

  --   return result;
  -- end function line_number;

  --
  impure function get_test_cfg ( constant str : string)
  return config_array_type is
    variable cfg_strings : lines_t := split(str, ":");
    variable cfg_items   : lines_t;
    variable result      : config_array_type(0 to cfg_strings'length - 1);
    variable current     : config_type;
  begin

    if cfg_strings'length = 0 then
      warning("Could not parse any config from " & quote(str));
      return result;
    end if;

    for i in 0 to cfg_strings'length - 1 loop
      cfg_items := split(cfg_strings(i).all, ",");
      
      if cfg_items'length /= 5 then
        failure("Malformed config string " & quote(cfg_strings(i).all));
      end if;

      current.modulation := modulation_type'value(cfg_items(0).all);
      current.frame_type := frame_length_type'value(cfg_items(1).all);
      current.code_rate := code_rate_type'value(cfg_items(2).all);
      current.input_file := (others => nul);
      current.reference_file := (others => nul);

      current.input_file(cfg_items(3).all'range) := cfg_items(3).all;
      current.reference_file(cfg_items(4).all'range) := cfg_items(4).all;

      result(i) := current;

    end loop;

    info("Parsed " & integer'image(result'length) & " configuration(s):");
    for i in result'range loop
      info("- " & integer'image(i) & ": " & to_string(result(i)));
    end loop;

    return result;

  end function get_test_cfg;

  -- Add double quotes around a string
  function quote ( constant s : string ) return string is
  begin
    return '"' & s & '"';
  end function quote;

  -- Returns a string representation of config_type
  function to_string( constant config : config_type ) return string is
  begin
    return "config("
      & "modulation=" & quote(modulation_type'image(config.modulation)) & ", "
      & "frame_type=" & quote(frame_length_type'image(config.frame_type)) & ", "
      & "code_rate=" & quote(code_rate_type'image(config.code_rate)) & ", "
      & "input_file=" & quote(config.input_file) & ", "
      & "reference_file=" & quote(config.reference_file) & ")";
  end function to_string;

end package body;
