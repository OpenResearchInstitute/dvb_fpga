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

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

use work.dvb_utils_pkg.all;

package testbench_utils_pkg is

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


end package body;

