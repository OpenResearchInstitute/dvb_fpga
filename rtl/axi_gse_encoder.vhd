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
    TID_WIDTH   : natural  := 0;
    GSE_START_HEADER_LEN : positive := 10;
    GSE_END_HEADER_LEN : positive := 10
  );
  port (
    -- Usual ports
    clk      : in  std_logic;
    rst      : in  std_logic;

    -- AXI input
    --s_frame_type : in  frame_type_t;
    --s_code_rate  : in  code_rate_t;
    s_pdu_length : in  std_logic_vector(15 downto 0);
    s_tvalid : in  std_logic;
    s_tlast  : in  std_logic;
    s_tready : out std_logic;
    s_tdata  : in  std_logic_vector(TDATA_WIDTH - 1 downto 0);
    --s_tid    : in  std_logic_vector(TID_WIDTH - 1 downto 0);

    -- AXI output
    m_tready : in  std_logic;
    m_tvalid : out std_logic;
    m_tlast  : out std_logic;
    m_tdata  : out std_logic_vector(TDATA_WIDTH - 1 downto 0));
    --m_tid    : out std_logic_vector(TID_WIDTH - 1 downto 0));
end axi_gse_encoder;

architecture axi_gse_encoder of axi_gse_encoder is
  
  impure function get_gse_end_header return std_logic_vector is
  variable pdu_length : unsigned(15 downto 0);
  variable  gse_end_header : std_logic_vector((GSE_END_HEADER_LEN * 8)  - 1  downto 0);
  begin
    pdu_length := unsigned(s_pdu_length(15 downto 0));
    if (pdu_length < 4096) then
      -- start bit
      gse_end_header(0) := '0';
      --end bit
      gse_end_header(1) := '1';
      -- label type
      gse_end_header(3 downto 2) := "11";
      -- gse length
      gse_end_header(15 downto 4) := s_pdu_length(5 downto 0);
      --frag ID
      gse_end_header(23 downto 16) :=  "11111111";
    -- elsif (pdu_length > 4096 and pdu_length < 8096) then
    -- else if (pdu_length > 8096) then
    end if;
    return gse_end_header;
  end;

  impure function get_gse_start_header return std_logic_array_t is
  variable pdu_length : unsigned(15 downto 0);
  variable gse_start_header : std_logic_array_t(0 to GSE_START_HEADER_LEN -1 )(TDATA_WIDTH -1 downto 0);
  variable pdu_length_i : std_logic_vector(15 downto 0) := x"0118";
  begin
    pdu_length := unsigned(s_pdu_length(15 downto 0));
   if (unsigned(pdu_length_i) < 4096) then
    -- start bit
    gse_start_header(0) := (7 => '1',-- SOF
                            6 => '1', -- EOF
                            5 downto 4 => "11", -- label type
                            3 downto 0 => "0001");
    else
    gse_start_header(0) := (7 => '1',-- SOF
                            6 => '1', -- EOF
                            5 downto 4 => "11", -- label type
                            3 downto 0 => "0001");
    end if;
 
    -- max length 4 k, numbits 6.
    -- currently hardcoded for 256 bytes packet. 256 byte PDU + 5 bytes of remaining header = 261
    gse_start_header(1) := "00001100";
    -- Fragment ID
    gse_start_header(2) :=  x"00";
    -- total length
    --gse_start_header(3) := std_logic_vector(pdu_length_i(15 downto 8));
    --gse_start_header(4) := std_logic_vector(pdu_length_i(7 downto 0));
    gse_start_header(3) := x"01";
    gse_start_header(4) := x"00";
    -- protocol type.
    gse_start_header(5) := (x"08");
    gse_start_header(6) := (x"00");
    -- gse_start_header(6) := x"00";
    gse_start_header(7) := (x"00");
    gse_start_header(8) := (x"00");
    gse_start_header(9) := (x"00");
    -- crc
    -- elsif (pdu_length > 4096 and pdu_length < 8096) then
    -- else if (pdu_length > 8096) then
    return gse_start_header;
  end;

  -- 5 state FSM --
    -- SOF is the same for all configs, so we'll only store the PLS
  --constant PLS_ROM       : std_logic_array_t := get_gse_start_header;
  --constant PLS_ROM_DEPTH : integer           := PLS_ROM'length;

  -- internatl signals.
  signal tlast_i : std_logic := '0';
  signal m_tvalid_i : std_logic := '0';
  signal s_tready_i : std_logic := '0';
  signal end_hdr_transfer_complete : boolean := False;
  signal start_hdr_transfer_complete : boolean := False;
  signal end_hdr_ndx : integer := 0;
  --constant  gse_start_header : std_logic_array_t(0 to GSE_START_HEADER_LEN -1 )(TDATA_WIDTH -1 downto 0);
  signal  gse_end_header : std_logic_vector((GSE_END_HEADER_LEN * 8) -1 downto 0);
  signal m_tdata_i : std_logic_vector(TDATA_WIDTH -1 downto 0);
  signal m_tready_to_send : std_logic := '0';
  signal s_tready_to_accept : std_logic := '0';
  type state_type is (idle, send_start_hdr, send_continue_hdr, send_end_hdr, send_pdu, send_crc);
  signal state : state_type := idle;
  constant gse_start_header       : std_logic_array_t := get_gse_start_header;
  signal index : natural range 0 to 9 := 0;
  begin
  
  --gse_start_header <= get_gse_start_header;
  gse_end_header <= get_gse_end_header;
  -- State Machine Implementation
  process(clk, rst)
  begin
    if rst = '1' then
      state <= idle;
      tlast_i <= '0';
      --s_tready_i <= '0'; -- we are not accepting data
      --m_tvalid_i <= '0'; -- we are not sending any data
    elsif rising_edge(clk) then
      case state is
        when idle =>
          if (s_tvalid = '1') then
            state <= send_start_hdr; -- we (master) need to send header first downstream if something is avaialble form upstream
          -- source(upstream or master) has indicated that it has placed valid data.
          --if (s_tvalid = '1') then
          --  s_tready_i <= '0'; -- sink not ready to accept data yet
          --else
           -- state <= idle;
          end if;
        when send_start_hdr =>
          -- send start header. source (we master) start sending data downstream
          --m_tvalid_i <= '1';
          if (start_hdr_transfer_complete) then
            --start header transfer complete. Now change FSM to send_pdu state.
            --m_tvalid_i <= '0';
            state <= send_pdu;
          end if;
        when send_pdu =>
          if s_tlast = '1' then
            --if (unsigned(s_pdu_length(15 downto 0)) > 4096) then
              -- send end header only if size is > 4096.
              --s_tready_i <= '0'; -- sink not accepting any data. Need to send end header.
              --state <= send_end_hdr;
            --else
              state <= idle;
            --end if;
          --else
          --  state <= send_pdu;
            --s_tready_i <= '1'; -- sink receive pdu
            --m_tvalid_i <= '1'; -- source forward it.
          end if;
          /* when send_end_hdr =>
          m_tvalid_i <= '1'; -- forward it.
          --emd header transfer complete. Now change FSM to idle state.
          if (end_hdr_transfer_complete) then
            state <= idle;
            m_tvalid_i <= '0';
          end if;*/
        when others =>
          state <= idle;
      end case;
    end if;
  end process;
  -- m_tvalid_i <= '1';
  -- state <= send_start_hdr;
  ------------------------------
  ---Asynchronous assignments---
  ------------------------------
  -- s_tready <= '1' when s_tvalid = '1' else '0';
  --m_tvalid <= m_tvalid_i;
  m_tready_to_send <= '1' when (m_tready = '1' and state /= idle) else '0';
  m_tvalid <= '1' when (m_tready_to_send = '1') else '0';
  s_tready_to_accept <= '1' when (s_tvalid =  '1' and s_tready = '1' and state /= idle) else '0';
  m_tdata  <= gse_start_header(index) when ( m_tready_to_send = '1' and s_tready_to_accept = '0') else s_tdata when (m_tready_to_send = '1' and s_tready_to_accept = '1');
  m_tlast <= s_tlast  when (m_tready_to_send = '1' and s_tready_to_accept = '1') else '0';
  s_tready <= '1' when (s_tvalid = '1' and state = send_pdu) else '0';
  

  process(clk, rst)
  -- variable index : natural range 0 to 9 := 0;
  begin
  if clk'event and clk = '1' then
    if (state = send_start_hdr) then
      if (m_tready_to_send = '1') then -- wait till we (master) receive ready from slave (downstream)
        if (index < 9) then 
          index <= index + 1;
        end if;
        if (index  = 8) then -- to save on 2 cycles that is used for signal updation.
          start_hdr_transfer_complete <= True;
        end if;
      end if;
    end if;
  end if;   
  end process;
  
  
end axi_gse_encoder;
