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


---------------
-- Libraries --
---------------
library	ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_stream_fifo is
  generic (
    FIFO_DEPTH          : positive := 1;
    DATA_WIDTH          : natural  := 1;
    RAM_INFERENCE_STYLE : string   := "auto");
  port (
    -- Usual ports
    clk     : in  std_logic;
    rst     : in  std_logic;

    -- Write side
    s_tvalid : in  std_logic;
    s_tready : out std_logic;
    s_tdata  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    s_tlast  : in  std_logic;

    -- Read side
    m_tvalid : out std_logic;
    m_tready : in  std_logic;
    m_tdata  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    m_tlast  : out std_logic);

end axi_stream_fifo;

architecture axi_stream_fifo of axi_stream_fifo is

  -------------
  -- Signals --
  -------------
  signal s_axi_dv        : std_logic;

  signal ram_wr_ptr      : unsigned(numbits(FIFO_DEPTH) downto 0);
  signal ram_wr_data_agg : std_logic_vector(DATA_WIDTH downto 0);

  signal ram_rd_en       : std_logic;
  signal ram_rd_en_reg   : std_logic;
  signal ram_rd_ptr      : unsigned(numbits(FIFO_DEPTH) downto 0);
  signal ram_rd_data_agg : std_logic_vector(DATA_WIDTH downto 0);

  signal ptr_diff        : unsigned(numbits(FIFO_DEPTH) downto 0);

  -- AXI stream master adapter interface
  signal ram_rd_full     : std_logic;
  signal ram_rd_dv       : std_logic;
  signal ram_rd_tdata    : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal ram_rd_tlast    : std_logic;

  -- Internals
  signal s_tready_i      : std_logic;


begin

  -------------------
  -- Port mappings --
  -------------------
  ram_u : entity work.ram_inference
    generic map (
      ADDR_WIDTH          => numbits(FIFO_DEPTH),
      DATA_WIDTH          => DATA_WIDTH + 1,
      RAM_INFERENCE_STYLE => RAM_INFERENCE_STYLE,
      EXTRA_OUTPUT_DELAY  => 0)
    port map (
      -- Port A
      clk_a     => clk,
      clken_a   => '1',
      wren_a    => s_axi_dv,
      addr_a    => std_logic_vector(ram_wr_ptr(ram_wr_ptr'length - 2 downto 0)),
      wrdata_a  => ram_wr_data_agg,
      rddata_a  => open,

      -- Port B
      clk_b     => clk,
      clken_b   => '1',
      addr_b    => std_logic_vector(ram_rd_ptr(ram_rd_ptr'length - 2 downto 0)),
      rddata_b  => ram_rd_data_agg);

  output_adapter_u : entity work.axi_stream_master_adapter
    generic map (
      MAX_SKEW_CYCLES => 2,
      TDATA_WIDTH     => DATA_WIDTH)
    port map (
      -- Usual ports
      clk      => clk,
      reset    => rst,
      -- wanna-be AXI interface
      wr_en    => ram_rd_dv,
      wr_full  => ram_rd_full,
      wr_data  => ram_rd_tdata,
      wr_last  => ram_rd_tlast,
      -- AXI master
      m_tvalid => m_tvalid,
      m_tready => m_tready,
      m_tdata  => m_tdata ,
      m_tlast  => m_tlast);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  s_tready_i      <= '1' when ptr_diff < FIFO_DEPTH - 1 else '0';
  s_axi_dv        <= '1' when s_tready_i = '1' and s_tvalid = '1' else '0';

  ram_wr_data_agg <= s_tlast & s_tdata;

  ram_rd_en       <= '1' when ram_rd_full = '0' and ptr_diff /= 0 else '0';

  -- Assign internals
  s_tready        <= s_tready_i;

  ---------------
  -- Processes --
  ---------------
  wr_side_p : process(clk, rst)
  begin
    if rst = '1' then
      ptr_diff   <= (others => '0');
      ram_wr_ptr <= (others => '0');
      ram_rd_ptr <= (others => '0');

    elsif clk'event and clk = '1' then

      ram_rd_dv     <= '0';
      ram_rd_en_reg <= ram_rd_en;

      -- Handle write pointer increment (FIFO_DEPTH is not necessarily a power of 2)
      if s_axi_dv = '1' then
        if ram_wr_ptr < FIFO_DEPTH then
          ram_wr_ptr <= ram_wr_ptr + 1;
        else
          ram_wr_ptr <= (others => '0');
        end if;
      end if;

      -- Handle read pointer increment (FIFO_DEPTH is not necessarily a power of 2)
      if ram_rd_en = '1' then
        if ram_rd_ptr < FIFO_DEPTH then
          ram_rd_ptr <= ram_rd_ptr + 1;
        else
          ram_rd_ptr <= (others => '0');
        end if;
      end if;

      -- Data takes 1 cycle to come out after we've updated the pointer, catch it when it
      -- does
      if ram_rd_en_reg = '1' then
        ram_rd_dv   <= '1';
        ram_rd_tdata <= ram_rd_data_agg(DATA_WIDTH - 1 downto 0);
        ram_rd_tlast <= ram_rd_data_agg(DATA_WIDTH);
      end if;

      -- Calculate the pointer difference without using the actual pointers; FIFO_DEPTH is
      -- not necessarily a power of 2
      if s_axi_dv = '1' and ram_rd_en = '0' then
        ptr_diff <= ptr_diff + 1;
      elsif s_axi_dv = '0' and ram_rd_en = '1' then
        ptr_diff <= ptr_diff - 1;
      end if;

    end if;
  end process;

end axi_stream_fifo;
