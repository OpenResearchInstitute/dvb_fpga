// -----------------------------------------------------------------------------
// 'dvbs2_encoder' Register Definitions
// Revision: 336
// -----------------------------------------------------------------------------
// Generated on 2023-01-02 at 19:46 (UTC) by airhdl version 2022.12.1-715060670
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

#ifndef DVBS2_ENCODER_REGS_H
#define DVBS2_ENCODER_REGS_H

/* Revision number of the 'dvbs2_encoder' register map */
#define DVBS2_ENCODER_REVISION 336

/* Default base address of the 'dvbs2_encoder' register map */
#define DVBS2_ENCODER_DEFAULT_BASEADDR 0x00000000

/* Size of the 'dvbs2_encoder' register map, in bytes */
#define DVBS2_ENCODER_RANGE_BYTES 4888

/* Register 'config' */
#define CONFIG_OFFSET 0x00000000 /* address offset of the 'config' register */

/* Field  'config.physical_layer_scrambler_shift_reg_init' */
#define CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_BIT_OFFSET 0 /* bit offset of the 'physical_layer_scrambler_shift_reg_init' field */
#define CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_BIT_WIDTH 18 /* bit width of the 'physical_layer_scrambler_shift_reg_init' field */
#define CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_BIT_MASK 0x0003FFFF /* bit mask of the 'physical_layer_scrambler_shift_reg_init' field */
#define CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_RESET 0x1 /* reset value of the 'physical_layer_scrambler_shift_reg_init' field */

/* Field  'config.enable_dummy_frames' */
#define CONFIG_ENABLE_DUMMY_FRAMES_BIT_OFFSET 18 /* bit offset of the 'enable_dummy_frames' field */
#define CONFIG_ENABLE_DUMMY_FRAMES_BIT_WIDTH 1 /* bit width of the 'enable_dummy_frames' field */
#define CONFIG_ENABLE_DUMMY_FRAMES_BIT_MASK 0x00040000 /* bit mask of the 'enable_dummy_frames' field */
#define CONFIG_ENABLE_DUMMY_FRAMES_RESET 0x0 /* reset value of the 'enable_dummy_frames' field */

/* Field  'config.swap_input_data_byte_endianness' */
#define CONFIG_SWAP_INPUT_DATA_BYTE_ENDIANNESS_BIT_OFFSET 19 /* bit offset of the 'swap_input_data_byte_endianness' field */
#define CONFIG_SWAP_INPUT_DATA_BYTE_ENDIANNESS_BIT_WIDTH 1 /* bit width of the 'swap_input_data_byte_endianness' field */
#define CONFIG_SWAP_INPUT_DATA_BYTE_ENDIANNESS_BIT_MASK 0x00080000 /* bit mask of the 'swap_input_data_byte_endianness' field */
#define CONFIG_SWAP_INPUT_DATA_BYTE_ENDIANNESS_RESET 0x0 /* reset value of the 'swap_input_data_byte_endianness' field */

/* Field  'config.swap_output_data_byte_endianness' */
#define CONFIG_SWAP_OUTPUT_DATA_BYTE_ENDIANNESS_BIT_OFFSET 20 /* bit offset of the 'swap_output_data_byte_endianness' field */
#define CONFIG_SWAP_OUTPUT_DATA_BYTE_ENDIANNESS_BIT_WIDTH 1 /* bit width of the 'swap_output_data_byte_endianness' field */
#define CONFIG_SWAP_OUTPUT_DATA_BYTE_ENDIANNESS_BIT_MASK 0x00100000 /* bit mask of the 'swap_output_data_byte_endianness' field */
#define CONFIG_SWAP_OUTPUT_DATA_BYTE_ENDIANNESS_RESET 0x0 /* reset value of the 'swap_output_data_byte_endianness' field */

/* Field  'config.force_output_ready' */
#define CONFIG_FORCE_OUTPUT_READY_BIT_OFFSET 21 /* bit offset of the 'force_output_ready' field */
#define CONFIG_FORCE_OUTPUT_READY_BIT_WIDTH 1 /* bit width of the 'force_output_ready' field */
#define CONFIG_FORCE_OUTPUT_READY_BIT_MASK 0x00200000 /* bit mask of the 'force_output_ready' field */
#define CONFIG_FORCE_OUTPUT_READY_RESET 0x0 /* reset value of the 'force_output_ready' field */

/* Register 'ldpc_fifo_status' */
#define LDPC_FIFO_STATUS_OFFSET 0x00000004 /* address offset of the 'ldpc_fifo_status' register */

/* Field  'ldpc_fifo_status.ldpc_fifo_entries' */
#define LDPC_FIFO_STATUS_LDPC_FIFO_ENTRIES_BIT_OFFSET 0 /* bit offset of the 'ldpc_fifo_entries' field */
#define LDPC_FIFO_STATUS_LDPC_FIFO_ENTRIES_BIT_WIDTH 14 /* bit width of the 'ldpc_fifo_entries' field */
#define LDPC_FIFO_STATUS_LDPC_FIFO_ENTRIES_BIT_MASK 0x00003FFF /* bit mask of the 'ldpc_fifo_entries' field */
#define LDPC_FIFO_STATUS_LDPC_FIFO_ENTRIES_RESET 0x0 /* reset value of the 'ldpc_fifo_entries' field */

/* Field  'ldpc_fifo_status.ldpc_fifo_empty' */
#define LDPC_FIFO_STATUS_LDPC_FIFO_EMPTY_BIT_OFFSET 16 /* bit offset of the 'ldpc_fifo_empty' field */
#define LDPC_FIFO_STATUS_LDPC_FIFO_EMPTY_BIT_WIDTH 1 /* bit width of the 'ldpc_fifo_empty' field */
#define LDPC_FIFO_STATUS_LDPC_FIFO_EMPTY_BIT_MASK 0x00010000 /* bit mask of the 'ldpc_fifo_empty' field */
#define LDPC_FIFO_STATUS_LDPC_FIFO_EMPTY_RESET 0x0 /* reset value of the 'ldpc_fifo_empty' field */

/* Field  'ldpc_fifo_status.ldpc_fifo_full' */
#define LDPC_FIFO_STATUS_LDPC_FIFO_FULL_BIT_OFFSET 17 /* bit offset of the 'ldpc_fifo_full' field */
#define LDPC_FIFO_STATUS_LDPC_FIFO_FULL_BIT_WIDTH 1 /* bit width of the 'ldpc_fifo_full' field */
#define LDPC_FIFO_STATUS_LDPC_FIFO_FULL_BIT_MASK 0x00020000 /* bit mask of the 'ldpc_fifo_full' field */
#define LDPC_FIFO_STATUS_LDPC_FIFO_FULL_RESET 0x0 /* reset value of the 'ldpc_fifo_full' field */

/* Field  'ldpc_fifo_status.arbiter_selected' */
#define LDPC_FIFO_STATUS_ARBITER_SELECTED_BIT_OFFSET 20 /* bit offset of the 'arbiter_selected' field */
#define LDPC_FIFO_STATUS_ARBITER_SELECTED_BIT_WIDTH 2 /* bit width of the 'arbiter_selected' field */
#define LDPC_FIFO_STATUS_ARBITER_SELECTED_BIT_MASK 0x00300000 /* bit mask of the 'arbiter_selected' field */
#define LDPC_FIFO_STATUS_ARBITER_SELECTED_RESET 0x0 /* reset value of the 'arbiter_selected' field */

/* Register 'frames_in_transit' */
#define FRAMES_IN_TRANSIT_OFFSET 0x00000008 /* address offset of the 'frames_in_transit' register */

/* Field  'frames_in_transit.value' */
#define FRAMES_IN_TRANSIT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define FRAMES_IN_TRANSIT_VALUE_BIT_WIDTH 8 /* bit width of the 'value' field */
#define FRAMES_IN_TRANSIT_VALUE_BIT_MASK 0x000000FF /* bit mask of the 'value' field */
#define FRAMES_IN_TRANSIT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'constellation_mapper_address' */
#define CONSTELLATION_MAPPER_ADDRESS_OFFSET 0x0000000C /* address offset of the 'constellation_mapper_address' register */

/* Field  'constellation_mapper_address.value' */
#define CONSTELLATION_MAPPER_ADDRESS_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define CONSTELLATION_MAPPER_ADDRESS_VALUE_BIT_WIDTH 32 /* bit width of the 'value' field */
#define CONSTELLATION_MAPPER_ADDRESS_VALUE_BIT_MASK 0xFFFFFFFF /* bit mask of the 'value' field */
#define CONSTELLATION_MAPPER_ADDRESS_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'constellation_mapper_write_data' */
#define CONSTELLATION_MAPPER_WRITE_DATA_OFFSET 0x00000010 /* address offset of the 'constellation_mapper_write_data' register */

/* Field  'constellation_mapper_write_data.value' */
#define CONSTELLATION_MAPPER_WRITE_DATA_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define CONSTELLATION_MAPPER_WRITE_DATA_VALUE_BIT_WIDTH 32 /* bit width of the 'value' field */
#define CONSTELLATION_MAPPER_WRITE_DATA_VALUE_BIT_MASK 0xFFFFFFFF /* bit mask of the 'value' field */
#define CONSTELLATION_MAPPER_WRITE_DATA_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'constellation_mapper_read_data' */
#define CONSTELLATION_MAPPER_READ_DATA_OFFSET 0x00000014 /* address offset of the 'constellation_mapper_read_data' register */

/* Field  'constellation_mapper_read_data.value' */
#define CONSTELLATION_MAPPER_READ_DATA_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define CONSTELLATION_MAPPER_READ_DATA_VALUE_BIT_WIDTH 32 /* bit width of the 'value' field */
#define CONSTELLATION_MAPPER_READ_DATA_VALUE_BIT_MASK 0xFFFFFFFF /* bit mask of the 'value' field */
#define CONSTELLATION_MAPPER_READ_DATA_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_input_width_converter_cfg' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_OFFSET 0x00000D00 /* address offset of the 'axi_debug_input_width_converter_cfg' register */

/* Field  'axi_debug_input_width_converter_cfg.block_data' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_BIT_OFFSET 0 /* bit offset of the 'block_data' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_BIT_WIDTH 1 /* bit width of the 'block_data' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_BIT_MASK 0x00000001 /* bit mask of the 'block_data' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_RESET 0x0 /* reset value of the 'block_data' field */

/* Field  'axi_debug_input_width_converter_cfg.allow_word' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_BIT_OFFSET 1 /* bit offset of the 'allow_word' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_BIT_WIDTH 1 /* bit width of the 'allow_word' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_BIT_MASK 0x00000002 /* bit mask of the 'allow_word' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_RESET 0x0 /* reset value of the 'allow_word' field */

/* Field  'axi_debug_input_width_converter_cfg.allow_frame' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_BIT_OFFSET 2 /* bit offset of the 'allow_frame' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_BIT_WIDTH 1 /* bit width of the 'allow_frame' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_BIT_MASK 0x00000004 /* bit mask of the 'allow_frame' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_RESET 0x0 /* reset value of the 'allow_frame' field */

/* Register 'axi_debug_input_width_converter_frame_count' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_OFFSET 0x00000D04 /* address offset of the 'axi_debug_input_width_converter_frame_count' register */

/* Field  'axi_debug_input_width_converter_frame_count.value' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_input_width_converter_last_frame_length' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_OFFSET 0x00000D08 /* address offset of the 'axi_debug_input_width_converter_last_frame_length' register */

/* Field  'axi_debug_input_width_converter_last_frame_length.value' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_input_width_converter_min_max_frame_length' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_OFFSET 0x00000D0C /* address offset of the 'axi_debug_input_width_converter_min_max_frame_length' register */

/* Field  'axi_debug_input_width_converter_min_max_frame_length.min_frame_length' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET 0 /* bit offset of the 'min_frame_length' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH 16 /* bit width of the 'min_frame_length' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_MASK 0x0000FFFF /* bit mask of the 'min_frame_length' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET 0x0 /* reset value of the 'min_frame_length' field */

/* Field  'axi_debug_input_width_converter_min_max_frame_length.max_frame_length' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET 16 /* bit offset of the 'max_frame_length' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH 16 /* bit width of the 'max_frame_length' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_MASK 0xFFFF0000 /* bit mask of the 'max_frame_length' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET 0x0 /* reset value of the 'max_frame_length' field */

/* Register 'axi_debug_input_width_converter_word_count' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_OFFSET 0x00000D10 /* address offset of the 'axi_debug_input_width_converter_word_count' register */

/* Field  'axi_debug_input_width_converter_word_count.value' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_input_width_converter_strobes' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_OFFSET 0x00000D14 /* address offset of the 'axi_debug_input_width_converter_strobes' register */

/* Field  'axi_debug_input_width_converter_strobes.s_tvalid' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TVALID_BIT_OFFSET 0 /* bit offset of the 's_tvalid' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TVALID_BIT_WIDTH 1 /* bit width of the 's_tvalid' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TVALID_BIT_MASK 0x00000001 /* bit mask of the 's_tvalid' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TVALID_RESET 0x0 /* reset value of the 's_tvalid' field */

/* Field  'axi_debug_input_width_converter_strobes.s_tready' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TREADY_BIT_OFFSET 1 /* bit offset of the 's_tready' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TREADY_BIT_WIDTH 1 /* bit width of the 's_tready' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TREADY_BIT_MASK 0x00000002 /* bit mask of the 's_tready' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TREADY_RESET 0x0 /* reset value of the 's_tready' field */

/* Field  'axi_debug_input_width_converter_strobes.m_tvalid' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TVALID_BIT_OFFSET 2 /* bit offset of the 'm_tvalid' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TVALID_BIT_WIDTH 1 /* bit width of the 'm_tvalid' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TVALID_BIT_MASK 0x00000004 /* bit mask of the 'm_tvalid' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TVALID_RESET 0x0 /* reset value of the 'm_tvalid' field */

/* Field  'axi_debug_input_width_converter_strobes.m_tready' */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TREADY_BIT_OFFSET 3 /* bit offset of the 'm_tready' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TREADY_BIT_WIDTH 1 /* bit width of the 'm_tready' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TREADY_BIT_MASK 0x00000008 /* bit mask of the 'm_tready' field */
#define AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TREADY_RESET 0x0 /* reset value of the 'm_tready' field */

/* Register 'axi_debug_bb_scrambler_cfg' */
#define AXI_DEBUG_BB_SCRAMBLER_CFG_OFFSET 0x00000E00 /* address offset of the 'axi_debug_bb_scrambler_cfg' register */

/* Field  'axi_debug_bb_scrambler_cfg.block_data' */
#define AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_BIT_OFFSET 0 /* bit offset of the 'block_data' field */
#define AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_BIT_WIDTH 1 /* bit width of the 'block_data' field */
#define AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_BIT_MASK 0x00000001 /* bit mask of the 'block_data' field */
#define AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_RESET 0x0 /* reset value of the 'block_data' field */

/* Field  'axi_debug_bb_scrambler_cfg.allow_word' */
#define AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_BIT_OFFSET 1 /* bit offset of the 'allow_word' field */
#define AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_BIT_WIDTH 1 /* bit width of the 'allow_word' field */
#define AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_BIT_MASK 0x00000002 /* bit mask of the 'allow_word' field */
#define AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_RESET 0x0 /* reset value of the 'allow_word' field */

/* Field  'axi_debug_bb_scrambler_cfg.allow_frame' */
#define AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_BIT_OFFSET 2 /* bit offset of the 'allow_frame' field */
#define AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_BIT_WIDTH 1 /* bit width of the 'allow_frame' field */
#define AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_BIT_MASK 0x00000004 /* bit mask of the 'allow_frame' field */
#define AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_RESET 0x0 /* reset value of the 'allow_frame' field */

/* Register 'axi_debug_bb_scrambler_frame_count' */
#define AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_OFFSET 0x00000E04 /* address offset of the 'axi_debug_bb_scrambler_frame_count' register */

/* Field  'axi_debug_bb_scrambler_frame_count.value' */
#define AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_bb_scrambler_last_frame_length' */
#define AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_OFFSET 0x00000E08 /* address offset of the 'axi_debug_bb_scrambler_last_frame_length' register */

/* Field  'axi_debug_bb_scrambler_last_frame_length.value' */
#define AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_bb_scrambler_min_max_frame_length' */
#define AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_OFFSET 0x00000E0C /* address offset of the 'axi_debug_bb_scrambler_min_max_frame_length' register */

/* Field  'axi_debug_bb_scrambler_min_max_frame_length.min_frame_length' */
#define AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET 0 /* bit offset of the 'min_frame_length' field */
#define AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH 16 /* bit width of the 'min_frame_length' field */
#define AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_MASK 0x0000FFFF /* bit mask of the 'min_frame_length' field */
#define AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET 0x0 /* reset value of the 'min_frame_length' field */

/* Field  'axi_debug_bb_scrambler_min_max_frame_length.max_frame_length' */
#define AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET 16 /* bit offset of the 'max_frame_length' field */
#define AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH 16 /* bit width of the 'max_frame_length' field */
#define AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_MASK 0xFFFF0000 /* bit mask of the 'max_frame_length' field */
#define AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET 0x0 /* reset value of the 'max_frame_length' field */

/* Register 'axi_debug_bb_scrambler_word_count' */
#define AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_OFFSET 0x00000E10 /* address offset of the 'axi_debug_bb_scrambler_word_count' register */

/* Field  'axi_debug_bb_scrambler_word_count.value' */
#define AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_bb_scrambler_strobes' */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_OFFSET 0x00000E14 /* address offset of the 'axi_debug_bb_scrambler_strobes' register */

/* Field  'axi_debug_bb_scrambler_strobes.s_tvalid' */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TVALID_BIT_OFFSET 0 /* bit offset of the 's_tvalid' field */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TVALID_BIT_WIDTH 1 /* bit width of the 's_tvalid' field */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TVALID_BIT_MASK 0x00000001 /* bit mask of the 's_tvalid' field */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TVALID_RESET 0x0 /* reset value of the 's_tvalid' field */

/* Field  'axi_debug_bb_scrambler_strobes.s_tready' */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TREADY_BIT_OFFSET 1 /* bit offset of the 's_tready' field */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TREADY_BIT_WIDTH 1 /* bit width of the 's_tready' field */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TREADY_BIT_MASK 0x00000002 /* bit mask of the 's_tready' field */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TREADY_RESET 0x0 /* reset value of the 's_tready' field */

/* Field  'axi_debug_bb_scrambler_strobes.m_tvalid' */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TVALID_BIT_OFFSET 2 /* bit offset of the 'm_tvalid' field */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TVALID_BIT_WIDTH 1 /* bit width of the 'm_tvalid' field */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TVALID_BIT_MASK 0x00000004 /* bit mask of the 'm_tvalid' field */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TVALID_RESET 0x0 /* reset value of the 'm_tvalid' field */

/* Field  'axi_debug_bb_scrambler_strobes.m_tready' */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TREADY_BIT_OFFSET 3 /* bit offset of the 'm_tready' field */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TREADY_BIT_WIDTH 1 /* bit width of the 'm_tready' field */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TREADY_BIT_MASK 0x00000008 /* bit mask of the 'm_tready' field */
#define AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TREADY_RESET 0x0 /* reset value of the 'm_tready' field */

/* Register 'axi_debug_bch_encoder_cfg' */
#define AXI_DEBUG_BCH_ENCODER_CFG_OFFSET 0x00000F00 /* address offset of the 'axi_debug_bch_encoder_cfg' register */

/* Field  'axi_debug_bch_encoder_cfg.block_data' */
#define AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_BIT_OFFSET 0 /* bit offset of the 'block_data' field */
#define AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_BIT_WIDTH 1 /* bit width of the 'block_data' field */
#define AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_BIT_MASK 0x00000001 /* bit mask of the 'block_data' field */
#define AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_RESET 0x0 /* reset value of the 'block_data' field */

/* Field  'axi_debug_bch_encoder_cfg.allow_word' */
#define AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_BIT_OFFSET 1 /* bit offset of the 'allow_word' field */
#define AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_BIT_WIDTH 1 /* bit width of the 'allow_word' field */
#define AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_BIT_MASK 0x00000002 /* bit mask of the 'allow_word' field */
#define AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_RESET 0x0 /* reset value of the 'allow_word' field */

/* Field  'axi_debug_bch_encoder_cfg.allow_frame' */
#define AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_BIT_OFFSET 2 /* bit offset of the 'allow_frame' field */
#define AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_BIT_WIDTH 1 /* bit width of the 'allow_frame' field */
#define AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_BIT_MASK 0x00000004 /* bit mask of the 'allow_frame' field */
#define AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_RESET 0x0 /* reset value of the 'allow_frame' field */

/* Register 'axi_debug_bch_encoder_frame_count' */
#define AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_OFFSET 0x00000F04 /* address offset of the 'axi_debug_bch_encoder_frame_count' register */

/* Field  'axi_debug_bch_encoder_frame_count.value' */
#define AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_bch_encoder_last_frame_length' */
#define AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_OFFSET 0x00000F08 /* address offset of the 'axi_debug_bch_encoder_last_frame_length' register */

/* Field  'axi_debug_bch_encoder_last_frame_length.value' */
#define AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_bch_encoder_min_max_frame_length' */
#define AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET 0x00000F0C /* address offset of the 'axi_debug_bch_encoder_min_max_frame_length' register */

/* Field  'axi_debug_bch_encoder_min_max_frame_length.min_frame_length' */
#define AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET 0 /* bit offset of the 'min_frame_length' field */
#define AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH 16 /* bit width of the 'min_frame_length' field */
#define AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_MASK 0x0000FFFF /* bit mask of the 'min_frame_length' field */
#define AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET 0x0 /* reset value of the 'min_frame_length' field */

/* Field  'axi_debug_bch_encoder_min_max_frame_length.max_frame_length' */
#define AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET 16 /* bit offset of the 'max_frame_length' field */
#define AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH 16 /* bit width of the 'max_frame_length' field */
#define AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_MASK 0xFFFF0000 /* bit mask of the 'max_frame_length' field */
#define AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET 0x0 /* reset value of the 'max_frame_length' field */

/* Register 'axi_debug_bch_encoder_word_count' */
#define AXI_DEBUG_BCH_ENCODER_WORD_COUNT_OFFSET 0x00000F10 /* address offset of the 'axi_debug_bch_encoder_word_count' register */

/* Field  'axi_debug_bch_encoder_word_count.value' */
#define AXI_DEBUG_BCH_ENCODER_WORD_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_BCH_ENCODER_WORD_COUNT_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_BCH_ENCODER_WORD_COUNT_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_BCH_ENCODER_WORD_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_bch_encoder_strobes' */
#define AXI_DEBUG_BCH_ENCODER_STROBES_OFFSET 0x00000F14 /* address offset of the 'axi_debug_bch_encoder_strobes' register */

/* Field  'axi_debug_bch_encoder_strobes.s_tvalid' */
#define AXI_DEBUG_BCH_ENCODER_STROBES_S_TVALID_BIT_OFFSET 0 /* bit offset of the 's_tvalid' field */
#define AXI_DEBUG_BCH_ENCODER_STROBES_S_TVALID_BIT_WIDTH 1 /* bit width of the 's_tvalid' field */
#define AXI_DEBUG_BCH_ENCODER_STROBES_S_TVALID_BIT_MASK 0x00000001 /* bit mask of the 's_tvalid' field */
#define AXI_DEBUG_BCH_ENCODER_STROBES_S_TVALID_RESET 0x0 /* reset value of the 's_tvalid' field */

/* Field  'axi_debug_bch_encoder_strobes.s_tready' */
#define AXI_DEBUG_BCH_ENCODER_STROBES_S_TREADY_BIT_OFFSET 1 /* bit offset of the 's_tready' field */
#define AXI_DEBUG_BCH_ENCODER_STROBES_S_TREADY_BIT_WIDTH 1 /* bit width of the 's_tready' field */
#define AXI_DEBUG_BCH_ENCODER_STROBES_S_TREADY_BIT_MASK 0x00000002 /* bit mask of the 's_tready' field */
#define AXI_DEBUG_BCH_ENCODER_STROBES_S_TREADY_RESET 0x0 /* reset value of the 's_tready' field */

/* Field  'axi_debug_bch_encoder_strobes.m_tvalid' */
#define AXI_DEBUG_BCH_ENCODER_STROBES_M_TVALID_BIT_OFFSET 2 /* bit offset of the 'm_tvalid' field */
#define AXI_DEBUG_BCH_ENCODER_STROBES_M_TVALID_BIT_WIDTH 1 /* bit width of the 'm_tvalid' field */
#define AXI_DEBUG_BCH_ENCODER_STROBES_M_TVALID_BIT_MASK 0x00000004 /* bit mask of the 'm_tvalid' field */
#define AXI_DEBUG_BCH_ENCODER_STROBES_M_TVALID_RESET 0x0 /* reset value of the 'm_tvalid' field */

/* Field  'axi_debug_bch_encoder_strobes.m_tready' */
#define AXI_DEBUG_BCH_ENCODER_STROBES_M_TREADY_BIT_OFFSET 3 /* bit offset of the 'm_tready' field */
#define AXI_DEBUG_BCH_ENCODER_STROBES_M_TREADY_BIT_WIDTH 1 /* bit width of the 'm_tready' field */
#define AXI_DEBUG_BCH_ENCODER_STROBES_M_TREADY_BIT_MASK 0x00000008 /* bit mask of the 'm_tready' field */
#define AXI_DEBUG_BCH_ENCODER_STROBES_M_TREADY_RESET 0x0 /* reset value of the 'm_tready' field */

/* Register 'axi_debug_ldpc_encoder_cfg' */
#define AXI_DEBUG_LDPC_ENCODER_CFG_OFFSET 0x00001000 /* address offset of the 'axi_debug_ldpc_encoder_cfg' register */

/* Field  'axi_debug_ldpc_encoder_cfg.block_data' */
#define AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_BIT_OFFSET 0 /* bit offset of the 'block_data' field */
#define AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_BIT_WIDTH 1 /* bit width of the 'block_data' field */
#define AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_BIT_MASK 0x00000001 /* bit mask of the 'block_data' field */
#define AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_RESET 0x0 /* reset value of the 'block_data' field */

/* Field  'axi_debug_ldpc_encoder_cfg.allow_word' */
#define AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_BIT_OFFSET 1 /* bit offset of the 'allow_word' field */
#define AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_BIT_WIDTH 1 /* bit width of the 'allow_word' field */
#define AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_BIT_MASK 0x00000002 /* bit mask of the 'allow_word' field */
#define AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_RESET 0x0 /* reset value of the 'allow_word' field */

/* Field  'axi_debug_ldpc_encoder_cfg.allow_frame' */
#define AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_BIT_OFFSET 2 /* bit offset of the 'allow_frame' field */
#define AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_BIT_WIDTH 1 /* bit width of the 'allow_frame' field */
#define AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_BIT_MASK 0x00000004 /* bit mask of the 'allow_frame' field */
#define AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_RESET 0x0 /* reset value of the 'allow_frame' field */

/* Register 'axi_debug_ldpc_encoder_frame_count' */
#define AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_OFFSET 0x00001004 /* address offset of the 'axi_debug_ldpc_encoder_frame_count' register */

/* Field  'axi_debug_ldpc_encoder_frame_count.value' */
#define AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_ldpc_encoder_last_frame_length' */
#define AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_OFFSET 0x00001008 /* address offset of the 'axi_debug_ldpc_encoder_last_frame_length' register */

/* Field  'axi_debug_ldpc_encoder_last_frame_length.value' */
#define AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_ldpc_encoder_min_max_frame_length' */
#define AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET 0x0000100C /* address offset of the 'axi_debug_ldpc_encoder_min_max_frame_length' register */

/* Field  'axi_debug_ldpc_encoder_min_max_frame_length.min_frame_length' */
#define AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET 0 /* bit offset of the 'min_frame_length' field */
#define AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH 16 /* bit width of the 'min_frame_length' field */
#define AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_MASK 0x0000FFFF /* bit mask of the 'min_frame_length' field */
#define AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET 0x0 /* reset value of the 'min_frame_length' field */

/* Field  'axi_debug_ldpc_encoder_min_max_frame_length.max_frame_length' */
#define AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET 16 /* bit offset of the 'max_frame_length' field */
#define AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH 16 /* bit width of the 'max_frame_length' field */
#define AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_MASK 0xFFFF0000 /* bit mask of the 'max_frame_length' field */
#define AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET 0x0 /* reset value of the 'max_frame_length' field */

/* Register 'axi_debug_ldpc_encoder_word_count' */
#define AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_OFFSET 0x00001010 /* address offset of the 'axi_debug_ldpc_encoder_word_count' register */

/* Field  'axi_debug_ldpc_encoder_word_count.value' */
#define AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_ldpc_encoder_strobes' */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_OFFSET 0x00001014 /* address offset of the 'axi_debug_ldpc_encoder_strobes' register */

/* Field  'axi_debug_ldpc_encoder_strobes.s_tvalid' */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_S_TVALID_BIT_OFFSET 0 /* bit offset of the 's_tvalid' field */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_S_TVALID_BIT_WIDTH 1 /* bit width of the 's_tvalid' field */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_S_TVALID_BIT_MASK 0x00000001 /* bit mask of the 's_tvalid' field */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_S_TVALID_RESET 0x0 /* reset value of the 's_tvalid' field */

/* Field  'axi_debug_ldpc_encoder_strobes.s_tready' */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_S_TREADY_BIT_OFFSET 1 /* bit offset of the 's_tready' field */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_S_TREADY_BIT_WIDTH 1 /* bit width of the 's_tready' field */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_S_TREADY_BIT_MASK 0x00000002 /* bit mask of the 's_tready' field */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_S_TREADY_RESET 0x0 /* reset value of the 's_tready' field */

/* Field  'axi_debug_ldpc_encoder_strobes.m_tvalid' */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_M_TVALID_BIT_OFFSET 2 /* bit offset of the 'm_tvalid' field */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_M_TVALID_BIT_WIDTH 1 /* bit width of the 'm_tvalid' field */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_M_TVALID_BIT_MASK 0x00000004 /* bit mask of the 'm_tvalid' field */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_M_TVALID_RESET 0x0 /* reset value of the 'm_tvalid' field */

/* Field  'axi_debug_ldpc_encoder_strobes.m_tready' */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_M_TREADY_BIT_OFFSET 3 /* bit offset of the 'm_tready' field */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_M_TREADY_BIT_WIDTH 1 /* bit width of the 'm_tready' field */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_M_TREADY_BIT_MASK 0x00000008 /* bit mask of the 'm_tready' field */
#define AXI_DEBUG_LDPC_ENCODER_STROBES_M_TREADY_RESET 0x0 /* reset value of the 'm_tready' field */

/* Register 'axi_debug_bit_interleaver_cfg' */
#define AXI_DEBUG_BIT_INTERLEAVER_CFG_OFFSET 0x00001100 /* address offset of the 'axi_debug_bit_interleaver_cfg' register */

/* Field  'axi_debug_bit_interleaver_cfg.block_data' */
#define AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_BIT_OFFSET 0 /* bit offset of the 'block_data' field */
#define AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_BIT_WIDTH 1 /* bit width of the 'block_data' field */
#define AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_BIT_MASK 0x00000001 /* bit mask of the 'block_data' field */
#define AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_RESET 0x0 /* reset value of the 'block_data' field */

/* Field  'axi_debug_bit_interleaver_cfg.allow_word' */
#define AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_BIT_OFFSET 1 /* bit offset of the 'allow_word' field */
#define AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_BIT_WIDTH 1 /* bit width of the 'allow_word' field */
#define AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_BIT_MASK 0x00000002 /* bit mask of the 'allow_word' field */
#define AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_RESET 0x0 /* reset value of the 'allow_word' field */

/* Field  'axi_debug_bit_interleaver_cfg.allow_frame' */
#define AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_BIT_OFFSET 2 /* bit offset of the 'allow_frame' field */
#define AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_BIT_WIDTH 1 /* bit width of the 'allow_frame' field */
#define AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_BIT_MASK 0x00000004 /* bit mask of the 'allow_frame' field */
#define AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_RESET 0x0 /* reset value of the 'allow_frame' field */

/* Register 'axi_debug_bit_interleaver_frame_count' */
#define AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_OFFSET 0x00001104 /* address offset of the 'axi_debug_bit_interleaver_frame_count' register */

/* Field  'axi_debug_bit_interleaver_frame_count.value' */
#define AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_bit_interleaver_last_frame_length' */
#define AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_OFFSET 0x00001108 /* address offset of the 'axi_debug_bit_interleaver_last_frame_length' register */

/* Field  'axi_debug_bit_interleaver_last_frame_length.value' */
#define AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_bit_interleaver_min_max_frame_length' */
#define AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_OFFSET 0x0000110C /* address offset of the 'axi_debug_bit_interleaver_min_max_frame_length' register */

/* Field  'axi_debug_bit_interleaver_min_max_frame_length.min_frame_length' */
#define AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET 0 /* bit offset of the 'min_frame_length' field */
#define AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH 16 /* bit width of the 'min_frame_length' field */
#define AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_MASK 0x0000FFFF /* bit mask of the 'min_frame_length' field */
#define AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET 0x0 /* reset value of the 'min_frame_length' field */

/* Field  'axi_debug_bit_interleaver_min_max_frame_length.max_frame_length' */
#define AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET 16 /* bit offset of the 'max_frame_length' field */
#define AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH 16 /* bit width of the 'max_frame_length' field */
#define AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_MASK 0xFFFF0000 /* bit mask of the 'max_frame_length' field */
#define AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET 0x0 /* reset value of the 'max_frame_length' field */

/* Register 'axi_debug_bit_interleaver_word_count' */
#define AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_OFFSET 0x00001110 /* address offset of the 'axi_debug_bit_interleaver_word_count' register */

/* Field  'axi_debug_bit_interleaver_word_count.value' */
#define AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_bit_interleaver_strobes' */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_OFFSET 0x00001114 /* address offset of the 'axi_debug_bit_interleaver_strobes' register */

/* Field  'axi_debug_bit_interleaver_strobes.s_tvalid' */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TVALID_BIT_OFFSET 0 /* bit offset of the 's_tvalid' field */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TVALID_BIT_WIDTH 1 /* bit width of the 's_tvalid' field */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TVALID_BIT_MASK 0x00000001 /* bit mask of the 's_tvalid' field */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TVALID_RESET 0x0 /* reset value of the 's_tvalid' field */

/* Field  'axi_debug_bit_interleaver_strobes.s_tready' */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TREADY_BIT_OFFSET 1 /* bit offset of the 's_tready' field */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TREADY_BIT_WIDTH 1 /* bit width of the 's_tready' field */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TREADY_BIT_MASK 0x00000002 /* bit mask of the 's_tready' field */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TREADY_RESET 0x0 /* reset value of the 's_tready' field */

/* Field  'axi_debug_bit_interleaver_strobes.m_tvalid' */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TVALID_BIT_OFFSET 2 /* bit offset of the 'm_tvalid' field */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TVALID_BIT_WIDTH 1 /* bit width of the 'm_tvalid' field */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TVALID_BIT_MASK 0x00000004 /* bit mask of the 'm_tvalid' field */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TVALID_RESET 0x0 /* reset value of the 'm_tvalid' field */

/* Field  'axi_debug_bit_interleaver_strobes.m_tready' */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TREADY_BIT_OFFSET 3 /* bit offset of the 'm_tready' field */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TREADY_BIT_WIDTH 1 /* bit width of the 'm_tready' field */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TREADY_BIT_MASK 0x00000008 /* bit mask of the 'm_tready' field */
#define AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TREADY_RESET 0x0 /* reset value of the 'm_tready' field */

/* Register 'axi_debug_constellation_mapper_cfg' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_CFG_OFFSET 0x00001200 /* address offset of the 'axi_debug_constellation_mapper_cfg' register */

/* Field  'axi_debug_constellation_mapper_cfg.block_data' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_CFG_BLOCK_DATA_BIT_OFFSET 0 /* bit offset of the 'block_data' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_CFG_BLOCK_DATA_BIT_WIDTH 1 /* bit width of the 'block_data' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_CFG_BLOCK_DATA_BIT_MASK 0x00000001 /* bit mask of the 'block_data' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_CFG_BLOCK_DATA_RESET 0x0 /* reset value of the 'block_data' field */

/* Field  'axi_debug_constellation_mapper_cfg.allow_word' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_WORD_BIT_OFFSET 1 /* bit offset of the 'allow_word' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_WORD_BIT_WIDTH 1 /* bit width of the 'allow_word' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_WORD_BIT_MASK 0x00000002 /* bit mask of the 'allow_word' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_WORD_RESET 0x0 /* reset value of the 'allow_word' field */

/* Field  'axi_debug_constellation_mapper_cfg.allow_frame' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_FRAME_BIT_OFFSET 2 /* bit offset of the 'allow_frame' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_FRAME_BIT_WIDTH 1 /* bit width of the 'allow_frame' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_FRAME_BIT_MASK 0x00000004 /* bit mask of the 'allow_frame' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_FRAME_RESET 0x0 /* reset value of the 'allow_frame' field */

/* Register 'axi_debug_constellation_mapper_frame_count' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_FRAME_COUNT_OFFSET 0x00001204 /* address offset of the 'axi_debug_constellation_mapper_frame_count' register */

/* Field  'axi_debug_constellation_mapper_frame_count.value' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_FRAME_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_FRAME_COUNT_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_FRAME_COUNT_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_FRAME_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_constellation_mapper_last_frame_length' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_LAST_FRAME_LENGTH_OFFSET 0x00001208 /* address offset of the 'axi_debug_constellation_mapper_last_frame_length' register */

/* Field  'axi_debug_constellation_mapper_last_frame_length.value' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_LAST_FRAME_LENGTH_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_LAST_FRAME_LENGTH_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_constellation_mapper_min_max_frame_length' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_OFFSET 0x0000120C /* address offset of the 'axi_debug_constellation_mapper_min_max_frame_length' register */

/* Field  'axi_debug_constellation_mapper_min_max_frame_length.min_frame_length' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET 0 /* bit offset of the 'min_frame_length' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH 16 /* bit width of the 'min_frame_length' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_MASK 0x0000FFFF /* bit mask of the 'min_frame_length' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET 0x0 /* reset value of the 'min_frame_length' field */

/* Field  'axi_debug_constellation_mapper_min_max_frame_length.max_frame_length' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET 16 /* bit offset of the 'max_frame_length' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH 16 /* bit width of the 'max_frame_length' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_MASK 0xFFFF0000 /* bit mask of the 'max_frame_length' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET 0x0 /* reset value of the 'max_frame_length' field */

/* Register 'axi_debug_constellation_mapper_word_count' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_WORD_COUNT_OFFSET 0x00001210 /* address offset of the 'axi_debug_constellation_mapper_word_count' register */

/* Field  'axi_debug_constellation_mapper_word_count.value' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_WORD_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_WORD_COUNT_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_WORD_COUNT_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_WORD_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_constellation_mapper_strobes' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_OFFSET 0x00001214 /* address offset of the 'axi_debug_constellation_mapper_strobes' register */

/* Field  'axi_debug_constellation_mapper_strobes.s_tvalid' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_S_TVALID_BIT_OFFSET 0 /* bit offset of the 's_tvalid' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_S_TVALID_BIT_WIDTH 1 /* bit width of the 's_tvalid' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_S_TVALID_BIT_MASK 0x00000001 /* bit mask of the 's_tvalid' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_S_TVALID_RESET 0x0 /* reset value of the 's_tvalid' field */

/* Field  'axi_debug_constellation_mapper_strobes.s_tready' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_S_TREADY_BIT_OFFSET 1 /* bit offset of the 's_tready' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_S_TREADY_BIT_WIDTH 1 /* bit width of the 's_tready' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_S_TREADY_BIT_MASK 0x00000002 /* bit mask of the 's_tready' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_S_TREADY_RESET 0x0 /* reset value of the 's_tready' field */

/* Field  'axi_debug_constellation_mapper_strobes.m_tvalid' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_M_TVALID_BIT_OFFSET 2 /* bit offset of the 'm_tvalid' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_M_TVALID_BIT_WIDTH 1 /* bit width of the 'm_tvalid' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_M_TVALID_BIT_MASK 0x00000004 /* bit mask of the 'm_tvalid' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_M_TVALID_RESET 0x0 /* reset value of the 'm_tvalid' field */

/* Field  'axi_debug_constellation_mapper_strobes.m_tready' */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_M_TREADY_BIT_OFFSET 3 /* bit offset of the 'm_tready' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_M_TREADY_BIT_WIDTH 1 /* bit width of the 'm_tready' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_M_TREADY_BIT_MASK 0x00000008 /* bit mask of the 'm_tready' field */
#define AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_M_TREADY_RESET 0x0 /* reset value of the 'm_tready' field */

/* Register 'axi_debug_plframe_cfg' */
#define AXI_DEBUG_PLFRAME_CFG_OFFSET 0x00001300 /* address offset of the 'axi_debug_plframe_cfg' register */

/* Field  'axi_debug_plframe_cfg.block_data' */
#define AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_BIT_OFFSET 0 /* bit offset of the 'block_data' field */
#define AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_BIT_WIDTH 1 /* bit width of the 'block_data' field */
#define AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_BIT_MASK 0x00000001 /* bit mask of the 'block_data' field */
#define AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_RESET 0x0 /* reset value of the 'block_data' field */

/* Field  'axi_debug_plframe_cfg.allow_word' */
#define AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_BIT_OFFSET 1 /* bit offset of the 'allow_word' field */
#define AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_BIT_WIDTH 1 /* bit width of the 'allow_word' field */
#define AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_BIT_MASK 0x00000002 /* bit mask of the 'allow_word' field */
#define AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_RESET 0x0 /* reset value of the 'allow_word' field */

/* Field  'axi_debug_plframe_cfg.allow_frame' */
#define AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_BIT_OFFSET 2 /* bit offset of the 'allow_frame' field */
#define AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_BIT_WIDTH 1 /* bit width of the 'allow_frame' field */
#define AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_BIT_MASK 0x00000004 /* bit mask of the 'allow_frame' field */
#define AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_RESET 0x0 /* reset value of the 'allow_frame' field */

/* Register 'axi_debug_plframe_frame_count' */
#define AXI_DEBUG_PLFRAME_FRAME_COUNT_OFFSET 0x00001304 /* address offset of the 'axi_debug_plframe_frame_count' register */

/* Field  'axi_debug_plframe_frame_count.value' */
#define AXI_DEBUG_PLFRAME_FRAME_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_PLFRAME_FRAME_COUNT_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_PLFRAME_FRAME_COUNT_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_PLFRAME_FRAME_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_plframe_last_frame_length' */
#define AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_OFFSET 0x00001308 /* address offset of the 'axi_debug_plframe_last_frame_length' register */

/* Field  'axi_debug_plframe_last_frame_length.value' */
#define AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_plframe_min_max_frame_length' */
#define AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_OFFSET 0x0000130C /* address offset of the 'axi_debug_plframe_min_max_frame_length' register */

/* Field  'axi_debug_plframe_min_max_frame_length.min_frame_length' */
#define AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET 0 /* bit offset of the 'min_frame_length' field */
#define AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH 16 /* bit width of the 'min_frame_length' field */
#define AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_MASK 0x0000FFFF /* bit mask of the 'min_frame_length' field */
#define AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET 0x0 /* reset value of the 'min_frame_length' field */

/* Field  'axi_debug_plframe_min_max_frame_length.max_frame_length' */
#define AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET 16 /* bit offset of the 'max_frame_length' field */
#define AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH 16 /* bit width of the 'max_frame_length' field */
#define AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_MASK 0xFFFF0000 /* bit mask of the 'max_frame_length' field */
#define AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET 0x0 /* reset value of the 'max_frame_length' field */

/* Register 'axi_debug_plframe_word_count' */
#define AXI_DEBUG_PLFRAME_WORD_COUNT_OFFSET 0x00001310 /* address offset of the 'axi_debug_plframe_word_count' register */

/* Field  'axi_debug_plframe_word_count.value' */
#define AXI_DEBUG_PLFRAME_WORD_COUNT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define AXI_DEBUG_PLFRAME_WORD_COUNT_VALUE_BIT_WIDTH 16 /* bit width of the 'value' field */
#define AXI_DEBUG_PLFRAME_WORD_COUNT_VALUE_BIT_MASK 0x0000FFFF /* bit mask of the 'value' field */
#define AXI_DEBUG_PLFRAME_WORD_COUNT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'axi_debug_plframe_strobes' */
#define AXI_DEBUG_PLFRAME_STROBES_OFFSET 0x00001314 /* address offset of the 'axi_debug_plframe_strobes' register */

/* Field  'axi_debug_plframe_strobes.s_tvalid' */
#define AXI_DEBUG_PLFRAME_STROBES_S_TVALID_BIT_OFFSET 0 /* bit offset of the 's_tvalid' field */
#define AXI_DEBUG_PLFRAME_STROBES_S_TVALID_BIT_WIDTH 1 /* bit width of the 's_tvalid' field */
#define AXI_DEBUG_PLFRAME_STROBES_S_TVALID_BIT_MASK 0x00000001 /* bit mask of the 's_tvalid' field */
#define AXI_DEBUG_PLFRAME_STROBES_S_TVALID_RESET 0x0 /* reset value of the 's_tvalid' field */

/* Field  'axi_debug_plframe_strobes.s_tready' */
#define AXI_DEBUG_PLFRAME_STROBES_S_TREADY_BIT_OFFSET 1 /* bit offset of the 's_tready' field */
#define AXI_DEBUG_PLFRAME_STROBES_S_TREADY_BIT_WIDTH 1 /* bit width of the 's_tready' field */
#define AXI_DEBUG_PLFRAME_STROBES_S_TREADY_BIT_MASK 0x00000002 /* bit mask of the 's_tready' field */
#define AXI_DEBUG_PLFRAME_STROBES_S_TREADY_RESET 0x0 /* reset value of the 's_tready' field */

/* Field  'axi_debug_plframe_strobes.m_tvalid' */
#define AXI_DEBUG_PLFRAME_STROBES_M_TVALID_BIT_OFFSET 2 /* bit offset of the 'm_tvalid' field */
#define AXI_DEBUG_PLFRAME_STROBES_M_TVALID_BIT_WIDTH 1 /* bit width of the 'm_tvalid' field */
#define AXI_DEBUG_PLFRAME_STROBES_M_TVALID_BIT_MASK 0x00000004 /* bit mask of the 'm_tvalid' field */
#define AXI_DEBUG_PLFRAME_STROBES_M_TVALID_RESET 0x0 /* reset value of the 'm_tvalid' field */

/* Field  'axi_debug_plframe_strobes.m_tready' */
#define AXI_DEBUG_PLFRAME_STROBES_M_TREADY_BIT_OFFSET 3 /* bit offset of the 'm_tready' field */
#define AXI_DEBUG_PLFRAME_STROBES_M_TREADY_BIT_WIDTH 1 /* bit width of the 'm_tready' field */
#define AXI_DEBUG_PLFRAME_STROBES_M_TREADY_BIT_MASK 0x00000008 /* bit mask of the 'm_tready' field */
#define AXI_DEBUG_PLFRAME_STROBES_M_TREADY_RESET 0x0 /* reset value of the 'm_tready' field */

#endif  /* DVBS2_ENCODER_REGS_H */
