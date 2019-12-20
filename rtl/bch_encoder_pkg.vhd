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

    type bch_encoder_cfg is record
        normal_frame_length : std_logic;
        bch_code            : std_logic_vector(1 downto 0);
    end record bch_encoder_cfg;

    constant BCH_NORMAL_FRAME_SIZE : integer := 64_800;
    constant BCH_SHORT_FRAME_SIZE : integer := 16_200;

    -- constant BB_NORMAL_FRAME_SIZE : integer := 64_800;
    -- constant BB_SHORT_FRAME_SIZE : integer := 16_200;

    type bch_frame_length is (normal, short);

    constant BCH_POLY_8 : integer := 0;
    constant BCH_POLY_10 : integer := 1;
    constant BCH_POLY_12 : integer := 2;

    type bch_192x8_context is record
        crc  : std_logic_vector(191 downto 0);
        data : std_logic_vector(7 downto 0);
    end record;

    impure function next_bch_192x8 (
        constant data     : in std_logic_vector(7 downto 0);
        constant crc      : in std_logic_vector(191 downto 0)) return std_logic_vector;

    impure function to_string (constant crc : bch_192x8_context) return string;

end bch_encoder_pkg;

package body bch_encoder_pkg is

    impure function next_bch_192x8 (
        constant data     : in std_logic_vector(7 downto 0);
        constant crc      : in std_logic_vector(191 downto 0)) return std_logic_vector is
        variable dq       : std_logic_vector(191 downto 0);
        variable next_crc : std_logic_vector(191 downto 0);
	begin

        dq(  0) := data(  7) xor data(  5) xor data(  4) xor data(  2) xor data(  0);
        dq(  1) := data(  7) xor data(  6) xor data(  4) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq(  2) := data(  3) xor data(  1) xor data(  0);
        dq(  3) := data(  4) xor data(  2) xor data(  1);
        dq(  4) := data(  5) xor data(  3) xor data(  2);
        dq(  5) := data(  7) xor data(  6) xor data(  5) xor data(  3) xor data(  2) xor data(  0);
        dq(  6) := data(  6) xor data(  5) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq(  7) := data(  6) xor data(  5) xor data(  3) xor data(  1) xor data(  0);
        dq(  8) := data(  6) xor data(  5) xor data(  1) xor data(  0);
        dq(  9) := data(  7) xor data(  6) xor data(  2) xor data(  1);
        dq( 10) := data(  5) xor data(  4) xor data(  3) xor data(  0);
        dq( 11) := data(  6) xor data(  5) xor data(  4) xor data(  1);
        dq( 12) := data(  6) xor data(  4) xor data(  0);
        dq( 13) := data(  7) xor data(  5) xor data(  1);
        dq( 14) := data(  7) xor data(  6) xor data(  5) xor data(  4) xor data(  0);
        dq( 15) := data(  7) xor data(  6) xor data(  5) xor data(  1);
        dq( 16) := data(  7) xor data(  6) xor data(  2);
        dq( 17) := data(  5) xor data(  4) xor data(  3) xor data(  2) xor data(  0);
        dq( 18) := data(  6) xor data(  5) xor data(  4) xor data(  3) xor data(  1);
        dq( 19) := data(  7) xor data(  6) xor data(  5) xor data(  4) xor data(  2);
        dq( 20) := data(  7) xor data(  6) xor data(  5) xor data(  3);
        dq( 21) := data(  7) xor data(  6) xor data(  4);
        dq( 22) := data(  7) xor data(  5);
        dq( 23) := data(  6);
        dq( 24) := data(  7);
        dq( 25) := data(  7) xor data(  5) xor data(  4) xor data(  2) xor data(  0);
        dq( 26) := data(  7) xor data(  6) xor data(  4) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq( 27) := data(  7) xor data(  5) xor data(  4) xor data(  3) xor data(  2) xor data(  1);
        dq( 28) := data(  6) xor data(  5) xor data(  4) xor data(  3) xor data(  2);
        dq( 29) := data(  6) xor data(  3) xor data(  2) xor data(  0);
        dq( 30) := data(  5) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq( 31) := data(  6) xor data(  4) xor data(  3) xor data(  2) xor data(  1);
        dq( 32) := data(  3) xor data(  0);
        dq( 33) := data(  7) xor data(  5) xor data(  2) xor data(  1) xor data(  0);
        dq( 34) := data(  7) xor data(  6) xor data(  5) xor data(  4) xor data(  3) xor data(  1) xor data(  0);
        dq( 35) := data(  7) xor data(  6) xor data(  5) xor data(  4) xor data(  2) xor data(  1);
        dq( 36) := data(  6) xor data(  4) xor data(  3) xor data(  0);
        dq( 37) := data(  2) xor data(  1) xor data(  0);
        dq( 38) := data(  7) xor data(  5) xor data(  4) xor data(  3) xor data(  1) xor data(  0);
        dq( 39) := data(  7) xor data(  6) xor data(  1) xor data(  0);
        dq( 40) := data(  5) xor data(  4) xor data(  1) xor data(  0);
        dq( 41) := data(  6) xor data(  5) xor data(  2) xor data(  1);
        dq( 42) := data(  6) xor data(  5) xor data(  4) xor data(  3) xor data(  0);
        dq( 43) := data(  7) xor data(  6) xor data(  5) xor data(  4) xor data(  1);
        dq( 44) := data(  7) xor data(  6) xor data(  5) xor data(  2);
        dq( 45) := data(  7) xor data(  6) xor data(  3);
        dq( 46) := data(  7) xor data(  4);
        dq( 47) := data(  7) xor data(  4) xor data(  2) xor data(  0);
        dq( 48) := data(  7) xor data(  4) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq( 49) := data(  7) xor data(  3) xor data(  1) xor data(  0);
        dq( 50) := data(  7) xor data(  5) xor data(  1) xor data(  0);
        dq( 51) := data(  6) xor data(  2) xor data(  1);
        dq( 52) := data(  7) xor data(  3) xor data(  2);
        dq( 53) := data(  4) xor data(  3);
        dq( 54) := data(  7) xor data(  2) xor data(  0);
        dq( 55) := data(  3) xor data(  1);
        dq( 56) := data(  7) xor data(  5) xor data(  0);
        dq( 57) := data(  7) xor data(  6) xor data(  5) xor data(  4) xor data(  2) xor data(  1) xor data(  0);
        dq( 58) := data(  7) xor data(  6) xor data(  5) xor data(  3) xor data(  2) xor data(  1);
        dq( 59) := data(  7) xor data(  6) xor data(  4) xor data(  3) xor data(  2);
        dq( 60) := data(  7) xor data(  5) xor data(  4) xor data(  3);
        dq( 61) := data(  6) xor data(  5) xor data(  4);
        dq( 62) := data(  7) xor data(  6) xor data(  5);
        dq( 63) := data(  7) xor data(  6);
        dq( 64) := data(  5) xor data(  4) xor data(  2) xor data(  0);
        dq( 65) := data(  6) xor data(  5) xor data(  3) xor data(  1);
        dq( 66) := data(  7) xor data(  6) xor data(  4) xor data(  2);
        dq( 67) := data(  4) xor data(  3) xor data(  2) xor data(  0);
        dq( 68) := data(  5) xor data(  4) xor data(  3) xor data(  1);
        dq( 69) := data(  6) xor data(  5) xor data(  4) xor data(  2);
        dq( 70) := data(  7) xor data(  6) xor data(  5) xor data(  3);
        dq( 71) := data(  6) xor data(  5) xor data(  2) xor data(  0);
        dq( 72) := data(  7) xor data(  6) xor data(  3) xor data(  1);
        dq( 73) := data(  7) xor data(  4) xor data(  2);
        dq( 74) := data(  5) xor data(  3);
        dq( 75) := data(  7) xor data(  6) xor data(  5) xor data(  2) xor data(  0);
        dq( 76) := data(  7) xor data(  6) xor data(  3) xor data(  1);
        dq( 77) := data(  7) xor data(  4) xor data(  2);
        dq( 78) := data(  5) xor data(  3);
        dq( 79) := data(  6) xor data(  4);
        dq( 80) := data(  4) xor data(  2) xor data(  0);
        dq( 81) := data(  5) xor data(  3) xor data(  1);
        dq( 82) := data(  7) xor data(  6) xor data(  5) xor data(  0);
        dq( 83) := data(  7) xor data(  6) xor data(  1);
        dq( 84) := data(  5) xor data(  4) xor data(  0);
        dq( 85) := data(  7) xor data(  6) xor data(  4) xor data(  2) xor data(  1) xor data(  0);
        dq( 86) := data(  7) xor data(  5) xor data(  3) xor data(  2) xor data(  1);
        dq( 87) := data(  6) xor data(  4) xor data(  3) xor data(  2);
        dq( 88) := data(  7) xor data(  5) xor data(  4) xor data(  3);
        dq( 89) := data(  6) xor data(  5) xor data(  4);
        dq( 90) := data(  6) xor data(  4) xor data(  2) xor data(  0);
        dq( 91) := data(  4) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq( 92) := data(  7) xor data(  3) xor data(  1) xor data(  0);
        dq( 93) := data(  4) xor data(  2) xor data(  1);
        dq( 94) := data(  7) xor data(  4) xor data(  3) xor data(  0);
        dq( 95) := data(  7) xor data(  2) xor data(  1) xor data(  0);
        dq( 96) := data(  3) xor data(  2) xor data(  1);
        dq( 97) := data(  4) xor data(  3) xor data(  2);
        dq( 98) := data(  5) xor data(  4) xor data(  3);
        dq( 99) := data(  7) xor data(  6) xor data(  2) xor data(  0);
        dq(100) := data(  5) xor data(  4) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq(101) := data(  6) xor data(  5) xor data(  4) xor data(  3) xor data(  2) xor data(  1);
        dq(102) := data(  6) xor data(  3) xor data(  0);
        dq(103) := data(  5) xor data(  2) xor data(  1) xor data(  0);
        dq(104) := data(  6) xor data(  3) xor data(  2) xor data(  1);
        dq(105) := data(  7) xor data(  4) xor data(  3) xor data(  2);
        dq(106) := data(  7) xor data(  3) xor data(  2) xor data(  0);
        dq(107) := data(  7) xor data(  5) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq(108) := data(  6) xor data(  4) xor data(  3) xor data(  2) xor data(  1);
        dq(109) := data(  3) xor data(  0);
        dq(110) := data(  4) xor data(  1);
        dq(111) := data(  5) xor data(  2);
        dq(112) := data(  7) xor data(  6) xor data(  5) xor data(  4) xor data(  3) xor data(  2) xor data(  0);
        dq(113) := data(  6) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq(114) := data(  5) xor data(  3) xor data(  1) xor data(  0);
        dq(115) := data(  7) xor data(  6) xor data(  5) xor data(  1) xor data(  0);
        dq(116) := data(  7) xor data(  6) xor data(  2) xor data(  1);
        dq(117) := data(  7) xor data(  3) xor data(  2);
        dq(118) := data(  7) xor data(  5) xor data(  3) xor data(  2) xor data(  0);
        dq(119) := data(  7) xor data(  6) xor data(  5) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq(120) := data(  7) xor data(  6) xor data(  4) xor data(  3) xor data(  2) xor data(  1);
        dq(121) := data(  7) xor data(  5) xor data(  4) xor data(  3) xor data(  2);
        dq(122) := data(  6) xor data(  5) xor data(  4) xor data(  3);
        dq(123) := data(  7) xor data(  6) xor data(  5) xor data(  4);
        dq(124) := data(  6) xor data(  4) xor data(  2) xor data(  0);
        dq(125) := data(  7) xor data(  5) xor data(  3) xor data(  1);
        dq(126) := data(  7) xor data(  6) xor data(  5) xor data(  0);
        dq(127) := data(  7) xor data(  6) xor data(  1);
        dq(128) := data(  7) xor data(  2);
        dq(129) := data(  3);
        dq(130) := data(  7) xor data(  5) xor data(  2) xor data(  0);
        dq(131) := data(  7) xor data(  6) xor data(  5) xor data(  4) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq(132) := data(  6) xor data(  3) xor data(  1) xor data(  0);
        dq(133) := data(  7) xor data(  4) xor data(  2) xor data(  1);
        dq(134) := data(  5) xor data(  3) xor data(  2);
        dq(135) := data(  6) xor data(  4) xor data(  3);
        dq(136) := data(  2) xor data(  0);
        dq(137) := data(  3) xor data(  1);
        dq(138) := data(  4) xor data(  2);
        dq(139) := data(  5) xor data(  3);
        dq(140) := data(  7) xor data(  6) xor data(  5) xor data(  2) xor data(  0);
        dq(141) := data(  7) xor data(  6) xor data(  3) xor data(  1);
        dq(142) := data(  5) xor data(  0);
        dq(143) := data(  6) xor data(  1);
        dq(144) := data(  7) xor data(  2);
        dq(145) := data(  3);
        dq(146) := data(  7) xor data(  5) xor data(  2) xor data(  0);
        dq(147) := data(  7) xor data(  6) xor data(  5) xor data(  4) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq(148) := data(  6) xor data(  3) xor data(  1) xor data(  0);
        dq(149) := data(  7) xor data(  4) xor data(  2) xor data(  1);
        dq(150) := data(  7) xor data(  4) xor data(  3) xor data(  0);
        dq(151) := data(  5) xor data(  4) xor data(  1);
        dq(152) := data(  6) xor data(  5) xor data(  2);
        dq(153) := data(  7) xor data(  6) xor data(  3);
        dq(154) := data(  5) xor data(  2) xor data(  0);
        dq(155) := data(  6) xor data(  3) xor data(  1);
        dq(156) := data(  7) xor data(  4) xor data(  2);
        dq(157) := data(  5) xor data(  3);
        dq(158) := data(  6) xor data(  4);
        dq(159) := data(  4) xor data(  2) xor data(  0);
        dq(160) := data(  7) xor data(  4) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq(161) := data(  7) xor data(  3) xor data(  1) xor data(  0);
        dq(162) := data(  4) xor data(  2) xor data(  1);
        dq(163) := data(  5) xor data(  3) xor data(  2);
        dq(164) := data(  6) xor data(  4) xor data(  3);
        dq(165) := data(  7) xor data(  5) xor data(  4);
        dq(166) := data(  6) xor data(  5);
        dq(167) := data(  6) xor data(  5) xor data(  4) xor data(  2) xor data(  0);
        dq(168) := data(  7) xor data(  6) xor data(  5) xor data(  3) xor data(  1);
        dq(169) := data(  6) xor data(  5) xor data(  0);
        dq(170) := data(  6) xor data(  5) xor data(  4) xor data(  2) xor data(  1) xor data(  0);
        dq(171) := data(  6) xor data(  4) xor data(  3) xor data(  1) xor data(  0);
        dq(172) := data(  7) xor data(  5) xor data(  4) xor data(  2) xor data(  1);
        dq(173) := data(  6) xor data(  5) xor data(  3) xor data(  2);
        dq(174) := data(  7) xor data(  6) xor data(  4) xor data(  3);
        dq(175) := data(  7) xor data(  5) xor data(  4);
        dq(176) := data(  6) xor data(  5);
        dq(177) := data(  6) xor data(  5) xor data(  4) xor data(  2) xor data(  0);
        dq(178) := data(  6) xor data(  4) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq(179) := data(  7) xor data(  5) xor data(  4) xor data(  3) xor data(  2) xor data(  1);
        dq(180) := data(  6) xor data(  5) xor data(  4) xor data(  3) xor data(  2);
        dq(181) := data(  6) xor data(  3) xor data(  2) xor data(  0);
        dq(182) := data(  7) xor data(  4) xor data(  3) xor data(  1);
        dq(183) := data(  5) xor data(  4) xor data(  2);
        dq(184) := data(  6) xor data(  5) xor data(  3);
        dq(185) := data(  6) xor data(  5) xor data(  2) xor data(  0);
        dq(186) := data(  6) xor data(  5) xor data(  4) xor data(  3) xor data(  2) xor data(  1) xor data(  0);
        dq(187) := data(  6) xor data(  3) xor data(  1) xor data(  0);
        dq(188) := data(  7) xor data(  4) xor data(  2) xor data(  1);
        dq(189) := data(  5) xor data(  3) xor data(  2);
        dq(190) := data(  7) xor data(  6) xor data(  5) xor data(  3) xor data(  2) xor data(  0);
        dq(191) := data(  7) xor data(  6) xor data(  4) xor data(  3) xor data(  1);

        report sformat("data=%r || dq=%r", fo(data), fo(dq));

        next_crc(  0) := crc(184) xor crc(186) xor crc(188) xor crc(189) xor crc(191) xor dq(  0);
        next_crc(  1) := crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(190) xor crc(191) xor dq(  1);
        next_crc(  2) := crc(184) xor crc(185) xor crc(187) xor dq(  2);
        next_crc(  3) := crc(185) xor crc(186) xor crc(188) xor dq(  3);
        next_crc(  4) := crc(186) xor crc(187) xor crc(189) xor dq(  4);
        next_crc(  5) := crc(184) xor crc(186) xor crc(187) xor crc(189) xor crc(190) xor crc(191) xor dq(  5);
        next_crc(  6) := crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(189) xor crc(190) xor dq(  6);
        next_crc(  7) := crc(184) xor crc(185) xor crc(187) xor crc(189) xor crc(190) xor dq(  7);
        next_crc(  8) := crc(  0) xor crc(184) xor crc(185) xor crc(189) xor crc(190) xor dq(  8);
        next_crc(  9) := crc(  1) xor crc(185) xor crc(186) xor crc(190) xor crc(191) xor dq(  9);
        next_crc( 10) := crc(  2) xor crc(184) xor crc(187) xor crc(188) xor crc(189) xor dq( 10);
        next_crc( 11) := crc(  3) xor crc(185) xor crc(188) xor crc(189) xor crc(190) xor dq( 11);
        next_crc( 12) := crc(  4) xor crc(184) xor crc(188) xor crc(190) xor dq( 12);
        next_crc( 13) := crc(  5) xor crc(185) xor crc(189) xor crc(191) xor dq( 13);
        next_crc( 14) := crc(  6) xor crc(184) xor crc(188) xor crc(189) xor crc(190) xor crc(191) xor dq( 14);
        next_crc( 15) := crc(  7) xor crc(185) xor crc(189) xor crc(190) xor crc(191) xor dq( 15);
        next_crc( 16) := crc(  8) xor crc(186) xor crc(190) xor crc(191) xor dq( 16);
        next_crc( 17) := crc(  9) xor crc(184) xor crc(186) xor crc(187) xor crc(188) xor crc(189) xor dq( 17);
        next_crc( 18) := crc( 10) xor crc(185) xor crc(187) xor crc(188) xor crc(189) xor crc(190) xor dq( 18);
        next_crc( 19) := crc( 11) xor crc(186) xor crc(188) xor crc(189) xor crc(190) xor crc(191) xor dq( 19);
        next_crc( 20) := crc( 12) xor crc(187) xor crc(189) xor crc(190) xor crc(191) xor dq( 20);
        next_crc( 21) := crc( 13) xor crc(188) xor crc(190) xor crc(191) xor dq( 21);
        next_crc( 22) := crc( 14) xor crc(189) xor crc(191) xor dq( 22);
        next_crc( 23) := crc( 15) xor crc(190) xor dq( 23);
        next_crc( 24) := crc( 16) xor crc(191) xor dq( 24);
        next_crc( 25) := crc( 17) xor crc(184) xor crc(186) xor crc(188) xor crc(189) xor crc(191) xor dq( 25);
        next_crc( 26) := crc( 18) xor crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(190) xor crc(191) xor dq( 26);
        next_crc( 27) := crc( 19) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(189) xor crc(191) xor dq( 27);
        next_crc( 28) := crc( 20) xor crc(186) xor crc(187) xor crc(188) xor crc(189) xor crc(190) xor dq( 28);
        next_crc( 29) := crc( 21) xor crc(184) xor crc(186) xor crc(187) xor crc(190) xor dq( 29);
        next_crc( 30) := crc( 22) xor crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(189) xor dq( 30);
        next_crc( 31) := crc( 23) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(190) xor dq( 31);
        next_crc( 32) := crc( 24) xor crc(184) xor crc(187) xor dq( 32);
        next_crc( 33) := crc( 25) xor crc(184) xor crc(185) xor crc(186) xor crc(189) xor crc(191) xor dq( 33);
        next_crc( 34) := crc( 26) xor crc(184) xor crc(185) xor crc(187) xor crc(188) xor crc(189) xor crc(190) xor crc(191) xor dq( 34);
        next_crc( 35) := crc( 27) xor crc(185) xor crc(186) xor crc(188) xor crc(189) xor crc(190) xor crc(191) xor dq( 35);
        next_crc( 36) := crc( 28) xor crc(184) xor crc(187) xor crc(188) xor crc(190) xor dq( 36);
        next_crc( 37) := crc( 29) xor crc(184) xor crc(185) xor crc(186) xor dq( 37);
        next_crc( 38) := crc( 30) xor crc(184) xor crc(185) xor crc(187) xor crc(188) xor crc(189) xor crc(191) xor dq( 38);
        next_crc( 39) := crc( 31) xor crc(184) xor crc(185) xor crc(190) xor crc(191) xor dq( 39);
        next_crc( 40) := crc( 32) xor crc(184) xor crc(185) xor crc(188) xor crc(189) xor dq( 40);
        next_crc( 41) := crc( 33) xor crc(185) xor crc(186) xor crc(189) xor crc(190) xor dq( 41);
        next_crc( 42) := crc( 34) xor crc(184) xor crc(187) xor crc(188) xor crc(189) xor crc(190) xor dq( 42);
        next_crc( 43) := crc( 35) xor crc(185) xor crc(188) xor crc(189) xor crc(190) xor crc(191) xor dq( 43);
        next_crc( 44) := crc( 36) xor crc(186) xor crc(189) xor crc(190) xor crc(191) xor dq( 44);
        next_crc( 45) := crc( 37) xor crc(187) xor crc(190) xor crc(191) xor dq( 45);
        next_crc( 46) := crc( 38) xor crc(188) xor crc(191) xor dq( 46);
        next_crc( 47) := crc( 39) xor crc(184) xor crc(186) xor crc(188) xor crc(191) xor dq( 47);
        next_crc( 48) := crc( 40) xor crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(191) xor dq( 48);
        next_crc( 49) := crc( 41) xor crc(184) xor crc(185) xor crc(187) xor crc(191) xor dq( 49);
        next_crc( 50) := crc( 42) xor crc(184) xor crc(185) xor crc(189) xor crc(191) xor dq( 50);
        next_crc( 51) := crc( 43) xor crc(185) xor crc(186) xor crc(190) xor dq( 51);
        next_crc( 52) := crc( 44) xor crc(186) xor crc(187) xor crc(191) xor dq( 52);
        next_crc( 53) := crc( 45) xor crc(187) xor crc(188) xor dq( 53);
        next_crc( 54) := crc( 46) xor crc(184) xor crc(186) xor crc(191) xor dq( 54);
        next_crc( 55) := crc( 47) xor crc(185) xor crc(187) xor dq( 55);
        next_crc( 56) := crc( 48) xor crc(184) xor crc(189) xor crc(191) xor dq( 56);
        next_crc( 57) := crc( 49) xor crc(184) xor crc(185) xor crc(186) xor crc(188) xor crc(189) xor crc(190) xor crc(191) xor dq( 57);
        next_crc( 58) := crc( 50) xor crc(185) xor crc(186) xor crc(187) xor crc(189) xor crc(190) xor crc(191) xor dq( 58);
        next_crc( 59) := crc( 51) xor crc(186) xor crc(187) xor crc(188) xor crc(190) xor crc(191) xor dq( 59);
        next_crc( 60) := crc( 52) xor crc(187) xor crc(188) xor crc(189) xor crc(191) xor dq( 60);
        next_crc( 61) := crc( 53) xor crc(188) xor crc(189) xor crc(190) xor dq( 61);
        next_crc( 62) := crc( 54) xor crc(189) xor crc(190) xor crc(191) xor dq( 62);
        next_crc( 63) := crc( 55) xor crc(190) xor crc(191) xor dq( 63);
        next_crc( 64) := crc( 56) xor crc(184) xor crc(186) xor crc(188) xor crc(189) xor dq( 64);
        next_crc( 65) := crc( 57) xor crc(185) xor crc(187) xor crc(189) xor crc(190) xor dq( 65);
        next_crc( 66) := crc( 58) xor crc(186) xor crc(188) xor crc(190) xor crc(191) xor dq( 66);
        next_crc( 67) := crc( 59) xor crc(184) xor crc(186) xor crc(187) xor crc(188) xor dq( 67);
        next_crc( 68) := crc( 60) xor crc(185) xor crc(187) xor crc(188) xor crc(189) xor dq( 68);
        next_crc( 69) := crc( 61) xor crc(186) xor crc(188) xor crc(189) xor crc(190) xor dq( 69);
        next_crc( 70) := crc( 62) xor crc(187) xor crc(189) xor crc(190) xor crc(191) xor dq( 70);
        next_crc( 71) := crc( 63) xor crc(184) xor crc(186) xor crc(189) xor crc(190) xor dq( 71);
        next_crc( 72) := crc( 64) xor crc(185) xor crc(187) xor crc(190) xor crc(191) xor dq( 72);
        next_crc( 73) := crc( 65) xor crc(186) xor crc(188) xor crc(191) xor dq( 73);
        next_crc( 74) := crc( 66) xor crc(187) xor crc(189) xor dq( 74);
        next_crc( 75) := crc( 67) xor crc(184) xor crc(186) xor crc(189) xor crc(190) xor crc(191) xor dq( 75);
        next_crc( 76) := crc( 68) xor crc(185) xor crc(187) xor crc(190) xor crc(191) xor dq( 76);
        next_crc( 77) := crc( 69) xor crc(186) xor crc(188) xor crc(191) xor dq( 77);
        next_crc( 78) := crc( 70) xor crc(187) xor crc(189) xor dq( 78);
        next_crc( 79) := crc( 71) xor crc(188) xor crc(190) xor dq( 79);
        next_crc( 80) := crc( 72) xor crc(184) xor crc(186) xor crc(188) xor dq( 80);
        next_crc( 81) := crc( 73) xor crc(185) xor crc(187) xor crc(189) xor dq( 81);
        next_crc( 82) := crc( 74) xor crc(184) xor crc(189) xor crc(190) xor crc(191) xor dq( 82);
        next_crc( 83) := crc( 75) xor crc(185) xor crc(190) xor crc(191) xor dq( 83);
        next_crc( 84) := crc( 76) xor crc(184) xor crc(188) xor crc(189) xor dq( 84);
        next_crc( 85) := crc( 77) xor crc(184) xor crc(185) xor crc(186) xor crc(188) xor crc(190) xor crc(191) xor dq( 85);
        next_crc( 86) := crc( 78) xor crc(185) xor crc(186) xor crc(187) xor crc(189) xor crc(191) xor dq( 86);
        next_crc( 87) := crc( 79) xor crc(186) xor crc(187) xor crc(188) xor crc(190) xor dq( 87);
        next_crc( 88) := crc( 80) xor crc(187) xor crc(188) xor crc(189) xor crc(191) xor dq( 88);
        next_crc( 89) := crc( 81) xor crc(188) xor crc(189) xor crc(190) xor dq( 89);
        next_crc( 90) := crc( 82) xor crc(184) xor crc(186) xor crc(188) xor crc(190) xor dq( 90);
        next_crc( 91) := crc( 83) xor crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor dq( 91);
        next_crc( 92) := crc( 84) xor crc(184) xor crc(185) xor crc(187) xor crc(191) xor dq( 92);
        next_crc( 93) := crc( 85) xor crc(185) xor crc(186) xor crc(188) xor dq( 93);
        next_crc( 94) := crc( 86) xor crc(184) xor crc(187) xor crc(188) xor crc(191) xor dq( 94);
        next_crc( 95) := crc( 87) xor crc(184) xor crc(185) xor crc(186) xor crc(191) xor dq( 95);
        next_crc( 96) := crc( 88) xor crc(185) xor crc(186) xor crc(187) xor dq( 96);
        next_crc( 97) := crc( 89) xor crc(186) xor crc(187) xor crc(188) xor dq( 97);
        next_crc( 98) := crc( 90) xor crc(187) xor crc(188) xor crc(189) xor dq( 98);
        next_crc( 99) := crc( 91) xor crc(184) xor crc(186) xor crc(190) xor crc(191) xor dq( 99);
        next_crc(100) := crc( 92) xor crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(189) xor dq(100);
        next_crc(101) := crc( 93) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(189) xor crc(190) xor dq(101);
        next_crc(102) := crc( 94) xor crc(184) xor crc(187) xor crc(190) xor dq(102);
        next_crc(103) := crc( 95) xor crc(184) xor crc(185) xor crc(186) xor crc(189) xor dq(103);
        next_crc(104) := crc( 96) xor crc(185) xor crc(186) xor crc(187) xor crc(190) xor dq(104);
        next_crc(105) := crc( 97) xor crc(186) xor crc(187) xor crc(188) xor crc(191) xor dq(105);
        next_crc(106) := crc( 98) xor crc(184) xor crc(186) xor crc(187) xor crc(191) xor dq(106);
        next_crc(107) := crc( 99) xor crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(189) xor crc(191) xor dq(107);
        next_crc(108) := crc(100) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(190) xor dq(108);
        next_crc(109) := crc(101) xor crc(184) xor crc(187) xor dq(109);
        next_crc(110) := crc(102) xor crc(185) xor crc(188) xor dq(110);
        next_crc(111) := crc(103) xor crc(186) xor crc(189) xor dq(111);
        next_crc(112) := crc(104) xor crc(184) xor crc(186) xor crc(187) xor crc(188) xor crc(189) xor crc(190) xor crc(191) xor dq(112);
        next_crc(113) := crc(105) xor crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(190) xor dq(113);
        next_crc(114) := crc(106) xor crc(184) xor crc(185) xor crc(187) xor crc(189) xor dq(114);
        next_crc(115) := crc(107) xor crc(184) xor crc(185) xor crc(189) xor crc(190) xor crc(191) xor dq(115);
        next_crc(116) := crc(108) xor crc(185) xor crc(186) xor crc(190) xor crc(191) xor dq(116);
        next_crc(117) := crc(109) xor crc(186) xor crc(187) xor crc(191) xor dq(117);
        next_crc(118) := crc(110) xor crc(184) xor crc(186) xor crc(187) xor crc(189) xor crc(191) xor dq(118);
        next_crc(119) := crc(111) xor crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(189) xor crc(190) xor crc(191) xor dq(119);
        next_crc(120) := crc(112) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(190) xor crc(191) xor dq(120);
        next_crc(121) := crc(113) xor crc(186) xor crc(187) xor crc(188) xor crc(189) xor crc(191) xor dq(121);
        next_crc(122) := crc(114) xor crc(187) xor crc(188) xor crc(189) xor crc(190) xor dq(122);
        next_crc(123) := crc(115) xor crc(188) xor crc(189) xor crc(190) xor crc(191) xor dq(123);
        next_crc(124) := crc(116) xor crc(184) xor crc(186) xor crc(188) xor crc(190) xor dq(124);
        next_crc(125) := crc(117) xor crc(185) xor crc(187) xor crc(189) xor crc(191) xor dq(125);
        next_crc(126) := crc(118) xor crc(184) xor crc(189) xor crc(190) xor crc(191) xor dq(126);
        next_crc(127) := crc(119) xor crc(185) xor crc(190) xor crc(191) xor dq(127);
        next_crc(128) := crc(120) xor crc(186) xor crc(191) xor dq(128);
        next_crc(129) := crc(121) xor crc(187) xor dq(129);
        next_crc(130) := crc(122) xor crc(184) xor crc(186) xor crc(189) xor crc(191) xor dq(130);
        next_crc(131) := crc(123) xor crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(189) xor crc(190) xor crc(191) xor dq(131);
        next_crc(132) := crc(124) xor crc(184) xor crc(185) xor crc(187) xor crc(190) xor dq(132);
        next_crc(133) := crc(125) xor crc(185) xor crc(186) xor crc(188) xor crc(191) xor dq(133);
        next_crc(134) := crc(126) xor crc(186) xor crc(187) xor crc(189) xor dq(134);
        next_crc(135) := crc(127) xor crc(187) xor crc(188) xor crc(190) xor dq(135);
        next_crc(136) := crc(128) xor crc(184) xor crc(186) xor dq(136);
        next_crc(137) := crc(129) xor crc(185) xor crc(187) xor dq(137);
        next_crc(138) := crc(130) xor crc(186) xor crc(188) xor dq(138);
        next_crc(139) := crc(131) xor crc(187) xor crc(189) xor dq(139);
        next_crc(140) := crc(132) xor crc(184) xor crc(186) xor crc(189) xor crc(190) xor crc(191) xor dq(140);
        next_crc(141) := crc(133) xor crc(185) xor crc(187) xor crc(190) xor crc(191) xor dq(141);
        next_crc(142) := crc(134) xor crc(184) xor crc(189) xor dq(142);
        next_crc(143) := crc(135) xor crc(185) xor crc(190) xor dq(143);
        next_crc(144) := crc(136) xor crc(186) xor crc(191) xor dq(144);
        next_crc(145) := crc(137) xor crc(187) xor dq(145);
        next_crc(146) := crc(138) xor crc(184) xor crc(186) xor crc(189) xor crc(191) xor dq(146);
        next_crc(147) := crc(139) xor crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(189) xor crc(190) xor crc(191) xor dq(147);
        next_crc(148) := crc(140) xor crc(184) xor crc(185) xor crc(187) xor crc(190) xor dq(148);
        next_crc(149) := crc(141) xor crc(185) xor crc(186) xor crc(188) xor crc(191) xor dq(149);
        next_crc(150) := crc(142) xor crc(184) xor crc(187) xor crc(188) xor crc(191) xor dq(150);
        next_crc(151) := crc(143) xor crc(185) xor crc(188) xor crc(189) xor dq(151);
        next_crc(152) := crc(144) xor crc(186) xor crc(189) xor crc(190) xor dq(152);
        next_crc(153) := crc(145) xor crc(187) xor crc(190) xor crc(191) xor dq(153);
        next_crc(154) := crc(146) xor crc(184) xor crc(186) xor crc(189) xor dq(154);
        next_crc(155) := crc(147) xor crc(185) xor crc(187) xor crc(190) xor dq(155);
        next_crc(156) := crc(148) xor crc(186) xor crc(188) xor crc(191) xor dq(156);
        next_crc(157) := crc(149) xor crc(187) xor crc(189) xor dq(157);
        next_crc(158) := crc(150) xor crc(188) xor crc(190) xor dq(158);
        next_crc(159) := crc(151) xor crc(184) xor crc(186) xor crc(188) xor dq(159);
        next_crc(160) := crc(152) xor crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(191) xor dq(160);
        next_crc(161) := crc(153) xor crc(184) xor crc(185) xor crc(187) xor crc(191) xor dq(161);
        next_crc(162) := crc(154) xor crc(185) xor crc(186) xor crc(188) xor dq(162);
        next_crc(163) := crc(155) xor crc(186) xor crc(187) xor crc(189) xor dq(163);
        next_crc(164) := crc(156) xor crc(187) xor crc(188) xor crc(190) xor dq(164);
        next_crc(165) := crc(157) xor crc(188) xor crc(189) xor crc(191) xor dq(165);
        next_crc(166) := crc(158) xor crc(189) xor crc(190) xor dq(166);
        next_crc(167) := crc(159) xor crc(184) xor crc(186) xor crc(188) xor crc(189) xor crc(190) xor dq(167);
        next_crc(168) := crc(160) xor crc(185) xor crc(187) xor crc(189) xor crc(190) xor crc(191) xor dq(168);
        next_crc(169) := crc(161) xor crc(184) xor crc(189) xor crc(190) xor dq(169);
        next_crc(170) := crc(162) xor crc(184) xor crc(185) xor crc(186) xor crc(188) xor crc(189) xor crc(190) xor dq(170);
        next_crc(171) := crc(163) xor crc(184) xor crc(185) xor crc(187) xor crc(188) xor crc(190) xor dq(171);
        next_crc(172) := crc(164) xor crc(185) xor crc(186) xor crc(188) xor crc(189) xor crc(191) xor dq(172);
        next_crc(173) := crc(165) xor crc(186) xor crc(187) xor crc(189) xor crc(190) xor dq(173);
        next_crc(174) := crc(166) xor crc(187) xor crc(188) xor crc(190) xor crc(191) xor dq(174);
        next_crc(175) := crc(167) xor crc(188) xor crc(189) xor crc(191) xor dq(175);
        next_crc(176) := crc(168) xor crc(189) xor crc(190) xor dq(176);
        next_crc(177) := crc(169) xor crc(184) xor crc(186) xor crc(188) xor crc(189) xor crc(190) xor dq(177);
        next_crc(178) := crc(170) xor crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(190) xor dq(178);
        next_crc(179) := crc(171) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(189) xor crc(191) xor dq(179);
        next_crc(180) := crc(172) xor crc(186) xor crc(187) xor crc(188) xor crc(189) xor crc(190) xor dq(180);
        next_crc(181) := crc(173) xor crc(184) xor crc(186) xor crc(187) xor crc(190) xor dq(181);
        next_crc(182) := crc(174) xor crc(185) xor crc(187) xor crc(188) xor crc(191) xor dq(182);
        next_crc(183) := crc(175) xor crc(186) xor crc(188) xor crc(189) xor dq(183);
        next_crc(184) := crc(176) xor crc(187) xor crc(189) xor crc(190) xor dq(184);
        next_crc(185) := crc(177) xor crc(184) xor crc(186) xor crc(189) xor crc(190) xor dq(185);
        next_crc(186) := crc(178) xor crc(184) xor crc(185) xor crc(186) xor crc(187) xor crc(188) xor crc(189) xor crc(190) xor dq(186);
        next_crc(187) := crc(179) xor crc(184) xor crc(185) xor crc(187) xor crc(190) xor dq(187);
        next_crc(188) := crc(180) xor crc(185) xor crc(186) xor crc(188) xor crc(191) xor dq(188);
        next_crc(189) := crc(181) xor crc(186) xor crc(187) xor crc(189) xor dq(189);
        next_crc(190) := crc(182) xor crc(184) xor crc(186) xor crc(187) xor crc(189) xor crc(190) xor crc(191) xor dq(190);
        next_crc(191) := crc(183) xor crc(185) xor crc(187) xor crc(188) xor crc(190) xor crc(191) xor dq(191);

        return next_crc;

    end function next_bch_192x8;

    -- Debug only, return a nice representation of the CRC context
    impure function to_string (
        constant crc : bch_192x8_context) return string is
    begin
    return sformat("crc(data=%r, crc=%r)", fo(crc.data), fo(crc.crc));
    end function to_string;

end package body;
