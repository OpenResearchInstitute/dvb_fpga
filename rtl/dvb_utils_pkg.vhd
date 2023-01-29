--
-- DVB FPGA
--
-- Copyright 2019-2022 by suoto <andre820@gmail.com>
--
-- This source describes Open Hardware and is licensed under the CERN-OHL-W v2.
--
-- You may redistribute and modify this source and make products using it under
-- the terms of the CERN-OHL-W v2 (https://ohwr.org/cern_ohl_w_v2.txt).
--
-- This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING
-- OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.
-- Please see the CERN-OHL-W v2 for applicable conditions.
--
-- Source location: https://github.com/phase4ground/dvb_fpga
--
-- As per CERN-OHL-W v2 section 4.1, should You produce hardware based on this
-- source, You must maintain the Source Location visible on the external case of
-- the DVB Encoder or other products you make using this source.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpga_cores;
use fpga_cores.common_pkg.all;

package dvb_utils_pkg is

  constant FECFRAME_SHORT_BIT_LENGTH  : integer := 16_200;
  constant FECFRAME_NORMAL_BIT_LENGTH : integer := 64_800;

  -- Sizes
  constant DVB_N_LDPC : integer_vector_t := (FECFRAME_SHORT_BIT_LENGTH, FECFRAME_NORMAL_BIT_LENGTH);

  type frame_type_t is (unknown, fecframe_normal, fecframe_short);

  type constellation_t is ( unknown, mod_qpsk, mod_8psk, mod_16apsk, mod_32apsk);

  -- Enum like type for LDPC codes
  type code_rate_t is (
    unknown, -- Only for sim, to allow setting an invalid value
    C1_4, C1_3, C2_5, C1_2, C3_5, C2_3, C3_4, C4_5,
    C5_6, C8_9, C9_10);

  type frame_type_array_t is array (natural range <>) of frame_type_t;
  type constellation_array_t is array (natural range <>) of constellation_t;
  type code_rate_array_t is array (natural range <>) of code_rate_t;

  constant FRAME_TYPE_LENGTH    : integer := frame_type_t'pos(frame_type_t'high) - frame_type_t'pos(frame_type_t'low) + 1;
  constant CODE_RATE_LENGTH     : integer := code_rate_t'pos(code_rate_t'high) - code_rate_t'pos(code_rate_t'low) + 1;
  constant CONSTELLATION_LENGTH : integer := constellation_t'pos(constellation_t'high) - constellation_t'pos(constellation_t'low) + 1;

  constant FRAME_TYPE_WIDTH     : integer := numbits(FRAME_TYPE_LENGTH);
  constant CONSTELLATION_WIDTH  : integer := numbits(CONSTELLATION_LENGTH);
  constant CODE_RATE_WIDTH      : integer := numbits(CODE_RATE_LENGTH);

  -- Encode/decode config types to std_logic_vectors
  function encode( constant v : frame_type_t ) return std_logic_vector;
  function encode( constant v : constellation_t ) return std_logic_vector;
  function encode( constant v : code_rate_t ) return std_logic_vector;

  function decode( constant v : std_logic_vector ) return frame_type_t ;
  function decode( constant v : std_logic_vector ) return constellation_t;
  function decode( constant v : std_logic_vector ) return code_rate_t;

  constant CONFIG_TUPLE_WIDTHS: integer_vector_t := (
    0 => FRAME_TYPE_WIDTH,
    1 => CONSTELLATION_WIDTH,
    2 => CODE_RATE_WIDTH,
    3 => 1); -- Pilots is a single bit

  constant ENCODED_CONFIG_WIDTH : integer  := sum(CONFIG_TUPLE_WIDTHS);

  type config_tuple_t is record
    frame_type    : frame_type_t;
    code_rate     : code_rate_t;
    constellation : constellation_t;
    pilots        : std_logic;
  end record;

  function to_string( constant cfg : config_tuple_t ) return string;

  type config_tuple_array_t is array (natural range <>) of config_tuple_t;

  function encode ( constant cfg : config_tuple_t ) return std_logic_vector;
  function decode ( constant v : std_logic_vector ) return config_tuple_t;

  function get_crc_length (
    constant frame_type : in  frame_type_t;
    constant code_rate  : in  code_rate_t) return positive;

  function to_signed_fixed_point (constant x : real; constant width : positive) return signed;
  function cos (constant x : real; constant width : positive) return signed;
  function sin (constant x : real; constant width : positive) return signed;

  function to_unsigned_fixed_point (constant x : real; constant width : positive) return unsigned;

end dvb_utils_pkg;

package body dvb_utils_pkg is

  function get_crc_length (
    constant frame_type : in  frame_type_t;
    constant code_rate  : in  code_rate_t) return positive is
    variable result     : integer := -1;
  begin
    if frame_type = fecframe_short then
      result := 168;
    else
      if code_rate = C8_9 or code_rate = C9_10 then
        result := 128;
      elsif code_rate = C5_6 or code_rate = C2_3 then
        result := 160;
      else
        result := 192;
      end if;
    end if;

    assert result /= -1
      report "Unable to determine CRC length for " &
             "frame type = " & frame_type_t'image(frame_type) & ", " &
             "code rate = " & code_rate_t'image(code_rate)
      severity Failure;

    return result;
  end function get_crc_length;

  function to_string( constant cfg : config_tuple_t ) return string is
  begin
    return "config_tuple("
      & "constellation=" & quote(constellation_t'image(cfg.constellation)) & ", "
      & "frame_type=" & quote(frame_type_t'image(cfg.frame_type)) & ", "
      & "code_rate=" & quote(code_rate_t'image(cfg.code_rate)) & ", "
      & "pilots=" & std_logic'image(cfg.pilots) & ")";
  end function to_string;


  function encode ( constant cfg : config_tuple_t ) return std_logic_vector is
  begin
    return cfg.pilots & encode(cfg.code_rate) & encode(cfg.constellation) & encode(cfg.frame_type);
  end function;

  function decode ( constant v : std_logic_vector ) return config_tuple_t is
  begin
    return (frame_type    => decode(get_field(v, 0, CONFIG_TUPLE_WIDTHS)),
            constellation => decode(get_field(v, 1, CONFIG_TUPLE_WIDTHS)),
            code_rate     => decode(get_field(v, 2, CONFIG_TUPLE_WIDTHS)),
            pilots        => get_field(v, 3, CONFIG_TUPLE_WIDTHS));
  end function;


  function is_ulogic ( constant v : std_logic_vector ) return boolean is
  begin
    for i in v'range loop
      if v(i) /= '0' and v(i) /= '1' then
        return False;
      end if;
    end loop;
    return True;
  end;

  function encode( constant v : frame_type_t ) return std_logic_vector is
  begin
    if v = unknown then
      return (FRAME_TYPE_WIDTH - 1 downto 0 => 'U');
    end if;
    return std_logic_vector(to_unsigned(frame_type_t'pos(v), FRAME_TYPE_WIDTH));
  end;

  function encode( constant v : constellation_t ) return std_logic_vector is
  begin
    if v = unknown then
      return (CONSTELLATION_WIDTH - 1 downto 0 => 'U');
    end if;
    return std_logic_vector(to_unsigned(constellation_t'pos(v), CONSTELLATION_WIDTH));
  end;

  function encode( constant v : code_rate_t ) return std_logic_vector is
  begin
    if v = unknown then
      return (CODE_RATE_WIDTH - 1 downto 0 => 'U');
    end if;
    return std_logic_vector(to_unsigned(code_rate_t'pos(v), CODE_RATE_WIDTH));
  end;

  function is_01 ( constant v : std_logic_vector ) return boolean is
  begin
    for i in v'range loop
      if v(i) /= '0' and v(i) /= '1' then
        return False;
      end if;
    end loop;
    return True;
  end;

  function decode( constant v : std_logic_vector ) return frame_type_t is
    variable index : integer;
  begin
    if not is_01(v) then
      return unknown;
    end if;
    index := to_integer(unsigned(v));
    if index >= frame_type_t'pos(frame_type_t'left) and index <= frame_type_t'pos(frame_type_t'right) then
      return frame_type_t'val(index);
    else
      report "Value of " & integer'image(index) & " "
           & "is outisde of frame_type_t range of "
           & integer'image(frame_type_t'pos(frame_type_t'left)) & " to "
           & integer'image(frame_type_t'pos(frame_type_t'right))
      severity Warning;
      return unknown;
    end if;
  end;

  function decode( constant v : std_logic_vector ) return constellation_t is
    variable index : integer;
  begin
    if not is_01(v) then
      return unknown;
    end if;
    index := to_integer(unsigned(v));
    if index >= constellation_t'pos(constellation_t'left) and index <= constellation_t'pos(constellation_t'right) then
      return constellation_t 'val(index);
    else
      report "Value of " & integer'image(index) & " "
           & "is outisde of constellation_t range of "
           & integer'image(constellation_t'pos(constellation_t'left)) & " to "
           & integer'image(constellation_t'pos(constellation_t'right))
      severity Warning;
      return unknown;
    end if;
  end;

  function decode( constant v : std_logic_vector ) return code_rate_t is
    variable index : integer;
  begin
    if not is_01(v) then
      return unknown;
    end if;

    index := to_integer(unsigned(v));
    if index >= code_rate_t'pos(code_rate_t'left) and index <= code_rate_t'pos(code_rate_t'right) then
      return code_rate_t'val(index);
    else
      report "Value of " & integer'image(index) & " "
           & "is outisde of code_rate_t range of "
           & integer'image(code_rate_t'pos(code_rate_t'left)) & " to "
           & integer'image(code_rate_t'pos(code_rate_t'right))
      severity Warning;
      return unknown;
    end if;
  end;

  function to_signed_fixed_point (constant x : real; constant width : positive) return signed is
    variable int : integer := integer(ieee.math_real.round(x * real(2**(width - 1))));
  begin
    if x = 1.0 then
      return to_signed(integer(int) - 1, width);
    end if;
    return to_signed(integer(int), width);
  end;

  function cos (constant x : real; constant width : positive) return signed is
  begin
    return to_signed_fixed_point(ieee.math_real.cos(x), width);
  end;

  function sin (constant x : real; constant width : positive) return signed is
  begin
    return to_signed_fixed_point(ieee.math_real.sin(x), width);
  end;

  function to_unsigned_fixed_point (constant x : real; constant width : positive) return unsigned is
    variable int : integer := integer(ieee.math_real.round(x * real(2**width)));
  begin
    if x = 1.0 then
      return to_unsigned(integer(int) - 1, width);
    end if;
    return to_unsigned(integer(int), width);
  end;

end package body;
