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

  constant PLFRAME_HEADER_LENGTH : integer := 90;

  type std_logic_2d_array_t is array (natural range <>, natural range <>) of std_logic_vector; -- Needs VHDL 2008 in Vivado
  constant MOD_8PSK_MAP : std_logic_2d_array_t(0 to 3, 0 to 1)(31 downto 0);

  impure function get_plframe_header_rom return std_logic_array_t;

  impure function get_plframe_header(
    constant constellation : in constellation_t;
    constant frame_type    : in frame_type_t;
    constant code_rate     : in code_rate_t) return std_logic_vector;

  function get_rom_addr (
    constant constellation : constellation_t;
    constant frame_type    : frame_type_t;
    constant code_rate     : code_rate_t) return integer;

end package plheader_tables_pkg;


library vunit_lib;
context vunit_lib.vunit_context;
library str_format;
use str_format.str_format_pkg.all;

package body plheader_tables_pkg is

  constant G : std_logic_array_t(0 to 6)(31 downto 0) := (
    0 => x"90AC2DDD", 1 => x"55555555", 2 => x"33333333", 3 => x"0F0F0F0F",
    4 => x"00FF00FF", 5 => x"0000FFFF", 6 => x"FFFFFFFF");

  constant PLFRAME_HEADER_SOF  : std_logic_vector(25 downto 0) := "01" & x"8D2E82";
  constant PL_HDR_SCRAMBLE_TAB : std_logic_vector(63 downto 0) := "0111000110011101100000111100100101010011010000100010110111111010";

  impure function to_fixed_point (constant x : real; constant width : natural) return signed is
  begin
    return to_signed(integer(ieee.math_real.round(x * real(2**(width - 1)))), width);
  end;

  impure function cos (constant x : real; constant width : natural) return signed is
  begin
    return to_fixed_point(ieee.math_real.cos(x), width);
  end;

  impure function sin (constant x : real; constant width : natural) return signed is
  begin
    return to_fixed_point(ieee.math_real.sin(x), width);
  end;

  impure function get_iq_pair (constant x : real; constant width : natural) return std_logic_vector is
    variable sin_x : std_logic_vector(width - 1 downto 0);
    variable cos_x : std_logic_vector(width - 1 downto 0);
  begin
    sin_x := std_logic_vector(sin(x, width));
    cos_x := std_logic_vector(cos(x, width));
    return sin_x & cos_x;
  end;

  constant MOD_8PSK_MAP : std_logic_2d_array_t(0 to 3, 0 to 1)(31 downto 0) := (
    0 => (0 => std_logic_vector(cos(      MATH_PI / 4.0, 16) & sin(      MATH_PI / 4.0, 16)),
          1 => std_logic_vector(cos(5.0 * MATH_PI / 4.0, 16) & sin(5.0 * MATH_PI / 4.0, 16))),
    1 => (0 => std_logic_vector(cos(5.0 * MATH_PI / 4.0, 16) & sin(      MATH_PI / 4.0, 16)),
          1 => std_logic_vector(cos(      MATH_PI / 4.0, 16) & sin(5.0 * MATH_PI / 4.0, 16))),
    2 => (0 => std_logic_vector(cos(5.0 * MATH_PI / 4.0, 16) & sin(      MATH_PI / 4.0, 16)),
          1 => std_logic_vector(cos(      MATH_PI / 4.0, 16) & sin(5.0 * MATH_PI / 4.0, 16))),
    3 => (0 => std_logic_vector(cos(5.0 * MATH_PI / 4.0, 16) & sin(5.0 * MATH_PI / 4.0, 16)),
          1 => std_logic_vector(cos(      MATH_PI / 4.0, 16) & sin(      MATH_PI / 4.0, 16)))
  );

  -- m_bpsk[0][0] = gr_complex( (r0 * cos(      GR_M_PI / 4.0)),  (r0 * sin(      GR_M_PI / 4.0)));
  -- m_bpsk[0][1] = gr_complex( (r0 * cos(5.0 * GR_M_PI / 4.0)),  (r0 * sin(5.0 * GR_M_PI / 4.0)));
  -- m_bpsk[1][0] = gr_complex( (r0 * cos(5.0 * GR_M_PI / 4.0)),  (r0 * sin(      GR_M_PI / 4.0)));
  -- m_bpsk[1][1] = gr_complex( (r0 * cos(      GR_M_PI / 4.0)),  (r0 * sin(5.0 * GR_M_PI / 4.0)));
  -- m_bpsk[2][0] = gr_complex( (r0 * cos(5.0 * GR_M_PI / 4.0)),  (r0 * sin(      GR_M_PI / 4.0)));
  -- m_bpsk[2][1] = gr_complex( (r0 * cos(      GR_M_PI / 4.0)),  (r0 * sin(5.0 * GR_M_PI / 4.0)));
  -- m_bpsk[3][0] = gr_complex( (r0 * cos(5.0 * GR_M_PI / 4.0)),  (r0 * sin(5.0 * GR_M_PI / 4.0)));
  -- m_bpsk[3][1] = gr_complex( (r0 * cos(      GR_M_PI / 4.0)),  (r0 * sin(      GR_M_PI / 4.0)));


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

    -- if constellation /= not_set and code_rate /= not_set then
    --   report "No MODOCDE for constellation=" & constellation_t'image(constellation) & ", code_rate=" & code_rate_t'image(code_rate)
    --     severity warning;
    -- end if;
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
    variable temp    : std_logic_vector(31 downto 0) := (others => '0');
    variable bit_var : std_logic_vector(31 downto 0) := (31 => '1', others => '0');
    variable result  : std_logic_vector(63 downto 0);
  begin
    if or(v and x"80") then
      temp := temp xor G(0);
    end if;
    if or(v and x"40") then
      temp := temp xor G(1);
    end if;
    if or(v and x"20") then
      temp := temp xor G(2);
    end if;
    if or(v and x"10") then
      temp := temp xor G(3);
    end if;
    if or(v and x"08") then
      temp := temp xor G(4);
    end if;
    if or(v and x"04") then
      temp := temp xor G(5);
    end if;
    if or(v and x"02") then
      temp := temp xor G(6);
    end if;

    for m in 0 to 31 loop
      if or(temp and bit_var) then
        result(m*2) := '1';
      else
        result(m*2) := '0';
      end if;

      if or(result(m*2) xor (v and x"01")) then
        result((m*2) + 1) := '1';
      else
        result((m*2) + 1) := '0';
      end if;

      bit_var := '0' & bit_var(31 downto 1);

    end loop;

    info(sformat("Encoded %r into %r", fo(v), fo(result)));
    for m in 0 to 63 loop
      result(m) := result(m) xor PL_HDR_SCRAMBLE_TAB(m);
    end loop;
    info(sformat("Encoded %r into %r", fo(v), fo(result)));

    return result;
  end function;

-- void dvbs2_physical_cc_impl::pl_header_encode(unsigned char modcod,
--                                             unsigned char type,
--                                             int* out)
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

  function modulate (constant v : std_logic_vector) return std_logic_vector is
    variable result : std_logic_vector(32*v'length - 1 downto 0);
  begin
    -- for i in 0 to 89 loop
    for i in 89 downto 0 loop
      if v(i) = '0' then
        result(32*(i + 1) - 1 downto 32*i) := std_logic_vector(MOD_8PSK_MAP(i mod 2, 0));
      else
        result(32*(i + 1) - 1 downto 32*i) := std_logic_vector(MOD_8PSK_MAP(i mod 2, 1));
      --   info(sformat("- [%d] %r", fo(i), fo(MOD_8PSK_MAP(i mod 2, 0))));
      -- else
      --   info(sformat("- [%d] %r", fo(i), fo(MOD_8PSK_MAP(i mod 2, 1))));
      end if;
    end loop;

    return result;
  end function;

  impure function get_plframe_header(
    constant constellation : in constellation_t;
    constant frame_type    : in frame_type_t;
    constant code_rate     : in code_rate_t) return std_logic_vector is

    variable header        : std_logic_vector (PLFRAME_HEADER_LENGTH - 1 downto 0);
    variable modcode       : std_logic_vector(7 downto 0);
    variable type_code     : std_logic_vector(7 downto 0);

    variable plscode       : std_logic_vector(63 downto 0) := (others => '0');

    variable has_pilots    : boolean := True;

  begin
    modcode := std_logic_vector(to_unsigned(get_modcode(constellation, code_rate), 8));
    if frame_type = fecframe_normal then
      type_code := x"00";
    elsif frame_type = fecframe_short then
      type_code := x"02";
    end if;

    if has_pilots then
      type_code(0) := '0';
    end if;

    -- Left side bit for SOF being the MSB of PL_HEADER
    -- concatenate to form PL header
    header := PLFRAME_HEADER_SOF & pl_header_encode(modcode, type_code);

    debug(sformat("Unmodulated header: %r", fo(header)));

    return modulate(header);

    -- for i in 0 to 89 loop
    --   if header(i) = '0' then
    --     info(sformat("- [%d] %r", fo(i), fo(MOD_8PSK_MAP(i mod 2, 0))));
    --   else
    --     info(sformat("- [%d] %r", fo(i), fo(MOD_8PSK_MAP(i mod 2, 1))));
    --   end if;
    -- end loop;

    -- return header;
  end function get_plframe_header;


  impure function get_plframe_header_rom return std_logic_array_t is
    impure function get_rom_depth return integer is
      variable addr  : integer := -2;
      variable depth : integer := 0;
      variable cnt   : integer := 0;
    begin
      for constellation in constellation_t'left to constellation_t'right loop
        for code_rate in code_rate_t'left to code_rate_t'right loop
          for frame_type in frame_type_t'left to frame_type_t'right loop
            addr := get_rom_addr(constellation, frame_type, code_rate);
            if addr >= 0 then
              -- info(sformat("[%2d] addr=%2d for %10s, %15s, %5s",
              --   fo(depth),
              --   fo(addr),
              --   fo(constellation_t'image(constellation)),
              --   fo(frame_type_t'image(frame_type)),
              --   fo(code_rate_t'image(code_rate))));
              depth := max(addr, depth);
              cnt := cnt + 1;
            end if;
          end loop;
        end loop;
      end loop;
      info(sformat("ROM depth is %d (%d entries)", fo(depth), fo(cnt)));
      return depth;
    end;
    constant ROM_DEPTH : integer := get_rom_depth;
    variable result    : std_logic_array_t(0 to ROM_DEPTH)(2880 - 1 downto 0);
    variable addr      : integer;
  begin
    warning(sformat("Populating header ROM (%dx%d)", fo(PLFRAME_HEADER_LENGTH), fo(ROM_DEPTH)));
    for i in 0 to 3 loop
      for j in 0 to 1 loop
        info(sformat("MOD_8PSK_MAP(%d, %d) = %r", fo(i), fo(j), fo(MOD_8PSK_MAP(i, j))));
      end loop;
    end loop;

    for constellation in constellation_t'left to constellation_t'right loop
      for code_rate in code_rate_t'left to code_rate_t'right loop
        for frame_type in frame_type_t'left to frame_type_t'right loop
          addr := get_rom_addr(constellation, frame_type, code_rate);
          if addr /= -1 then
            info(
              sformat(
                "Populating addr=%2d for %10s, %15s, %5s",
                fo(addr),
                fo(constellation_t'image(constellation)),
                fo(frame_type_t'image(frame_type)),
                fo(code_rate_t'image(code_rate))));
            result(addr) := get_plframe_header(constellation, frame_type, code_rate);
          end if;
        end loop;
      end loop;
    end loop;
    return result;
  end function get_plframe_header_rom;

  function get_rom_addr (
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

end package body plheader_tables_pkg;

-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
