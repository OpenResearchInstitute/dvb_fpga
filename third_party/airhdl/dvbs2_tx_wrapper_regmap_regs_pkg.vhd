-- -----------------------------------------------------------------------------
-- 'dvbs2_tx_wrapper_regmap' Register Definitions
-- Revision: 123
-- -----------------------------------------------------------------------------
-- Generated on 2021-03-21 at 15:18 (UTC) by airhdl version 2021.03.1
-- -----------------------------------------------------------------------------
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
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package dvbs2_tx_wrapper_regmap_regs_pkg is

    -- Type definitions
    type slv1_array_t is array(natural range <>) of std_logic_vector(0 downto 0);
    type slv2_array_t is array(natural range <>) of std_logic_vector(1 downto 0);
    type slv3_array_t is array(natural range <>) of std_logic_vector(2 downto 0);
    type slv4_array_t is array(natural range <>) of std_logic_vector(3 downto 0);
    type slv5_array_t is array(natural range <>) of std_logic_vector(4 downto 0);
    type slv6_array_t is array(natural range <>) of std_logic_vector(5 downto 0);
    type slv7_array_t is array(natural range <>) of std_logic_vector(6 downto 0);
    type slv8_array_t is array(natural range <>) of std_logic_vector(7 downto 0);
    type slv9_array_t is array(natural range <>) of std_logic_vector(8 downto 0);
    type slv10_array_t is array(natural range <>) of std_logic_vector(9 downto 0);
    type slv11_array_t is array(natural range <>) of std_logic_vector(10 downto 0);
    type slv12_array_t is array(natural range <>) of std_logic_vector(11 downto 0);
    type slv13_array_t is array(natural range <>) of std_logic_vector(12 downto 0);
    type slv14_array_t is array(natural range <>) of std_logic_vector(13 downto 0);
    type slv15_array_t is array(natural range <>) of std_logic_vector(14 downto 0);
    type slv16_array_t is array(natural range <>) of std_logic_vector(15 downto 0);
    type slv17_array_t is array(natural range <>) of std_logic_vector(16 downto 0);
    type slv18_array_t is array(natural range <>) of std_logic_vector(17 downto 0);
    type slv19_array_t is array(natural range <>) of std_logic_vector(18 downto 0);
    type slv20_array_t is array(natural range <>) of std_logic_vector(19 downto 0);
    type slv21_array_t is array(natural range <>) of std_logic_vector(20 downto 0);
    type slv22_array_t is array(natural range <>) of std_logic_vector(21 downto 0);
    type slv23_array_t is array(natural range <>) of std_logic_vector(22 downto 0);
    type slv24_array_t is array(natural range <>) of std_logic_vector(23 downto 0);
    type slv25_array_t is array(natural range <>) of std_logic_vector(24 downto 0);
    type slv26_array_t is array(natural range <>) of std_logic_vector(25 downto 0);
    type slv27_array_t is array(natural range <>) of std_logic_vector(26 downto 0);
    type slv28_array_t is array(natural range <>) of std_logic_vector(27 downto 0);
    type slv29_array_t is array(natural range <>) of std_logic_vector(28 downto 0);
    type slv30_array_t is array(natural range <>) of std_logic_vector(29 downto 0);
    type slv31_array_t is array(natural range <>) of std_logic_vector(30 downto 0);
    type slv32_array_t is array(natural range <>) of std_logic_vector(31 downto 0);

    -- User-logic ports (from user-logic to register file)
    type user2regs_t is record
        ldpc_fifo_status_ldpc_fifo_entries : std_logic_vector(13 downto 0); -- value of register 'ldpc_fifo_status', field 'ldpc_fifo_entries'
        ldpc_fifo_status_ldpc_fifo_empty : std_logic_vector(0 downto 0); -- value of register 'ldpc_fifo_status', field 'ldpc_fifo_empty'
        ldpc_fifo_status_ldpc_fifo_full : std_logic_vector(0 downto 0); -- value of register 'ldpc_fifo_status', field 'ldpc_fifo_full'
        frames_in_transit_value : std_logic_vector(7 downto 0); -- value of register 'frames_in_transit', field 'value'
        bit_mapper_ram_rdata : std_logic_vector(31 downto 0); -- read data for memory 'bit_mapper_ram'
        axi_debug_input_width_converter_frame_count_value : std_logic_vector(15 downto 0); -- value of register 'axi_debug_input_width_converter_frame_count', field 'value'
        axi_debug_input_width_converter_last_frame_length_value : std_logic_vector(15 downto 0); -- value of register 'axi_debug_input_width_converter_last_frame_length', field 'value'
        axi_debug_input_width_converter_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0); -- value of register 'axi_debug_input_width_converter_min_max_frame_length', field 'min_frame_length'
        axi_debug_input_width_converter_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0); -- value of register 'axi_debug_input_width_converter_min_max_frame_length', field 'max_frame_length'
        axi_debug_bb_scrambler_frame_count_value : std_logic_vector(15 downto 0); -- value of register 'axi_debug_bb_scrambler_frame_count', field 'value'
        axi_debug_bb_scrambler_last_frame_length_value : std_logic_vector(15 downto 0); -- value of register 'axi_debug_bb_scrambler_last_frame_length', field 'value'
        axi_debug_bb_scrambler_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0); -- value of register 'axi_debug_bb_scrambler_min_max_frame_length', field 'min_frame_length'
        axi_debug_bb_scrambler_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0); -- value of register 'axi_debug_bb_scrambler_min_max_frame_length', field 'max_frame_length'
        axi_debug_bch_encoder_frame_count_value : std_logic_vector(15 downto 0); -- value of register 'axi_debug_bch_encoder_frame_count', field 'value'
        axi_debug_bch_encoder_last_frame_length_value : std_logic_vector(15 downto 0); -- value of register 'axi_debug_bch_encoder_last_frame_length', field 'value'
        axi_debug_bch_encoder_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0); -- value of register 'axi_debug_bch_encoder_min_max_frame_length', field 'min_frame_length'
        axi_debug_bch_encoder_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0); -- value of register 'axi_debug_bch_encoder_min_max_frame_length', field 'max_frame_length'
        axi_debug_ldpc_encoder_frame_count_value : std_logic_vector(15 downto 0); -- value of register 'axi_debug_ldpc_encoder_frame_count', field 'value'
        axi_debug_ldpc_encoder_last_frame_length_value : std_logic_vector(15 downto 0); -- value of register 'axi_debug_ldpc_encoder_last_frame_length', field 'value'
        axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0); -- value of register 'axi_debug_ldpc_encoder_min_max_frame_length', field 'min_frame_length'
        axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0); -- value of register 'axi_debug_ldpc_encoder_min_max_frame_length', field 'max_frame_length'
        axi_debug_bit_interleaver_frame_count_value : std_logic_vector(15 downto 0); -- value of register 'axi_debug_bit_interleaver_frame_count', field 'value'
        axi_debug_bit_interleaver_last_frame_length_value : std_logic_vector(15 downto 0); -- value of register 'axi_debug_bit_interleaver_last_frame_length', field 'value'
        axi_debug_bit_interleaver_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0); -- value of register 'axi_debug_bit_interleaver_min_max_frame_length', field 'min_frame_length'
        axi_debug_bit_interleaver_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0); -- value of register 'axi_debug_bit_interleaver_min_max_frame_length', field 'max_frame_length'
    end record;
    
    -- User-logic ports (from register file to user-logic)
    type regs2user_t is record
        config_strobe : std_logic; -- Strobe signal for register 'config' (pulsed when the register is written from the bus}
        config_physical_layer_scrambler_shift_reg_init : std_logic_vector(17 downto 0); -- Value of register 'config', field 'physical_layer_scrambler_shift_reg_init'
        config_enable_dummy_frames : std_logic_vector(0 downto 0); -- Value of register 'config', field 'enable_dummy_frames'
        ldpc_fifo_status_strobe : std_logic; -- Strobe signal for register 'ldpc_fifo_status' (pulsed when the register is read from the bus}
        frames_in_transit_strobe : std_logic; -- Strobe signal for register 'frames_in_transit' (pulsed when the register is read from the bus}
        bit_mapper_ram_addr : std_logic_vector(7 downto 0); -- read/write address for memory 'bit_mapper_ram'
        bit_mapper_ram_wdata : std_logic_vector(31 downto 0); -- write data for memory 'bit_mapper_ram'         
        bit_mapper_ram_wen : std_logic_vector(3 downto 0); -- byte-wide write-enable for memory 'bit_mapper_ram'
        polyphase_filter_coefficients_addr : std_logic_vector(8 downto 0); -- read/write address for memory 'polyphase_filter_coefficients'
        polyphase_filter_coefficients_wdata : std_logic_vector(31 downto 0); -- write data for memory 'polyphase_filter_coefficients'         
        polyphase_filter_coefficients_wen : std_logic_vector(3 downto 0); -- byte-wide write-enable for memory 'polyphase_filter_coefficients'
        axi_debug_input_width_converter_cfg_strobe : std_logic; -- Strobe signal for register 'axi_debug_input_width_converter_cfg' (pulsed when the register is written from the bus}
        axi_debug_input_width_converter_cfg_block_data : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_input_width_converter_cfg', field 'block_data'
        axi_debug_input_width_converter_cfg_allow_word : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_input_width_converter_cfg', field 'allow_word'
        axi_debug_input_width_converter_cfg_allow_frame : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_input_width_converter_cfg', field 'allow_frame'
        axi_debug_input_width_converter_cfg_reset_min_max : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_input_width_converter_cfg', field 'reset_min_max'
        axi_debug_input_width_converter_frame_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_input_width_converter_frame_count' (pulsed when the register is read from the bus}
        axi_debug_input_width_converter_last_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_input_width_converter_last_frame_length' (pulsed when the register is read from the bus}
        axi_debug_input_width_converter_min_max_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_input_width_converter_min_max_frame_length' (pulsed when the register is read from the bus}
        axi_debug_bb_scrambler_cfg_strobe : std_logic; -- Strobe signal for register 'axi_debug_bb_scrambler_cfg' (pulsed when the register is written from the bus}
        axi_debug_bb_scrambler_cfg_block_data : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bb_scrambler_cfg', field 'block_data'
        axi_debug_bb_scrambler_cfg_allow_word : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bb_scrambler_cfg', field 'allow_word'
        axi_debug_bb_scrambler_cfg_allow_frame : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bb_scrambler_cfg', field 'allow_frame'
        axi_debug_bb_scrambler_cfg_reset_min_max : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bb_scrambler_cfg', field 'reset_min_max'
        axi_debug_bb_scrambler_frame_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_bb_scrambler_frame_count' (pulsed when the register is read from the bus}
        axi_debug_bb_scrambler_last_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_bb_scrambler_last_frame_length' (pulsed when the register is read from the bus}
        axi_debug_bb_scrambler_min_max_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_bb_scrambler_min_max_frame_length' (pulsed when the register is read from the bus}
        axi_debug_bch_encoder_cfg_strobe : std_logic; -- Strobe signal for register 'axi_debug_bch_encoder_cfg' (pulsed when the register is written from the bus}
        axi_debug_bch_encoder_cfg_block_data : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bch_encoder_cfg', field 'block_data'
        axi_debug_bch_encoder_cfg_allow_word : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bch_encoder_cfg', field 'allow_word'
        axi_debug_bch_encoder_cfg_allow_frame : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bch_encoder_cfg', field 'allow_frame'
        axi_debug_bch_encoder_cfg_reset_min_max : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bch_encoder_cfg', field 'reset_min_max'
        axi_debug_bch_encoder_frame_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_bch_encoder_frame_count' (pulsed when the register is read from the bus}
        axi_debug_bch_encoder_last_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_bch_encoder_last_frame_length' (pulsed when the register is read from the bus}
        axi_debug_bch_encoder_min_max_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_bch_encoder_min_max_frame_length' (pulsed when the register is read from the bus}
        axi_debug_ldpc_encoder_cfg_strobe : std_logic; -- Strobe signal for register 'axi_debug_ldpc_encoder_cfg' (pulsed when the register is written from the bus}
        axi_debug_ldpc_encoder_cfg_block_data : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_ldpc_encoder_cfg', field 'block_data'
        axi_debug_ldpc_encoder_cfg_allow_word : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_ldpc_encoder_cfg', field 'allow_word'
        axi_debug_ldpc_encoder_cfg_allow_frame : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_ldpc_encoder_cfg', field 'allow_frame'
        axi_debug_ldpc_encoder_cfg_reset_min_max : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_ldpc_encoder_cfg', field 'reset_min_max'
        axi_debug_ldpc_encoder_frame_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_ldpc_encoder_frame_count' (pulsed when the register is read from the bus}
        axi_debug_ldpc_encoder_last_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_ldpc_encoder_last_frame_length' (pulsed when the register is read from the bus}
        axi_debug_ldpc_encoder_min_max_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_ldpc_encoder_min_max_frame_length' (pulsed when the register is read from the bus}
        axi_debug_bit_interleaver_cfg_strobe : std_logic; -- Strobe signal for register 'axi_debug_bit_interleaver_cfg' (pulsed when the register is written from the bus}
        axi_debug_bit_interleaver_cfg_block_data : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bit_interleaver_cfg', field 'block_data'
        axi_debug_bit_interleaver_cfg_allow_word : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bit_interleaver_cfg', field 'allow_word'
        axi_debug_bit_interleaver_cfg_allow_frame : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bit_interleaver_cfg', field 'allow_frame'
        axi_debug_bit_interleaver_cfg_reset_min_max : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bit_interleaver_cfg', field 'reset_min_max'
        axi_debug_bit_interleaver_frame_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_bit_interleaver_frame_count' (pulsed when the register is read from the bus}
        axi_debug_bit_interleaver_last_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_bit_interleaver_last_frame_length' (pulsed when the register is read from the bus}
        axi_debug_bit_interleaver_min_max_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_bit_interleaver_min_max_frame_length' (pulsed when the register is read from the bus}
    end record;

    -- Revision number of the 'dvbs2_tx_wrapper_regmap' register map
    constant DVBS2_TX_WRAPPER_REGMAP_REVISION : natural := 123;

    -- Default base address of the 'dvbs2_tx_wrapper_regmap' register map 
    constant DVBS2_TX_WRAPPER_REGMAP_DEFAULT_BASEADDR : unsigned(31 downto 0) := unsigned'(x"00000000");
    
    -- Register 'config'
    constant CONFIG_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000000"); -- address offset of the 'config' register
    -- Field 'config.physical_layer_scrambler_shift_reg_init'
    constant CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_BIT_OFFSET : natural := 0; -- bit offset of the 'physical_layer_scrambler_shift_reg_init' field
    constant CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_BIT_WIDTH : natural := 18; -- bit width of the 'physical_layer_scrambler_shift_reg_init' field
    constant CONFIG_PHYSICAL_LAYER_SCRAMBLER_SHIFT_REG_INIT_RESET : std_logic_vector(17 downto 0) := std_logic_vector'("000000000000000001"); -- reset value of the 'physical_layer_scrambler_shift_reg_init' field
    -- Field 'config.enable_dummy_frames'
    constant CONFIG_ENABLE_DUMMY_FRAMES_BIT_OFFSET : natural := 18; -- bit offset of the 'enable_dummy_frames' field
    constant CONFIG_ENABLE_DUMMY_FRAMES_BIT_WIDTH : natural := 1; -- bit width of the 'enable_dummy_frames' field
    constant CONFIG_ENABLE_DUMMY_FRAMES_RESET : std_logic_vector(18 downto 18) := std_logic_vector'("0"); -- reset value of the 'enable_dummy_frames' field
    
    -- Register 'ldpc_fifo_status'
    constant LDPC_FIFO_STATUS_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000004"); -- address offset of the 'ldpc_fifo_status' register
    -- Field 'ldpc_fifo_status.ldpc_fifo_entries'
    constant LDPC_FIFO_STATUS_LDPC_FIFO_ENTRIES_BIT_OFFSET : natural := 0; -- bit offset of the 'ldpc_fifo_entries' field
    constant LDPC_FIFO_STATUS_LDPC_FIFO_ENTRIES_BIT_WIDTH : natural := 14; -- bit width of the 'ldpc_fifo_entries' field
    constant LDPC_FIFO_STATUS_LDPC_FIFO_ENTRIES_RESET : std_logic_vector(13 downto 0) := std_logic_vector'("00000000000000"); -- reset value of the 'ldpc_fifo_entries' field
    -- Field 'ldpc_fifo_status.ldpc_fifo_empty'
    constant LDPC_FIFO_STATUS_LDPC_FIFO_EMPTY_BIT_OFFSET : natural := 16; -- bit offset of the 'ldpc_fifo_empty' field
    constant LDPC_FIFO_STATUS_LDPC_FIFO_EMPTY_BIT_WIDTH : natural := 1; -- bit width of the 'ldpc_fifo_empty' field
    constant LDPC_FIFO_STATUS_LDPC_FIFO_EMPTY_RESET : std_logic_vector(16 downto 16) := std_logic_vector'("0"); -- reset value of the 'ldpc_fifo_empty' field
    -- Field 'ldpc_fifo_status.ldpc_fifo_full'
    constant LDPC_FIFO_STATUS_LDPC_FIFO_FULL_BIT_OFFSET : natural := 17; -- bit offset of the 'ldpc_fifo_full' field
    constant LDPC_FIFO_STATUS_LDPC_FIFO_FULL_BIT_WIDTH : natural := 1; -- bit width of the 'ldpc_fifo_full' field
    constant LDPC_FIFO_STATUS_LDPC_FIFO_FULL_RESET : std_logic_vector(17 downto 17) := std_logic_vector'("0"); -- reset value of the 'ldpc_fifo_full' field
    
    -- Register 'frames_in_transit'
    constant FRAMES_IN_TRANSIT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000008"); -- address offset of the 'frames_in_transit' register
    -- Field 'frames_in_transit.value'
    constant FRAMES_IN_TRANSIT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant FRAMES_IN_TRANSIT_VALUE_BIT_WIDTH : natural := 8; -- bit width of the 'value' field
    constant FRAMES_IN_TRANSIT_VALUE_RESET : std_logic_vector(7 downto 0) := std_logic_vector'("00000000"); -- reset value of the 'value' field
    
    -- Register 'bit_mapper_ram'
    constant BIT_MAPPER_RAM_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000000C"); -- address offset of the 'bit_mapper_ram' register
    constant BIT_MAPPER_RAM_DEPTH : natural := 240; -- depth of the 'bit_mapper_ram' memory, in elements
    constant BIT_MAPPER_RAM_READ_LATENCY : natural := 1; -- read latency of the 'bit_mapper_ram' memory, in clock cycles
    -- Field 'bit_mapper_ram.data'
    constant BIT_MAPPER_RAM_DATA_BIT_OFFSET : natural := 0; -- bit offset of the 'data' field
    constant BIT_MAPPER_RAM_DATA_BIT_WIDTH : natural := 32; -- bit width of the 'data' field
    constant BIT_MAPPER_RAM_DATA_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'data' field
    
    -- Register 'polyphase_filter_coefficients'
    constant POLYPHASE_FILTER_COEFFICIENTS_OFFSET : unsigned(31 downto 0) := unsigned'(x"000003CC"); -- address offset of the 'polyphase_filter_coefficients' register
    constant POLYPHASE_FILTER_COEFFICIENTS_DEPTH : natural := 512; -- depth of the 'polyphase_filter_coefficients' memory, in elements
    constant POLYPHASE_FILTER_COEFFICIENTS_READ_LATENCY : natural := 1; -- read latency of the 'polyphase_filter_coefficients' memory, in clock cycles
    -- Field 'polyphase_filter_coefficients.value'
    constant POLYPHASE_FILTER_COEFFICIENTS_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant POLYPHASE_FILTER_COEFFICIENTS_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant POLYPHASE_FILTER_COEFFICIENTS_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field
    
    -- Register 'axi_debug_input_width_converter_cfg'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000BCC"); -- address offset of the 'axi_debug_input_width_converter_cfg' register
    -- Field 'axi_debug_input_width_converter_cfg.block_data'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_BIT_OFFSET : natural := 0; -- bit offset of the 'block_data' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_BIT_WIDTH : natural := 1; -- bit width of the 'block_data' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_BLOCK_DATA_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'block_data' field
    -- Field 'axi_debug_input_width_converter_cfg.allow_word'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_BIT_OFFSET : natural := 1; -- bit offset of the 'allow_word' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_BIT_WIDTH : natural := 1; -- bit width of the 'allow_word' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_WORD_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 'allow_word' field
    -- Field 'axi_debug_input_width_converter_cfg.allow_frame'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_BIT_OFFSET : natural := 2; -- bit offset of the 'allow_frame' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_BIT_WIDTH : natural := 1; -- bit width of the 'allow_frame' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_ALLOW_FRAME_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'allow_frame' field
    -- Field 'axi_debug_input_width_converter_cfg.reset_min_max'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_RESET_MIN_MAX_BIT_OFFSET : natural := 3; -- bit offset of the 'reset_min_max' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_RESET_MIN_MAX_BIT_WIDTH : natural := 1; -- bit width of the 'reset_min_max' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_RESET_MIN_MAX_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'reset_min_max' field
    
    -- Register 'axi_debug_input_width_converter_frame_count'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000BD0"); -- address offset of the 'axi_debug_input_width_converter_frame_count' register
    -- Field 'axi_debug_input_width_converter_frame_count.value'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field
    
    -- Register 'axi_debug_input_width_converter_last_frame_length'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000BD4"); -- address offset of the 'axi_debug_input_width_converter_last_frame_length' register
    -- Field 'axi_debug_input_width_converter_last_frame_length.value'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field
    
    -- Register 'axi_debug_input_width_converter_min_max_frame_length'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000BD8"); -- address offset of the 'axi_debug_input_width_converter_min_max_frame_length' register
    -- Field 'axi_debug_input_width_converter_min_max_frame_length.min_frame_length'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET : natural := 0; -- bit offset of the 'min_frame_length' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'min_frame_length' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'min_frame_length' field
    -- Field 'axi_debug_input_width_converter_min_max_frame_length.max_frame_length'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET : natural := 16; -- bit offset of the 'max_frame_length' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'max_frame_length' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET : std_logic_vector(31 downto 16) := std_logic_vector'("0000000000000000"); -- reset value of the 'max_frame_length' field
    
    -- Register 'axi_debug_bb_scrambler_cfg'
    constant AXI_DEBUG_BB_SCRAMBLER_CFG_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000BDC"); -- address offset of the 'axi_debug_bb_scrambler_cfg' register
    -- Field 'axi_debug_bb_scrambler_cfg.block_data'
    constant AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_BIT_OFFSET : natural := 0; -- bit offset of the 'block_data' field
    constant AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_BIT_WIDTH : natural := 1; -- bit width of the 'block_data' field
    constant AXI_DEBUG_BB_SCRAMBLER_CFG_BLOCK_DATA_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'block_data' field
    -- Field 'axi_debug_bb_scrambler_cfg.allow_word'
    constant AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_BIT_OFFSET : natural := 1; -- bit offset of the 'allow_word' field
    constant AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_BIT_WIDTH : natural := 1; -- bit width of the 'allow_word' field
    constant AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_WORD_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 'allow_word' field
    -- Field 'axi_debug_bb_scrambler_cfg.allow_frame'
    constant AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_BIT_OFFSET : natural := 2; -- bit offset of the 'allow_frame' field
    constant AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_BIT_WIDTH : natural := 1; -- bit width of the 'allow_frame' field
    constant AXI_DEBUG_BB_SCRAMBLER_CFG_ALLOW_FRAME_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'allow_frame' field
    -- Field 'axi_debug_bb_scrambler_cfg.reset_min_max'
    constant AXI_DEBUG_BB_SCRAMBLER_CFG_RESET_MIN_MAX_BIT_OFFSET : natural := 3; -- bit offset of the 'reset_min_max' field
    constant AXI_DEBUG_BB_SCRAMBLER_CFG_RESET_MIN_MAX_BIT_WIDTH : natural := 1; -- bit width of the 'reset_min_max' field
    constant AXI_DEBUG_BB_SCRAMBLER_CFG_RESET_MIN_MAX_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'reset_min_max' field
    
    -- Register 'axi_debug_bb_scrambler_frame_count'
    constant AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000BE0"); -- address offset of the 'axi_debug_bb_scrambler_frame_count' register
    -- Field 'axi_debug_bb_scrambler_frame_count.value'
    constant AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field
    
    -- Register 'axi_debug_bb_scrambler_last_frame_length'
    constant AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000BE4"); -- address offset of the 'axi_debug_bb_scrambler_last_frame_length' register
    -- Field 'axi_debug_bb_scrambler_last_frame_length.value'
    constant AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field
    
    -- Register 'axi_debug_bb_scrambler_min_max_frame_length'
    constant AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000BE8"); -- address offset of the 'axi_debug_bb_scrambler_min_max_frame_length' register
    -- Field 'axi_debug_bb_scrambler_min_max_frame_length.min_frame_length'
    constant AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET : natural := 0; -- bit offset of the 'min_frame_length' field
    constant AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'min_frame_length' field
    constant AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'min_frame_length' field
    -- Field 'axi_debug_bb_scrambler_min_max_frame_length.max_frame_length'
    constant AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET : natural := 16; -- bit offset of the 'max_frame_length' field
    constant AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'max_frame_length' field
    constant AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET : std_logic_vector(31 downto 16) := std_logic_vector'("0000000000000000"); -- reset value of the 'max_frame_length' field
    
    -- Register 'axi_debug_bch_encoder_cfg'
    constant AXI_DEBUG_BCH_ENCODER_CFG_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000BEC"); -- address offset of the 'axi_debug_bch_encoder_cfg' register
    -- Field 'axi_debug_bch_encoder_cfg.block_data'
    constant AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_BIT_OFFSET : natural := 0; -- bit offset of the 'block_data' field
    constant AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_BIT_WIDTH : natural := 1; -- bit width of the 'block_data' field
    constant AXI_DEBUG_BCH_ENCODER_CFG_BLOCK_DATA_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'block_data' field
    -- Field 'axi_debug_bch_encoder_cfg.allow_word'
    constant AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_BIT_OFFSET : natural := 1; -- bit offset of the 'allow_word' field
    constant AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_BIT_WIDTH : natural := 1; -- bit width of the 'allow_word' field
    constant AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_WORD_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 'allow_word' field
    -- Field 'axi_debug_bch_encoder_cfg.allow_frame'
    constant AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_BIT_OFFSET : natural := 2; -- bit offset of the 'allow_frame' field
    constant AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_BIT_WIDTH : natural := 1; -- bit width of the 'allow_frame' field
    constant AXI_DEBUG_BCH_ENCODER_CFG_ALLOW_FRAME_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'allow_frame' field
    -- Field 'axi_debug_bch_encoder_cfg.reset_min_max'
    constant AXI_DEBUG_BCH_ENCODER_CFG_RESET_MIN_MAX_BIT_OFFSET : natural := 3; -- bit offset of the 'reset_min_max' field
    constant AXI_DEBUG_BCH_ENCODER_CFG_RESET_MIN_MAX_BIT_WIDTH : natural := 1; -- bit width of the 'reset_min_max' field
    constant AXI_DEBUG_BCH_ENCODER_CFG_RESET_MIN_MAX_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'reset_min_max' field
    
    -- Register 'axi_debug_bch_encoder_frame_count'
    constant AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000BF0"); -- address offset of the 'axi_debug_bch_encoder_frame_count' register
    -- Field 'axi_debug_bch_encoder_frame_count.value'
    constant AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field
    
    -- Register 'axi_debug_bch_encoder_last_frame_length'
    constant AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000BF4"); -- address offset of the 'axi_debug_bch_encoder_last_frame_length' register
    -- Field 'axi_debug_bch_encoder_last_frame_length.value'
    constant AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field
    
    -- Register 'axi_debug_bch_encoder_min_max_frame_length'
    constant AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000BF8"); -- address offset of the 'axi_debug_bch_encoder_min_max_frame_length' register
    -- Field 'axi_debug_bch_encoder_min_max_frame_length.min_frame_length'
    constant AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET : natural := 0; -- bit offset of the 'min_frame_length' field
    constant AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'min_frame_length' field
    constant AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'min_frame_length' field
    -- Field 'axi_debug_bch_encoder_min_max_frame_length.max_frame_length'
    constant AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET : natural := 16; -- bit offset of the 'max_frame_length' field
    constant AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'max_frame_length' field
    constant AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET : std_logic_vector(31 downto 16) := std_logic_vector'("0000000000000000"); -- reset value of the 'max_frame_length' field
    
    -- Register 'axi_debug_ldpc_encoder_cfg'
    constant AXI_DEBUG_LDPC_ENCODER_CFG_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000BFC"); -- address offset of the 'axi_debug_ldpc_encoder_cfg' register
    -- Field 'axi_debug_ldpc_encoder_cfg.block_data'
    constant AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_BIT_OFFSET : natural := 0; -- bit offset of the 'block_data' field
    constant AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_BIT_WIDTH : natural := 1; -- bit width of the 'block_data' field
    constant AXI_DEBUG_LDPC_ENCODER_CFG_BLOCK_DATA_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'block_data' field
    -- Field 'axi_debug_ldpc_encoder_cfg.allow_word'
    constant AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_BIT_OFFSET : natural := 1; -- bit offset of the 'allow_word' field
    constant AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_BIT_WIDTH : natural := 1; -- bit width of the 'allow_word' field
    constant AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_WORD_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 'allow_word' field
    -- Field 'axi_debug_ldpc_encoder_cfg.allow_frame'
    constant AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_BIT_OFFSET : natural := 2; -- bit offset of the 'allow_frame' field
    constant AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_BIT_WIDTH : natural := 1; -- bit width of the 'allow_frame' field
    constant AXI_DEBUG_LDPC_ENCODER_CFG_ALLOW_FRAME_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'allow_frame' field
    -- Field 'axi_debug_ldpc_encoder_cfg.reset_min_max'
    constant AXI_DEBUG_LDPC_ENCODER_CFG_RESET_MIN_MAX_BIT_OFFSET : natural := 3; -- bit offset of the 'reset_min_max' field
    constant AXI_DEBUG_LDPC_ENCODER_CFG_RESET_MIN_MAX_BIT_WIDTH : natural := 1; -- bit width of the 'reset_min_max' field
    constant AXI_DEBUG_LDPC_ENCODER_CFG_RESET_MIN_MAX_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'reset_min_max' field
    
    -- Register 'axi_debug_ldpc_encoder_frame_count'
    constant AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000C00"); -- address offset of the 'axi_debug_ldpc_encoder_frame_count' register
    -- Field 'axi_debug_ldpc_encoder_frame_count.value'
    constant AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field
    
    -- Register 'axi_debug_ldpc_encoder_last_frame_length'
    constant AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000C04"); -- address offset of the 'axi_debug_ldpc_encoder_last_frame_length' register
    -- Field 'axi_debug_ldpc_encoder_last_frame_length.value'
    constant AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field
    
    -- Register 'axi_debug_ldpc_encoder_min_max_frame_length'
    constant AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000C08"); -- address offset of the 'axi_debug_ldpc_encoder_min_max_frame_length' register
    -- Field 'axi_debug_ldpc_encoder_min_max_frame_length.min_frame_length'
    constant AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET : natural := 0; -- bit offset of the 'min_frame_length' field
    constant AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'min_frame_length' field
    constant AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'min_frame_length' field
    -- Field 'axi_debug_ldpc_encoder_min_max_frame_length.max_frame_length'
    constant AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET : natural := 16; -- bit offset of the 'max_frame_length' field
    constant AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'max_frame_length' field
    constant AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET : std_logic_vector(31 downto 16) := std_logic_vector'("0000000000000000"); -- reset value of the 'max_frame_length' field
    
    -- Register 'axi_debug_bit_interleaver_cfg'
    constant AXI_DEBUG_BIT_INTERLEAVER_CFG_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000C0C"); -- address offset of the 'axi_debug_bit_interleaver_cfg' register
    -- Field 'axi_debug_bit_interleaver_cfg.block_data'
    constant AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_BIT_OFFSET : natural := 0; -- bit offset of the 'block_data' field
    constant AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_BIT_WIDTH : natural := 1; -- bit width of the 'block_data' field
    constant AXI_DEBUG_BIT_INTERLEAVER_CFG_BLOCK_DATA_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'block_data' field
    -- Field 'axi_debug_bit_interleaver_cfg.allow_word'
    constant AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_BIT_OFFSET : natural := 1; -- bit offset of the 'allow_word' field
    constant AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_BIT_WIDTH : natural := 1; -- bit width of the 'allow_word' field
    constant AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_WORD_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 'allow_word' field
    -- Field 'axi_debug_bit_interleaver_cfg.allow_frame'
    constant AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_BIT_OFFSET : natural := 2; -- bit offset of the 'allow_frame' field
    constant AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_BIT_WIDTH : natural := 1; -- bit width of the 'allow_frame' field
    constant AXI_DEBUG_BIT_INTERLEAVER_CFG_ALLOW_FRAME_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'allow_frame' field
    -- Field 'axi_debug_bit_interleaver_cfg.reset_min_max'
    constant AXI_DEBUG_BIT_INTERLEAVER_CFG_RESET_MIN_MAX_BIT_OFFSET : natural := 3; -- bit offset of the 'reset_min_max' field
    constant AXI_DEBUG_BIT_INTERLEAVER_CFG_RESET_MIN_MAX_BIT_WIDTH : natural := 1; -- bit width of the 'reset_min_max' field
    constant AXI_DEBUG_BIT_INTERLEAVER_CFG_RESET_MIN_MAX_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'reset_min_max' field
    
    -- Register 'axi_debug_bit_interleaver_frame_count'
    constant AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000C10"); -- address offset of the 'axi_debug_bit_interleaver_frame_count' register
    -- Field 'axi_debug_bit_interleaver_frame_count.value'
    constant AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field
    
    -- Register 'axi_debug_bit_interleaver_last_frame_length'
    constant AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000C14"); -- address offset of the 'axi_debug_bit_interleaver_last_frame_length' register
    -- Field 'axi_debug_bit_interleaver_last_frame_length.value'
    constant AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field
    
    -- Register 'axi_debug_bit_interleaver_min_max_frame_length'
    constant AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000C18"); -- address offset of the 'axi_debug_bit_interleaver_min_max_frame_length' register
    -- Field 'axi_debug_bit_interleaver_min_max_frame_length.min_frame_length'
    constant AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET : natural := 0; -- bit offset of the 'min_frame_length' field
    constant AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'min_frame_length' field
    constant AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'min_frame_length' field
    -- Field 'axi_debug_bit_interleaver_min_max_frame_length.max_frame_length'
    constant AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET : natural := 16; -- bit offset of the 'max_frame_length' field
    constant AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'max_frame_length' field
    constant AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET : std_logic_vector(31 downto 16) := std_logic_vector'("0000000000000000"); -- reset value of the 'max_frame_length' field

end dvbs2_tx_wrapper_regmap_regs_pkg;
