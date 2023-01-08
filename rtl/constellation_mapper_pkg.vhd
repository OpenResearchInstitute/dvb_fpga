--
-- DVB FPGA
--
-- Copyright 2019-2022 by suoto <andre820@gmail.com>
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library fpga_cores;
use fpga_cores.common_pkg.all;

use work.dvb_utils_pkg.all;

package constellation_mapper_pkg is

  -- ###################################################################################
  -- ## Radius' table functions and constants ##########################################
  -- ###################################################################################
  -- Radius table addresses
  constant RADIUS_SHORT_16APSK_C2_3   : integer := 0;
  constant RADIUS_SHORT_16APSK_C3_4   : integer := 1;
  constant RADIUS_SHORT_16APSK_C3_5   : integer := 2;
  constant RADIUS_SHORT_16APSK_C4_5   : integer := 3;
  constant RADIUS_SHORT_16APSK_C5_6   : integer := 4;
  constant RADIUS_SHORT_16APSK_C8_9   : integer := 5;

  constant RADIUS_NORMAL_16APSK_C2_3  : integer := 6;
  constant RADIUS_NORMAL_16APSK_C3_4  : integer := 7;
  constant RADIUS_NORMAL_16APSK_C3_5  : integer := 8;
  constant RADIUS_NORMAL_16APSK_C4_5  : integer := 9;
  constant RADIUS_NORMAL_16APSK_C5_6  : integer := 10;
  constant RADIUS_NORMAL_16APSK_C8_9  : integer := 11;
  constant RADIUS_NORMAL_16APSK_C9_10 : integer := 12;

  constant RADIUS_SHORT_32APSK_C3_4   : integer := 13;
  constant RADIUS_SHORT_32APSK_C4_5   : integer := 14;
  constant RADIUS_SHORT_32APSK_C5_6   : integer := 15;
  constant RADIUS_SHORT_32APSK_C8_9   : integer := 16;

  constant RADIUS_NORMAL_32APSK_C3_4  : integer := 17;
  constant RADIUS_NORMAL_32APSK_C4_5  : integer := 18;
  constant RADIUS_NORMAL_32APSK_C5_6  : integer := 19;
  constant RADIUS_NORMAL_32APSK_C8_9  : integer := 20;
  constant RADIUS_NORMAL_32APSK_C9_10 : integer := 21;

  -- Number of RADIUS_<length>_<constellation>_<code_rate> constants representing the
  -- radius table addresses
  constant RADIUS_TABLE_DEPTH         : integer := 22;

  function get_radius_table( width : integer ) return std_logic_array_t;

  -- ###################################################################################
  -- ## IQ table functions and constants ###############################################
  -- ###################################################################################
  constant BASE_OFFSET_QPSK   : integer := 0;
  constant BASE_OFFSET_8PSK   : integer := BASE_OFFSET_QPSK + 4;
  constant BASE_OFFSET_16APSK : integer := BASE_OFFSET_8PSK + 8;
  constant BASE_OFFSET_32APSK : integer := BASE_OFFSET_16APSK + 16;
  constant IQ_TABLE_DEPTH     : integer := 60;

  function get_iq_table( width : integer ) return std_logic_array_t;

end constellation_mapper_pkg;

package body constellation_mapper_pkg is

  function get_radius_table( width : integer ) return std_logic_array_t is

    -- Helper function to return an entry of the table
    function get_row_content ( constant r0, r1 : real ) return std_logic_vector is
      constant r0_uns : signed(width/2 - 1 downto 0) := to_signed_fixed_point(r0, width/2);
      constant r1_uns : signed(width/2 - 1 downto 0) := to_signed_fixed_point(r1, width/2);
    begin
        return std_logic_vector(r0_uns) & std_logic_vector(r1_uns);
    end function get_row_content;

    constant table : std_logic_array_t( 0 to RADIUS_TABLE_DEPTH - 1 )(width - 1 downto 0) := (
      RADIUS_SHORT_16APSK_C2_3   => get_row_content(r0 => 0.31746031746031744, r1 => 1.0),
      RADIUS_SHORT_16APSK_C3_4   => get_row_content(r0 => 0.3508771929824561,  r1 => 1.0),
      RADIUS_SHORT_16APSK_C3_5   => get_row_content(r0 => 0.27027027027027023, r1 => 1.0),
      RADIUS_SHORT_16APSK_C4_5   => get_row_content(r0 => 0.36363636363636365, r1 => 1.0),
      RADIUS_SHORT_16APSK_C5_6   => get_row_content(r0 => 0.37037037037037035, r1 => 1.0),
      RADIUS_SHORT_16APSK_C8_9   => get_row_content(r0 => 0.3846153846153846,  r1 => 1.0),

      RADIUS_NORMAL_16APSK_C2_3  => get_row_content(r0 => 0.31746031746031744, r1 => 1.0),
      RADIUS_NORMAL_16APSK_C3_4  => get_row_content(r0 => 0.3508771929824561,  r1 => 1.0),
      RADIUS_NORMAL_16APSK_C3_5  => get_row_content(r0 => 0.27027027027027023, r1 => 1.0),
      RADIUS_NORMAL_16APSK_C4_5  => get_row_content(r0 => 0.36363636363636365, r1 => 1.0),
      RADIUS_NORMAL_16APSK_C5_6  => get_row_content(r0 => 0.37037037037037035, r1 => 1.0),
      RADIUS_NORMAL_16APSK_C8_9  => get_row_content(r0 => 0.3846153846153846,  r1 => 1.0),
      RADIUS_NORMAL_16APSK_C9_10 => get_row_content(r0 => 0.38910505836575876, r1 => 1.0),

      RADIUS_SHORT_32APSK_C3_4   => get_row_content(r0 => 0.18975332068311196, r1 => 0.538899430740038),
      RADIUS_SHORT_32APSK_C4_5   => get_row_content(r0 => 0.20533880903490762, r1 => 0.5585215605749487),
      RADIUS_SHORT_32APSK_C5_6   => get_row_content(r0 => 0.21551724137931036, r1 => 0.5689655172413793),
      RADIUS_SHORT_32APSK_C8_9   => get_row_content(r0 => 0.23094688221709006, r1 => 0.5866050808314087),

      RADIUS_NORMAL_32APSK_C3_4  => get_row_content(r0 => 0.18975332068311196, r1 => 0.538899430740038),
      RADIUS_NORMAL_32APSK_C4_5  => get_row_content(r0 => 0.20533880903490762, r1 => 0.5585215605749487),
      RADIUS_NORMAL_32APSK_C5_6  => get_row_content(r0 => 0.21551724137931036, r1 => 0.5689655172413793),
      RADIUS_NORMAL_32APSK_C8_9  => get_row_content(r0 => 0.23094688221709006, r1 => 0.5866050808314087),
      RADIUS_NORMAL_32APSK_C9_10 => get_row_content(r0 => 0.23255813953488372, r1 => 0.5883720930232558)
    );
  begin
    return table;
  end function get_radius_table;

  function get_iq_table( width : integer ) return std_logic_array_t is
    -- Small helpers to reduce footprint of calling this over and over
    function get_iq_pair (constant x : real) return std_logic_vector is
      variable result : std_logic_vector(width - 1 downto 0);
    begin
      return std_logic_vector(cos(x, width/2) & sin(x, width/2));
    end function get_iq_pair;

    constant table : std_logic_array_t(0 to IQ_TABLE_DEPTH - 1)(width - 1 downto 0) := (
      -- QPSK
      0 => get_iq_pair(        MATH_PI /  4.0),
      1 => get_iq_pair(  7.0 * MATH_PI /  4.0),
      2 => get_iq_pair(  3.0 * MATH_PI /  4.0),
      3 => get_iq_pair(  5.0 * MATH_PI /  4.0),

      -- 8PSK
      4  => get_iq_pair(        MATH_PI /  4.0),
      5  => get_iq_pair(  0.0),
      6  => get_iq_pair(  4.0 * MATH_PI /  4.0),
      7  => get_iq_pair(  5.0 * MATH_PI /  4.0),
      8  => get_iq_pair(  2.0 * MATH_PI /  4.0),
      9  => get_iq_pair(  7.0 * MATH_PI /  4.0),
      10 => get_iq_pair(  3.0 * MATH_PI /  4.0),
      11 => get_iq_pair(  6.0 * MATH_PI /  4.0),

      -- 16APSK (although here we only have the the PSK part)
      12 => get_iq_pair(        MATH_PI /  4.0),
      13 => get_iq_pair(       -MATH_PI /  4.0),
      14 => get_iq_pair(  3.0 * MATH_PI /  4.0),
      15 => get_iq_pair( -3.0 * MATH_PI /  4.0),
      16 => get_iq_pair(        MATH_PI / 12.0),
      17 => get_iq_pair(       -MATH_PI / 12.0),
      18 => get_iq_pair( 11.0 * MATH_PI / 12.0),
      19 => get_iq_pair(-11.0 * MATH_PI / 12.0),
      20 => get_iq_pair(  5.0 * MATH_PI / 12.0),
      21 => get_iq_pair( -5.0 * MATH_PI / 12.0),
      22 => get_iq_pair(  7.0 * MATH_PI / 12.0),
      23 => get_iq_pair( -7.0 * MATH_PI / 12.0),
      24 => get_iq_pair(        MATH_PI /  4.0),
      25 => get_iq_pair(       -MATH_PI /  4.0),
      26 => get_iq_pair(  3.0 * MATH_PI /  4.0),
      27 => get_iq_pair( -3.0 * MATH_PI /  4.0),

      -- 32APSK (although here we only have the the PSK part)
      28 => get_iq_pair(        MATH_PI /  4.0),
      29 => get_iq_pair(  5.0 * MATH_PI / 12.0),
      30 => get_iq_pair(       -MATH_PI /  4.0),
      31 => get_iq_pair( -5.0 * MATH_PI / 12.0),
      32 => get_iq_pair(  3.0 * MATH_PI /  4.0),
      33 => get_iq_pair(  7.0 * MATH_PI / 12.0),
      34 => get_iq_pair( -3.0 * MATH_PI /  4.0),
      35 => get_iq_pair( -7.0 * MATH_PI / 12.0),
      36 => get_iq_pair(        MATH_PI /  8.0),
      37 => get_iq_pair(  3.0 * MATH_PI /  8.0),
      38 => get_iq_pair(       -MATH_PI /  4.0),
      39 => get_iq_pair(       -MATH_PI /  2.0),
      40 => get_iq_pair(  3.0 * MATH_PI /  4.0),
      41 => get_iq_pair(        MATH_PI /  2.0),
      42 => get_iq_pair( -7.0 * MATH_PI /  8.0),
      43 => get_iq_pair( -5.0 * MATH_PI /  8.0),
      44 => get_iq_pair(        MATH_PI / 12.0),
      45 => get_iq_pair(        MATH_PI /  4.0),
      46 => get_iq_pair(       -MATH_PI / 12.0),
      47 => get_iq_pair(       -MATH_PI /  4.0),
      48 => get_iq_pair( 11.0 * MATH_PI / 12.0),
      49 => get_iq_pair(  3.0 * MATH_PI /  4.0),
      50 => get_iq_pair(-11.0 * MATH_PI / 12.0),
      51 => get_iq_pair( -3.0 * MATH_PI /  4.0),
      52 => get_iq_pair(  0.0),
      53 => get_iq_pair(        MATH_PI /  4.0),
      54 => get_iq_pair(       -MATH_PI /  8.0),
      55 => get_iq_pair( -3.0 * MATH_PI /  8.0),
      56 => get_iq_pair(  7.0 * MATH_PI /  8.0),
      57 => get_iq_pair(  5.0 * MATH_PI /  8.0),
      58 => get_iq_pair(        MATH_PI),
      59 => get_iq_pair( -3.0 * MATH_PI /  4.0)
    );
  begin
    return table;
  end function get_iq_table;

end package body;
