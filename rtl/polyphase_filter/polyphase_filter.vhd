--
-- DVB IP
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
-- Wrapper to allow instantiating the dvbs2_encoder to a Vivado block diagram

-- This is heavily based on https://github.com/phase4ground/DVB-receiver/blob/master/modem/hdl/library/polyphase_filter/polyphase_filter.v
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
entity polyphase_filter_vhd is
  generic (
     NUMBER_TAPS       : integer:= 32;
     DATA_IN_WIDTH     : integer:= 16;
     DATA_OUT_WIDTH    : integer:= 16;
     COEFFICIENT_WIDTH : integer:= 16;
     RATE_CHANGE       : integer:= 8
   );
  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    -- coeffs input interface
    coeffs_wren  : in  std_logic;
    coeffs_addr  : in  std_logic_vector(numbits(NUMBER_TAPS) - 1 downto 0);
    coeffs_wdata : in  std_logic_vector(COEFFICIENT_WIDTH - 1 downto 0);
    coeffs_rdata : out std_logic_vector(COEFFICIENT_WIDTH - 1 downto 0);
    -- input data interface
    s_tvalid     : in  std_logic;
    s_tlast      : in  std_logic;
    s_tready     : out std_logic;
    s_tdata      : in  std_logic_vector(DATA_IN_WIDTH - 1 downto 0);
    -- output data interface
    m_tvalid     : out std_logic;
    m_tlast      : out std_logic;
    m_tready     : in std_logic;
    m_tdata      : out std_logic_vector(DATA_OUT_WIDTH - 1 downto 0)
  );
end polyphase_filter_vhd;

architecture polyphase_filter_vhd of polyphase_filter_vhd is

  -- Constants
  constant SUB_LENGTH : integer := NUMBER_TAPS/RATE_CHANGE;

  -------------
  -- Signals --
  -------------
  signal input_mask           : std_logic_vector(RATE_CHANGE - 1 downto 0);
  signal fir_input_data_valid : std_logic_vector(RATE_CHANGE - 1 downto 0);
  signal output_mask          : std_logic_vector(RATE_CHANGE - 1 downto 0);

  signal rep_tdata            : std_logic_array_t(RATE_CHANGE - 1 downto 0)(DATA_IN_WIDTH downto 0);
  signal rep_tvalid           : std_logic_vector(RATE_CHANGE - 1 downto 0);
  signal rep_tready           : std_logic_vector(RATE_CHANGE - 1 downto 0);

  signal filter_s_tready      : std_logic_vector(RATE_CHANGE - 1 downto 0);
  signal filter_s_tdata       : std_logic_array_t(RATE_CHANGE - 1 downto 0)(DATA_OUT_WIDTH - 1 downto 0);
  signal filter_s_tlast       : std_logic_vector(RATE_CHANGE - 1 downto 0);
  signal filter_s_tvalid      : std_logic_vector(RATE_CHANGE - 1 downto 0);

  signal selected_filter      : std_logic_vector(numbits(RATE_CHANGE) - 1 downto 0);
  signal addr_filter          : std_logic_vector(numbits(SUB_LENGTH) - 1 downto 0);

begin

  selected_filter <= coeffs_addr(selected_filter'range);
  addr_filter     <= coeffs_addr(selected_filter'length + addr_filter'length - 1 downto selected_filter'length);

  -- Distribute input data stream into the FIR instances
  axi_stream_replicate_block : block
    signal s_tdata_agg : std_logic_vector(DATA_IN_WIDTH downto 0);
  begin
    s_tdata_agg <= s_tlast & s_tdata;

    axi_stream_replicate_u : entity fpga_cores.axi_stream_replicate
      generic map (
        INTERFACES  => RATE_CHANGE,
        TDATA_WIDTH => DATA_IN_WIDTH + 1)
      port map (
        -- Usual ports
        clk       => clk,
        rst       => rst,

        -- AXI stream input
        s_tvalid  => s_tvalid,
        s_tready  => s_tready,
        s_tdata   => s_tdata_agg,
        -- AXI stream outputs
        m_tvalid  => rep_tvalid,
        m_tready  => rep_tready,
        m_tdata   => rep_tdata);
  end block;

  fir_filter_gen : for i in 0 to RATE_CHANGE - 1 generate
    signal wren               : std_logic;

    signal filter_m_tready    : std_logic;
    signal filter_m_tdata_agg : std_logic_vector(DATA_IN_WIDTH downto 0);
    signal filter_m_tdata     : std_logic_vector(DATA_IN_WIDTH - 1 downto 0);
    signal filter_m_tlast     : std_logic;
    signal filter_m_tvalid    : std_logic;
  begin
    wren <= coeffs_wren when unsigned(selected_filter) = i else '0';

    fir_flow_control_u : entity fpga_cores.axi_stream_flow_control
      generic map ( DATA_WIDTH => DATA_IN_WIDTH + 1)
      port map (
        -- Usual ports
        enable   => input_mask(i),

        s_tvalid => rep_tvalid(i),
        s_tready => rep_tready(i),
        s_tdata  => rep_tdata(i),

        m_tvalid => filter_m_tvalid,
        m_tready => filter_m_tready,
        m_tdata  => filter_m_tdata_agg);

    filter_m_tdata          <= filter_m_tdata_agg(DATA_IN_WIDTH - 1 downto 0);
    filter_m_tlast          <= filter_m_tdata_agg(DATA_IN_WIDTH);
    fir_input_data_valid(i) <= filter_m_tvalid and filter_m_tready;

    fir_filter_u : entity work.fir_filter_vhd
      generic map (
        NUMBER_TAPS       => SUB_LENGTH,
        DATA_WIDTH        => DATA_IN_WIDTH,
        COEFFICIENT_WIDTH => COEFFICIENT_WIDTH)
      port map (
        clk             => clk,
        rst             => rst,

        -- FIR coefficients input
        coeffs_wren      => wren,
        coeffs_addr      => addr_filter,
        coeffs_wdata     => coeffs_wdata,
        coeffs_rdata     => coeffs_rdata,
        --
        data_in_tready  => filter_m_tready,
        data_in_tdata   => filter_m_tdata,
        data_in_tlast   => filter_m_tlast,
        data_in_tvalid  => filter_m_tvalid,
        --
        data_out_tready => filter_s_tready(i),
        data_out_tdata  => filter_s_tdata(i),
        data_out_tlast  => filter_s_tlast(i),
        data_out_tvalid => filter_s_tvalid(i));
  end generate;

  filter_s_tready <= (others => m_tready);
  m_tvalid        <= or(output_mask and filter_s_tvalid);
  
  process(filter_s_tdata, filter_s_tlast, output_mask)
    variable tdata : std_logic_vector(DATA_OUT_WIDTH - 1 downto 0);
    variable tlast : std_logic;
  begin
    tdata := (others => '0');
    tlast := '0';
    for i in 0 to RATE_CHANGE - 1 loop
      tdata := tdata or (filter_s_tdata(i) and (DATA_OUT_WIDTH - 1 downto 0 => output_mask(i)));
      tlast := tlast or (filter_s_tlast(i) and output_mask(i));
    end loop;
    m_tdata <= tdata;
    m_tlast <= tlast;
  end process;

  -- Input mask will shift across all filters to distribute data at the correct time
  process(clk, rst)
  begin
    if rst = '1' then
      input_mask  <= (0 => '1', others => '0');
      output_mask <= (0 => '1', others => '0');
    elsif rising_edge(clk) then
      -- Shift input mask to allow data going into each of the FIR filter instances
      if or(fir_input_data_valid) then
        input_mask <= input_mask(RATE_CHANGE - 2 downto 0) & input_mask(RATE_CHANGE - 1);
      end if;

      -- Shift output mask to select the
      if or(filter_s_tvalid and filter_s_tready) then
        output_mask <= output_mask(RATE_CHANGE - 2 downto 0) & output_mask(RATE_CHANGE - 1);
      end if;
    end if;
  end process;

end polyphase_filter_vhd;
