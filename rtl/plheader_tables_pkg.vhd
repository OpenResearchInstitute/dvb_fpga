--
-- DVB IP
--
-- Copyright 2020 by Anshul Makkar <anshulmakkar@gmail.com>
--
-- This file is part of DVB IP.
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

---------------
-- Libraries --
---------------
library	ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.MATH_PI;

library fpga_cores;
use fpga_cores.common_pkg.all;

use work.dvb_utils_pkg.all;

package plheader_tables_pkg is

  function get_plframe_header_rom return std_logic_array_t;

  -- We'll expose this to use as a address to the header ROM
  function get_modcode (
    constant constellation : in constellation_t;
    constant code_rate : in code_rate_t) return integer;

end package plheader_tables_pkg;


package body plheader_tables_pkg is

  constant PLFRAME_HEADER_LENGTH : integer := 90;

  constant G : unsigned_array_t(0 to 6)(31 downto 0) := (
    0 => x"90AC2DDD", 1 => x"55555555", 2 => x"33333333", 3 => x"0F0F0F0F",
    4 => x"00FF00FF", 5 => x"0000FFFF", 6 => x"FFFFFFFF");

  constant PLFRAME_HEADER_SOF  : std_logic_vector(25 downto 0) := "01" & x"8D2E82";
  constant PL_HDR_SCRAMBLE_TAB : std_logic_vector(63 downto 0) := ("0111000110011101100000111100100101010011010000100010110111111010");


  function get_modcode (
    constant constellation : in constellation_t;
    constant code_rate : in code_rate_t) return integer is
  begin
    if (constellation = mod_8psk) then
      case code_rate is
        when C3_5 => return 12;
        when C2_3 => return 13;
        when C3_4 => return 14;
        when C5_6 => return 15;
        when C8_9 => return 16;
        when C9_10 => return 17;
        when others => null; --return 0;
      end case;
    end if;

    if constellation = mod_16apsk then
      case code_rate is
        when C2_3 => return 18;
        when C3_4 => return 19;
        when C4_5 => return 20;
        when C5_6 => return 21;
        when C8_9 => return 22;
        when C9_10 => return 23;
        when others => null; --return 0;
      end case;
    end if;

    if constellation = mod_32apsk then
      case code_rate is
        when C3_4 => return 24;
        when C4_5 => return 25;
        when C5_6 => return 26;
        when C8_9 => return 27;
        when C9_10 => return 28;
        when others => null; --return 0;
      end case;
    end if;

    -- report "No MODOCDE for constellation=" & constellation_t'image(constellation) & ", code_rate=" & code_rate_t'image(code_rate)
    --   severity Failure;
    return -1;
  end;

  function get_plframe_header(
    constant constellation : in constellation_t;
    constant code_rate     : in code_rate_t) return std_logic_vector is

    variable header        : std_logic_vector (PLFRAME_HEADER_LENGTH - 1 downto 0);
    variable modcode       : unsigned(7 downto 0) := (others => '0');
    variable modbit        : unsigned (31 downto 0) := (31 => '1', others => '0');

    variable plscode       : std_logic_vector(63 downto 0) := (others => '0');

    -- no pilot insertion and  FECFRAMESIZE 64800
    variable type_code     : unsigned (1 downto 0) := (others => '0');
    variable code          : unsigned (7 downto 0) := (others => '0');
    variable res           : unsigned (7 downto 0) := (others => '0');
    variable temp          : unsigned (31 downto 0);

  begin
    modcode := to_unsigned(get_modcode(constellation, code_rate), 8);

    -- Left side bit for SOF being the MSB of PL_HEADER
    -- concatenate to form PL header
    header :=  PLFRAME_HEADER_SOF & header(PLFRAME_HEADER_LENGTH - 1 downto PLFRAME_HEADER_SOF'length);

    -- pl header encode
    res := modcode and x"80";
    if res /= 0 then
      code := modcode or ( type_code and x"01");
    else
      code := (modcode (7 downto 2) & '0') or type_code;
    end if;

    --scrambling process start. Can move to different function
    -- move below code to a different function.
    -- b_64_8_code
    res := code and x"80";
    if res /= 0 then
      temp := temp xor G(0);
    end if;

    res := code and x"40";
    if res /= 0 then
      temp := temp xor G(1);
    end if;

    res := code and x"20";
    if res /= 0 then
      temp := temp xor G(2);
    end if;

    res := code and x"10";
    if res /= 0 then
      temp := temp xor G(3);
    end if;

    res := code and x"08";
    if res /= 0 then
      temp := temp xor G(4);
    end if;

    res := code and x"04";
    if res /= 0 then
      temp := temp xor G(5);
    end if;

    res := code and x"02";
    if res /= 0 then
      temp := temp xor G(6);
    end if;

    for m in 0 to 31 loop
      temp := temp and modbit;
      if temp /= 0 then
        plscode(m *2) := '1';
      else
        plscode(m *2) := '0';
      end if;
      code := code and x"01";
      plscode((m * 2) + 1) := plscode(m * 2) xor code(0);
      -- right shift modbit.
      modbit := '0' & modbit(31 downto 1);
    end loop;

     --randomize it.
    for m in 0 to 63 loop
      plscode(m) := plscode(m) xor PL_HDR_SCRAMBLE_TAB(m);
    end loop;

    --concatename pl_tmp and pl_header containing SOF
    header(63 downto 0) :=  plscode(63 downto 0);

    return header;
  end function get_plframe_header;


  function get_plframe_header_rom return std_logic_array_t is
    function get_rom_depth return integer is
      variable cnt : integer := 0;
    begin
      for cfg_constellation in constellation_t'left to constellation_t'right loop
        for cfg_code_rate in code_rate_t'left to code_rate_t'right loop
          if get_modcode(cfg_constellation, cfg_code_rate) /= -1 then
            cnt := cnt + 1;
          end if;
        end loop;
      end loop;
      return cnt;
    end;
    constant ROM_DEPTH : integer := get_rom_depth;
    variable result    : std_logic_array_t(0 to ROM_DEPTH - 1)(PLFRAME_HEADER_LENGTH -1 downto 0);
    variable addr      : integer;
  begin
    for constellation in constellation_t'left to constellation_t'right loop
      for code_rate in code_rate_t'left to code_rate_t'right loop
        addr := get_modcode(constellation, code_rate);
        if addr /= -1 then
          result(addr) := get_plframe_header(constellation, code_rate);
        end if;
      end loop;
    end loop;
    return result;
  end function get_plframe_header_rom;

end package body plheader_tables_pkg;

-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
