-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
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

---------------
-- Libraries --
---------------
library ieee;
use ieee.math_complex.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library osvvm;
use osvvm.RandomPkg.all;

library vunit_lib;
context vunit_lib.vunit_context;

library str_format;
use str_format.str_format_pkg.all;

library fpga_cores;
use fpga_cores.common_pkg.all;
library fpga_cores_sim;

use work.dvb_sim_utils_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_file_compare_tolerance is
  generic (
    READER_NAME         : string;
    DATA_WIDTH          : integer := 1;
    TOLERANCE           : natural := 0;
    SWAP_BYTE_ENDIANESS : boolean := False;
    ERROR_CNT_WIDTH     : natural := 8;
    REPORT_SEVERITY     : severity_level := Error);
  port (
    -- Usual ports
    clk                : in  std_logic;
    rst                : in  std_logic;
    -- Config and status
    tdata_error_cnt    : out std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
    tlast_error_cnt    : out std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
    error_cnt          : out std_logic_vector(ERROR_CNT_WIDTH - 1 downto 0);
    -- Debug stuff
    expected_tdata     : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    expected_tlast     : out std_logic;
    -- Data input
    s_tready           : in  std_logic;
    s_tdata            : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    s_tvalid           : in  std_logic;
    s_tlast            : in  std_logic);
end axi_file_compare_tolerance;

architecture axi_file_compare_tolerance of axi_file_compare_tolerance is

  -------------
  -- Signals --
  -------------
  signal m_tvalid          : std_logic;
  signal m_tlast           : std_logic;
  signal m_tdata           : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal expected_tdata_i  : std_logic_vector(DATA_WIDTH - 1 downto 0);

  signal axi_data_valid    : std_logic;

  signal tdata_error_cnt_i : unsigned(ERROR_CNT_WIDTH - 1 downto 0);
  signal tlast_error_cnt_i : unsigned(ERROR_CNT_WIDTH - 1 downto 0);

begin

  -------------------
  -- Port mappings --
  -------------------
  file_reader_u : entity fpga_cores_sim.axi_file_reader
    generic map (
      READER_NAME => READER_NAME,
      DATA_WIDTH  => DATA_WIDTH)
    port map (
      -- Usual ports
      clk                => clk,
      rst                => rst,
      -- Config and status
      tvalid_probability => 1.0,
      completed          => open,
      -- Data output
      m_tready           => axi_data_valid,
      m_tvalid           => m_tvalid,
      m_tdata            => m_tdata,
      m_tlast            => m_tlast);

  g_swap : if SWAP_BYTE_ENDIANESS generate
    expected_tdata_i <= mirror_bytes(m_tdata(DATA_WIDTH - 1 downto DATA_WIDTH/2)) &
                        mirror_bytes(m_tdata(DATA_WIDTH/2 - 1 downto 0));
  end generate;

  g_no_swap : if not SWAP_BYTE_ENDIANESS generate
    expected_tdata_i <= m_tdata;
  end generate;

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  axi_data_valid <= '1' when s_tready = '1' and s_tvalid = '1' and m_tvalid = '1'
                    else '0';


  expected_tdata <= expected_tdata_i;
  expected_tlast <= m_tlast;

  tdata_error_cnt <= std_logic_vector(tdata_error_cnt_i);
  tlast_error_cnt <= std_logic_vector(tlast_error_cnt_i);
  error_cnt       <= std_logic_vector(tdata_error_cnt_i + tlast_error_cnt_i);

  ---------------
  -- Processes --
  ---------------
  process -- {{ -----------------------------------------------------------
    constant logger      : logger_t := get_logger(READER_NAME);
    variable word_cnt    : natural  := 0;
    variable frame_cnt   : natural  := 0;

    variable recv_r      : complex;
    variable expected_r  : complex;
    variable recv_p      : complex_polar;
    variable expected_p  : complex_polar;
    variable expected_re : signed(DATA_WIDTH/2 - 1 downto 0);
    variable expected_im : signed(DATA_WIDTH/2 - 1 downto 0);

    procedure notify ( constant s : string ) is
    begin
      case REPORT_SEVERITY is
        when note    => info(logger, s);
        when warning => warning(logger, s);
        when error   => error(logger, s);
        when failure => failure(logger, s);
      end case;
    end procedure;

    function str ( constant v : complex ) return string is
    begin
        return "(" & real'image(v.re) & ", " & real'image(v.im) & ")";
    end function;

    function str ( constant v : complex_polar ) return string is
    begin
        return "(" & real'image(v.mag) & ", " & real'image(v.arg) & ")";
    end function;

    procedure check_within_tolerance (
      constant v            : std_logic_vector;
      constant ref          : std_logic_vector) is
      constant v_rect       : complex                           := to_complex(v);
      constant ref_rect     : complex                           := to_complex(ref);
      constant v_re         : signed(DATA_WIDTH/2 - 1 downto 0) := signed(v(DATA_WIDTH - 1 downto DATA_WIDTH/2));
      constant v_im         : signed(DATA_WIDTH/2 - 1 downto 0) := signed(v(DATA_WIDTH/2 - 1 downto 0));
      variable ref_re       : integer;
      variable ref_im       : integer;
      variable ref_re_range : fpga_cores.common_pkg.integer_vector_t(0 to 1);
      variable ref_im_range : fpga_cores.common_pkg.integer_vector_t(0 to 1);
      variable error_pct    : integer;
      variable failed       : boolean := False;
    begin
      ref_re       := to_integer(signed(ref(DATA_WIDTH - 1 downto DATA_WIDTH/2)));
      ref_im       := to_integer(signed(ref(DATA_WIDTH/2 - 1 downto 0)));
      ref_re_range := ( ref_re - TOLERANCE, ref_re + TOLERANCE);
      ref_im_range := ( ref_im - TOLERANCE, ref_im + TOLERANCE);

      -- Now we know signs match, so we can check if v is within the set tolerance
      if v_re /= ref_re and (v_re < minimum(ref_re_range) or v_re > max(ref_re_range)) then
        failed := True;
      end if;

      if v_im /= ref_im and (v_im < minimum(ref_im_range) or v_im > max(ref_im_range)) then
        failed := True;
      end if;

      if failed then
        tdata_error_cnt_i <= tdata_error_cnt_i + 1;

        error_pct := max(
          integer(100.0*((ref_rect.re - v_rect.re) / ref_rect.re)),
          integer(100.0*((ref_rect.im - v_rect.im) / ref_rect.im))
        );

        notify(
          sformat(
            "[%d, %d] Comparison failed. " & lf &
            "Got:      %r %r (%d, %d), delta (%d, %d)" & lf &
            "Expected: %r %r (%d, %d)" & lf &
            "Tolerance range: re=(%d, %d), im=(%d, %d). Error=%d\%",
            fo(frame_cnt),
            fo(word_cnt),
            fo(v(DATA_WIDTH - 1 downto DATA_WIDTH/2)),
            fo(v(DATA_WIDTH/2 - 1 downto 0)),
            fo(to_integer(signed(v(DATA_WIDTH - 1 downto DATA_WIDTH/2)))),
            fo(to_integer(signed(v(DATA_WIDTH/2 - 1 downto 0)))),
            fo(ref_re - v_re),
            fo(ref_im - v_im),
            fo(ref(DATA_WIDTH - 1 downto DATA_WIDTH/2)),
            fo(ref(DATA_WIDTH/2 - 1 downto 0)),
            fo(to_integer(signed(ref(DATA_WIDTH - 1 downto DATA_WIDTH/2)))),
            fo(to_integer(signed(ref(DATA_WIDTH/2 - 1 downto 0)))),
            fo(minimum(ref_re_range)), fo(max(ref_re_range)),
            fo(minimum(ref_im_range)), fo(max(ref_im_range)),
            fo(error_pct)
          ));
      end if;
    end procedure;

  begin
    tdata_error_cnt_i <= (others => '0');
    tlast_error_cnt_i <= (others => '0');

    wait until rst = '0';
    while True loop
      wait until axi_data_valid = '1' and rising_edge(clk);
      check_within_tolerance(s_tdata, expected_tdata_i);

      if s_tlast /= m_tlast then
        notify(
          sformat(
            "TLAST error in frame %d, word %d: Expected %r but got %r",
            fo(frame_cnt),
            fo(word_cnt),
            fo(to_boolean(m_tlast)),
            fo(to_boolean(s_tlast))
          )
        );
      tlast_error_cnt_i <= tlast_error_cnt_i + 1;
      end if;

      word_cnt := word_cnt + 1;
      if s_tlast = '1' then
        info(logger, sformat("Received frame %d with %d words", fo(frame_cnt), fo(word_cnt)));
        word_cnt  := 0;
        frame_cnt := frame_cnt + 1;
      end if;
    end loop;
  end process; -- }} -------------------------------------------------------------------

end axi_file_compare_tolerance;
