// -----------------------------------------------------------------------------
// 'dvbs2_encoder' Register Component
// Revision: 144
// -----------------------------------------------------------------------------
// Generated on 2021-04-09 at 07:38 (UTC) by airhdl version 2021.03.1
// -----------------------------------------------------------------------------
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
// -----------------------------------------------------------------------------

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
    localparam logic [1:0]                      AXI_OKAY        = 2'b00;
    localparam logic [1:0]                      AXI_DECERR      = 2'b11;

    // Registered signals
    logic                                       s_axi_awready_r;
    logic                                       s_axi_wready_r;
    logic [$bits(s_axi_awaddr)-1:0]             s_axi_awaddr_reg_r;
    logic                                       s_axi_bvalid_r;
    logic [$bits(s_axi_bresp)-1:0]              s_axi_bresp_r;
    logic                                       s_axi_arready_r;
    logic [$bits(s_axi_araddr)-1:0]             s_axi_araddr_reg_r;
    logic                                       s_axi_rvalid_r;
    logic [$bits(s_axi_rresp)-1:0]              s_axi_rresp_r;
    logic [$bits(s_axi_wdata)-1:0]              s_axi_wdata_reg_r;
    logic [$bits(s_axi_wstrb)-1:0]              s_axi_wstrb_reg_r;
    logic [$bits(s_axi_rdata)-1:0]              s_axi_rdata_r;

    // User-defined registers
    logic s_config_strobe_r;
    logic [17:0] s_reg_config_physical_layer_scrambler_shift_reg_init_r;
    logic [0:0] s_reg_config_enable_dummy_frames_r;
    logic s_ldpc_fifo_status_strobe_r;
    logic [13:0] s_reg_ldpc_fifo_status_ldpc_fifo_entries;
    logic [0:0] s_reg_ldpc_fifo_status_ldpc_fifo_empty;
    logic [0:0] s_reg_ldpc_fifo_status_ldpc_fifo_full;
    logic s_frames_in_transit_strobe_r;
    logic [7:0] s_reg_frames_in_transit_value;
    logic [7:0] s_bit_mapper_ram_raddr_r;
    logic [31:0] s_bit_mapper_ram_rdata;
    logic [7:0] s_bit_mapper_ram_waddr_r;
    logic [3:0] s_bit_mapper_ram_wen_r;
    logic [31:0] s_bit_mapper_ram_wdata_r;        
    logic [8:0] s_polyphase_filter_coefficients_raddr_r;
    logic [31:0] s_polyphase_filter_coefficients_rdata;
    logic [8:0] s_polyphase_filter_coefficients_waddr_r;
    logic [3:0] s_polyphase_filter_coefficients_wen_r;
    logic [31:0] s_polyphase_filter_coefficients_wdata_r;        
    logic s_axi_debug_input_width_converter_cfg_strobe_r;
    logic [0:0] s_reg_axi_debug_input_width_converter_cfg_block_data_r;
    logic [0:0] s_reg_axi_debug_input_width_converter_cfg_allow_word_r;
    logic [0:0] s_reg_axi_debug_input_width_converter_cfg_allow_frame_r;
    logic [0:0] s_reg_axi_debug_input_width_converter_cfg_reset_min_max_r;
    logic s_axi_debug_input_width_converter_frame_count_strobe_r;
    logic [15:0] s_reg_axi_debug_input_width_converter_frame_count_value;
    logic s_axi_debug_input_width_converter_last_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_input_width_converter_last_frame_length_value;
    logic s_axi_debug_input_width_converter_min_max_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_input_width_converter_min_max_frame_length_min_frame_length;
    logic [15:0] s_reg_axi_debug_input_width_converter_min_max_frame_length_max_frame_length;
    logic s_axi_debug_bb_scrambler_cfg_strobe_r;
    logic [0:0] s_reg_axi_debug_bb_scrambler_cfg_block_data_r;
    logic [0:0] s_reg_axi_debug_bb_scrambler_cfg_allow_word_r;
    logic [0:0] s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r;
    logic [0:0] s_reg_axi_debug_bb_scrambler_cfg_reset_min_max_r;
    logic s_axi_debug_bb_scrambler_frame_count_strobe_r;
    logic [15:0] s_reg_axi_debug_bb_scrambler_frame_count_value;
    logic s_axi_debug_bb_scrambler_last_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_bb_scrambler_last_frame_length_value;
    logic s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_bb_scrambler_min_max_frame_length_min_frame_length;
    logic [15:0] s_reg_axi_debug_bb_scrambler_min_max_frame_length_max_frame_length;
    logic s_axi_debug_bch_encoder_cfg_strobe_r;
    logic [0:0] s_reg_axi_debug_bch_encoder_cfg_block_data_r;
    logic [0:0] s_reg_axi_debug_bch_encoder_cfg_allow_word_r;
    logic [0:0] s_reg_axi_debug_bch_encoder_cfg_allow_frame_r;
    logic [0:0] s_reg_axi_debug_bch_encoder_cfg_reset_min_max_r;
    logic s_axi_debug_bch_encoder_frame_count_strobe_r;
    logic [15:0] s_reg_axi_debug_bch_encoder_frame_count_value;
    logic s_axi_debug_bch_encoder_last_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_bch_encoder_last_frame_length_value;
    logic s_axi_debug_bch_encoder_min_max_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_bch_encoder_min_max_frame_length_min_frame_length;
    logic [15:0] s_reg_axi_debug_bch_encoder_min_max_frame_length_max_frame_length;
    logic s_axi_debug_ldpc_encoder_cfg_strobe_r;
    logic [0:0] s_reg_axi_debug_ldpc_encoder_cfg_block_data_r;
    logic [0:0] s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r;
    logic [0:0] s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r;
    logic [0:0] s_reg_axi_debug_ldpc_encoder_cfg_reset_min_max_r;
    logic s_axi_debug_ldpc_encoder_frame_count_strobe_r;
    logic [15:0] s_reg_axi_debug_ldpc_encoder_frame_count_value;
    logic s_axi_debug_ldpc_encoder_last_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_ldpc_encoder_last_frame_length_value;
    logic s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length;
    logic [15:0] s_reg_axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length;
    logic s_axi_debug_bit_interleaver_cfg_strobe_r;
    logic [0:0] s_reg_axi_debug_bit_interleaver_cfg_block_data_r;
    logic [0:0] s_reg_axi_debug_bit_interleaver_cfg_allow_word_r;
    logic [0:0] s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r;
    logic [0:0] s_reg_axi_debug_bit_interleaver_cfg_reset_min_max_r;
    logic s_axi_debug_bit_interleaver_frame_count_strobe_r;
    logic [15:0] s_reg_axi_debug_bit_interleaver_frame_count_value;
    logic s_axi_debug_bit_interleaver_last_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_bit_interleaver_last_frame_length_value;
    logic s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_bit_interleaver_min_max_frame_length_min_frame_length;
    logic [15:0] s_reg_axi_debug_bit_interleaver_min_max_frame_length_max_frame_length;
    logic s_axi_debug_plframe_cfg_strobe_r;
    logic [0:0] s_reg_axi_debug_plframe_cfg_block_data_r;
    logic [0:0] s_reg_axi_debug_plframe_cfg_allow_word_r;
    logic [0:0] s_reg_axi_debug_plframe_cfg_allow_frame_r;
    logic [0:0] s_reg_axi_debug_plframe_cfg_reset_min_max_r;
    logic s_axi_debug_plframe_frame_count_strobe_r;
    logic [15:0] s_reg_axi_debug_plframe_frame_count_value;
    logic s_axi_debug_plframe_last_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_plframe_last_frame_length_value;
    logic s_axi_debug_plframe_min_max_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_plframe_min_max_frame_length_min_frame_length;
    logic [15:0] s_reg_axi_debug_plframe_min_max_frame_length_max_frame_length;
    logic s_axi_debug_output_cfg_strobe_r;
    logic [0:0] s_reg_axi_debug_output_cfg_block_data_r;
    logic [0:0] s_reg_axi_debug_output_cfg_allow_word_r;
    logic [0:0] s_reg_axi_debug_output_cfg_allow_frame_r;
    logic [0:0] s_reg_axi_debug_output_cfg_reset_min_max_r;
    logic s_axi_debug_output_frame_count_strobe_r;
    logic [15:0] s_reg_axi_debug_output_frame_count_value;
    logic s_axi_debug_output_last_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_output_last_frame_length_value;
    logic s_axi_debug_output_min_max_frame_length_strobe_r;
    logic [15:0] s_reg_axi_debug_output_min_max_frame_length_min_frame_length;
    logic [15:0] s_reg_axi_debug_output_min_max_frame_length_max_frame_length;

    //--------------------------------------------------------------------------
    // Inputs
    //
    assign s_reg_ldpc_fifo_status_ldpc_fifo_entries = user2regs.ldpc_fifo_status_ldpc_fifo_entries;
    assign s_reg_ldpc_fifo_status_ldpc_fifo_empty = user2regs.ldpc_fifo_status_ldpc_fifo_empty;
    assign s_reg_ldpc_fifo_status_ldpc_fifo_full = user2regs.ldpc_fifo_status_ldpc_fifo_full;
    assign s_reg_frames_in_transit_value = user2regs.frames_in_transit_value;
    assign s_bit_mapper_ram_rdata = user2regs.bit_mapper_ram_rdata; 
    assign s_polyphase_filter_coefficients_rdata = user2regs.polyphase_filter_coefficients_rdata; 
    assign s_reg_axi_debug_input_width_converter_frame_count_value = user2regs.axi_debug_input_width_converter_frame_count_value;
    assign s_reg_axi_debug_input_width_converter_last_frame_length_value = user2regs.axi_debug_input_width_converter_last_frame_length_value;
    assign s_reg_axi_debug_input_width_converter_min_max_frame_length_min_frame_length = user2regs.axi_debug_input_width_converter_min_max_frame_length_min_frame_length;
    assign s_reg_axi_debug_input_width_converter_min_max_frame_length_max_frame_length = user2regs.axi_debug_input_width_converter_min_max_frame_length_max_frame_length;
    assign s_reg_axi_debug_bb_scrambler_frame_count_value = user2regs.axi_debug_bb_scrambler_frame_count_value;
    assign s_reg_axi_debug_bb_scrambler_last_frame_length_value = user2regs.axi_debug_bb_scrambler_last_frame_length_value;
    assign s_reg_axi_debug_bb_scrambler_min_max_frame_length_min_frame_length = user2regs.axi_debug_bb_scrambler_min_max_frame_length_min_frame_length;
    assign s_reg_axi_debug_bb_scrambler_min_max_frame_length_max_frame_length = user2regs.axi_debug_bb_scrambler_min_max_frame_length_max_frame_length;
    assign s_reg_axi_debug_bch_encoder_frame_count_value = user2regs.axi_debug_bch_encoder_frame_count_value;
    assign s_reg_axi_debug_bch_encoder_last_frame_length_value = user2regs.axi_debug_bch_encoder_last_frame_length_value;
    assign s_reg_axi_debug_bch_encoder_min_max_frame_length_min_frame_length = user2regs.axi_debug_bch_encoder_min_max_frame_length_min_frame_length;
    assign s_reg_axi_debug_bch_encoder_min_max_frame_length_max_frame_length = user2regs.axi_debug_bch_encoder_min_max_frame_length_max_frame_length;
    assign s_reg_axi_debug_ldpc_encoder_frame_count_value = user2regs.axi_debug_ldpc_encoder_frame_count_value;
    assign s_reg_axi_debug_ldpc_encoder_last_frame_length_value = user2regs.axi_debug_ldpc_encoder_last_frame_length_value;
    assign s_reg_axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length = user2regs.axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length;
    assign s_reg_axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length = user2regs.axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length;
    assign s_reg_axi_debug_bit_interleaver_frame_count_value = user2regs.axi_debug_bit_interleaver_frame_count_value;
    assign s_reg_axi_debug_bit_interleaver_last_frame_length_value = user2regs.axi_debug_bit_interleaver_last_frame_length_value;
    assign s_reg_axi_debug_bit_interleaver_min_max_frame_length_min_frame_length = user2regs.axi_debug_bit_interleaver_min_max_frame_length_min_frame_length;
    assign s_reg_axi_debug_bit_interleaver_min_max_frame_length_max_frame_length = user2regs.axi_debug_bit_interleaver_min_max_frame_length_max_frame_length;
    assign s_reg_axi_debug_plframe_frame_count_value = user2regs.axi_debug_plframe_frame_count_value;
    assign s_reg_axi_debug_plframe_last_frame_length_value = user2regs.axi_debug_plframe_last_frame_length_value;
    assign s_reg_axi_debug_plframe_min_max_frame_length_min_frame_length = user2regs.axi_debug_plframe_min_max_frame_length_min_frame_length;
    assign s_reg_axi_debug_plframe_min_max_frame_length_max_frame_length = user2regs.axi_debug_plframe_min_max_frame_length_max_frame_length;
    assign s_reg_axi_debug_output_frame_count_value = user2regs.axi_debug_output_frame_count_value;
    assign s_reg_axi_debug_output_last_frame_length_value = user2regs.axi_debug_output_last_frame_length_value;
    assign s_reg_axi_debug_output_min_max_frame_length_min_frame_length = user2regs.axi_debug_output_min_max_frame_length_min_frame_length;
    assign s_reg_axi_debug_output_min_max_frame_length_max_frame_length = user2regs.axi_debug_output_min_max_frame_length_max_frame_length;

    //--------------------------------------------------------------------------
    // Read-transaction FSM
    //    
    localparam MAX_MEMORY_LATENCY = 2;

    typedef enum {
        READ_IDLE,
        READ_REGISTER,
        WAIT_MEMORY_RDATA,
        READ_RESPONSE,
        READ_DONE
    } read_state_t;

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin: read_fsm
        // registered state variables
        read_state_t v_state_r;
        logic [31:0] v_rdata_r;
        logic [1:0] v_rresp_r;
        int v_mem_wait_count_r;
        // combinatorial helper variables
        logic v_addr_hit;
        logic [AXI_ADDR_WIDTH-1:0] v_mem_addr;
        if (~axi_aresetn) begin
            v_state_r          <= READ_IDLE;
            v_rdata_r          <= '0;
            v_rresp_r          <= '0;
            v_mem_wait_count_r <= 0;            
            s_axi_arready_r    <= '0;
            s_axi_rvalid_r     <= '0;
            s_axi_rresp_r      <= '0;
            s_axi_araddr_reg_r <= '0;
            s_axi_rdata_r      <= '0;
            s_ldpc_fifo_status_strobe_r <= '0;
            s_frames_in_transit_strobe_r <= '0;
            s_bit_mapper_ram_raddr_r <= '0;
            s_polyphase_filter_coefficients_raddr_r <= '0;
            s_axi_debug_input_width_converter_frame_count_strobe_r <= '0;
            s_axi_debug_input_width_converter_last_frame_length_strobe_r <= '0;
            s_axi_debug_input_width_converter_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_bb_scrambler_frame_count_strobe_r <= '0;
            s_axi_debug_bb_scrambler_last_frame_length_strobe_r <= '0;
            s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_bch_encoder_frame_count_strobe_r <= '0;
            s_axi_debug_bch_encoder_last_frame_length_strobe_r <= '0;
            s_axi_debug_bch_encoder_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_frame_count_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_last_frame_length_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_bit_interleaver_frame_count_strobe_r <= '0;
            s_axi_debug_bit_interleaver_last_frame_length_strobe_r <= '0;
            s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_plframe_frame_count_strobe_r <= '0;
            s_axi_debug_plframe_last_frame_length_strobe_r <= '0;
            s_axi_debug_plframe_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_output_frame_count_strobe_r <= '0;
            s_axi_debug_output_last_frame_length_strobe_r <= '0;
            s_axi_debug_output_min_max_frame_length_strobe_r <= '0;
        end else begin
            // Default values:
            s_axi_arready_r <= 1'b0;
            s_ldpc_fifo_status_strobe_r <= '0;
            s_frames_in_transit_strobe_r <= '0;
            s_bit_mapper_ram_raddr_r <= '0;
            s_polyphase_filter_coefficients_raddr_r <= '0;
            s_axi_debug_input_width_converter_frame_count_strobe_r <= '0;
            s_axi_debug_input_width_converter_last_frame_length_strobe_r <= '0;
            s_axi_debug_input_width_converter_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_bb_scrambler_frame_count_strobe_r <= '0;
            s_axi_debug_bb_scrambler_last_frame_length_strobe_r <= '0;
            s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_bch_encoder_frame_count_strobe_r <= '0;
            s_axi_debug_bch_encoder_last_frame_length_strobe_r <= '0;
            s_axi_debug_bch_encoder_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_frame_count_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_last_frame_length_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_bit_interleaver_frame_count_strobe_r <= '0;
            s_axi_debug_bit_interleaver_last_frame_length_strobe_r <= '0;
            s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_plframe_frame_count_strobe_r <= '0;
            s_axi_debug_plframe_last_frame_length_strobe_r <= '0;
            s_axi_debug_plframe_min_max_frame_length_strobe_r <= '0;
            s_axi_debug_output_frame_count_strobe_r <= '0;
            s_axi_debug_output_last_frame_length_strobe_r <= '0;
            s_axi_debug_output_min_max_frame_length_strobe_r <= '0;

            case (v_state_r)

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
                    // defaults:
                    v_addr_hit = 1'b0;
                    v_rdata_r  <= '0;
                    
                    // register 'config' at address offset 0x0
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::CONFIG_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[17:0] <= s_reg_config_physical_layer_scrambler_shift_reg_init_r;
                        v_rdata_r[18:18] <= s_reg_config_enable_dummy_frames_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'ldpc_fifo_status' at address offset 0x4
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::LDPC_FIFO_STATUS_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[13:0] <= s_reg_ldpc_fifo_status_ldpc_fifo_entries;
                        v_rdata_r[16:16] <= s_reg_ldpc_fifo_status_ldpc_fifo_empty;
                        v_rdata_r[17:17] <= s_reg_ldpc_fifo_status_ldpc_fifo_full;
                        s_ldpc_fifo_status_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'frames_in_transit' at address offset 0x8
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::FRAMES_IN_TRANSIT_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[7:0] <= s_reg_frames_in_transit_value;
                        s_frames_in_transit_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // memory 'bit_mapper_ram' at address offset 0xC
                    if (s_axi_araddr_reg_r >= BASEADDR + dvbs2_encoder_regs_pkg::BIT_MAPPER_RAM_OFFSET && 
                        s_axi_araddr_reg_r < BASEADDR + dvbs2_encoder_regs_pkg::BIT_MAPPER_RAM_OFFSET + dvbs2_encoder_regs_pkg::BIT_MAPPER_RAM_DEPTH * 4) begin
                        v_addr_hit = 1'b1;
                        // generate memory read address:
                        v_mem_addr = s_axi_araddr_reg_r - BASEADDR - dvbs2_encoder_regs_pkg::BIT_MAPPER_RAM_OFFSET;
                        s_bit_mapper_ram_raddr_r <= v_mem_addr[9:2]; // output address has 4-byte granularity
                        v_mem_wait_count_r <= dvbs2_encoder_regs_pkg::BIT_MAPPER_RAM_READ_LATENCY;
                        v_state_r <= WAIT_MEMORY_RDATA;
                    end
                    // memory 'polyphase_filter_coefficients' at address offset 0x3CC
                    if (s_axi_araddr_reg_r >= BASEADDR + dvbs2_encoder_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_OFFSET && 
                        s_axi_araddr_reg_r < BASEADDR + dvbs2_encoder_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_OFFSET + dvbs2_encoder_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_DEPTH * 4) begin
                        v_addr_hit = 1'b1;
                        // generate memory read address:
                        v_mem_addr = s_axi_araddr_reg_r - BASEADDR - dvbs2_encoder_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_OFFSET;
                        s_polyphase_filter_coefficients_raddr_r <= v_mem_addr[10:2]; // output address has 4-byte granularity
                        v_mem_wait_count_r <= dvbs2_encoder_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_READ_LATENCY;
                        v_state_r <= WAIT_MEMORY_RDATA;
                    end
                    // register 'axi_debug_input_width_converter_cfg' at address offset 0xBCC
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_input_width_converter_cfg_block_data_r;
                        v_rdata_r[1:1] <= s_reg_axi_debug_input_width_converter_cfg_allow_word_r;
                        v_rdata_r[2:2] <= s_reg_axi_debug_input_width_converter_cfg_allow_frame_r;
                        v_rdata_r[3:3] <= s_reg_axi_debug_input_width_converter_cfg_reset_min_max_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_input_width_converter_frame_count' at address offset 0xBD0
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_input_width_converter_frame_count_value;
                        s_axi_debug_input_width_converter_frame_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_input_width_converter_last_frame_length' at address offset 0xBD4
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_input_width_converter_last_frame_length_value;
                        s_axi_debug_input_width_converter_last_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_input_width_converter_min_max_frame_length' at address offset 0xBD8
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_input_width_converter_min_max_frame_length_min_frame_length;
                        v_rdata_r[31:16] <= s_reg_axi_debug_input_width_converter_min_max_frame_length_max_frame_length;
                        s_axi_debug_input_width_converter_min_max_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_bb_scrambler_cfg' at address offset 0xBDC
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_CFG_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_bb_scrambler_cfg_block_data_r;
                        v_rdata_r[1:1] <= s_reg_axi_debug_bb_scrambler_cfg_allow_word_r;
                        v_rdata_r[2:2] <= s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r;
                        v_rdata_r[3:3] <= s_reg_axi_debug_bb_scrambler_cfg_reset_min_max_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_bb_scrambler_frame_count' at address offset 0xBE0
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bb_scrambler_frame_count_value;
                        s_axi_debug_bb_scrambler_frame_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_bb_scrambler_last_frame_length' at address offset 0xBE4
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bb_scrambler_last_frame_length_value;
                        s_axi_debug_bb_scrambler_last_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_bb_scrambler_min_max_frame_length' at address offset 0xBE8
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bb_scrambler_min_max_frame_length_min_frame_length;
                        v_rdata_r[31:16] <= s_reg_axi_debug_bb_scrambler_min_max_frame_length_max_frame_length;
                        s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_bch_encoder_cfg' at address offset 0xBEC
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_CFG_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_bch_encoder_cfg_block_data_r;
                        v_rdata_r[1:1] <= s_reg_axi_debug_bch_encoder_cfg_allow_word_r;
                        v_rdata_r[2:2] <= s_reg_axi_debug_bch_encoder_cfg_allow_frame_r;
                        v_rdata_r[3:3] <= s_reg_axi_debug_bch_encoder_cfg_reset_min_max_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_bch_encoder_frame_count' at address offset 0xBF0
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bch_encoder_frame_count_value;
                        s_axi_debug_bch_encoder_frame_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_bch_encoder_last_frame_length' at address offset 0xBF4
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bch_encoder_last_frame_length_value;
                        s_axi_debug_bch_encoder_last_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_bch_encoder_min_max_frame_length' at address offset 0xBF8
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bch_encoder_min_max_frame_length_min_frame_length;
                        v_rdata_r[31:16] <= s_reg_axi_debug_bch_encoder_min_max_frame_length_max_frame_length;
                        s_axi_debug_bch_encoder_min_max_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_ldpc_encoder_cfg' at address offset 0xBFC
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_CFG_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_ldpc_encoder_cfg_block_data_r;
                        v_rdata_r[1:1] <= s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r;
                        v_rdata_r[2:2] <= s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r;
                        v_rdata_r[3:3] <= s_reg_axi_debug_ldpc_encoder_cfg_reset_min_max_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_ldpc_encoder_frame_count' at address offset 0xC00
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_ldpc_encoder_frame_count_value;
                        s_axi_debug_ldpc_encoder_frame_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_ldpc_encoder_last_frame_length' at address offset 0xC04
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_ldpc_encoder_last_frame_length_value;
                        s_axi_debug_ldpc_encoder_last_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_ldpc_encoder_min_max_frame_length' at address offset 0xC08
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length;
                        v_rdata_r[31:16] <= s_reg_axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length;
                        s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_bit_interleaver_cfg' at address offset 0xC0C
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_CFG_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_bit_interleaver_cfg_block_data_r;
                        v_rdata_r[1:1] <= s_reg_axi_debug_bit_interleaver_cfg_allow_word_r;
                        v_rdata_r[2:2] <= s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r;
                        v_rdata_r[3:3] <= s_reg_axi_debug_bit_interleaver_cfg_reset_min_max_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_bit_interleaver_frame_count' at address offset 0xC10
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bit_interleaver_frame_count_value;
                        s_axi_debug_bit_interleaver_frame_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_bit_interleaver_last_frame_length' at address offset 0xC14
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bit_interleaver_last_frame_length_value;
                        s_axi_debug_bit_interleaver_last_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_bit_interleaver_min_max_frame_length' at address offset 0xC18
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_bit_interleaver_min_max_frame_length_min_frame_length;
                        v_rdata_r[31:16] <= s_reg_axi_debug_bit_interleaver_min_max_frame_length_max_frame_length;
                        s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_plframe_cfg' at address offset 0xC1C
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_CFG_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_plframe_cfg_block_data_r;
                        v_rdata_r[1:1] <= s_reg_axi_debug_plframe_cfg_allow_word_r;
                        v_rdata_r[2:2] <= s_reg_axi_debug_plframe_cfg_allow_frame_r;
                        v_rdata_r[3:3] <= s_reg_axi_debug_plframe_cfg_reset_min_max_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_plframe_frame_count' at address offset 0xC20
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_FRAME_COUNT_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_plframe_frame_count_value;
                        s_axi_debug_plframe_frame_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_plframe_last_frame_length' at address offset 0xC24
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_plframe_last_frame_length_value;
                        s_axi_debug_plframe_last_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_plframe_min_max_frame_length' at address offset 0xC28
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_plframe_min_max_frame_length_min_frame_length;
                        v_rdata_r[31:16] <= s_reg_axi_debug_plframe_min_max_frame_length_max_frame_length;
                        s_axi_debug_plframe_min_max_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_output_cfg' at address offset 0xC2C
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_OUTPUT_CFG_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_axi_debug_output_cfg_block_data_r;
                        v_rdata_r[1:1] <= s_reg_axi_debug_output_cfg_allow_word_r;
                        v_rdata_r[2:2] <= s_reg_axi_debug_output_cfg_allow_frame_r;
                        v_rdata_r[3:3] <= s_reg_axi_debug_output_cfg_reset_min_max_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_output_frame_count' at address offset 0xC30
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_OUTPUT_FRAME_COUNT_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_output_frame_count_value;
                        s_axi_debug_output_frame_count_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_output_last_frame_length' at address offset 0xC34
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_OUTPUT_LAST_FRAME_LENGTH_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_output_last_frame_length_value;
                        s_axi_debug_output_last_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'axi_debug_output_min_max_frame_length' at address offset 0xC38
                    if (s_axi_araddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[15:0] <= s_reg_axi_debug_output_min_max_frame_length_min_frame_length;
                        v_rdata_r[31:16] <= s_reg_axi_debug_output_min_max_frame_length_max_frame_length;
                        s_axi_debug_output_min_max_frame_length_strobe_r <= 1'b1;
                        v_state_r <= READ_RESPONSE;
                    end
                    if (v_addr_hit) begin
                        v_rresp_r <= AXI_OKAY;
                    end else begin
                        v_rresp_r <= AXI_DECERR;
                        // pragma translate_off
                        $warning("ARADDR decode error");
                        // pragma translate_on
                        v_state_r <= READ_RESPONSE;
                    end
                end
                
                // Wait for memory read data
                WAIT_MEMORY_RDATA: begin
                    if (v_mem_wait_count_r == 0) begin
                        // memory 'bit_mapper_ram' at address offset 0xC
                        if (s_axi_araddr_reg_r >= BASEADDR + dvbs2_encoder_regs_pkg::BIT_MAPPER_RAM_OFFSET && 
                            s_axi_araddr_reg_r < BASEADDR + dvbs2_encoder_regs_pkg::BIT_MAPPER_RAM_OFFSET + dvbs2_encoder_regs_pkg::BIT_MAPPER_RAM_DEPTH * 4) begin
                            v_rdata_r[31:0] <= s_bit_mapper_ram_rdata[31:0];
                        end
                        // memory 'polyphase_filter_coefficients' at address offset 0x3CC
                        if (s_axi_araddr_reg_r >= BASEADDR + dvbs2_encoder_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_OFFSET && 
                            s_axi_araddr_reg_r < BASEADDR + dvbs2_encoder_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_OFFSET + dvbs2_encoder_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_DEPTH * 4) begin
                            v_rdata_r[31:0] <= s_polyphase_filter_coefficients_rdata[31:0];
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

    //--------------------------------------------------------------------------
    // Write-transaction FSM
    //    

    typedef enum {
        WRITE_IDLE,
        WRITE_ADDR_FIRST,
        WRITE_DATA_FIRST,
        WRITE_UPDATE_REGISTER,
        WRITE_DONE
    } write_state_t;

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin: write_fsm
        // registered state variables
        write_state_t v_state_r;
        // combinatorial helper variables
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
            s_bit_mapper_ram_waddr_r <= '0;
            s_bit_mapper_ram_wen_r <= '0;
            s_bit_mapper_ram_wdata_r <= '0;
            s_polyphase_filter_coefficients_waddr_r <= '0;
            s_polyphase_filter_coefficients_wen_r <= '0;
            s_polyphase_filter_coefficients_wdata_r <= '0;
            s_axi_debug_input_width_converter_cfg_strobe_r <= '0;
            s_reg_axi_debug_input_width_converter_cfg_block_data_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_input_width_converter_cfg_allow_word_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_input_width_converter_cfg_allow_frame_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_RESET;
            s_reg_axi_debug_input_width_converter_cfg_reset_min_max_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_RESET_MIN_MAX_RESET;
            s_axi_debug_bb_scrambler_cfg_strobe_r <= '0;
            s_reg_axi_debug_bb_scrambler_cfg_block_data_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_bb_scrambler_cfg_allow_word_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_RESET;
            s_reg_axi_debug_bb_scrambler_cfg_reset_min_max_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_CFG_RESET_MIN_MAX_RESET;
            s_axi_debug_bch_encoder_cfg_strobe_r <= '0;
            s_reg_axi_debug_bch_encoder_cfg_block_data_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_bch_encoder_cfg_allow_word_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_bch_encoder_cfg_allow_frame_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_RESET;
            s_reg_axi_debug_bch_encoder_cfg_reset_min_max_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_CFG_RESET_MIN_MAX_RESET;
            s_axi_debug_ldpc_encoder_cfg_strobe_r <= '0;
            s_reg_axi_debug_ldpc_encoder_cfg_block_data_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_RESET;
            s_reg_axi_debug_ldpc_encoder_cfg_reset_min_max_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_CFG_RESET_MIN_MAX_RESET;
            s_axi_debug_bit_interleaver_cfg_strobe_r <= '0;
            s_reg_axi_debug_bit_interleaver_cfg_block_data_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_bit_interleaver_cfg_allow_word_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_RESET;
            s_reg_axi_debug_bit_interleaver_cfg_reset_min_max_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_CFG_RESET_MIN_MAX_RESET;
            s_axi_debug_plframe_cfg_strobe_r <= '0;
            s_reg_axi_debug_plframe_cfg_block_data_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_plframe_cfg_allow_word_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_plframe_cfg_allow_frame_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_RESET;
            s_reg_axi_debug_plframe_cfg_reset_min_max_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_CFG_RESET_MIN_MAX_RESET;
            s_axi_debug_output_cfg_strobe_r <= '0;
            s_reg_axi_debug_output_cfg_block_data_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_OUTPUT_CFG_BLOCK_DATA_RESET;
            s_reg_axi_debug_output_cfg_allow_word_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_OUTPUT_CFG_ALLOW_WORD_RESET;
            s_reg_axi_debug_output_cfg_allow_frame_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_OUTPUT_CFG_ALLOW_FRAME_RESET;
            s_reg_axi_debug_output_cfg_reset_min_max_r <= dvbs2_encoder_regs_pkg::AXI_DEBUG_OUTPUT_CFG_RESET_MIN_MAX_RESET;

        end else begin
            // Default values:
            s_axi_awready_r <= 1'b0;
            s_axi_wready_r  <= 1'b0;
            s_config_strobe_r <= '0;
            s_bit_mapper_ram_waddr_r <= '0; // always reset to zero because of wired OR
            s_bit_mapper_ram_wen_r <= '0;
            s_polyphase_filter_coefficients_waddr_r <= '0; // always reset to zero because of wired OR
            s_polyphase_filter_coefficients_wen_r <= '0;
            s_axi_debug_input_width_converter_cfg_strobe_r <= '0;
            s_axi_debug_bb_scrambler_cfg_strobe_r <= '0;
            s_axi_debug_bch_encoder_cfg_strobe_r <= '0;
            s_axi_debug_ldpc_encoder_cfg_strobe_r <= '0;
            s_axi_debug_bit_interleaver_cfg_strobe_r <= '0;
            s_axi_debug_plframe_cfg_strobe_r <= '0;
            s_axi_debug_output_cfg_strobe_r <= '0;
            v_addr_hit = 1'b0;
            
            // Self-clearing fields:
            s_reg_axi_debug_input_width_converter_cfg_allow_word_r <= '0;
            s_reg_axi_debug_input_width_converter_cfg_allow_frame_r <= '0;
            s_reg_axi_debug_input_width_converter_cfg_reset_min_max_r <= '0;
            s_reg_axi_debug_bb_scrambler_cfg_allow_word_r <= '0;
            s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r <= '0;
            s_reg_axi_debug_bb_scrambler_cfg_reset_min_max_r <= '0;
            s_reg_axi_debug_bch_encoder_cfg_allow_word_r <= '0;
            s_reg_axi_debug_bch_encoder_cfg_allow_frame_r <= '0;
            s_reg_axi_debug_bch_encoder_cfg_reset_min_max_r <= '0;
            s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r <= '0;
            s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r <= '0;
            s_reg_axi_debug_ldpc_encoder_cfg_reset_min_max_r <= '0;
            s_reg_axi_debug_bit_interleaver_cfg_allow_word_r <= '0;
            s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r <= '0;
            s_reg_axi_debug_bit_interleaver_cfg_reset_min_max_r <= '0;
            s_reg_axi_debug_plframe_cfg_allow_word_r <= '0;
            s_reg_axi_debug_plframe_cfg_allow_frame_r <= '0;
            s_reg_axi_debug_plframe_cfg_reset_min_max_r <= '0;
            s_reg_axi_debug_output_cfg_allow_word_r <= '0;
            s_reg_axi_debug_output_cfg_allow_frame_r <= '0;
            s_reg_axi_debug_output_cfg_reset_min_max_r <= '0;

            case (v_state_r)

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

                    // register 'config' at address offset 0x0
                    if (s_axi_awaddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::CONFIG_OFFSET) begin
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
                    end



                    // memory 'bit_mapper_ram' at address offset 0xC                    
                    if (s_axi_awaddr_reg_r >= BASEADDR + dvbs2_encoder_regs_pkg::BIT_MAPPER_RAM_OFFSET && 
                        s_axi_awaddr_reg_r < BASEADDR + dvbs2_encoder_regs_pkg::BIT_MAPPER_RAM_OFFSET + dvbs2_encoder_regs_pkg::BIT_MAPPER_RAM_DEPTH * 4) begin
                        v_addr_hit = 1'b1;
                        v_mem_addr = s_axi_awaddr_reg_r - BASEADDR - dvbs2_encoder_regs_pkg::BIT_MAPPER_RAM_OFFSET;
                        s_bit_mapper_ram_waddr_r <= v_mem_addr[9:2]; // output address has 4-byte granularity
                        s_bit_mapper_ram_wen_r <= s_axi_wstrb_reg_r;
                        s_bit_mapper_ram_wdata_r <= s_axi_wdata_reg_r;
                    end    

                    // memory 'polyphase_filter_coefficients' at address offset 0x3CC                    
                    if (s_axi_awaddr_reg_r >= BASEADDR + dvbs2_encoder_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_OFFSET && 
                        s_axi_awaddr_reg_r < BASEADDR + dvbs2_encoder_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_OFFSET + dvbs2_encoder_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_DEPTH * 4) begin
                        v_addr_hit = 1'b1;
                        v_mem_addr = s_axi_awaddr_reg_r - BASEADDR - dvbs2_encoder_regs_pkg::POLYPHASE_FILTER_COEFFICIENTS_OFFSET;
                        s_polyphase_filter_coefficients_waddr_r <= v_mem_addr[10:2]; // output address has 4-byte granularity
                        s_polyphase_filter_coefficients_wen_r <= s_axi_wstrb_reg_r;
                        s_polyphase_filter_coefficients_wdata_r <= s_axi_wdata_reg_r;
                    end    

                    // register 'axi_debug_input_width_converter_cfg' at address offset 0xBCC
                    if (s_axi_awaddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_OFFSET) begin
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
                        // field 'reset_min_max':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_input_width_converter_cfg_reset_min_max_r[0] <= s_axi_wdata_reg_r[3]; // reset_min_max[0]
                        end
                    end




                    // register 'axi_debug_bb_scrambler_cfg' at address offset 0xBDC
                    if (s_axi_awaddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BB_SCRAMBLER_CFG_OFFSET) begin
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
                        // field 'reset_min_max':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_bb_scrambler_cfg_reset_min_max_r[0] <= s_axi_wdata_reg_r[3]; // reset_min_max[0]
                        end
                    end




                    // register 'axi_debug_bch_encoder_cfg' at address offset 0xBEC
                    if (s_axi_awaddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BCH_ENCODER_CFG_OFFSET) begin
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
                        // field 'reset_min_max':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_bch_encoder_cfg_reset_min_max_r[0] <= s_axi_wdata_reg_r[3]; // reset_min_max[0]
                        end
                    end




                    // register 'axi_debug_ldpc_encoder_cfg' at address offset 0xBFC
                    if (s_axi_awaddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_LDPC_ENCODER_CFG_OFFSET) begin
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
                        // field 'reset_min_max':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_ldpc_encoder_cfg_reset_min_max_r[0] <= s_axi_wdata_reg_r[3]; // reset_min_max[0]
                        end
                    end




                    // register 'axi_debug_bit_interleaver_cfg' at address offset 0xC0C
                    if (s_axi_awaddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_BIT_INTERLEAVER_CFG_OFFSET) begin
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
                        // field 'reset_min_max':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_bit_interleaver_cfg_reset_min_max_r[0] <= s_axi_wdata_reg_r[3]; // reset_min_max[0]
                        end
                    end




                    // register 'axi_debug_plframe_cfg' at address offset 0xC1C
                    if (s_axi_awaddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_PLFRAME_CFG_OFFSET) begin
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
                        // field 'reset_min_max':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_plframe_cfg_reset_min_max_r[0] <= s_axi_wdata_reg_r[3]; // reset_min_max[0]
                        end
                    end




                    // register 'axi_debug_output_cfg' at address offset 0xC2C
                    if (s_axi_awaddr_reg_r == BASEADDR + dvbs2_encoder_regs_pkg::AXI_DEBUG_OUTPUT_CFG_OFFSET) begin
                        v_addr_hit = 1'b1;
                        s_axi_debug_output_cfg_strobe_r <= 1'b1;
                        // field 'block_data':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_output_cfg_block_data_r[0] <= s_axi_wdata_reg_r[0]; // block_data[0]
                        end
                        // field 'allow_word':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_output_cfg_allow_word_r[0] <= s_axi_wdata_reg_r[1]; // allow_word[0]
                        end
                        // field 'allow_frame':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_output_cfg_allow_frame_r[0] <= s_axi_wdata_reg_r[2]; // allow_frame[0]
                        end
                        // field 'reset_min_max':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_axi_debug_output_cfg_reset_min_max_r[0] <= s_axi_wdata_reg_r[3]; // reset_min_max[0]
                        end
                    end




                    if (!v_addr_hit) begin
                        s_axi_bresp_r   <= AXI_DECERR;
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

    //--------------------------------------------------------------------------
    // Outputs
    //
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
    assign regs2user.ldpc_fifo_status_strobe = s_ldpc_fifo_status_strobe_r;
    assign regs2user.frames_in_transit_strobe = s_frames_in_transit_strobe_r;
    assign regs2user.bit_mapper_ram_addr = s_bit_mapper_ram_waddr_r | s_bit_mapper_ram_raddr_r; // using wired OR as read/write address multiplexer
    assign regs2user.bit_mapper_ram_wen = s_bit_mapper_ram_wen_r;   
    assign regs2user.bit_mapper_ram_wdata = s_bit_mapper_ram_wdata_r;
    assign regs2user.polyphase_filter_coefficients_addr = s_polyphase_filter_coefficients_waddr_r | s_polyphase_filter_coefficients_raddr_r; // using wired OR as read/write address multiplexer
    assign regs2user.polyphase_filter_coefficients_wen = s_polyphase_filter_coefficients_wen_r;   
    assign regs2user.polyphase_filter_coefficients_wdata = s_polyphase_filter_coefficients_wdata_r;
    assign regs2user.axi_debug_input_width_converter_cfg_strobe = s_axi_debug_input_width_converter_cfg_strobe_r;
    assign regs2user.axi_debug_input_width_converter_cfg_block_data = s_reg_axi_debug_input_width_converter_cfg_block_data_r;
    assign regs2user.axi_debug_input_width_converter_cfg_allow_word = s_reg_axi_debug_input_width_converter_cfg_allow_word_r;
    assign regs2user.axi_debug_input_width_converter_cfg_allow_frame = s_reg_axi_debug_input_width_converter_cfg_allow_frame_r;
    assign regs2user.axi_debug_input_width_converter_cfg_reset_min_max = s_reg_axi_debug_input_width_converter_cfg_reset_min_max_r;
    assign regs2user.axi_debug_input_width_converter_frame_count_strobe = s_axi_debug_input_width_converter_frame_count_strobe_r;
    assign regs2user.axi_debug_input_width_converter_last_frame_length_strobe = s_axi_debug_input_width_converter_last_frame_length_strobe_r;
    assign regs2user.axi_debug_input_width_converter_min_max_frame_length_strobe = s_axi_debug_input_width_converter_min_max_frame_length_strobe_r;
    assign regs2user.axi_debug_bb_scrambler_cfg_strobe = s_axi_debug_bb_scrambler_cfg_strobe_r;
    assign regs2user.axi_debug_bb_scrambler_cfg_block_data = s_reg_axi_debug_bb_scrambler_cfg_block_data_r;
    assign regs2user.axi_debug_bb_scrambler_cfg_allow_word = s_reg_axi_debug_bb_scrambler_cfg_allow_word_r;
    assign regs2user.axi_debug_bb_scrambler_cfg_allow_frame = s_reg_axi_debug_bb_scrambler_cfg_allow_frame_r;
    assign regs2user.axi_debug_bb_scrambler_cfg_reset_min_max = s_reg_axi_debug_bb_scrambler_cfg_reset_min_max_r;
    assign regs2user.axi_debug_bb_scrambler_frame_count_strobe = s_axi_debug_bb_scrambler_frame_count_strobe_r;
    assign regs2user.axi_debug_bb_scrambler_last_frame_length_strobe = s_axi_debug_bb_scrambler_last_frame_length_strobe_r;
    assign regs2user.axi_debug_bb_scrambler_min_max_frame_length_strobe = s_axi_debug_bb_scrambler_min_max_frame_length_strobe_r;
    assign regs2user.axi_debug_bch_encoder_cfg_strobe = s_axi_debug_bch_encoder_cfg_strobe_r;
    assign regs2user.axi_debug_bch_encoder_cfg_block_data = s_reg_axi_debug_bch_encoder_cfg_block_data_r;
    assign regs2user.axi_debug_bch_encoder_cfg_allow_word = s_reg_axi_debug_bch_encoder_cfg_allow_word_r;
    assign regs2user.axi_debug_bch_encoder_cfg_allow_frame = s_reg_axi_debug_bch_encoder_cfg_allow_frame_r;
    assign regs2user.axi_debug_bch_encoder_cfg_reset_min_max = s_reg_axi_debug_bch_encoder_cfg_reset_min_max_r;
    assign regs2user.axi_debug_bch_encoder_frame_count_strobe = s_axi_debug_bch_encoder_frame_count_strobe_r;
    assign regs2user.axi_debug_bch_encoder_last_frame_length_strobe = s_axi_debug_bch_encoder_last_frame_length_strobe_r;
    assign regs2user.axi_debug_bch_encoder_min_max_frame_length_strobe = s_axi_debug_bch_encoder_min_max_frame_length_strobe_r;
    assign regs2user.axi_debug_ldpc_encoder_cfg_strobe = s_axi_debug_ldpc_encoder_cfg_strobe_r;
    assign regs2user.axi_debug_ldpc_encoder_cfg_block_data = s_reg_axi_debug_ldpc_encoder_cfg_block_data_r;
    assign regs2user.axi_debug_ldpc_encoder_cfg_allow_word = s_reg_axi_debug_ldpc_encoder_cfg_allow_word_r;
    assign regs2user.axi_debug_ldpc_encoder_cfg_allow_frame = s_reg_axi_debug_ldpc_encoder_cfg_allow_frame_r;
    assign regs2user.axi_debug_ldpc_encoder_cfg_reset_min_max = s_reg_axi_debug_ldpc_encoder_cfg_reset_min_max_r;
    assign regs2user.axi_debug_ldpc_encoder_frame_count_strobe = s_axi_debug_ldpc_encoder_frame_count_strobe_r;
    assign regs2user.axi_debug_ldpc_encoder_last_frame_length_strobe = s_axi_debug_ldpc_encoder_last_frame_length_strobe_r;
    assign regs2user.axi_debug_ldpc_encoder_min_max_frame_length_strobe = s_axi_debug_ldpc_encoder_min_max_frame_length_strobe_r;
    assign regs2user.axi_debug_bit_interleaver_cfg_strobe = s_axi_debug_bit_interleaver_cfg_strobe_r;
    assign regs2user.axi_debug_bit_interleaver_cfg_block_data = s_reg_axi_debug_bit_interleaver_cfg_block_data_r;
    assign regs2user.axi_debug_bit_interleaver_cfg_allow_word = s_reg_axi_debug_bit_interleaver_cfg_allow_word_r;
    assign regs2user.axi_debug_bit_interleaver_cfg_allow_frame = s_reg_axi_debug_bit_interleaver_cfg_allow_frame_r;
    assign regs2user.axi_debug_bit_interleaver_cfg_reset_min_max = s_reg_axi_debug_bit_interleaver_cfg_reset_min_max_r;
    assign regs2user.axi_debug_bit_interleaver_frame_count_strobe = s_axi_debug_bit_interleaver_frame_count_strobe_r;
    assign regs2user.axi_debug_bit_interleaver_last_frame_length_strobe = s_axi_debug_bit_interleaver_last_frame_length_strobe_r;
    assign regs2user.axi_debug_bit_interleaver_min_max_frame_length_strobe = s_axi_debug_bit_interleaver_min_max_frame_length_strobe_r;
    assign regs2user.axi_debug_plframe_cfg_strobe = s_axi_debug_plframe_cfg_strobe_r;
    assign regs2user.axi_debug_plframe_cfg_block_data = s_reg_axi_debug_plframe_cfg_block_data_r;
    assign regs2user.axi_debug_plframe_cfg_allow_word = s_reg_axi_debug_plframe_cfg_allow_word_r;
    assign regs2user.axi_debug_plframe_cfg_allow_frame = s_reg_axi_debug_plframe_cfg_allow_frame_r;
    assign regs2user.axi_debug_plframe_cfg_reset_min_max = s_reg_axi_debug_plframe_cfg_reset_min_max_r;
    assign regs2user.axi_debug_plframe_frame_count_strobe = s_axi_debug_plframe_frame_count_strobe_r;
    assign regs2user.axi_debug_plframe_last_frame_length_strobe = s_axi_debug_plframe_last_frame_length_strobe_r;
    assign regs2user.axi_debug_plframe_min_max_frame_length_strobe = s_axi_debug_plframe_min_max_frame_length_strobe_r;
    assign regs2user.axi_debug_output_cfg_strobe = s_axi_debug_output_cfg_strobe_r;
    assign regs2user.axi_debug_output_cfg_block_data = s_reg_axi_debug_output_cfg_block_data_r;
    assign regs2user.axi_debug_output_cfg_allow_word = s_reg_axi_debug_output_cfg_allow_word_r;
    assign regs2user.axi_debug_output_cfg_allow_frame = s_reg_axi_debug_output_cfg_allow_frame_r;
    assign regs2user.axi_debug_output_cfg_reset_min_max = s_reg_axi_debug_output_cfg_reset_min_max_r;
    assign regs2user.axi_debug_output_frame_count_strobe = s_axi_debug_output_frame_count_strobe_r;
    assign regs2user.axi_debug_output_last_frame_length_strobe = s_axi_debug_output_last_frame_length_strobe_r;
    assign regs2user.axi_debug_output_min_max_frame_length_strobe = s_axi_debug_output_min_max_frame_length_strobe_r;

endmodule: dvbs2_encoder_regs

`resetall
