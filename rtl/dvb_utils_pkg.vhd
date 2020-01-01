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

package dvb_utils_pkg is

  constant BCH_NORMAL_FRAME_SIZE : integer := 64_800;
  constant BCH_SHORT_FRAME_SIZE : integer := 16_200;

  -- constant BB_NORMAL_FRAME_SIZE : integer := 64_800;
  -- constant BB_SHORT_FRAME_SIZE : integer := 16_200;

  type frame_length_type is (not_set, normal, short);

  type modulation_type is ( not_set, mod_8_psk, mod_16_psk, mod_32_psk);

  -- Enum like type for LDPC codes
  type ldpc_code_type is (
    not_set, -- Only for sim, to allow setting an invalid value
    ldpc_1_4, ldpc_1_3, ldpc_2_5, ldpc_1_2, ldpc_3_5, ldpc_2_3, ldpc_3_4, ldpc_4_5,
    ldpc_5_6, ldpc_8_9, ldpc_9_10);

  constant BCH_POLY_8 : integer := 0;
  constant BCH_POLY_10 : integer := 1;
  constant BCH_POLY_12 : integer := 2;

end dvb_utils_pkg;

package body dvb_utils_pkg is

end package body;
