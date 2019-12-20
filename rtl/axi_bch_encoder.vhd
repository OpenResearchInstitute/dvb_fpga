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

---------------------------------
-- Block name and description --
--------------------------------

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
        return (result / TDATA_WIDTH) - 1;
    end function get_crc_length;

    -------------
    -- Signals --
    -------------
    signal bch_code        : std_logic_vector(1 downto 0);
    signal s_is_first_word : std_logic;

    signal axi_delay_tvalid : std_logic;
    signal axi_delay_tdata  : std_logic_vector(TDATA_WIDTH - 1 downto 0);
    signal axi_delay_tlast  : std_logic;
    signal axi_delay_tready : std_logic;

    signal axi_delay_data_valid : std_logic;
    signal s_axi_data_valid     : std_logic;
    signal m_axi_data_valid     : std_logic;

    -- Internals to wire output ports
    signal s_tready_i : std_logic;
    signal m_tvalid_i : std_logic;
    signal m_tlast_i  : std_logic;

    -- Largest is 192 bits, use a slice when handling polynomials with smaller contexts
    signal crc_word_cnt : unsigned(numbits(MAX_WORD_CNT) - 1 downto 0);
    signal crc          : std_logic_vector(191 downto 0);
    signal next_crc     : std_logic_vector(191 downto 0);

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
            fd    => s_is_first_word,
            nd    => s_axi_data_valid,
            rdy   => open,
            d     => s_tdata,
            c     => crc,
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

    ---------------
    -- Processes --
    ---------------
    process(clk, rst)
    begin
        if rst = '1' then
            crc_word_cnt        <= (others => '0');
            s_is_first_word <= '1';
        elsif clk'event and clk = '1' then

            m_tlast_i <= '0';

            -- Transfer data from the AXI delay
            if crc_word_cnt = 0 then
                axi_delay_tready <= m_tready;
                m_tvalid_i       <= axi_delay_tvalid;
                m_tdata          <= axi_delay_tdata;
            end if;

            if m_axi_data_valid = '1' then
                -- Transfer data from the CRC block
                if crc_word_cnt /= 0 then
                    m_tdata    <= next_crc(crc'length - 1 downto crc'length - TDATA_WIDTH);
                    next_crc   <= next_crc(crc'length - TDATA_WIDTH - 1 downto 0) & (TDATA_WIDTH - 1 downto 0 => 'U');
                    crc_word_cnt   <= crc_word_cnt - 1;

                    -- On the cycle before last, assert tlast but also release the
                    -- internal AXI delay so that data is assigned in
                    if crc_word_cnt = 1 then
                        m_tlast_i <= '1';
                        axi_delay_tready <= '1';
                    end if;
                end if;
            end if;

            if s_axi_data_valid = '1' then
                s_is_first_word <= '0';
                if s_is_first_word = '1' then
                    bch_code <= cfg_bch_code;
                end if;
            end if;

            -- Handle tht delayed AXI data. When that completes the frame (e.g tlast is
            -- high), load the CRC word counter and switch to append CRC mode
            if axi_delay_data_valid = '1' and axi_delay_tlast = '1' then
                -- TODO: Check if this uses the carry bit to reset
                -- crc_word_cnt   <= 0 - to_unsigned(get_crc_length(bch_code), crc_word_cnt'length);
                crc_word_cnt   <= to_unsigned(get_crc_length(bch_code), crc_word_cnt'length);
                -- Block further data
                axi_delay_tready <= '0';
                -- Switch mode
                m_tvalid_i <= '1';
                -- Assign the very first CRC word
                m_tdata    <= crc(crc'length - 1 downto crc'length - TDATA_WIDTH);
                next_crc   <= crc(crc'length - TDATA_WIDTH - 1 downto 0) & (TDATA_WIDTH - 1 downto 0 => 'U');
            end if;

        end if;
    end process;

end axi_bch_encoder;
