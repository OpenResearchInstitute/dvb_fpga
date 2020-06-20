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

library fpga_cores;
use fpga_cores.common_pkg.all;

use work.ldpc_tables_pkg.all;
use work.dvb_utils_pkg.all;

package ldpc_pkg is

  -- LDPC tables 7a and 7b
  -- Largest Q is 135, so we need 8 bits
  constant LDPC_Q_WIDTH : natural := 8;
  --
  constant DVB_LDPC_GROUP_LENGTH : natural := 360;

  type ldpc_table_t is record
    data   : integer_2d_array_t;
    q      : natural;
    length : natural;
  end record;

  function get_ldpc_table (
    constant frame_type : in frame_type_t;
    constant code_rate  : in code_rate_t)
  return ldpc_table_t;

end ldpc_pkg;

package body ldpc_pkg is

  function get_table (
    constant frame_type : in frame_type_t;
    constant code_rate  : in code_rate_t)
  return integer_2d_array_t is
  begin

    if frame_type = fecframe_short   and code_rate = C4_5  then return LDPC_TABLE_FECFRAME_SHORT_C4_5;    end if;
    if frame_type = fecframe_short   and code_rate = C8_9  then return LDPC_TABLE_FECFRAME_SHORT_C8_9;    end if;
    if frame_type = fecframe_normal  and code_rate = C8_9  then return LDPC_TABLE_FECFRAME_NORMAL_C8_9;   end if;
    if frame_type = fecframe_normal  and code_rate = C9_10 then return LDPC_TABLE_FECFRAME_NORMAL_C9_10;  end if;
    if frame_type = fecframe_short   and code_rate = C1_2  then return LDPC_TABLE_FECFRAME_SHORT_C1_2;    end if;
    if frame_type = fecframe_normal  and code_rate = C1_2  then return LDPC_TABLE_FECFRAME_NORMAL_C1_2;   end if;
    if frame_type = fecframe_short   and code_rate = C1_4  then return LDPC_TABLE_FECFRAME_SHORT_C1_4;    end if;
    if frame_type = fecframe_short   and code_rate = C1_3  then return LDPC_TABLE_FECFRAME_SHORT_C1_3;    end if;
    if frame_type = fecframe_short   and code_rate = C2_5  then return LDPC_TABLE_FECFRAME_SHORT_C2_5;    end if;
    if frame_type = fecframe_short   and code_rate = C3_5  then return LDPC_TABLE_FECFRAME_SHORT_C3_5;    end if;
    if frame_type = fecframe_short   and code_rate = C2_3  then return LDPC_TABLE_FECFRAME_SHORT_C2_3;    end if;
    if frame_type = fecframe_short   and code_rate = C3_4  then return LDPC_TABLE_FECFRAME_SHORT_C3_4;    end if;
    if frame_type = fecframe_short   and code_rate = C5_6  then return LDPC_TABLE_FECFRAME_SHORT_C5_6;    end if;
    if frame_type = fecframe_normal  and code_rate = C1_4  then return LDPC_TABLE_FECFRAME_NORMAL_C1_4;   end if;
    if frame_type = fecframe_normal  and code_rate = C1_3  then return LDPC_TABLE_FECFRAME_NORMAL_C1_3;   end if;
    if frame_type = fecframe_normal  and code_rate = C2_5  then return LDPC_TABLE_FECFRAME_NORMAL_C2_5;   end if;
    if frame_type = fecframe_normal  and code_rate = C3_5  then return LDPC_TABLE_FECFRAME_NORMAL_C3_5;   end if;
    if frame_type = fecframe_normal  and code_rate = C2_3  then return LDPC_TABLE_FECFRAME_NORMAL_C2_3;   end if;
    if frame_type = fecframe_normal  and code_rate = C3_4  then return LDPC_TABLE_FECFRAME_NORMAL_C3_4;   end if;
    if frame_type = fecframe_normal  and code_rate = C4_5  then return LDPC_TABLE_FECFRAME_NORMAL_C4_5;   end if;
    if frame_type = fecframe_normal  and code_rate = C5_6  then return LDPC_TABLE_FECFRAME_NORMAL_C5_6;   end if;
  end function;

  function get_q (
    constant frame_type : in frame_type_t;
    constant code_rate  : in code_rate_t) return integer is
    variable result     : natural;
  begin
    if frame_type = fecframe_normal  and code_rate = C1_4  then result := 135; end if;
    if frame_type = fecframe_normal  and code_rate = C1_3  then result := 120; end if;
    if frame_type = fecframe_normal  and code_rate = C2_5  then result := 108; end if;
    if frame_type = fecframe_normal  and code_rate = C1_2  then result := 90;  end if;
    if frame_type = fecframe_normal  and code_rate = C3_5  then result := 72;  end if;
    if frame_type = fecframe_normal  and code_rate = C2_3  then result := 60;  end if;
    if frame_type = fecframe_normal  and code_rate = C3_4  then result := 45;  end if;
    if frame_type = fecframe_normal  and code_rate = C4_5  then result := 36;  end if;
    if frame_type = fecframe_normal  and code_rate = C5_6  then result := 30;  end if;
    if frame_type = fecframe_normal  and code_rate = C8_9  then result := 20;  end if;
    if frame_type = fecframe_normal  and code_rate = C9_10 then result := 18;  end if;

    if frame_type = fecframe_short  and code_rate = C1_4   then result := 36;   end if;
    if frame_type = fecframe_short  and code_rate = C1_3   then result := 30;   end if;
    if frame_type = fecframe_short  and code_rate = C2_5   then result := 27;   end if;
    if frame_type = fecframe_short  and code_rate = C1_2   then result := 25;   end if;
    if frame_type = fecframe_short  and code_rate = C3_5   then result := 18;   end if;
    if frame_type = fecframe_short  and code_rate = C2_3   then result := 15;   end if;
    if frame_type = fecframe_short  and code_rate = C3_4   then result := 12;   end if;
    if frame_type = fecframe_short  and code_rate = C4_5   then result := 10;   end if;
    if frame_type = fecframe_short  and code_rate = C5_6   then result := 8;    end if;
    if frame_type = fecframe_short  and code_rate = C8_9   then result := 5;    end if;

    return result;
  end function;

  function get_ldpc_code_length (
    constant frame_type : in frame_type_t;
    constant code_rate  : in code_rate_t) return natural is
    variable result     : natural;
  begin
    if frame_type = fecframe_normal  and code_rate = C1_4  then result := 16_200; end if;
    if frame_type = fecframe_normal  and code_rate = C1_3  then result := 21_600; end if;
    if frame_type = fecframe_normal  and code_rate = C2_5  then result := 25_920; end if;
    if frame_type = fecframe_normal  and code_rate = C1_2  then result := 32_400; end if;
    if frame_type = fecframe_normal  and code_rate = C3_5  then result := 38_880; end if;
    if frame_type = fecframe_normal  and code_rate = C2_3  then result := 43_200; end if;
    if frame_type = fecframe_normal  and code_rate = C3_4  then result := 48_600; end if;
    if frame_type = fecframe_normal  and code_rate = C4_5  then result := 51_840; end if;
    if frame_type = fecframe_normal  and code_rate = C5_6  then result := 54_000; end if;
    if frame_type = fecframe_normal  and code_rate = C8_9  then result := 57_600; end if;
    if frame_type = fecframe_normal  and code_rate = C9_10 then result := 58_320; end if;

    if frame_type = fecframe_short  and code_rate = C1_4   then result :=  3_240;  end if;
    if frame_type = fecframe_short  and code_rate = C1_3   then result :=  5_400;  end if;
    if frame_type = fecframe_short  and code_rate = C2_5   then result :=  6_480;  end if;
    if frame_type = fecframe_short  and code_rate = C1_2   then result :=  7_200;  end if;
    if frame_type = fecframe_short  and code_rate = C3_5   then result :=  9_720;  end if;
    if frame_type = fecframe_short  and code_rate = C2_3   then result := 10_800;  end if;
    if frame_type = fecframe_short  and code_rate = C3_4   then result := 11_880;  end if;
    if frame_type = fecframe_short  and code_rate = C4_5   then result := 12_600;  end if;
    if frame_type = fecframe_short  and code_rate = C5_6   then result := 13_320;  end if;
    if frame_type = fecframe_short  and code_rate = C8_9   then result := 14_400;  end if;

    if frame_type = fecframe_normal then
      return FECFRAME_NORMAL_BIT_LENGHT - result;
    end if;

    return FECFRAME_SHORT_BIT_LENGTH - result;

  end function;

  function get_ldpc_table (
    constant frame_type : in frame_type_t;
    constant code_rate  : in code_rate_t)
  return ldpc_table_t is
  begin
    return (data   => get_table(frame_type, code_rate),
            q      => get_q(frame_type, code_rate),
            length => get_ldpc_code_length(frame_type, code_rate));
  end function;


end package body;
