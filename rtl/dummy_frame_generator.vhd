-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
--
-- DVB FPGA
--
-- Copyright 2019-2022 by suoto <andre820@gmail.com>
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
use ieee.math_real.MATH_PI;
use ieee.math_real.MATH_SQRT_2;

library fpga_cores;
use fpga_cores.common_pkg.all;

use work.dvb_utils_pkg.all;
use work.plframe_header_pkg.all;
------------------------
-- Entity declaration --
------------------------
entity dummy_frame_generator is
  generic ( TDATA_WIDTH : natural := 32 );
  port (
    -- Usual ports
    clk            : in  std_logic;
    rst            : in  std_logic;
    -- Pulse to trigger generating a dummy frame
    generate_frame : in  std_logic;
    -- AXI output
    m_tready       : in  std_logic;
    m_tvalid       : out std_logic;
    m_tlast        : out std_logic;
    m_tdata        : out std_logic_vector(TDATA_WIDTH - 1 downto 0));
end dummy_frame_generator;

architecture dummy_frame_generator of dummy_frame_generator is

  ---------------
  -- Constants --
  ---------------
  constant MOD_8PSK_MAP : std_logic_array_t(0 to 7)(TDATA_WIDTH - 1 downto 0) := (
    0 => std_logic_vector(cos(      MATH_PI / 4.0, TDATA_WIDTH/2) & sin(      MATH_PI / 4.0, TDATA_WIDTH/2)),
    1 => std_logic_vector(cos(5.0 * MATH_PI / 4.0, TDATA_WIDTH/2) & sin(5.0 * MATH_PI / 4.0, TDATA_WIDTH/2)),
    2 => std_logic_vector(cos(5.0 * MATH_PI / 4.0, TDATA_WIDTH/2) & sin(      MATH_PI / 4.0, TDATA_WIDTH/2)),
    3 => std_logic_vector(cos(      MATH_PI / 4.0, TDATA_WIDTH/2) & sin(5.0 * MATH_PI / 4.0, TDATA_WIDTH/2)),
    4 => std_logic_vector(cos(5.0 * MATH_PI / 4.0, TDATA_WIDTH/2) & sin(      MATH_PI / 4.0, TDATA_WIDTH/2)),
    5 => std_logic_vector(cos(      MATH_PI / 4.0, TDATA_WIDTH/2) & sin(5.0 * MATH_PI / 4.0, TDATA_WIDTH/2)),
    6 => std_logic_vector(cos(5.0 * MATH_PI / 4.0, TDATA_WIDTH/2) & sin(5.0 * MATH_PI / 4.0, TDATA_WIDTH/2)),
    7 => std_logic_vector(cos(      MATH_PI / 4.0, TDATA_WIDTH/2) & sin(      MATH_PI / 4.0, TDATA_WIDTH/2))
  );

  function get_encoded_header return std_logic_array_t is
    constant HEADER   : std_logic_vector := SOF & DUMMY_FRAME_PLS_CODE;
    variable result   : std_logic_array_t(0 to HEADER'length - 1)(TDATA_WIDTH - 1 downto 0);
    variable map_addr : integer;
  begin
    for i in HEADER'length - 1 downto 0 loop
      map_addr  := 2*(i mod 2) + to_integer(unsigned'((0 to 0 => HEADER(i))));
      result(i) := MOD_8PSK_MAP(map_addr);
    end loop;
    return result;
  end function;

  constant ENCODED_HEADER_ROM : std_logic_array_t := get_encoded_header;
  -- Payload length as defined in 5.5.1
  constant PAYLOAD_LENGTH     : integer := 36*90;
  constant DUMMY_FRAME_LENGTH : integer := ENCODED_HEADER_ROM'length + PAYLOAD_LENGTH;
  constant PAYLOAD_DATA       : std_logic_vector(TDATA_WIDTH - 1 downto 0) := std_logic_vector(
    to_signed_fixed_point(1.0 / MATH_SQRT_2, TDATA_WIDTH/2) &
    to_signed_fixed_point(1.0 / MATH_SQRT_2, TDATA_WIDTH/2)
  );

  -------------
  -- Signals --
  -------------
  signal tvalid_0   : std_logic;
  signal tvalid_1   : std_logic;
  signal tlast_0    : std_logic;
  signal tlast_1    : std_logic;
  signal word_count : unsigned(numbits(DUMMY_FRAME_LENGTH) - 1 downto 0);
  signal is_header  : std_logic;
  signal rom_addr   : unsigned(numbits(ENCODED_HEADER_ROM'length) - 1 downto 0);
  signal rom_data   : std_logic_vector(TDATA_WIDTH - 1 downto 0);

begin

  -------------------
  -- Port mappings --
  -------------------
  header_rom_u : entity fpga_cores.rom_inference
  generic map (
    ROM_DATA     => ENCODED_HEADER_ROM,
    ROM_TYPE     => auto,
    OUTPUT_DELAY => 1)
  port map (
    clk    => clk,
    clken  => '1',
    addr   => std_logic_vector(rom_addr),
    rddata => rom_data);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  m_tvalid   <= tvalid_1;
  m_tlast    <= tlast_1 and tvalid_1;
  tlast_0  <= '1' when word_count = DUMMY_FRAME_LENGTH - 1 else '0';

  m_tdata  <= (others => 'U') when tvalid_1 = '0' else
              (rom_data and (TDATA_WIDTH - 1 downto 0 => is_header)) or
              (PAYLOAD_DATA and (TDATA_WIDTH - 1 downto 0 => not is_header));

  -- Keep ROM addr constant when not reading from it to reduce power
  rom_addr <= word_count(numbits(ENCODED_HEADER_ROM'length) - 1 downto 0) when is_header else
              (others => '0');

  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
  begin
    if rst = '1' then
      word_count <= (others => '1');
      tvalid_0   <= '0';
      tvalid_1   <= 'U';
      tlast_1    <= 'U';
      is_header  <= 'U';
    elsif clk'event and clk = '1' then
      tvalid_1 <= tvalid_0;
      tlast_1  <= tlast_0;

      -- Only reload the counter when not already sending a frame
      if generate_frame and (not tvalid_0 or (tvalid_0 and m_tready and tlast_0))then
        word_count <= (others => '0');
        tvalid_0   <= '1';
      end if;

      if tvalid_0 = '1' and m_tready = '1' then
        word_count <= word_count + 1;
        if word_count = DUMMY_FRAME_LENGTH - 1 then
          word_count <= (others => '0');
          tvalid_0   <= '0';
        end if;
      end if;

      is_header <= '0';
      if word_count < ENCODED_HEADER_ROM'length then
        is_header <= '1';
      end if;

    end if;
  end process;

end dummy_frame_generator;
