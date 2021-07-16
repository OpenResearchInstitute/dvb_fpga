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
entity axi_gse_bbframe is
  generic (
    TDATA_WIDTH : positive := 8;
    ADDR_WIDTH   : natural := 16;
    TID_WIDTH   : natural  := 0;
    BB_HEADER_LEN : positive := 10;
    -- word is 8 bits. Max 7274 words of 8 bit each.
    MAX_AXI_WORDS : positive := 7274;
    MAX_BBFRAME_LENGTH : unsigned(15 downto 0) := X"E350"
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
end axi_gse_bbframe;

architecture axi_gse_bbframe of axi_gse_bbframe is

  impure function get_bbheader return std_logic_vector is
  variable bb_header : std_logic_vector((BB_HEADER_LEN * 8) -1 downto 0);
  begin
  -- Baseband header formation.
    -- MATYPE-1 Generic stream continuous
    bb_header(1 downto 0) := "01";
    -- MATYPE-1 single stream
    bb_header(2) := '1';
    -- MATYPE-1 constant stream
    bb_header(3) := '1';
    -- MATYPE-1 ISSYI not active
    bb_header(4) := '0';
    -- MATYPE-1 null packet deletion not active.
    bb_header(5) :=  '0';
    -- MATYPE-1 transmission roll off factor 00 ??
    bb_header(7 downto 6) := "00";
    -- MATYPE-1 : single stream so 2nd byte reserved..
    bb_header(15 downto 8) := x"00";
    -- UPL continuous stream
    bb_header(31 downto 16) := x"0000";
    -- DPL 58,112 = 58,192 - 80 for 9/10 LDPC code table 5a, Page 22.
    bb_header(47 downto 32) := x"E300";
    -- SYNC byte not using  
    bb_header(55 downto 48) := x"00"; 
    -- SYNCD byte
    bb_header(71 downto 56) := x"0000";
    --CRC-8
    bb_header(79 downto 72) := x"00";
    return bb_header;
  end;
  -- internatl signals.

  --signal  bb_header : std_logic_vector((BB_HEADER_LEN * 8) -1 downto 0);
  
  -- FSM --
  type state_type is (idle, write_ram, read_ram);
  type data_type is array (0 to (MAX_AXI_WORDS - 1)) of std_logic_vector(TDATA_WIDTH- 1 downto 0);
  signal ram: data_type;
  signal state : state_type;
  signal tlast_i : std_logic;
  signal ram_wren : std_logic;
  signal ram_wrndx : positive;
  signal ram_wrcomplete : boolean := False;
  signal ram_rdndx : positive;
  signal ram_rden : std_logic;
  signal ram_rdcomplete : boolean := False;
  signal s_tready_i : std_logic;
  signal m_tvalid_i : std_logic;
  constant BB_HEADER : std_logic_vector := get_bbheader;
  begin
  
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
          state <= read_ram;
        else
          state <= write_ram;
        end if;
      when read_ram =>
      -- when writing to ram is complete, switch back to idle to read again.
      if (ram_rdcomplete) then
        state <= idle;
      else
        state <= read_ram;
      end if;
      when others =>
        state <= idle;
      end case;    
    end if;
  end process;

  -- sink/reader is always ready to accept s_tdata and write to ram until the ram is full.
  -- counter/index to keep track of writes to ram.
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
      -- fill till complete bbframe size.
      if (ram_wrndx = MAX_AXI_WORDS -1) then
        -- last AXI word received. write to ram done.
        ram_wrcomplete <= True;
        ram_wrndx <= 0;
      end if;
    end if;
  end if;
  end process;

  -- counter/index to keep track of read from ram.
  process(clk, rst)
  begin
  if rst = '1' then
    ram_rdndx <= 0;
  elsif clk'event and clk = '1' then
    if (ram_rdndx > 0 ) then
      if (ram_rden = '1') then
        -- ram_wrndx pointer is incremented after every write to ram. 
        -- This is done only when ram_wren is 1;
        ram_rdndx <= ram_rdndx - 1;
        ram_rdcomplete <= False;
      end if;
      if (ram_rdndx = 0) then
        -- last AXI word received. write to ram done.
        ram_rdcomplete <= True;
      end if;
    end if;
  elsif (ram_rdndx = 0 and ram_wrcomplete) then
    ram_rdndx <= ram_wrndx;
  end if;
  end process;


  --ram_wren to enable write to write to ram
  ram_wren <= '1' when (s_tvalid = '1'  and s_tready_i = '1' and ram_rden = '0') else '0';
  
  -- write to ram 
  process(clk, rst)
  begin
  if rst = '1' then
  elsif clk'event and clk = '1' then
    if (ram_wren = '1' and s_tvalid = '1') then
     -- we need to accumulate till we have received PDU of BBLENGTH
      ram(ram_wrndx) <= s_tdata (TDATA_WIDTH -1 downto 0);
    end if;
  end if;
  end process;  

  -- generate m_tvalid
  data_p : process(clk, rst)
  begin
  if rst = '1' then
    m_tvalid_i <= '0';
  elsif clk'event and clk = '1' then
    if (state = read_ram and ram_rden = '1') then
      m_tvalid_i <= '1';
    else
      m_tvalid_i <= '0';
    end if;
  end if;
  end process data_p;

--generate m_tdata i.e read from ram
    process(clk)
    begin
    if clk'event and clk = '1' then
      if (ram_rden = '1' and m_tvalid_i = '1') then
        m_tdata <= ram(ram_rdndx)(7 downto 0);
      end if;
    end if;
  --gse_pkt((MAX_UDP_PKT_SIZE * 8) -1 downto (MAX_UDP_PKT_SIZE - GSE_HEADER_LEN) * 8) <= gse_header( GSE_HEADER_LEN * 8 -1 downto 0);
  -- gse_pkt( (MAX_UDP_PKT_SIZE - GSE_HEADER_LEN ) * 8 -1 downto 
    end process;
    
--genearte m_tlast  
  last_p : process(clk, rst)
  begin
  if rst = '1' then
    m_tlast <= '0';
  elsif clk'event and clk = '1' then
    if (ram_rdcomplete) then
      m_tlast <= '1';
    else
      m_tlast <= '0';
    end if;
  end if;
  end process last_p;
end axi_gse_bbframe;
