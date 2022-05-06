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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fpga_cores;
use fpga_cores.common_pkg.all;

use work.dvb_utils_pkg.all;
use work.ldpc_pkg.all;
use work.ldpc_tables_pkg.all;

------------------------
-- Entity declaration --
------------------------
entity axi_ldpc_table is
  port (
    -- Usual ports
    clk     : in  std_logic;
    rst     : in  std_logic;

    -- Parameter input
    s_frame_type    : in  frame_type_t;
    s_code_rate     : in  code_rate_t;
    s_tready        : out std_logic;
    s_tvalid        : in  std_logic;

    -- Config out
    m_tready     : in  std_logic;
    m_tvalid     : out std_logic;
    m_offset     : out std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);
    m_next       : out std_logic;
    m_tuser      : out std_logic_vector(numbits(max(DVB_N_LDPC)) - 1 downto 0);
    m_tlast      : out std_logic);
end axi_ldpc_table;

architecture axi_ldpc_table of axi_ldpc_table is

  ---------------
  -- Constants --
  ---------------
  constant PARAM_FIFO_DATA_WIDTHS : integer_vector_t := (
    0 => FRAME_TYPE_WIDTH,
    1 => CODE_RATE_WIDTH);

  constant TABLE_ENTRY_WIDTH : integer := get_table_entry_width(LDPC_DATA_TABLE);

  -- Record with LDPC metadata as unsigned vectors
  type ldpc_metadata_unsigned_t is record
    addr          : unsigned(numbits(LDPC_DATA_TABLE'length) - 1 downto 0);
    q             : unsigned(LDPC_Q_WIDTH - 1 downto 0);
    stage_0_loops : unsigned(7 downto 0);
    stage_0_rows  : unsigned(7 downto 0);
    stage_1_loops : unsigned(7 downto 0);
    stage_1_rows  : unsigned(7 downto 0);
  end record ldpc_metadata_unsigned_t;

  -- Overload original to get unsigned fields
  function get_ldpc_metadata (
    constant frame_type : frame_type_t;
    constant code_rate  : code_rate_t) return ldpc_metadata_unsigned_t is
    variable result     : ldpc_metadata_t := get_ldpc_metadata(frame_type, code_rate);
  begin
    return (
      addr          => to_unsigned(result.addr, numbits(LDPC_DATA_TABLE'length)),
      q             => to_unsigned(result.q, LDPC_Q_WIDTH),
      stage_0_loops => to_unsigned(result.stage_0_loops - 1, 8),
      stage_0_rows  => to_unsigned(result.stage_0_rows - 1, 8),
      stage_1_loops => to_unsigned(result.stage_1_loops - 1, 8),
      stage_1_rows  => to_unsigned(result.stage_1_rows - 1, 8)
    );
  end;

  -------------
  -- Signals --
  -------------
  signal param_fifo_tdata_in  : std_logic_vector(sum(PARAM_FIFO_DATA_WIDTHS) - 1 downto 0);
  signal param_fifo_tdata_out : std_logic_vector(sum(PARAM_FIFO_DATA_WIDTHS) - 1 downto 0);

  signal axi_tready           : std_logic;
  signal axi_tvalid           : std_logic;
  signal axi_dv               : std_logic;

  -- Actual config we have to process
  signal cfg_frame_type    : frame_type_t;
  signal cfg_code_rate     : code_rate_t;

  signal table_length      : unsigned(numbits(max(DVB_N_LDPC)) - 1 downto 0);
  signal table_length_reg  : unsigned(numbits(max(DVB_N_LDPC)) - 1 downto 0);

  signal metadata          : ldpc_metadata_unsigned_t;
  signal table_addr        : unsigned(numbits(LDPC_DATA_TABLE'length) - 1 downto 0);
  signal rom_data          : std_logic_vector(TABLE_ENTRY_WIDTH - 1 downto 0);
  signal offset_delta      : unsigned(TABLE_ENTRY_WIDTH - 1 downto 0);
  signal offset_delta_reg  : std_logic_vector(TABLE_ENTRY_WIDTH - 1 downto 0);
  signal busy              : std_logic;

  signal stage             : unsigned(0 downto 0);
  signal loop_cnt          : unsigned(7 downto 0); -- TODO: resize correctly
  signal loop_cnt_max      : unsigned(7 downto 0); -- TODO: resize correctly
  signal row_cnt           : unsigned(7 downto 0); -- TODO: resize correctly
  signal row_cnt_max       : unsigned(7 downto 0); -- TODO: resize correctly
  signal group_cnt         : unsigned(numbits(DVB_LDPC_GROUP_LENGTH) - 1 downto 0);

  signal ldpc_wr_en        : std_logic;
  signal ldpc_next         : std_logic;
  signal ldpc_coeff        : unsigned(numbits(max(DVB_N_LDPC)) downto 0);
  signal last_coeff        : std_logic;
  signal raw_offset        : unsigned(numbits(max(DVB_N_LDPC)) downto 0);

  -- Interface with AXI stream adapter
  signal axi_out_wren      : std_logic;
  signal axi_out_wr_full   : std_logic;
  signal axi_out_next      : std_logic;
  -- This offset needs to be 1 bit bigger than needed because while the offset itself will
  -- not be higher than DVB_N_LDPC, adding it with the offset delta *BEFORE* the modulus
  -- operator will
  signal axi_out_offset    : unsigned(numbits(max(DVB_N_LDPC)) downto 0);
  signal axi_out_bit_cnt   : unsigned(numbits(max(DVB_N_LDPC)) - 1 downto 0);
  signal axi_out_last      : std_logic;

begin

  -- Add a small FIFO for the config to mitigate latency between the config input and the
  -- actual coefficients going out
  param_fifo_tdata_in <= encode(s_code_rate) & encode(s_frame_type);

  param_fifo_u : entity fpga_cores.axi_stream_fifo
    generic map (
      FIFO_DEPTH => 2,
      DATA_WIDTH => sum(PARAM_FIFO_DATA_WIDTHS),
      RAM_TYPE   => lut)
    port map (
      -- Usual ports
      clk     => clk,
      rst     => rst,

      -- Write side
      s_tvalid => s_tvalid,
      s_tready => s_tready,
      s_tdata  => param_fifo_tdata_in,
      s_tlast  => '0',

      -- Read side
      m_tvalid => axi_tvalid,
      m_tready => axi_tready,
      m_tdata  => param_fifo_tdata_out,
      m_tlast  => open);

  -- The ROM with the coefficients from the spec
  rom_u : entity fpga_cores.rom_inference
    generic map (
      ROM_DATA     => LDPC_DATA_TABLE,
      ROM_TYPE     => auto,
      OUTPUT_DELAY => 2)
    port map (
      clk    => clk,
      clken  => '1',
      addr   => std_logic_vector(table_addr),
      rddata => rom_data);

  ----------------------------------
  -- Controls for reading the ROM --
  ----------------------------------
  axi_dv <= axi_tvalid and axi_tready;

  row_cnt_max <= (others => 'U') when stage = (stage'range => 'U') else
                 metadata.stage_0_rows when stage = 0              else
                 metadata.stage_1_rows;

  loop_cnt_max <= (others => 'U') when stage = (stage'range => 'U') else
                  metadata.stage_0_loops when stage = 0 else
                  metadata.stage_1_loops;

  ldpc_coeff <= '0' & unsigned(rom_data);

  last_coeff  <= '1' when loop_cnt = loop_cnt_max and stage = 1 and row_cnt = row_cnt_max and group_cnt = DVB_LDPC_GROUP_LENGTH - 1 else '0';

  ldpc_wr_en <= busy and not axi_out_wr_full;

  ----------------------------------------------------------------------------
  -- Read the ROM and generate the values for calculating the actual offset --
  ----------------------------------------------------------------------------
  process(clk, rst)
    variable tmp_frame_type    : frame_type_t;
    variable tmp_code_rate     : code_rate_t;
    variable tmp_ldpc_metadata : ldpc_metadata_unsigned_t;
  begin
    if rst = '1' then
      axi_tready      <= '1';
      busy            <= '0';
      ldpc_next       <= '0';

      stage           <= (others => '0');
      loop_cnt        <= (others => '0');
      row_cnt         <= (others => '0');
      group_cnt       <= (others => '0');
      axi_out_bit_cnt <= (others => '0');
      offset_delta    <= (others => '0');

      table_length    <= (others => '1');

      table_addr      <= (others => 'U');
      cfg_frame_type  <= unknown;
      cfg_code_rate   <= unknown;
      metadata        <= (addr          => (others => 'U'),
                          q             => (others => 'U'),
                          stage_0_loops => (others => 'U'),
                          stage_0_rows  => (others => 'U'),
                          stage_1_loops => (others => 'U'),
                          stage_1_rows  => (others => 'U'));

    elsif clk'event and clk = '1' then

      ldpc_next    <= '0';

      if axi_dv = '1' then
        axi_tready        <= '0';
        busy              <= '1';

        -- Use temporary variables as aliases
        tmp_frame_type    := decode(get_field(param_fifo_tdata_out, 0, PARAM_FIFO_DATA_WIDTHS));
        tmp_code_rate     := decode(get_field(param_fifo_tdata_out, 1, PARAM_FIFO_DATA_WIDTHS));
        tmp_ldpc_metadata := get_ldpc_metadata(frame_type => tmp_frame_type,
                                               code_rate  => tmp_code_rate);

        cfg_frame_type    <= tmp_frame_type;
        cfg_code_rate     <= tmp_code_rate;

        metadata          <= tmp_ldpc_metadata;
        table_addr        <= tmp_ldpc_metadata.addr;
      end if;

      if axi_out_wren = '1' and axi_out_next = '1' then
        axi_out_bit_cnt <= axi_out_bit_cnt + 1;

        if axi_out_last = '1' then
          axi_out_bit_cnt <= (others => '0');
          table_length    <= (others => '1');
        end if;
      end if;

      if busy = '1' and axi_out_wr_full = '0' then

        -- Can't update table length when reading from the parameter FIFO because its
        -- value is used in conjunction with the ROM output, which is delayed
        table_length  <= to_unsigned(get_ldpc_code_length(frame_type => cfg_frame_type,
                                                          code_rate => cfg_code_rate),
                                     table_length'length);

        table_addr    <= table_addr + 1;
        row_cnt       <= row_cnt + 1;

        last_row : if row_cnt = row_cnt_max then
          row_cnt    <= (others => '0');
          ldpc_next  <= '1';
          group_cnt  <= group_cnt + 1;

          -- Modulus operator is spread across the terms of the final offset calculation
          if offset_delta + metadata.q < table_length then
            offset_delta  <= offset_delta + metadata.q;
          else
            offset_delta  <= offset_delta + metadata.q - table_length;
          end if;

          -- Re read this address range
          table_addr <= metadata.addr;

          -- Handle end of the 360 entries group
          end_of_group : if group_cnt = DVB_LDPC_GROUP_LENGTH - 1 then
            group_cnt       <= (others => '0');
            loop_cnt        <= loop_cnt + 1;
            table_addr      <= table_addr + 1;

            -- Once we iterated enough times over this range, let the address increment
            -- but store the point where that happened so we can do the same thing with
            -- a different base address
            metadata.addr   <= table_addr + 1;

            end_of_loop : if loop_cnt = loop_cnt_max then
              loop_cnt      <= (others => '0');

              if stage = 0 then
                stage       <= stage + 1;
              else
                stage       <= (others => '0');
                busy        <= '0';
                axi_tready  <= '1';
              end if;
            end if end_of_loop;
          end if end_of_group;
        end if last_row;
      end if;
    end if;
  end process;

  -------------------------------------------------------------
  -- Synchronize control and data for the AXI output adapter --
  -------------------------------------------------------------
  axi_out_ctrl_gen_u : entity fpga_cores.sr_delay
    generic map (
      DELAY_CYCLES  => 4,
      DATA_WIDTH    => 2,
      EXTRACT_SHREG => False)
    port map (
      clk      => clk,
      clken    => '1',

      din(0)   => ldpc_wr_en,
      din(1)   => last_coeff,

      dout(0)  => axi_out_wren,
      dout(1)  => axi_out_last);

  axi_out_next_gen_u : entity fpga_cores.sr_delay
    generic map (
      DELAY_CYCLES  => 3,
      DATA_WIDTH    => 1,
      EXTRACT_SHREG => False)
    port map (
      clk      => clk,
      clken    => '1',

      din(0)   => ldpc_next,
      dout(0)  => axi_out_next);

  -- Synchronize the offset with the pipelined ldpc_coeff
  offset_delta_delay_u : entity fpga_cores.sr_delay
    generic map (
      DELAY_CYCLES  => 2,
      DATA_WIDTH    => offset_delta'length,
      EXTRACT_SHREG => False)
    port map (
      clk      => clk,
      clken    => '1',

      din   => std_logic_vector(offset_delta),
      dout  => offset_delta_reg);

  -- Pipeline axi_out_offset to improve timing. Doing both arithmetic and decision in the
  -- same cycle was resulting in non ideal logic re timing
  process(clk)
  begin
    if rising_edge(clk) then
      raw_offset       <= ldpc_coeff + unsigned(offset_delta_reg);
      table_length_reg <= table_length;

      if raw_offset < table_length_reg then
        axi_out_offset <= raw_offset;
      else
        -- Second modulus pass
        axi_out_offset <= raw_offset - table_length_reg;
      end if;
    end if;
  end process;

  output_adapter_block : block
    signal wr_data : std_logic_vector(m_offset'length + m_tuser'length downto 0);
    signal rd_data : std_logic_vector(m_offset'length + m_tuser'length downto 0);
  begin

    wr_data  <= axi_out_next
                & std_logic_vector(axi_out_bit_cnt)
                & std_logic_vector(axi_out_offset(numbits(max(DVB_N_LDPC)) - 1 downto 0));

    m_offset <= rd_data(m_offset'length - 1 downto 0);
    m_tuser  <= rd_data(m_tuser'length + m_offset'length - 1 downto m_offset'length);
    m_next   <= rd_data(m_tuser'length + m_offset'length);

    axi_out_adapter_u : entity fpga_cores.axi_stream_master_adapter
      generic map (
        MAX_SKEW_CYCLES => 5,
        TDATA_WIDTH     => wr_data'length)
      port map (
        -- Usual ports
        clk      => clk,
        reset    => rst,
        -- wanna-be AXI interface
        wr_en    => axi_out_wren,
        wr_full  => axi_out_wr_full,
        wr_data  => wr_data,
        wr_last  => axi_out_last,
        -- AXI master
        m_tvalid => m_tvalid,
        m_tready => m_tready,
        m_tdata  => rd_data,
        m_tlast  => m_tlast);
  end block output_adapter_block;

end axi_ldpc_table;
