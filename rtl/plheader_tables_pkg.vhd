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
--use ieee.math_real.MATH_PI;

library fpga_cores;
use fpga_cores.common_pkg.all;

use work.dvb_utils_pkg.all;

package plheader_tables_pkg is
  /* 
  --------
  --Types-
  --------
  type unsigned_32_vector_t is array(0 to 6) of unsigned;
  type  pl_hdr_table_t is array (0 to 20) of std_logic_vector(89 downto 0);

  type protected_t is protected
    procedure build_plheader(
       constant constellation : in constellation_t;
       constant code_rate : in code_rate_t);
    impure function get_plheader(
       constant constellation : constellation_t;
       constant code_rate :  code_rate_t) return std_logic_vector;
  end protected;
  shared variable shared_plheader : protected_t;
  constant PL_HDR_LEN : integer := 90;
  constant PL_HDR_SOF_LEN : integer := 26;
  constant PL_HDR_SCRAMBLE_LEN : integer := 64;
  constant DATA_WIDTH : natural := 32;
  
  constant G : unsigned_32_vector_t := (0 => x"90AC2DDD",
      1 => x"55555555", 2 => x"33333333", 3 => x"0F0F0F0F", 
      4 => x"00FF00FF", 5 => x"0000FFFF", 6=> x"FFFFFFFF");
  */
end package plheader_tables_pkg;

package body plheader_tables_pkg is  
  /*
  function to_fixed_point (constant x : real) return signed is
  constant width : natural := DATA_WIDTH/2 - 1;
  constant round_a : integer := integer(ieee.math_real.round(x * real(2**width)));
  variable a     : signed(width - 1 downto 0) := to_signed(round_a, width);
begin
  if a < 0 then
    a := to_signed(round_a, width);
    a := abs a;
    a := not a;
    a := a + 1;
    a := a + ( 2 ** width );
  end if;
  return a;
end;

function encode_constellation( constant v : constellation_t ) return std_logic_vector is
begin
  if v = not_set then
    return (CONSTELLATION_WIDTH - 1 downto 0 => 'U');
  end if;
  return std_logic_vector(to_unsigned(constellation_t'pos(v), CONSTELLATION_WIDTH));
end;

function cos (constant x : real) return unsigned is
begin
  return unsigned(resize(to_fixed_point(ieee.math_real.cos(x)), DATA_WIDTH/2));
end;

function sin (constant x : real) return unsigned is
begin
  return unsigned(resize(to_fixed_point(ieee.math_real.sin(x)), DATA_WIDTH/2));
end;

function get_iq_pair (constant x : real) return std_logic_vector is
  variable sin_x : std_logic_vector(DATA_WIDTH -1 downto 0);
  variable cos_x : std_logic_vector(DATA_WIDTH -1 downto 0);
begin
  sin_x := std_logic_vector(sin(x));
  cos_x := std_logic_vector(cos(x));
  return sin_x & cos_x;
end;

constant MOD_8PSK_MAP : std_logic_vector_2d_t(0 to 7)(DATA_WIDTH - 1 downto 0) := (
    0 => get_iq_pair(      MATH_PI / 4.0),
    1 => get_iq_pair(0.0),
    2 => get_iq_pair(4.0 * MATH_PI / 4.0),
    3 => get_iq_pair(5.0 * MATH_PI / 4.0),
    4 => get_iq_pair(2.0 * MATH_PI / 4.0),
    5 => get_iq_pair(7.0 * MATH_PI / 4.0),
    6 => get_iq_pair(3.0 * MATH_PI / 4.0),
    7 => get_iq_pair(6.0 * MATH_PI / 4.0)
  );
     
  function set_modcod (
    constant constellation : in constellation_t;
    constant code_rate : in code_rate_t) return unsigned is
    variable modcode :  unsigned (7 to 0) := (others => '0');
  begin
    if (constellation = mod_8psk) then
      case code_rate is
        when C3_5 => modcode := to_unsigned(integer(12), 8);
        when C2_3 => modcode := to_unsigned(integer(13), 8);
        when C3_4 => modcode := to_unsigned(integer(14), 8);
        when C5_6 => modcode := to_unsigned(integer(15), 8);
        when C8_9 => modcode := to_unsigned(integer(16), 8);
        when C9_10 => modcode := to_unsigned(integer(17), 8);
        when others => modcode := to_unsigned(integer(0), 8);
      end case;
    end if;
  
    if constellation = mod_16apsk then
      case code_rate is
        when C2_3 => modcode := to_unsigned(integer(18), 8);
        when C3_4 => modcode := to_unsigned(integer(19), 8);
        when C4_5 => modcode := to_unsigned(integer(20), 8);
        when C5_6 => modcode := to_unsigned(integer(21), 8);
        when C8_9 => modcode := to_unsigned(integer(22), 8);
        when C9_10 => modcode := to_unsigned(integer(23), 8);
        when others => modcode := to_unsigned(integer(0), 8);
      end case;
    end if;

    if constellation = mod_32apsk then
      case code_rate is
        when C3_4 => modcode := to_unsigned(integer(24), 8);
        when C4_5 => modcode := to_unsigned(integer(25), 8);
        when C5_6 => modcode := to_unsigned(integer(26), 8);
        when C8_9 => modcode := to_unsigned(integer(27), 8);
        when C9_10 => modcode := to_unsigned(integer(28), 8);
        when others => modcode := to_unsigned(integer(0), 8);
      end case;
    end if;
    
    return modcode;
  end;

  type protected_t is protected body
    variable pl_header_table : pl_hdr_table_t;
    procedure build_plheader(
    constant constellation : in constellation_t;
      constant code_rate : in code_rate_t) is
        
    variable pl_header : std_logic_vector (PL_HDR_LEN - 1 downto 0); 
    constant PL_HDR_SOF : std_logic_vector (PL_HDR_SOF_LEN -1 downto 0) := ("01100011010010111010000010");
    variable modcode : unsigned(7 downto 0) := (others => '0');
    variable modbit : unsigned (31 downto 0) := x"80000000";
    
    variable plscode : std_logic_vector(63 downto 0) := (others => '0'); 
    constant PL_HDR_SCRAMBLE_TAB : std_logic_vector (PL_HDR_SCRAMBLE_LEN -1 downto 0) :=
        ("0111000110011101100000111100100101010011010000100010110111111010");
        
    -- no pilot insertion and  FECFRAMESIZE 64800
    variable type_code : unsigned (1 downto 0) := (others => '0');
    variable code : unsigned (7 downto 0) := (others => '0');
    variable res : unsigned (7 downto 0) := (others => '0');
    variable temp : unsigned (31 downto 0);
  
  begin
    modcode := set_modcod(constellation, code_rate);
    
    -- Left side bit for SOF being the MSB of PL_HEADER
    -- concatenate to form PL header
    pl_header :=  PL_HDR_SOF(25 downto 0) & 
      pl_header(PL_HDR_LEN -1 downto PL_HDR_SOF_LEN);
    
    -- pl header encode 
    res := modcode and x"80";
    if res /= x"00" then
      code := modcode or ( type_code and x"01");
    else
      code := (modcode (7 downto 2) & '0') or type_code;
    end if;

    --scrambling process start. Can move to different function
    -- move below code to a different function.
    -- b_64_8_code
    res := code and x"80";
    if res /= x"00" then
      temp := temp xor G(0);
    end if;
    
    res := code and x"40";
    if res /= x"00" then
      temp := temp xor G(1);
    end if;

    res := code and x"20";
    if res /= x"00" then
      temp := temp xor G(2);
    end if;
   
    res := code and x"10";
    if res /= x"00" then
      temp := temp xor G(3);
    end if;
    
    res := code and x"08";
    if res /= x"00" then
      temp := temp xor G(4);
    end if;
    
    res := code and x"04";
    if res /= x"00" then
      temp := temp xor G(5);
    end if;
    
    res := code and x"02";
    if res /= x"00" then
      temp := temp xor G(6);
    end if;
      
    for m in 0 to 31 loop
      temp := temp and modbit;
      if temp /= x"00000000" then
        plscode(m *2) := '1'; 
      else
        plscode(m *2) := '0';
      end if ;
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
    pl_header(63 downto 0) :=  plscode(63 downto 0);
        

    if (constellation = mod_8psk) then
      case code_rate is
       when C3_5 => pl_header_table(0) := pl_header;
       when C2_3 => pl_header_table(1) := pl_header;
       when C3_4 => pl_header_table(2) := pl_header;
       when C5_6 => pl_header_table(3) := pl_header;
       when C8_9 => pl_header_table(4) := pl_header;
       when C9_10 => pl_header_table(5) := pl_header;
       when others => pl_header_table(6) := pl_header;
      end case;
    end if;
      
    if constellation = mod_16apsk then
        case code_rate is
       when C2_3 => pl_header_table(7) := pl_header;
       when C3_4 => pl_header_table(8) := pl_header;
       when C4_5 => pl_header_table(9) := pl_header;
       when C5_6 => pl_header_table(10) := pl_header;
       when C8_9 => pl_header_table(11) := pl_header;
       when C9_10 => pl_header_table(12) := pl_header;
       when others => pl_header_table(13) := pl_header;
      end case;
    end if;
    
    if constellation = mod_32apsk then
      case code_rate is
        when C3_4 => pl_header_table(14) := pl_header;
        when C4_5 => pl_header_table(15) := pl_header;
        when C5_6 => pl_header_table(16) := pl_header;
        when C8_9 => pl_header_table(17) := pl_header;
        when C9_10 => pl_header_table(18) := pl_header;
        when others => pl_header_table(19) := pl_header;
     end case;
   end if;  
  end procedure;

     impure function  get_plheader(
     constant constellation : constellation_t;
       constant code_rate :  code_rate_t) return std_logic_vector is
   begin
     if (constellation = mod_8psk) then
       case code_rate is
           when C3_5 => return pl_header_table(0);
           when C2_3 => return pl_header_table(1);
           when C3_4 => return pl_header_table(2);
           when C5_6 => return pl_header_table(3);
           when C8_9 => return pl_header_table(4);
           when C9_10 => return pl_header_table(5);
           when others => return pl_header_table(6);
       end case;
     end if;
   
     if constellation = mod_16apsk then
       case code_rate is
          when C2_3 => return pl_header_table(7);
          when C3_4 => return pl_header_table(8);
          when C4_5 => return pl_header_table(9);
          when C5_6 => return pl_header_table(10);
          when C8_9 => return pl_header_table(11);
          when C9_10 => return pl_header_table(12);
          when others => return pl_header_table(13);
       end case; 
     end if;
   
     if constellation = mod_32apsk then
       case code_rate is
          when C3_4 => return pl_header_table(14);
          when C4_5 => return pl_header_table(15);
          when C5_6 => return pl_header_table(16);
          when C8_9 => return pl_header_table(17);
          when C9_10 => return pl_header_table(18);
          when others => return pl_header_table(19);
      end case;  
     end if;
   end function;
  end protected body;
  */
end package body plheader_tables_pkg;
  
  -- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
