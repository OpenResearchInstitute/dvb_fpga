--
-- DVB IP
--
-- Copyright 2021 by Anshul Makkar <anshulmakkar@gmail.com>
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

use work.dvb_utils_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_gse_encoder is
  generic (
    TDATA_WIDTH : positive := 8;
    ADDR_WIDTH   : natural := 16;
    TID_WIDTH   : natural  := 0;
    GSE_HEADER_LEN : positive := 10;
    MAX_UDP_PKT_SIZE : positive := 512;
    MAX_AXI_WORDS : positive := 8
  );
  port (
    -- Usual ports
    clk      : in  std_logic;
    rst      : in  std_logic;

    -- AXI input
    s_frame_type : in  frame_type_t;
    s_code_rate  : in  code_rate_t;
    s_tvalid : in  std_logic;
    s_tlast  : in  std_logic;
    s_tready : out std_logic;
    s_tdata  : in  std_logic_vector(TDATA_WIDTH - 1 downto 0);
    s_tid    : in  std_logic_vector(TID_WIDTH - 1 downto 0);

    -- AXI output
    m_tready : in  std_logic;
    m_tvalid : out std_logic;
    m_tlast  : out std_logic;
    m_tdata  : out std_logic_vector(TDATA_WIDTH - 1 downto 0);
    m_tid    : out std_logic_vector(TID_WIDTH - 1 downto 0));
end axi_gse_encoder;

architecture axi_gse_encoder of axi_gse_encoder is

  function get_gse_header return std_logic_vector is
  variable gse_header : std_logic_vector(numbits(GSE_HEADER_LEN) -1 downto 0);
  begin
    -- start bit
    gse_header(0) := '1';
    gse_header(1) := '1';
    gse_header(3 downto 2) := "10";
    return gse_header;
  end;
  constant num_input_words : natural := 8;
  -- FSM --
  type state_type is (idle, write_ram);
  type data_type is array (0 to (MAX_AXI_WORDS - 1)) of std_logic_vector(TDATA_WIDTH- 1 downto 0);
  --type t_Memory is array (0 to 127) of std_logic_vector(7 downto 0);
  shared variable ram: data_type;
  signal state : state_type;
  type t_gse_pkt_array is array  (0 to 512) of std_logic_vector(7 downto 0);
  signal gse_pkt : t_gse_pkt_array;
  --signal payload : std_logic_vector(numbits(MAX_UDP_PKT_SIZE) -1 downto 0);
  signal tlast_i : std_logic;
  signal ram_wren : std_logic;
  signal ram_wrndx : natural;
  signal ram_wrcomplete : boolean := False;
  signal s_tready_i : std_logic;
  begin
  --constant GSE_HEADER := std_logic_vector := get_gse_header();
  
  -- State Machine Implementation
  process(clk, rst)
  begin
    if rst = '1' then
      state <= Idle;
      tlast_i <= '0';
    elsif clk'event and clk = '1' then
      case state is
        when Idle =>
          -- sink starts accepting data when s_tvalid is asserted to indicate presence of data.
          if (s_tvalid = '1') then
            state <= write_ram; -- read and write to ram
        end if;
        when write_ram =>
          -- when writing to ram is complete, switch back to idle to read again.
          if (ram_wrcomplete) then
            state <= idle;
          else
            state <= write_ram;
          end if;
        when others =>
          state <= idle;
      end case;    
    end if;
  end process;
  
  -- sink/reader is always ready to accept s_tdata and write to ram until the ram is full.
  s_tready_i <= '1' when (state = write_ram and ram_wrndx <= MAX_AXI_WORDS - 1) else '0';

  process(clk, rst)
  begin
  if rst = '1' then
    ram_wrndx <= 0;
  elsif clk'event and clk = '1' then
    if (ram_wrndx <= MAX_AXI_WORDS  -1 ) then
      if (ram_wren = '1') then
        -- ram_wrndx pointer is incremented after every write to ram. 
        -- This is done only when ram_wren is 1;
        ram_wrndx <= ram_wrndx + 1;
        ram_wrcomplete <= False;
      end if;
      if ((ram_wrndx = MAX_AXI_WORDS -1 ) or s_tlast = '1') then
        -- last AXI word received. write to ram done.
        ram_wrcomplete <= True;
      end if;
    end if;
  end if;
  end process;
  
  --ram_wren to enable write
  ram_wren <= s_tvalid  and s_tready_i;
  
  process(clk, rst)
  begin
  if rst = '1' then
  elsif clk'event and clk = '1' then
    if (ram_wren = '1') then
      ram(ram_wrndx) := s_tdata (TDATA_WIDTH -1 downto 0);
    end if;
  end if;
  end process;  
  
  --read data from memory.
  process
    if not ram_wrcomplete then 
      wait until ram_wrcomplete;
    end if;
    
    gse_pkt((MAX_UDP_PKT_SIZE * 8) -1 downto (MAX_UDP_PKT_SIZE - GSE_HEADER_LEN) * 8) <= gse_header( GSE_HEADER_LEN * 8 -1 downto 0);
    -- gse_pkt( (MAX_UDP_PKT_SIZE - GSE_HEADER_LEN ) * 8 -1 downto 
  end process;
    
   
end axi_gse_encoder;
