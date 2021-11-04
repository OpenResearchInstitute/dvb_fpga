--
-- DVB FPGA
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpga_cores;
use fpga_cores.common_pkg.all;

use work.dvb_utils_pkg.all;
use work.ldpc_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity gse_encoder is
  generic ( DATA_WIDTH : integer := 1);
  port (
    -- Usual ports
    clk               : in  std_logic;
    rst               : in  std_logic;

    -- Frame MODCOD configuration -- will take effect once the current baseband frame is
    -- completed
    cfg_frame_type    : in frame_type_t;
    cfg_constellation : in constellation_t;
    cfg_code_rate     : in code_rate_t;

    -- Write side
    -- MODCOD is used to calculate the baseband frame length
    s_pdu_byte_length : in  std_logic_vector(15 downto 0);
    s_tvalid          : in  std_logic;
    s_tready          : out std_logic;
    s_tdata           : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    s_tlast           : in  std_logic;

    -- Read side
    m_constellation   : out constellation_t;
    m_frame_type      : out frame_type_t;
    m_code_rate       : out code_rate_t;
    m_tvalid          : out std_logic;
    m_tready          : in  std_logic;
    m_tdata           : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    m_tlast           : out std_logic);
end entity gse_encoder;

architecture gse_encoder of gse_encoder is

  ---------------
  -- Constants --
  ---------------
  constant BASEBAND_FRAME_LENGTH_WIDTH : integer := numbits(FECFRAME_NORMAL_BIT_LENGTH / 8);
  constant GSE_LENGTH_OFFSET : integer := 1 + 2 + 2 + 6;

  -- Frame length in bits, should be mapped in LUT ROM
  function get_baseband_frame_length (
    constant frame_type    : frame_type_t;
    constant constellation : constellation_t;
    constant code_rate     : code_rate_t ) return unsigned is
    variable result        : integer := -1;
  begin
    case frame_type is
      when FECFRAME_NORMAL =>
        case code_rate is
          when C1_4 => result := 16_008;
          when C1_3 => result := 21_408;
          when C2_5 => result := 25_728;
          when C1_2 => result := 32_208;
          when C3_5 => result := 38_688;
          when C2_3 => result := 43_040;
          when C3_4 => result := 48_408;
          when C4_5 => result := 51_648;
          when C5_6 => result := 53_840;
          when C8_9 => result := 57_472;
          when C9_10 => result := 58_192;
          when others => null;
        end case;
      when FECFRAME_SHORT =>
        case code_rate is
          when C1_4 => result := 3_072;
          when C1_3 => result := 5_232;
          when C2_5 => result := 6_312;
          when C1_2 => result := 7_032;
          when C3_5 => result := 9_552;
          when C2_3 => result := 10_632;
          when C3_4 => result := 11_712;
          when C4_5 => result := 12_432;
          when C5_6 => result := 13_152;
          when C8_9 => result := 14_232;
          when others => null;
        end case;
      when others => null;
    end case;

    assert result /= -1
      report "Unable to get baseband frame length for " &
      "frame_type=" & frame_type_t'image(frame_type) & ", " &
      "constellation=" & constellation_t'image(constellation) & ", " &
      "code_rate=" & code_rate_t'image(code_rate)
      severity Failure;

    return to_unsigned(result / 8, BASEBAND_FRAME_LENGTH_WIDTH);
  end;

  -----------
  -- Types --
  -----------

  -- PDU fits in the baseband frame (no frag), 6 byte label, no extension
  -- | 1 | 1 | 00 | gse length | protocol type | 6 byte label | PDU data | CRC |
  --  <---------------------- 10 bytes ---------------------->

  -- PDU start but does not fit in the baseband frame, i.e., fragment. 6 byte label, no extension
  -- | 1 | 0 | 00 | gse length | fragment ID | total length | protocol type | 6 byte label | PDU data |
  --  <----------------------------------- 13 bytes -------------------------------------->
  -- | 0 | 0 | 11 | gse length | fragment ID | PDU data |
  --  <-------------- 3 bytes -------------->
  -- | 0 | 1 | 11 | gse length | fragment ID | PDU data | CRC |
  --  <-------------- 3 bytes -------------->


  -- Pass header through a axi_stream_width_converter from 13 to 1 and use tkeep to select
  -- which bytes should be written. Assign input tlast set to high and ignore output
  -- tlast. Actual PDU data connects in parallel via arbiter (prio=abs). CRC is 4 bytes
  -- and can go through width conv as well.
  -- Might be possible to use arbiter with prio=RR and use tlast to mark end of segments

  type state_t is (idle_st, insert_gse_header, done_st);

  -- Fields that are always present
  type gse_header_t is record
    start_indicator      : std_logic;
    end_indicator        : std_logic;
    label_type_indicator : std_logic_vector(1 downto 0);
    gse_length           : unsigned(11 downto 0);
  end record;

  -------------
  -- Signals --
  -------------
  signal state                : state_t;

  signal start_indicator      : std_logic;
  signal end_indicator        : std_logic;
  signal label_type_indicator : std_logic_vector(1 downto 0);
  signal gse_length           : unsigned(11 downto 0);

  signal gse_header_tvalid    : std_logic;
  signal gse_header_tready    : std_logic;
  signal gse_header           : std_logic_vector(13*8 - 1 downto 0);
  signal gse_header_mask      : std_logic_vector(12 downto 0);

  signal bb_frame_byte_length : unsigned(BASEBAND_FRAME_LENGTH_WIDTH - 1 downto 0);
  signal pdu_byte_length      : unsigned(15 downto 0);
  signal byte_count           : unsigned(BASEBAND_FRAME_LENGTH_WIDTH - 1 downto 0);
  signal first_word           : std_logic;
  signal s_axi_dv             : std_logic;
  signal s_tready_i           : std_logic;
  signal m_tdata_i           : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

  -------------------
  -- Port mappings --
  -------------------
  header_width_conversion : entity fpga_cores.axi_stream_width_converter
    generic map (
      INPUT_DATA_WIDTH    => 13*8,
      OUTPUT_DATA_WIDTH   => 8,
      AXI_TID_WIDTH       => 0,
      IGNORE_TKEEP        => False)
    port map (
      -- Usual ports
      clk      => clk,
      rst      => rst,
      -- AXI stream input
      s_tready => gse_header_tready,
      s_tdata  => gse_header,
      s_tkeep  => gse_header_mask,
      s_tvalid => gse_header_tvalid,
      s_tlast  => '1',
      -- AXI stream output
      m_tready => '1',
      m_tdata  => m_tdata_i,
      m_tkeep  => open,
      m_tvalid => m_tvalid,
      m_tlast  => open);


  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  s_axi_dv <= s_tvalid and s_tready_i;
  s_tready <= s_tready_i;
  m_tdata  <= mirror_bits(m_tdata_i);

  pdu_byte_length <= unsigned(s_pdu_byte_length);

  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
    variable header : std_logic_vector(13*8 - 1 downto 0);
  begin
    if rst = '1' then
      first_word           <= '1';
      bb_frame_byte_length <= (others => 'U');
      byte_count           <= (others => '0');

      start_indicator      <= 'U';
      end_indicator        <= 'U';
      label_type_indicator <= (others => '0');
      gse_length           <= (others => 'U');

      gse_header_tvalid    <= '0';
      gse_header           <= (others => 'U');
    elsif clk'event and clk = '1' then

      gse_header_tvalid <= '0';

      case state is
        when idle_st =>
          -- When byte count is 0 it means we're starting the current baseband frame
          if byte_count = 0 then
            bb_frame_byte_length     <= get_baseband_frame_length(cfg_frame_type, cfg_constellation, cfg_code_rate);
          end if;
          start_indicator <= '1';

          -- Treat s_tvalid as a request to transmit. Need to insert GSE header before
          -- adding the actual data
          if s_tvalid then
            state <= insert_gse_header;

            -- Set the end indicator if the GSE encapsulated PDU fits the current baseband
            -- frame
            if byte_count + pdu_byte_length + (1 + 2 + 2 + 6) < bb_frame_byte_length then
              end_indicator <= '1';
              gse_length    <= (1 + 2 + 2 + 6) + pdu_byte_length(11 downto 0);

              -- Sanity check: it PDU fits into the (remaining) baseband frame, its length
              -- can't be greater than the max GSE length
              assert pdu_byte_length(15 downto 12) = 0;

            else
              -- PDU does not fit the current baseband frame, will need to fragment it
              end_indicator <= '0';
              gse_length    <= (others => '1'); -- 4095 bytes
            end if;
          end if;

        when insert_gse_header =>
            gse_header        <= (others => 'U');
            header(71 downto 0)        := start_indicator & end_indicator & label_type_indicator & std_logic_vector(gse_length)  -- 2 bytes
                                 & std_logic_vector(pdu_byte_length) -- 2 bytes
                                 & x"0800" -- 2 bytes
                                 & x"012345"; -- 3 bytes

            gse_header(71 downto 0) <= mirror_bits(header(71 downto 0));

            gse_header_mask             <= (others => '0');
            gse_header_mask(8 downto 0) <= (others => '1');
            gse_header_tvalid <= '1';
            if gse_header_tready then
              state <= done_st;
            end if;

  -- | 1 | 1 | 00 | gse length | protocol type | 6 byte label | PDU data | CRC |

        when done_st => null;
        when others =>
          state <= idle_st;

      end case;

    end if;
  end process;

end gse_encoder;
