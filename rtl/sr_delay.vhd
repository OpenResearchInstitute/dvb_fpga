--
-- DVB FPGA
--
-- Copyright 2019 by Suoto <andre820@gmail.com>
--
-- This file is part of DVB FPGA.
--
-- DVB FPGA is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- DVB FPGA is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DVB FPGA.  If not, see <http://www.gnu.org/licenses/>.

library	ieee;
use ieee.std_logic_1164.all;  

-- Shit register based delay --
entity sr_delay is
  generic (
    DELAY_CYCLES  : natural  := 1;
    DATA_WIDTH    : positive := 1;
    EXTRACT_SHREG : boolean  := True);
  port (
    clk     : in  std_logic;
    clken   : in  std_logic;

    din     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    dout    : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end sr_delay;

architecture sr_delay of sr_delay is

  -- Converts EXTRACT_SHREG (boolean) to "yes" or "no" (string) for Xilinx's SHREG_EXTRACT
  -- attribute
  function xilinx_shreg_extract return string is
  begin
    if EXTRACT_SHREG then
      return "yes";
    else
      return "no";
    end if;
  end xilinx_shreg_extract;

  -- Converts EXTRACT_SHREG (boolean) to "TRUE" or "FALSE" (string) for Xilinx's ASYNC_REG
  -- attribute
  function xilinx_async_reg return string is
  begin
    if EXTRACT_SHREG then
      return "TRUE";
    else
      return "FALSE";
    end if;
  end xilinx_async_reg;

  -----------
  -- Types --
  -----------
  type din_t is array (natural range <>) of std_logic_vector(DATA_WIDTH - 1 downto 0);

  -------------
  -- Signals --
  -------------
  signal din_sr   : din_t(DELAY_CYCLES - 1 downto 0);

  -- Xilinx XST: disable shift-register LUT (SRL) extraction
  attribute SHREG_EXTRACT : string;
  attribute SHREG_EXTRACT of din_sr : signal is xilinx_shreg_extract;

  -- Disable X propagation during timing simulation. In the event of 
  -- a timing violation, the previous value is retained on the output instead 
  -- of going unknown (see Xilinx UG625)
  attribute ASYNC_REG : string;
  attribute ASYNC_REG of din_sr : signal is xilinx_async_reg;

begin

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  no_delay : if DELAY_CYCLES = 0 generate
    dout <= din;
  end generate no_delay;

  non_zero_delay : if DELAY_CYCLES > 0 generate
    dout <= din_sr(DELAY_CYCLES - 1);
  end generate non_zero_delay;

  ---------------
  -- Processes --
  ---------------
  non_zero_delay_p : if DELAY_CYCLES > 0 generate
    process(clk)
    begin
      if clk'event and clk = '1' then
        if clken = '1' then
          din_sr  <= din_sr(DELAY_CYCLES - 2 downto 0) & din;
        end if;
      end if;
    end process;
  end generate non_zero_delay_p;

end sr_delay;
