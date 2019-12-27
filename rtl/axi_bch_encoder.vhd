--
-- DVB IP
--
-- Copyright 2019 by Andre Souto (suoto)
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

library str_format;
    use str_format.str_format_pkg.all;

use work.common_pkg.all;
use work.bch_encoder_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_bch_encoder is
  generic (
    TDATA_WIDTH : integer  := 8
  );
  port (
    -- Usual ports
    clk     : in  std_logic;
    rst     : in  std_logic;

    cfg_bch_code : in  std_logic_vector(1 downto 0);

    -- AXI input
    s_tvalid : in  std_logic;
    s_tdata  : in  std_logic_vector(TDATA_WIDTH - 1 downto 0);
    s_tlast  : in  std_logic;
    s_tready : out std_logic;

    -- AXI output
    m_tready : in  std_logic;
    m_tvalid : out std_logic;
    m_tlast  : out std_logic;
    m_tdata  : out std_logic_vector(TDATA_WIDTH - 1 downto 0));
end axi_bch_encoder;

architecture axi_bch_encoder of axi_bch_encoder is

  ---------------
  -- Constants --
  ---------------
  -- To count to the max number of words appended to the frame
  constant MAX_WORD_CNT : integer := 192 / TDATA_WIDTH;

  function get_crc_length (
    constant bch_code : in std_logic_vector(1 downto 0)) return integer is
    variable result   : integer := -1;
  begin
    if unsigned(bch_code) = BCH_POLY_8 then
      result := 128;
    elsif unsigned(bch_code) = BCH_POLY_10 then
      result := 160;
    elsif unsigned(bch_code) = BCH_POLY_12 then
      result := 192;
    else
      report "Invalid BCH code " & integer'image(to_integer(unsigned(bch_code)))
      severity Failure;
    end if;
    -- This is mostly static, so division should not be a problem. In any case,
    -- TDATA_WIDTH will always be a power of 2, so this division will map to a shift
    -- operation
    return (result / TDATA_WIDTH);
  end function get_crc_length;

  -------------
  -- Signals --
  -------------
  signal bch_code             : std_logic_vector(1 downto 0);
  signal s_axi_first_word      : std_logic;

  signal axi_delay_tvalid     : std_logic;
  signal axi_delay_tdata      : std_logic_vector(TDATA_WIDTH - 1 downto 0);
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
  signal crc_ulogic           : std_ulogic_vector(191 downto 0);
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
    signal tdata_agg_in  : std_logic_vector(TDATA_WIDTH downto 0);
    signal tdata_agg_out : std_logic_vector(TDATA_WIDTH downto 0);
  begin
    tdata_agg_in    <= s_tlast & s_tdata;

    axi_delay_tdata <= tdata_agg_out(TDATA_WIDTH - 1 downto 0);
    axi_delay_tlast <= tdata_agg_out(TDATA_WIDTH);

    data_delay_u : entity work.axi_stream_delay
    generic map (
      DELAY_CYCLES => 2,
      TDATA_WIDTH  => TDATA_WIDTH + 1)
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

  -- BCH Encders as
  -- Keep the BCH encoders as similar as possible to what was generated at
  -- https://leventozturk.com/engineering/crc/
  bch_u : entity work.bch_192x8
    generic map (SEED => (others => '0'))
    port map (
      clk   => clk,
      reset => rst,
      fd    => s_axi_first_word,
      nd    => s_axi_data_valid,
      rdy   => open,
      d     => std_ulogic_vector(s_tdata),
      c     => crc_ulogic,
      o     => open);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  s_axi_data_valid     <= '1' when s_tready_i = '1' and s_tvalid = '1' else '0';
  axi_delay_data_valid <= '1' when axi_delay_tvalid = '1' and axi_delay_tready = '1' else '0';
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

  m_tdata          <= axi_delay_tdata when crc_word_cnt = 0 else
                      crc_srl(crc_srl'length - 1 downto crc_srl'length - TDATA_WIDTH);

  m_tlast_i <= '1' when crc_word_cnt = 1 else '0';

  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
  begin
    if rst = '1' then
      crc_word_cnt    <= (others => '0');
      s_axi_first_word <= '1';
    elsif clk'event and clk = '1' then

      crc_sample       <= '0';
      crc_sample_delay <= crc_sample;

      if m_axi_data_valid = '1' and crc_word_cnt /= 0 then
        -- Shift the CRC, tdata will be assigned to the MSB
        crc_srl      <= crc_srl(crc_srl'length - TDATA_WIDTH - 1 downto 0) & (TDATA_WIDTH - 1 downto 0 => 'U');
        crc_word_cnt <= crc_word_cnt - 1;
      end if;

      if s_axi_data_valid = '1' then
        -- Need to mark the first word so the CRC block can reset the calculation
        s_axi_first_word <= s_tlast;

        -- Need to sync when the CRC output is actually what we want, since we won't
        -- necessarily stop writing data to the CRC calculation block
        if s_tlast = '1' then
          crc_sample <= '1';
        end if;

        -- Sample the BCH code used on the first word
        if s_axi_first_word = '1' then
          bch_code <= cfg_bch_code;
        end if;

      end if;

      -- Time when the CRC is actually completed to sample it
      if crc_sample_delay = '1' then
        crc_srl <= std_logic_vector(crc_ulogic);
      end if;

      -- Handle the completion of AXI delayed data (e.g tlast is high). When that
      -- happens, load the CRC word counter, which will trigger switching to append CRC
      -- mode
      if axi_delay_data_valid = '1' and axi_delay_tlast = '1' then
        -- TODO: Check if this uses the carry bit to reset
        -- crc_word_cnt   <= 0 - to_unsigned(get_crc_length(bch_code), crc_word_cnt'length);
        crc_word_cnt     <= to_unsigned(get_crc_length(bch_code), crc_word_cnt'length);
      end if;

    end if;
  end process;

end axi_bch_encoder;
