--
-- DVB FPGA
--
-- Copyright 2020-2022 by suoto <andre820@gmail.com>
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

-- Authors: Anshul Makkar <anshulmakkar@gmail.com>, suoto <andre820@gmail.com>

---------------
-- Libraries --
---------------
library	ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpga_cores;
use fpga_cores.common_pkg.all;

use work.dvb_utils_pkg.all;

package plframe_header_pkg is

  function get_pls_rom return std_logic_array_t;

  -- Code that generates each PLS code is an implementation of GNU Radio's C code in
  -- VHDL. Relevant files:
  -- https://github.com/gnuradio/gnuradio/blob/master/gr-dtv/lib/dvbs2/dvbs2_physical_cc_impl.cc
  -- https://github.com/gnuradio/gnuradio/blob/master/gr-dtv/lib/dvbs2/dvbs2_physical_cc_impl.h
  function get_pls_rom_addr (
    constant constellation : constellation_t;
    constant frame_type    : frame_type_t;
    constant code_rate     : code_rate_t;
    constant has_pilots    : boolean) return integer;

  constant SOF                  : std_logic_vector(25 downto 0) := "01" & x"8D2E82";
  constant DUMMY_FRAME_PLS_CODE : std_logic_vector;

end package plframe_header_pkg;

package body plframe_header_pkg is

  constant G : std_logic_array_t(0 to 6)(31 downto 0) := (
    0 => x"90AC2DDD", 1 => x"55555555", 2 => x"33333333", 3 => x"0F0F0F0F",
    4 => x"00FF00FF", 5 => x"0000FFFF", 6 => x"FFFFFFFF");

  function get_modcode (
    constant constellation : in constellation_t;
    constant code_rate : in code_rate_t) return integer is
  begin
    if (constellation = MOD_QPSK) then
      case code_rate is
        when C1_4 => return 1;
        when C1_3 => return 2;
        when C2_5 => return 3;
        when C1_2 => return 4;
        when C3_5 => return 5;
        when C2_3 => return 6;
        when C3_4 => return 7;
        when C4_5 => return 8;
        when C5_6 => return 9;
        when C8_9 => return 10;
        when C9_10 => return 11;
        when others => null;
      end case;
    end if;

    if (constellation = MOD_8PSK) then
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

    if constellation = MOD_16APSK then
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

    if constellation = MOD_32APSK then
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
  function b_64_8_code (constant v : std_logic_vector(7 downto 0)) return std_logic_vector is
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
      result((m*2) + 1) := result(m*2) xor v(0);
      bit_mask          := '0' & bit_mask(31 downto 1);
    end loop;

    result := mirror_bits(result);

    for m in 0 to 63 loop
      result(m) := result(m) xor PL_HDR_SCRAMBLE_TAB(m);
    end loop;

    return result;
  end function;

  function pl_header_encode(
    constant modcode   : std_logic_vector(7 downto 0);
    constant type_code : std_logic_vector(1 downto 0)) return std_logic_vector is
    variable code      : std_logic_vector(7 downto 0);
  begin
    if modcode(7) then
      code := modcode(7 downto 2) & (type_code and "01");
    else
      code := modcode(5 downto 0) & type_code;
    end if;
    return b_64_8_code(code);
  end function;

  function get_pls_code(
    constant constellation : in constellation_t;
    constant frame_type    : in frame_type_t;
    constant code_rate     : in code_rate_t;
    constant has_pilots    : in boolean) return std_logic_vector is

    variable modcode       : std_logic_vector(7 downto 0);
    variable type_code     : std_logic_vector(1 downto 0);

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

  function get_pls_rom return std_logic_array_t is
    function get_rom_depth return integer is
      variable addr  : integer := -2;
      variable depth : integer := 0;
      variable cnt   : integer := 0;
    begin
      for has_pilots in boolean'left to boolean'right loop
        for frame_type in frame_type_t'left to frame_type_t'right loop
          for constellation in constellation_t'left to constellation_t'right loop
            for code_rate in code_rate_t'left to code_rate_t'right loop
              addr := get_pls_rom_addr(constellation, frame_type, code_rate, has_pilots);
              if addr >= 0 then
                depth := max(addr, depth);
                cnt   := cnt + 1;
              end if;
            end loop;
          end loop;
        end loop;
      end loop;
      return depth;
    end;
    constant ROM_DEPTH : integer := get_rom_depth;
    variable result    : std_logic_array_t(0 to ROM_DEPTH)(63 downto 0);
    variable addr      : integer;
  begin
    for has_pilots in boolean'left to boolean'right loop
      for frame_type in frame_type_t'left to frame_type_t'right loop
        for constellation in constellation_t'left to constellation_t'right loop
          for code_rate in code_rate_t'left to code_rate_t'right loop
            addr := get_pls_rom_addr(constellation, frame_type, code_rate, has_pilots);
            if addr /= -1 then
              result(addr) := get_pls_code(constellation, frame_type, code_rate, has_pilots);
            end if;
          end loop;
        end loop;
      end loop;
    end loop;
    return result;
  end function get_pls_rom;

  function get_pls_rom_addr (
    constant constellation : constellation_t;
    constant frame_type    : frame_type_t;
    constant code_rate     : code_rate_t;
    constant has_pilots    : boolean) return integer is
    variable addr          : integer := get_modcode(constellation, code_rate);
  begin
    if addr = -1 then
      return -1;
    end if;
    if frame_type = unknown then
      return -1;
    end if;
    if not has_pilots then
      if frame_type = fecframe_short then
        return addr;
      end if;
      if frame_type = fecframe_normal then
        return addr + 32;
      end if;
    end if;

    if frame_type = fecframe_short then
      return addr + 64;
    end if;
    if frame_type = fecframe_normal then
      return addr + 96;
    end if;

  end;

  constant DUMMY_FRAME_PLS_CODE : std_logic_vector := pl_header_encode(
    modcode   => (others => '0'),
    type_code => (others => '0'));

end package body plframe_header_pkg;

-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
