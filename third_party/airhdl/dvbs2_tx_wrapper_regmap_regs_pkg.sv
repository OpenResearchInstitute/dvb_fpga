// -----------------------------------------------------------------------------
// 'dvbs2_tx_wrapper_regmap' Register Definitions
// Revision: 123
// -----------------------------------------------------------------------------
// Generated on 2021-03-21 at 15:18 (UTC) by airhdl version 2021.03.1
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

package dvbs2_tx_wrapper_regmap_regs_pkg;

    // User-logic ports (from user-logic to register file)
    typedef struct {
        logic [13:0] ldpc_fifo_status_ldpc_fifo_entries; // Value of register 'ldpc_fifo_status', field 'ldpc_fifo_entries'
        logic [0:0] ldpc_fifo_status_ldpc_fifo_empty; // Value of register 'ldpc_fifo_status', field 'ldpc_fifo_empty'
        logic [0:0] ldpc_fifo_status_ldpc_fifo_full; // Value of register 'ldpc_fifo_status', field 'ldpc_fifo_full'
        logic [7:0] frames_in_transit_value; // Value of register 'frames_in_transit', field 'value'
        logic [31:0] bit_mapper_ram_rdata; // read data for memory 'bit_mapper_ram'
        logic [15:0] axi_debug_input_width_converter_frame_count_value; // Value of register 'axi_debug_input_width_converter_frame_count', field 'value'
        logic [15:0] axi_debug_input_width_converter_last_frame_length_value; // Value of register 'axi_debug_input_width_converter_last_frame_length', field 'value'
        logic [15:0] axi_debug_input_width_converter_min_max_frame_length_min_frame_length; // Value of register 'axi_debug_input_width_converter_min_max_frame_length', field 'min_frame_length'
        logic [15:0] axi_debug_input_width_converter_min_max_frame_length_max_frame_length; // Value of register 'axi_debug_input_width_converter_min_max_frame_length', field 'max_frame_length'
        logic [15:0] axi_debug_bb_scrambler_frame_count_value; // Value of register 'axi_debug_bb_scrambler_frame_count', field 'value'
        logic [15:0] axi_debug_bb_scrambler_last_frame_length_value; // Value of register 'axi_debug_bb_scrambler_last_frame_length', field 'value'
        logic [15:0] axi_debug_bb_scrambler_min_max_frame_length_min_frame_length; // Value of register 'axi_debug_bb_scrambler_min_max_frame_length', field 'min_frame_length'
        logic [15:0] axi_debug_bb_scrambler_min_max_frame_length_max_frame_length; // Value of register 'axi_debug_bb_scrambler_min_max_frame_length', field 'max_frame_length'
        logic [15:0] axi_debug_bch_encoder_frame_count_value; // Value of register 'axi_debug_bch_encoder_frame_count', field 'value'
        logic [15:0] axi_debug_bch_encoder_last_frame_length_value; // Value of register 'axi_debug_bch_encoder_last_frame_length', field 'value'
        logic [15:0] axi_debug_bch_encoder_min_max_frame_length_min_frame_length; // Value of register 'axi_debug_bch_encoder_min_max_frame_length', field 'min_frame_length'
        logic [15:0] axi_debug_bch_encoder_min_max_frame_length_max_frame_length; // Value of register 'axi_debug_bch_encoder_min_max_frame_length', field 'max_frame_length'
        logic [15:0] axi_debug_ldpc_encoder_frame_count_value; // Value of register 'axi_debug_ldpc_encoder_frame_count', field 'value'
        logic [15:0] axi_debug_ldpc_encoder_last_frame_length_value; // Value of register 'axi_debug_ldpc_encoder_last_frame_length', field 'value'
        logic [15:0] axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length; // Value of register 'axi_debug_ldpc_encoder_min_max_frame_length', field 'min_frame_length'
        logic [15:0] axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length; // Value of register 'axi_debug_ldpc_encoder_min_max_frame_length', field 'max_frame_length'
        logic [15:0] axi_debug_bit_interleaver_frame_count_value; // Value of register 'axi_debug_bit_interleaver_frame_count', field 'value'
        logic [15:0] axi_debug_bit_interleaver_last_frame_length_value; // Value of register 'axi_debug_bit_interleaver_last_frame_length', field 'value'
        logic [15:0] axi_debug_bit_interleaver_min_max_frame_length_min_frame_length; // Value of register 'axi_debug_bit_interleaver_min_max_frame_length', field 'min_frame_length'
        logic [15:0] axi_debug_bit_interleaver_min_max_frame_length_max_frame_length; // Value of register 'axi_debug_bit_interleaver_min_max_frame_length', field 'max_frame_length'
    } user2regs_t;
    
    // User-logic ports (from register file to user-logic)
    typedef struct {
        logic config_strobe; // Strobe logic for register 'config' (pulsed when the register is written from the bus)
        logic [17:0] config_physical_layer_scrambler_shift_reg_init; // Value of register 'config', field 'physical_layer_scrambler_shift_reg_init'
        logic [0:0] config_enable_dummy_frames; // Value of register 'config', field 'enable_dummy_frames'
        logic ldpc_fifo_status_strobe; // Strobe logic for register 'ldpc_fifo_status' (pulsed when the register is read from the bus)
        logic frames_in_transit_strobe; // Strobe logic for register 'frames_in_transit' (pulsed when the register is read from the bus)
        logic [7:0] bit_mapper_ram_addr; // read/write address for memory 'bit_mapper_ram'
        logic [31:0] bit_mapper_ram_wdata; // write data for memory 'bit_mapper_ram'         
        logic [3:0] bit_mapper_ram_wen; // byte-wide write-enable for memory 'bit_mapper_ram'
        logic [8:0] polyphase_filter_coefficients_addr; // read/write address for memory 'polyphase_filter_coefficients'
        logic [31:0] polyphase_filter_coefficients_wdata; // write data for memory 'polyphase_filter_coefficients'         
        logic [3:0] polyphase_filter_coefficients_wen; // byte-wide write-enable for memory 'polyphase_filter_coefficients'
        logic axi_debug_input_width_converter_cfg_strobe; // Strobe logic for register 'axi_debug_input_width_converter_cfg' (pulsed when the register is written from the bus)
        logic [0:0] axi_debug_input_width_converter_cfg_block_data; // Value of register 'axi_debug_input_width_converter_cfg', field 'block_data'
        logic [0:0] axi_debug_input_width_converter_cfg_allow_word; // Value of register 'axi_debug_input_width_converter_cfg', field 'allow_word'
        logic [0:0] axi_debug_input_width_converter_cfg_allow_frame; // Value of register 'axi_debug_input_width_converter_cfg', field 'allow_frame'
        logic [0:0] axi_debug_input_width_converter_cfg_reset_min_max; // Value of register 'axi_debug_input_width_converter_cfg', field 'reset_min_max'
        logic axi_debug_input_width_converter_frame_count_strobe; // Strobe logic for register 'axi_debug_input_width_converter_frame_count' (pulsed when the register is read from the bus)
        logic axi_debug_input_width_converter_last_frame_length_strobe; // Strobe logic for register 'axi_debug_input_width_converter_last_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_input_width_converter_min_max_frame_length_strobe; // Strobe logic for register 'axi_debug_input_width_converter_min_max_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_bb_scrambler_cfg_strobe; // Strobe logic for register 'axi_debug_bb_scrambler_cfg' (pulsed when the register is written from the bus)
        logic [0:0] axi_debug_bb_scrambler_cfg_block_data; // Value of register 'axi_debug_bb_scrambler_cfg', field 'block_data'
        logic [0:0] axi_debug_bb_scrambler_cfg_allow_word; // Value of register 'axi_debug_bb_scrambler_cfg', field 'allow_word'
        logic [0:0] axi_debug_bb_scrambler_cfg_allow_frame; // Value of register 'axi_debug_bb_scrambler_cfg', field 'allow_frame'
        logic [0:0] axi_debug_bb_scrambler_cfg_reset_min_max; // Value of register 'axi_debug_bb_scrambler_cfg', field 'reset_min_max'
        logic axi_debug_bb_scrambler_frame_count_strobe; // Strobe logic for register 'axi_debug_bb_scrambler_frame_count' (pulsed when the register is read from the bus)
        logic axi_debug_bb_scrambler_last_frame_length_strobe; // Strobe logic for register 'axi_debug_bb_scrambler_last_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_bb_scrambler_min_max_frame_length_strobe; // Strobe logic for register 'axi_debug_bb_scrambler_min_max_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_bch_encoder_cfg_strobe; // Strobe logic for register 'axi_debug_bch_encoder_cfg' (pulsed when the register is written from the bus)
        logic [0:0] axi_debug_bch_encoder_cfg_block_data; // Value of register 'axi_debug_bch_encoder_cfg', field 'block_data'
        logic [0:0] axi_debug_bch_encoder_cfg_allow_word; // Value of register 'axi_debug_bch_encoder_cfg', field 'allow_word'
        logic [0:0] axi_debug_bch_encoder_cfg_allow_frame; // Value of register 'axi_debug_bch_encoder_cfg', field 'allow_frame'
        logic [0:0] axi_debug_bch_encoder_cfg_reset_min_max; // Value of register 'axi_debug_bch_encoder_cfg', field 'reset_min_max'
        logic axi_debug_bch_encoder_frame_count_strobe; // Strobe logic for register 'axi_debug_bch_encoder_frame_count' (pulsed when the register is read from the bus)
        logic axi_debug_bch_encoder_last_frame_length_strobe; // Strobe logic for register 'axi_debug_bch_encoder_last_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_bch_encoder_min_max_frame_length_strobe; // Strobe logic for register 'axi_debug_bch_encoder_min_max_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_ldpc_encoder_cfg_strobe; // Strobe logic for register 'axi_debug_ldpc_encoder_cfg' (pulsed when the register is written from the bus)
        logic [0:0] axi_debug_ldpc_encoder_cfg_block_data; // Value of register 'axi_debug_ldpc_encoder_cfg', field 'block_data'
        logic [0:0] axi_debug_ldpc_encoder_cfg_allow_word; // Value of register 'axi_debug_ldpc_encoder_cfg', field 'allow_word'
        logic [0:0] axi_debug_ldpc_encoder_cfg_allow_frame; // Value of register 'axi_debug_ldpc_encoder_cfg', field 'allow_frame'
        logic [0:0] axi_debug_ldpc_encoder_cfg_reset_min_max; // Value of register 'axi_debug_ldpc_encoder_cfg', field 'reset_min_max'
        logic axi_debug_ldpc_encoder_frame_count_strobe; // Strobe logic for register 'axi_debug_ldpc_encoder_frame_count' (pulsed when the register is read from the bus)
        logic axi_debug_ldpc_encoder_last_frame_length_strobe; // Strobe logic for register 'axi_debug_ldpc_encoder_last_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_ldpc_encoder_min_max_frame_length_strobe; // Strobe logic for register 'axi_debug_ldpc_encoder_min_max_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_bit_interleaver_cfg_strobe; // Strobe logic for register 'axi_debug_bit_interleaver_cfg' (pulsed when the register is written from the bus)
        logic [0:0] axi_debug_bit_interleaver_cfg_block_data; // Value of register 'axi_debug_bit_interleaver_cfg', field 'block_data'
        logic [0:0] axi_debug_bit_interleaver_cfg_allow_word; // Value of register 'axi_debug_bit_interleaver_cfg', field 'allow_word'
        logic [0:0] axi_debug_bit_interleaver_cfg_allow_frame; // Value of register 'axi_debug_bit_interleaver_cfg', field 'allow_frame'
        logic [0:0] axi_debug_bit_interleaver_cfg_reset_min_max; // Value of register 'axi_debug_bit_interleaver_cfg', field 'reset_min_max'
        logic axi_debug_bit_interleaver_frame_count_strobe; // Strobe logic for register 'axi_debug_bit_interleaver_frame_count' (pulsed when the register is read from the bus)
        logic axi_debug_bit_interleaver_last_frame_length_strobe; // Strobe logic for register 'axi_debug_bit_interleaver_last_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_bit_interleaver_min_max_frame_length_strobe; // Strobe logic for register 'axi_debug_bit_interleaver_min_max_frame_length' (pulsed when the register is read from the bus)
    } regs2user_t;

    // Revision number of the 'dvbs2_tx_wrapper_regmap' register map
    localparam DVBS2_TX_WRAPPER_REGMAP_REVISION = 123;

    // Default base address of the 'dvbs2_tx_wrapper_regmap' register map 
    localparam logic [31:0] DVBS2_TX_WRAPPER_REGMAP_DEFAULT_BASEADDR = 32'h00000000;
    
    // Register 'config'
    localparam logic [31:0] CONFIG_OFFSET = 32'h00000000; // address offset of the 'config' register
    // Field 'config.physical_layer_scrambler_shift_reg_init'
    localparam CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_BIT_OFFSET = 0; // bit offset of the 'physical_layer_scrambler_shift_reg_init' field
    localparam CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_BIT_WIDTH = 18; // bit width of the 'physical_layer_scrambler_shift_reg_init' field
    localparam logic [17:0] CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_RESET = 18'b000000000000000001; // reset value of the 'physical_layer_scrambler_shift_reg_init' field
    // Field 'config.enable_dummy_frames'
    localparam CONFIG_ENABLE_DUMMY_FRAMES_BIT_OFFSET = 18; // bit offset of the 'enable_dummy_frames' field
    localparam CONFIG_ENABLE_DUMMY_FRAMES_BIT_WIDTH = 1; // bit width of the 'enable_dummy_frames' field
    localparam logic [18:18] CONFIG_ENABLE_DUMMY_FRAMES_RESET = 1'b0; // reset value of the 'enable_dummy_frames' field
    
    // Register 'ldpc_fifo_status'
    localparam logic [31:0] LDPC_FIFO_STATUS_OFFSET = 32'h00000004; // address offset of the 'ldpc_fifo_status' register
    // Field 'ldpc_fifo_status.ldpc_fifo_entries'
    localparam LDPC_FIFO_STATUS_LDPC_FIFO_ENTRIES_BIT_OFFSET = 0; // bit offset of the 'ldpc_fifo_entries' field
    localparam LDPC_FIFO_STATUS_LDPC_FIFO_ENTRIES_BIT_WIDTH = 14; // bit width of the 'ldpc_fifo_entries' field
    localparam logic [13:0] LDPC_FIFO_STATUS_LDPC_FIFO_ENTRIES_RESET = 14'b00000000000000; // reset value of the 'ldpc_fifo_entries' field
    // Field 'ldpc_fifo_status.ldpc_fifo_empty'
    localparam LDPC_FIFO_STATUS_LDPC_FIFO_EMPTY_BIT_OFFSET = 16; // bit offset of the 'ldpc_fifo_empty' field
    localparam LDPC_FIFO_STATUS_LDPC_FIFO_EMPTY_BIT_WIDTH = 1; // bit width of the 'ldpc_fifo_empty' field
    localparam logic [16:16] LDPC_FIFO_STATUS_LDPC_FIFO_EMPTY_RESET = 1'b0; // reset value of the 'ldpc_fifo_empty' field
    // Field 'ldpc_fifo_status.ldpc_fifo_full'
    localparam LDPC_FIFO_STATUS_LDPC_FIFO_FULL_BIT_OFFSET = 17; // bit offset of the 'ldpc_fifo_full' field
    localparam LDPC_FIFO_STATUS_LDPC_FIFO_FULL_BIT_WIDTH = 1; // bit width of the 'ldpc_fifo_full' field
    localparam logic [17:17] LDPC_FIFO_STATUS_LDPC_FIFO_FULL_RESET = 1'b0; // reset value of the 'ldpc_fifo_full' field
    
    // Register 'frames_in_transit'
    localparam logic [31:0] FRAMES_IN_TRANSIT_OFFSET = 32'h00000008; // address offset of the 'frames_in_transit' register
    // Field 'frames_in_transit.value'
    localparam FRAMES_IN_TRANSIT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam FRAMES_IN_TRANSIT_VALUE_BIT_WIDTH = 8; // bit width of the 'value' field
    localparam logic [7:0] FRAMES_IN_TRANSIT_VALUE_RESET = 8'b00000000; // reset value of the 'value' field
    
    // Register 'bit_mapper_ram'
    localparam logic [31:0] BIT_MAPPER_RAM_OFFSET = 32'h0000000C; // address offset of the 'bit_mapper_ram' register
    localparam BIT_MAPPER_RAM_DEPTH = 240; // depth of the 'bit_mapper_ram' memory, in elements
    localparam BIT_MAPPER_RAM_READ_LATENCY = 1; // read latency of the 'bit_mapper_ram' memory, in clock cycles
    // Field 'bit_mapper_ram.data'
    localparam BIT_MAPPER_RAM_DATA_BIT_OFFSET = 0; // bit offset of the 'data' field
    localparam BIT_MAPPER_RAM_DATA_BIT_WIDTH = 32; // bit width of the 'data' field
    localparam logic [31:0] BIT_MAPPER_RAM_DATA_RESET = 32'b00000000000000000000000000000000; // reset value of the 'data' field
    
    // Register 'polyphase_filter_coefficients'
    localparam logic [31:0] POLYPHASE_FILTER_COEFFICIENTS_OFFSET = 32'h000003CC; // address offset of the 'polyphase_filter_coefficients' register
    localparam POLYPHASE_FILTER_COEFFICIENTS_DEPTH = 512; // depth of the 'polyphase_filter_coefficients' memory, in elements
    localparam POLYPHASE_FILTER_COEFFICIENTS_READ_LATENCY = 1; // read latency of the 'polyphase_filter_coefficients' memory, in clock cycles
    // Field 'polyphase_filter_coefficients.value'
    localparam POLYPHASE_FILTER_COEFFICIENTS_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam POLYPHASE_FILTER_COEFFICIENTS_VALUE_BIT_WIDTH = 32; // bit width of the 'value' field
    localparam logic [31:0] POLYPHASE_FILTER_COEFFICIENTS_VALUE_RESET = 32'b00000000000000000000000000000000; // reset value of the 'value' field
    
    // Register 'axi_debug_input_width_converter_cfg'
    localparam logic [31:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_OFFSET = 32'h00000BCC; // address offset of the 'axi_debug_input_width_converter_cfg' register
    // Field 'axi_debug_input_width_converter_cfg.block_data'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_BIT_OFFSET = 0; // bit offset of the 'block_data' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_BIT_WIDTH = 1; // bit width of the 'block_data' field
    localparam logic [0:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_RESET = 1'b0; // reset value of the 'block_data' field
    // Field 'axi_debug_input_width_converter_cfg.allow_word'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_BIT_OFFSET = 1; // bit offset of the 'allow_word' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_BIT_WIDTH = 1; // bit width of the 'allow_word' field
    localparam logic [1:1] AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_RESET = 1'b0; // reset value of the 'allow_word' field
    // Field 'axi_debug_input_width_converter_cfg.allow_frame'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_BIT_OFFSET = 2; // bit offset of the 'allow_frame' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_BIT_WIDTH = 1; // bit width of the 'allow_frame' field
    localparam logic [2:2] AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_RESET = 1'b0; // reset value of the 'allow_frame' field
    // Field 'axi_debug_input_width_converter_cfg.reset_min_max'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_RESET_MIN_MAX_BIT_OFFSET = 3; // bit offset of the 'reset_min_max' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_RESET_MIN_MAX_BIT_WIDTH = 1; // bit width of the 'reset_min_max' field
    localparam logic [3:3] AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_RESET_MIN_MAX_RESET = 1'b0; // reset value of the 'reset_min_max' field
    
    // Register 'axi_debug_input_width_converter_frame_count'
    localparam logic [31:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_OFFSET = 32'h00000BD0; // address offset of the 'axi_debug_input_width_converter_frame_count' register
    // Field 'axi_debug_input_width_converter_frame_count.value'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field
    
    // Register 'axi_debug_input_width_converter_last_frame_length'
    localparam logic [31:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_OFFSET = 32'h00000BD4; // address offset of the 'axi_debug_input_width_converter_last_frame_length' register
    // Field 'axi_debug_input_width_converter_last_frame_length.value'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field
    
    // Register 'axi_debug_input_width_converter_min_max_frame_length'
    localparam logic [31:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_OFFSET = 32'h00000BD8; // address offset of the 'axi_debug_input_width_converter_min_max_frame_length' register
    // Field 'axi_debug_input_width_converter_min_max_frame_length.min_frame_length'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; // bit offset of the 'min_frame_length' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'min_frame_length' field
    localparam logic [15:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'min_frame_length' field
    // Field 'axi_debug_input_width_converter_min_max_frame_length.max_frame_length'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; // bit offset of the 'max_frame_length' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'max_frame_length' field
    localparam logic [31:16] AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'max_frame_length' field
    
    // Register 'axi_debug_bb_scrambler_cfg'
    localparam logic [31:0] AXI_DEBUG_BB_SCRAMBLER_CFG_OFFSET = 32'h00000BDC; // address offset of the 'axi_debug_bb_scrambler_cfg' register
    // Field 'axi_debug_bb_scrambler_cfg.block_data'
    localparam AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_BIT_OFFSET = 0; // bit offset of the 'block_data' field
    localparam AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_BIT_WIDTH = 1; // bit width of the 'block_data' field
    localparam logic [0:0] AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_RESET = 1'b0; // reset value of the 'block_data' field
    // Field 'axi_debug_bb_scrambler_cfg.allow_word'
    localparam AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_BIT_OFFSET = 1; // bit offset of the 'allow_word' field
    localparam AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_BIT_WIDTH = 1; // bit width of the 'allow_word' field
    localparam logic [1:1] AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_RESET = 1'b0; // reset value of the 'allow_word' field
    // Field 'axi_debug_bb_scrambler_cfg.allow_frame'
    localparam AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_BIT_OFFSET = 2; // bit offset of the 'allow_frame' field
    localparam AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_BIT_WIDTH = 1; // bit width of the 'allow_frame' field
    localparam logic [2:2] AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_RESET = 1'b0; // reset value of the 'allow_frame' field
    // Field 'axi_debug_bb_scrambler_cfg.reset_min_max'
    localparam AXI_DEBUG_BB_SCRAMBLER_CFG_RESET_MIN_MAX_BIT_OFFSET = 3; // bit offset of the 'reset_min_max' field
    localparam AXI_DEBUG_BB_SCRAMBLER_CFG_RESET_MIN_MAX_BIT_WIDTH = 1; // bit width of the 'reset_min_max' field
    localparam logic [3:3] AXI_DEBUG_BB_SCRAMBLER_CFG_RESET_MIN_MAX_RESET = 1'b0; // reset value of the 'reset_min_max' field
    
    // Register 'axi_debug_bb_scrambler_frame_count'
    localparam logic [31:0] AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_OFFSET = 32'h00000BE0; // address offset of the 'axi_debug_bb_scrambler_frame_count' register
    // Field 'axi_debug_bb_scrambler_frame_count.value'
    localparam AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field
    
    // Register 'axi_debug_bb_scrambler_last_frame_length'
    localparam logic [31:0] AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_OFFSET = 32'h00000BE4; // address offset of the 'axi_debug_bb_scrambler_last_frame_length' register
    // Field 'axi_debug_bb_scrambler_last_frame_length.value'
    localparam AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field
    
    // Register 'axi_debug_bb_scrambler_min_max_frame_length'
    localparam logic [31:0] AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_OFFSET = 32'h00000BE8; // address offset of the 'axi_debug_bb_scrambler_min_max_frame_length' register
    // Field 'axi_debug_bb_scrambler_min_max_frame_length.min_frame_length'
    localparam AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; // bit offset of the 'min_frame_length' field
    localparam AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'min_frame_length' field
    localparam logic [15:0] AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'min_frame_length' field
    // Field 'axi_debug_bb_scrambler_min_max_frame_length.max_frame_length'
    localparam AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; // bit offset of the 'max_frame_length' field
    localparam AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'max_frame_length' field
    localparam logic [31:16] AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'max_frame_length' field
    
    // Register 'axi_debug_bch_encoder_cfg'
    localparam logic [31:0] AXI_DEBUG_BCH_ENCODER_CFG_OFFSET = 32'h00000BEC; // address offset of the 'axi_debug_bch_encoder_cfg' register
    // Field 'axi_debug_bch_encoder_cfg.block_data'
    localparam AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_BIT_OFFSET = 0; // bit offset of the 'block_data' field
    localparam AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_BIT_WIDTH = 1; // bit width of the 'block_data' field
    localparam logic [0:0] AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_RESET = 1'b0; // reset value of the 'block_data' field
    // Field 'axi_debug_bch_encoder_cfg.allow_word'
    localparam AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_BIT_OFFSET = 1; // bit offset of the 'allow_word' field
    localparam AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_BIT_WIDTH = 1; // bit width of the 'allow_word' field
    localparam logic [1:1] AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_RESET = 1'b0; // reset value of the 'allow_word' field
    // Field 'axi_debug_bch_encoder_cfg.allow_frame'
    localparam AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_BIT_OFFSET = 2; // bit offset of the 'allow_frame' field
    localparam AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_BIT_WIDTH = 1; // bit width of the 'allow_frame' field
    localparam logic [2:2] AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_RESET = 1'b0; // reset value of the 'allow_frame' field
    // Field 'axi_debug_bch_encoder_cfg.reset_min_max'
    localparam AXI_DEBUG_BCH_ENCODER_CFG_RESET_MIN_MAX_BIT_OFFSET = 3; // bit offset of the 'reset_min_max' field
    localparam AXI_DEBUG_BCH_ENCODER_CFG_RESET_MIN_MAX_BIT_WIDTH = 1; // bit width of the 'reset_min_max' field
    localparam logic [3:3] AXI_DEBUG_BCH_ENCODER_CFG_RESET_MIN_MAX_RESET = 1'b0; // reset value of the 'reset_min_max' field
    
    // Register 'axi_debug_bch_encoder_frame_count'
    localparam logic [31:0] AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_OFFSET = 32'h00000BF0; // address offset of the 'axi_debug_bch_encoder_frame_count' register
    // Field 'axi_debug_bch_encoder_frame_count.value'
    localparam AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field
    
    // Register 'axi_debug_bch_encoder_last_frame_length'
    localparam logic [31:0] AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_OFFSET = 32'h00000BF4; // address offset of the 'axi_debug_bch_encoder_last_frame_length' register
    // Field 'axi_debug_bch_encoder_last_frame_length.value'
    localparam AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field
    
    // Register 'axi_debug_bch_encoder_min_max_frame_length'
    localparam logic [31:0] AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET = 32'h00000BF8; // address offset of the 'axi_debug_bch_encoder_min_max_frame_length' register
    // Field 'axi_debug_bch_encoder_min_max_frame_length.min_frame_length'
    localparam AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; // bit offset of the 'min_frame_length' field
    localparam AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'min_frame_length' field
    localparam logic [15:0] AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'min_frame_length' field
    // Field 'axi_debug_bch_encoder_min_max_frame_length.max_frame_length'
    localparam AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; // bit offset of the 'max_frame_length' field
    localparam AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'max_frame_length' field
    localparam logic [31:16] AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'max_frame_length' field
    
    // Register 'axi_debug_ldpc_encoder_cfg'
    localparam logic [31:0] AXI_DEBUG_LDPC_ENCODER_CFG_OFFSET = 32'h00000BFC; // address offset of the 'axi_debug_ldpc_encoder_cfg' register
    // Field 'axi_debug_ldpc_encoder_cfg.block_data'
    localparam AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_BIT_OFFSET = 0; // bit offset of the 'block_data' field
    localparam AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_BIT_WIDTH = 1; // bit width of the 'block_data' field
    localparam logic [0:0] AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_RESET = 1'b0; // reset value of the 'block_data' field
    // Field 'axi_debug_ldpc_encoder_cfg.allow_word'
    localparam AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_BIT_OFFSET = 1; // bit offset of the 'allow_word' field
    localparam AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_BIT_WIDTH = 1; // bit width of the 'allow_word' field
    localparam logic [1:1] AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_RESET = 1'b0; // reset value of the 'allow_word' field
    // Field 'axi_debug_ldpc_encoder_cfg.allow_frame'
    localparam AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_BIT_OFFSET = 2; // bit offset of the 'allow_frame' field
    localparam AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_BIT_WIDTH = 1; // bit width of the 'allow_frame' field
    localparam logic [2:2] AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_RESET = 1'b0; // reset value of the 'allow_frame' field
    // Field 'axi_debug_ldpc_encoder_cfg.reset_min_max'
    localparam AXI_DEBUG_LDPC_ENCODER_CFG_RESET_MIN_MAX_BIT_OFFSET = 3; // bit offset of the 'reset_min_max' field
    localparam AXI_DEBUG_LDPC_ENCODER_CFG_RESET_MIN_MAX_BIT_WIDTH = 1; // bit width of the 'reset_min_max' field
    localparam logic [3:3] AXI_DEBUG_LDPC_ENCODER_CFG_RESET_MIN_MAX_RESET = 1'b0; // reset value of the 'reset_min_max' field
    
    // Register 'axi_debug_ldpc_encoder_frame_count'
    localparam logic [31:0] AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_OFFSET = 32'h00000C00; // address offset of the 'axi_debug_ldpc_encoder_frame_count' register
    // Field 'axi_debug_ldpc_encoder_frame_count.value'
    localparam AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field
    
    // Register 'axi_debug_ldpc_encoder_last_frame_length'
    localparam logic [31:0] AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_OFFSET = 32'h00000C04; // address offset of the 'axi_debug_ldpc_encoder_last_frame_length' register
    // Field 'axi_debug_ldpc_encoder_last_frame_length.value'
    localparam AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field
    
    // Register 'axi_debug_ldpc_encoder_min_max_frame_length'
    localparam logic [31:0] AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET = 32'h00000C08; // address offset of the 'axi_debug_ldpc_encoder_min_max_frame_length' register
    // Field 'axi_debug_ldpc_encoder_min_max_frame_length.min_frame_length'
    localparam AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; // bit offset of the 'min_frame_length' field
    localparam AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'min_frame_length' field
    localparam logic [15:0] AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'min_frame_length' field
    // Field 'axi_debug_ldpc_encoder_min_max_frame_length.max_frame_length'
    localparam AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; // bit offset of the 'max_frame_length' field
    localparam AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'max_frame_length' field
    localparam logic [31:16] AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'max_frame_length' field
    
    // Register 'axi_debug_bit_interleaver_cfg'
    localparam logic [31:0] AXI_DEBUG_BIT_INTERLEAVER_CFG_OFFSET = 32'h00000C0C; // address offset of the 'axi_debug_bit_interleaver_cfg' register
    // Field 'axi_debug_bit_interleaver_cfg.block_data'
    localparam AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_BIT_OFFSET = 0; // bit offset of the 'block_data' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_BIT_WIDTH = 1; // bit width of the 'block_data' field
    localparam logic [0:0] AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_RESET = 1'b0; // reset value of the 'block_data' field
    // Field 'axi_debug_bit_interleaver_cfg.allow_word'
    localparam AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_BIT_OFFSET = 1; // bit offset of the 'allow_word' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_BIT_WIDTH = 1; // bit width of the 'allow_word' field
    localparam logic [1:1] AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_RESET = 1'b0; // reset value of the 'allow_word' field
    // Field 'axi_debug_bit_interleaver_cfg.allow_frame'
    localparam AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_BIT_OFFSET = 2; // bit offset of the 'allow_frame' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_BIT_WIDTH = 1; // bit width of the 'allow_frame' field
    localparam logic [2:2] AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_RESET = 1'b0; // reset value of the 'allow_frame' field
    // Field 'axi_debug_bit_interleaver_cfg.reset_min_max'
    localparam AXI_DEBUG_BIT_INTERLEAVER_CFG_RESET_MIN_MAX_BIT_OFFSET = 3; // bit offset of the 'reset_min_max' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_CFG_RESET_MIN_MAX_BIT_WIDTH = 1; // bit width of the 'reset_min_max' field
    localparam logic [3:3] AXI_DEBUG_BIT_INTERLEAVER_CFG_RESET_MIN_MAX_RESET = 1'b0; // reset value of the 'reset_min_max' field
    
    // Register 'axi_debug_bit_interleaver_frame_count'
    localparam logic [31:0] AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_OFFSET = 32'h00000C10; // address offset of the 'axi_debug_bit_interleaver_frame_count' register
    // Field 'axi_debug_bit_interleaver_frame_count.value'
    localparam AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field
    
    // Register 'axi_debug_bit_interleaver_last_frame_length'
    localparam logic [31:0] AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_OFFSET = 32'h00000C14; // address offset of the 'axi_debug_bit_interleaver_last_frame_length' register
    // Field 'axi_debug_bit_interleaver_last_frame_length.value'
    localparam AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field
    
    // Register 'axi_debug_bit_interleaver_min_max_frame_length'
    localparam logic [31:0] AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_OFFSET = 32'h00000C18; // address offset of the 'axi_debug_bit_interleaver_min_max_frame_length' register
    // Field 'axi_debug_bit_interleaver_min_max_frame_length.min_frame_length'
    localparam AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; // bit offset of the 'min_frame_length' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'min_frame_length' field
    localparam logic [15:0] AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'min_frame_length' field
    // Field 'axi_debug_bit_interleaver_min_max_frame_length.max_frame_length'
    localparam AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; // bit offset of the 'max_frame_length' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'max_frame_length' field
    localparam logic [31:16] AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'max_frame_length' field

endpackage: dvbs2_tx_wrapper_regmap_regs_pkg
