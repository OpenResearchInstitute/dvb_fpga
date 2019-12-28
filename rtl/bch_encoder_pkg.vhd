--
-- DVB IP
--
-- Copyright 2019 by Andre Souto (suoto)
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

library str_format;
use str_format.str_format_pkg.all;

package bch_encoder_pkg is

  constant BCH_NORMAL_FRAME_SIZE : integer := 64_800;
  constant BCH_SHORT_FRAME_SIZE : integer := 16_200;

  -- constant BB_NORMAL_FRAME_SIZE : integer := 64_800;
  -- constant BB_SHORT_FRAME_SIZE : integer := 16_200;

  type bch_frame_length is (normal, short);

  constant BCH_POLY_8 : integer := 0;
  constant BCH_POLY_10 : integer := 1;
  constant BCH_POLY_12 : integer := 2;

end bch_encoder_pkg;

package body bch_encoder_pkg is

  end package body;
