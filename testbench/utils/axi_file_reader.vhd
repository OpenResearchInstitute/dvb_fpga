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

use work.common_pkg.all;
use work.file_utils_pkg.all;
use work.testbench_utils_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_file_reader is
  generic (
    READER_NAME : string;
    DATA_WIDTH  : integer  := 1);
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
  signal dbg_word_cnt   : integer := 0;

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
    variable cfg          : file_reader_cfg_t;
    variable ratio        : ratio_t := (DATA_WIDTH, DATA_WIDTH);
    --
    constant self         : actor_t := new_actor(READER_NAME);
    constant logger       : logger_t := get_logger(READER_NAME);
    variable msg          : msg_t;

    variable tvalid_rand  : RandomPType;
    variable word_cnt     : integer := 0;
    -- Need to read a word in advance to detect the end of file in time to generate tlast
    variable m_tdata_next : std_logic_vector(DATA_WIDTH - 1 downto 0);

    --
    type file_status_t is (opened, closed, unknown);
    variable file_status         : file_status_t := unknown;
    --
    type file_type is file of character;
    file file_handler : file_type;

    type std_logic_vector_ptr_t is access std_logic_vector;
    variable bytes_read     : integer := 0;

    variable ratio_buff_cnt : integer := 0;
    variable ratio_buff     : std_logic_vector_ptr_t;

    variable buffer_bit_cnt : natural := 0;
    variable data_buffer    : std_logic_vector(max(2*DATA_WIDTH, 8) - 1 downto 0);

    ------------------------------------------------------------------------------------
    impure function read_word_from_file return std_logic_vector is
      variable char       : character;
      variable byte       : std_logic_vector(7 downto 0);
      variable buff_local : std_logic_vector(ratio_buff'range);
      variable result     : std_logic_vector(ratio.first - 1 downto 0);
      variable unused     : std_logic_vector(ratio.second - ratio.first - 1 downto 0);
    begin

      buff_local := ratio_buff.all;
      deallocate(ratio_buff);

      -- Need to read bytes to decode them properly, make sure we have enough first
      while ratio_buff_cnt < ratio.second loop
        read(file_handler, char);
        byte           := std_logic_vector(to_unsigned(character'pos(char), 8));
        bytes_read     := bytes_read + 1;

        buff_local     := buff_local(buff_local'length - byte'length - 1 downto 0) & byte;
        ratio_buff_cnt := ratio_buff_cnt + 8;

        -- trace(
        --   logger,
        --   sformat(
        --     "ratio = %s || bytes read=%d || ratio_buff_cnt=%d || byte=%r | buffer=%r || %b",
        --     fo(ratio),
        --     fo(bytes_read),
        --     fo(ratio_buff_cnt),
        --     fo(byte),
        --     fo(buff_local),
        --     fo(buff_local)));

      end loop;

      -- Bits we're interested in are on the MSB at this point
      result := buff_local(buff_local'length - ratio.second + ratio.first - 1 downto buff_local'length - ratio.second);
      unused := buff_local(buff_local'length - 1 downto buff_local'length - ratio.second + ratio.first);

      -- Remove the bits we're going to return from the buffer
      buff_local     := buff_local(buff_local'length - ratio.second - 1 downto 0) & (ratio.second - 1 downto 0 => 'U');
      ratio_buff     := new std_logic_vector'(buff_local);
      ratio_buff_cnt := ratio_buff_cnt - ratio.second;

      -- Sanity check
      if unused /= (unused'range => '0') then
        warning(sformat("Unused bits should be 0, got %b", fo(unused)));
      end if;

      -- debug(
      --   logger,
      --   sformat("%2d => %2d || buff_local = %r || %b || result = %r",
      --     fo(ratio_buff_cnt + ratio.second),
      --     fo(ratio_buff_cnt),
      --     fo(ratio_buff.all),
      --     fo(ratio_buff.all),
      --     fo(result)));

      return result;

    end function read_word_from_file;

    ------------------------------------------------------------------------------------
    impure function get_next_data (constant word_width : in natural)
    return std_logic_vector is
      variable result : std_logic_vector(word_width - 1 downto 0);
      variable word   : std_logic_vector(ratio.first - 1 downto 0);
    begin
      while buffer_bit_cnt < word_width loop
        word           := read_word_from_file;
        buffer_bit_cnt := buffer_bit_cnt + ratio.first;

        data_buffer  := data_buffer(data_buffer'length - ratio.first - 1 downto 0)
          & word(ratio.first - 1 downto 0);

        -- trace(
        --   logger,
        --   sformat(
        --    "buffer_bit_cnt=%2d | word=%r | data_buffer=%r || %b",
        --     fo(buffer_bit_cnt),
        --     fo(word),
        --     fo(data_buffer),
        --     fo(data_buffer)));

      end loop;

      -- Result is going to be the MSB of the valid section
      result := data_buffer(buffer_bit_cnt - 1 downto buffer_bit_cnt - data_width);

      -- Remove the result from the bit counter and buffer. Assign U's to the
      -- bit buffer so that we don't get accidently valid outputs when
      -- something goes wrong
      data_buffer(buffer_bit_cnt - 1 downto buffer_bit_cnt - data_width) := (others => 'U');
      buffer_bit_cnt := buffer_bit_cnt - word_width;

      -- info(sformat("result = %r", fo(result)));
      return result;

    end function get_next_data;
    ------------------------------------------------------------------------------------
    procedure reply_with_size is
      variable reply_msg : msg_t := new_msg;
    begin
      push_integer(reply_msg, word_cnt);
      reply_msg.sender := self;
      reply(net, msg, reply_msg);
    end procedure reply_with_size;

  begin

    if rst = '1' then
      m_tvalid_wr <= '0';
      m_tlast_i   <= '0';
      m_tdata     <= (others => 'U');
      completed   <= '0';
      -- bit_list.reset;
      if file_status /= closed then
          file_status := closed;
          file_close(file_handler);
      end if;
    else

      -- Clear out AXI stuff when data has been transferred only
      if axi_data_valid then
        completed   <= '0';
        m_tvalid_wr <= '0';
        m_tlast_i   <= '0';
        m_tdata     <= (others => 'U');
        word_cnt    := word_cnt + 1;
        dbg_word_cnt <= dbg_word_cnt + 1;

        if m_tlast_i = '1' then
          file_close(file_handler);
          file_status  := closed;

          info(
            logger,
            sformat("Read %d words from %s", fo(word_cnt), quote(cfg.filename.all)));

          completed      <= '1';
          dbg_word_cnt   <= 0;
          word_cnt       := 0;
          buffer_bit_cnt := 0;
        end if;
      end if;

      -- If the file hasn't been opened, wait we get a msg with the file name
      if file_status /= opened  then
        if has_message(self) then
          receive(net, self, msg);
          cfg   := pop(msg);
          ratio := cfg.ratio;

          deallocate(ratio_buff);
          bytes_read     := 0;
          ratio_buff_cnt := 0;

          -- Avoid bit banging too much if everything is valid
          if ratio.first = ratio.second then
            ratio      := (DATA_WIDTH, DATA_WIDTH);
            ratio_buff := new std_logic_vector(max(DATA_WIDTH, 8) - 1 downto 0);
          else
            ratio_buff := new std_logic_vector(max(ratio.second, 8) - 1 downto 0);
          end if;

          info(
            logger,
            sformat(
              "Reading %s. Data ratio is %d:%d (requested by %s)", quote(cfg.filename.all),
              fo(cfg.ratio.first), fo(cfg.ratio.second),
              quote(name(msg.sender))));

          file_open(file_handler, cfg.filename.all, read_mode);
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
          -- Only assert tlast when the file has been completely read and all data
          -- buffered has been read
          if endfile(file_handler) and buffer_bit_cnt = 0 and ratio_buff_cnt = 0 then
            m_tlast_i    <= '1';
            reply_with_size;
          end if;
        end if;
      end if;

      -- Generate a tvalid enable with the configured probability
      m_tvalid_en <= '0';
      if tvalid_rand.RandReal(1.0) <= tvalid_probability then
        m_tvalid_en <= '1';
      end if;
    end if;

    wait until rising_edge(clk);

  end process;

end axi_file_reader;
