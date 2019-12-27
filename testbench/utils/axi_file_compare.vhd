--
-- DVB FPGA
--
-- Copyright 2019 by Andre Souto (suoto)
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

library vunit_lib;
    context vunit_lib.vunit_context;

library osvvm;
    use osvvm.RandomPkg.all;

library str_format;
    use str_format.str_format_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_file_compare is
  generic (
    ERROR_CNT_WIDTH : natural := 8;
    -- axi_file_reader config
    DATA_WIDTH     : positive := 1;
    -- GNU Radio does not have bit format, so most blocks use 1 bit per byte. Set this to
    -- True to use the LSB to form a data word
    BYTES_ARE_BITS : boolean := False;
    -- Repeat the frame whenever reaching EOF
    REPEAT_CNT     : natural := 1);
  port (
    -- Usual ports
    clk                : in  std_logic;
    rst                : in  std_logic;
    -- Config and status
    file_name          : string;
    tdata_error_cnt    : out std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
    tlast_error_cnt    : out std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
    error_cnt          : out std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
    tready_probability : in real range 0.0 to 1.0 := 1.0;
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
  signal start             : std_logic;
  signal completed         : std_logic;
  signal s_tready_i        : std_logic;
  signal axi_data_valid    : std_logic;

  signal tdata_error_i     : std_logic;
  signal tdata_error_cnt_i : unsigned(ERROR_CNT_WIDTH - 1 downto 0);

  signal tlast_error_i     : std_logic;
  signal tlast_error_cnt_i : unsigned(ERROR_CNT_WIDTH - 1 downto 0);

  signal error_cnt_i       : unsigned(ERROR_CNT_WIDTH - 1 downto 0);

  signal expected_tdata    : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal expected_tvalid   : std_logic;
  signal expected_tlast    : std_logic;

begin

  -------------------
  -- Port mappings --
  -------------------
  axi_file_reader_u : entity work.axi_file_reader
  generic map (
    DATA_WIDTH     => DATA_WIDTH,
    BYTES_ARE_BITS => BYTES_ARE_BITS,
    REPEAT_CNT     => REPEAT_CNT)
  port map (
    -- Usual ports
    clk                => clk,
    rst                => rst,
    -- Config and status
    file_name          => file_name,
    start              => '1',
    completed          => completed,
    tvalid_probability => 1.0,
    
    -- Data output
    m_tready           => axi_data_valid,
    m_tdata            => expected_tdata,
    m_tvalid           => expected_tvalid,
    m_tlast            => expected_tlast);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  error_cnt       <= std_logic_vector(error_cnt_i);
  tdata_error_cnt <= std_logic_vector(tdata_error_cnt_i);
  tlast_error_cnt <= std_logic_vector(tlast_error_cnt_i);

  s_tready       <= s_tready_i when expected_tvalid = '1' else '0';
  axi_data_valid <= '1' when s_tready_i = '1' and s_tvalid = '1' and expected_tvalid = '1'
                    else '0';

  tdata_error_i <= '1' when axi_data_valid = '1' and s_tdata /= expected_tdata else '0';
  tlast_error_i <= '1' when axi_data_valid = '1' and s_tlast /= expected_tlast else '0';

  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
    variable tready_rand : RandomPType;
  begin
    if rst = '1' then
      start      <= '1';
      s_tready_i <= '0';

      tdata_error_cnt_i <= (others => '0');
      tlast_error_cnt_i <= (others => '0');
      error_cnt_i       <= (others => '0');
    elsif rising_edge(clk) then

      if axi_data_valid then
        start <= '0';
      end if;

      -- Generate a tready enable with the configured probability
      s_tready_i <= '0';
      if tready_rand.RandReal(1.0) <= tready_probability then
        s_tready_i <= '1';
      end if;

      -- Count errors
      if tdata_error_i = '1' or tlast_error_i = '1' then
        error_cnt_i <= error_cnt_i + 1;

        if tdata_error_i = '1' then
          tdata_error_cnt_i <= tdata_error_cnt_i + 1;
        end if;

        if tlast_error_i = '1' then
          tlast_error_cnt_i <= tlast_error_cnt_i + 1;
        end if;

      end if;
    end if;
  end process;

end axi_file_compare;
