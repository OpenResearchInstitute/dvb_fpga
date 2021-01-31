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

library vunit_lib;
context vunit_lib.vunit_context;
library str_format;
use str_format.str_format_pkg.all;

library fpga_cores;
use fpga_cores.common_pkg.all;

use work.dvb_utils_pkg.all;

package plframe_header_pkg is

  impure function get_pls_rom return std_logic_array_t;

  -- Code that generates each PLS code is an implementation of GNU Radio's C code in
  -- VHDL. Relevant files:
  -- https://github.com/gnuradio/gnuradio/blob/master/gr-dtv/lib/dvbs2/dvbs2_physical_cc_impl.cc
  -- https://github.com/gnuradio/gnuradio/blob/master/gr-dtv/lib/dvbs2/dvbs2_physical_cc_impl.h
  function get_pls_rom_addr (
    constant constellation : constellation_t;
    constant frame_type    : frame_type_t;
    constant code_rate     : code_rate_t) return integer;

end package plframe_header_pkg;

package body plframe_header_pkg is

  constant G : std_logic_array_t(0 to 6)(31 downto 0) := (
    0 => x"90AC2DDD", 1 => x"55555555", 2 => x"33333333", 3 => x"0F0F0F0F",
    4 => x"00FF00FF", 5 => x"0000FFFF", 6 => x"FFFFFFFF");

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
        when others => null;
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
        when others => null;
      end case;
    end if;

    if constellation = mod_32apsk then
      case code_rate is
        when C3_4 => return 24;
        when C4_5 => return 25;
        when C5_6 => return 26;
        when C8_9 => return 27;
        when C9_10 => return 28;
        when others => null;
      end case;
    end if;

    return -1;
  end;

  function get_modcode (
    constant constellation : in constellation_t;
    constant code_rate : in code_rate_t) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(get_modcode(constellation => constellation, code_rate => code_rate), 8));
  end function;

-- void dvbs2_physical_cc_impl::b_64_8_code(unsigned char in, int* out)
  impure function b_64_8_code (constant v : std_logic_vector(7 downto 0)) return std_logic_vector is
    constant PL_HDR_SCRAMBLE_TAB : std_logic_vector(63 downto 0) := "0111000110011101100000111100100101010011010000100010110111111010";
    variable temp                : std_logic_vector(31 downto 0) := (others => '0');
    variable bit_mask            : std_logic_vector(31 downto 0) := x"80000000";
    variable result              : std_logic_vector(63 downto 0);
  begin
    if or(v and x"80") then temp := temp xor G(0); end if;
    if or(v and x"40") then temp := temp xor G(1); end if;
    if or(v and x"20") then temp := temp xor G(2); end if;
    if or(v and x"10") then temp := temp xor G(3); end if;
    if or(v and x"08") then temp := temp xor G(4); end if;
    if or(v and x"04") then temp := temp xor G(5); end if;
    if or(v and x"02") then temp := temp xor G(6); end if;

    for m in 0 to 31 loop
      result(m*2)       := or(temp and bit_mask);
      result((m*2) + 1) := or(result(m*2) xor (v and x"01"));
      bit_mask          := '0' & bit_mask(31 downto 1);
    end loop;

    result := mirror_bits(result);

    for m in 0 to 63 loop
      result(m) := result(m) xor PL_HDR_SCRAMBLE_TAB(m);
    end loop;

    return result;
  end function;

  impure function pl_header_encode(
    constant modcode   : std_logic_vector(7 downto 0);
    constant type_code : std_logic_vector(7 downto 0)) return std_logic_vector is
    variable code      : std_logic_vector(7 downto 0);
  begin
    if or(modcode and x"80") then
      code := modcode or (type_code and x"01");
    else
      code := (modcode(5 downto 0) & "00") or type_code;
    end if;
    return b_64_8_code(code);
  end function;

  impure function get_pls_code(
    constant constellation : in constellation_t;
    constant frame_type    : in frame_type_t;
    constant code_rate     : in code_rate_t) return std_logic_vector is

    variable modcode       : std_logic_vector(7 downto 0);
    variable type_code     : std_logic_vector(7 downto 0);
    variable has_pilots    : boolean := False;

  begin
    modcode := std_logic_vector(to_unsigned(get_modcode(constellation, code_rate), 8));
    type_code := (others => '0');
    if frame_type = fecframe_normal then
      type_code(1) := '0';
    elsif frame_type = fecframe_short then
      type_code(1) := '1';
    end if;

    if has_pilots then
      type_code(0) := '1';
    end if;

    return pl_header_encode(modcode, type_code);
  end function get_pls_code;


  impure function get_pls_rom return std_logic_array_t is
    impure function get_rom_depth return integer is
      variable addr  : integer := -2;
      variable depth : integer := 0;
      variable cnt   : integer := 0;
    begin
      for constellation in constellation_t'left to constellation_t'right loop
        for code_rate in code_rate_t'left to code_rate_t'right loop
          for frame_type in frame_type_t'left to frame_type_t'right loop
            addr := get_pls_rom_addr(constellation, frame_type, code_rate);
            if addr >= 0 then
              depth := max(addr, depth);
              cnt   := cnt + 1;
            end if;
          end loop;
        end loop;
      end loop;
      info(sformat("ROM depth is %d (%d entries)", fo(depth), fo(cnt)));
      return depth;
    end;
    constant ROM_DEPTH : integer := get_rom_depth;
    variable result    : std_logic_array_t(0 to ROM_DEPTH)(63 downto 0);
    variable addr      : integer;
  begin
    for constellation in constellation_t'left to constellation_t'right loop
      for code_rate in code_rate_t'left to code_rate_t'right loop
        for frame_type in frame_type_t'left to frame_type_t'right loop
          addr := get_pls_rom_addr(constellation, frame_type, code_rate);
          if addr /= -1 then
            result(addr) := get_pls_code(constellation, frame_type, code_rate);
          end if;
        end loop;
      end loop;
    end loop;
    return result;
  end function get_pls_rom;

  function get_pls_rom_addr (
    constant constellation : constellation_t;
    constant frame_type    : frame_type_t;
    constant code_rate     : code_rate_t) return integer is
    variable addr          : integer := get_modcode(constellation, code_rate);
  begin
    if addr = -1 then
      return -1;
    end if;
    if frame_type = not_set then
      return -1;
    end if;
    if frame_type = fecframe_short then
      return addr;
    end if;
    if frame_type = fecframe_normal then
      return addr + 32;
    end if;
  end;

end package body plframe_header_pkg;

-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
