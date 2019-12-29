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
use std.textio.all;

library	ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

library osvvm;
use osvvm.RandomPkg.all;

library str_format;
use str_format.str_format_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_file_reader is
  generic (
    READER_NAME    : string;
    DATA_WIDTH     : integer  := 1;
    -- GNU Radio does not have bit format, so most blocks use 1 bit per byte. Set this to
    -- True to use the LSB to form a data word
    BYTES_ARE_BITS : boolean := False);
  port (
    -- Usual ports
    clk                : in  std_logic;
    rst                : in  std_logic;
    -- Config and status
    tvalid_probability : in  real range 0.0 to 1.0 := 1.0;
    completed          : out std_logic;

    -- Data output
    m_tready           : in std_logic;
    m_tdata            : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    m_tvalid           : out std_logic;
    m_tlast            : out std_logic);
end axi_file_reader;

architecture axi_file_reader of axi_file_reader is

  -----------
  -- Types --
  -----------

  -------------
  -- Signals --
  -------------
  signal m_tvalid_i     : std_logic;
  signal m_tvalid_wr    : std_logic;
  signal m_tvalid_en    : std_logic := '0';
  signal m_tlast_i      : std_logic;
  signal axi_data_valid : boolean;

begin

  -------------------
  -- Port mappings --
  -------------------

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  m_tvalid       <= m_tvalid_i;
  m_tvalid_i     <= '1' when m_tvalid_en = '1' and m_tvalid_wr = '1' else '0';

  m_tlast        <= m_tlast_i;
  axi_data_valid <= m_tvalid_i = '1' and m_tready = '1';

  ---------------
  -- Processes --
  ---------------
  process
    --
    constant self         : actor_t := new_actor(READER_NAME);
    constant logger       : logger_t := get_logger(READER_NAME);
    variable msg          : msg_t;

    variable tvalid_rand  : RandomPType;
    variable current_file : line;
    variable word_cnt     : integer := 0;
    -- Need to read a word in advance to detect the end of file in time to generate tlast
    variable m_tdata_next : std_logic_vector(DATA_WIDTH - 1 downto 0);

    --
    type file_status_type is (opened, closed, unknown);
    variable file_status : file_status_type := unknown;
    --
    type file_type is file of character;
    file file_handler : file_type;
    variable char     : character;
    variable byte_cnt : integer := 0;
    variable data     : std_logic_vector(2*DATA_WIDTH - 1 downto 0);

    ------------------------------------------------------------------------------------
    impure function read_word_from_file (constant word_width : in natural)
    return std_logic_vector is
      variable result : std_logic_vector(word_width - 1 downto 0);
      variable byte : std_logic_vector(7 downto 0);
    begin
      while byte_cnt < word_width loop
        read(file_handler, char);

        byte     := std_logic_vector(to_unsigned(character'pos(char), 8));
        byte_cnt := byte_cnt + byte'length;
        data     := data(data'length - 8 - 1 downto 0) & byte;
      end loop;

      byte_cnt := byte_cnt mod word_width;
      result   := data(word_width - 1 downto 0);

      return result;
    end function read_word_from_file;

    ------------------------------------------------------------------------------------
    impure function get_next_data (constant word_width : in natural)
    return std_logic_vector is
      variable result : std_logic_vector(word_width - 1 downto 0);
    begin
      if BYTES_ARE_BITS then
        for i in 0 to word_width - 1 loop
          result(word_width - i - 1) := read_word_from_file(8)(0);
        end loop;
      else
        result := read_word_from_file(word_width);
      end if;

      return result;

    end function get_next_data;
    ------------------------------------------------------------------------------------

  begin
    if rst = '1' then
      m_tvalid_wr <= '0';
      m_tlast_i   <= '0';
      m_tdata     <= (others => 'U');
      completed   <= '0';
      if file_status /= closed then
          file_status := closed;
          file_close(file_handler);
      end if;
    else 
    -- elsif rising_edge(clk) then

      -- Clear out AXI stuff when data has been transferred only
      if axi_data_valid then
        completed   <= '0';
        m_tvalid_wr <= '0';
        m_tlast_i   <= '0';
        m_tdata     <= (others => 'U');
        word_cnt    := word_cnt + 1;

        if m_tlast_i = '1' then
          file_close(file_handler);
          file_status  := closed;

          info(logger, "Read " & integer'image(word_cnt) & " words from " & current_file.all);
          completed <= '1';
          word_cnt  := 0;
          byte_cnt  := 0;
        end if;
      end if;

      -- If the file hasn't been opened, wait we get a msg with the file name
      if file_status /= opened  then
        if has_message(self) then
          receive(net, self, msg);
          deallocate(current_file);
          write(current_file, pop_string(msg));

          info(logger, "Reading " & current_file.all);
          file_open(file_handler, current_file.all, read_mode);
          file_status  := opened;

          m_tdata_next := get_next_data(DATA_WIDTH);
        end if;
      else
        -- If the file has been opened, read the next word whenever the previous one is
        -- valid
        if axi_data_valid then
          m_tdata_next := get_next_data(DATA_WIDTH);
        end if;
      end if;

      if file_status = opened then
        m_tvalid_wr <= '1';
        m_tdata     <= m_tdata_next;
        if axi_data_valid then
          if endfile(file_handler) then
            m_tlast_i    <= '1';
            acknowledge(net, msg, True);
          end if;
        end if;
      end if;

      -- Generate a tvalid enable with the configured probability
      m_tvalid_en <= '0';
      if tvalid_rand.RandReal(1.0) <= tvalid_probability then
        m_tvalid_en <= '1';
      end if;
    end if;
    wait until rising_edge(clk); -- or rst = '1';
  end process;

  -- process
  -- begin
  --   wait until m_tlast_i = '1';
  --   wait;
  -- end process;

end axi_file_reader;
