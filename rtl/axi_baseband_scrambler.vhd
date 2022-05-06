--
-- DVB FPGA
--
-- Copyright 2019-2021 by Suoto <andre820@gmail.com>
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
---------------------------------
-- Block name and description --
--------------------------------

---------------
-- Libraries --
---------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------
-- Entity declaration --
------------------------
entity axi_baseband_scrambler is
  generic (
    TDATA_WIDTH : positive := 8;
    TID_WIDTH   : natural  := 0
  );
  port (
    -- Usual ports
    clk      : in  std_logic;
    rst      : in  std_logic;

    -- AXI input
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
end axi_baseband_scrambler;

architecture axi_baseband_scrambler of axi_baseband_scrambler is

  ---------------
  -- Constants --
  ---------------
  constant LFSR_WIDTH : integer := 15;
  constant LFSR_INIT  : std_logic_vector(LFSR_WIDTH - 1 downto 0) := "000000010101001";

  -------------
  -- Signals --
  -------------
  signal lfsr       : std_logic_vector(LFSR_WIDTH - 1 downto 0);
  signal s_axi_dv   : std_logic;
  signal m_axi_dv   : std_logic;

  -- Internals
  signal s_tready_i : std_logic;
  signal m_tvalid_i : std_logic;
  signal m_tdata_i  : std_logic_vector(TDATA_WIDTH - 1 downto 0);
  signal m_tid_i    : std_logic_vector(TID_WIDTH - 1 downto 0);

begin

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  s_axi_dv <= s_tready_i and s_tvalid;
  m_axi_dv <= m_tready and m_tvalid_i;

  s_tready_i <= m_tready;

  -- Assign internals
  m_tdata  <= m_tdata_i when m_tvalid_i = '1' else (others => 'U');
  m_tid    <= m_tid_i when m_tvalid_i = '1' else (others => 'U');
  s_tready <= s_tready_i;
  m_tvalid <= m_tvalid_i;

  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
    variable next_lfsr : std_logic_vector(LFSR_WIDTH - 1 downto 0);
  begin
    if rst = '1' then
      lfsr       <= LFSR_INIT;
      m_tlast    <= '0';
      m_tvalid_i <= '0';
    elsif clk'event and clk = '1' then
      if m_axi_dv = '1' then
        m_tvalid_i <= '0';
        m_tlast    <= '0';
      end if;

      if s_axi_dv = '1' then
        m_tvalid_i <= '1';
        m_tlast    <= s_tlast;
        m_tid_i    <= s_tid;

        -- Calculate the next LFSR
        next_lfsr := lfsr;
        for i in 0 to TDATA_WIDTH - 1 loop
          next_lfsr := next_lfsr(LFSR_WIDTH - 2 downto 0) & (next_lfsr(13) xor next_lfsr(14));
          m_tdata_i(TDATA_WIDTH - 1 - i) <= next_lfsr(0) xor s_tdata(TDATA_WIDTH - 1 - i);
        end loop;

        -- Reinit the LFSR at every end of frame
        lfsr   <= next_lfsr;
        if s_tlast = '1' then
          lfsr <= LFSR_INIT;
        end if;

      end if;
    end if;
  end process;

end axi_baseband_scrambler;
