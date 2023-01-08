----------------------------------------------------------------------------------------------------
-- 'dvbs2_encoder' Register Component
-- Revision: 347
----------------------------------------------------------------------------------------------------
-- Generated on 2023-01-08 at 17:59 (UTC) by airhdl version 2023.01.1-740440560
----------------------------------------------------------------------------------------------------
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.dvbs2_encoder_regs_pkg.all;

entity dvbs2_encoder_regs is
    generic(
        AXI_ADDR_WIDTH : integer := 32;  -- width of the AXI address bus
        BASEADDR : std_logic_vector(31 downto 0) := x"00000000" -- the register file's system base address
    );
    port(
        -- Clock and Reset
        axi_aclk    : in  std_logic;
        axi_aresetn : in  std_logic;
        -- AXI Write Address Channel
        s_axi_awaddr  : in  std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
        s_axi_awprot  : in  std_logic_vector(2 downto 0); -- sigasi @suppress "Unused port"
        s_axi_awvalid : in  std_logic;
        s_axi_awready : out std_logic;
        -- AXI Write Data Channel
        s_axi_wdata   : in  std_logic_vector(31 downto 0);
        s_axi_wstrb   : in  std_logic_vector(3 downto 0);
        s_axi_wvalid  : in  std_logic;
        s_axi_wready  : out std_logic;
        -- AXI Read Address Channel
        s_axi_araddr  : in  std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
        s_axi_arprot  : in  std_logic_vector(2 downto 0); -- sigasi @suppress "Unused port"
        s_axi_arvalid : in  std_logic;
        s_axi_arready : out std_logic;
        -- AXI Read Data Channel
        s_axi_rdata   : out std_logic_vector(31 downto 0);
        s_axi_rresp   : out std_logic_vector(1 downto 0);
        s_axi_rvalid  : out std_logic;
        s_axi_rready  : in  std_logic;
        -- AXI Write Response Channel
        s_axi_bresp   : out std_logic_vector(1 downto 0);
        s_axi_bvalid  : out std_logic;
        s_axi_bready  : in  std_logic;
        -- User Ports
        user2regs     : in user2regs_t;
        regs2user     : out regs2user_t
    );
end entity dvbs2_encoder_regs;

architecture RTL of dvbs2_encoder_regs is

    ------------------------------------------------------------------------------------------------
    -- Constants
    ------------------------------------------------------------------------------------------------

    constant AXI_OKAY           : std_logic_vector(1 downto 0) := "00";
    constant AXI_SLVERR         : std_logic_vector(1 downto 0) := "10";

    ------------------------------------------------------------------------------------------------
    -- Signals
    ------------------------------------------------------------------------------------------------

    -- Registered signals
    signal s_axi_awready_r    : std_logic;
    signal s_axi_wready_r     : std_logic;
    signal s_axi_awaddr_reg_r : unsigned(s_axi_awaddr'range);
    signal s_axi_bvalid_r     : std_logic;
    signal s_axi_bresp_r      : std_logic_vector(s_axi_bresp'range);
    signal s_axi_arready_r    : std_logic;
    signal s_axi_araddr_reg_r : unsigned(AXI_ADDR_WIDTH - 1 downto 0);
    signal s_axi_rvalid_r     : std_logic;
    signal s_axi_rresp_r      : std_logic_vector(s_axi_rresp'range);
    signal s_axi_wdata_reg_r  : std_logic_vector(s_axi_wdata'range);
    signal s_axi_wstrb_reg_r  : std_logic_vector(s_axi_wstrb'range);
    signal s_axi_rdata_r      : std_logic_vector(s_axi_rdata'range);

    -- User-defined registers
    signal s_config_strobe_r : std_logic;
    signal s_reg_config_physical_layer_scrambler_shift_reg_init_r : std_logic_vector(17 downto 0);
    signal s_reg_config_enable_dummy_frames_r : std_logic_vector(0 downto 0);
    signal s_reg_config_swap_input_data_byte_endianness_r : std_logic_vector(0 downto 0);
    signal s_reg_config_swap_output_data_byte_endianness_r : std_logic_vector(0 downto 0);
    signal s_reg_config_force_output_ready_r : std_logic_vector(0 downto 0);
    signal s_ldpc_fifo_status_strobe_r : std_logic;
    signal s_reg_ldpc_fifo_status_ldpc_fifo_entries : std_logic_vector(13 downto 0);
    signal s_reg_ldpc_fifo_status_ldpc_fifo_empty : std_logic_vector(0 downto 0);
    signal s_reg_ldpc_fifo_status_ldpc_fifo_full : std_logic_vector(0 downto 0);
    signal s_reg_ldpc_fifo_status_arbiter_selected : std_logic_vector(1 downto 0);
    signal s_frames_in_transit_strobe_r : std_logic;
    signal s_reg_frames_in_transit_value : std_logic_vector(7 downto 0);
    signal s_constellation_map_radius_ram_raddr_r : std_logic_vector(4 downto 0);
    signal s_constellation_map_radius_ram_ren_r : std_logic;
    signal s_constellation_map_radius_ram_rdata : std_logic_vector(31 downto 0);
    signal s_constellation_map_radius_ram_waddr_r : std_logic_vector(4 downto 0);
    signal s_constellation_map_radius_ram_wen_r : std_logic_vector(3 downto 0);
    signal s_constellation_map_radius_ram_wdata_r : std_logic_vector(31 downto 0);
    signal s_constellation_map_iq_ram_raddr_r : std_logic_vector(5 downto 0);
    signal s_constellation_map_iq_ram_ren_r : std_logic;
    signal s_constellation_map_iq_ram_rdata : std_logic_vector(31 downto 0);
    signal s_constellation_map_iq_ram_waddr_r : std_logic_vector(5 downto 0);
    signal s_constellation_map_iq_ram_wen_r : std_logic_vector(3 downto 0);
    signal s_constellation_map_iq_ram_wdata_r : std_logic_vector(31 downto 0);
    signal s_axi_debug_input_width_converter_cfg_strobe_r : std_logic;
    signal s_reg_axi_debug_input_width_converter_cfg_block_data_r : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_input_width_converter_cfg_allow_word_r : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_input_width_converter_cfg_allow_frame_r : std_logic_vector(0 downto 0);
    signal s_axi_debug_input_width_converter_frame_count_strobe_r : std_logic;
    signal s_reg_axi_debug_input_width_converter_frame_count_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_input_width_converter_last_frame_length_strobe_r : std_logic;
    signal s_reg_axi_debug_input_width_converter_last_frame_length_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_input_width_converter_min_max_frame_length_strobe_r : std_logic;
    signal s_reg_axi_debug_input_width_converter_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0);
    signal s_reg_axi_debug_input_width_converter_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0);
    signal s_axi_debug_input_width_converter_word_count_strobe_r : std_logic;
    signal s_reg_axi_debug_input_width_converter_word_count_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_input_width_converter_strobes_strobe_r : std_logic;
    signal s_reg_axi_debug_input_width_converter_strobes_s_tvalid : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_input_width_converter_strobes_s_tready : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_input_width_converter_strobes_m_tvalid : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_input_width_converter_strobes_m_tready : std_logic_vector(0 downto 0);
    signal s_axi_debug_bb_scrambler_cfg_strobe_r : std_logic;
    signal s_reg_axi_debug_bb_scrambler_cfg_block_data_r : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bb_scrambler_cfg_allow_word_r : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r : std_logic_vector(0 downto 0);
    signal s_axi_debug_bb_scrambler_frame_count_strobe_r : std_logic;
    signal s_reg_axi_debug_bb_scrambler_frame_count_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_bb_scrambler_last_frame_length_strobe_r : std_logic;
    signal s_reg_axi_debug_bb_scrambler_last_frame_length_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r : std_logic;
    signal s_reg_axi_debug_bb_scrambler_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0);
    signal s_reg_axi_debug_bb_scrambler_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0);
    signal s_axi_debug_bb_scrambler_word_count_strobe_r : std_logic;
    signal s_reg_axi_debug_bb_scrambler_word_count_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_bb_scrambler_strobes_strobe_r : std_logic;
    signal s_reg_axi_debug_bb_scrambler_strobes_s_tvalid : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bb_scrambler_strobes_s_tready : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bb_scrambler_strobes_m_tvalid : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bb_scrambler_strobes_m_tready : std_logic_vector(0 downto 0);
    signal s_axi_debug_bch_encoder_cfg_strobe_r : std_logic;
    signal s_reg_axi_debug_bch_encoder_cfg_block_data_r : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bch_encoder_cfg_allow_word_r : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bch_encoder_cfg_allow_frame_r : std_logic_vector(0 downto 0);
    signal s_axi_debug_bch_encoder_frame_count_strobe_r : std_logic;
    signal s_reg_axi_debug_bch_encoder_frame_count_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_bch_encoder_last_frame_length_strobe_r : std_logic;
    signal s_reg_axi_debug_bch_encoder_last_frame_length_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_bch_encoder_min_max_frame_length_strobe_r : std_logic;
    signal s_reg_axi_debug_bch_encoder_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0);
    signal s_reg_axi_debug_bch_encoder_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0);
    signal s_axi_debug_bch_encoder_word_count_strobe_r : std_logic;
    signal s_reg_axi_debug_bch_encoder_word_count_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_bch_encoder_strobes_strobe_r : std_logic;
    signal s_reg_axi_debug_bch_encoder_strobes_s_tvalid : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bch_encoder_strobes_s_tready : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bch_encoder_strobes_m_tvalid : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bch_encoder_strobes_m_tready : std_logic_vector(0 downto 0);
    signal s_axi_debug_ldpc_encoder_cfg_strobe_r : std_logic;
    signal s_reg_axi_debug_ldpc_encoder_cfg_block_data_r : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r : std_logic_vector(0 downto 0);
    signal s_axi_debug_ldpc_encoder_frame_count_strobe_r : std_logic;
    signal s_reg_axi_debug_ldpc_encoder_frame_count_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_ldpc_encoder_last_frame_length_strobe_r : std_logic;
    signal s_reg_axi_debug_ldpc_encoder_last_frame_length_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r : std_logic;
    signal s_reg_axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0);
    signal s_reg_axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0);
    signal s_axi_debug_ldpc_encoder_word_count_strobe_r : std_logic;
    signal s_reg_axi_debug_ldpc_encoder_word_count_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_ldpc_encoder_strobes_strobe_r : std_logic;
    signal s_reg_axi_debug_ldpc_encoder_strobes_s_tvalid : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_ldpc_encoder_strobes_s_tready : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_ldpc_encoder_strobes_m_tvalid : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_ldpc_encoder_strobes_m_tready : std_logic_vector(0 downto 0);
    signal s_axi_debug_bit_interleaver_cfg_strobe_r : std_logic;
    signal s_reg_axi_debug_bit_interleaver_cfg_block_data_r : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bit_interleaver_cfg_allow_word_r : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r : std_logic_vector(0 downto 0);
    signal s_axi_debug_bit_interleaver_frame_count_strobe_r : std_logic;
    signal s_reg_axi_debug_bit_interleaver_frame_count_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_bit_interleaver_last_frame_length_strobe_r : std_logic;
    signal s_reg_axi_debug_bit_interleaver_last_frame_length_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r : std_logic;
    signal s_reg_axi_debug_bit_interleaver_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0);
    signal s_reg_axi_debug_bit_interleaver_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0);
    signal s_axi_debug_bit_interleaver_word_count_strobe_r : std_logic;
    signal s_reg_axi_debug_bit_interleaver_word_count_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_bit_interleaver_strobes_strobe_r : std_logic;
    signal s_reg_axi_debug_bit_interleaver_strobes_s_tvalid : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bit_interleaver_strobes_s_tready : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bit_interleaver_strobes_m_tvalid : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_bit_interleaver_strobes_m_tready : std_logic_vector(0 downto 0);
    signal s_axi_debug_constellation_mapper_cfg_strobe_r : std_logic;
    signal s_reg_axi_debug_constellation_mapper_cfg_block_data_r : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_constellation_mapper_cfg_allow_word_r : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_constellation_mapper_cfg_allow_frame_r : std_logic_vector(0 downto 0);
    signal s_axi_debug_constellation_mapper_frame_count_strobe_r : std_logic;
    signal s_reg_axi_debug_constellation_mapper_frame_count_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_constellation_mapper_last_frame_length_strobe_r : std_logic;
    signal s_reg_axi_debug_constellation_mapper_last_frame_length_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_constellation_mapper_min_max_frame_length_strobe_r : std_logic;
    signal s_reg_axi_debug_constellation_mapper_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0);
    signal s_reg_axi_debug_constellation_mapper_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0);
    signal s_axi_debug_constellation_mapper_word_count_strobe_r : std_logic;
    signal s_reg_axi_debug_constellation_mapper_word_count_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_constellation_mapper_strobes_strobe_r : std_logic;
    signal s_reg_axi_debug_constellation_mapper_strobes_s_tvalid : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_constellation_mapper_strobes_s_tready : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_constellation_mapper_strobes_m_tvalid : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_constellation_mapper_strobes_m_tready : std_logic_vector(0 downto 0);
    signal s_axi_debug_plframe_cfg_strobe_r : std_logic;
    signal s_reg_axi_debug_plframe_cfg_block_data_r : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_plframe_cfg_allow_word_r : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_plframe_cfg_allow_frame_r : std_logic_vector(0 downto 0);
    signal s_axi_debug_plframe_frame_count_strobe_r : std_logic;
    signal s_reg_axi_debug_plframe_frame_count_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_plframe_last_frame_length_strobe_r : std_logic;
    signal s_reg_axi_debug_plframe_last_frame_length_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_plframe_min_max_frame_length_strobe_r : std_logic;
    signal s_reg_axi_debug_plframe_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0);
    signal s_reg_axi_debug_plframe_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0);
    signal s_axi_debug_plframe_word_count_strobe_r : std_logic;
    signal s_reg_axi_debug_plframe_word_count_value : std_logic_vector(15 downto 0);
    signal s_axi_debug_plframe_strobes_strobe_r : std_logic;
    signal s_reg_axi_debug_plframe_strobes_s_tvalid : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_plframe_strobes_s_tready : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_plframe_strobes_m_tvalid : std_logic_vector(0 downto 0);
    signal s_reg_axi_debug_plframe_strobes_m_tready : std_logic_vector(0 downto 0);

begin

    ------------------------------------------------------------------------------------------------
    -- Inputs
    ------------------------------------------------------------------------------------------------

    s_reg_ldpc_fifo_status_ldpc_fifo_entries <= user2regs.ldpc_fifo_status_ldpc_fifo_entries;
    s_reg_ldpc_fifo_status_ldpc_fifo_empty <= user2regs.ldpc_fifo_status_ldpc_fifo_empty;
    s_reg_ldpc_fifo_status_ldpc_fifo_full <= user2regs.ldpc_fifo_status_ldpc_fifo_full;
    s_reg_ldpc_fifo_status_arbiter_selected <= user2regs.ldpc_fifo_status_arbiter_selected;
    s_reg_frames_in_transit_value <= user2regs.frames_in_transit_value;
    s_constellation_map_radius_ram_rdata <= user2regs.constellation_map_radius_ram_rdata;
    s_constellation_map_iq_ram_rdata <= user2regs.constellation_map_iq_ram_rdata;
    s_reg_axi_debug_input_width_converter_frame_count_value <= user2regs.axi_debug_input_width_converter_frame_count_value;
    s_reg_axi_debug_input_width_converter_last_frame_length_value <= user2regs.axi_debug_input_width_converter_last_frame_length_value;
    s_reg_axi_debug_input_width_converter_min_max_frame_length_min_frame_length <= user2regs.axi_debug_input_width_converter_min_max_frame_length_min_frame_length;
    s_reg_axi_debug_input_width_converter_min_max_frame_length_max_frame_length <= user2regs.axi_debug_input_width_converter_min_max_frame_length_max_frame_length;
    s_reg_axi_debug_input_width_converter_word_count_value <= user2regs.axi_debug_input_width_converter_word_count_value;
    s_reg_axi_debug_input_width_converter_strobes_s_tvalid <= user2regs.axi_debug_input_width_converter_strobes_s_tvalid;
    s_reg_axi_debug_input_width_converter_strobes_s_tready <= user2regs.axi_debug_input_width_converter_strobes_s_tready;
    s_reg_axi_debug_input_width_converter_strobes_m_tvalid <= user2regs.axi_debug_input_width_converter_strobes_m_tvalid;
    s_reg_axi_debug_input_width_converter_strobes_m_tready <= user2regs.axi_debug_input_width_converter_strobes_m_tready;
    s_reg_axi_debug_bb_scrambler_frame_count_value <= user2regs.axi_debug_bb_scrambler_frame_count_value;
    s_reg_axi_debug_bb_scrambler_last_frame_length_value <= user2regs.axi_debug_bb_scrambler_last_frame_length_value;
    s_reg_axi_debug_bb_scrambler_min_max_frame_length_min_frame_length <= user2regs.axi_debug_bb_scrambler_min_max_frame_length_min_frame_length;
    s_reg_axi_debug_bb_scrambler_min_max_frame_length_max_frame_length <= user2regs.axi_debug_bb_scrambler_min_max_frame_length_max_frame_length;
    s_reg_axi_debug_bb_scrambler_word_count_value <= user2regs.axi_debug_bb_scrambler_word_count_value;
    s_reg_axi_debug_bb_scrambler_strobes_s_tvalid <= user2regs.axi_debug_bb_scrambler_strobes_s_tvalid;
    s_reg_axi_debug_bb_scrambler_strobes_s_tready <= user2regs.axi_debug_bb_scrambler_strobes_s_tready;
    s_reg_axi_debug_bb_scrambler_strobes_m_tvalid <= user2regs.axi_debug_bb_scrambler_strobes_m_tvalid;
    s_reg_axi_debug_bb_scrambler_strobes_m_tready <= user2regs.axi_debug_bb_scrambler_strobes_m_tready;
    s_reg_axi_debug_bch_encoder_frame_count_value <= user2regs.axi_debug_bch_encoder_frame_count_value;
    s_reg_axi_debug_bch_encoder_last_frame_length_value <= user2regs.axi_debug_bch_encoder_last_frame_length_value;
    s_reg_axi_debug_bch_encoder_min_max_frame_length_min_frame_length <= user2regs.axi_debug_bch_encoder_min_max_frame_length_min_frame_length;
    s_reg_axi_debug_bch_encoder_min_max_frame_length_max_frame_length <= user2regs.axi_debug_bch_encoder_min_max_frame_length_max_frame_length;
    s_reg_axi_debug_bch_encoder_word_count_value <= user2regs.axi_debug_bch_encoder_word_count_value;
    s_reg_axi_debug_bch_encoder_strobes_s_tvalid <= user2regs.axi_debug_bch_encoder_strobes_s_tvalid;
    s_reg_axi_debug_bch_encoder_strobes_s_tready <= user2regs.axi_debug_bch_encoder_strobes_s_tready;
    s_reg_axi_debug_bch_encoder_strobes_m_tvalid <= user2regs.axi_debug_bch_encoder_strobes_m_tvalid;
    s_reg_axi_debug_bch_encoder_strobes_m_tready <= user2regs.axi_debug_bch_encoder_strobes_m_tready;
    s_reg_axi_debug_ldpc_encoder_frame_count_value <= user2regs.axi_debug_ldpc_encoder_frame_count_value;
    s_reg_axi_debug_ldpc_encoder_last_frame_length_value <= user2regs.axi_debug_ldpc_encoder_last_frame_length_value;
    s_reg_axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length <= user2regs.axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length;
    s_reg_axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length <= user2regs.axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length;
    s_reg_axi_debug_ldpc_encoder_word_count_value <= user2regs.axi_debug_ldpc_encoder_word_count_value;
    s_reg_axi_debug_ldpc_encoder_strobes_s_tvalid <= user2regs.axi_debug_ldpc_encoder_strobes_s_tvalid;
    s_reg_axi_debug_ldpc_encoder_strobes_s_tready <= user2regs.axi_debug_ldpc_encoder_strobes_s_tready;
    s_reg_axi_debug_ldpc_encoder_strobes_m_tvalid <= user2regs.axi_debug_ldpc_encoder_strobes_m_tvalid;
    s_reg_axi_debug_ldpc_encoder_strobes_m_tready <= user2regs.axi_debug_ldpc_encoder_strobes_m_tready;
    s_reg_axi_debug_bit_interleaver_frame_count_value <= user2regs.axi_debug_bit_interleaver_frame_count_value;
    s_reg_axi_debug_bit_interleaver_last_frame_length_value <= user2regs.axi_debug_bit_interleaver_last_frame_length_value;
    s_reg_axi_debug_bit_interleaver_min_max_frame_length_min_frame_length <= user2regs.axi_debug_bit_interleaver_min_max_frame_length_min_frame_length;
    s_reg_axi_debug_bit_interleaver_min_max_frame_length_max_frame_length <= user2regs.axi_debug_bit_interleaver_min_max_frame_length_max_frame_length;
    s_reg_axi_debug_bit_interleaver_word_count_value <= user2regs.axi_debug_bit_interleaver_word_count_value;
    s_reg_axi_debug_bit_interleaver_strobes_s_tvalid <= user2regs.axi_debug_bit_interleaver_strobes_s_tvalid;
    s_reg_axi_debug_bit_interleaver_strobes_s_tready <= user2regs.axi_debug_bit_interleaver_strobes_s_tready;
    s_reg_axi_debug_bit_interleaver_strobes_m_tvalid <= user2regs.axi_debug_bit_interleaver_strobes_m_tvalid;
    s_reg_axi_debug_bit_interleaver_strobes_m_tready <= user2regs.axi_debug_bit_interleaver_strobes_m_tready;
    s_reg_axi_debug_constellation_mapper_frame_count_value <= user2regs.axi_debug_constellation_mapper_frame_count_value;
    s_reg_axi_debug_constellation_mapper_last_frame_length_value <= user2regs.axi_debug_constellation_mapper_last_frame_length_value;
    s_reg_axi_debug_constellation_mapper_min_max_frame_length_min_frame_length <= user2regs.axi_debug_constellation_mapper_min_max_frame_length_min_frame_length;
    s_reg_axi_debug_constellation_mapper_min_max_frame_length_max_frame_length <= user2regs.axi_debug_constellation_mapper_min_max_frame_length_max_frame_length;
    s_reg_axi_debug_constellation_mapper_word_count_value <= user2regs.axi_debug_constellation_mapper_word_count_value;
    s_reg_axi_debug_constellation_mapper_strobes_s_tvalid <= user2regs.axi_debug_constellation_mapper_strobes_s_tvalid;
    s_reg_axi_debug_constellation_mapper_strobes_s_tready <= user2regs.axi_debug_constellation_mapper_strobes_s_tready;
    s_reg_axi_debug_constellation_mapper_strobes_m_tvalid <= user2regs.axi_debug_constellation_mapper_strobes_m_tvalid;
    s_reg_axi_debug_constellation_mapper_strobes_m_tready <= user2regs.axi_debug_constellation_mapper_strobes_m_tready;
    s_reg_axi_debug_plframe_frame_count_value <= user2regs.axi_debug_plframe_frame_count_value;
    s_reg_axi_debug_plframe_last_frame_length_value <= user2regs.axi_debug_plframe_last_frame_length_value;
    s_reg_axi_debug_plframe_min_max_frame_length_min_frame_length <= user2regs.axi_debug_plframe_min_max_frame_length_min_frame_length;
    s_reg_axi_debug_plframe_min_max_frame_length_max_frame_length <= user2regs.axi_debug_plframe_min_max_frame_length_max_frame_length;
    s_reg_axi_debug_plframe_word_count_value <= user2regs.axi_debug_plframe_word_count_value;
    s_reg_axi_debug_plframe_strobes_s_tvalid <= user2regs.axi_debug_plframe_strobes_s_tvalid;
    s_reg_axi_debug_plframe_strobes_s_tready <= user2regs.axi_debug_plframe_strobes_s_tready;
    s_reg_axi_debug_plframe_strobes_m_tvalid <= user2regs.axi_debug_plframe_strobes_m_tvalid;
    s_reg_axi_debug_plframe_strobes_m_tready <= user2regs.axi_debug_plframe_strobes_m_tready;

    ------------------------------------------------------------------------------------------------
    -- Read-transaction FSM
    ------------------------------------------------------------------------------------------------

    read_fsm : process(axi_aclk, axi_aresetn) is
        constant MAX_MEMORY_LATENCY : natural := 5;
        type t_state is (IDLE, READ_REGISTER, WAIT_MEMORY_RDATA, READ_RESPONSE, DONE);
        -- registered state variables
        variable v_state_r          : t_state;
        variable v_rdata_r          : std_logic_vector(31 downto 0);
        variable v_rresp_r          : std_logic_vector(s_axi_rresp'range);
        variable v_mem_wait_count_r : natural range 0 to MAX_MEMORY_LATENCY;
        -- combinatorial helper variables
        variable v_addr_hit : boolean;
        variable v_mem_addr : unsigned(AXI_ADDR_WIDTH-1 downto 0);
    begin
        if axi_aresetn = '0' then
            v_state_r          := IDLE;
            v_rdata_r          := (others => '0');
            v_rresp_r          := (others => '0');
            v_mem_wait_count_r := 0;
            s_axi_arready_r    <= '0';
            s_axi_rvalid_r     <= '0';
            s_axi_rresp_r      <= (others => '0');
            s_axi_araddr_reg_r <= (others => '0');
            s_axi_rdata_r      <= (others => '0');
            s_ldpc_fifo_status_strobe_r <= '0';
            s_frames_in_transit_strobe_r <= '0';
            s_constellation_map_radius_ram_raddr_r <= (others => '0');
            s_constellation_map_radius_ram_ren_r <= '0';
            s_constellation_map_iq_ram_raddr_r <= (others => '0');
            s_constellation_map_iq_ram_ren_r <= '0';
            s_axi_debug_input_width_converter_frame_count_strobe_r <= '0';
            s_axi_debug_input_width_converter_last_frame_length_strobe_r <= '0';
            s_axi_debug_input_width_converter_min_max_frame_length_strobe_r <= '0';
            s_axi_debug_input_width_converter_word_count_strobe_r <= '0';
            s_axi_debug_input_width_converter_strobes_strobe_r <= '0';
            s_axi_debug_bb_scrambler_frame_count_strobe_r <= '0';
            s_axi_debug_bb_scrambler_last_frame_length_strobe_r <= '0';
            s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r <= '0';
            s_axi_debug_bb_scrambler_word_count_strobe_r <= '0';
            s_axi_debug_bb_scrambler_strobes_strobe_r <= '0';
            s_axi_debug_bch_encoder_frame_count_strobe_r <= '0';
            s_axi_debug_bch_encoder_last_frame_length_strobe_r <= '0';
            s_axi_debug_bch_encoder_min_max_frame_length_strobe_r <= '0';
            s_axi_debug_bch_encoder_word_count_strobe_r <= '0';
            s_axi_debug_bch_encoder_strobes_strobe_r <= '0';
            s_axi_debug_ldpc_encoder_frame_count_strobe_r <= '0';
            s_axi_debug_ldpc_encoder_last_frame_length_strobe_r <= '0';
            s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r <= '0';
            s_axi_debug_ldpc_encoder_word_count_strobe_r <= '0';
            s_axi_debug_ldpc_encoder_strobes_strobe_r <= '0';
            s_axi_debug_bit_interleaver_frame_count_strobe_r <= '0';
            s_axi_debug_bit_interleaver_last_frame_length_strobe_r <= '0';
            s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r <= '0';
            s_axi_debug_bit_interleaver_word_count_strobe_r <= '0';
            s_axi_debug_bit_interleaver_strobes_strobe_r <= '0';
            s_axi_debug_constellation_mapper_frame_count_strobe_r <= '0';
            s_axi_debug_constellation_mapper_last_frame_length_strobe_r <= '0';
            s_axi_debug_constellation_mapper_min_max_frame_length_strobe_r <= '0';
            s_axi_debug_constellation_mapper_word_count_strobe_r <= '0';
            s_axi_debug_constellation_mapper_strobes_strobe_r <= '0';
            s_axi_debug_plframe_frame_count_strobe_r <= '0';
            s_axi_debug_plframe_last_frame_length_strobe_r <= '0';
            s_axi_debug_plframe_min_max_frame_length_strobe_r <= '0';
            s_axi_debug_plframe_word_count_strobe_r <= '0';
            s_axi_debug_plframe_strobes_strobe_r <= '0';

        elsif rising_edge(axi_aclk) then
            -- Default values:
            s_axi_arready_r <= '0';
            s_ldpc_fifo_status_strobe_r <= '0';
            s_frames_in_transit_strobe_r <= '0';
            s_constellation_map_radius_ram_raddr_r <= (others => '0');
            s_constellation_map_iq_ram_raddr_r <= (others => '0');
            s_axi_debug_input_width_converter_frame_count_strobe_r <= '0';
            s_axi_debug_input_width_converter_last_frame_length_strobe_r <= '0';
            s_axi_debug_input_width_converter_min_max_frame_length_strobe_r <= '0';
            s_axi_debug_input_width_converter_word_count_strobe_r <= '0';
            s_axi_debug_input_width_converter_strobes_strobe_r <= '0';
            s_axi_debug_bb_scrambler_frame_count_strobe_r <= '0';
            s_axi_debug_bb_scrambler_last_frame_length_strobe_r <= '0';
            s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r <= '0';
            s_axi_debug_bb_scrambler_word_count_strobe_r <= '0';
            s_axi_debug_bb_scrambler_strobes_strobe_r <= '0';
            s_axi_debug_bch_encoder_frame_count_strobe_r <= '0';
            s_axi_debug_bch_encoder_last_frame_length_strobe_r <= '0';
            s_axi_debug_bch_encoder_min_max_frame_length_strobe_r <= '0';
            s_axi_debug_bch_encoder_word_count_strobe_r <= '0';
            s_axi_debug_bch_encoder_strobes_strobe_r <= '0';
            s_axi_debug_ldpc_encoder_frame_count_strobe_r <= '0';
            s_axi_debug_ldpc_encoder_last_frame_length_strobe_r <= '0';
            s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r <= '0';
            s_axi_debug_ldpc_encoder_word_count_strobe_r <= '0';
            s_axi_debug_ldpc_encoder_strobes_strobe_r <= '0';
            s_axi_debug_bit_interleaver_frame_count_strobe_r <= '0';
            s_axi_debug_bit_interleaver_last_frame_length_strobe_r <= '0';
            s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r <= '0';
            s_axi_debug_bit_interleaver_word_count_strobe_r <= '0';
            s_axi_debug_bit_interleaver_strobes_strobe_r <= '0';
            s_axi_debug_constellation_mapper_frame_count_strobe_r <= '0';
            s_axi_debug_constellation_mapper_last_frame_length_strobe_r <= '0';
            s_axi_debug_constellation_mapper_min_max_frame_length_strobe_r <= '0';
            s_axi_debug_constellation_mapper_word_count_strobe_r <= '0';
            s_axi_debug_constellation_mapper_strobes_strobe_r <= '0';
            s_axi_debug_plframe_frame_count_strobe_r <= '0';
            s_axi_debug_plframe_last_frame_length_strobe_r <= '0';
            s_axi_debug_plframe_min_max_frame_length_strobe_r <= '0';
            s_axi_debug_plframe_word_count_strobe_r <= '0';
            s_axi_debug_plframe_strobes_strobe_r <= '0';

            case v_state_r is

                -- Wait for the start of a read transaction, which is initiated by the
                -- assertion of ARVALID
                when IDLE =>
                    if s_axi_arvalid = '1' then
                        s_axi_araddr_reg_r <= unsigned(s_axi_araddr); -- save the read address
                        s_axi_arready_r    <= '1'; -- acknowledge the read-address
                        v_state_r          := READ_REGISTER;
                    end if;

                -- Read from the actual storage element
                when READ_REGISTER =>
                    -- Defaults:
                    v_addr_hit := false;
                    v_rdata_r  := (others => '0');

                    -- Register  'config' at address offset 0x0
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + CONFIG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(17 downto 0) := s_reg_config_physical_layer_scrambler_shift_reg_init_r;
                        v_rdata_r(18 downto 18) := s_reg_config_enable_dummy_frames_r;
                        v_rdata_r(19 downto 19) := s_reg_config_swap_input_data_byte_endianness_r;
                        v_rdata_r(20 downto 20) := s_reg_config_swap_output_data_byte_endianness_r;
                        v_rdata_r(21 downto 21) := s_reg_config_force_output_ready_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'ldpc_fifo_status' at address offset 0x4
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + LDPC_FIFO_STATUS_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(13 downto 0) := s_reg_ldpc_fifo_status_ldpc_fifo_entries;
                        v_rdata_r(16 downto 16) := s_reg_ldpc_fifo_status_ldpc_fifo_empty;
                        v_rdata_r(17 downto 17) := s_reg_ldpc_fifo_status_ldpc_fifo_full;
                        v_rdata_r(21 downto 20) := s_reg_ldpc_fifo_status_arbiter_selected;
                        s_ldpc_fifo_status_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'frames_in_transit' at address offset 0x8
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + FRAMES_IN_TRANSIT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(7 downto 0) := s_reg_frames_in_transit_value;
                        s_frames_in_transit_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Memory 'constellation_map_radius_ram' at address offset 0x10
                    if s_axi_araddr_reg_r >= resize(unsigned(BASEADDR) + CONSTELLATION_MAP_RADIUS_RAM_OFFSET, AXI_ADDR_WIDTH) and
                        s_axi_araddr_reg_r < resize(unsigned(BASEADDR) + CONSTELLATION_MAP_RADIUS_RAM_OFFSET + CONSTELLATION_MAP_RADIUS_RAM_DEPTH * 4, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        -- Generate memory read address:
                        v_mem_addr := s_axi_araddr_reg_r - resize(unsigned(BASEADDR) + CONSTELLATION_MAP_RADIUS_RAM_OFFSET, AXI_ADDR_WIDTH);
                        s_constellation_map_radius_ram_raddr_r <= std_logic_vector(v_mem_addr(6 downto 2)); -- output address has 4-byte granularity
                        s_constellation_map_radius_ram_ren_r <= '1';
                        v_mem_wait_count_r := CONSTELLATION_MAP_RADIUS_RAM_READ_LATENCY;
                        v_state_r := WAIT_MEMORY_RDATA;
                    end if;
                    -- Memory 'constellation_map_iq_ram' at address offset 0x110
                    if s_axi_araddr_reg_r >= resize(unsigned(BASEADDR) + CONSTELLATION_MAP_IQ_RAM_OFFSET, AXI_ADDR_WIDTH) and
                        s_axi_araddr_reg_r < resize(unsigned(BASEADDR) + CONSTELLATION_MAP_IQ_RAM_OFFSET + CONSTELLATION_MAP_IQ_RAM_DEPTH * 4, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        -- Generate memory read address:
                        v_mem_addr := s_axi_araddr_reg_r - resize(unsigned(BASEADDR) + CONSTELLATION_MAP_IQ_RAM_OFFSET, AXI_ADDR_WIDTH);
                        s_constellation_map_iq_ram_raddr_r <= std_logic_vector(v_mem_addr(7 downto 2)); -- output address has 4-byte granularity
                        s_constellation_map_iq_ram_ren_r <= '1';
                        v_mem_wait_count_r := CONSTELLATION_MAP_IQ_RAM_READ_LATENCY;
                        v_state_r := WAIT_MEMORY_RDATA;
                    end if;
                    -- Register  'axi_debug_input_width_converter_cfg' at address offset 0xD00
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_axi_debug_input_width_converter_cfg_block_data_r;
                        v_rdata_r(1 downto 1) := s_reg_axi_debug_input_width_converter_cfg_allow_word_r;
                        v_rdata_r(2 downto 2) := s_reg_axi_debug_input_width_converter_cfg_allow_frame_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_input_width_converter_frame_count' at address offset 0xD04
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_input_width_converter_frame_count_value;
                        s_axi_debug_input_width_converter_frame_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_input_width_converter_last_frame_length' at address offset 0xD08
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_input_width_converter_last_frame_length_value;
                        s_axi_debug_input_width_converter_last_frame_length_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_input_width_converter_min_max_frame_length' at address offset 0xD0C
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_input_width_converter_min_max_frame_length_min_frame_length;
                        v_rdata_r(31 downto 16) := s_reg_axi_debug_input_width_converter_min_max_frame_length_max_frame_length;
                        s_axi_debug_input_width_converter_min_max_frame_length_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_input_width_converter_word_count' at address offset 0xD10
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_input_width_converter_word_count_value;
                        s_axi_debug_input_width_converter_word_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_input_width_converter_strobes' at address offset 0xD14
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_axi_debug_input_width_converter_strobes_s_tvalid;
                        v_rdata_r(1 downto 1) := s_reg_axi_debug_input_width_converter_strobes_s_tready;
                        v_rdata_r(2 downto 2) := s_reg_axi_debug_input_width_converter_strobes_m_tvalid;
                        v_rdata_r(3 downto 3) := s_reg_axi_debug_input_width_converter_strobes_m_tready;
                        s_axi_debug_input_width_converter_strobes_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bb_scrambler_cfg' at address offset 0xE00
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BB_SCRAMBLER_CFG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_axi_debug_bb_scrambler_cfg_block_data_r;
                        v_rdata_r(1 downto 1) := s_reg_axi_debug_bb_scrambler_cfg_allow_word_r;
                        v_rdata_r(2 downto 2) := s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bb_scrambler_frame_count' at address offset 0xE04
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_bb_scrambler_frame_count_value;
                        s_axi_debug_bb_scrambler_frame_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bb_scrambler_last_frame_length' at address offset 0xE08
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_bb_scrambler_last_frame_length_value;
                        s_axi_debug_bb_scrambler_last_frame_length_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bb_scrambler_min_max_frame_length' at address offset 0xE0C
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_bb_scrambler_min_max_frame_length_min_frame_length;
                        v_rdata_r(31 downto 16) := s_reg_axi_debug_bb_scrambler_min_max_frame_length_max_frame_length;
                        s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bb_scrambler_word_count' at address offset 0xE10
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_bb_scrambler_word_count_value;
                        s_axi_debug_bb_scrambler_word_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bb_scrambler_strobes' at address offset 0xE14
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BB_SCRAMBLER_STROBES_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_axi_debug_bb_scrambler_strobes_s_tvalid;
                        v_rdata_r(1 downto 1) := s_reg_axi_debug_bb_scrambler_strobes_s_tready;
                        v_rdata_r(2 downto 2) := s_reg_axi_debug_bb_scrambler_strobes_m_tvalid;
                        v_rdata_r(3 downto 3) := s_reg_axi_debug_bb_scrambler_strobes_m_tready;
                        s_axi_debug_bb_scrambler_strobes_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bch_encoder_cfg' at address offset 0xF00
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BCH_ENCODER_CFG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_axi_debug_bch_encoder_cfg_block_data_r;
                        v_rdata_r(1 downto 1) := s_reg_axi_debug_bch_encoder_cfg_allow_word_r;
                        v_rdata_r(2 downto 2) := s_reg_axi_debug_bch_encoder_cfg_allow_frame_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bch_encoder_frame_count' at address offset 0xF04
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_bch_encoder_frame_count_value;
                        s_axi_debug_bch_encoder_frame_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bch_encoder_last_frame_length' at address offset 0xF08
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_bch_encoder_last_frame_length_value;
                        s_axi_debug_bch_encoder_last_frame_length_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bch_encoder_min_max_frame_length' at address offset 0xF0C
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_bch_encoder_min_max_frame_length_min_frame_length;
                        v_rdata_r(31 downto 16) := s_reg_axi_debug_bch_encoder_min_max_frame_length_max_frame_length;
                        s_axi_debug_bch_encoder_min_max_frame_length_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bch_encoder_word_count' at address offset 0xF10
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BCH_ENCODER_WORD_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_bch_encoder_word_count_value;
                        s_axi_debug_bch_encoder_word_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bch_encoder_strobes' at address offset 0xF14
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BCH_ENCODER_STROBES_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_axi_debug_bch_encoder_strobes_s_tvalid;
                        v_rdata_r(1 downto 1) := s_reg_axi_debug_bch_encoder_strobes_s_tready;
                        v_rdata_r(2 downto 2) := s_reg_axi_debug_bch_encoder_strobes_m_tvalid;
                        v_rdata_r(3 downto 3) := s_reg_axi_debug_bch_encoder_strobes_m_tready;
                        s_axi_debug_bch_encoder_strobes_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_ldpc_encoder_cfg' at address offset 0x1000
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_LDPC_ENCODER_CFG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_axi_debug_ldpc_encoder_cfg_block_data_r;
                        v_rdata_r(1 downto 1) := s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r;
                        v_rdata_r(2 downto 2) := s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_ldpc_encoder_frame_count' at address offset 0x1004
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_ldpc_encoder_frame_count_value;
                        s_axi_debug_ldpc_encoder_frame_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_ldpc_encoder_last_frame_length' at address offset 0x1008
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_ldpc_encoder_last_frame_length_value;
                        s_axi_debug_ldpc_encoder_last_frame_length_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_ldpc_encoder_min_max_frame_length' at address offset 0x100C
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length;
                        v_rdata_r(31 downto 16) := s_reg_axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length;
                        s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_ldpc_encoder_word_count' at address offset 0x1010
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_ldpc_encoder_word_count_value;
                        s_axi_debug_ldpc_encoder_word_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_ldpc_encoder_strobes' at address offset 0x1014
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_LDPC_ENCODER_STROBES_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_axi_debug_ldpc_encoder_strobes_s_tvalid;
                        v_rdata_r(1 downto 1) := s_reg_axi_debug_ldpc_encoder_strobes_s_tready;
                        v_rdata_r(2 downto 2) := s_reg_axi_debug_ldpc_encoder_strobes_m_tvalid;
                        v_rdata_r(3 downto 3) := s_reg_axi_debug_ldpc_encoder_strobes_m_tready;
                        s_axi_debug_ldpc_encoder_strobes_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bit_interleaver_cfg' at address offset 0x1100
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BIT_INTERLEAVER_CFG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_axi_debug_bit_interleaver_cfg_block_data_r;
                        v_rdata_r(1 downto 1) := s_reg_axi_debug_bit_interleaver_cfg_allow_word_r;
                        v_rdata_r(2 downto 2) := s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bit_interleaver_frame_count' at address offset 0x1104
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_bit_interleaver_frame_count_value;
                        s_axi_debug_bit_interleaver_frame_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bit_interleaver_last_frame_length' at address offset 0x1108
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_bit_interleaver_last_frame_length_value;
                        s_axi_debug_bit_interleaver_last_frame_length_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bit_interleaver_min_max_frame_length' at address offset 0x110C
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_bit_interleaver_min_max_frame_length_min_frame_length;
                        v_rdata_r(31 downto 16) := s_reg_axi_debug_bit_interleaver_min_max_frame_length_max_frame_length;
                        s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bit_interleaver_word_count' at address offset 0x1110
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_bit_interleaver_word_count_value;
                        s_axi_debug_bit_interleaver_word_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_bit_interleaver_strobes' at address offset 0x1114
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BIT_INTERLEAVER_STROBES_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_axi_debug_bit_interleaver_strobes_s_tvalid;
                        v_rdata_r(1 downto 1) := s_reg_axi_debug_bit_interleaver_strobes_s_tready;
                        v_rdata_r(2 downto 2) := s_reg_axi_debug_bit_interleaver_strobes_m_tvalid;
                        v_rdata_r(3 downto 3) := s_reg_axi_debug_bit_interleaver_strobes_m_tready;
                        s_axi_debug_bit_interleaver_strobes_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_constellation_mapper_cfg' at address offset 0x1200
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_CONSTELLATION_MAPPER_CFG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_axi_debug_constellation_mapper_cfg_block_data_r;
                        v_rdata_r(1 downto 1) := s_reg_axi_debug_constellation_mapper_cfg_allow_word_r;
                        v_rdata_r(2 downto 2) := s_reg_axi_debug_constellation_mapper_cfg_allow_frame_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_constellation_mapper_frame_count' at address offset 0x1204
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_CONSTELLATION_MAPPER_FRAME_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_constellation_mapper_frame_count_value;
                        s_axi_debug_constellation_mapper_frame_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_constellation_mapper_last_frame_length' at address offset 0x1208
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_CONSTELLATION_MAPPER_LAST_FRAME_LENGTH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_constellation_mapper_last_frame_length_value;
                        s_axi_debug_constellation_mapper_last_frame_length_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_constellation_mapper_min_max_frame_length' at address offset 0x120C
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_constellation_mapper_min_max_frame_length_min_frame_length;
                        v_rdata_r(31 downto 16) := s_reg_axi_debug_constellation_mapper_min_max_frame_length_max_frame_length;
                        s_axi_debug_constellation_mapper_min_max_frame_length_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_constellation_mapper_word_count' at address offset 0x1210
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_CONSTELLATION_MAPPER_WORD_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_constellation_mapper_word_count_value;
                        s_axi_debug_constellation_mapper_word_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_constellation_mapper_strobes' at address offset 0x1214
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_axi_debug_constellation_mapper_strobes_s_tvalid;
                        v_rdata_r(1 downto 1) := s_reg_axi_debug_constellation_mapper_strobes_s_tready;
                        v_rdata_r(2 downto 2) := s_reg_axi_debug_constellation_mapper_strobes_m_tvalid;
                        v_rdata_r(3 downto 3) := s_reg_axi_debug_constellation_mapper_strobes_m_tready;
                        s_axi_debug_constellation_mapper_strobes_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_plframe_cfg' at address offset 0x1300
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_PLFRAME_CFG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_axi_debug_plframe_cfg_block_data_r;
                        v_rdata_r(1 downto 1) := s_reg_axi_debug_plframe_cfg_allow_word_r;
                        v_rdata_r(2 downto 2) := s_reg_axi_debug_plframe_cfg_allow_frame_r;
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_plframe_frame_count' at address offset 0x1304
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_PLFRAME_FRAME_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_plframe_frame_count_value;
                        s_axi_debug_plframe_frame_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_plframe_last_frame_length' at address offset 0x1308
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_plframe_last_frame_length_value;
                        s_axi_debug_plframe_last_frame_length_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_plframe_min_max_frame_length' at address offset 0x130C
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_plframe_min_max_frame_length_min_frame_length;
                        v_rdata_r(31 downto 16) := s_reg_axi_debug_plframe_min_max_frame_length_max_frame_length;
                        s_axi_debug_plframe_min_max_frame_length_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_plframe_word_count' at address offset 0x1310
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_PLFRAME_WORD_COUNT_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(15 downto 0) := s_reg_axi_debug_plframe_word_count_value;
                        s_axi_debug_plframe_word_count_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    -- Register  'axi_debug_plframe_strobes' at address offset 0x1314
                    if s_axi_araddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_PLFRAME_STROBES_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        v_rdata_r(0 downto 0) := s_reg_axi_debug_plframe_strobes_s_tvalid;
                        v_rdata_r(1 downto 1) := s_reg_axi_debug_plframe_strobes_s_tready;
                        v_rdata_r(2 downto 2) := s_reg_axi_debug_plframe_strobes_m_tvalid;
                        v_rdata_r(3 downto 3) := s_reg_axi_debug_plframe_strobes_m_tready;
                        s_axi_debug_plframe_strobes_strobe_r <= '1';
                        v_state_r := READ_RESPONSE;
                    end if;
                    --
                    if v_addr_hit then
                        v_rresp_r := AXI_OKAY;
                    else
                        v_rresp_r := AXI_SLVERR;
                        -- pragma translate_off
                        report "ARADDR decode error" severity warning;
                        -- pragma translate_on
                        v_state_r := READ_RESPONSE;
                    end if;

                -- Wait for memory read data
                when WAIT_MEMORY_RDATA =>
                    if v_mem_wait_count_r = 0 then
                        -- memory 'constellation_map_radius_ram' at address offset 0x10
                        if s_axi_araddr_reg_r >= resize(unsigned(BASEADDR) + CONSTELLATION_MAP_RADIUS_RAM_OFFSET, AXI_ADDR_WIDTH) and
                            s_axi_araddr_reg_r < resize(unsigned(BASEADDR) + CONSTELLATION_MAP_RADIUS_RAM_OFFSET + CONSTELLATION_MAP_RADIUS_RAM_DEPTH * 4, AXI_ADDR_WIDTH) then
                            v_rdata_r(31 downto 0) := s_constellation_map_radius_ram_rdata(31 downto 0);
                            s_constellation_map_radius_ram_ren_r <= '0';
                        end if;
                        -- memory 'constellation_map_iq_ram' at address offset 0x110
                        if s_axi_araddr_reg_r >= resize(unsigned(BASEADDR) + CONSTELLATION_MAP_IQ_RAM_OFFSET, AXI_ADDR_WIDTH) and
                            s_axi_araddr_reg_r < resize(unsigned(BASEADDR) + CONSTELLATION_MAP_IQ_RAM_OFFSET + CONSTELLATION_MAP_IQ_RAM_DEPTH * 4, AXI_ADDR_WIDTH) then
                            v_rdata_r(31 downto 0) := s_constellation_map_iq_ram_rdata(31 downto 0);
                            s_constellation_map_iq_ram_ren_r <= '0';
                        end if;
                        v_state_r      := READ_RESPONSE;
                    else
                        v_mem_wait_count_r := v_mem_wait_count_r - 1;
                    end if;

                -- Generate read response
                when READ_RESPONSE =>
                    s_axi_rvalid_r <= '1';
                    s_axi_rresp_r  <= v_rresp_r;
                    s_axi_rdata_r  <= v_rdata_r;
                    --
                    v_state_r      := DONE;

                -- Write transaction completed, wait for master RREADY to proceed
                when DONE =>
                    if s_axi_rready = '1' then
                        s_axi_rvalid_r <= '0';
                        s_axi_rdata_r   <= (others => '0');
                        v_state_r      := IDLE;
                    end if;
            end case;
        end if;
    end process read_fsm;

    ------------------------------------------------------------------------------------------------
    -- Write-transaction FSM
    ------------------------------------------------------------------------------------------------

    write_fsm : process(axi_aclk, axi_aresetn) is
        type t_state is (IDLE, ADDR_FIRST, DATA_FIRST, UPDATE_REGISTER, DONE);
        variable v_state_r  : t_state;
        variable v_addr_hit : boolean;
        variable v_mem_addr : unsigned(AXI_ADDR_WIDTH-1 downto 0);
    begin
        if axi_aresetn = '0' then
            v_state_r          := IDLE;
            s_axi_awready_r    <= '0';
            s_axi_wready_r     <= '0';
            s_axi_awaddr_reg_r <= (others => '0');
            s_axi_wdata_reg_r  <= (others => '0');
            s_axi_wstrb_reg_r  <= (others => '0');
            s_axi_bvalid_r     <= '0';
            s_axi_bresp_r      <= (others => '0');
            --
            s_config_strobe_r <= '0';
            s_reg_config_physical_layer_scrambler_shift_reg_init_r <= CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_RESET;
            s_reg_config_enable_dummy_frames_r <= CONFIG_ENABLE_DUMMY_FRAMES_RESET;
            s_reg_config_swap_input_data_byte_endianness_r <= CONFIG_SWAP_INPUT_DATA_BYTE_ENDIANNESS_RESET;
            s_reg_config_swap_output_data_byte_endianness_r <= CONFIG_SWAP_OUTPUT_DATA_BYTE_ENDIANNESS_RESET;
            s_reg_config_force_output_ready_r <= CONFIG_FORCE_OUTPUT_READY_RESET;
            s_constellation_map_radius_ram_waddr_r <= (others => '0');
            s_constellation_map_radius_ram_wen_r <= (others => '0');
            s_constellation_map_radius_ram_wdata_r <= (others => '0');
            s_constellation_map_iq_ram_waddr_r <= (others => '0');
            s_constellation_map_iq_ram_wen_r <= (others => '0');
            s_constellation_map_iq_ram_wdata_r <= (others => '0');
            s_axi_debug_input_width_converter_cfg_strobe_r <= '0';
            s_reg_axi_debug_input_width_converter_cfg_block_data_r <= AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_input_width_converter_cfg_allow_word_r <= AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_input_width_converter_cfg_allow_frame_r <= AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_RESET;
            s_axi_debug_bb_scrambler_cfg_strobe_r <= '0';
            s_reg_axi_debug_bb_scrambler_cfg_block_data_r <= AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_bb_scrambler_cfg_allow_word_r <= AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r <= AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_RESET;
            s_axi_debug_bch_encoder_cfg_strobe_r <= '0';
            s_reg_axi_debug_bch_encoder_cfg_block_data_r <= AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_bch_encoder_cfg_allow_word_r <= AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_bch_encoder_cfg_allow_frame_r <= AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_RESET;
            s_axi_debug_ldpc_encoder_cfg_strobe_r <= '0';
            s_reg_axi_debug_ldpc_encoder_cfg_block_data_r <= AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r <= AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r <= AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_RESET;
            s_axi_debug_bit_interleaver_cfg_strobe_r <= '0';
            s_reg_axi_debug_bit_interleaver_cfg_block_data_r <= AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_bit_interleaver_cfg_allow_word_r <= AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r <= AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_RESET;
            s_axi_debug_constellation_mapper_cfg_strobe_r <= '0';
            s_reg_axi_debug_constellation_mapper_cfg_block_data_r <= AXI_DEBUG_CONSTELLATION_MAPPER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_constellation_mapper_cfg_allow_word_r <= AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_constellation_mapper_cfg_allow_frame_r <= AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_FRAME_RESET;
            s_axi_debug_plframe_cfg_strobe_r <= '0';
            s_reg_axi_debug_plframe_cfg_block_data_r <= AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_plframe_cfg_allow_word_r <= AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_plframe_cfg_allow_frame_r <= AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_RESET;

        elsif rising_edge(axi_aclk) then
            -- Default values:
            s_axi_awready_r <= '0';
            s_axi_wready_r  <= '0';
            s_config_strobe_r <= '0';
            s_constellation_map_radius_ram_waddr_r <= (others => '0'); -- always reset to zero because of wired OR
            s_constellation_map_radius_ram_wen_r <= (others => '0');
            s_constellation_map_iq_ram_waddr_r <= (others => '0'); -- always reset to zero because of wired OR
            s_constellation_map_iq_ram_wen_r <= (others => '0');
            s_axi_debug_input_width_converter_cfg_strobe_r <= '0';
            s_axi_debug_bb_scrambler_cfg_strobe_r <= '0';
            s_axi_debug_bch_encoder_cfg_strobe_r <= '0';
            s_axi_debug_ldpc_encoder_cfg_strobe_r <= '0';
            s_axi_debug_bit_interleaver_cfg_strobe_r <= '0';
            s_axi_debug_constellation_mapper_cfg_strobe_r <= '0';
            s_axi_debug_plframe_cfg_strobe_r <= '0';

            -- Self-clearing fields:
            s_reg_axi_debug_input_width_converter_cfg_allow_word_r <= (others => '0');
            s_reg_axi_debug_input_width_converter_cfg_allow_frame_r <= (others => '0');
            s_reg_axi_debug_bb_scrambler_cfg_allow_word_r <= (others => '0');
            s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r <= (others => '0');
            s_reg_axi_debug_bch_encoder_cfg_allow_word_r <= (others => '0');
            s_reg_axi_debug_bch_encoder_cfg_allow_frame_r <= (others => '0');
            s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r <= (others => '0');
            s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r <= (others => '0');
            s_reg_axi_debug_bit_interleaver_cfg_allow_word_r <= (others => '0');
            s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r <= (others => '0');
            s_reg_axi_debug_constellation_mapper_cfg_allow_word_r <= (others => '0');
            s_reg_axi_debug_constellation_mapper_cfg_allow_frame_r <= (others => '0');
            s_reg_axi_debug_plframe_cfg_allow_word_r <= (others => '0');
            s_reg_axi_debug_plframe_cfg_allow_frame_r <= (others => '0');

            case v_state_r is

                -- Wait for the start of a write transaction, which may be
                -- initiated by either of the following conditions:
                --   * assertion of both AWVALID and WVALID
                --   * assertion of AWVALID
                --   * assertion of WVALID
                when IDLE =>
                    if s_axi_awvalid = '1' and s_axi_wvalid = '1' then
                        s_axi_awaddr_reg_r <= unsigned(s_axi_awaddr); -- save the write-address
                        s_axi_awready_r    <= '1'; -- acknowledge the write-address
                        s_axi_wdata_reg_r  <= s_axi_wdata; -- save the write-data
                        s_axi_wstrb_reg_r  <= s_axi_wstrb; -- save the write-strobe
                        s_axi_wready_r     <= '1'; -- acknowledge the write-data
                        v_state_r          := UPDATE_REGISTER;
                    elsif s_axi_awvalid = '1' then
                        s_axi_awaddr_reg_r <= unsigned(s_axi_awaddr); -- save the write-address
                        s_axi_awready_r    <= '1'; -- acknowledge the write-address
                        v_state_r          := ADDR_FIRST;
                    elsif s_axi_wvalid = '1' then
                        s_axi_wdata_reg_r <= s_axi_wdata; -- save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; -- save the write-strobe
                        s_axi_wready_r    <= '1'; -- acknowledge the write-data
                        v_state_r         := DATA_FIRST;
                    end if;

                -- Address-first write transaction: wait for the write-data
                when ADDR_FIRST =>
                    if s_axi_wvalid = '1' then
                        s_axi_wdata_reg_r <= s_axi_wdata; -- save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; -- save the write-strobe
                        s_axi_wready_r    <= '1'; -- acknowledge the write-data
                        v_state_r         := UPDATE_REGISTER;
                    end if;

                -- Data-first write transaction: wait for the write-address
                when DATA_FIRST =>
                    if s_axi_awvalid = '1' then
                        s_axi_awaddr_reg_r <= unsigned(s_axi_awaddr); -- save the write-address
                        s_axi_awready_r    <= '1'; -- acknowledge the write-address
                        v_state_r          := UPDATE_REGISTER;
                    end if;

                -- Update the actual storage element
                when UPDATE_REGISTER =>
                    s_axi_bresp_r               <= AXI_OKAY; -- default value, may be overriden in case of decode error
                    s_axi_bvalid_r              <= '1';
                    --
                    v_addr_hit := false;
                    -- register 'config' at address offset 0x0
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + CONFIG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_config_strobe_r <= '1';
                        -- field 'physical_layer_scrambler_shift_reg_init':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(0) <= s_axi_wdata_reg_r(0); -- physical_layer_scrambler_shift_reg_init(0)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(1) <= s_axi_wdata_reg_r(1); -- physical_layer_scrambler_shift_reg_init(1)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(2) <= s_axi_wdata_reg_r(2); -- physical_layer_scrambler_shift_reg_init(2)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(3) <= s_axi_wdata_reg_r(3); -- physical_layer_scrambler_shift_reg_init(3)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(4) <= s_axi_wdata_reg_r(4); -- physical_layer_scrambler_shift_reg_init(4)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(5) <= s_axi_wdata_reg_r(5); -- physical_layer_scrambler_shift_reg_init(5)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(6) <= s_axi_wdata_reg_r(6); -- physical_layer_scrambler_shift_reg_init(6)
                        end if;
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(7) <= s_axi_wdata_reg_r(7); -- physical_layer_scrambler_shift_reg_init(7)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(8) <= s_axi_wdata_reg_r(8); -- physical_layer_scrambler_shift_reg_init(8)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(9) <= s_axi_wdata_reg_r(9); -- physical_layer_scrambler_shift_reg_init(9)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(10) <= s_axi_wdata_reg_r(10); -- physical_layer_scrambler_shift_reg_init(10)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(11) <= s_axi_wdata_reg_r(11); -- physical_layer_scrambler_shift_reg_init(11)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(12) <= s_axi_wdata_reg_r(12); -- physical_layer_scrambler_shift_reg_init(12)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(13) <= s_axi_wdata_reg_r(13); -- physical_layer_scrambler_shift_reg_init(13)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(14) <= s_axi_wdata_reg_r(14); -- physical_layer_scrambler_shift_reg_init(14)
                        end if;
                        if s_axi_wstrb_reg_r(1) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(15) <= s_axi_wdata_reg_r(15); -- physical_layer_scrambler_shift_reg_init(15)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(16) <= s_axi_wdata_reg_r(16); -- physical_layer_scrambler_shift_reg_init(16)
                        end if;
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r(17) <= s_axi_wdata_reg_r(17); -- physical_layer_scrambler_shift_reg_init(17)
                        end if;
                        -- field 'enable_dummy_frames':
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_config_enable_dummy_frames_r(0) <= s_axi_wdata_reg_r(18); -- enable_dummy_frames(0)
                        end if;
                        -- field 'swap_input_data_byte_endianness':
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_config_swap_input_data_byte_endianness_r(0) <= s_axi_wdata_reg_r(19); -- swap_input_data_byte_endianness(0)
                        end if;
                        -- field 'swap_output_data_byte_endianness':
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_config_swap_output_data_byte_endianness_r(0) <= s_axi_wdata_reg_r(20); -- swap_output_data_byte_endianness(0)
                        end if;
                        -- field 'force_output_ready':
                        if s_axi_wstrb_reg_r(2) = '1' then
                            s_reg_config_force_output_ready_r(0) <= s_axi_wdata_reg_r(21); -- force_output_ready(0)
                        end if;
                    end if;
                    -- memory 'constellation_map_radius_ram' at address offset 0x10
                    if s_axi_awaddr_reg_r >= resize(unsigned(BASEADDR) + CONSTELLATION_MAP_RADIUS_RAM_OFFSET, AXI_ADDR_WIDTH) and
                        s_axi_awaddr_reg_r < resize(unsigned(BASEADDR) + CONSTELLATION_MAP_RADIUS_RAM_OFFSET + CONSTELLATION_MAP_RADIUS_RAM_DEPTH * 4, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        v_mem_addr := s_axi_awaddr_reg_r - resize(unsigned(BASEADDR) + CONSTELLATION_MAP_RADIUS_RAM_OFFSET, AXI_ADDR_WIDTH);
                        s_constellation_map_radius_ram_waddr_r <= std_logic_vector(v_mem_addr(6 downto 2)); -- output address has 4-byte granularity
                        s_constellation_map_radius_ram_wen_r <= s_axi_wstrb_reg_r;
                        s_constellation_map_radius_ram_wdata_r <= s_axi_wdata_reg_r;
                    end if;
                    -- memory 'constellation_map_iq_ram' at address offset 0x110
                    if s_axi_awaddr_reg_r >= resize(unsigned(BASEADDR) + CONSTELLATION_MAP_IQ_RAM_OFFSET, AXI_ADDR_WIDTH) and
                        s_axi_awaddr_reg_r < resize(unsigned(BASEADDR) + CONSTELLATION_MAP_IQ_RAM_OFFSET + CONSTELLATION_MAP_IQ_RAM_DEPTH * 4, AXI_ADDR_WIDTH) then
                        v_addr_hit := true;
                        v_mem_addr := s_axi_awaddr_reg_r - resize(unsigned(BASEADDR) + CONSTELLATION_MAP_IQ_RAM_OFFSET, AXI_ADDR_WIDTH);
                        s_constellation_map_iq_ram_waddr_r <= std_logic_vector(v_mem_addr(7 downto 2)); -- output address has 4-byte granularity
                        s_constellation_map_iq_ram_wen_r <= s_axi_wstrb_reg_r;
                        s_constellation_map_iq_ram_wdata_r <= s_axi_wdata_reg_r;
                    end if;
                    -- register 'axi_debug_input_width_converter_cfg' at address offset 0xD00
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_axi_debug_input_width_converter_cfg_strobe_r <= '1';
                        -- field 'block_data':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_input_width_converter_cfg_block_data_r(0) <= s_axi_wdata_reg_r(0); -- block_data(0)
                        end if;
                        -- field 'allow_word':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_input_width_converter_cfg_allow_word_r(0) <= s_axi_wdata_reg_r(1); -- allow_word(0)
                        end if;
                        -- field 'allow_frame':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_input_width_converter_cfg_allow_frame_r(0) <= s_axi_wdata_reg_r(2); -- allow_frame(0)
                        end if;
                    end if;
                    -- register 'axi_debug_bb_scrambler_cfg' at address offset 0xE00
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BB_SCRAMBLER_CFG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_axi_debug_bb_scrambler_cfg_strobe_r <= '1';
                        -- field 'block_data':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_bb_scrambler_cfg_block_data_r(0) <= s_axi_wdata_reg_r(0); -- block_data(0)
                        end if;
                        -- field 'allow_word':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_bb_scrambler_cfg_allow_word_r(0) <= s_axi_wdata_reg_r(1); -- allow_word(0)
                        end if;
                        -- field 'allow_frame':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r(0) <= s_axi_wdata_reg_r(2); -- allow_frame(0)
                        end if;
                    end if;
                    -- register 'axi_debug_bch_encoder_cfg' at address offset 0xF00
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BCH_ENCODER_CFG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_axi_debug_bch_encoder_cfg_strobe_r <= '1';
                        -- field 'block_data':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_bch_encoder_cfg_block_data_r(0) <= s_axi_wdata_reg_r(0); -- block_data(0)
                        end if;
                        -- field 'allow_word':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_bch_encoder_cfg_allow_word_r(0) <= s_axi_wdata_reg_r(1); -- allow_word(0)
                        end if;
                        -- field 'allow_frame':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_bch_encoder_cfg_allow_frame_r(0) <= s_axi_wdata_reg_r(2); -- allow_frame(0)
                        end if;
                    end if;
                    -- register 'axi_debug_ldpc_encoder_cfg' at address offset 0x1000
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_LDPC_ENCODER_CFG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_axi_debug_ldpc_encoder_cfg_strobe_r <= '1';
                        -- field 'block_data':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_ldpc_encoder_cfg_block_data_r(0) <= s_axi_wdata_reg_r(0); -- block_data(0)
                        end if;
                        -- field 'allow_word':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r(0) <= s_axi_wdata_reg_r(1); -- allow_word(0)
                        end if;
                        -- field 'allow_frame':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r(0) <= s_axi_wdata_reg_r(2); -- allow_frame(0)
                        end if;
                    end if;
                    -- register 'axi_debug_bit_interleaver_cfg' at address offset 0x1100
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_BIT_INTERLEAVER_CFG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_axi_debug_bit_interleaver_cfg_strobe_r <= '1';
                        -- field 'block_data':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_bit_interleaver_cfg_block_data_r(0) <= s_axi_wdata_reg_r(0); -- block_data(0)
                        end if;
                        -- field 'allow_word':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_bit_interleaver_cfg_allow_word_r(0) <= s_axi_wdata_reg_r(1); -- allow_word(0)
                        end if;
                        -- field 'allow_frame':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r(0) <= s_axi_wdata_reg_r(2); -- allow_frame(0)
                        end if;
                    end if;
                    -- register 'axi_debug_constellation_mapper_cfg' at address offset 0x1200
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_CONSTELLATION_MAPPER_CFG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_axi_debug_constellation_mapper_cfg_strobe_r <= '1';
                        -- field 'block_data':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_constellation_mapper_cfg_block_data_r(0) <= s_axi_wdata_reg_r(0); -- block_data(0)
                        end if;
                        -- field 'allow_word':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_constellation_mapper_cfg_allow_word_r(0) <= s_axi_wdata_reg_r(1); -- allow_word(0)
                        end if;
                        -- field 'allow_frame':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_constellation_mapper_cfg_allow_frame_r(0) <= s_axi_wdata_reg_r(2); -- allow_frame(0)
                        end if;
                    end if;
                    -- register 'axi_debug_plframe_cfg' at address offset 0x1300
                    if s_axi_awaddr_reg_r(AXI_ADDR_WIDTH-1 downto 2) = resize(unsigned(BASEADDR(AXI_ADDR_WIDTH-1 downto 2)) + AXI_DEBUG_PLFRAME_CFG_OFFSET(AXI_ADDR_WIDTH-1 downto 2), AXI_ADDR_WIDTH-2) then
                        v_addr_hit := true;
                        s_axi_debug_plframe_cfg_strobe_r <= '1';
                        -- field 'block_data':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_plframe_cfg_block_data_r(0) <= s_axi_wdata_reg_r(0); -- block_data(0)
                        end if;
                        -- field 'allow_word':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_plframe_cfg_allow_word_r(0) <= s_axi_wdata_reg_r(1); -- allow_word(0)
                        end if;
                        -- field 'allow_frame':
                        if s_axi_wstrb_reg_r(0) = '1' then
                            s_reg_axi_debug_plframe_cfg_allow_frame_r(0) <= s_axi_wdata_reg_r(2); -- allow_frame(0)
                        end if;
                    end if;
                    --
                    if not v_addr_hit then
                        s_axi_bresp_r <= AXI_SLVERR;
                        -- pragma translate_off
                        report "AWADDR decode error" severity warning;
                        -- pragma translate_on
                    end if;
                    --
                    v_state_r := DONE;

                -- Write transaction completed, wait for master BREADY to proceed
                when DONE =>
                    if s_axi_bready = '1' then
                        s_axi_bvalid_r <= '0';
                        v_state_r      := IDLE;
                    end if;

            end case;


        end if;
    end process write_fsm;

    ------------------------------------------------------------------------------------------------
    -- Outputs
    ------------------------------------------------------------------------------------------------

    s_axi_awready <= s_axi_awready_r;
    s_axi_wready  <= s_axi_wready_r;
    s_axi_bvalid  <= s_axi_bvalid_r;
    s_axi_bresp   <= s_axi_bresp_r;
    s_axi_arready <= s_axi_arready_r;
    s_axi_rvalid  <= s_axi_rvalid_r;
    s_axi_rresp   <= s_axi_rresp_r;
    s_axi_rdata   <= s_axi_rdata_r;

    regs2user.config_strobe <= s_config_strobe_r;
    regs2user.config_physical_layer_scrambler_shift_reg_init <= s_reg_config_physical_layer_scrambler_shift_reg_init_r;
    regs2user.config_enable_dummy_frames <= s_reg_config_enable_dummy_frames_r;
    regs2user.config_swap_input_data_byte_endianness <= s_reg_config_swap_input_data_byte_endianness_r;
    regs2user.config_swap_output_data_byte_endianness <= s_reg_config_swap_output_data_byte_endianness_r;
    regs2user.config_force_output_ready <= s_reg_config_force_output_ready_r;
    regs2user.ldpc_fifo_status_strobe <= s_ldpc_fifo_status_strobe_r;
    regs2user.frames_in_transit_strobe <= s_frames_in_transit_strobe_r;
    regs2user.constellation_map_radius_ram_addr <= s_constellation_map_radius_ram_waddr_r or s_constellation_map_radius_ram_raddr_r; -- using wired OR as read/write address multiplexer
    regs2user.constellation_map_radius_ram_wen <= s_constellation_map_radius_ram_wen_r;
    regs2user.constellation_map_radius_ram_wdata <= s_constellation_map_radius_ram_wdata_r;
    regs2user.constellation_map_radius_ram_ren <= s_constellation_map_radius_ram_ren_r;
    regs2user.constellation_map_iq_ram_addr <= s_constellation_map_iq_ram_waddr_r or s_constellation_map_iq_ram_raddr_r; -- using wired OR as read/write address multiplexer
    regs2user.constellation_map_iq_ram_wen <= s_constellation_map_iq_ram_wen_r;
    regs2user.constellation_map_iq_ram_wdata <= s_constellation_map_iq_ram_wdata_r;
    regs2user.constellation_map_iq_ram_ren <= s_constellation_map_iq_ram_ren_r;
    regs2user.axi_debug_input_width_converter_cfg_strobe <= s_axi_debug_input_width_converter_cfg_strobe_r;
    regs2user.axi_debug_input_width_converter_cfg_block_data <= s_reg_axi_debug_input_width_converter_cfg_block_data_r;
    regs2user.axi_debug_input_width_converter_cfg_allow_word <= s_reg_axi_debug_input_width_converter_cfg_allow_word_r;
    regs2user.axi_debug_input_width_converter_cfg_allow_frame <= s_reg_axi_debug_input_width_converter_cfg_allow_frame_r;
    regs2user.axi_debug_input_width_converter_frame_count_strobe <= s_axi_debug_input_width_converter_frame_count_strobe_r;
    regs2user.axi_debug_input_width_converter_last_frame_length_strobe <= s_axi_debug_input_width_converter_last_frame_length_strobe_r;
    regs2user.axi_debug_input_width_converter_min_max_frame_length_strobe <= s_axi_debug_input_width_converter_min_max_frame_length_strobe_r;
    regs2user.axi_debug_input_width_converter_word_count_strobe <= s_axi_debug_input_width_converter_word_count_strobe_r;
    regs2user.axi_debug_input_width_converter_strobes_strobe <= s_axi_debug_input_width_converter_strobes_strobe_r;
    regs2user.axi_debug_bb_scrambler_cfg_strobe <= s_axi_debug_bb_scrambler_cfg_strobe_r;
    regs2user.axi_debug_bb_scrambler_cfg_block_data <= s_reg_axi_debug_bb_scrambler_cfg_block_data_r;
    regs2user.axi_debug_bb_scrambler_cfg_allow_word <= s_reg_axi_debug_bb_scrambler_cfg_allow_word_r;
    regs2user.axi_debug_bb_scrambler_cfg_allow_frame <= s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r;
    regs2user.axi_debug_bb_scrambler_frame_count_strobe <= s_axi_debug_bb_scrambler_frame_count_strobe_r;
    regs2user.axi_debug_bb_scrambler_last_frame_length_strobe <= s_axi_debug_bb_scrambler_last_frame_length_strobe_r;
    regs2user.axi_debug_bb_scrambler_min_max_frame_length_strobe <= s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r;
    regs2user.axi_debug_bb_scrambler_word_count_strobe <= s_axi_debug_bb_scrambler_word_count_strobe_r;
    regs2user.axi_debug_bb_scrambler_strobes_strobe <= s_axi_debug_bb_scrambler_strobes_strobe_r;
    regs2user.axi_debug_bch_encoder_cfg_strobe <= s_axi_debug_bch_encoder_cfg_strobe_r;
    regs2user.axi_debug_bch_encoder_cfg_block_data <= s_reg_axi_debug_bch_encoder_cfg_block_data_r;
    regs2user.axi_debug_bch_encoder_cfg_allow_word <= s_reg_axi_debug_bch_encoder_cfg_allow_word_r;
    regs2user.axi_debug_bch_encoder_cfg_allow_frame <= s_reg_axi_debug_bch_encoder_cfg_allow_frame_r;
    regs2user.axi_debug_bch_encoder_frame_count_strobe <= s_axi_debug_bch_encoder_frame_count_strobe_r;
    regs2user.axi_debug_bch_encoder_last_frame_length_strobe <= s_axi_debug_bch_encoder_last_frame_length_strobe_r;
    regs2user.axi_debug_bch_encoder_min_max_frame_length_strobe <= s_axi_debug_bch_encoder_min_max_frame_length_strobe_r;
    regs2user.axi_debug_bch_encoder_word_count_strobe <= s_axi_debug_bch_encoder_word_count_strobe_r;
    regs2user.axi_debug_bch_encoder_strobes_strobe <= s_axi_debug_bch_encoder_strobes_strobe_r;
    regs2user.axi_debug_ldpc_encoder_cfg_strobe <= s_axi_debug_ldpc_encoder_cfg_strobe_r;
    regs2user.axi_debug_ldpc_encoder_cfg_block_data <= s_reg_axi_debug_ldpc_encoder_cfg_block_data_r;
    regs2user.axi_debug_ldpc_encoder_cfg_allow_word <= s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r;
    regs2user.axi_debug_ldpc_encoder_cfg_allow_frame <= s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r;
    regs2user.axi_debug_ldpc_encoder_frame_count_strobe <= s_axi_debug_ldpc_encoder_frame_count_strobe_r;
    regs2user.axi_debug_ldpc_encoder_last_frame_length_strobe <= s_axi_debug_ldpc_encoder_last_frame_length_strobe_r;
    regs2user.axi_debug_ldpc_encoder_min_max_frame_length_strobe <= s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r;
    regs2user.axi_debug_ldpc_encoder_word_count_strobe <= s_axi_debug_ldpc_encoder_word_count_strobe_r;
    regs2user.axi_debug_ldpc_encoder_strobes_strobe <= s_axi_debug_ldpc_encoder_strobes_strobe_r;
    regs2user.axi_debug_bit_interleaver_cfg_strobe <= s_axi_debug_bit_interleaver_cfg_strobe_r;
    regs2user.axi_debug_bit_interleaver_cfg_block_data <= s_reg_axi_debug_bit_interleaver_cfg_block_data_r;
    regs2user.axi_debug_bit_interleaver_cfg_allow_word <= s_reg_axi_debug_bit_interleaver_cfg_allow_word_r;
    regs2user.axi_debug_bit_interleaver_cfg_allow_frame <= s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r;
    regs2user.axi_debug_bit_interleaver_frame_count_strobe <= s_axi_debug_bit_interleaver_frame_count_strobe_r;
    regs2user.axi_debug_bit_interleaver_last_frame_length_strobe <= s_axi_debug_bit_interleaver_last_frame_length_strobe_r;
    regs2user.axi_debug_bit_interleaver_min_max_frame_length_strobe <= s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r;
    regs2user.axi_debug_bit_interleaver_word_count_strobe <= s_axi_debug_bit_interleaver_word_count_strobe_r;
    regs2user.axi_debug_bit_interleaver_strobes_strobe <= s_axi_debug_bit_interleaver_strobes_strobe_r;
    regs2user.axi_debug_constellation_mapper_cfg_strobe <= s_axi_debug_constellation_mapper_cfg_strobe_r;
    regs2user.axi_debug_constellation_mapper_cfg_block_data <= s_reg_axi_debug_constellation_mapper_cfg_block_data_r;
    regs2user.axi_debug_constellation_mapper_cfg_allow_word <= s_reg_axi_debug_constellation_mapper_cfg_allow_word_r;
    regs2user.axi_debug_constellation_mapper_cfg_allow_frame <= s_reg_axi_debug_constellation_mapper_cfg_allow_frame_r;
    regs2user.axi_debug_constellation_mapper_frame_count_strobe <= s_axi_debug_constellation_mapper_frame_count_strobe_r;
    regs2user.axi_debug_constellation_mapper_last_frame_length_strobe <= s_axi_debug_constellation_mapper_last_frame_length_strobe_r;
    regs2user.axi_debug_constellation_mapper_min_max_frame_length_strobe <= s_axi_debug_constellation_mapper_min_max_frame_length_strobe_r;
    regs2user.axi_debug_constellation_mapper_word_count_strobe <= s_axi_debug_constellation_mapper_word_count_strobe_r;
    regs2user.axi_debug_constellation_mapper_strobes_strobe <= s_axi_debug_constellation_mapper_strobes_strobe_r;
    regs2user.axi_debug_plframe_cfg_strobe <= s_axi_debug_plframe_cfg_strobe_r;
    regs2user.axi_debug_plframe_cfg_block_data <= s_reg_axi_debug_plframe_cfg_block_data_r;
    regs2user.axi_debug_plframe_cfg_allow_word <= s_reg_axi_debug_plframe_cfg_allow_word_r;
    regs2user.axi_debug_plframe_cfg_allow_frame <= s_reg_axi_debug_plframe_cfg_allow_frame_r;
    regs2user.axi_debug_plframe_frame_count_strobe <= s_axi_debug_plframe_frame_count_strobe_r;
    regs2user.axi_debug_plframe_last_frame_length_strobe <= s_axi_debug_plframe_last_frame_length_strobe_r;
    regs2user.axi_debug_plframe_min_max_frame_length_strobe <= s_axi_debug_plframe_min_max_frame_length_strobe_r;
    regs2user.axi_debug_plframe_word_count_strobe <= s_axi_debug_plframe_word_count_strobe_r;
    regs2user.axi_debug_plframe_strobes_strobe <= s_axi_debug_plframe_strobes_strobe_r;

end architecture RTL;
