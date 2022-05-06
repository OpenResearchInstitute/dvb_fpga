--
-- DVB FPGA
--
-- Copyright 2019-2022 by Suoto <andre820@gmail.com>
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
library	ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpga_cores;
use fpga_cores.common_pkg.all;
use fpga_cores.axi_pkg.all;

use work.dvb_utils_pkg.all;
use work.ldpc_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_ldpc_encoder_core is
  generic ( TID_WIDTH : integer := 0 );
  port (
    -- Usual ports
    clk             : in  std_logic;
    rst             : in  std_logic;
    -- AXI LDPC table input
    s_ldpc_tready   : out std_logic;
    s_ldpc_tvalid   : in  std_logic;
    s_ldpc_offset   : in  std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);
    s_ldpc_next     : in  std_logic;
    s_ldpc_tuser    : in  std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);
    s_ldpc_tlast    : in  std_logic;
    -- AXI data input
    s_constellation : in  constellation_t;
    s_frame_type    : in  frame_type_t;
    s_code_rate     : in  code_rate_t;
    s_tready        : out std_logic;
    s_tvalid        : in  std_logic;
    s_tlast         : in  std_logic;
    s_tdata         : in  std_logic_vector(7 downto 0);
    s_tid           : in  std_logic_vector(TID_WIDTH - 1 downto 0);
    -- AXI output
    m_tready        : in  std_logic;
    m_tvalid        : out std_logic;
    m_tlast         : out std_logic;
    m_tdata         : out std_logic_vector(7 downto 0);
    m_tid           : out std_logic_vector(TID_WIDTH - 1 downto 0));
end axi_ldpc_encoder_core;

architecture axi_ldpc_encoder_core of axi_ldpc_encoder_core is

  ---------------
  -- Constants --
  ---------------
  constant DATA_WIDTH           : natural := 8;
  constant ROM_DATA_WIDTH       : natural := numbits(max(DVB_N_LDPC));
  constant FRAME_RAM_DATA_WIDTH : natural := 16;
  constant FRAME_RAM_DEPTH      : natural := (max(DVB_N_LDPC) + FRAME_RAM_DATA_WIDTH - 1) / FRAME_RAM_DATA_WIDTH;
  constant FRAME_RAM_ADDR_WIDTH : natural := numbits(FRAME_RAM_DEPTH);

  type ldpc_data_t is record
    tready     : std_logic;
    tvalid     : std_logic;
    tlast      : std_logic;
    tid        : std_logic_vector(TID_WIDTH - 1 downto 0);
    tdata      : std_logic;
    offset     : std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);
    tuser      : std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);
    frame_type : frame_type_t;
  end record;

  type axi_and_metadata_t is record
    constellation : constellation_t;
    frame_type    : frame_type_t;
    code_rate     : code_rate_t;
    tdata         : std_logic_vector(DATA_WIDTH - 1 downto 0);
    tvalid        : std_logic;
    tready        : std_logic;
    tlast         : std_logic;
    data_valid    : std_logic;
  end record;

  -------------
  -- Signals --
  -------------
  signal m_tvalid_i               : std_logic; -- internal version of m_tvalid

  -- Branches of the AXI replicate
  signal axi_passthrough          : axi_stream_bus_t(tdata(DATA_WIDTH - 1 downto 0), tuser(TID_WIDTH - 1 downto 0));
  signal ldpc_branch              : axi_and_metadata_t;

  -- Main data input for the LDPC calculation
  signal ldpc_data                : ldpc_data_t;
  signal ldpc_dv                  : std_logic;
  signal ldpc_first_word          : std_logic;
  signal ldpc_frame_length        : unsigned(numbits(max(DVB_N_LDPC)) - 1 downto 0);
  signal dbg_ldpc_data_count      : unsigned(s_ldpc_tuser'length - 1 downto 0) := (others => '0');

  -- Interface with the frame RAM
  signal ram_en_in                : std_logic;
  signal ram_addr_in              : unsigned(FRAME_RAM_ADDR_WIDTH - 1 downto 0);
  signal ram_addr_sweep           : unsigned(FRAME_RAM_ADDR_WIDTH - 1 downto 0);
  signal ram_bit_index_in         : unsigned(numbits(FRAME_RAM_DATA_WIDTH) - 1 downto 0);

  -- Frame RAM output
  signal ram_en_out               : std_logic;
  signal ram_addr_out             : std_logic_vector(FRAME_RAM_ADDR_WIDTH - 1 downto 0);
  signal ram_bit_index_out        : unsigned(numbits(FRAME_RAM_DATA_WIDTH) - 1 downto 0);
  -- ram_bit_index_in is sync with ram_addr_out and rame_ram_rddata
  signal ram_data_out             : std_logic_vector(FRAME_RAM_DATA_WIDTH  - 1 downto 0);
  -- AXI data synchronized to the frame RAM output data
  signal ldpc_tdata_reg           : std_logic;
  -- Frame RAM data loop
  signal ram_data_in              : std_logic_vector(FRAME_RAM_DATA_WIDTH - 1 downto 0);

  -- Last XOR pass on data from the frame RAM
  signal encoded_wr_en            : std_logic;
  signal encoded_wr_full          : std_logic;
  signal encoded_wr_data          : std_logic_vector(FRAME_RAM_DATA_WIDTH - 1 downto 0);
  signal encoded_wr_last          : std_logic;
  signal encoded_wr_mask          : std_logic_vector((FRAME_RAM_DATA_WIDTH + 7) / 8 - 1 downto 0);

  signal axi_encoded              : axi_stream_bus_t(tdata(FRAME_RAM_DATA_WIDTH - 1 downto 0),
                                                     tuser((FRAME_RAM_DATA_WIDTH + 7) / 8 - 1 downto 0));

  -- Control flags to append the LDPC data once input frame has finished
  signal post_indata_ram_sweep    : std_logic;
  signal ram_sweep_last_addr      : unsigned(FRAME_RAM_ADDR_WIDTH - 1 downto 0);
  signal ram_sweep_last_addr_mask : std_logic_vector((FRAME_RAM_DATA_WIDTH + 7) / 8 - 1 downto 0);
  signal ram_sweep_completed      : std_logic;
  signal write_encoded_data       : std_logic;
  signal output_encoded_data      : std_logic;

  signal axi_out                  : axi_stream_data_bus_t(tdata(DATA_WIDTH - 1 downto 0));
  signal m_tid_reg                : std_logic_vector(TID_WIDTH - 1 downto 0);

begin

  -------------------
  -- Port mappings --
  -------------------
  -- Duplicate input stream, one leaf will connect to the output and the other to the
  -- actual LDPC calculation that will be appended
  input_duplicate_block : block -- {{ --------------------------------------------------
    constant WIDTHS : integer_vector_t := (
      0 => DATA_WIDTH,
      1 => 1,
      2 => FRAME_TYPE_WIDTH,
      3 => CONSTELLATION_WIDTH,
      4 => CODE_RATE_WIDTH,
      5 => TID_WIDTH);

    constant AXI_DUP_DATA_WIDTH   : integer := sum(WIDTHS);

    signal s_tdata_agg            : std_logic_vector(AXI_DUP_DATA_WIDTH - 1 downto 0);

    signal axi_dup0_tdata         : std_logic_vector(AXI_DUP_DATA_WIDTH - 1 downto 0);
    signal axi_dup1_tdata         : std_logic_vector(AXI_DUP_DATA_WIDTH - 1 downto 0);

  begin

    s_tdata_agg <= s_tid &
                   encode(s_code_rate) &
                   encode(s_constellation) &
                   encode(s_frame_type) &
                   s_tlast &
                   s_tdata;

    axi_passthrough.tdata  <= get_field(axi_dup0_tdata, 0, WIDTHS);
    axi_passthrough.tlast  <= get_field(axi_dup0_tdata, 1, WIDTHS);
    axi_passthrough.tuser  <= get_field(axi_dup0_tdata, 5, WIDTHS);

    ldpc_branch.tdata         <= get_field(axi_dup1_tdata, 0, WIDTHS);
    ldpc_branch.tlast         <= get_field(axi_dup1_tdata, 1, WIDTHS);
    ldpc_branch.frame_type    <= decode(get_field(axi_dup1_tdata, 2, WIDTHS));
    ldpc_branch.constellation <= decode(get_field(axi_dup1_tdata, 3, WIDTHS));
    ldpc_branch.code_rate     <= decode(get_field(axi_dup1_tdata, 4, WIDTHS));
    ldpc_branch.data_valid    <= ldpc_branch.tready and ldpc_branch.tvalid;

    input_duplicate_u : entity fpga_cores.axi_stream_replicate
      generic map (
        INTERFACES => 2,
        TDATA_WIDTH => AXI_DUP_DATA_WIDTH )
      port map (
        -- Usual ports
        clk         => clk,
        rst         => rst,
        -- AXI stream input
        s_tready    => s_tready,
        s_tdata     => s_tdata_agg,
        s_tvalid    => s_tvalid,
        -- AXI stream outputs
        m_tvalid(0) => axi_passthrough.tvalid,
        m_tvalid(1) => ldpc_branch.tvalid,
        m_tready(0) => axi_passthrough.tready,
        m_tready(1) => ldpc_branch.tready,
        m_tdata(0)  => axi_dup0_tdata,
        m_tdata(1)  => axi_dup1_tdata);

  end block; -- }} ---------------------------------------------------------------------


  -- Convert from FRAME_RAM_DATA_WIDTH to the specified data width
  input_conversion_block : block -- {{ -------------------------------------------------
    signal s_tid_encoded : std_logic_vector(FRAME_TYPE_WIDTH - 1 downto 0);
    signal m_tid_encoded : std_logic_vector(FRAME_TYPE_WIDTH - 1 downto 0);
  begin
    -- GHDL fails if this is done at the port map
    s_tid_encoded       <= encode(ldpc_branch.frame_type);

    ldpc_input_sync_u : entity work.ldpc_input_sync
      generic map (
        INPUT_DATA_WIDTH  => DATA_WIDTH,
        TID_WIDTH         => FRAME_TYPE_WIDTH)
      port map (
        -- Usual ports
        clk             => clk,
        rst             => rst,
        -- AXI LDPC table input
        s_ldpc_tready   => s_ldpc_tready,
        s_ldpc_tvalid   => s_ldpc_tvalid,
        s_ldpc_offset   => s_ldpc_offset,
        s_ldpc_next     => s_ldpc_next,
        s_ldpc_tuser    => s_ldpc_tuser,
        s_ldpc_tlast    => s_ldpc_tlast,
        -- AXI data input
        s_tready        => ldpc_branch.tready,
        s_tvalid        => ldpc_branch.tvalid,
        s_tlast         => ldpc_branch.tlast,
        s_tdata         => ldpc_branch.tdata,
        s_tid           => s_tid_encoded,
        -- AXI data output
        m_tready        => ldpc_data.tready,
        m_tvalid        => ldpc_data.tvalid,
        m_tlast         => ldpc_data.tlast,
        m_tid           => m_tid_encoded,
        m_tdata         => ldpc_data.tdata,
        m_ldpc_offset   => ldpc_data.offset,
        m_ldpc_tuser    => ldpc_data.tuser);

      ldpc_data.frame_type <= decode(m_tid_encoded);
    end block; -- }} -------------------------------------------------------------------

  frame_ram_u : entity fpga_cores.pipeline_context_ram
    generic map (
      DEPTH      => FRAME_RAM_DEPTH,
      DATA_WIDTH => FRAME_RAM_DATA_WIDTH,
      RAM_TYPE   => bram)
    port map (
      clk         => clk,
      -- Checkout request interface
      en_in       => ram_en_in,
      addr_in     => std_logic_vector(ram_addr_in),
      -- Data checkout output
      en_out      => ram_en_out,
      addr_out    => ram_addr_out,
      context_out => ram_data_out,
      -- Updated data input
      context_in  => ram_data_in);

  -- Can't stop reading from the frame RAM instantly, allow some slack
  frame_ram_adapter_block : block -- {{ ------------------------------------------------
    signal wr_data   : std_logic_vector(encoded_wr_data'length + encoded_wr_mask'length - 1 downto 0);
    signal tdata_out : std_logic_vector(encoded_wr_data'length + encoded_wr_mask'length - 1 downto 0);
    signal wr_en     : std_logic;
  begin

    wr_data           <= encoded_wr_mask & encoded_wr_data;

    axi_encoded.tuser <= tdata_out(tdata_out'length - 1 downto 16);
    axi_encoded.tdata <= tdata_out(15 downto 0);

    frame_ram_adapter_u : entity fpga_cores.axi_stream_master_adapter
      generic map (
        MAX_SKEW_CYCLES => 3,
        TDATA_WIDTH     => encoded_wr_data'length + encoded_wr_mask'length)
      port map (
        -- Usual ports
        clk      => clk,
        reset    => rst,
        -- Wanna-be AXI interface
        wr_en    => encoded_wr_en,
        wr_full  => encoded_wr_full,
        wr_data  => wr_data,
        wr_last  => encoded_wr_last,
        -- AXI master
        m_tvalid => axi_encoded.tvalid,
        m_tready => axi_encoded.tready,
        m_tdata  => tdata_out,
        m_tlast  => axi_encoded.tlast);
  end block; -- }} -------------------------------------------------------------------

  -- Convert from FRAME_RAM_DATA_WIDTH to the specified data width
  output_width_conversion_u : entity fpga_cores.axi_stream_width_converter
    generic map (
      INPUT_DATA_WIDTH  => FRAME_RAM_DATA_WIDTH,
      OUTPUT_DATA_WIDTH => DATA_WIDTH,
      AXI_TID_WIDTH     => 0)
    port map (
      -- Usual ports
      clk        => clk,
      rst        => rst,
      -- AXI stream input
      s_tready   => axi_encoded.tready,
      s_tdata    => axi_encoded.tdata,
      s_tkeep    => axi_encoded.tuser,
      s_tvalid   => axi_encoded.tvalid,
      s_tlast    => axi_encoded.tlast,
      -- AXI stream output
      m_tready   => axi_out.tready,
      m_tdata    => axi_out.tdata,
      m_tvalid   => axi_out.tvalid,
      m_tlast    => axi_out.tlast);

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  -- Values synchronized with data from pipeline_context_ram
  ram_bit_index_in   <= unsigned(ldpc_data.offset(numbits(FRAME_RAM_DATA_WIDTH) - 1 downto 0));
  ram_addr_in        <= unsigned(s_ldpc_offset(ROM_DATA_WIDTH - 1 downto numbits(FRAME_RAM_DATA_WIDTH))) when not post_indata_ram_sweep else
                        ram_addr_sweep;

  ldpc_dv                <= ldpc_data.tready and ldpc_data.tvalid;
  ldpc_data.tready       <= not post_indata_ram_sweep and not write_encoded_data;

  -- Mux output data
  axi_out.tready         <= m_tready and output_encoded_data;
  axi_passthrough.tready <= m_tready and not output_encoded_data;
  m_tlast                <= output_encoded_data and axi_out.tlast;

  m_tdata                <= axi_passthrough.tdata when not output_encoded_data else
                            mirror_bits(axi_out.tdata);

  m_tvalid_i             <= (axi_passthrough.tvalid and axi_passthrough.tready and not output_encoded_data)
                             or axi_out.tvalid;

  m_tid                  <= (axi_passthrough.tuser and (TID_WIDTH - 1 downto 0 => not output_encoded_data)) or
                            (m_tid_reg and (TID_WIDTH - 1 downto 0 => output_encoded_data));

  ram_en_in              <= ldpc_dv or (post_indata_ram_sweep and not encoded_wr_full);

  ram_sweep_completed    <= ram_en_in when ram_addr_in = ram_sweep_last_addr else '0';

  m_tvalid      <= m_tvalid_i;

  ---------------
  -- Processes --
  ---------------
  axi_flow_ctrl_p : process(clk) -- {{ -------------------------------------------------
    variable tmp : unsigned(numbits(max(DVB_N_LDPC)) - 1 downto 0);
  begin
    if rising_edge(clk) then

      ram_bit_index_out <= ram_bit_index_in;

      encoded_wr_last   <= '0';
      encoded_wr_mask   <= (others => '1');
      if unsigned(ram_addr_out) = ram_sweep_last_addr then
        encoded_wr_last <= '1';
        encoded_wr_mask <= ram_sweep_last_addr_mask;
      end if;

      if ldpc_dv and ldpc_data.tlast then
        ram_addr_sweep <= (others => '0');
        tmp            := ldpc_frame_length - unsigned(ldpc_data.tuser) - 1;

        if tmp(3) then
          ram_sweep_last_addr      <= tmp(tmp'length - 1 downto 4);
          ram_sweep_last_addr_mask <= "01";
        else
          ram_sweep_last_addr      <= tmp(tmp'length - 1 downto 4) - 1;
          ram_sweep_last_addr_mask <= "11";
        end if;

      elsif post_indata_ram_sweep and not encoded_wr_full then
        ram_addr_sweep <= ram_addr_sweep + 1;
      end if;

      -- AXI frame data control
      if ldpc_dv then
        dbg_ldpc_data_count  <= dbg_ldpc_data_count + 1;

        if ldpc_data.tlast then
          dbg_ldpc_data_count <= (others => '0');
        end if;

        -- Set the expected frame length. Data will passthrough and LDPC codes will be
        -- appended to complete the appropriate n_ldpc length (either 16,200 or 64,800).
        if ldpc_first_word then
          if ldpc_data.frame_type = FECFRAME_SHORT then
            ldpc_frame_length <= to_unsigned(FECFRAME_SHORT_BIT_LENGTH, ldpc_frame_length'length);
          elsif ldpc_data.frame_type = FECFRAME_NORMAL then
            ldpc_frame_length <= to_unsigned(FECFRAME_NORMAL_BIT_LENGTH, ldpc_frame_length'length);
          else
            report "Don't know how to handle frame type=" & quote(frame_type_t'image(ldpc_data.frame_type))
              severity Error;
          end if;
        end if;
      end if;

    end if;
  end process; -- }} -------------------------------------------------------------------

  frame_ram_data_handle_p : process(clk, rst) -- {{ ------------------------------------
    variable xored_data : std_logic_vector(FRAME_RAM_DATA_WIDTH - 1 downto 0);
  begin
    if rst then
      write_encoded_data  <= '0';
      output_encoded_data <= '0';
      encoded_wr_en       <= '0';

      encoded_wr_data     <= (others => 'U');
      ram_data_in         <= (others => 'U');

      xored_data          := (others => 'U');

    elsif rising_edge(clk) then

      encoded_wr_en    <= '0';

      -- Always return the context, will change only when needed
      ram_data_in <= to_01_sim(ram_data_out);

      -- When calculating the final XOR'ed value, the first bit will depend on the
      -- address. We can safely assign here and avoid extra logic levels on the FF control
      if unsigned(ram_addr_out) = 0 then
        xored_data(0) := ram_data_out(0);
      else
        xored_data(0) := encoded_wr_data(FRAME_RAM_DATA_WIDTH - 1) xor ram_data_out(0);
      end if;

      if post_indata_ram_sweep then
        write_encoded_data  <= '1';
      end if;

      -- if write_encoded_data then
      if axi_passthrough.tvalid and axi_passthrough.tready and axi_passthrough.tlast then
        output_encoded_data <= '1';
      end if;

      if axi_out.tvalid and axi_out.tready and axi_out.tlast then
        output_encoded_data <= '0';
      end if;

      if encoded_wr_en and encoded_wr_last then
        encoded_wr_en      <= '0';
        write_encoded_data <= '0';
      elsif write_encoded_data then
        encoded_wr_en      <= ram_en_out;
      end if;

      -- Handle data coming out of the frame RAM, either by using the input data of by
      -- calculating the actual final XOR'ed value
      if ram_en_out then
        if write_encoded_data then
          ram_data_in <= (others => '0');
        else
          ram_data_in(to_integer(ram_bit_index_out)) <= ldpc_tdata_reg xor to_01_sim(ram_data_out(to_integer(ram_bit_index_out)));
        end if;

        -- Calculate the final XOR between output bits
        for i in 1 to FRAME_RAM_DATA_WIDTH - 1 loop
          xored_data(i) := ram_data_out(i) xor xored_data(i - 1);
        end loop;
        encoded_wr_data  <= xored_data;

      end if;

    end if;
  end process; -- }} -------------------------------------------------------------------

  axi_bit_sync_p : process(clk, rst)
  begin
    if rst then
      ldpc_first_word       <= '1';
      post_indata_ram_sweep <= '0';
      -- We don't want things muxed with rst here
      ldpc_tdata_reg        <= 'U';
      m_tid_reg             <= (others => 'U');
    elsif rising_edge(clk) then

      if ldpc_dv and ldpc_data.tlast then
        post_indata_ram_sweep <= '1';
      end if;

      -- Switch between forwarding data from s_axi or the codes calculated internally
      if axi_passthrough.tvalid and axi_passthrough.tready then
        m_tid_reg <= axi_passthrough.tuser;
      end if;

      if ram_sweep_completed then
        post_indata_ram_sweep <= '0';
      end if;

      if ldpc_dv then
        ldpc_first_word <= ldpc_data.tlast;
        ldpc_tdata_reg  <= ldpc_data.tdata;
      end if;

    end if;
  end process;

end axi_ldpc_encoder_core;

-- vim: set foldmethod=marker foldmarker=--\ {{,--\ }} :
