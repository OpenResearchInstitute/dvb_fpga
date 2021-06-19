--
-- DVB IP
--
-- Copyright 2019 by Suoto <andre820@gmail.com>
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
---------------
-- Libraries --
---------------
library	ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpga_cores;
use fpga_cores.common_pkg.all;

use work.dvb_utils_pkg.all;

library fpga_cores;

------------------------
-- Entity declaration --
------------------------
entity axi_bch_encoder is
  generic ( TID_WIDTH   : integer := 0 );
  port (
    -- Usual ports
    clk          : in  std_logic;
    rst          : in  std_logic;
    -- AXI input
    s_frame_type : in  frame_type_t;
    s_code_rate  : in  code_rate_t;
    s_tvalid     : in  std_logic;
    s_tlast      : in  std_logic;
    s_tready     : out std_logic;
    s_tdata      : in  std_logic_vector(7 downto 0);
    s_tid        : in  std_logic_vector(TID_WIDTH - 1 downto 0);
    -- AXI output
    m_tready     : in  std_logic;
    m_tvalid     : out std_logic;
    m_tlast      : out std_logic;
    m_tdata      : out std_logic_vector(7 downto 0);
    m_tid        : out std_logic_vector(TID_WIDTH - 1 downto 0));
end axi_bch_encoder;

architecture axi_bch_encoder of axi_bch_encoder is

  ---------------
  -- Constants --
  ---------------
  -- Leaving this as constant in case we need to change in the future. The main issue is
  -- the actual CRC blocks are not generic (they were generated individually), so support
  -- other data widths values is not trivial
  constant TDATA_WIDTH : integer := 8;
  -- To count to the max number of words appended to the frame
  constant MAX_WORD_CNT : integer := 192 / TDATA_WIDTH;

  -------------
  -- Signals --
  -------------
  signal cfg_frame_type_out   : frame_type_t;
  signal cfg_code_rate_out    : code_rate_t;

  signal s_axi_first_word     : std_logic;
  signal tid_reg              : std_logic_vector(TID_WIDTH - 1 downto 0);

  signal axi_delay_tvalid     : std_logic;
  signal axi_delay_tdata      : std_logic_vector(TDATA_WIDTH - 1 downto 0);
  signal axi_delay_tid        : std_logic_vector(TID_WIDTH - 1 downto 0);
  signal axi_delay_tlast      : std_logic;
  signal axi_delay_tready     : std_logic;

  signal axi_delay_data_valid : std_logic;
  signal s_axi_data_valid     : std_logic;
  signal m_axi_data_valid     : std_logic;

  -- Internals to wire output ports
  signal s_tready_i           : std_logic;
  signal m_tvalid_i           : std_logic := '0';
  signal m_tlast_i            : std_logic := '0';

  -- Largest is 192 bits, use a slice when handling polynomials with smaller contexts
  signal crc_word_cnt         : unsigned(numbits(MAX_WORD_CNT) - 1 downto 0);
  signal crc_word_cnt_next    : unsigned(numbits(MAX_WORD_CNT) - 1 downto 0);
  signal crc                  : std_logic_vector(191 downto 0);
  signal crc_srl              : std_logic_vector(191 downto 0);
  signal crc_sample           : std_logic := '0';
  signal crc_sample_delay     : std_logic := '0';

begin

  -------------------
  -- Port mappings --
  -------------------
  -- Delay the incoming data to match the BCH calculation delay so we can switch to
  -- appending without any bubbles
  data_delay_block : block
    signal tdata_agg_in  : std_logic_vector(TID_WIDTH + TDATA_WIDTH downto 0);
    signal tdata_agg_out : std_logic_vector(TID_WIDTH + TDATA_WIDTH downto 0);
  begin
    tdata_agg_in    <= s_tlast & s_tid & s_tdata;

    axi_delay_tdata <= tdata_agg_out(TDATA_WIDTH - 1 downto 0);
    axi_delay_tid   <= tdata_agg_out(TID_WIDTH + TDATA_WIDTH - 1 downto TDATA_WIDTH);
    axi_delay_tlast <= tdata_agg_out(TID_WIDTH + TDATA_WIDTH);

    data_delay_u : entity fpga_cores.axi_stream_delay
      generic map (
        DELAY_CYCLES => 2,
        TDATA_WIDTH  => tdata_agg_in'length)
      port map (
        -- Usual ports
        clk     => clk,
        rst     => rst,

        -- AXI slave input
        s_tvalid => s_tvalid,
        s_tready => s_tready_i,
        s_tdata  => tdata_agg_in,

        -- AXI master output
        m_tvalid => axi_delay_tvalid,
        m_tready => axi_delay_tready,
        m_tdata  => tdata_agg_out);
  end block data_delay_block;

  -- BCH encoders are wrapped with a mux to hide away unrelated stuff. The idea is to keep
  -- the generated CRC codes as similar as possible to how they were generated
  bch_u : entity work.bch_encoder_mux
    port map (
      clk                => clk,
      rst                => rst,

      -- Input data
      cfg_frame_type_in  => s_frame_type,
      cfg_code_rate_in   => s_code_rate,

      first_word         => s_axi_first_word,
      wr_en              => s_axi_data_valid,
      wr_data            => s_tdata,

      -- Output data
      cfg_frame_type_out => cfg_frame_type_out,
      cfg_code_rate_out  => cfg_code_rate_out,

      crc_rdy            => open,
      crc                => crc,
      data_out           => open);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  s_axi_data_valid     <= '1' when s_tready_i = '1' and s_tvalid = '1' else '0';
  axi_delay_data_valid <= '1' when axi_delay_tvalid = '1' and axi_delay_tready = '1' else
                          '0';
  m_axi_data_valid     <= '1' when m_tready = '1' and m_tvalid_i = '1' else '0';

  -- Assign internals
  s_tready <= s_tready_i;
  m_tvalid <= m_tvalid_i;
  m_tlast  <= m_tlast_i;

  -- Mux AXI master output to either forward AXI slave (via AXI delay) or to append the
  -- CRC
  axi_delay_tready <= m_tready when crc_word_cnt = 0 else '0';

  m_tvalid_i       <= '0' when rst = '1' else
                      axi_delay_tvalid when crc_word_cnt = 0 else
                      '1';

  m_tdata          <= (others => 'U') when m_tvalid_i = '0' else
                      axi_delay_tdata when crc_word_cnt = 0 else
                      crc_srl(crc_srl'length - 1 downto crc_srl'length - TDATA_WIDTH);

  -- Use axi_delay_tid when passing data through and tid_reg when appending the CRC
  m_tid            <= (others => 'U') when m_tvalid_i = '0' else
                      (tid_reg       and     (m_tid'range => or(crc_word_cnt))) or
                      (axi_delay_tid and not (m_tid'range => or(crc_word_cnt)));

  m_tlast_i        <= '1' when crc_word_cnt = 1 else '0';

  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
  begin
    if rst = '1' then
      crc_word_cnt      <= (others => '0');
      s_axi_first_word  <= '1';

      -- Avoiding unnecessary muxes with rst
      crc_word_cnt_next <= (others => 'U');
      crc_sample        <= 'U';
      crc_sample_delay  <= 'U';
      crc_srl           <= (others => 'U');
    elsif clk'event and clk = '1' then

      crc_sample       <= '0';
      crc_sample_delay <= crc_sample;

      if m_axi_data_valid = '1' then
        if crc_word_cnt = 0 then
          tid_reg <= axi_delay_tid;
        else
          -- Shift the CRC, tdata will be assigned to the MSB
          crc_srl      <= crc_srl(crc_srl'length - TDATA_WIDTH - 1 downto 0)
                          & (TDATA_WIDTH - 1 downto 0 => 'U');
          crc_word_cnt <= crc_word_cnt - 1;
        end if;
      end if;

      if s_axi_data_valid = '1' then
        -- Need to mark the first word so the CRC block can reset the calculation
        s_axi_first_word <= s_tlast;

        -- Need to sync when the CRC output is actually what we want, since we won't
        -- necessarily stop writing data to the CRC calculation block
        if s_tlast = '1' then
          crc_sample      <= '1';
        end if;

        if s_tlast = '1' then
          -- This is mostly static, so division should not be a problem. In any case,
          -- TDATA_WIDTH will always be a power of 2, so this division will map to a shift
          -- operation
          crc_word_cnt_next <= to_unsigned(
                            get_crc_length(s_frame_type, s_code_rate) / TDATA_WIDTH,
                            crc_word_cnt'length);
        end if;

      end if;

      -- Time when the CRC is actually completed to sample it
      if crc_sample_delay = '1' then
        -- CRC widths vary, by default BCH encoder mux fills in the LSB. Because we use
        -- the MSB and shift it left, fill in the MSB part of the SRL
        if get_crc_length(cfg_frame_type_out, cfg_code_rate_out) = 128 then
          crc_srl <= crc(127 downto 0) & (63 downto 0 => 'U');
        elsif get_crc_length(cfg_frame_type_out, cfg_code_rate_out) = 160 then
          crc_srl <= crc(159 downto 0) & (31 downto 0 => 'U');
        elsif get_crc_length(cfg_frame_type_out, cfg_code_rate_out) = 168 then
          crc_srl <= crc(167 downto 0) & (23 downto 0 => 'U');
        else
          crc_srl <= crc;
        end if;
      end if;

      -- Handle the completion of AXI delayed data (e.g tlast is high). When that
      -- happens, load the CRC word counter, which will trigger switching to append CRC
      -- mode
      if axi_delay_data_valid = '1' and axi_delay_tlast = '1' then
        crc_word_cnt <= crc_word_cnt_next;
      end if;

    end if;
  end process;
end axi_bch_encoder;
