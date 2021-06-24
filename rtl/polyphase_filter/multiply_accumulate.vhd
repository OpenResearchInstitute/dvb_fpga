--
-- DVB IP
--
-- Copyright 2019 by Suoto <andre820@gmail.com>
--
-- This source describes Open Hardware and is licensed under the CERN-OHL-W v2.
--
-- You may redistribute and modify this source and make products using it under
-- the terms of the CERN-OHL-W v2 (https:--ohwr.org/cern_ohl_w_v2.txt).
--
-- This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING
-- OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.
-- Please see the CERN-OHL-W v2 for applicable conditions.
--
-- Source location: https:--github.com/phase4ground/dvb_fpga
--
-- As per CERN-OHL-W v2 section 4.1, should You produce hardware based on this
-- source, You must maintain the Source Location visible on the external case of
-- the DVB Encoder or other products you make using this source.
-- Wrapper to allow instantiating the dvbs2_encoder to a Vivado block diagram

---------------------------------
-- Block name and description --
--------------------------------

---------------
-- Libraries --
---------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpga_cores;
use fpga_cores.common_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity multiply_accumulate_vhd is
  generic (
    DATA_WIDTH          : integer := 16;
    COEFFICIENT_WIDTH   : integer := 16;
    CARRY_WIDTH         : integer := 48;
    DATA_IN_NUMBER_REGS : integer := 1);
  port (
    clk            : in  std_logic;
    rst            : in  std_logic;

    ce_coefficient : in std_logic;
    coefficient_in : in std_logic_vector(COEFFICIENT_WIDTH - 1 downto 0);

    ce_calculate   : in std_logic;
    data_in        : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    carry_in       : in std_logic_vector(CARRY_WIDTH - 1 downto 0);
    carry_out      : out std_logic_vector(CARRY_WIDTH - 1 downto 0);
    data_carry     : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    data_out       : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end multiply_accumulate_vhd;

architecture multiply_accumulate_vhd of multiply_accumulate_vhd is

  -------------
  -- Signals --
  -------------
  signal coefficient_register : std_logic_vector(COEFFICIENT_WIDTH - 1 downto 0);

  signal data_in_register : std_logic_array_t(DATA_IN_NUMBER_REGS - 1 downto 0)(DATA_WIDTH-1 downto 0);
  signal data_in_internal : std_logic_vector(DATA_WIDTH - 1 downto 0);

  signal data_in_internal_delay : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal mac_value : signed(CARRY_WIDTH - 1 downto 0);

begin

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  -- tap off the end of the shift register delay line and use it internally and pass it outside
  data_in_internal <= data_in_register(DATA_IN_NUMBER_REGS - 1);
  data_carry <= data_in_internal;


  -- output the trimmed and full precision outputs
  carry_out <= std_logic_vector(mac_value);
  data_out  <= std_logic_vector(mac_value(2*DATA_WIDTH - 2 - 1 downto DATA_WIDTH - 2));


  ---------------
  -- Processes --
  ---------------
  -- store the coefficient
  process(clk, rst)
  begin
    if rst = '1' then
      coefficient_register   <= (others => 'U');
      data_in_register       <= (others => (others => '0'));
      data_in_internal_delay <= (others => '0');
      mac_value              <= (others => '0');
    elsif rising_edge(clk) then
      if (ce_coefficient) then
        coefficient_register <= coefficient_in;
      end if;

      if ce_calculate then
        data_in_register(0) <= data_in;
        for i in 1 to DATA_IN_NUMBER_REGS - 1 loop
          data_in_register(i) <= data_in_register(i - 1);
        end loop;
        data_in_internal_delay <= data_in_internal;

        -- perform the core multiply and accumalate operation
        mac_value <= signed(coefficient_register) * signed(data_in_internal_delay) + signed(carry_in);

      end if;

    end if;
  end process;

end multiply_accumulate_vhd;
