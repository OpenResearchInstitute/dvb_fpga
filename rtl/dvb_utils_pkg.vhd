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

package dvb_utils_pkg is

  constant BCH_NORMAL_FRAME_SIZE : integer := 64_800;
  constant BCH_SHORT_FRAME_SIZE : integer := 16_200;

  type frame_length_type is (not_set, normal, short);

  type modulation_type is ( not_set, mod_8psk, mod_16apsk, mod_32apsk);

  -- Enum like type for LDPC codes
  type code_rate_type is (
    not_set, -- Only for sim, to allow setting an invalid value
    C1_4, C1_3, C2_5, C1_2, C3_5, C2_3, C3_4, C4_5,
    C5_6, C8_9, C9_10);

  constant BCH_POLY_8 : integer := 0;
  constant BCH_POLY_10 : integer := 1;
  constant BCH_POLY_12 : integer := 2;

end dvb_utils_pkg;

package body dvb_utils_pkg is

end package body;
