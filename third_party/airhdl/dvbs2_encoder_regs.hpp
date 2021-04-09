// -----------------------------------------------------------------------------
// 'dvbs2_encoder' Register Definitions
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

#ifndef DVBS2_ENCODER_REGS_H
#define DVBS2_ENCODER_REGS_H

#include <string>
#include <cstdint>

namespace dvbs2_encoder_regs {

    static const std::string name = "dvbs2_encoder";

    /* Revision number of the 'dvbs2_encoder' register map */
    static const std::uint32_t REVISION = 144;

    /* Default base address of the 'dvbs2_encoder' register map */
    static const std::uint32_t BASE_ADDRESS = 0x00000000;

    /* Register 'config' */
    static const std::uint32_t CONFIG_OFFSET = 0x00000000; /* address offset of the 'config' register */

    /* Field 'config.physical_layer_scrambler_shift_reg_init' */
    static const int CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_BIT_OFFSET = 0; /* bit offset of the 'physical_layer_scrambler_shift_reg_init' field */
    static const int CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_BIT_WIDTH = 18; /* bit width of the 'physical_layer_scrambler_shift_reg_init' field */
    static const std::uint32_t CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_BIT_MASK = 0x0003FFFF; /* bit mask of the 'physical_layer_scrambler_shift_reg_init' field */
    static const std::uint32_t CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_RESET = 0x1; /* reset value of the 'physical_layer_scrambler_shift_reg_init' field */

    /* Field 'config.enable_dummy_frames' */
    static const int CONFIG_ENABLE_DUMMY_FRAMES_BIT_OFFSET = 18; /* bit offset of the 'enable_dummy_frames' field */
    static const int CONFIG_ENABLE_DUMMY_FRAMES_BIT_WIDTH = 1; /* bit width of the 'enable_dummy_frames' field */
    static const std::uint32_t CONFIG_ENABLE_DUMMY_FRAMES_BIT_MASK = 0x00040000; /* bit mask of the 'enable_dummy_frames' field */
    static const std::uint32_t CONFIG_ENABLE_DUMMY_FRAMES_RESET = 0x0; /* reset value of the 'enable_dummy_frames' field */

    /* Register 'ldpc_fifo_status' */
    static const std::uint32_t LDPC_FIFO_STATUS_OFFSET = 0x00000004; /* address offset of the 'ldpc_fifo_status' register */

    /* Field 'ldpc_fifo_status.ldpc_fifo_entries' */
    static const int LDPC_FIFO_STATUS_LDPC_FIFO_ENTRIES_BIT_OFFSET = 0; /* bit offset of the 'ldpc_fifo_entries' field */
    static const int LDPC_FIFO_STATUS_LDPC_FIFO_ENTRIES_BIT_WIDTH = 14; /* bit width of the 'ldpc_fifo_entries' field */
    static const std::uint32_t LDPC_FIFO_STATUS_LDPC_FIFO_ENTRIES_BIT_MASK = 0x00003FFF; /* bit mask of the 'ldpc_fifo_entries' field */
    static const std::uint32_t LDPC_FIFO_STATUS_LDPC_FIFO_ENTRIES_RESET = 0x0; /* reset value of the 'ldpc_fifo_entries' field */

    /* Field 'ldpc_fifo_status.ldpc_fifo_empty' */
    static const int LDPC_FIFO_STATUS_LDPC_FIFO_EMPTY_BIT_OFFSET = 16; /* bit offset of the 'ldpc_fifo_empty' field */
    static const int LDPC_FIFO_STATUS_LDPC_FIFO_EMPTY_BIT_WIDTH = 1; /* bit width of the 'ldpc_fifo_empty' field */
    static const std::uint32_t LDPC_FIFO_STATUS_LDPC_FIFO_EMPTY_BIT_MASK = 0x00010000; /* bit mask of the 'ldpc_fifo_empty' field */
    static const std::uint32_t LDPC_FIFO_STATUS_LDPC_FIFO_EMPTY_RESET = 0x0; /* reset value of the 'ldpc_fifo_empty' field */

    /* Field 'ldpc_fifo_status.ldpc_fifo_full' */
    static const int LDPC_FIFO_STATUS_LDPC_FIFO_FULL_BIT_OFFSET = 17; /* bit offset of the 'ldpc_fifo_full' field */
    static const int LDPC_FIFO_STATUS_LDPC_FIFO_FULL_BIT_WIDTH = 1; /* bit width of the 'ldpc_fifo_full' field */
    static const std::uint32_t LDPC_FIFO_STATUS_LDPC_FIFO_FULL_BIT_MASK = 0x00020000; /* bit mask of the 'ldpc_fifo_full' field */
    static const std::uint32_t LDPC_FIFO_STATUS_LDPC_FIFO_FULL_RESET = 0x0; /* reset value of the 'ldpc_fifo_full' field */

    /* Register 'frames_in_transit' */
    static const std::uint32_t FRAMES_IN_TRANSIT_OFFSET = 0x00000008; /* address offset of the 'frames_in_transit' register */

    /* Field 'frames_in_transit.value' */
    static const int FRAMES_IN_TRANSIT_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int FRAMES_IN_TRANSIT_VALUE_BIT_WIDTH = 8; /* bit width of the 'value' field */
    static const std::uint32_t FRAMES_IN_TRANSIT_VALUE_BIT_MASK = 0x000000FF; /* bit mask of the 'value' field */
    static const std::uint32_t FRAMES_IN_TRANSIT_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'bit_mapper_ram' */
    static const std::uint32_t BIT_MAPPER_RAM_OFFSET = 0x0000000C; /* address offset of the 'bit_mapper_ram' register */
    static const int BIT_MAPPER_RAM_DEPTH = 240; /* depth of the 'bit_mapper_ram' memory, in elements */

    /* Field 'bit_mapper_ram.data' */
    static const int BIT_MAPPER_RAM_DATA_BIT_OFFSET = 0; /* bit offset of the 'data' field */
    static const int BIT_MAPPER_RAM_DATA_BIT_WIDTH = 32; /* bit width of the 'data' field */
    static const std::uint32_t BIT_MAPPER_RAM_DATA_BIT_MASK = 0xFFFFFFFF; /* bit mask of the 'data' field */
    static const std::uint32_t BIT_MAPPER_RAM_DATA_RESET = 0x0; /* reset value of the 'data' field */

    /* Register 'polyphase_filter_coefficients' */
    static const std::uint32_t POLYPHASE_FILTER_COEFFICIENTS_OFFSET = 0x000003CC; /* address offset of the 'polyphase_filter_coefficients' register */
    static const int POLYPHASE_FILTER_COEFFICIENTS_DEPTH = 512; /* depth of the 'polyphase_filter_coefficients' memory, in elements */

    /* Field 'polyphase_filter_coefficients.value' */
    static const int POLYPHASE_FILTER_COEFFICIENTS_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int POLYPHASE_FILTER_COEFFICIENTS_VALUE_BIT_WIDTH = 32; /* bit width of the 'value' field */
    static const std::uint32_t POLYPHASE_FILTER_COEFFICIENTS_VALUE_BIT_MASK = 0xFFFFFFFF; /* bit mask of the 'value' field */
    static const std::uint32_t POLYPHASE_FILTER_COEFFICIENTS_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_input_width_converter_cfg' */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_OFFSET = 0x00000BCC; /* address offset of the 'axi_debug_input_width_converter_cfg' register */

    /* Field 'axi_debug_input_width_converter_cfg.block_data' */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_BIT_OFFSET = 0; /* bit offset of the 'block_data' field */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_BIT_WIDTH = 1; /* bit width of the 'block_data' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_BIT_MASK = 0x00000001; /* bit mask of the 'block_data' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_RESET = 0x0; /* reset value of the 'block_data' field */

    /* Field 'axi_debug_input_width_converter_cfg.allow_word' */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_BIT_OFFSET = 1; /* bit offset of the 'allow_word' field */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_BIT_WIDTH = 1; /* bit width of the 'allow_word' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_BIT_MASK = 0x00000002; /* bit mask of the 'allow_word' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_RESET = 0x0; /* reset value of the 'allow_word' field */

    /* Field 'axi_debug_input_width_converter_cfg.allow_frame' */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_BIT_OFFSET = 2; /* bit offset of the 'allow_frame' field */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_BIT_WIDTH = 1; /* bit width of the 'allow_frame' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_BIT_MASK = 0x00000004; /* bit mask of the 'allow_frame' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_RESET = 0x0; /* reset value of the 'allow_frame' field */

    /* Field 'axi_debug_input_width_converter_cfg.reset_min_max' */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_RESET_MIN_MAX_BIT_OFFSET = 3; /* bit offset of the 'reset_min_max' field */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_RESET_MIN_MAX_BIT_WIDTH = 1; /* bit width of the 'reset_min_max' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_RESET_MIN_MAX_BIT_MASK = 0x00000008; /* bit mask of the 'reset_min_max' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_RESET_MIN_MAX_RESET = 0x0; /* reset value of the 'reset_min_max' field */

    /* Register 'axi_debug_input_width_converter_frame_count' */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_OFFSET = 0x00000BD0; /* address offset of the 'axi_debug_input_width_converter_frame_count' register */

    /* Field 'axi_debug_input_width_converter_frame_count.value' */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; /* bit width of the 'value' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_BIT_MASK = 0x0000FFFF; /* bit mask of the 'value' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_input_width_converter_last_frame_length' */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_OFFSET = 0x00000BD4; /* address offset of the 'axi_debug_input_width_converter_last_frame_length' register */

    /* Field 'axi_debug_input_width_converter_last_frame_length.value' */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; /* bit width of the 'value' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_BIT_MASK = 0x0000FFFF; /* bit mask of the 'value' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_input_width_converter_min_max_frame_length' */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_OFFSET = 0x00000BD8; /* address offset of the 'axi_debug_input_width_converter_min_max_frame_length' register */

    /* Field 'axi_debug_input_width_converter_min_max_frame_length.min_frame_length' */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; /* bit offset of the 'min_frame_length' field */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; /* bit width of the 'min_frame_length' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_MASK = 0x0000FFFF; /* bit mask of the 'min_frame_length' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 0x0; /* reset value of the 'min_frame_length' field */

    /* Field 'axi_debug_input_width_converter_min_max_frame_length.max_frame_length' */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; /* bit offset of the 'max_frame_length' field */
    static const int AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; /* bit width of the 'max_frame_length' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_MASK = 0xFFFF0000; /* bit mask of the 'max_frame_length' field */
    static const std::uint32_t AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 0x0; /* reset value of the 'max_frame_length' field */

    /* Register 'axi_debug_bb_scrambler_cfg' */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_CFG_OFFSET = 0x00000BDC; /* address offset of the 'axi_debug_bb_scrambler_cfg' register */

    /* Field 'axi_debug_bb_scrambler_cfg.block_data' */
    static const int AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_BIT_OFFSET = 0; /* bit offset of the 'block_data' field */
    static const int AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_BIT_WIDTH = 1; /* bit width of the 'block_data' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_BIT_MASK = 0x00000001; /* bit mask of the 'block_data' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_RESET = 0x0; /* reset value of the 'block_data' field */

    /* Field 'axi_debug_bb_scrambler_cfg.allow_word' */
    static const int AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_BIT_OFFSET = 1; /* bit offset of the 'allow_word' field */
    static const int AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_BIT_WIDTH = 1; /* bit width of the 'allow_word' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_BIT_MASK = 0x00000002; /* bit mask of the 'allow_word' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_RESET = 0x0; /* reset value of the 'allow_word' field */

    /* Field 'axi_debug_bb_scrambler_cfg.allow_frame' */
    static const int AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_BIT_OFFSET = 2; /* bit offset of the 'allow_frame' field */
    static const int AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_BIT_WIDTH = 1; /* bit width of the 'allow_frame' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_BIT_MASK = 0x00000004; /* bit mask of the 'allow_frame' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_RESET = 0x0; /* reset value of the 'allow_frame' field */

    /* Field 'axi_debug_bb_scrambler_cfg.reset_min_max' */
    static const int AXI_DEBUG_BB_SCRAMBLER_CFG_RESET_MIN_MAX_BIT_OFFSET = 3; /* bit offset of the 'reset_min_max' field */
    static const int AXI_DEBUG_BB_SCRAMBLER_CFG_RESET_MIN_MAX_BIT_WIDTH = 1; /* bit width of the 'reset_min_max' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_CFG_RESET_MIN_MAX_BIT_MASK = 0x00000008; /* bit mask of the 'reset_min_max' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_CFG_RESET_MIN_MAX_RESET = 0x0; /* reset value of the 'reset_min_max' field */

    /* Register 'axi_debug_bb_scrambler_frame_count' */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_OFFSET = 0x00000BE0; /* address offset of the 'axi_debug_bb_scrambler_frame_count' register */

    /* Field 'axi_debug_bb_scrambler_frame_count.value' */
    static const int AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; /* bit width of the 'value' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_BIT_MASK = 0x0000FFFF; /* bit mask of the 'value' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_bb_scrambler_last_frame_length' */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_OFFSET = 0x00000BE4; /* address offset of the 'axi_debug_bb_scrambler_last_frame_length' register */

    /* Field 'axi_debug_bb_scrambler_last_frame_length.value' */
    static const int AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; /* bit width of the 'value' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_BIT_MASK = 0x0000FFFF; /* bit mask of the 'value' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_bb_scrambler_min_max_frame_length' */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_OFFSET = 0x00000BE8; /* address offset of the 'axi_debug_bb_scrambler_min_max_frame_length' register */

    /* Field 'axi_debug_bb_scrambler_min_max_frame_length.min_frame_length' */
    static const int AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; /* bit offset of the 'min_frame_length' field */
    static const int AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; /* bit width of the 'min_frame_length' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_MASK = 0x0000FFFF; /* bit mask of the 'min_frame_length' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 0x0; /* reset value of the 'min_frame_length' field */

    /* Field 'axi_debug_bb_scrambler_min_max_frame_length.max_frame_length' */
    static const int AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; /* bit offset of the 'max_frame_length' field */
    static const int AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; /* bit width of the 'max_frame_length' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_MASK = 0xFFFF0000; /* bit mask of the 'max_frame_length' field */
    static const std::uint32_t AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 0x0; /* reset value of the 'max_frame_length' field */

    /* Register 'axi_debug_bch_encoder_cfg' */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_CFG_OFFSET = 0x00000BEC; /* address offset of the 'axi_debug_bch_encoder_cfg' register */

    /* Field 'axi_debug_bch_encoder_cfg.block_data' */
    static const int AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_BIT_OFFSET = 0; /* bit offset of the 'block_data' field */
    static const int AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_BIT_WIDTH = 1; /* bit width of the 'block_data' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_BIT_MASK = 0x00000001; /* bit mask of the 'block_data' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_RESET = 0x0; /* reset value of the 'block_data' field */

    /* Field 'axi_debug_bch_encoder_cfg.allow_word' */
    static const int AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_BIT_OFFSET = 1; /* bit offset of the 'allow_word' field */
    static const int AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_BIT_WIDTH = 1; /* bit width of the 'allow_word' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_BIT_MASK = 0x00000002; /* bit mask of the 'allow_word' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_RESET = 0x0; /* reset value of the 'allow_word' field */

    /* Field 'axi_debug_bch_encoder_cfg.allow_frame' */
    static const int AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_BIT_OFFSET = 2; /* bit offset of the 'allow_frame' field */
    static const int AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_BIT_WIDTH = 1; /* bit width of the 'allow_frame' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_BIT_MASK = 0x00000004; /* bit mask of the 'allow_frame' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_RESET = 0x0; /* reset value of the 'allow_frame' field */

    /* Field 'axi_debug_bch_encoder_cfg.reset_min_max' */
    static const int AXI_DEBUG_BCH_ENCODER_CFG_RESET_MIN_MAX_BIT_OFFSET = 3; /* bit offset of the 'reset_min_max' field */
    static const int AXI_DEBUG_BCH_ENCODER_CFG_RESET_MIN_MAX_BIT_WIDTH = 1; /* bit width of the 'reset_min_max' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_CFG_RESET_MIN_MAX_BIT_MASK = 0x00000008; /* bit mask of the 'reset_min_max' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_CFG_RESET_MIN_MAX_RESET = 0x0; /* reset value of the 'reset_min_max' field */

    /* Register 'axi_debug_bch_encoder_frame_count' */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_OFFSET = 0x00000BF0; /* address offset of the 'axi_debug_bch_encoder_frame_count' register */

    /* Field 'axi_debug_bch_encoder_frame_count.value' */
    static const int AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; /* bit width of the 'value' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_BIT_MASK = 0x0000FFFF; /* bit mask of the 'value' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_bch_encoder_last_frame_length' */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_OFFSET = 0x00000BF4; /* address offset of the 'axi_debug_bch_encoder_last_frame_length' register */

    /* Field 'axi_debug_bch_encoder_last_frame_length.value' */
    static const int AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; /* bit width of the 'value' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_MASK = 0x0000FFFF; /* bit mask of the 'value' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_bch_encoder_min_max_frame_length' */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET = 0x00000BF8; /* address offset of the 'axi_debug_bch_encoder_min_max_frame_length' register */

    /* Field 'axi_debug_bch_encoder_min_max_frame_length.min_frame_length' */
    static const int AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; /* bit offset of the 'min_frame_length' field */
    static const int AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; /* bit width of the 'min_frame_length' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_MASK = 0x0000FFFF; /* bit mask of the 'min_frame_length' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 0x0; /* reset value of the 'min_frame_length' field */

    /* Field 'axi_debug_bch_encoder_min_max_frame_length.max_frame_length' */
    static const int AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; /* bit offset of the 'max_frame_length' field */
    static const int AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; /* bit width of the 'max_frame_length' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_MASK = 0xFFFF0000; /* bit mask of the 'max_frame_length' field */
    static const std::uint32_t AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 0x0; /* reset value of the 'max_frame_length' field */

    /* Register 'axi_debug_ldpc_encoder_cfg' */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_CFG_OFFSET = 0x00000BFC; /* address offset of the 'axi_debug_ldpc_encoder_cfg' register */

    /* Field 'axi_debug_ldpc_encoder_cfg.block_data' */
    static const int AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_BIT_OFFSET = 0; /* bit offset of the 'block_data' field */
    static const int AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_BIT_WIDTH = 1; /* bit width of the 'block_data' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_BIT_MASK = 0x00000001; /* bit mask of the 'block_data' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_RESET = 0x0; /* reset value of the 'block_data' field */

    /* Field 'axi_debug_ldpc_encoder_cfg.allow_word' */
    static const int AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_BIT_OFFSET = 1; /* bit offset of the 'allow_word' field */
    static const int AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_BIT_WIDTH = 1; /* bit width of the 'allow_word' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_BIT_MASK = 0x00000002; /* bit mask of the 'allow_word' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_RESET = 0x0; /* reset value of the 'allow_word' field */

    /* Field 'axi_debug_ldpc_encoder_cfg.allow_frame' */
    static const int AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_BIT_OFFSET = 2; /* bit offset of the 'allow_frame' field */
    static const int AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_BIT_WIDTH = 1; /* bit width of the 'allow_frame' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_BIT_MASK = 0x00000004; /* bit mask of the 'allow_frame' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_RESET = 0x0; /* reset value of the 'allow_frame' field */

    /* Field 'axi_debug_ldpc_encoder_cfg.reset_min_max' */
    static const int AXI_DEBUG_LDPC_ENCODER_CFG_RESET_MIN_MAX_BIT_OFFSET = 3; /* bit offset of the 'reset_min_max' field */
    static const int AXI_DEBUG_LDPC_ENCODER_CFG_RESET_MIN_MAX_BIT_WIDTH = 1; /* bit width of the 'reset_min_max' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_CFG_RESET_MIN_MAX_BIT_MASK = 0x00000008; /* bit mask of the 'reset_min_max' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_CFG_RESET_MIN_MAX_RESET = 0x0; /* reset value of the 'reset_min_max' field */

    /* Register 'axi_debug_ldpc_encoder_frame_count' */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_OFFSET = 0x00000C00; /* address offset of the 'axi_debug_ldpc_encoder_frame_count' register */

    /* Field 'axi_debug_ldpc_encoder_frame_count.value' */
    static const int AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; /* bit width of the 'value' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_BIT_MASK = 0x0000FFFF; /* bit mask of the 'value' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_ldpc_encoder_last_frame_length' */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_OFFSET = 0x00000C04; /* address offset of the 'axi_debug_ldpc_encoder_last_frame_length' register */

    /* Field 'axi_debug_ldpc_encoder_last_frame_length.value' */
    static const int AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; /* bit width of the 'value' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_MASK = 0x0000FFFF; /* bit mask of the 'value' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_ldpc_encoder_min_max_frame_length' */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET = 0x00000C08; /* address offset of the 'axi_debug_ldpc_encoder_min_max_frame_length' register */

    /* Field 'axi_debug_ldpc_encoder_min_max_frame_length.min_frame_length' */
    static const int AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; /* bit offset of the 'min_frame_length' field */
    static const int AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; /* bit width of the 'min_frame_length' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_MASK = 0x0000FFFF; /* bit mask of the 'min_frame_length' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 0x0; /* reset value of the 'min_frame_length' field */

    /* Field 'axi_debug_ldpc_encoder_min_max_frame_length.max_frame_length' */
    static const int AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; /* bit offset of the 'max_frame_length' field */
    static const int AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; /* bit width of the 'max_frame_length' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_MASK = 0xFFFF0000; /* bit mask of the 'max_frame_length' field */
    static const std::uint32_t AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 0x0; /* reset value of the 'max_frame_length' field */

    /* Register 'axi_debug_bit_interleaver_cfg' */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_CFG_OFFSET = 0x00000C0C; /* address offset of the 'axi_debug_bit_interleaver_cfg' register */

    /* Field 'axi_debug_bit_interleaver_cfg.block_data' */
    static const int AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_BIT_OFFSET = 0; /* bit offset of the 'block_data' field */
    static const int AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_BIT_WIDTH = 1; /* bit width of the 'block_data' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_BIT_MASK = 0x00000001; /* bit mask of the 'block_data' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_RESET = 0x0; /* reset value of the 'block_data' field */

    /* Field 'axi_debug_bit_interleaver_cfg.allow_word' */
    static const int AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_BIT_OFFSET = 1; /* bit offset of the 'allow_word' field */
    static const int AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_BIT_WIDTH = 1; /* bit width of the 'allow_word' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_BIT_MASK = 0x00000002; /* bit mask of the 'allow_word' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_RESET = 0x0; /* reset value of the 'allow_word' field */

    /* Field 'axi_debug_bit_interleaver_cfg.allow_frame' */
    static const int AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_BIT_OFFSET = 2; /* bit offset of the 'allow_frame' field */
    static const int AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_BIT_WIDTH = 1; /* bit width of the 'allow_frame' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_BIT_MASK = 0x00000004; /* bit mask of the 'allow_frame' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_RESET = 0x0; /* reset value of the 'allow_frame' field */

    /* Field 'axi_debug_bit_interleaver_cfg.reset_min_max' */
    static const int AXI_DEBUG_BIT_INTERLEAVER_CFG_RESET_MIN_MAX_BIT_OFFSET = 3; /* bit offset of the 'reset_min_max' field */
    static const int AXI_DEBUG_BIT_INTERLEAVER_CFG_RESET_MIN_MAX_BIT_WIDTH = 1; /* bit width of the 'reset_min_max' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_CFG_RESET_MIN_MAX_BIT_MASK = 0x00000008; /* bit mask of the 'reset_min_max' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_CFG_RESET_MIN_MAX_RESET = 0x0; /* reset value of the 'reset_min_max' field */

    /* Register 'axi_debug_bit_interleaver_frame_count' */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_OFFSET = 0x00000C10; /* address offset of the 'axi_debug_bit_interleaver_frame_count' register */

    /* Field 'axi_debug_bit_interleaver_frame_count.value' */
    static const int AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_BIT_WIDTH = 16; /* bit width of the 'value' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_BIT_MASK = 0x0000FFFF; /* bit mask of the 'value' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_bit_interleaver_last_frame_length' */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_OFFSET = 0x00000C14; /* address offset of the 'axi_debug_bit_interleaver_last_frame_length' register */

    /* Field 'axi_debug_bit_interleaver_last_frame_length.value' */
    static const int AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; /* bit width of the 'value' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_BIT_MASK = 0x0000FFFF; /* bit mask of the 'value' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_bit_interleaver_min_max_frame_length' */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_OFFSET = 0x00000C18; /* address offset of the 'axi_debug_bit_interleaver_min_max_frame_length' register */

    /* Field 'axi_debug_bit_interleaver_min_max_frame_length.min_frame_length' */
    static const int AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; /* bit offset of the 'min_frame_length' field */
    static const int AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; /* bit width of the 'min_frame_length' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_MASK = 0x0000FFFF; /* bit mask of the 'min_frame_length' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 0x0; /* reset value of the 'min_frame_length' field */

    /* Field 'axi_debug_bit_interleaver_min_max_frame_length.max_frame_length' */
    static const int AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; /* bit offset of the 'max_frame_length' field */
    static const int AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; /* bit width of the 'max_frame_length' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_MASK = 0xFFFF0000; /* bit mask of the 'max_frame_length' field */
    static const std::uint32_t AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 0x0; /* reset value of the 'max_frame_length' field */

    /* Register 'axi_debug_plframe_cfg' */
    static const std::uint32_t AXI_DEBUG_PLFRAME_CFG_OFFSET = 0x00000C1C; /* address offset of the 'axi_debug_plframe_cfg' register */

    /* Field 'axi_debug_plframe_cfg.block_data' */
    static const int AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_BIT_OFFSET = 0; /* bit offset of the 'block_data' field */
    static const int AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_BIT_WIDTH = 1; /* bit width of the 'block_data' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_BIT_MASK = 0x00000001; /* bit mask of the 'block_data' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_RESET = 0x0; /* reset value of the 'block_data' field */

    /* Field 'axi_debug_plframe_cfg.allow_word' */
    static const int AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_BIT_OFFSET = 1; /* bit offset of the 'allow_word' field */
    static const int AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_BIT_WIDTH = 1; /* bit width of the 'allow_word' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_BIT_MASK = 0x00000002; /* bit mask of the 'allow_word' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_RESET = 0x0; /* reset value of the 'allow_word' field */

    /* Field 'axi_debug_plframe_cfg.allow_frame' */
    static const int AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_BIT_OFFSET = 2; /* bit offset of the 'allow_frame' field */
    static const int AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_BIT_WIDTH = 1; /* bit width of the 'allow_frame' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_BIT_MASK = 0x00000004; /* bit mask of the 'allow_frame' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_RESET = 0x0; /* reset value of the 'allow_frame' field */

    /* Field 'axi_debug_plframe_cfg.reset_min_max' */
    static const int AXI_DEBUG_PLFRAME_CFG_RESET_MIN_MAX_BIT_OFFSET = 3; /* bit offset of the 'reset_min_max' field */
    static const int AXI_DEBUG_PLFRAME_CFG_RESET_MIN_MAX_BIT_WIDTH = 1; /* bit width of the 'reset_min_max' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_CFG_RESET_MIN_MAX_BIT_MASK = 0x00000008; /* bit mask of the 'reset_min_max' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_CFG_RESET_MIN_MAX_RESET = 0x0; /* reset value of the 'reset_min_max' field */

    /* Register 'axi_debug_plframe_frame_count' */
    static const std::uint32_t AXI_DEBUG_PLFRAME_FRAME_COUNT_OFFSET = 0x00000C20; /* address offset of the 'axi_debug_plframe_frame_count' register */

    /* Field 'axi_debug_plframe_frame_count.value' */
    static const int AXI_DEBUG_PLFRAME_FRAME_COUNT_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int AXI_DEBUG_PLFRAME_FRAME_COUNT_VALUE_BIT_WIDTH = 16; /* bit width of the 'value' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_FRAME_COUNT_VALUE_BIT_MASK = 0x0000FFFF; /* bit mask of the 'value' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_FRAME_COUNT_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_plframe_last_frame_length' */
    static const std::uint32_t AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_OFFSET = 0x00000C24; /* address offset of the 'axi_debug_plframe_last_frame_length' register */

    /* Field 'axi_debug_plframe_last_frame_length.value' */
    static const int AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; /* bit width of the 'value' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_VALUE_BIT_MASK = 0x0000FFFF; /* bit mask of the 'value' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_plframe_min_max_frame_length' */
    static const std::uint32_t AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_OFFSET = 0x00000C28; /* address offset of the 'axi_debug_plframe_min_max_frame_length' register */

    /* Field 'axi_debug_plframe_min_max_frame_length.min_frame_length' */
    static const int AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; /* bit offset of the 'min_frame_length' field */
    static const int AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; /* bit width of the 'min_frame_length' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_MASK = 0x0000FFFF; /* bit mask of the 'min_frame_length' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 0x0; /* reset value of the 'min_frame_length' field */

    /* Field 'axi_debug_plframe_min_max_frame_length.max_frame_length' */
    static const int AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; /* bit offset of the 'max_frame_length' field */
    static const int AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; /* bit width of the 'max_frame_length' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_MASK = 0xFFFF0000; /* bit mask of the 'max_frame_length' field */
    static const std::uint32_t AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 0x0; /* reset value of the 'max_frame_length' field */

    /* Register 'axi_debug_output_cfg' */
    static const std::uint32_t AXI_DEBUG_OUTPUT_CFG_OFFSET = 0x00000C2C; /* address offset of the 'axi_debug_output_cfg' register */

    /* Field 'axi_debug_output_cfg.block_data' */
    static const int AXI_DEBUG_OUTPUT_CFG_BLOCK_DATA_BIT_OFFSET = 0; /* bit offset of the 'block_data' field */
    static const int AXI_DEBUG_OUTPUT_CFG_BLOCK_DATA_BIT_WIDTH = 1; /* bit width of the 'block_data' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_CFG_BLOCK_DATA_BIT_MASK = 0x00000001; /* bit mask of the 'block_data' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_CFG_BLOCK_DATA_RESET = 0x0; /* reset value of the 'block_data' field */

    /* Field 'axi_debug_output_cfg.allow_word' */
    static const int AXI_DEBUG_OUTPUT_CFG_ALLOW_WORD_BIT_OFFSET = 1; /* bit offset of the 'allow_word' field */
    static const int AXI_DEBUG_OUTPUT_CFG_ALLOW_WORD_BIT_WIDTH = 1; /* bit width of the 'allow_word' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_CFG_ALLOW_WORD_BIT_MASK = 0x00000002; /* bit mask of the 'allow_word' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_CFG_ALLOW_WORD_RESET = 0x0; /* reset value of the 'allow_word' field */

    /* Field 'axi_debug_output_cfg.allow_frame' */
    static const int AXI_DEBUG_OUTPUT_CFG_ALLOW_FRAME_BIT_OFFSET = 2; /* bit offset of the 'allow_frame' field */
    static const int AXI_DEBUG_OUTPUT_CFG_ALLOW_FRAME_BIT_WIDTH = 1; /* bit width of the 'allow_frame' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_CFG_ALLOW_FRAME_BIT_MASK = 0x00000004; /* bit mask of the 'allow_frame' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_CFG_ALLOW_FRAME_RESET = 0x0; /* reset value of the 'allow_frame' field */

    /* Field 'axi_debug_output_cfg.reset_min_max' */
    static const int AXI_DEBUG_OUTPUT_CFG_RESET_MIN_MAX_BIT_OFFSET = 3; /* bit offset of the 'reset_min_max' field */
    static const int AXI_DEBUG_OUTPUT_CFG_RESET_MIN_MAX_BIT_WIDTH = 1; /* bit width of the 'reset_min_max' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_CFG_RESET_MIN_MAX_BIT_MASK = 0x00000008; /* bit mask of the 'reset_min_max' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_CFG_RESET_MIN_MAX_RESET = 0x0; /* reset value of the 'reset_min_max' field */

    /* Register 'axi_debug_output_frame_count' */
    static const std::uint32_t AXI_DEBUG_OUTPUT_FRAME_COUNT_OFFSET = 0x00000C30; /* address offset of the 'axi_debug_output_frame_count' register */

    /* Field 'axi_debug_output_frame_count.value' */
    static const int AXI_DEBUG_OUTPUT_FRAME_COUNT_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int AXI_DEBUG_OUTPUT_FRAME_COUNT_VALUE_BIT_WIDTH = 16; /* bit width of the 'value' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_FRAME_COUNT_VALUE_BIT_MASK = 0x0000FFFF; /* bit mask of the 'value' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_FRAME_COUNT_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_output_last_frame_length' */
    static const std::uint32_t AXI_DEBUG_OUTPUT_LAST_FRAME_LENGTH_OFFSET = 0x00000C34; /* address offset of the 'axi_debug_output_last_frame_length' register */

    /* Field 'axi_debug_output_last_frame_length.value' */
    static const int AXI_DEBUG_OUTPUT_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET = 0; /* bit offset of the 'value' field */
    static const int AXI_DEBUG_OUTPUT_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH = 16; /* bit width of the 'value' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_LAST_FRAME_LENGTH_VALUE_BIT_MASK = 0x0000FFFF; /* bit mask of the 'value' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_LAST_FRAME_LENGTH_VALUE_RESET = 0x0; /* reset value of the 'value' field */

    /* Register 'axi_debug_output_min_max_frame_length' */
    static const std::uint32_t AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_OFFSET = 0x00000C38; /* address offset of the 'axi_debug_output_min_max_frame_length' register */

    /* Field 'axi_debug_output_min_max_frame_length.min_frame_length' */
    static const int AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET = 0; /* bit offset of the 'min_frame_length' field */
    static const int AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH = 16; /* bit width of the 'min_frame_length' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_MASK = 0x0000FFFF; /* bit mask of the 'min_frame_length' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET = 0x0; /* reset value of the 'min_frame_length' field */

    /* Field 'axi_debug_output_min_max_frame_length.max_frame_length' */
    static const int AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET = 16; /* bit offset of the 'max_frame_length' field */
    static const int AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH = 16; /* bit width of the 'max_frame_length' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_MASK = 0xFFFF0000; /* bit mask of the 'max_frame_length' field */
    static const std::uint32_t AXI_DEBUG_OUTPUT_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET = 0x0; /* reset value of the 'max_frame_length' field */

}

#endif  /* DVBS2_ENCODER_REGS_H */
