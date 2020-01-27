--
-- DVB FPGA
--
-- Copyright 2019 by Suoto <andre820@gmail.com>
--
-- This file is part of DVB FPGA.
--
-- DVB FPGA is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- DVB FPGA is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DVB FPGA.  If not, see <http://www.gnu.org/licenses/>.

---------------------------------
-- Block name and description --
--------------------------------

---------------
-- Libraries --
---------------
library	ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library osvvm;
use osvvm.RandomPkg.all;

library str_format;
use str_format.str_format_pkg.all;

library vunit_lib;
context vunit_lib.vunit_context;


use work.common_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_file_compare is
  generic (
    READER_NAME     : string;
    ERROR_CNT_WIDTH : natural := 8;
    REPORT_SEVERITY : severity_level := Warning;
    -- axi_file_reader config
    DATA_WIDTH      : positive := 1);
  port (
    -- Usual ports
    clk                : in  std_logic;
    rst                : in  std_logic;
    -- Config and status
    tdata_error_cnt    : out std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
    tlast_error_cnt    : out std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
    error_cnt          : out std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
    tready_probability : in real range 0.0 to 1.0 := 1.0;
    -- Debug stuff
    expected_tdata     : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    expected_tlast     : out std_logic;
    -- Data input
    s_tready           : out std_logic;
    s_tdata            : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    s_tvalid           : in  std_logic;
    s_tlast            : in  std_logic);
end axi_file_compare;

architecture axi_file_compare of axi_file_compare is

  -----------
  -- Types --
  -----------

  -------------
  -- Signals --
  -------------
  signal completed         : std_logic;
  signal s_tready_i        : std_logic;
  signal axi_data_valid    : std_logic;

  signal tdata_error_i     : std_logic;
  signal tdata_error_cnt_i : unsigned(ERROR_CNT_WIDTH - 1 downto 0);

  signal tlast_error_i     : std_logic;
  signal tlast_error_cnt_i : unsigned(ERROR_CNT_WIDTH - 1 downto 0);

  signal error_cnt_i       : unsigned(ERROR_CNT_WIDTH - 1 downto 0);
  signal frame_cnt         : integer := 0;
  signal word_cnt          : integer := 0;

  signal expected_tdata_i  : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal expected_tvalid_i : std_logic;
  signal expected_tlast_i  : std_logic;

begin

  -------------------
  -- Port mappings --
  -------------------
  axi_file_reader_u : entity work.axi_file_reader
  generic map (
    READER_NAME => READER_NAME,
    DATA_WIDTH  => DATA_WIDTH)
  port map (
    -- Usual ports
    clk                => clk,
    rst                => rst,
    -- Config and status
    completed          => completed,
    tvalid_probability => 1.0,
    
    -- Data output
    m_tready           => axi_data_valid,
    m_tdata            => expected_tdata_i,
    m_tvalid           => expected_tvalid_i,
    m_tlast            => expected_tlast_i);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  error_cnt       <= std_logic_vector(error_cnt_i);
  tdata_error_cnt <= std_logic_vector(tdata_error_cnt_i);
  tlast_error_cnt <= std_logic_vector(tlast_error_cnt_i);

  expected_tdata  <= expected_tdata_i;
  expected_tlast  <= expected_tlast_i;

  s_tready       <= s_tready_i when expected_tvalid_i = '1' else '0';
  axi_data_valid <= '1' when s_tready_i = '1' and s_tvalid = '1' and expected_tvalid_i = '1'
                    else '0';

  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
    variable tready_rand : RandomPType;
  begin
    if rst = '1' then
      s_tready_i        <= '0';

      tdata_error_cnt_i <= (others => '0');
      tlast_error_cnt_i <= (others => '0');
      error_cnt_i       <= (others => '0');
      frame_cnt         <= 0;
      word_cnt          <= 0;
    elsif rising_edge(clk) then

      tdata_error_i <= '0';
      tlast_error_i <= '0';

      -- Generate a tready enable with the configured probability
      s_tready_i <= '0';
      if tready_rand.RandReal(1.0) <= tready_probability then
        s_tready_i <= '1';
      end if;

      if axi_data_valid = '1' then
        word_cnt <= word_cnt + 1;
        if s_tlast = '1' then
          word_cnt  <= 0;
          frame_cnt <= frame_cnt + 1;
        end if;
      end if;

      -- Count errors
      if axi_data_valid = '1' then
        if s_tdata /= expected_tdata_i then
          tdata_error_i     <= '1';
          error_cnt_i       <= error_cnt_i + 1;
          tdata_error_cnt_i <= tdata_error_cnt_i + 1;

          warning(
            sformat(
              "TDATA error in frame %d, word %d: Expected %r but got %r",
              fo(frame_cnt), fo(word_cnt), fo(expected_tdata_i), fo(s_tdata)));

            -- severity REPORT_SEVERITY;
        end if;

        if s_tlast /= expected_tlast_i then
          tlast_error_i     <= '1';
          error_cnt_i       <= error_cnt_i + 1;
          tlast_error_cnt_i <= tlast_error_cnt_i + 1;

          warning(
            sformat(
              "TLAST error in frame %d, word %d: Expected %r but got %r",
              fo(frame_cnt), fo(word_cnt), fo(to_boolean(expected_tlast_i)), fo(to_boolean(s_tlast))));
        end if;

      end if;
    end if;
  end process;

end axi_file_compare;
