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
---------------
-- Libraries --
---------------
use std.textio.all;

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
entity axi_file_compare_complex is
  generic (
    READER_NAME         : string;
    DATA_WIDTH          : integer := 1;
    TOLERANCE           : natural := 0;
    SWAP_BYTE_ENDIANESS : boolean := False;
    ERROR_CNT_WIDTH     : natural := 8;
    REPORT_SEVERITY     : severity_level := Error;
    DUMP_FILE_FORMAT    : string := "");  -- Leave empty to disable
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
end axi_file_compare_complex;

architecture axi_file_compare_complex of axi_file_compare_complex is

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

  signal dbg_error         : complex;

  signal dbg_recv_re       : signed(DATA_WIDTH/2 - 1 downto 0) := (others => '0');
  signal dbg_recv_im       : signed(DATA_WIDTH/2 - 1 downto 0) := (others => '0');

  signal dbg_expected_re   : signed(DATA_WIDTH/2 - 1 downto 0) := (others => '0');
  signal dbg_expected_im   : signed(DATA_WIDTH/2 - 1 downto 0) := (others => '0');

  signal dbg_error_re      : signed(DATA_WIDTH/2 - 1 downto 0) := (others => '0');
  signal dbg_error_im      : signed(DATA_WIDTH/2 - 1 downto 0) := (others => '0');
  signal dbg_error_re_max  : signed(DATA_WIDTH/2 - 1 downto 0) := (others => '0');
  signal dbg_error_im_max  : signed(DATA_WIDTH/2 - 1 downto 0) := (others => '0');
  signal dbg_acc_error     : complex := (re => 0.0, im => 0.0);

  -- Handle opening, closing and keeping track of indexes for multiple files
  type dump_file_t is protected
    procedure write ( constant v : complex );
    procedure close;
  end protected;

  type dump_file_t is protected body
    constant logger    : logger_t := get_logger("dump_file_t");
    variable index     : integer := 0;
    variable file_name : line := null;

    file file_handler  : text;

    procedure init is
    begin
      assert file_name = null
        report sformat("Can't initialize dump file, filename is '%s'", file_name.all)
        severity Failure;

      -- Apply the index to the file format
      write(file_name, sformat(DUMP_FILE_FORMAT, fo(index)));
      index := index + 1;

      debug(logger, sformat("Opening file '%s'", file_name.all));

      file_open(file_handler, file_name.all, write_mode);
    end;

    procedure write ( constant v : complex ) is
      variable L : line;
    begin
      if DUMP_FILE_FORMAT = "" then
        return;
      end if;
      -- Initialize if that's not done yet
      if file_name = null then
        init;
      end if;
      write(L, real'image(v.re) & ",");
      write(L, real'image(v.im));
      writeline(file_handler, L);
      deallocate(L);
    end procedure;

    procedure close is
    begin
      if file_name = null then
        return;
      end if;
      debug(logger, sformat("Closing '%s'", file_name.all));
      file_close(file_handler);
      deallocate(file_name);
      file_name := null;
    end;

  end protected body;

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

    variable outfile : dump_file_t;

    procedure check_within_tolerance (
      constant v            : std_logic_vector;
      constant ref          : std_logic_vector) is
      constant v_re         : signed(DATA_WIDTH/2 - 1 downto 0) := signed(v(DATA_WIDTH - 1 downto DATA_WIDTH/2));
      constant v_im         : signed(DATA_WIDTH/2 - 1 downto 0) := signed(v(DATA_WIDTH/2 - 1 downto 0));
      constant v_rect       : complex                           := to_complex(v);
      constant ref_rect     : complex                           := to_complex(ref);
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

      outfile.write(v_rect);

      -- Now we know signs match, so we can check if v is within the set tolerance
      if v_re /= ref_re and (v_re < minimum(ref_re_range) or v_re > max(ref_re_range)) then
        failed := True;
      end if;

      if v_im /= ref_im and (v_im < minimum(ref_im_range) or v_im > max(ref_im_range)) then
        failed := True;
      end if;

      dbg_error     <= v_rect - ref_rect;
      dbg_error_re  <= v_re - ref_re;
      dbg_error_im  <= v_im - ref_im;

      if abs(v_re - ref_re) > dbg_error_re_max then
        dbg_error_re_max <= abs(v_re - ref_re);
      end if;

      if abs(v_im - ref_im) > dbg_error_im_max then
        dbg_error_im_max <= abs(v_im - ref_im);
      end if;

      dbg_acc_error <= dbg_acc_error + v_rect - ref_rect;

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

      if has_undefined(s_tdata) then
        failure(sformat("Input data has undefined values: %r (%b)", fo(s_tdata), fo(s_tdata)));
      end if;

      dbg_recv_re     <= signed(s_tdata(DATA_WIDTH - 1 downto DATA_WIDTH/2));
      dbg_recv_im     <= signed(s_tdata(DATA_WIDTH/2 - 1 downto 0));
      dbg_expected_re <= signed(expected_tdata_i(DATA_WIDTH - 1 downto DATA_WIDTH/2));
      dbg_expected_im <= signed(expected_tdata_i(DATA_WIDTH/2 - 1 downto 0));

      check_within_tolerance(s_tdata, expected_tdata_i);

      if s_tlast = '1' then
        outfile.close;
      end if;

      if s_tlast /= m_tlast then
        notify(
          sformat(
            "TLAST error in frame %d, word %d: Expected %r but got %r",
            fo(frame_cnt),
            fo(word_cnt),
            std_logic'image(m_tlast),
            std_logic'image(s_tlast)
          )
        );
        tlast_error_cnt_i <= tlast_error_cnt_i + 1;
      end if;

      if s_tlast = '1' then
        dbg_acc_error <= (re => 0.0, im => 0.0);
        dbg_error_re_max <= (others => '0');
        dbg_error_im_max <= (others => '0');
        info(logger, sformat("Received frame %d with %d words", fo(frame_cnt), fo(word_cnt)));
        word_cnt  := 0;
        frame_cnt := frame_cnt + 1;
      end if;

      word_cnt := word_cnt + 1;
    end loop;
  end process; -- }} -------------------------------------------------------------------

end axi_file_compare_complex;
