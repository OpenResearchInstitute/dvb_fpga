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

-- use std.textio.all;

library vunit_lib;
    context vunit_lib.vunit_context;

library osvvm;
    use osvvm.RandomPkg.all;

library str_format;
    use str_format.str_format_pkg.all;


------------------------
-- Entity declaration --
------------------------
entity axi_file_reader is
  generic (
    FILE_NAME      : string;
    DATA_WIDTH     : integer  := 1;
    -- GNU Radio does not have bit format, so most blocks use 1 bit per byte. Set this to
    -- True to use the LSB to form a data word
    BYTES_ARE_BITS : boolean := False;
    -- Repeat the frame whenever reaching EOF
    REPEAT_CNT     : positive := 1);
  port (
    -- Usual ports
    clk                : in  std_logic;
    rst                : in  std_logic;
    -- Config and status
    start              : in  std_logic;
    completed          : out std_logic;
    tvalid_probability : in real range 0.0 to 1.0 := 1.0;
    
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
  signal m_tvalid_i      : std_logic;
  signal m_tvalid_wr     : std_logic;
  signal m_tvalid_en     : std_logic := '0';
  signal m_tlast_i       : std_logic;
  signal axi_data_valid  : boolean;

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
    variable word_cnt : integer;

    -- 
    type file_type is file of character;
    file file_handler : file_type;
    variable char     : character;
    variable byte_cnt : integer := 0;
    variable data     : std_logic_vector(2*DATA_WIDTH - 1 downto 0);

    --
    impure function read_word_from_file (constant word_width : in natural) return std_logic_vector is
      variable result : std_logic_vector(word_width - 1 downto 0);
      variable byte : std_logic_vector(7 downto 0);
    begin
      -- debug(sformat("Reading %d bits", fo(word_width)));

      while byte_cnt < word_width loop
        read(file_handler, char);

        byte     := std_logic_vector(to_unsigned(character'pos(char), 8));
        -- debug(sformat("byte_cnt = %d, byte = %r", fo(byte_cnt), fo(byte)));

        byte_cnt := byte_cnt + byte'length;

        data     := data(data'length - 8 - 1 downto 0) & byte;
      end loop;

      byte_cnt := byte_cnt mod word_width;
      result   := data(word_width - 1 downto 0);

      return result;
    end function read_word_from_file;
    
    impure function get_next_data (constant word_width : in natural) return std_logic_vector is
      variable result : std_logic_vector(word_width - 1 downto 0);
    begin
      if BYTES_ARE_BITS then
        for i in 0 to word_width - 1 loop
          result(word_width - i - 1) := read_word_from_file(8)(0);
        end loop;
      else
        result := read_word_from_file(word_width);
      end if;

      -- info(sformat("(%d) Result: %r", fo(byte_cnt), fo(result)));

      return result;

    end function get_next_data;

    -- 
    ----------------------------
    procedure read_file is
      variable next_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
    begin

      byte_cnt := 0;

      m_tvalid_wr   <= '0';
      m_tlast_i     <= '0';
      word_cnt      := 0;

      if start /= '1' then
        wait until start = '1' and rising_edge(clk);
      end if;

      file_open(file_handler, FILE_NAME, read_mode);
      next_data     := get_next_data(DATA_WIDTH);

      while True loop
        m_tvalid_wr <= '1';
        m_tdata     <= next_data;
        -- Assert tlast at the end of the file
        if endfile(file_handler) then
          m_tlast_i <= '1';
        end if;

        wait until axi_data_valid and rising_edge(clk);

        word_cnt    := word_cnt + 1;
        m_tlast_i   <= '0';
        m_tvalid_wr <= '0';
        m_tdata     <= (others => 'U');

        if not endfile(file_handler) then
          next_data   := get_next_data(DATA_WIDTH);
        else
          next_data := (others => 'U');
        end if;

        if m_tlast_i = '1' then
          exit;
        end if;

      end loop;

      file_close(file_handler);

    end procedure read_file;
  -------------------------

  begin

    info("Filename: " & FILE_NAME);

    while True loop
      wait until rst = '0' and rising_edge(clk);
      completed <= '0';
      for i in 0 to REPEAT_CNT - 1 loop
        read_file;
        info("Done reading " & FILE_NAME);
        m_tvalid_wr <= '0';
        m_tlast_i   <= '0';
      end loop;

      completed <= '1';

      wait until rising_edge(clk);

    end loop;

    -- wait;
  end process;

  -- Generate a tvalid enable with the configured probability
  m_tvalid_gen : process(clk)
    variable rand : RandomPType;
  begin
    if rising_edge(clk) then
      m_tvalid_en <= '0';
      if rand.RandReal(1.0) <= tvalid_probability then
        m_tvalid_en <= '1';
      end if;
    end if;
  end process;

end axi_file_reader;
