--
-- DVB IP
--
-- Copyright 2019 by Suoto <andre820@gmail.com>
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

--------------------------
-- Simple edge detector --
--------------------------

---------------
-- Libraries --
---------------
library	ieee;
use ieee.std_logic_1164.all;  

------------------------
-- Entity declaration --
------------------------
entity edge_detector is
  generic (
    SYNCHRONIZE_INPUT : boolean := false;
    OUTPUT_DELAY      : natural := 1);
  port (
    -- Usual ports
    clk     : in  std_logic;
    clken   : in  std_logic;

    -- 
    din     : in  std_logic;
    -- Edges detected
    rising  : out std_logic;
    falling : out std_logic;
    toggle  : out std_logic);
end edge_detector;

architecture edge_detector of edge_detector is

  -------------
  -- Signals --
  -------------
  signal din_i     : std_logic;
  signal din_d     : std_logic;
  signal rising_i  : std_logic;
  signal falling_i : std_logic;
  signal toggle_i  : std_logic;

begin

  -------------------
  -- Port mappings --
  -------------------
  gsync_in : if SYNCHRONIZE_INPUT generate
    sync_in : entity work.synchronizer
      generic map (
        SYNC_STAGES => 1,
        DATA_WIDTH  => 1)
      port map (
        clk     => clk,
        clken   => clken,

        din(0)  => din,
        dout(0) => din_i);
  end generate gsync_in;

  output_a : entity work.sr_delay
    generic map (
      DELAY_CYCLES => OUTPUT_DELAY,
      DATA_WIDTH   => 3)
    port map (
      clk     => clk,
      clken   => clken,

      din(0)  => rising_i,
      din(1)  => falling_i,
      din(2)  => toggle_i,

      dout(0) => rising,
      dout(1) => falling,
      dout(2) => toggle);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  ngsync_in : if not SYNCHRONIZE_INPUT generate
    din_i <= din;
  end generate ngsync_in;

  rising_i  <= '1' when din_i = '1' and din_d /= '1' else '0';
  falling_i <= '1' when din_i /= '1' and din_d = '1' else '0';
  toggle_i  <= rising_i or falling_i;

  ---------------
  -- Processes --
  ---------------
  process(clk)
  begin
    if clk'event and clk = '1' then
      if clken = '1' then
        din_d <= din_i;
      end if;
    end if;
  end process;

end edge_detector;

