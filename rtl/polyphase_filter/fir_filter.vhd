--
-- DVB IP
--
-- Copyright 2019 by Suoto <andre820@gmail.com>
--
-- This source describes Open Hardware and is licensed under the CERN-OHL-W v2.
--
-- You may redistribute and modify this source and make products using it under
-- the terms of the CERN-OHL-W v2 (https:--ohwr.org/cern_ohl_w_v2.txt).
--
-- This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING
-- OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.
-- Please see the CERN-OHL-W v2 for applicable conditions.
--
-- Source location: https:--github.com/phase4ground/dvb_fpga
--
-- As per CERN-OHL-W v2 section 4.1, should You produce hardware based on this
-- source, You must maintain the Source Location visible on the external case of
-- the DVB Encoder or other products you make using this source.
-- Wrapper to allow instantiating the dvbs2_encoder to a Vivado block diagram

-- This is heavily based on https://github.com/phase4ground/DVB-receiver/blob/master/modem/hdl/library/fir_filter/fir_filter.v
-- by yrrapt (Thomas Parry)

---------------
-- Libraries --
---------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpga_cores;
use fpga_cores.common_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity fir_filter is
  generic (
    NUMBER_TAPS       : integer := 16;
    DATA_WIDTH        : integer := 16;
    COEFFICIENT_WIDTH : integer := 16);
  port (
    clk             : in std_logic;
    rst             : in std_logic;

    coeffs_wren     : in  std_logic;
    coeffs_addr     : in  std_logic_vector(numbits(NUMBER_TAPS) - 1 downto 0);
    coeffs_wdata    : in  std_logic_vector(COEFFICIENT_WIDTH - 1 downto 0);
    coeffs_rdata    : out std_logic_vector(COEFFICIENT_WIDTH - 1 downto 0);

    data_in_tready  : out std_logic;
    data_in_tdata   : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    data_in_tlast   : in std_logic;
    data_in_tvalid  : in std_logic;

    data_out_tready : in std_logic;
    data_out_tdata  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    data_out_tlast  : out std_logic;
    data_out_tvalid : out std_logic);
end fir_filter;

architecture fir_filter of fir_filter is

  constant CARRY_WIDTH  : integer := 48;
  constant MAC_DELAY    : integer := 2;
  constant FILTER_DELAY : integer := NUMBER_TAPS + MAC_DELAY;
  constant TLAST_DELAY  : integer := FILTER_DELAY + NUMBER_TAPS-1;

  -----------
  -- Types --
  -----------
  type mac_type is record
    en       : std_logic;
    data_in  : std_logic_vector(DATA_WIDTH - 1 downto 0);
    carry    : std_logic_vector(CARRY_WIDTH - 1 downto 0);
    data_out : std_logic_vector(DATA_WIDTH - 1 downto 0);
  end record;

  type mac_chain_type is array (NUMBER_TAPS - 0 downto 0) of mac_type;

  -------------
  -- Signals --
  -------------
  signal mac_coefficients    : std_logic_array_t(NUMBER_TAPS - 1 downto 0)(COEFFICIENT_WIDTH - 1 downto 0);
  signal data_in_tready_i    : std_logic;
  signal samples_remaining   : std_logic;
  signal empty_remaining     : std_logic;
  signal tlast_latch         : std_logic;
  signal tlast_clear_count   : unsigned(numbits(TLAST_DELAY) - 1 downto 0);

  signal tvalid_delay_line   : std_logic_vector(FILTER_DELAY - 1 downto 0);
  signal tlast_delay_line    : std_logic_vector(TLAST_DELAY - 1 downto 0);
  signal filter_data_in      : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal data_out            : std_logic_vector(DATA_WIDTH - 1 downto 0);

  signal mac                 : mac_chain_type;

begin

  mac(0).data_in <= filter_data_in;
  mac(0).carry   <= (others => '0');
  mac(0).en      <= (data_in_tvalid and data_in_tready_i and data_in_tvalid) or empty_remaining;

  -------------------
  -- Port mappings --
  -------------------
  g_mac : for i in 0 to NUMBER_TAPS - 1 generate
    function get_number_regs return integer is begin
      if i = 0 then
        return 1;
      end if;
      return 2;
    end function;
  begin

    mac(i + 1).en <= (tvalid_delay_line(i) and data_in_tready_i and data_in_tvalid) or empty_remaining;

    mac_u : entity work.multiply_accumulate
      generic map (
        OP_A_WIDTH          => DATA_WIDTH,
        OP_B_WIDTH          => COEFFICIENT_WIDTH,
        CARRY_WIDTH         => CARRY_WIDTH,
        DATA_IN_NUMBER_REGS => get_number_regs)
      port map (
        clk        => clk,
        rst        => rst,

        op_en      => mac(i).en,
        op_a       => mac(i).data_in,
        op_b       => mac_coefficients(i),
        cin        => mac(i).carry,

        carry_out  => mac(i+1).carry,
        data_carry => mac(i+1).data_in,
        data_out   => mac(i).data_out);
  end generate;

  data_out <= mac(NUMBER_TAPS - 1).data_out;

  data_in_tready_i <= data_out_tready;
  data_in_tready   <= data_in_tready_i;
  data_out_tdata   <= data_out;

  -- combine the enable signals
  empty_remaining <= or(tlast_delay_line) and data_out_tready;

  -- signal that there is still samples in the delay line
  samples_remaining <= or(tvalid_delay_line);

  -- output is valid as long as the previous clock enable of the last
  -- DSP48E1 was high
  data_out_tvalid <= tvalid_delay_line(FILTER_DELAY - 1);

  -- pass through the tlast signal
  data_out_tlast <= tlast_delay_line(TLAST_DELAY - 1);

  -- create delay lines for the valid and last signals
  --  TODO I'm not happy with this yet as it will not clear if the number of valid inputs is
  --       less than the delay line width.  Ideally this should be fixed
  filter_data_in <= data_in_tdata and not (DATA_WIDTH -1 downto 0 => tlast_latch);

  process(clk, rst)
  begin
    if rst = '1' then
      tlast_latch <= '0';

      tvalid_delay_line <= (others => '0');
      tlast_delay_line  <= (others => '0');
      tlast_clear_count <= (others => '0');

    elsif rising_edge(clk) then
      if data_in_tvalid and data_in_tready then
        tlast_latch <= tlast_latch or data_in_tlast;
      end if;


      -- we need to clear out remaining samples within the delay line
      if tlast_latch and empty_remaining then
        tlast_clear_count <= tlast_clear_count + 1;
        tvalid_delay_line <= tvalid_delay_line(FILTER_DELAY - 2 downto 0) & '1';
        tlast_delay_line  <= tlast_delay_line(TLAST_DELAY - 2 downto 0) & data_in_tlast;
      -- a valid input sample has been provided or we're clearing the output
      --  so increment the delay line
      elsif ((data_in_tready and data_in_tvalid) or empty_remaining) then
        tvalid_delay_line <= tvalid_delay_line(FILTER_DELAY - 2 downto 0) & data_in_tvalid;
        tlast_delay_line  <= tlast_delay_line(TLAST_DELAY - 2 downto 0) & data_in_tlast;
      end if;

      -- Store coefficients
      coeffs_rdata <= mac_coefficients(to_integer(unsigned(coeffs_addr)));
      if coeffs_wren then
        mac_coefficients(to_integer(unsigned(coeffs_addr))) <= coeffs_wdata;
      end if;

    end if;
  end process;

end fir_filter;
