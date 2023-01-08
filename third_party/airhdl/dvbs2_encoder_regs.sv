// -------------------------------------------------------------------------------------------------
// 'dvbs2_encoder' Register Component
// Revision: 347
// -------------------------------------------------------------------------------------------------
// Generated on 2023-01-08 at 17:59 (UTC) by airhdl version 2023.01.1-740440560
// -------------------------------------------------------------------------------------------------
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// -------------------------------------------------------------------------------------------------

`default_nettype none

module dvbs2_encoder_regs #(
    parameter AXI_ADDR_WIDTH = 32, // width of the AXI address bus
    parameter logic [31:0] BASEADDR = 32'h00000000 // the register file's system base address
    ) (
    // Clock and Reset
    input  wire                      axi_aclk,
    input  wire                      axi_aresetn,

    // AXI Write Address Channel
    input  wire [AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire [2:0]                s_axi_awprot,
    input  wire                      s_axi_awvalid,
    output wire                      s_axi_awready,

    // AXI Write Data Channel
    input  wire [31:0]               s_axi_wdata,
    input  wire [3:0]                s_axi_wstrb,
    input  wire                      s_axi_wvalid,
    output wire                      s_axi_wready,

    // AXI Read Address Channel
    input  wire [AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire [2:0]                s_axi_arprot,
    input  wire                      s_axi_arvalid,
    output wire                      s_axi_arready,

    // AXI Read Data Channel
    output wire [31:0]               s_axi_rdata,
    output wire [1:0]                s_axi_rresp,
    output wire                      s_axi_rvalid,
    input  wire                      s_axi_rready,

    // AXI Write Response Channel
    output wire [1:0]                s_axi_bresp,
    output wire                      s_axi_bvalid,
    input  wire                      s_axi_bready,

    // User Ports
    input dvbs2_encoder_regs_pkg::user2regs_t user2regs,
    output dvbs2_encoder_regs_pkg::regs2user_t regs2user
    );

    // Constants
    localparam logic [1:0] AXI_OKAY   = 2'b00;
    localparam logic [1:0] AXI_SLVERR = 2'b10;

    // Registered signals
    logic                           s_axi_awready_r;
    logic                           s_axi_wready_r;
    logic [$bits(s_axi_awaddr)-1:0] s_axi_awaddr_reg_r;
    logic                           s_axi_bvalid_r;
    logic [$bits(s_axi_bresp)-1:0]  s_axi_bresp_r;
    logic                           s_axi_arready_r;
    logic [$bits(s_axi_araddr)-1:0] s_axi_araddr_reg_r;
    logic                           s_axi_rvalid_r;
    logic [$bits(s_axi_rresp)-1:0]  s_axi_rresp_r;
    logic [$bits(s_axi_wdata)-1:0]  s_axi_wdata_reg_r;
    logic [$bits(s_axi_wstrb)-1:0]  s_axi_wstrb_reg_r;
    logic [$bits(s_axi_rdata)-1:0]  s_axi_rdata_r;

    // User-defined registers
    logic s_config_strobe_r;
    logic [17:0] s_reg_config_physical_layer_scrambler_shift_reg_init_r;
    logic [0:0] s_reg_config_enable_dummy_frames_r;
    logic [0:0] s_reg_config_swap_input_data_byte_endianness_r;
    logic [0:0] s_reg_config_swap_output_data_byte_endianness_r;
    logic [0:0] s_reg_config_force_output_ready_r;
    logic s_ldpc_fifo_status_strobe_r;
    logic [13:0] s_reg_ldpc_fifo_status_ldpc_fifo_entries;
    logic [0:0] s_reg_ldpc_fifo_status_ldpc_fifo_empty;
    logic [0:0] s_reg_ldpc_fifo_status_ldpc_fifo_full;
    logic [1:0] s_reg_ldpc_fifo_status_arbiter_selected;
    logic s_frames_in_transit_strobe_r;
    logic [7:0] s_reg_frames_in_transit_value;
    logic [4:0] s_constellation_map_radius_ram_raddr_r;
    logic s_constellation_map_radius_ram_ren_r;
    logic [31:0] s_constellation_map_radius_ram_rdata;
    logic [4:0] s_constellation_map_radius_ram_waddr_r;
    logic [3:0] s_constellation_map_radius_ram_wen_r;
    logic [31:0] s_constellation_map_radius_ram_wdata_r;
    logic [5:0] s_constellation_map_iq_ram_raddr_r;
    logic s_constellation_map_iq_ram_ren_r;
    logic [31:0] s_constellation_map_iq_ram_rdata;
    logic [5:0] s_constellation_map_iq_ram_waddr_r;
    logic [3:0] s_constellation_map_iq_ram_wen_r;
    logic [31:0] s_constellation_map_iq_ram_wdata_r;
    logic s_axi_debug_input_width_converter_cfg_strobe_r;
    logic [0:0] s_reg_axi_debug_input_width_converter_cfg_block_data_r;
    logic [0:0] s_reg_axi_debug_input_width_converter_cfg_allow_word_r;
    logic [0:0] s_reg_axi_debug_input_width_converter_cfg_allow_frame_r;
    logic s_axi_debug_input_width_converter_frame_count_strobe_r;
    logic [15:0] s_reg_axi_debug_input_width_converter_frame_count_value;
    logic s_axi_debug_input_width_converter_last_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_input_width_converter_last_frame_length_value;
    logic s_axi_debug_input_width_converter_min_max_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_input_width_converter_min_max_frame_length_min_frame_length;
    logic [15:0] s_reg_axi_debug_input_width_converter_min_max_frame_length_max_frame_length;
    logic s_axi_debug_input_width_converter_word_count_strobe_r;
    logic [15:0] s_reg_axi_debug_input_width_converter_word_count_value;
    logic s_axi_debug_input_width_converter_strobes_strobe_r;
    logic [0:0] s_reg_axi_debug_input_width_converter_strobes_s_tvalid;
    logic [0:0] s_reg_axi_debug_input_width_converter_strobes_s_tready;
    logic [0:0] s_reg_axi_debug_input_width_converter_strobes_m_tvalid;
    logic [0:0] s_reg_axi_debug_input_width_converter_strobes_m_tready;
    logic s_axi_debug_bb_scrambler_cfg_strobe_r;
    logic [0:0] s_reg_axi_debug_bb_scrambler_cfg_block_data_r;
    logic [0:0] s_reg_axi_debug_bb_scrambler_cfg_allow_word_r;
    logic [0:0] s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r;
    logic s_axi_debug_bb_scrambler_frame_count_strobe_r;
    logic [15:0] s_reg_axi_debug_bb_scrambler_frame_count_value;
    logic s_axi_debug_bb_scrambler_last_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_bb_scrambler_last_frame_length_value;
    logic s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_bb_scrambler_min_max_frame_length_min_frame_length;
    logic [15:0] s_reg_axi_debug_bb_scrambler_min_max_frame_length_max_frame_length;
    logic s_axi_debug_bb_scrambler_word_count_strobe_r;
    logic [15:0] s_reg_axi_debug_bb_scrambler_word_count_value;
    logic s_axi_debug_bb_scrambler_strobes_strobe_r;
    logic [0:0] s_reg_axi_debug_bb_scrambler_strobes_s_tvalid;
    logic [0:0] s_reg_axi_debug_bb_scrambler_strobes_s_tready;
    logic [0:0] s_reg_axi_debug_bb_scrambler_strobes_m_tvalid;
    logic [0:0] s_reg_axi_debug_bb_scrambler_strobes_m_tready;
    logic s_axi_debug_bch_encoder_cfg_strobe_r;
    logic [0:0] s_reg_axi_debug_bch_encoder_cfg_block_data_r;
    logic [0:0] s_reg_axi_debug_bch_encoder_cfg_allow_word_r;
    logic [0:0] s_reg_axi_debug_bch_encoder_cfg_allow_frame_r;
    logic s_axi_debug_bch_encoder_frame_count_strobe_r;
    logic [15:0] s_reg_axi_debug_bch_encoder_frame_count_value;
    logic s_axi_debug_bch_encoder_last_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_bch_encoder_last_frame_length_value;
    logic s_axi_debug_bch_encoder_min_max_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_bch_encoder_min_max_frame_length_min_frame_length;
    logic [15:0] s_reg_axi_debug_bch_encoder_min_max_frame_length_max_frame_length;
    logic s_axi_debug_bch_encoder_word_count_strobe_r;
    logic [15:0] s_reg_axi_debug_bch_encoder_word_count_value;
    logic s_axi_debug_bch_encoder_strobes_strobe_r;
    logic [0:0] s_reg_axi_debug_bch_encoder_strobes_s_tvalid;
    logic [0:0] s_reg_axi_debug_bch_encoder_strobes_s_tready;
    logic [0:0] s_reg_axi_debug_bch_encoder_strobes_m_tvalid;
    logic [0:0] s_reg_axi_debug_bch_encoder_strobes_m_tready;
    logic s_axi_debug_ldpc_encoder_cfg_strobe_r;
    logic [0:0] s_reg_axi_debug_ldpc_encoder_cfg_block_data_r;
    logic [0:0] s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r;
    logic [0:0] s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r;
    logic s_axi_debug_ldpc_encoder_frame_count_strobe_r;
    logic [15:0] s_reg_axi_debug_ldpc_encoder_frame_count_value;
    logic s_axi_debug_ldpc_encoder_last_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_ldpc_encoder_last_frame_length_value;
    logic s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length;
    logic [15:0] s_reg_axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length;
    logic s_axi_debug_ldpc_encoder_word_count_strobe_r;
    logic [15:0] s_reg_axi_debug_ldpc_encoder_word_count_value;
    logic s_axi_debug_ldpc_encoder_strobes_strobe_r;
    logic [0:0] s_reg_axi_debug_ldpc_encoder_strobes_s_tvalid;
    logic [0:0] s_reg_axi_debug_ldpc_encoder_strobes_s_tready;
    logic [0:0] s_reg_axi_debug_ldpc_encoder_strobes_m_tvalid;
    logic [0:0] s_reg_axi_debug_ldpc_encoder_strobes_m_tready;
    logic s_axi_debug_bit_interleaver_cfg_strobe_r;
    logic [0:0] s_reg_axi_debug_bit_interleaver_cfg_block_data_r;
    logic [0:0] s_reg_axi_debug_bit_interleaver_cfg_allow_word_r;
    logic [0:0] s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r;
    logic s_axi_debug_bit_interleaver_frame_count_strobe_r;
    logic [15:0] s_reg_axi_debug_bit_interleaver_frame_count_value;
    logic s_axi_debug_bit_interleaver_last_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_bit_interleaver_last_frame_length_value;
    logic s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_bit_interleaver_min_max_frame_length_min_frame_length;
    logic [15:0] s_reg_axi_debug_bit_interleaver_min_max_frame_length_max_frame_length;
    logic s_axi_debug_bit_interleaver_word_count_strobe_r;
    logic [15:0] s_reg_axi_debug_bit_interleaver_word_count_value;
    logic s_axi_debug_bit_interleaver_strobes_strobe_r;
    logic [0:0] s_reg_axi_debug_bit_interleaver_strobes_s_tvalid;
    logic [0:0] s_reg_axi_debug_bit_interleaver_strobes_s_tready;
    logic [0:0] s_reg_axi_debug_bit_interleaver_strobes_m_tvalid;
    logic [0:0] s_reg_axi_debug_bit_interleaver_strobes_m_tready;
    logic s_axi_debug_constellation_mapper_cfg_strobe_r;
    logic [0:0] s_reg_axi_debug_constellation_mapper_cfg_block_data_r;
    logic [0:0] s_reg_axi_debug_constellation_mapper_cfg_allow_word_r;
    logic [0:0] s_reg_axi_debug_constellation_mapper_cfg_allow_frame_r;
    logic s_axi_debug_constellation_mapper_frame_count_strobe_r;
    logic [15:0] s_reg_axi_debug_constellation_mapper_frame_count_value;
    logic s_axi_debug_constellation_mapper_last_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_constellation_mapper_last_frame_length_value;
    logic s_axi_debug_constellation_mapper_min_max_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_constellation_mapper_min_max_frame_length_min_frame_length;
    logic [15:0] s_reg_axi_debug_constellation_mapper_min_max_frame_length_max_frame_length;
    logic s_axi_debug_constellation_mapper_word_count_strobe_r;
    logic [15:0] s_reg_axi_debug_constellation_mapper_word_count_value;
    logic s_axi_debug_constellation_mapper_strobes_strobe_r;
    logic [0:0] s_reg_axi_debug_constellation_mapper_strobes_s_tvalid;
    logic [0:0] s_reg_axi_debug_constellation_mapper_strobes_s_tready;
    logic [0:0] s_reg_axi_debug_constellation_mapper_strobes_m_tvalid;
    logic [0:0] s_reg_axi_debug_constellation_mapper_strobes_m_tready;
    logic s_axi_debug_plframe_cfg_strobe_r;
    logic [0:0] s_reg_axi_debug_plframe_cfg_block_data_r;
    logic [0:0] s_reg_axi_debug_plframe_cfg_allow_word_r;
    logic [0:0] s_reg_axi_debug_plframe_cfg_allow_frame_r;
    logic s_axi_debug_plframe_frame_count_strobe_r;
    logic [15:0] s_reg_axi_debug_plframe_frame_count_value;
    logic s_axi_debug_plframe_last_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_plframe_last_frame_length_value;
    logic s_axi_debug_plframe_min_max_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_plframe_min_max_frame_length_min_frame_length;
    logic [15:0] s_reg_axi_debug_plframe_min_max_frame_length_max_frame_length;
    logic s_axi_debug_plframe_word_count_strobe_r;
    logic [15:0] s_reg_axi_debug_plframe_word_count_value;
    logic s_axi_debug_plframe_strobes_strobe_r;
    logic [0:0] s_reg_axi_debug_plframe_strobes_s_tvalid;
    logic [0:0] s_reg_axi_debug_plframe_strobes_s_tready;
    logic [0:0] s_reg_axi_debug_plframe_strobes_m_tvalid;
    logic [0:0] s_reg_axi_debug_plframe_strobes_m_tready;

    //----------------------------------------------------------------------------------------------
    // Inputs
    //----------------------------------------------------------------------------------------------

    assign s_reg_ldpc_fifo_status_ldpc_fifo_entries = user2regs.ldpc_fifo_status_ldpc_fifo_entries;
    assign s_reg_ldpc_fifo_status_ldpc_fifo_empty = user2regs.ldpc_fifo_status_ldpc_fifo_empty;
    assign s_reg_ldpc_fifo_status_ldpc_fifo_full = user2regs.ldpc_fifo_status_ldpc_fifo_full;
    assign s_reg_ldpc_fifo_status_arbiter_selected = user2regs.ldpc_fifo_status_arbiter_selected;
    assign s_reg_frames_in_transit_value = user2regs.frames_in_transit_value;
    assign s_constellation_map_radius_ram_rdata = user2regs.constellation_map_radius_ram_rdata;
    assign s_constellation_map_iq_ram_rdata = user2regs.constellation_map_iq_ram_rdata;
    assign s_reg_axi_debug_input_width_converter_frame_count_value = user2regs.axi_debug_input_width_converter_frame_count_value;
    assign s_reg_axi_debug_input_width_converter_last_frame_length_value = user2regs.axi_debug_input_width_converter_last_frame_length_value;
    assign s_reg_axi_debug_input_width_converter_min_max_frame_length_min_frame_length = user2regs.axi_debug_input_width_converter_min_max_frame_length_min_frame_length;
    assign s_reg_axi_debug_input_width_converter_min_max_frame_length_max_frame_length = user2regs.axi_debug_input_width_converter_min_max_frame_length_max_frame_length;
    assign s_reg_axi_debug_input_width_converter_word_count_value = user2regs.axi_debug_input_width_converter_word_count_value;
    assign s_reg_axi_debug_input_width_converter_strobes_s_tvalid = user2regs.axi_debug_input_width_converter_strobes_s_tvalid;
    assign s_reg_axi_debug_input_width_converter_strobes_s_tready = user2regs.axi_debug_input_width_converter_strobes_s_tready;
    assign s_reg_axi_debug_input_width_converter_strobes_m_tvalid = user2regs.axi_debug_input_width_converter_strobes_m_tvalid;
    assign s_reg_axi_debug_input_width_converter_strobes_m_tready = user2regs.axi_debug_input_width_converter_strobes_m_tready;
    assign s_reg_axi_debug_bb_scrambler_frame_count_value = user2regs.axi_debug_bb_scrambler_frame_count_value;
    assign s_reg_axi_debug_bb_scrambler_last_frame_length_value = user2regs.axi_debug_bb_scrambler_last_frame_length_value;
    assign s_reg_axi_debug_bb_scrambler_min_max_frame_length_min_frame_length = user2regs.axi_debug_bb_scrambler_min_max_frame_length_min_frame_length;
    assign s_reg_axi_debug_bb_scrambler_min_max_frame_length_max_frame_length = user2regs.axi_debug_bb_scrambler_min_max_frame_length_max_frame_length;
    assign s_reg_axi_debug_bb_scrambler_word_count_value = user2regs.axi_debug_bb_scrambler_word_count_value;
    assign s_reg_axi_debug_bb_scrambler_strobes_s_tvalid = user2regs.axi_debug_bb_scrambler_strobes_s_tvalid;
    assign s_reg_axi_debug_bb_scrambler_strobes_s_tready = user2regs.axi_debug_bb_scrambler_strobes_s_tready;
    assign s_reg_axi_debug_bb_scrambler_strobes_m_tvalid = user2regs.axi_debug_bb_scrambler_strobes_m_tvalid;
    assign s_reg_axi_debug_bb_scrambler_strobes_m_tready = user2regs.axi_debug_bb_scrambler_strobes_m_tready;
    assign s_reg_axi_debug_bch_encoder_frame_count_value = user2regs.axi_debug_bch_encoder_frame_count_value;
    assign s_reg_axi_debug_bch_encoder_last_frame_length_value = user2regs.axi_debug_bch_encoder_last_frame_length_value;
    assign s_reg_axi_debug_bch_encoder_min_max_frame_length_min_frame_length = user2regs.axi_debug_bch_encoder_min_max_frame_length_min_frame_length;
    assign s_reg_axi_debug_bch_encoder_min_max_frame_length_max_frame_length = user2regs.axi_debug_bch_encoder_min_max_frame_length_max_frame_length;
    assign s_reg_axi_debug_bch_encoder_word_count_value = user2regs.axi_debug_bch_encoder_word_count_value;
    assign s_reg_axi_debug_bch_encoder_strobes_s_tvalid = user2regs.axi_debug_bch_encoder_strobes_s_tvalid;
    assign s_reg_axi_debug_bch_encoder_strobes_s_tready = user2regs.axi_debug_bch_encoder_strobes_s_tready;
    assign s_reg_axi_debug_bch_encoder_strobes_m_tvalid = user2regs.axi_debug_bch_encoder_strobes_m_tvalid;
    assign s_reg_axi_debug_bch_encoder_strobes_m_tready = user2regs.axi_debug_bch_encoder_strobes_m_tready;
    assign s_reg_axi_debug_ldpc_encoder_frame_count_value = user2regs.axi_debug_ldpc_encoder_frame_count_value;
    assign s_reg_axi_debug_ldpc_encoder_last_frame_length_value = user2regs.axi_debug_ldpc_encoder_last_frame_length_value;
    assign s_reg_axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length = user2regs.axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length;
    assign s_reg_axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length = user2regs.axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length;
    assign s_reg_axi_debug_ldpc_encoder_word_count_value = user2regs.axi_debug_ldpc_encoder_word_count_value;
    assign s_reg_axi_debug_ldpc_encoder_strobes_s_tvalid = user2regs.axi_debug_ldpc_encoder_strobes_s_tvalid;
    assign s_reg_axi_debug_ldpc_encoder_strobes_s_tready = user2regs.axi_debug_ldpc_encoder_strobes_s_tready;
    assign s_reg_axi_debug_ldpc_encoder_strobes_m_tvalid = user2regs.axi_debug_ldpc_encoder_strobes_m_tvalid;
    assign s_reg_axi_debug_ldpc_encoder_strobes_m_tready = user2regs.axi_debug_ldpc_encoder_strobes_m_tready;
    assign s_reg_axi_debug_bit_interleaver_frame_count_value = user2regs.axi_debug_bit_interleaver_frame_count_value;
    assign s_reg_axi_debug_bit_interleaver_last_frame_length_value = user2regs.axi_debug_bit_interleaver_last_frame_length_value;
    assign s_reg_axi_debug_bit_interleaver_min_max_frame_length_min_frame_length = user2regs.axi_debug_bit_interleaver_min_max_frame_length_min_frame_length;
    assign s_reg_axi_debug_bit_interleaver_min_max_frame_length_max_frame_length = user2regs.axi_debug_bit_interleaver_min_max_frame_length_max_frame_length;
    assign s_reg_axi_debug_bit_interleaver_word_count_value = user2regs.axi_debug_bit_interleaver_word_count_value;
    assign s_reg_axi_debug_bit_interleaver_strobes_s_tvalid = user2regs.axi_debug_bit_interleaver_strobes_s_tvalid;
    assign s_reg_axi_debug_bit_interleaver_strobes_s_tready = user2regs.axi_debug_bit_interleaver_strobes_s_tready;
    assign s_reg_axi_debug_bit_interleaver_strobes_m_tvalid = user2regs.axi_debug_bit_interleaver_strobes_m_tvalid;
    assign s_reg_axi_debug_bit_interleaver_strobes_m_tready = user2regs.axi_debug_bit_interleaver_strobes_m_tready;
    assign s_reg_axi_debug_constellation_mapper_frame_count_value = user2regs.axi_debug_constellation_mapper_frame_count_value;
    assign s_reg_axi_debug_constellation_mapper_last_frame_length_value = user2regs.axi_debug_constellation_mapper_last_frame_length_value;
    assign s_reg_axi_debug_constellation_mapper_min_max_frame_length_min_frame_length = user2regs.axi_debug_constellation_mapper_min_max_frame_length_min_frame_length;
    assign s_reg_axi_debug_constellation_mapper_min_max_frame_length_max_frame_length = user2regs.axi_debug_constellation_mapper_min_max_frame_length_max_frame_length;
    assign s_reg_axi_debug_constellation_mapper_word_count_value = user2regs.axi_debug_constellation_mapper_word_count_value;
    assign s_reg_axi_debug_constellation_mapper_strobes_s_tvalid = user2regs.axi_debug_constellation_mapper_strobes_s_tvalid;
    assign s_reg_axi_debug_constellation_mapper_strobes_s_tready = user2regs.axi_debug_constellation_mapper_strobes_s_tready;
    assign s_reg_axi_debug_constellation_mapper_strobes_m_tvalid = user2regs.axi_debug_constellation_mapper_strobes_m_tvalid;
    assign s_reg_axi_debug_constellation_mapper_strobes_m_tready = user2regs.axi_debug_constellation_mapper_strobes_m_tready;
    assign s_reg_axi_debug_plframe_frame_count_value = user2regs.axi_debug_plframe_frame_count_value;
    assign s_reg_axi_debug_plframe_last_frame_length_value = user2regs.axi_debug_plframe_last_frame_length_value;
    assign s_reg_axi_debug_plframe_min_max_frame_length_min_frame_length = user2regs.axi_debug_plframe_min_max_frame_length_min_frame_length;
    assign s_reg_axi_debug_plframe_min_max_frame_length_max_frame_length = user2regs.axi_debug_plframe_min_max_frame_length_max_frame_length;
    assign s_reg_axi_debug_plframe_word_count_value = user2regs.axi_debug_plframe_word_count_value;
    assign s_reg_axi_debug_plframe_strobes_s_tvalid = user2regs.axi_debug_plframe_strobes_s_tvalid;
    assign s_reg_axi_debug_plframe_strobes_s_tready = user2regs.axi_debug_plframe_strobes_s_tready;
    assign s_reg_axi_debug_plframe_strobes_m_tvalid = user2regs.axi_debug_plframe_strobes_m_tvalid;
    assign s_reg_axi_debug_plframe_strobes_m_tready = user2regs.axi_debug_plframe_strobes_m_tready;

    //----------------------------------------------------------------------------------------------
    // Read-transaction FSM
    //----------------------------------------------------------------------------------------------

    localparam MAX_MEMORY_LATENCY = 5;

    typedef enum {
        READ_IDLE,
        READ_REGISTER,
        WAIT_MEMORY_RDATA,
        READ_RESPONSE,
        READ_DONE
    } read_state_t;

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin: read_fsm
        // Registered state variables
        read_state_t v_state_r;
        logic [31:0] v_rdata_r;
        logic [1:0] v_rresp_r;
        logic [$clog2(MAX_MEMORY_LATENCY)-1:0] v_mem_wait_count_r;
        // Combinatorial helper variables
        logic v_addr_hit;
        logic [AXI_ADDR_WIDTH-1:0] v_mem_addr;
        if (~axi_aresetn) begin
            v_state_r          <= READ_IDLE;
            v_rdata_r          <= '0;
            v_rresp_r          <= '0;
            v_mem_wait_count_r <= '0;
            s_axi_arready_r    <= '0;
            s_axi_rvalid_r     <= '0;
            s_axi_rresp_r      <= '0;
            s_axi_araddr_reg_r <= '0;
            s_axi_rdata_r      <= '0;
            s_ldpc_fifo_status_strobe_r <= '0;
            s_frames_in_transit_strobe_r <= '0;
            s_constellation_map_radius_ram_raddr_r <= '0;
            s_constellation_map_radius_ram_ren_r <= 0;
            s_constellation_map_iq_ram_raddr_r <= '0;
            s_constellation_map_iq_ram_ren_r <= 0;
            s_axi_debug_input_width_converter_frame_count_strobe_r <= '0;
            s_axi_debug_input_width_converter_last_frame_length_strobe_r <= '0;
            s_axi_debug_input_width_converter_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_input_width_converter_word_count_strobe_r <= '0;
            s_axi_debug_input_width_converter_strobes_strobe_r <= '0;
            s_axi_debug_bb_scrambler_frame_count_strobe_r <= '0;
            s_axi_debug_bb_scrambler_last_frame_length_strobe_r <= '0;
            s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_bb_scrambler_word_count_strobe_r <= '0;
            s_axi_debug_bb_scrambler_strobes_strobe_r <= '0;
            s_axi_debug_bch_encoder_frame_count_strobe_r <= '0;
            s_axi_debug_bch_encoder_last_frame_length_strobe_r <= '0;
            s_axi_debug_bch_encoder_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_bch_encoder_word_count_strobe_r <= '0;
            s_axi_debug_bch_encoder_strobes_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_frame_count_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_last_frame_length_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_word_count_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_strobes_strobe_r <= '0;
            s_axi_debug_bit_interleaver_frame_count_strobe_r <= '0;
            s_axi_debug_bit_interleaver_last_frame_length_strobe_r <= '0;
            s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_bit_interleaver_word_count_strobe_r <= '0;
            s_axi_debug_bit_interleaver_strobes_strobe_r <= '0;
            s_axi_debug_constellation_mapper_frame_count_strobe_r <= '0;
            s_axi_debug_constellation_mapper_last_frame_length_strobe_r <= '0;
            s_axi_debug_constellation_mapper_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_constellation_mapper_word_count_strobe_r <= '0;
            s_axi_debug_constellation_mapper_strobes_strobe_r <= '0;
            s_axi_debug_plframe_frame_count_strobe_r <= '0;
            s_axi_debug_plframe_last_frame_length_strobe_r <= '0;
            s_axi_debug_plframe_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_plframe_word_count_strobe_r <= '0;
            s_axi_debug_plframe_strobes_strobe_r <= '0;
        end else begin
            // Default values:
            s_axi_arready_r <= 1'b0;
            s_ldpc_fifo_status_strobe_r <= '0;
            s_frames_in_transit_strobe_r <= '0;
            s_constellation_map_radius_ram_raddr_r <= '0;
            s_constellation_map_iq_ram_raddr_r <= '0;
            s_axi_debug_input_width_converter_frame_count_strobe_r <= '0;
            s_axi_debug_input_width_converter_last_frame_length_strobe_r <= '0;
            s_axi_debug_input_width_converter_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_input_width_converter_word_count_strobe_r <= '0;
            s_axi_debug_input_width_converter_strobes_strobe_r <= '0;
            s_axi_debug_bb_scrambler_frame_count_strobe_r <= '0;
            s_axi_debug_bb_scrambler_last_frame_length_strobe_r <= '0;
            s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_bb_scrambler_word_count_strobe_r <= '0;
            s_axi_debug_bb_scrambler_strobes_strobe_r <= '0;
            s_axi_debug_bch_encoder_frame_count_strobe_r <= '0;
            s_axi_debug_bch_encoder_last_frame_length_strobe_r <= '0;
            s_axi_debug_bch_encoder_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_bch_encoder_word_count_strobe_r <= '0;
            s_axi_debug_bch_encoder_strobes_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_frame_count_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_last_frame_length_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_word_count_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_strobes_strobe_r <= '0;
            s_axi_debug_bit_interleaver_frame_count_strobe_r <= '0;
            s_axi_debug_bit_interleaver_last_frame_length_strobe_r <= '0;
            s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_bit_interleaver_word_count_strobe_r <= '0;
            s_axi_debug_bit_interleaver_strobes_strobe_r <= '0;
            s_axi_debug_constellation_mapper_frame_count_strobe_r <= '0;
            s_axi_debug_constellation_mapper_last_frame_length_strobe_r <= '0;
            s_axi_debug_constellation_mapper_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_constellation_mapper_word_count_strobe_r <= '0;
            s_axi_debug_constellation_mapper_strobes_strobe_r <= '0;
            s_axi_debug_plframe_frame_count_strobe_r <= '0;
            s_axi_debug_plframe_last_frame_length_strobe_r <= '0;
            s_axi_debug_plframe_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_plframe_word_count_strobe_r <= '0;
            s_axi_debug_plframe_strobes_strobe_r <= '0;

            case (v_state_r) // sigasi @suppress "Default clause missing from case statement"

                // Wait for the start of a read transaction, which is
                // initiated by the assertion of ARVALID
                READ_IDLE: begin
                    if (s_axi_arvalid) begin
                        s_axi_araddr_reg_r <= s_axi_araddr;     // save the read address
                        s_axi_arready_r    <= 1'b1;             // acknowledge the read-address
                        v_state_r          <= READ_REGISTER;
                    end
                end

                // Read from the actual storage element
                READ_REGISTER: begin
                    // Defaults:
                    v_addr_hit = 1'b0;
                    v_rdata_r  <= '0;

                    // Register 'config' at address offset 0x0
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::CONFIG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[17:0] <= s_reg_config_physical_layer_scrambler_shift_reg_init_r;
                        v_rdata_r[18:18] <= s_reg_config_enable_dummy_frames_r;
                        v_rdata_r[19:19] <= s_reg_config_swap_input_data_byte_endianness_r;
                        v_rdata_r[20:20] <= s_reg_config_swap_output_data_byte_endianness_r;
                        v_rdata_r[21:21] <= s_reg_config_force_output_ready_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'ldpc_fifo_status' at address offset 0x4
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::LDPC_FIFO_STATUS_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[13:0] <= s_reg_ldpc_fifo_status_ldpc_fifo_entries;
                        v_rdata_r[16:16] <= s_reg_ldpc_fifo_status_ldpc_fifo_empty;
                        v_rdata_r[17:17] <= s_reg_ldpc_fifo_status_ldpc_fifo_full;
                        v_rdata_r[21:20] <= s_reg_ldpc_fifo_status_arbiter_selected;
                        s_ldpc_fifo_status_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'frames_in_transit' at address offset 0x8
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::FRAMES_IN_TRANSIT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[7:0] <= s_reg_frames_in_transit_value;
                        s_frames_in_transit_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Memory 'constellation_map_radius_ram' at address offset 0x10
                    if (s_axi_araddr_reg_r >= AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_RADIUS_RAM_OFFSET) &&
                        s_axi_araddr_reg_r < AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_RADIUS_RAM_OFFSET + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_RADIUS_RAM_DEPTH * 4)) begin
                        v_addr_hit = 1'b1;
                        // Generate memory read address:
                        v_mem_addr = s_axi_araddr_reg_r - AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_RADIUS_RAM_OFFSET);
                        s_constellation_map_radius_ram_raddr_r <= v_mem_addr[6:2]; // output address has 4-byte granularity
                        s_constellation_map_radius_ram_ren_r <= 1;
                        v_mem_wait_count_r <= dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_RADIUS_RAM_READ_LATENCY;
                        v_state_r <= WAIT_MEMORY_RDATA;
                    end
                    // Memory 'constellation_map_iq_ram' at address offset 0x110
                    if (s_axi_araddr_reg_r >= AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_IQ_RAM_OFFSET) &&
                        s_axi_araddr_reg_r < AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_IQ_RAM_OFFSET + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_IQ_RAM_DEPTH * 4)) begin
                        v_addr_hit = 1'b1;
                        // Generate memory read address:
                        v_mem_addr = s_axi_araddr_reg_r - AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_IQ_RAM_OFFSET);
                        s_constellation_map_iq_ram_raddr_r <= v_mem_addr[7:2]; // output address has 4-byte granularity
                        s_constellation_map_iq_ram_ren_r <= 1;
                        v_mem_wait_count_r <= dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_IQ_RAM_READ_LATENCY;
                        v_state_r <= WAIT_MEMORY_RDATA;
                    end
                    // Register 'axi_debug_input_width_converter_cfg' at address offset 0xD00
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_input_width_converter_cfg_block_data_r;
                        v_rdata_r[1:1] <= s_reg_axi_debug_input_width_converter_cfg_allow_word_r;
                        v_rdata_r[2:2] <= s_reg_axi_debug_input_width_converter_cfg_allow_frame_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_input_width_converter_frame_count' at address offset 0xD04
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_input_width_converter_frame_count_value;
                        s_axi_debug_input_width_converter_frame_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_input_width_converter_last_frame_length' at address offset 0xD08
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_input_width_converter_last_frame_length_value;
                        s_axi_debug_input_width_converter_last_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_input_width_converter_min_max_frame_length' at address offset 0xD0C
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_input_width_converter_min_max_frame_length_min_frame_length;
                        v_rdata_r[31:16] <= s_reg_axi_debug_input_width_converter_min_max_frame_length_max_frame_length;
                        s_axi_debug_input_width_converter_min_max_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_input_width_converter_word_count' at address offset 0xD10
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_input_width_converter_word_count_value;
                        s_axi_debug_input_width_converter_word_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_input_width_converter_strobes' at address offset 0xD14
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_input_width_converter_strobes_s_tvalid;
                        v_rdata_r[1:1] <= s_reg_axi_debug_input_width_converter_strobes_s_tready;
                        v_rdata_r[2:2] <= s_reg_axi_debug_input_width_converter_strobes_m_tvalid;
                        v_rdata_r[3:3] <= s_reg_axi_debug_input_width_converter_strobes_m_tready;
                        s_axi_debug_input_width_converter_strobes_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bb_scrambler_cfg' at address offset 0xE00
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_CFG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_bb_scrambler_cfg_block_data_r;
                        v_rdata_r[1:1] <= s_reg_axi_debug_bb_scrambler_cfg_allow_word_r;
                        v_rdata_r[2:2] <= s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bb_scrambler_frame_count' at address offset 0xE04
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bb_scrambler_frame_count_value;
                        s_axi_debug_bb_scrambler_frame_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bb_scrambler_last_frame_length' at address offset 0xE08
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bb_scrambler_last_frame_length_value;
                        s_axi_debug_bb_scrambler_last_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bb_scrambler_min_max_frame_length' at address offset 0xE0C
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bb_scrambler_min_max_frame_length_min_frame_length;
                        v_rdata_r[31:16] <= s_reg_axi_debug_bb_scrambler_min_max_frame_length_max_frame_length;
                        s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bb_scrambler_word_count' at address offset 0xE10
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bb_scrambler_word_count_value;
                        s_axi_debug_bb_scrambler_word_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bb_scrambler_strobes' at address offset 0xE14
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_STROBES_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_bb_scrambler_strobes_s_tvalid;
                        v_rdata_r[1:1] <= s_reg_axi_debug_bb_scrambler_strobes_s_tready;
                        v_rdata_r[2:2] <= s_reg_axi_debug_bb_scrambler_strobes_m_tvalid;
                        v_rdata_r[3:3] <= s_reg_axi_debug_bb_scrambler_strobes_m_tready;
                        s_axi_debug_bb_scrambler_strobes_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bch_encoder_cfg' at address offset 0xF00
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_CFG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_bch_encoder_cfg_block_data_r;
                        v_rdata_r[1:1] <= s_reg_axi_debug_bch_encoder_cfg_allow_word_r;
                        v_rdata_r[2:2] <= s_reg_axi_debug_bch_encoder_cfg_allow_frame_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bch_encoder_frame_count' at address offset 0xF04
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bch_encoder_frame_count_value;
                        s_axi_debug_bch_encoder_frame_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bch_encoder_last_frame_length' at address offset 0xF08
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bch_encoder_last_frame_length_value;
                        s_axi_debug_bch_encoder_last_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bch_encoder_min_max_frame_length' at address offset 0xF0C
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bch_encoder_min_max_frame_length_min_frame_length;
                        v_rdata_r[31:16] <= s_reg_axi_debug_bch_encoder_min_max_frame_length_max_frame_length;
                        s_axi_debug_bch_encoder_min_max_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bch_encoder_word_count' at address offset 0xF10
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_WORD_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bch_encoder_word_count_value;
                        s_axi_debug_bch_encoder_word_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bch_encoder_strobes' at address offset 0xF14
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_STROBES_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_bch_encoder_strobes_s_tvalid;
                        v_rdata_r[1:1] <= s_reg_axi_debug_bch_encoder_strobes_s_tready;
                        v_rdata_r[2:2] <= s_reg_axi_debug_bch_encoder_strobes_m_tvalid;
                        v_rdata_r[3:3] <= s_reg_axi_debug_bch_encoder_strobes_m_tready;
                        s_axi_debug_bch_encoder_strobes_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_ldpc_encoder_cfg' at address offset 0x1000
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_CFG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_ldpc_encoder_cfg_block_data_r;
                        v_rdata_r[1:1] <= s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r;
                        v_rdata_r[2:2] <= s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_ldpc_encoder_frame_count' at address offset 0x1004
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_ldpc_encoder_frame_count_value;
                        s_axi_debug_ldpc_encoder_frame_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_ldpc_encoder_last_frame_length' at address offset 0x1008
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_ldpc_encoder_last_frame_length_value;
                        s_axi_debug_ldpc_encoder_last_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_ldpc_encoder_min_max_frame_length' at address offset 0x100C
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length;
                        v_rdata_r[31:16] <= s_reg_axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length;
                        s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_ldpc_encoder_word_count' at address offset 0x1010
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_ldpc_encoder_word_count_value;
                        s_axi_debug_ldpc_encoder_word_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_ldpc_encoder_strobes' at address offset 0x1014
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_STROBES_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_ldpc_encoder_strobes_s_tvalid;
                        v_rdata_r[1:1] <= s_reg_axi_debug_ldpc_encoder_strobes_s_tready;
                        v_rdata_r[2:2] <= s_reg_axi_debug_ldpc_encoder_strobes_m_tvalid;
                        v_rdata_r[3:3] <= s_reg_axi_debug_ldpc_encoder_strobes_m_tready;
                        s_axi_debug_ldpc_encoder_strobes_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bit_interleaver_cfg' at address offset 0x1100
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_CFG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_bit_interleaver_cfg_block_data_r;
                        v_rdata_r[1:1] <= s_reg_axi_debug_bit_interleaver_cfg_allow_word_r;
                        v_rdata_r[2:2] <= s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bit_interleaver_frame_count' at address offset 0x1104
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bit_interleaver_frame_count_value;
                        s_axi_debug_bit_interleaver_frame_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bit_interleaver_last_frame_length' at address offset 0x1108
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bit_interleaver_last_frame_length_value;
                        s_axi_debug_bit_interleaver_last_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bit_interleaver_min_max_frame_length' at address offset 0x110C
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bit_interleaver_min_max_frame_length_min_frame_length;
                        v_rdata_r[31:16] <= s_reg_axi_debug_bit_interleaver_min_max_frame_length_max_frame_length;
                        s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bit_interleaver_word_count' at address offset 0x1110
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bit_interleaver_word_count_value;
                        s_axi_debug_bit_interleaver_word_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_bit_interleaver_strobes' at address offset 0x1114
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_STROBES_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_bit_interleaver_strobes_s_tvalid;
                        v_rdata_r[1:1] <= s_reg_axi_debug_bit_interleaver_strobes_s_tready;
                        v_rdata_r[2:2] <= s_reg_axi_debug_bit_interleaver_strobes_m_tvalid;
                        v_rdata_r[3:3] <= s_reg_axi_debug_bit_interleaver_strobes_m_tready;
                        s_axi_debug_bit_interleaver_strobes_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_constellation_mapper_cfg' at address offset 0x1200
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_CONSTELLATION_MAPPER_CFG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_constellation_mapper_cfg_block_data_r;
                        v_rdata_r[1:1] <= s_reg_axi_debug_constellation_mapper_cfg_allow_word_r;
                        v_rdata_r[2:2] <= s_reg_axi_debug_constellation_mapper_cfg_allow_frame_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_constellation_mapper_frame_count' at address offset 0x1204
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_CONSTELLATION_MAPPER_FRAME_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_constellation_mapper_frame_count_value;
                        s_axi_debug_constellation_mapper_frame_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_constellation_mapper_last_frame_length' at address offset 0x1208
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_CONSTELLATION_MAPPER_LAST_FRAME_LENGTH_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_constellation_mapper_last_frame_length_value;
                        s_axi_debug_constellation_mapper_last_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_constellation_mapper_min_max_frame_length' at address offset 0x120C
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_constellation_mapper_min_max_frame_length_min_frame_length;
                        v_rdata_r[31:16] <= s_reg_axi_debug_constellation_mapper_min_max_frame_length_max_frame_length;
                        s_axi_debug_constellation_mapper_min_max_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_constellation_mapper_word_count' at address offset 0x1210
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_CONSTELLATION_MAPPER_WORD_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_constellation_mapper_word_count_value;
                        s_axi_debug_constellation_mapper_word_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_constellation_mapper_strobes' at address offset 0x1214
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_constellation_mapper_strobes_s_tvalid;
                        v_rdata_r[1:1] <= s_reg_axi_debug_constellation_mapper_strobes_s_tready;
                        v_rdata_r[2:2] <= s_reg_axi_debug_constellation_mapper_strobes_m_tvalid;
                        v_rdata_r[3:3] <= s_reg_axi_debug_constellation_mapper_strobes_m_tready;
                        s_axi_debug_constellation_mapper_strobes_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_plframe_cfg' at address offset 0x1300
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_CFG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_plframe_cfg_block_data_r;
                        v_rdata_r[1:1] <= s_reg_axi_debug_plframe_cfg_allow_word_r;
                        v_rdata_r[2:2] <= s_reg_axi_debug_plframe_cfg_allow_frame_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_plframe_frame_count' at address offset 0x1304
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_FRAME_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_plframe_frame_count_value;
                        s_axi_debug_plframe_frame_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_plframe_last_frame_length' at address offset 0x1308
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_plframe_last_frame_length_value;
                        s_axi_debug_plframe_last_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_plframe_min_max_frame_length' at address offset 0x130C
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_plframe_min_max_frame_length_min_frame_length;
                        v_rdata_r[31:16] <= s_reg_axi_debug_plframe_min_max_frame_length_max_frame_length;
                        s_axi_debug_plframe_min_max_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_plframe_word_count' at address offset 0x1310
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_WORD_COUNT_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_plframe_word_count_value;
                        s_axi_debug_plframe_word_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // Register 'axi_debug_plframe_strobes' at address offset 0x1314
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_STROBES_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_plframe_strobes_s_tvalid;
                        v_rdata_r[1:1] <= s_reg_axi_debug_plframe_strobes_s_tready;
                        v_rdata_r[2:2] <= s_reg_axi_debug_plframe_strobes_m_tvalid;
                        v_rdata_r[3:3] <= s_reg_axi_debug_plframe_strobes_m_tready;
                        s_axi_debug_plframe_strobes_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    if (v_addr_hit) begin
                        v_rresp_r <= AXI_OKAY;
                    end else begin
                        v_rresp_r <= AXI_SLVERR;
                        // pragma translate_off
                        $warning("ARADDR decode error");
                        // pragma translate_on
                        v_state_r <= READ_RESPONSE;
                    end
                end

                // Wait for memory read data
                WAIT_MEMORY_RDATA: begin
                    if (v_mem_wait_count_r == 0) begin
                        // Memory 'constellation_map_radius_ram' at address offset 0x10
                        if (s_axi_araddr_reg_r >= AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_RADIUS_RAM_OFFSET) &&
                            s_axi_araddr_reg_r < AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_RADIUS_RAM_OFFSET + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_RADIUS_RAM_DEPTH * 4)) begin
                            v_rdata_r[31:0] <= s_constellation_map_radius_ram_rdata[31:0];
                            s_constellation_map_radius_ram_ren_r <= 0;
                        end
                        // Memory 'constellation_map_iq_ram' at address offset 0x110
                        if (s_axi_araddr_reg_r >= AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_IQ_RAM_OFFSET) &&
                            s_axi_araddr_reg_r < AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_IQ_RAM_OFFSET + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_IQ_RAM_DEPTH * 4)) begin
                            v_rdata_r[31:0] <= s_constellation_map_iq_ram_rdata[31:0];
                            s_constellation_map_iq_ram_ren_r <= 0;
                        end
                        v_state_r <= READ_RESPONSE;
                    end else begin
                        v_mem_wait_count_r <= v_mem_wait_count_r - 1;
                    end
                end

                // Generate read response
                READ_RESPONSE: begin
                    s_axi_rvalid_r <= 1'b1;
                    s_axi_rresp_r  <= v_rresp_r;
                    s_axi_rdata_r  <= v_rdata_r;
                    v_state_r      <= READ_DONE;
                end

                // Write transaction completed, wait for master RREADY to proceed
                READ_DONE: begin
                    if (s_axi_rready) begin
                        s_axi_rvalid_r <= 1'b0;
                        s_axi_rdata_r  <= '0;
                        v_state_r      <= READ_IDLE;
                    end
                end

            endcase
        end
    end: read_fsm

    //----------------------------------------------------------------------------------------------
    // Write-transaction FSM
    //----------------------------------------------------------------------------------------------

    typedef enum {
        WRITE_IDLE,
        WRITE_ADDR_FIRST,
        WRITE_DATA_FIRST,
        WRITE_UPDATE_REGISTER,
        WRITE_DONE
    } write_state_t;

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin: write_fsm
        // Registered state variables
        write_state_t v_state_r;
        // Combinatorial helper variables
        logic v_addr_hit;
        logic [AXI_ADDR_WIDTH-1:0] v_mem_addr;
        if (~axi_aresetn) begin
            v_state_r                   <= WRITE_IDLE;
            s_axi_awready_r             <= 1'b0;
            s_axi_wready_r              <= 1'b0;
            s_axi_awaddr_reg_r          <= '0;
            s_axi_wdata_reg_r           <= '0;
            s_axi_wstrb_reg_r           <= '0;
            s_axi_bvalid_r              <= 1'b0;
            s_axi_bresp_r               <= '0;

            s_config_strobe_r <= '0;
            s_reg_config_physical_layer_scrambler_shift_reg_init_r <= dvbs2_encoder_regs_pkg::CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_RESET;
            s_reg_config_enable_dummy_frames_r <= dvbs2_encoder_regs_pkg::CONFIG_ENABLE_DUMMY_FRAMES_RESET;
            s_reg_config_swap_input_data_byte_endianness_r <= dvbs2_encoder_regs_pkg::CONFIG_SWAP_INPUT_DATA_BYTE_ENDIANNESS_RESET;
            s_reg_config_swap_output_data_byte_endianness_r <= dvbs2_encoder_regs_pkg::CONFIG_SWAP_OUTPUT_DATA_BYTE_ENDIANNESS_RESET;
            s_reg_config_force_output_ready_r <= dvbs2_encoder_regs_pkg::CONFIG_FORCE_OUTPUT_READY_RESET;
            s_constellation_map_radius_ram_waddr_r <= '0;
            s_constellation_map_radius_ram_wen_r <= '0;
            s_constellation_map_radius_ram_wdata_r <= '0;
            s_constellation_map_iq_ram_waddr_r <= '0;
            s_constellation_map_iq_ram_wen_r <= '0;
            s_constellation_map_iq_ram_wdata_r <= '0;
            s_axi_debug_input_width_converter_cfg_strobe_r <= '0;
            s_reg_axi_debug_input_width_converter_cfg_block_data_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_input_width_converter_cfg_allow_word_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_input_width_converter_cfg_allow_frame_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_RESET;
            s_axi_debug_bb_scrambler_cfg_strobe_r <= '0;
            s_reg_axi_debug_bb_scrambler_cfg_block_data_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_bb_scrambler_cfg_allow_word_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_RESET;
            s_axi_debug_bch_encoder_cfg_strobe_r <= '0;
            s_reg_axi_debug_bch_encoder_cfg_block_data_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_bch_encoder_cfg_allow_word_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_bch_encoder_cfg_allow_frame_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_RESET;
            s_axi_debug_ldpc_encoder_cfg_strobe_r <= '0;
            s_reg_axi_debug_ldpc_encoder_cfg_block_data_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_RESET;
            s_axi_debug_bit_interleaver_cfg_strobe_r <= '0;
            s_reg_axi_debug_bit_interleaver_cfg_block_data_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_bit_interleaver_cfg_allow_word_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_RESET;
            s_axi_debug_constellation_mapper_cfg_strobe_r <= '0;
            s_reg_axi_debug_constellation_mapper_cfg_block_data_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_CONSTELLATION_MAPPER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_constellation_mapper_cfg_allow_word_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_constellation_mapper_cfg_allow_frame_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_FRAME_RESET;
            s_axi_debug_plframe_cfg_strobe_r <= '0;
            s_reg_axi_debug_plframe_cfg_block_data_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_plframe_cfg_allow_word_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_plframe_cfg_allow_frame_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_RESET;

        end else begin
            // Default values:
            s_axi_awready_r <= 1'b0;
            s_axi_wready_r  <= 1'b0;
            s_config_strobe_r <= '0;
            s_constellation_map_radius_ram_waddr_r <= '0; // always reset to zero because of wired OR
            s_constellation_map_radius_ram_wen_r <= '0;
            s_constellation_map_iq_ram_waddr_r <= '0; // always reset to zero because of wired OR
            s_constellation_map_iq_ram_wen_r <= '0;
            s_axi_debug_input_width_converter_cfg_strobe_r <= '0;
            s_axi_debug_bb_scrambler_cfg_strobe_r <= '0;
            s_axi_debug_bch_encoder_cfg_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_cfg_strobe_r <= '0;
            s_axi_debug_bit_interleaver_cfg_strobe_r <= '0;
            s_axi_debug_constellation_mapper_cfg_strobe_r <= '0;
            s_axi_debug_plframe_cfg_strobe_r <= '0;
            v_addr_hit = 1'b0;

            // Self-clearing fields:
            s_reg_axi_debug_input_width_converter_cfg_allow_word_r <= '0;
            s_reg_axi_debug_input_width_converter_cfg_allow_frame_r <= '0;
            s_reg_axi_debug_bb_scrambler_cfg_allow_word_r <= '0;
            s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r <= '0;
            s_reg_axi_debug_bch_encoder_cfg_allow_word_r <= '0;
            s_reg_axi_debug_bch_encoder_cfg_allow_frame_r <= '0;
            s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r <= '0;
            s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r <= '0;
            s_reg_axi_debug_bit_interleaver_cfg_allow_word_r <= '0;
            s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r <= '0;
            s_reg_axi_debug_constellation_mapper_cfg_allow_word_r <= '0;
            s_reg_axi_debug_constellation_mapper_cfg_allow_frame_r <= '0;
            s_reg_axi_debug_plframe_cfg_allow_word_r <= '0;
            s_reg_axi_debug_plframe_cfg_allow_frame_r <= '0;

            case (v_state_r) // sigasi @suppress "Default clause missing from case statement"

                // Wait for the start of a write transaction, which may be
                // initiated by either of the following conditions:
                //   * assertion of both AWVALID and WVALID
                //   * assertion of AWVALID
                //   * assertion of WVALID
                WRITE_IDLE: begin
                    if (s_axi_awvalid && s_axi_wvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        s_axi_wdata_reg_r  <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r  <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r     <= 1'b1; // acknowledge the write-data
                        v_state_r          <= WRITE_UPDATE_REGISTER;
                    end else if (s_axi_awvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        v_state_r          <= WRITE_ADDR_FIRST;
                    end else if (s_axi_wvalid) begin
                        s_axi_wdata_reg_r <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r    <= 1'b1; // acknowledge the write-data
                        v_state_r         <= WRITE_DATA_FIRST;
                    end
                end

                // Address-first write transaction: wait for the write-data
                WRITE_ADDR_FIRST: begin
                    if (s_axi_wvalid) begin
                        s_axi_wdata_reg_r <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r    <= 1'b1; // acknowledge the write-data
                        v_state_r         <= WRITE_UPDATE_REGISTER;
                    end
                end

                // Data-first write transaction: wait for the write-address
                WRITE_DATA_FIRST: begin
                    if (s_axi_awvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        v_state_r          <= WRITE_UPDATE_REGISTER;
                    end
                end

                // Update the actual storage element
                WRITE_UPDATE_REGISTER: begin
                    s_axi_bresp_r  <= AXI_OKAY; // default value, may be overriden in case of decode error
                    s_axi_bvalid_r <= 1'b1;

                    // Register  'config' at address offset 0x0
                    if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::CONFIG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        s_config_strobe_r <= 1'b1;
                        // field 'physical_layer_scrambler_shift_reg_init':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[0] <= s_axi_wdata_reg_r[0]; // physical_layer_scrambler_shift_reg_init[0]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[1] <= s_axi_wdata_reg_r[1]; // physical_layer_scrambler_shift_reg_init[1]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[2] <= s_axi_wdata_reg_r[2]; // physical_layer_scrambler_shift_reg_init[2]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[3] <= s_axi_wdata_reg_r[3]; // physical_layer_scrambler_shift_reg_init[3]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[4] <= s_axi_wdata_reg_r[4]; // physical_layer_scrambler_shift_reg_init[4]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[5] <= s_axi_wdata_reg_r[5]; // physical_layer_scrambler_shift_reg_init[5]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[6] <= s_axi_wdata_reg_r[6]; // physical_layer_scrambler_shift_reg_init[6]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[7] <= s_axi_wdata_reg_r[7]; // physical_layer_scrambler_shift_reg_init[7]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[8] <= s_axi_wdata_reg_r[8]; // physical_layer_scrambler_shift_reg_init[8]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[9] <= s_axi_wdata_reg_r[9]; // physical_layer_scrambler_shift_reg_init[9]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[10] <= s_axi_wdata_reg_r[10]; // physical_layer_scrambler_shift_reg_init[10]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[11] <= s_axi_wdata_reg_r[11]; // physical_layer_scrambler_shift_reg_init[11]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[12] <= s_axi_wdata_reg_r[12]; // physical_layer_scrambler_shift_reg_init[12]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[13] <= s_axi_wdata_reg_r[13]; // physical_layer_scrambler_shift_reg_init[13]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[14] <= s_axi_wdata_reg_r[14]; // physical_layer_scrambler_shift_reg_init[14]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[15] <= s_axi_wdata_reg_r[15]; // physical_layer_scrambler_shift_reg_init[15]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[16] <= s_axi_wdata_reg_r[16]; // physical_layer_scrambler_shift_reg_init[16]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_config_physical_layer_scrambler_shift_reg_init_r[17] <= s_axi_wdata_reg_r[17]; // physical_layer_scrambler_shift_reg_init[17]
                        end
                        // field 'enable_dummy_frames':
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_config_enable_dummy_frames_r[0] <= s_axi_wdata_reg_r[18]; // enable_dummy_frames[0]
                        end
                        // field 'swap_input_data_byte_endianness':
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_config_swap_input_data_byte_endianness_r[0] <= s_axi_wdata_reg_r[19]; // swap_input_data_byte_endianness[0]
                        end
                        // field 'swap_output_data_byte_endianness':
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_config_swap_output_data_byte_endianness_r[0] <= s_axi_wdata_reg_r[20]; // swap_output_data_byte_endianness[0]
                        end
                        // field 'force_output_ready':
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_config_force_output_ready_r[0] <= s_axi_wdata_reg_r[21]; // force_output_ready[0]
                        end
                    end



                    // Memory 'constellation_map_radius_ram' at address offset 0x10
                    if (s_axi_awaddr_reg_r >= AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_RADIUS_RAM_OFFSET) &&
                        s_axi_awaddr_reg_r < AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_RADIUS_RAM_OFFSET + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_RADIUS_RAM_DEPTH * 4)) begin
                        v_addr_hit = 1'b1;
                        v_mem_addr = s_axi_awaddr_reg_r - AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_RADIUS_RAM_OFFSET);
                        s_constellation_map_radius_ram_waddr_r <= v_mem_addr[6:2]; // output address has 4-byte granularity
                        s_constellation_map_radius_ram_wen_r <= s_axi_wstrb_reg_r;
                        s_constellation_map_radius_ram_wdata_r <= s_axi_wdata_reg_r;
                    end

                    // Memory 'constellation_map_iq_ram' at address offset 0x110
                    if (s_axi_awaddr_reg_r >= AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_IQ_RAM_OFFSET) &&
                        s_axi_awaddr_reg_r < AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_IQ_RAM_OFFSET + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_IQ_RAM_DEPTH * 4)) begin
                        v_addr_hit = 1'b1;
                        v_mem_addr = s_axi_awaddr_reg_r - AXI_ADDR_WIDTH'(BASEADDR + dvbs2_encoder_regs_pkg::CONSTELLATION_MAP_IQ_RAM_OFFSET);
                        s_constellation_map_iq_ram_waddr_r <= v_mem_addr[7:2]; // output address has 4-byte granularity
                        s_constellation_map_iq_ram_wen_r <= s_axi_wstrb_reg_r;
                        s_constellation_map_iq_ram_wdata_r <= s_axi_wdata_reg_r;
                    end

                    // Register  'axi_debug_input_width_converter_cfg' at address offset 0xD00
                    if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        s_axi_debug_input_width_converter_cfg_strobe_r <= 1'b1;
                        // field 'block_data':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_input_width_converter_cfg_block_data_r[0] <= s_axi_wdata_reg_r[0]; // block_data[0]
                        end
                        // field 'allow_word':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_input_width_converter_cfg_allow_word_r[0] <= s_axi_wdata_reg_r[1]; // allow_word[0]
                        end
                        // field 'allow_frame':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_input_width_converter_cfg_allow_frame_r[0] <= s_axi_wdata_reg_r[2]; // allow_frame[0]
                        end
                    end






                    // Register  'axi_debug_bb_scrambler_cfg' at address offset 0xE00
                    if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_CFG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        s_axi_debug_bb_scrambler_cfg_strobe_r <= 1'b1;
                        // field 'block_data':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_bb_scrambler_cfg_block_data_r[0] <= s_axi_wdata_reg_r[0]; // block_data[0]
                        end
                        // field 'allow_word':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_bb_scrambler_cfg_allow_word_r[0] <= s_axi_wdata_reg_r[1]; // allow_word[0]
                        end
                        // field 'allow_frame':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r[0] <= s_axi_wdata_reg_r[2]; // allow_frame[0]
                        end
                    end






                    // Register  'axi_debug_bch_encoder_cfg' at address offset 0xF00
                    if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_CFG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        s_axi_debug_bch_encoder_cfg_strobe_r <= 1'b1;
                        // field 'block_data':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_bch_encoder_cfg_block_data_r[0] <= s_axi_wdata_reg_r[0]; // block_data[0]
                        end
                        // field 'allow_word':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_bch_encoder_cfg_allow_word_r[0] <= s_axi_wdata_reg_r[1]; // allow_word[0]
                        end
                        // field 'allow_frame':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_bch_encoder_cfg_allow_frame_r[0] <= s_axi_wdata_reg_r[2]; // allow_frame[0]
                        end
                    end






                    // Register  'axi_debug_ldpc_encoder_cfg' at address offset 0x1000
                    if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_CFG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        s_axi_debug_ldpc_encoder_cfg_strobe_r <= 1'b1;
                        // field 'block_data':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_ldpc_encoder_cfg_block_data_r[0] <= s_axi_wdata_reg_r[0]; // block_data[0]
                        end
                        // field 'allow_word':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r[0] <= s_axi_wdata_reg_r[1]; // allow_word[0]
                        end
                        // field 'allow_frame':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r[0] <= s_axi_wdata_reg_r[2]; // allow_frame[0]
                        end
                    end






                    // Register  'axi_debug_bit_interleaver_cfg' at address offset 0x1100
                    if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_CFG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        s_axi_debug_bit_interleaver_cfg_strobe_r <= 1'b1;
                        // field 'block_data':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_bit_interleaver_cfg_block_data_r[0] <= s_axi_wdata_reg_r[0]; // block_data[0]
                        end
                        // field 'allow_word':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_bit_interleaver_cfg_allow_word_r[0] <= s_axi_wdata_reg_r[1]; // allow_word[0]
                        end
                        // field 'allow_frame':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r[0] <= s_axi_wdata_reg_r[2]; // allow_frame[0]
                        end
                    end






                    // Register  'axi_debug_constellation_mapper_cfg' at address offset 0x1200
                    if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_CONSTELLATION_MAPPER_CFG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        s_axi_debug_constellation_mapper_cfg_strobe_r <= 1'b1;
                        // field 'block_data':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_constellation_mapper_cfg_block_data_r[0] <= s_axi_wdata_reg_r[0]; // block_data[0]
                        end
                        // field 'allow_word':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_constellation_mapper_cfg_allow_word_r[0] <= s_axi_wdata_reg_r[1]; // allow_word[0]
                        end
                        // field 'allow_frame':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_constellation_mapper_cfg_allow_frame_r[0] <= s_axi_wdata_reg_r[2]; // allow_frame[0]
                        end
                    end






                    // Register  'axi_debug_plframe_cfg' at address offset 0x1300
                    if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_CFG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        s_axi_debug_plframe_cfg_strobe_r <= 1'b1;
                        // field 'block_data':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_plframe_cfg_block_data_r[0] <= s_axi_wdata_reg_r[0]; // block_data[0]
                        end
                        // field 'allow_word':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_plframe_cfg_allow_word_r[0] <= s_axi_wdata_reg_r[1]; // allow_word[0]
                        end
                        // field 'allow_frame':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_plframe_cfg_allow_frame_r[0] <= s_axi_wdata_reg_r[2]; // allow_frame[0]
                        end
                    end






                    if (!v_addr_hit) begin
                        s_axi_bresp_r   <= AXI_SLVERR;
                        // pragma translate_off
                        $warning("AWADDR decode error");
                        // pragma translate_on
                    end
                    v_state_r <= WRITE_DONE;
                end

                // Write transaction completed, wait for master BREADY to proceed
                WRITE_DONE: begin
                    if (s_axi_bready) begin
                        s_axi_bvalid_r <= 1'b0;
                        v_state_r      <= WRITE_IDLE;
                    end
                end
            endcase


        end
    end: write_fsm

    //----------------------------------------------------------------------------------------------
    // Outputs
    //----------------------------------------------------------------------------------------------

    assign s_axi_awready = s_axi_awready_r;
    assign s_axi_wready  = s_axi_wready_r;
    assign s_axi_bvalid  = s_axi_bvalid_r;
    assign s_axi_bresp   = s_axi_bresp_r;
    assign s_axi_arready = s_axi_arready_r;
    assign s_axi_rvalid  = s_axi_rvalid_r;
    assign s_axi_rresp   = s_axi_rresp_r;
    assign s_axi_rdata   = s_axi_rdata_r;

    assign regs2user.config_strobe = s_config_strobe_r;
    assign regs2user.config_physical_layer_scrambler_shift_reg_init = s_reg_config_physical_layer_scrambler_shift_reg_init_r;
    assign regs2user.config_enable_dummy_frames = s_reg_config_enable_dummy_frames_r;
    assign regs2user.config_swap_input_data_byte_endianness = s_reg_config_swap_input_data_byte_endianness_r;
    assign regs2user.config_swap_output_data_byte_endianness = s_reg_config_swap_output_data_byte_endianness_r;
    assign regs2user.config_force_output_ready = s_reg_config_force_output_ready_r;
    assign regs2user.ldpc_fifo_status_strobe = s_ldpc_fifo_status_strobe_r;
    assign regs2user.frames_in_transit_strobe = s_frames_in_transit_strobe_r;
    assign regs2user.constellation_map_radius_ram_addr = s_constellation_map_radius_ram_waddr_r | s_constellation_map_radius_ram_raddr_r; // using wired OR as read/write address multiplexer
    assign regs2user.constellation_map_radius_ram_wen = s_constellation_map_radius_ram_wen_r;
    assign regs2user.constellation_map_radius_ram_wdata = s_constellation_map_radius_ram_wdata_r;
    assign regs2user.constellation_map_radius_ram_ren = s_constellation_map_radius_ram_ren_r;
    assign regs2user.constellation_map_iq_ram_addr = s_constellation_map_iq_ram_waddr_r | s_constellation_map_iq_ram_raddr_r; // using wired OR as read/write address multiplexer
    assign regs2user.constellation_map_iq_ram_wen = s_constellation_map_iq_ram_wen_r;
    assign regs2user.constellation_map_iq_ram_wdata = s_constellation_map_iq_ram_wdata_r;
    assign regs2user.constellation_map_iq_ram_ren = s_constellation_map_iq_ram_ren_r;
    assign regs2user.axi_debug_input_width_converter_cfg_strobe = s_axi_debug_input_width_converter_cfg_strobe_r;
    assign regs2user.axi_debug_input_width_converter_cfg_block_data = s_reg_axi_debug_input_width_converter_cfg_block_data_r;
    assign regs2user.axi_debug_input_width_converter_cfg_allow_word = s_reg_axi_debug_input_width_converter_cfg_allow_word_r;
    assign regs2user.axi_debug_input_width_converter_cfg_allow_frame = s_reg_axi_debug_input_width_converter_cfg_allow_frame_r;
    assign regs2user.axi_debug_input_width_converter_frame_count_strobe = s_axi_debug_input_width_converter_frame_count_strobe_r;
    assign regs2user.axi_debug_input_width_converter_last_frame_length_strobe = s_axi_debug_input_width_converter_last_frame_length_strobe_r;
    assign regs2user.axi_debug_input_width_converter_min_max_frame_length_strobe = s_axi_debug_input_width_converter_min_max_frame_length_strobe_r;
    assign regs2user.axi_debug_input_width_converter_word_count_strobe = s_axi_debug_input_width_converter_word_count_strobe_r;
    assign regs2user.axi_debug_input_width_converter_strobes_strobe = s_axi_debug_input_width_converter_strobes_strobe_r;
    assign regs2user.axi_debug_bb_scrambler_cfg_strobe = s_axi_debug_bb_scrambler_cfg_strobe_r;
    assign regs2user.axi_debug_bb_scrambler_cfg_block_data = s_reg_axi_debug_bb_scrambler_cfg_block_data_r;
    assign regs2user.axi_debug_bb_scrambler_cfg_allow_word = s_reg_axi_debug_bb_scrambler_cfg_allow_word_r;
    assign regs2user.axi_debug_bb_scrambler_cfg_allow_frame = s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r;
    assign regs2user.axi_debug_bb_scrambler_frame_count_strobe = s_axi_debug_bb_scrambler_frame_count_strobe_r;
    assign regs2user.axi_debug_bb_scrambler_last_frame_length_strobe = s_axi_debug_bb_scrambler_last_frame_length_strobe_r;
    assign regs2user.axi_debug_bb_scrambler_min_max_frame_length_strobe = s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r;
    assign regs2user.axi_debug_bb_scrambler_word_count_strobe = s_axi_debug_bb_scrambler_word_count_strobe_r;
    assign regs2user.axi_debug_bb_scrambler_strobes_strobe = s_axi_debug_bb_scrambler_strobes_strobe_r;
    assign regs2user.axi_debug_bch_encoder_cfg_strobe = s_axi_debug_bch_encoder_cfg_strobe_r;
    assign regs2user.axi_debug_bch_encoder_cfg_block_data = s_reg_axi_debug_bch_encoder_cfg_block_data_r;
    assign regs2user.axi_debug_bch_encoder_cfg_allow_word = s_reg_axi_debug_bch_encoder_cfg_allow_word_r;
    assign regs2user.axi_debug_bch_encoder_cfg_allow_frame = s_reg_axi_debug_bch_encoder_cfg_allow_frame_r;
    assign regs2user.axi_debug_bch_encoder_frame_count_strobe = s_axi_debug_bch_encoder_frame_count_strobe_r;
    assign regs2user.axi_debug_bch_encoder_last_frame_length_strobe = s_axi_debug_bch_encoder_last_frame_length_strobe_r;
    assign regs2user.axi_debug_bch_encoder_min_max_frame_length_strobe = s_axi_debug_bch_encoder_min_max_frame_length_strobe_r;
    assign regs2user.axi_debug_bch_encoder_word_count_strobe = s_axi_debug_bch_encoder_word_count_strobe_r;
    assign regs2user.axi_debug_bch_encoder_strobes_strobe = s_axi_debug_bch_encoder_strobes_strobe_r;
    assign regs2user.axi_debug_ldpc_encoder_cfg_strobe = s_axi_debug_ldpc_encoder_cfg_strobe_r;
    assign regs2user.axi_debug_ldpc_encoder_cfg_block_data = s_reg_axi_debug_ldpc_encoder_cfg_block_data_r;
    assign regs2user.axi_debug_ldpc_encoder_cfg_allow_word = s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r;
    assign regs2user.axi_debug_ldpc_encoder_cfg_allow_frame = s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r;
    assign regs2user.axi_debug_ldpc_encoder_frame_count_strobe = s_axi_debug_ldpc_encoder_frame_count_strobe_r;
    assign regs2user.axi_debug_ldpc_encoder_last_frame_length_strobe = s_axi_debug_ldpc_encoder_last_frame_length_strobe_r;
    assign regs2user.axi_debug_ldpc_encoder_min_max_frame_length_strobe = s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r;
    assign regs2user.axi_debug_ldpc_encoder_word_count_strobe = s_axi_debug_ldpc_encoder_word_count_strobe_r;
    assign regs2user.axi_debug_ldpc_encoder_strobes_strobe = s_axi_debug_ldpc_encoder_strobes_strobe_r;
    assign regs2user.axi_debug_bit_interleaver_cfg_strobe = s_axi_debug_bit_interleaver_cfg_strobe_r;
    assign regs2user.axi_debug_bit_interleaver_cfg_block_data = s_reg_axi_debug_bit_interleaver_cfg_block_data_r;
    assign regs2user.axi_debug_bit_interleaver_cfg_allow_word = s_reg_axi_debug_bit_interleaver_cfg_allow_word_r;
    assign regs2user.axi_debug_bit_interleaver_cfg_allow_frame = s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r;
    assign regs2user.axi_debug_bit_interleaver_frame_count_strobe = s_axi_debug_bit_interleaver_frame_count_strobe_r;
    assign regs2user.axi_debug_bit_interleaver_last_frame_length_strobe = s_axi_debug_bit_interleaver_last_frame_length_strobe_r;
    assign regs2user.axi_debug_bit_interleaver_min_max_frame_length_strobe = s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r;
    assign regs2user.axi_debug_bit_interleaver_word_count_strobe = s_axi_debug_bit_interleaver_word_count_strobe_r;
    assign regs2user.axi_debug_bit_interleaver_strobes_strobe = s_axi_debug_bit_interleaver_strobes_strobe_r;
    assign regs2user.axi_debug_constellation_mapper_cfg_strobe = s_axi_debug_constellation_mapper_cfg_strobe_r;
    assign regs2user.axi_debug_constellation_mapper_cfg_block_data = s_reg_axi_debug_constellation_mapper_cfg_block_data_r;
    assign regs2user.axi_debug_constellation_mapper_cfg_allow_word = s_reg_axi_debug_constellation_mapper_cfg_allow_word_r;
    assign regs2user.axi_debug_constellation_mapper_cfg_allow_frame = s_reg_axi_debug_constellation_mapper_cfg_allow_frame_r;
    assign regs2user.axi_debug_constellation_mapper_frame_count_strobe = s_axi_debug_constellation_mapper_frame_count_strobe_r;
    assign regs2user.axi_debug_constellation_mapper_last_frame_length_strobe = s_axi_debug_constellation_mapper_last_frame_length_strobe_r;
    assign regs2user.axi_debug_constellation_mapper_min_max_frame_length_strobe = s_axi_debug_constellation_mapper_min_max_frame_length_strobe_r;
    assign regs2user.axi_debug_constellation_mapper_word_count_strobe = s_axi_debug_constellation_mapper_word_count_strobe_r;
    assign regs2user.axi_debug_constellation_mapper_strobes_strobe = s_axi_debug_constellation_mapper_strobes_strobe_r;
    assign regs2user.axi_debug_plframe_cfg_strobe = s_axi_debug_plframe_cfg_strobe_r;
    assign regs2user.axi_debug_plframe_cfg_block_data = s_reg_axi_debug_plframe_cfg_block_data_r;
    assign regs2user.axi_debug_plframe_cfg_allow_word = s_reg_axi_debug_plframe_cfg_allow_word_r;
    assign regs2user.axi_debug_plframe_cfg_allow_frame = s_reg_axi_debug_plframe_cfg_allow_frame_r;
    assign regs2user.axi_debug_plframe_frame_count_strobe = s_axi_debug_plframe_frame_count_strobe_r;
    assign regs2user.axi_debug_plframe_last_frame_length_strobe = s_axi_debug_plframe_last_frame_length_strobe_r;
    assign regs2user.axi_debug_plframe_min_max_frame_length_strobe = s_axi_debug_plframe_min_max_frame_length_strobe_r;
    assign regs2user.axi_debug_plframe_word_count_strobe = s_axi_debug_plframe_word_count_strobe_r;
    assign regs2user.axi_debug_plframe_strobes_strobe = s_axi_debug_plframe_strobes_strobe_r;

endmodule: dvbs2_encoder_regs

`resetall
