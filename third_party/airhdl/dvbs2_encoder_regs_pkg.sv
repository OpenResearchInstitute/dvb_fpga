// -----------------------------------------------------------------------------
// 'dvbs2_encoder' Register Definitions
// Revision: 298
// -----------------------------------------------------------------------------
// Generated on 2022-04-06 at 18:22 (UTC) by airhdl version 2022.03.1-114
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

package dvbs2_encoder_regs_pkg;

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
        logic [15:0] axi_debug_input_width_converter_word_count_value; // Value of register 'axi_debug_input_width_converter_word_count', field 'value'
        logic [0:0] axi_debug_input_width_converter_strobes_s_tvalid; // Value of register 'axi_debug_input_width_converter_strobes', field 's_tvalid'
        logic [0:0] axi_debug_input_width_converter_strobes_s_tready; // Value of register 'axi_debug_input_width_converter_strobes', field 's_tready'
        logic [0:0] axi_debug_input_width_converter_strobes_m_tvalid; // Value of register 'axi_debug_input_width_converter_strobes', field 'm_tvalid'
        logic [0:0] axi_debug_input_width_converter_strobes_m_tready; // Value of register 'axi_debug_input_width_converter_strobes', field 'm_tready'
        logic [15:0] axi_debug_bb_scrambler_frame_count_value; // Value of register 'axi_debug_bb_scrambler_frame_count', field 'value'
        logic [15:0] axi_debug_bb_scrambler_last_frame_length_value; // Value of register 'axi_debug_bb_scrambler_last_frame_length', field 'value'
        logic [15:0] axi_debug_bb_scrambler_min_max_frame_length_min_frame_length; // Value of register 'axi_debug_bb_scrambler_min_max_frame_length', field 'min_frame_length'
        logic [15:0] axi_debug_bb_scrambler_min_max_frame_length_max_frame_length; // Value of register 'axi_debug_bb_scrambler_min_max_frame_length', field 'max_frame_length'
        logic [15:0] axi_debug_bb_scrambler_word_count_value; // Value of register 'axi_debug_bb_scrambler_word_count', field 'value'
        logic [0:0] axi_debug_bb_scrambler_strobes_s_tvalid; // Value of register 'axi_debug_bb_scrambler_strobes', field 's_tvalid'
        logic [0:0] axi_debug_bb_scrambler_strobes_s_tready; // Value of register 'axi_debug_bb_scrambler_strobes', field 's_tready'
        logic [0:0] axi_debug_bb_scrambler_strobes_m_tvalid; // Value of register 'axi_debug_bb_scrambler_strobes', field 'm_tvalid'
        logic [0:0] axi_debug_bb_scrambler_strobes_m_tready; // Value of register 'axi_debug_bb_scrambler_strobes', field 'm_tready'
        logic [15:0] axi_debug_bch_encoder_frame_count_value; // Value of register 'axi_debug_bch_encoder_frame_count', field 'value'
        logic [15:0] axi_debug_bch_encoder_last_frame_length_value; // Value of register 'axi_debug_bch_encoder_last_frame_length', field 'value'
        logic [15:0] axi_debug_bch_encoder_min_max_frame_length_min_frame_length; // Value of register 'axi_debug_bch_encoder_min_max_frame_length', field 'min_frame_length'
        logic [15:0] axi_debug_bch_encoder_min_max_frame_length_max_frame_length; // Value of register 'axi_debug_bch_encoder_min_max_frame_length', field 'max_frame_length'
        logic [15:0] axi_debug_bch_encoder_word_count_value; // Value of register 'axi_debug_bch_encoder_word_count', field 'value'
        logic [0:0] axi_debug_bch_encoder_strobes_s_tvalid; // Value of register 'axi_debug_bch_encoder_strobes', field 's_tvalid'
        logic [0:0] axi_debug_bch_encoder_strobes_s_tready; // Value of register 'axi_debug_bch_encoder_strobes', field 's_tready'
        logic [0:0] axi_debug_bch_encoder_strobes_m_tvalid; // Value of register 'axi_debug_bch_encoder_strobes', field 'm_tvalid'
        logic [0:0] axi_debug_bch_encoder_strobes_m_tready; // Value of register 'axi_debug_bch_encoder_strobes', field 'm_tready'
        logic [15:0] axi_debug_ldpc_encoder_frame_count_value; // Value of register 'axi_debug_ldpc_encoder_frame_count', field 'value'
        logic [15:0] axi_debug_ldpc_encoder_last_frame_length_value; // Value of register 'axi_debug_ldpc_encoder_last_frame_length', field 'value'
        logic [15:0] axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length; // Value of register 'axi_debug_ldpc_encoder_min_max_frame_length', field 'min_frame_length'
        logic [15:0] axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length; // Value of register 'axi_debug_ldpc_encoder_min_max_frame_length', field 'max_frame_length'
        logic [15:0] axi_debug_ldpc_encoder_word_count_value; // Value of register 'axi_debug_ldpc_encoder_word_count', field 'value'
        logic [0:0] axi_debug_ldpc_encoder_strobes_s_tvalid; // Value of register 'axi_debug_ldpc_encoder_strobes', field 's_tvalid'
        logic [0:0] axi_debug_ldpc_encoder_strobes_s_tready; // Value of register 'axi_debug_ldpc_encoder_strobes', field 's_tready'
        logic [0:0] axi_debug_ldpc_encoder_strobes_m_tvalid; // Value of register 'axi_debug_ldpc_encoder_strobes', field 'm_tvalid'
        logic [0:0] axi_debug_ldpc_encoder_strobes_m_tready; // Value of register 'axi_debug_ldpc_encoder_strobes', field 'm_tready'
        logic [15:0] axi_debug_bit_interleaver_frame_count_value; // Value of register 'axi_debug_bit_interleaver_frame_count', field 'value'
        logic [15:0] axi_debug_bit_interleaver_last_frame_length_value; // Value of register 'axi_debug_bit_interleaver_last_frame_length', field 'value'
        logic [15:0] axi_debug_bit_interleaver_min_max_frame_length_min_frame_length; // Value of register 'axi_debug_bit_interleaver_min_max_frame_length', field 'min_frame_length'
        logic [15:0] axi_debug_bit_interleaver_min_max_frame_length_max_frame_length; // Value of register 'axi_debug_bit_interleaver_min_max_frame_length', field 'max_frame_length'
        logic [15:0] axi_debug_bit_interleaver_word_count_value; // Value of register 'axi_debug_bit_interleaver_word_count', field 'value'
        logic [0:0] axi_debug_bit_interleaver_strobes_s_tvalid; // Value of register 'axi_debug_bit_interleaver_strobes', field 's_tvalid'
        logic [0:0] axi_debug_bit_interleaver_strobes_s_tready; // Value of register 'axi_debug_bit_interleaver_strobes', field 's_tready'
        logic [0:0] axi_debug_bit_interleaver_strobes_m_tvalid; // Value of register 'axi_debug_bit_interleaver_strobes', field 'm_tvalid'
        logic [0:0] axi_debug_bit_interleaver_strobes_m_tready; // Value of register 'axi_debug_bit_interleaver_strobes', field 'm_tready'
        logic [15:0] axi_debug_plframe_frame_count_value; // Value of register 'axi_debug_plframe_frame_count', field 'value'
        logic [15:0] axi_debug_plframe_last_frame_length_value; // Value of register 'axi_debug_plframe_last_frame_length', field 'value'
        logic [15:0] axi_debug_plframe_min_max_frame_length_min_frame_length; // Value of register 'axi_debug_plframe_min_max_frame_length', field 'min_frame_length'
        logic [15:0] axi_debug_plframe_min_max_frame_length_max_frame_length; // Value of register 'axi_debug_plframe_min_max_frame_length', field 'max_frame_length'
        logic [15:0] axi_debug_plframe_word_count_value; // Value of register 'axi_debug_plframe_word_count', field 'value'
        logic [0:0] axi_debug_plframe_strobes_s_tvalid; // Value of register 'axi_debug_plframe_strobes', field 's_tvalid'
        logic [0:0] axi_debug_plframe_strobes_s_tready; // Value of register 'axi_debug_plframe_strobes', field 's_tready'
        logic [0:0] axi_debug_plframe_strobes_m_tvalid; // Value of register 'axi_debug_plframe_strobes', field 'm_tvalid'
        logic [0:0] axi_debug_plframe_strobes_m_tready; // Value of register 'axi_debug_plframe_strobes', field 'm_tready'
        logic [15:0] axi_debug_output_frame_count_value; // Value of register 'axi_debug_output_frame_count', field 'value'
        logic [15:0] axi_debug_output_last_frame_length_value; // Value of register 'axi_debug_output_last_frame_length', field 'value'
        logic [15:0] axi_debug_output_min_max_frame_length_min_frame_length; // Value of register 'axi_debug_output_min_max_frame_length', field 'min_frame_length'
        logic [15:0] axi_debug_output_min_max_frame_length_max_frame_length; // Value of register 'axi_debug_output_min_max_frame_length', field 'max_frame_length'
        logic [15:0] axi_debug_output_word_count_value; // Value of register 'axi_debug_output_word_count', field 'value'
        logic [0:0] axi_debug_output_strobes_s_tvalid; // Value of register 'axi_debug_output_strobes', field 's_tvalid'
        logic [0:0] axi_debug_output_strobes_s_tready; // Value of register 'axi_debug_output_strobes', field 's_tready'
        logic [0:0] axi_debug_output_strobes_m_tvalid; // Value of register 'axi_debug_output_strobes', field 'm_tvalid'
        logic [0:0] axi_debug_output_strobes_m_tready; // Value of register 'axi_debug_output_strobes', field 'm_tready'
    } user2regs_t;

    // User-logic ports (from register file to user-logic)
    typedef struct {
        logic config_strobe; // Strobe logic for register 'config' (pulsed when the register is written from the bus)
        logic [17:0] config_physical_layer_scrambler_shift_reg_init; // Value of register 'config', field 'physical_layer_scrambler_shift_reg_init'
        logic [0:0] config_enable_dummy_frames; // Value of register 'config', field 'enable_dummy_frames'
        logic [0:0] config_swap_input_data_byte_endianness; // Value of register 'config', field 'swap_input_data_byte_endianness'
        logic [0:0] config_swap_output_data_byte_endianness; // Value of register 'config', field 'swap_output_data_byte_endianness'
        logic [0:0] config_force_output_ready; // Value of register 'config', field 'force_output_ready'
        logic ldpc_fifo_status_strobe; // Strobe logic for register 'ldpc_fifo_status' (pulsed when the register is read from the bus)
        logic frames_in_transit_strobe; // Strobe logic for register 'frames_in_transit' (pulsed when the register is read from the bus)
        logic [7:0] bit_mapper_ram_addr; // read/write address for memory 'bit_mapper_ram'
        logic [31:0] bit_mapper_ram_wdata; // write data for memory 'bit_mapper_ram'
        logic [3:0] bit_mapper_ram_wen; // byte-wide write-enable for memory 'bit_mapper_ram'
        logic bit_mapper_ram_ren; // read-enable for memory 'bit_mapper_ram'
        logic axi_debug_input_width_converter_cfg_strobe; // Strobe logic for register 'axi_debug_input_width_converter_cfg' (pulsed when the register is written from the bus)
        logic [0:0] axi_debug_input_width_converter_cfg_block_data; // Value of register 'axi_debug_input_width_converter_cfg', field 'block_data'
        logic [0:0] axi_debug_input_width_converter_cfg_allow_word; // Value of register 'axi_debug_input_width_converter_cfg', field 'allow_word'
        logic [0:0] axi_debug_input_width_converter_cfg_allow_frame; // Value of register 'axi_debug_input_width_converter_cfg', field 'allow_frame'
        logic axi_debug_input_width_converter_frame_count_strobe; // Strobe logic for register 'axi_debug_input_width_converter_frame_count' (pulsed when the register is read from the bus)
        logic axi_debug_input_width_converter_last_frame_length_strobe; // Strobe logic for register 'axi_debug_input_width_converter_last_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_input_width_converter_min_max_frame_length_strobe; // Strobe logic for register 'axi_debug_input_width_converter_min_max_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_input_width_converter_word_count_strobe; // Strobe logic for register 'axi_debug_input_width_converter_word_count' (pulsed when the register is read from the bus)
        logic axi_debug_input_width_converter_strobes_strobe; // Strobe logic for register 'axi_debug_input_width_converter_strobes' (pulsed when the register is read from the bus)
        logic axi_debug_bb_scrambler_cfg_strobe; // Strobe logic for register 'axi_debug_bb_scrambler_cfg' (pulsed when the register is written from the bus)
        logic [0:0] axi_debug_bb_scrambler_cfg_block_data; // Value of register 'axi_debug_bb_scrambler_cfg', field 'block_data'
        logic [0:0] axi_debug_bb_scrambler_cfg_allow_word; // Value of register 'axi_debug_bb_scrambler_cfg', field 'allow_word'
        logic [0:0] axi_debug_bb_scrambler_cfg_allow_frame; // Value of register 'axi_debug_bb_scrambler_cfg', field 'allow_frame'
        logic axi_debug_bb_scrambler_frame_count_strobe; // Strobe logic for register 'axi_debug_bb_scrambler_frame_count' (pulsed when the register is read from the bus)
        logic axi_debug_bb_scrambler_last_frame_length_strobe; // Strobe logic for register 'axi_debug_bb_scrambler_last_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_bb_scrambler_min_max_frame_length_strobe; // Strobe logic for register 'axi_debug_bb_scrambler_min_max_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_bb_scrambler_word_count_strobe; // Strobe logic for register 'axi_debug_bb_scrambler_word_count' (pulsed when the register is read from the bus)
        logic axi_debug_bb_scrambler_strobes_strobe; // Strobe logic for register 'axi_debug_bb_scrambler_strobes' (pulsed when the register is read from the bus)
        logic axi_debug_bch_encoder_cfg_strobe; // Strobe logic for register 'axi_debug_bch_encoder_cfg' (pulsed when the register is written from the bus)
        logic [0:0] axi_debug_bch_encoder_cfg_block_data; // Value of register 'axi_debug_bch_encoder_cfg', field 'block_data'
        logic [0:0] axi_debug_bch_encoder_cfg_allow_word; // Value of register 'axi_debug_bch_encoder_cfg', field 'allow_word'
        logic [0:0] axi_debug_bch_encoder_cfg_allow_frame; // Value of register 'axi_debug_bch_encoder_cfg', field 'allow_frame'
        logic axi_debug_bch_encoder_frame_count_strobe; // Strobe logic for register 'axi_debug_bch_encoder_frame_count' (pulsed when the register is read from the bus)
        logic axi_debug_bch_encoder_last_frame_length_strobe; // Strobe logic for register 'axi_debug_bch_encoder_last_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_bch_encoder_min_max_frame_length_strobe; // Strobe logic for register 'axi_debug_bch_encoder_min_max_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_bch_encoder_word_count_strobe; // Strobe logic for register 'axi_debug_bch_encoder_word_count' (pulsed when the register is read from the bus)
        logic axi_debug_bch_encoder_strobes_strobe; // Strobe logic for register 'axi_debug_bch_encoder_strobes' (pulsed when the register is read from the bus)
        logic axi_debug_ldpc_encoder_cfg_strobe; // Strobe logic for register 'axi_debug_ldpc_encoder_cfg' (pulsed when the register is written from the bus)
        logic [0:0] axi_debug_ldpc_encoder_cfg_block_data; // Value of register 'axi_debug_ldpc_encoder_cfg', field 'block_data'
        logic [0:0] axi_debug_ldpc_encoder_cfg_allow_word; // Value of register 'axi_debug_ldpc_encoder_cfg', field 'allow_word'
        logic [0:0] axi_debug_ldpc_encoder_cfg_allow_frame; // Value of register 'axi_debug_ldpc_encoder_cfg', field 'allow_frame'
        logic axi_debug_ldpc_encoder_frame_count_strobe; // Strobe logic for register 'axi_debug_ldpc_encoder_frame_count' (pulsed when the register is read from the bus)
        logic axi_debug_ldpc_encoder_last_frame_length_strobe; // Strobe logic for register 'axi_debug_ldpc_encoder_last_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_ldpc_encoder_min_max_frame_length_strobe; // Strobe logic for register 'axi_debug_ldpc_encoder_min_max_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_ldpc_encoder_word_count_strobe; // Strobe logic for register 'axi_debug_ldpc_encoder_word_count' (pulsed when the register is read from the bus)
        logic axi_debug_ldpc_encoder_strobes_strobe; // Strobe logic for register 'axi_debug_ldpc_encoder_strobes' (pulsed when the register is read from the bus)
        logic axi_debug_bit_interleaver_cfg_strobe; // Strobe logic for register 'axi_debug_bit_interleaver_cfg' (pulsed when the register is written from the bus)
        logic [0:0] axi_debug_bit_interleaver_cfg_block_data; // Value of register 'axi_debug_bit_interleaver_cfg', field 'block_data'
        logic [0:0] axi_debug_bit_interleaver_cfg_allow_word; // Value of register 'axi_debug_bit_interleaver_cfg', field 'allow_word'
        logic [0:0] axi_debug_bit_interleaver_cfg_allow_frame; // Value of register 'axi_debug_bit_interleaver_cfg', field 'allow_frame'
        logic axi_debug_bit_interleaver_frame_count_strobe; // Strobe logic for register 'axi_debug_bit_interleaver_frame_count' (pulsed when the register is read from the bus)
        logic axi_debug_bit_interleaver_last_frame_length_strobe; // Strobe logic for register 'axi_debug_bit_interleaver_last_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_bit_interleaver_min_max_frame_length_strobe; // Strobe logic for register 'axi_debug_bit_interleaver_min_max_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_bit_interleaver_word_count_strobe; // Strobe logic for register 'axi_debug_bit_interleaver_word_count' (pulsed when the register is read from the bus)
        logic axi_debug_bit_interleaver_strobes_strobe; // Strobe logic for register 'axi_debug_bit_interleaver_strobes' (pulsed when the register is read from the bus)
        logic axi_debug_plframe_cfg_strobe; // Strobe logic for register 'axi_debug_plframe_cfg' (pulsed when the register is written from the bus)
        logic [0:0] axi_debug_plframe_cfg_block_data; // Value of register 'axi_debug_plframe_cfg', field 'block_data'
        logic [0:0] axi_debug_plframe_cfg_allow_word; // Value of register 'axi_debug_plframe_cfg', field 'allow_word'
        logic [0:0] axi_debug_plframe_cfg_allow_frame; // Value of register 'axi_debug_plframe_cfg', field 'allow_frame'
        logic axi_debug_plframe_frame_count_strobe; // Strobe logic for register 'axi_debug_plframe_frame_count' (pulsed when the register is read from the bus)
        logic axi_debug_plframe_last_frame_length_strobe; // Strobe logic for register 'axi_debug_plframe_last_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_plframe_min_max_frame_length_strobe; // Strobe logic for register 'axi_debug_plframe_min_max_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_plframe_word_count_strobe; // Strobe logic for register 'axi_debug_plframe_word_count' (pulsed when the register is read from the bus)
        logic axi_debug_plframe_strobes_strobe; // Strobe logic for register 'axi_debug_plframe_strobes' (pulsed when the register is read from the bus)
        logic axi_debug_output_cfg_strobe; // Strobe logic for register 'axi_debug_output_cfg' (pulsed when the register is written from the bus)
        logic [0:0] axi_debug_output_cfg_block_data; // Value of register 'axi_debug_output_cfg', field 'block_data'
        logic [0:0] axi_debug_output_cfg_allow_word; // Value of register 'axi_debug_output_cfg', field 'allow_word'
        logic [0:0] axi_debug_output_cfg_allow_frame; // Value of register 'axi_debug_output_cfg', field 'allow_frame'
        logic axi_debug_output_frame_count_strobe; // Strobe logic for register 'axi_debug_output_frame_count' (pulsed when the register is read from the bus)
        logic axi_debug_output_last_frame_length_strobe; // Strobe logic for register 'axi_debug_output_last_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_output_min_max_frame_length_strobe; // Strobe logic for register 'axi_debug_output_min_max_frame_length' (pulsed when the register is read from the bus)
        logic axi_debug_output_word_count_strobe; // Strobe logic for register 'axi_debug_output_word_count' (pulsed when the register is read from the bus)
        logic axi_debug_output_strobes_strobe; // Strobe logic for register 'axi_debug_output_strobes' (pulsed when the register is read from the bus)
    } regs2user_t;

    // Revision number of the 'dvbs2_encoder' register map
    localparam DVBS2_ENCODER_REVISION = 298;

    // Default base address of the 'dvbs2_encoder' register map
    localparam logic [31:0] DVBS2_ENCODER_DEFAULT_BASEADDR = 32'h00000000;

    // Size of the 'dvbs2_encoder' register map, in bytes
    localparam DVBS2_ENCODER_RANGE_BYTES = 4888;

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
    // Field 'config.swap_input_data_byte_endianness'
    localparam CONFIG_SWAP_INPUT_DATA_BYTE_ENDIANNESS_BIT_OFFSET = 19; // bit offset of the 'swap_input_data_byte_endianness' field
    localparam CONFIG_SWAP_INPUT_DATA_BYTE_ENDIANNESS_BIT_WIDTH = 1; // bit width of the 'swap_input_data_byte_endianness' field
    localparam logic [19:19] CONFIG_SWAP_INPUT_DATA_BYTE_ENDIANNESS_RESET = 1'b0; // reset value of the 'swap_input_data_byte_endianness' field
    // Field 'config.swap_output_data_byte_endianness'
    localparam CONFIG_SWAP_OUTPUT_DATA_BYTE_ENDIANNESS_BIT_OFFSET = 20; // bit offset of the 'swap_output_data_byte_endianness' field
    localparam CONFIG_SWAP_OUTPUT_DATA_BYTE_ENDIANNESS_BIT_WIDTH = 1; // bit width of the 'swap_output_data_byte_endianness' field
    localparam logic [20:20] CONFIG_SWAP_OUTPUT_DATA_BYTE_ENDIANNESS_RESET = 1'b0; // reset value of the 'swap_output_data_byte_endianness' field
    // Field 'config.force_output_ready'
    localparam CONFIG_FORCE_OUTPUT_READY_BIT_OFFSET = 21; // bit offset of the 'force_output_ready' field
    localparam CONFIG_FORCE_OUTPUT_READY_BIT_WIDTH = 1; // bit width of the 'force_output_ready' field
    localparam logic [21:21] CONFIG_FORCE_OUTPUT_READY_RESET = 1'b0; // reset value of the 'force_output_ready' field

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

    // Register 'axi_debug_input_width_converter_cfg'
    localparam logic [31:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_OFFSET = 32'h00000D00; // address offset of the 'axi_debug_input_width_converter_cfg' register
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

    // Register 'axi_debug_input_width_converter_frame_count'
    localparam logic [31:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_OFFSET = 32'h00000D04; // address offset of the 'axi_debug_input_width_converter_frame_count' register
    // Field 'axi_debug_input_width_converter_frame_count.value'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_input_width_converter_last_frame_length'
    localparam logic [31:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_OFFSET = 32'h00000D08; // address offset of the 'axi_debug_input_width_converter_last_frame_length' register
    // Field 'axi_debug_input_width_converter_last_frame_length.value'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_input_width_converter_min_max_frame_length'
    localparam logic [31:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_OFFSET = 32'h00000D0C; // address offset of the 'axi_debug_input_width_converter_min_max_frame_length' register
    // Field 'axi_debug_input_width_converter_min_max_frame_length.min_frame_length'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; // bit offset of the 'min_frame_length' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'min_frame_length' field
    localparam logic [15:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'min_frame_length' field
    // Field 'axi_debug_input_width_converter_min_max_frame_length.max_frame_length'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; // bit offset of the 'max_frame_length' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'max_frame_length' field
    localparam logic [31:16] AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'max_frame_length' field

    // Register 'axi_debug_input_width_converter_word_count'
    localparam logic [31:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_OFFSET = 32'h00000D10; // address offset of the 'axi_debug_input_width_converter_word_count' register
    // Field 'axi_debug_input_width_converter_word_count.value'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_input_width_converter_strobes'
    localparam logic [31:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_OFFSET = 32'h00000D14; // address offset of the 'axi_debug_input_width_converter_strobes' register
    // Field 'axi_debug_input_width_converter_strobes.s_tvalid'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TVALID_BIT_OFFSET = 0; // bit offset of the 's_tvalid' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TVALID_BIT_WIDTH = 1; // bit width of the 's_tvalid' field
    localparam logic [0:0] AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TVALID_RESET = 1'b0; // reset value of the 's_tvalid' field
    // Field 'axi_debug_input_width_converter_strobes.s_tready'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TREADY_BIT_OFFSET = 1; // bit offset of the 's_tready' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TREADY_BIT_WIDTH = 1; // bit width of the 's_tready' field
    localparam logic [1:1] AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TREADY_RESET = 1'b0; // reset value of the 's_tready' field
    // Field 'axi_debug_input_width_converter_strobes.m_tvalid'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TVALID_BIT_OFFSET = 2; // bit offset of the 'm_tvalid' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TVALID_BIT_WIDTH = 1; // bit width of the 'm_tvalid' field
    localparam logic [2:2] AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TVALID_RESET = 1'b0; // reset value of the 'm_tvalid' field
    // Field 'axi_debug_input_width_converter_strobes.m_tready'
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TREADY_BIT_OFFSET = 3; // bit offset of the 'm_tready' field
    localparam AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TREADY_BIT_WIDTH = 1; // bit width of the 'm_tready' field
    localparam logic [3:3] AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TREADY_RESET = 1'b0; // reset value of the 'm_tready' field

    // Register 'axi_debug_bb_scrambler_cfg'
    localparam logic [31:0] AXI_DEBUG_BB_SCRAMBLER_CFG_OFFSET = 32'h00000E00; // address offset of the 'axi_debug_bb_scrambler_cfg' register
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

    // Register 'axi_debug_bb_scrambler_frame_count'
    localparam logic [31:0] AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_OFFSET = 32'h00000E04; // address offset of the 'axi_debug_bb_scrambler_frame_count' register
    // Field 'axi_debug_bb_scrambler_frame_count.value'
    localparam AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_bb_scrambler_last_frame_length'
    localparam logic [31:0] AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_OFFSET = 32'h00000E08; // address offset of the 'axi_debug_bb_scrambler_last_frame_length' register
    // Field 'axi_debug_bb_scrambler_last_frame_length.value'
    localparam AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_bb_scrambler_min_max_frame_length'
    localparam logic [31:0] AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_OFFSET = 32'h00000E0C; // address offset of the 'axi_debug_bb_scrambler_min_max_frame_length' register
    // Field 'axi_debug_bb_scrambler_min_max_frame_length.min_frame_length'
    localparam AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; // bit offset of the 'min_frame_length' field
    localparam AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'min_frame_length' field
    localparam logic [15:0] AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'min_frame_length' field
    // Field 'axi_debug_bb_scrambler_min_max_frame_length.max_frame_length'
    localparam AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; // bit offset of the 'max_frame_length' field
    localparam AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'max_frame_length' field
    localparam logic [31:16] AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'max_frame_length' field

    // Register 'axi_debug_bb_scrambler_word_count'
    localparam logic [31:0] AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_OFFSET = 32'h00000E10; // address offset of the 'axi_debug_bb_scrambler_word_count' register
    // Field 'axi_debug_bb_scrambler_word_count.value'
    localparam AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_bb_scrambler_strobes'
    localparam logic [31:0] AXI_DEBUG_BB_SCRAMBLER_STROBES_OFFSET = 32'h00000E14; // address offset of the 'axi_debug_bb_scrambler_strobes' register
    // Field 'axi_debug_bb_scrambler_strobes.s_tvalid'
    localparam AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TVALID_BIT_OFFSET = 0; // bit offset of the 's_tvalid' field
    localparam AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TVALID_BIT_WIDTH = 1; // bit width of the 's_tvalid' field
    localparam logic [0:0] AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TVALID_RESET = 1'b0; // reset value of the 's_tvalid' field
    // Field 'axi_debug_bb_scrambler_strobes.s_tready'
    localparam AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TREADY_BIT_OFFSET = 1; // bit offset of the 's_tready' field
    localparam AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TREADY_BIT_WIDTH = 1; // bit width of the 's_tready' field
    localparam logic [1:1] AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TREADY_RESET = 1'b0; // reset value of the 's_tready' field
    // Field 'axi_debug_bb_scrambler_strobes.m_tvalid'
    localparam AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TVALID_BIT_OFFSET = 2; // bit offset of the 'm_tvalid' field
    localparam AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TVALID_BIT_WIDTH = 1; // bit width of the 'm_tvalid' field
    localparam logic [2:2] AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TVALID_RESET = 1'b0; // reset value of the 'm_tvalid' field
    // Field 'axi_debug_bb_scrambler_strobes.m_tready'
    localparam AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TREADY_BIT_OFFSET = 3; // bit offset of the 'm_tready' field
    localparam AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TREADY_BIT_WIDTH = 1; // bit width of the 'm_tready' field
    localparam logic [3:3] AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TREADY_RESET = 1'b0; // reset value of the 'm_tready' field

    // Register 'axi_debug_bch_encoder_cfg'
    localparam logic [31:0] AXI_DEBUG_BCH_ENCODER_CFG_OFFSET = 32'h00000F00; // address offset of the 'axi_debug_bch_encoder_cfg' register
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

    // Register 'axi_debug_bch_encoder_frame_count'
    localparam logic [31:0] AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_OFFSET = 32'h00000F04; // address offset of the 'axi_debug_bch_encoder_frame_count' register
    // Field 'axi_debug_bch_encoder_frame_count.value'
    localparam AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_bch_encoder_last_frame_length'
    localparam logic [31:0] AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_OFFSET = 32'h00000F08; // address offset of the 'axi_debug_bch_encoder_last_frame_length' register
    // Field 'axi_debug_bch_encoder_last_frame_length.value'
    localparam AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_bch_encoder_min_max_frame_length'
    localparam logic [31:0] AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET = 32'h00000F0C; // address offset of the 'axi_debug_bch_encoder_min_max_frame_length' register
    // Field 'axi_debug_bch_encoder_min_max_frame_length.min_frame_length'
    localparam AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; // bit offset of the 'min_frame_length' field
    localparam AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'min_frame_length' field
    localparam logic [15:0] AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'min_frame_length' field
    // Field 'axi_debug_bch_encoder_min_max_frame_length.max_frame_length'
    localparam AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; // bit offset of the 'max_frame_length' field
    localparam AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'max_frame_length' field
    localparam logic [31:16] AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'max_frame_length' field

    // Register 'axi_debug_bch_encoder_word_count'
    localparam logic [31:0] AXI_DEBUG_BCH_ENCODER_WORD_COUNT_OFFSET = 32'h00000F10; // address offset of the 'axi_debug_bch_encoder_word_count' register
    // Field 'axi_debug_bch_encoder_word_count.value'
    localparam AXI_DEBUG_BCH_ENCODER_WORD_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BCH_ENCODER_WORD_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BCH_ENCODER_WORD_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_bch_encoder_strobes'
    localparam logic [31:0] AXI_DEBUG_BCH_ENCODER_STROBES_OFFSET = 32'h00000F14; // address offset of the 'axi_debug_bch_encoder_strobes' register
    // Field 'axi_debug_bch_encoder_strobes.s_tvalid'
    localparam AXI_DEBUG_BCH_ENCODER_STROBES_S_TVALID_BIT_OFFSET = 0; // bit offset of the 's_tvalid' field
    localparam AXI_DEBUG_BCH_ENCODER_STROBES_S_TVALID_BIT_WIDTH = 1; // bit width of the 's_tvalid' field
    localparam logic [0:0] AXI_DEBUG_BCH_ENCODER_STROBES_S_TVALID_RESET = 1'b0; // reset value of the 's_tvalid' field
    // Field 'axi_debug_bch_encoder_strobes.s_tready'
    localparam AXI_DEBUG_BCH_ENCODER_STROBES_S_TREADY_BIT_OFFSET = 1; // bit offset of the 's_tready' field
    localparam AXI_DEBUG_BCH_ENCODER_STROBES_S_TREADY_BIT_WIDTH = 1; // bit width of the 's_tready' field
    localparam logic [1:1] AXI_DEBUG_BCH_ENCODER_STROBES_S_TREADY_RESET = 1'b0; // reset value of the 's_tready' field
    // Field 'axi_debug_bch_encoder_strobes.m_tvalid'
    localparam AXI_DEBUG_BCH_ENCODER_STROBES_M_TVALID_BIT_OFFSET = 2; // bit offset of the 'm_tvalid' field
    localparam AXI_DEBUG_BCH_ENCODER_STROBES_M_TVALID_BIT_WIDTH = 1; // bit width of the 'm_tvalid' field
    localparam logic [2:2] AXI_DEBUG_BCH_ENCODER_STROBES_M_TVALID_RESET = 1'b0; // reset value of the 'm_tvalid' field
    // Field 'axi_debug_bch_encoder_strobes.m_tready'
    localparam AXI_DEBUG_BCH_ENCODER_STROBES_M_TREADY_BIT_OFFSET = 3; // bit offset of the 'm_tready' field
    localparam AXI_DEBUG_BCH_ENCODER_STROBES_M_TREADY_BIT_WIDTH = 1; // bit width of the 'm_tready' field
    localparam logic [3:3] AXI_DEBUG_BCH_ENCODER_STROBES_M_TREADY_RESET = 1'b0; // reset value of the 'm_tready' field

    // Register 'axi_debug_ldpc_encoder_cfg'
    localparam logic [31:0] AXI_DEBUG_LDPC_ENCODER_CFG_OFFSET = 32'h00001000; // address offset of the 'axi_debug_ldpc_encoder_cfg' register
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

    // Register 'axi_debug_ldpc_encoder_frame_count'
    localparam logic [31:0] AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_OFFSET = 32'h00001004; // address offset of the 'axi_debug_ldpc_encoder_frame_count' register
    // Field 'axi_debug_ldpc_encoder_frame_count.value'
    localparam AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_ldpc_encoder_last_frame_length'
    localparam logic [31:0] AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_OFFSET = 32'h00001008; // address offset of the 'axi_debug_ldpc_encoder_last_frame_length' register
    // Field 'axi_debug_ldpc_encoder_last_frame_length.value'
    localparam AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_ldpc_encoder_min_max_frame_length'
    localparam logic [31:0] AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET = 32'h0000100C; // address offset of the 'axi_debug_ldpc_encoder_min_max_frame_length' register
    // Field 'axi_debug_ldpc_encoder_min_max_frame_length.min_frame_length'
    localparam AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; // bit offset of the 'min_frame_length' field
    localparam AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'min_frame_length' field
    localparam logic [15:0] AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'min_frame_length' field
    // Field 'axi_debug_ldpc_encoder_min_max_frame_length.max_frame_length'
    localparam AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; // bit offset of the 'max_frame_length' field
    localparam AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'max_frame_length' field
    localparam logic [31:16] AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'max_frame_length' field

    // Register 'axi_debug_ldpc_encoder_word_count'
    localparam logic [31:0] AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_OFFSET = 32'h00001010; // address offset of the 'axi_debug_ldpc_encoder_word_count' register
    // Field 'axi_debug_ldpc_encoder_word_count.value'
    localparam AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_ldpc_encoder_strobes'
    localparam logic [31:0] AXI_DEBUG_LDPC_ENCODER_STROBES_OFFSET = 32'h00001014; // address offset of the 'axi_debug_ldpc_encoder_strobes' register
    // Field 'axi_debug_ldpc_encoder_strobes.s_tvalid'
    localparam AXI_DEBUG_LDPC_ENCODER_STROBES_S_TVALID_BIT_OFFSET = 0; // bit offset of the 's_tvalid' field
    localparam AXI_DEBUG_LDPC_ENCODER_STROBES_S_TVALID_BIT_WIDTH = 1; // bit width of the 's_tvalid' field
    localparam logic [0:0] AXI_DEBUG_LDPC_ENCODER_STROBES_S_TVALID_RESET = 1'b0; // reset value of the 's_tvalid' field
    // Field 'axi_debug_ldpc_encoder_strobes.s_tready'
    localparam AXI_DEBUG_LDPC_ENCODER_STROBES_S_TREADY_BIT_OFFSET = 1; // bit offset of the 's_tready' field
    localparam AXI_DEBUG_LDPC_ENCODER_STROBES_S_TREADY_BIT_WIDTH = 1; // bit width of the 's_tready' field
    localparam logic [1:1] AXI_DEBUG_LDPC_ENCODER_STROBES_S_TREADY_RESET = 1'b0; // reset value of the 's_tready' field
    // Field 'axi_debug_ldpc_encoder_strobes.m_tvalid'
    localparam AXI_DEBUG_LDPC_ENCODER_STROBES_M_TVALID_BIT_OFFSET = 2; // bit offset of the 'm_tvalid' field
    localparam AXI_DEBUG_LDPC_ENCODER_STROBES_M_TVALID_BIT_WIDTH = 1; // bit width of the 'm_tvalid' field
    localparam logic [2:2] AXI_DEBUG_LDPC_ENCODER_STROBES_M_TVALID_RESET = 1'b0; // reset value of the 'm_tvalid' field
    // Field 'axi_debug_ldpc_encoder_strobes.m_tready'
    localparam AXI_DEBUG_LDPC_ENCODER_STROBES_M_TREADY_BIT_OFFSET = 3; // bit offset of the 'm_tready' field
    localparam AXI_DEBUG_LDPC_ENCODER_STROBES_M_TREADY_BIT_WIDTH = 1; // bit width of the 'm_tready' field
    localparam logic [3:3] AXI_DEBUG_LDPC_ENCODER_STROBES_M_TREADY_RESET = 1'b0; // reset value of the 'm_tready' field

    // Register 'axi_debug_bit_interleaver_cfg'
    localparam logic [31:0] AXI_DEBUG_BIT_INTERLEAVER_CFG_OFFSET = 32'h00001100; // address offset of the 'axi_debug_bit_interleaver_cfg' register
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

    // Register 'axi_debug_bit_interleaver_frame_count'
    localparam logic [31:0] AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_OFFSET = 32'h00001104; // address offset of the 'axi_debug_bit_interleaver_frame_count' register
    // Field 'axi_debug_bit_interleaver_frame_count.value'
    localparam AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_bit_interleaver_last_frame_length'
    localparam logic [31:0] AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_OFFSET = 32'h00001108; // address offset of the 'axi_debug_bit_interleaver_last_frame_length' register
    // Field 'axi_debug_bit_interleaver_last_frame_length.value'
    localparam AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_bit_interleaver_min_max_frame_length'
    localparam logic [31:0] AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_OFFSET = 32'h0000110C; // address offset of the 'axi_debug_bit_interleaver_min_max_frame_length' register
    // Field 'axi_debug_bit_interleaver_min_max_frame_length.min_frame_length'
    localparam AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; // bit offset of the 'min_frame_length' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'min_frame_length' field
    localparam logic [15:0] AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'min_frame_length' field
    // Field 'axi_debug_bit_interleaver_min_max_frame_length.max_frame_length'
    localparam AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; // bit offset of the 'max_frame_length' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'max_frame_length' field
    localparam logic [31:16] AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'max_frame_length' field

    // Register 'axi_debug_bit_interleaver_word_count'
    localparam logic [31:0] AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_OFFSET = 32'h00001110; // address offset of the 'axi_debug_bit_interleaver_word_count' register
    // Field 'axi_debug_bit_interleaver_word_count.value'
    localparam AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_bit_interleaver_strobes'
    localparam logic [31:0] AXI_DEBUG_BIT_INTERLEAVER_STROBES_OFFSET = 32'h00001114; // address offset of the 'axi_debug_bit_interleaver_strobes' register
    // Field 'axi_debug_bit_interleaver_strobes.s_tvalid'
    localparam AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TVALID_BIT_OFFSET = 0; // bit offset of the 's_tvalid' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TVALID_BIT_WIDTH = 1; // bit width of the 's_tvalid' field
    localparam logic [0:0] AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TVALID_RESET = 1'b0; // reset value of the 's_tvalid' field
    // Field 'axi_debug_bit_interleaver_strobes.s_tready'
    localparam AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TREADY_BIT_OFFSET = 1; // bit offset of the 's_tready' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TREADY_BIT_WIDTH = 1; // bit width of the 's_tready' field
    localparam logic [1:1] AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TREADY_RESET = 1'b0; // reset value of the 's_tready' field
    // Field 'axi_debug_bit_interleaver_strobes.m_tvalid'
    localparam AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TVALID_BIT_OFFSET = 2; // bit offset of the 'm_tvalid' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TVALID_BIT_WIDTH = 1; // bit width of the 'm_tvalid' field
    localparam logic [2:2] AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TVALID_RESET = 1'b0; // reset value of the 'm_tvalid' field
    // Field 'axi_debug_bit_interleaver_strobes.m_tready'
    localparam AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TREADY_BIT_OFFSET = 3; // bit offset of the 'm_tready' field
    localparam AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TREADY_BIT_WIDTH = 1; // bit width of the 'm_tready' field
    localparam logic [3:3] AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TREADY_RESET = 1'b0; // reset value of the 'm_tready' field

    // Register 'axi_debug_plframe_cfg'
    localparam logic [31:0] AXI_DEBUG_PLFRAME_CFG_OFFSET = 32'h00001200; // address offset of the 'axi_debug_plframe_cfg' register
    // Field 'axi_debug_plframe_cfg.block_data'
    localparam AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_BIT_OFFSET = 0; // bit offset of the 'block_data' field
    localparam AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_BIT_WIDTH = 1; // bit width of the 'block_data' field
    localparam logic [0:0] AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_RESET = 1'b0; // reset value of the 'block_data' field
    // Field 'axi_debug_plframe_cfg.allow_word'
    localparam AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_BIT_OFFSET = 1; // bit offset of the 'allow_word' field
    localparam AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_BIT_WIDTH = 1; // bit width of the 'allow_word' field
    localparam logic [1:1] AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_RESET = 1'b0; // reset value of the 'allow_word' field
    // Field 'axi_debug_plframe_cfg.allow_frame'
    localparam AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_BIT_OFFSET = 2; // bit offset of the 'allow_frame' field
    localparam AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_BIT_WIDTH = 1; // bit width of the 'allow_frame' field
    localparam logic [2:2] AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_RESET = 1'b0; // reset value of the 'allow_frame' field

    // Register 'axi_debug_plframe_frame_count'
    localparam logic [31:0] AXI_DEBUG_PLFRAME_FRAME_COUNT_OFFSET = 32'h00001204; // address offset of the 'axi_debug_plframe_frame_count' register
    // Field 'axi_debug_plframe_frame_count.value'
    localparam AXI_DEBUG_PLFRAME_FRAME_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_PLFRAME_FRAME_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_PLFRAME_FRAME_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_plframe_last_frame_length'
    localparam logic [31:0] AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_OFFSET = 32'h00001208; // address offset of the 'axi_debug_plframe_last_frame_length' register
    // Field 'axi_debug_plframe_last_frame_length.value'
    localparam AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_plframe_min_max_frame_length'
    localparam logic [31:0] AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_OFFSET = 32'h0000120C; // address offset of the 'axi_debug_plframe_min_max_frame_length' register
    // Field 'axi_debug_plframe_min_max_frame_length.min_frame_length'
    localparam AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; // bit offset of the 'min_frame_length' field
    localparam AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'min_frame_length' field
    localparam logic [15:0] AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'min_frame_length' field
    // Field 'axi_debug_plframe_min_max_frame_length.max_frame_length'
    localparam AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; // bit offset of the 'max_frame_length' field
    localparam AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'max_frame_length' field
    localparam logic [31:16] AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'max_frame_length' field

    // Register 'axi_debug_plframe_word_count'
    localparam logic [31:0] AXI_DEBUG_PLFRAME_WORD_COUNT_OFFSET = 32'h00001210; // address offset of the 'axi_debug_plframe_word_count' register
    // Field 'axi_debug_plframe_word_count.value'
    localparam AXI_DEBUG_PLFRAME_WORD_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_PLFRAME_WORD_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_PLFRAME_WORD_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_plframe_strobes'
    localparam logic [31:0] AXI_DEBUG_PLFRAME_STROBES_OFFSET = 32'h00001214; // address offset of the 'axi_debug_plframe_strobes' register
    // Field 'axi_debug_plframe_strobes.s_tvalid'
    localparam AXI_DEBUG_PLFRAME_STROBES_S_TVALID_BIT_OFFSET = 0; // bit offset of the 's_tvalid' field
    localparam AXI_DEBUG_PLFRAME_STROBES_S_TVALID_BIT_WIDTH = 1; // bit width of the 's_tvalid' field
    localparam logic [0:0] AXI_DEBUG_PLFRAME_STROBES_S_TVALID_RESET = 1'b0; // reset value of the 's_tvalid' field
    // Field 'axi_debug_plframe_strobes.s_tready'
    localparam AXI_DEBUG_PLFRAME_STROBES_S_TREADY_BIT_OFFSET = 1; // bit offset of the 's_tready' field
    localparam AXI_DEBUG_PLFRAME_STROBES_S_TREADY_BIT_WIDTH = 1; // bit width of the 's_tready' field
    localparam logic [1:1] AXI_DEBUG_PLFRAME_STROBES_S_TREADY_RESET = 1'b0; // reset value of the 's_tready' field
    // Field 'axi_debug_plframe_strobes.m_tvalid'
    localparam AXI_DEBUG_PLFRAME_STROBES_M_TVALID_BIT_OFFSET = 2; // bit offset of the 'm_tvalid' field
    localparam AXI_DEBUG_PLFRAME_STROBES_M_TVALID_BIT_WIDTH = 1; // bit width of the 'm_tvalid' field
    localparam logic [2:2] AXI_DEBUG_PLFRAME_STROBES_M_TVALID_RESET = 1'b0; // reset value of the 'm_tvalid' field
    // Field 'axi_debug_plframe_strobes.m_tready'
    localparam AXI_DEBUG_PLFRAME_STROBES_M_TREADY_BIT_OFFSET = 3; // bit offset of the 'm_tready' field
    localparam AXI_DEBUG_PLFRAME_STROBES_M_TREADY_BIT_WIDTH = 1; // bit width of the 'm_tready' field
    localparam logic [3:3] AXI_DEBUG_PLFRAME_STROBES_M_TREADY_RESET = 1'b0; // reset value of the 'm_tready' field

    // Register 'axi_debug_output_cfg'
    localparam logic [31:0] AXI_DEBUG_OUTPUT_CFG_OFFSET = 32'h00001300; // address offset of the 'axi_debug_output_cfg' register
    // Field 'axi_debug_output_cfg.block_data'
    localparam AXI_DEBUG_OUTPUT_CFG_BLOCK_DATA_BIT_OFFSET = 0; // bit offset of the 'block_data' field
    localparam AXI_DEBUG_OUTPUT_CFG_BLOCK_DATA_BIT_WIDTH = 1; // bit width of the 'block_data' field
    localparam logic [0:0] AXI_DEBUG_OUTPUT_CFG_BLOCK_DATA_RESET = 1'b0; // reset value of the 'block_data' field
    // Field 'axi_debug_output_cfg.allow_word'
    localparam AXI_DEBUG_OUTPUT_CFG_ALLOW_WORD_BIT_OFFSET = 1; // bit offset of the 'allow_word' field
    localparam AXI_DEBUG_OUTPUT_CFG_ALLOW_WORD_BIT_WIDTH = 1; // bit width of the 'allow_word' field
    localparam logic [1:1] AXI_DEBUG_OUTPUT_CFG_ALLOW_WORD_RESET = 1'b0; // reset value of the 'allow_word' field
    // Field 'axi_debug_output_cfg.allow_frame'
    localparam AXI_DEBUG_OUTPUT_CFG_ALLOW_FRAME_BIT_OFFSET = 2; // bit offset of the 'allow_frame' field
    localparam AXI_DEBUG_OUTPUT_CFG_ALLOW_FRAME_BIT_WIDTH = 1; // bit width of the 'allow_frame' field
    localparam logic [2:2] AXI_DEBUG_OUTPUT_CFG_ALLOW_FRAME_RESET = 1'b0; // reset value of the 'allow_frame' field

    // Register 'axi_debug_output_frame_count'
    localparam logic [31:0] AXI_DEBUG_OUTPUT_FRAME_COUNT_OFFSET = 32'h00001304; // address offset of the 'axi_debug_output_frame_count' register
    // Field 'axi_debug_output_frame_count.value'
    localparam AXI_DEBUG_OUTPUT_FRAME_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_OUTPUT_FRAME_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_OUTPUT_FRAME_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_output_last_frame_length'
    localparam logic [31:0] AXI_DEBUG_OUTPUT_LAST_FRAME_LENGTH_OFFSET = 32'h00001308; // address offset of the 'axi_debug_output_last_frame_length' register
    // Field 'axi_debug_output_last_frame_length.value'
    localparam AXI_DEBUG_OUTPUT_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_OUTPUT_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_OUTPUT_LAST_FRAME_LENGTH_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_output_min_max_frame_length'
    localparam logic [31:0] AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_OFFSET = 32'h0000130C; // address offset of the 'axi_debug_output_min_max_frame_length' register
    // Field 'axi_debug_output_min_max_frame_length.min_frame_length'
    localparam AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; // bit offset of the 'min_frame_length' field
    localparam AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'min_frame_length' field
    localparam logic [15:0] AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'min_frame_length' field
    // Field 'axi_debug_output_min_max_frame_length.max_frame_length'
    localparam AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; // bit offset of the 'max_frame_length' field
    localparam AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; // bit width of the 'max_frame_length' field
    localparam logic [31:16] AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 16'b0000000000000000; // reset value of the 'max_frame_length' field

    // Register 'axi_debug_output_word_count'
    localparam logic [31:0] AXI_DEBUG_OUTPUT_WORD_COUNT_OFFSET = 32'h00001310; // address offset of the 'axi_debug_output_word_count' register
    // Field 'axi_debug_output_word_count.value'
    localparam AXI_DEBUG_OUTPUT_WORD_COUNT_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam AXI_DEBUG_OUTPUT_WORD_COUNT_VALUE_BIT_WIDTH = 16; // bit width of the 'value' field
    localparam logic [15:0] AXI_DEBUG_OUTPUT_WORD_COUNT_VALUE_RESET = 16'b0000000000000000; // reset value of the 'value' field

    // Register 'axi_debug_output_strobes'
    localparam logic [31:0] AXI_DEBUG_OUTPUT_STROBES_OFFSET = 32'h00001314; // address offset of the 'axi_debug_output_strobes' register
    // Field 'axi_debug_output_strobes.s_tvalid'
    localparam AXI_DEBUG_OUTPUT_STROBES_S_TVALID_BIT_OFFSET = 0; // bit offset of the 's_tvalid' field
    localparam AXI_DEBUG_OUTPUT_STROBES_S_TVALID_BIT_WIDTH = 1; // bit width of the 's_tvalid' field
    localparam logic [0:0] AXI_DEBUG_OUTPUT_STROBES_S_TVALID_RESET = 1'b0; // reset value of the 's_tvalid' field
    // Field 'axi_debug_output_strobes.s_tready'
    localparam AXI_DEBUG_OUTPUT_STROBES_S_TREADY_BIT_OFFSET = 1; // bit offset of the 's_tready' field
    localparam AXI_DEBUG_OUTPUT_STROBES_S_TREADY_BIT_WIDTH = 1; // bit width of the 's_tready' field
    localparam logic [1:1] AXI_DEBUG_OUTPUT_STROBES_S_TREADY_RESET = 1'b0; // reset value of the 's_tready' field
    // Field 'axi_debug_output_strobes.m_tvalid'
    localparam AXI_DEBUG_OUTPUT_STROBES_M_TVALID_BIT_OFFSET = 2; // bit offset of the 'm_tvalid' field
    localparam AXI_DEBUG_OUTPUT_STROBES_M_TVALID_BIT_WIDTH = 1; // bit width of the 'm_tvalid' field
    localparam logic [2:2] AXI_DEBUG_OUTPUT_STROBES_M_TVALID_RESET = 1'b0; // reset value of the 'm_tvalid' field
    // Field 'axi_debug_output_strobes.m_tready'
    localparam AXI_DEBUG_OUTPUT_STROBES_M_TREADY_BIT_OFFSET = 3; // bit offset of the 'm_tready' field
    localparam AXI_DEBUG_OUTPUT_STROBES_M_TREADY_BIT_WIDTH = 1; // bit width of the 'm_tready' field
    localparam logic [3:3] AXI_DEBUG_OUTPUT_STROBES_M_TREADY_RESET = 1'b0; // reset value of the 'm_tready' field

endpackage: dvbs2_encoder_regs_pkg
