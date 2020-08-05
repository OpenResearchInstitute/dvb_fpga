--
-- DVB IP
--
-- Copyright 2019 by Suoto <andre820@gmail.com>
--
-- This file is part of the DVB IP.
--
-- DVB IP is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- DVB IP is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DVB IP.  If not, see <http://www.gnu.org/licenses/>.

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
    s_constellation : in  constellation_t;
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
    1 => CONSTELLATION_WIDTH,
    2 => CODE_RATE_WIDTH);

  constant TABLE_ENTRY_WIDTH : integer := LDPC_DATA_TABLE(0)'length;

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
    constant frame_length : frame_type_t;
    constant code_rate    : code_rate_t) return ldpc_metadata_unsigned_t is
    variable result       : ldpc_metadata_t := get_ldpc_metadata(frame_length, code_rate);
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
  signal cfg_constellation : constellation_t;
  signal cfg_frame_type    : frame_type_t;
  signal cfg_code_rate     : code_rate_t;

  signal table_length      : unsigned(numbits(max(DVB_N_LDPC)) - 1 downto 0);

  signal metadata          : ldpc_metadata_unsigned_t;
  signal table_addr        : unsigned(numbits(LDPC_DATA_TABLE'length) - 1 downto 0);
  signal rom_data          : std_logic_vector(TABLE_ENTRY_WIDTH - 1 downto 0);
  signal reset_delta       : std_logic;
  signal offset_delta      : unsigned(TABLE_ENTRY_WIDTH - 1 downto 0); --
  signal sample_rom_data   : std_logic;
  signal busy              : std_logic;

  signal stage             : unsigned(0 downto 0);
  signal loop_cnt          : unsigned(7 downto 0); -- TODO: resize correctly
  signal loop_cnt_max      : unsigned(7 downto 0); -- TODO: resize correctly
  signal row_cnt           : unsigned(7 downto 0); -- TODO: resize correctly
  signal row_cnt_max       : unsigned(7 downto 0); -- TODO: resize correctly

  signal ldpc_next         : std_logic;
  signal ldpc_next_reg     : std_logic;
  signal ldpc_coeff        : unsigned(numbits(max(DVB_N_LDPC)) - 1 downto 0);
  signal last_coeff        : std_logic;
  signal ldpc_offset       : unsigned(numbits(max(DVB_N_LDPC)) - 1 downto 0);

  signal bit_cnt           : unsigned(numbits(max(DVB_N_LDPC)) - 1 downto 0);
  signal group_cnt         : unsigned(numbits(DVB_LDPC_GROUP_LENGTH) - 1 downto 0);

  -- Interface with AXI stream adapter
  signal axi_out_wren   : std_logic;
  signal axi_out_wrfull : std_logic;
  signal axi_out_last   : std_logic;

begin

  -------------------
  -- Port mappings --
  -------------------
  -- Add a small FIFO for the config to mitigate latency between the config input and the
  -- actual coefficients going out
  param_fifo_tdata_in <= encode(s_code_rate) &
                         encode(s_constellation) &
                         encode(s_frame_type);

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

  -- The ROM itself
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

  ldpc_start_gen_u : entity fpga_cores.sr_delay
    generic map (
      DELAY_CYCLES  => 2,
      DATA_WIDTH    => 1,
      EXTRACT_SHREG => False)
    port map (
      clk     => clk,
      clken   => '1',

      din(0)   => axi_dv,
      dout(0)  => sample_rom_data);

  -- Synchronize ldpc_next with the actual calculated coefficient
  ldpc_next_gen_u : entity fpga_cores.sr_delay
    generic map (
      DELAY_CYCLES  => 2,
      DATA_WIDTH    => 3,
      EXTRACT_SHREG => False)
    port map (
      clk     => clk,
      clken   => '1',

      din(0)   => ldpc_next,
      din(1)   => busy,
      din(2)   => last_coeff,
      dout(0)  => m_next,
      dout(1)  => axi_out_wren,
      dout(2)  => axi_out_last);

  output_adapter_block : block
    signal wr_data : std_logic_vector(m_offset'length + m_tuser'length - 1 downto 0);
    signal rd_data : std_logic_vector(m_offset'length + m_tuser'length - 1 downto 0);

  begin

    wr_data  <= std_logic_vector(bit_cnt & ldpc_offset);

    m_offset <= rd_data(m_offset'length - 1 downto 0);
    m_tuser  <= rd_data(m_tuser'length + m_offset'length - 1 downto m_offset'length);

    axi_out_adapter_u : entity fpga_cores.axi_stream_master_adapter
      generic map (
        MAX_SKEW_CYCLES => 3,
        TDATA_WIDTH     => m_offset'length + m_tuser'length)
      port map (
        -- Usual ports
        clk      => clk,
        reset    => rst,
        -- wanna-be AXI interface
        wr_en    => axi_out_wren,
        wr_full  => axi_out_wrfull,
        wr_data  => wr_data,
        wr_last  => axi_out_last,
        -- AXI master
        m_tvalid => m_tvalid,
        m_tready => m_tready,
        m_tdata  => rd_data,
        m_tlast  => m_tlast);
    end block output_adapter_block;

  ------------------------------
  -- Asynchronous assignments --
  ------------------------------
  axi_dv <= axi_tvalid and axi_tready;

  row_cnt_max <= metadata.stage_0_rows when stage = 0 else
                 metadata.stage_1_rows;

  loop_cnt_max <= metadata.stage_0_loops when stage = 0 else
                  metadata.stage_1_loops;

  table_length <= to_unsigned(get_ldpc_code_length(frame_type => cfg_frame_type,
                                                   code_rate => cfg_code_rate),
                              table_length'length);

  -- Offset + delta won't ever go past 2*table length, so we can simplify the modulo operator
  ldpc_offset <= ldpc_coeff + offset_delta when ldpc_coeff + offset_delta < table_length else
                 ldpc_coeff + offset_delta - table_length;


  ldpc_coeff <= unsigned(rom_data);

  last_coeff  <= '1' when loop_cnt = loop_cnt_max and stage = 1 and row_cnt = row_cnt_max and group_cnt = DVB_LDPC_GROUP_LENGTH - 1 else '0';

  ---------------
  -- Processes --
  ---------------
  process(clk, rst)
    variable tmp_constellation : constellation_t;
    variable tmp_frame_type    : frame_type_t;
    variable tmp_code_rate     : code_rate_t;
    variable tmp_ldpc_metadata : ldpc_metadata_unsigned_t;
  begin
    if rst = '1' then
      axi_tready      <= '1';
      busy            <= '0';
      ldpc_next       <= '0';
      ldpc_next_reg   <= 'U';
      reset_delta     <= 'U';

      if IS_SIMULATION then
        table_addr <= (others => '0');
      else
        table_addr <= (others => 'U');
      end if;

    elsif clk'event and clk = '1' then

      ldpc_next       <= '0';
      ldpc_next_reg   <= ldpc_next;
      -- reset_delta  <= '0';

      if axi_dv = '1' then
        axi_tready        <= '0';
        busy              <= '1';

        -- Use temporary variables as aliases
        tmp_frame_type    := decode(extract(param_fifo_tdata_out, 0, PARAM_FIFO_DATA_WIDTHS));
        tmp_constellation := decode(extract(param_fifo_tdata_out, 1, PARAM_FIFO_DATA_WIDTHS));
        tmp_code_rate     := decode(extract(param_fifo_tdata_out, 2, PARAM_FIFO_DATA_WIDTHS));
        tmp_ldpc_metadata := get_ldpc_metadata(frame_length => tmp_frame_type, code_rate => tmp_code_rate);

        cfg_frame_type    <= tmp_frame_type;
        cfg_constellation <= tmp_constellation;
        cfg_code_rate     <= tmp_code_rate;

        metadata          <= tmp_ldpc_metadata;
        table_addr        <= tmp_ldpc_metadata.addr;

        stage             <= (others => '0');
        loop_cnt          <= (others => '0');
        row_cnt           <= (others => '0');
        group_cnt         <= (others => '0');
        bit_cnt           <= (others => '0');
        offset_delta      <= (others => '0');
      end if;

      if axi_out_wren = '1' then
        if ldpc_next_reg = '1' then
          bit_cnt     <= bit_cnt + 1;
          reset_delta <= '0';
          if reset_delta = '1' or offset_delta + metadata.q = table_length then
            offset_delta <= (others => '0');
          else
            offset_delta <= offset_delta + metadata.q;
          end if;
        end if;
      end if;

      if busy = '1' then
        table_addr <= table_addr + 1;
        row_cnt    <= row_cnt + 1;

        last_row : if row_cnt = row_cnt_max then
          row_cnt    <= (others => '0');
          ldpc_next  <= '1';
          -- Re-read this address range
          table_addr <= metadata.addr;

          group_cnt   <= group_cnt + 1;

          -- Handle end of the 360 entries group
          end_of_group : if group_cnt = DVB_LDPC_GROUP_LENGTH - 1 then
            group_cnt       <= (others => '0');
            loop_cnt        <= loop_cnt + 1;
            table_addr      <= table_addr + 1;
            reset_delta     <= '1';

            -- Once we iterated enough times over this range, let the address increment
            -- but store the point where that happened so we can do the same thing with
            -- a different base address
            metadata.addr   <= table_addr + 1;

            if loop_cnt = loop_cnt_max then
              loop_cnt      <= (others => '0');

              if stage = 0 then
                stage      <= stage + 1;
              else
                stage      <= (others => '0');
                busy       <= '0';
                axi_tready <= '1';
              end if;
            end if;
          end if end_of_group;
        end if last_row;
      end if;
    end if;
  end process;

end axi_ldpc_table;
