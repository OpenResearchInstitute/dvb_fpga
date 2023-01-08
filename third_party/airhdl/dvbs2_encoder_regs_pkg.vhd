-- -----------------------------------------------------------------------------
-- 'dvbs2_encoder' Register Definitions
-- Revision: 347
-- -----------------------------------------------------------------------------
-- Generated on 2023-01-08 at 17:59 (UTC) by airhdl version 2023.01.1-740440560
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

package dvbs2_encoder_regs_pkg is

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
        ldpc_fifo_status_ldpc_fifo_entries : std_logic_vector(13 downto 0); -- read value of register 'ldpc_fifo_status', field 'ldpc_fifo_entries'
        ldpc_fifo_status_ldpc_fifo_empty : std_logic_vector(0 downto 0); -- read value of register 'ldpc_fifo_status', field 'ldpc_fifo_empty'
        ldpc_fifo_status_ldpc_fifo_full : std_logic_vector(0 downto 0); -- read value of register 'ldpc_fifo_status', field 'ldpc_fifo_full'
        ldpc_fifo_status_arbiter_selected : std_logic_vector(1 downto 0); -- read value of register 'ldpc_fifo_status', field 'arbiter_selected'
        frames_in_transit_value : std_logic_vector(7 downto 0); -- read value of register 'frames_in_transit', field 'value'
        constellation_map_radius_ram_rdata : std_logic_vector(31 downto 0); -- read data for memory 'constellation_map_radius_ram'
        constellation_map_iq_ram_rdata : std_logic_vector(31 downto 0); -- read data for memory 'constellation_map_iq_ram'
        axi_debug_input_width_converter_frame_count_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_input_width_converter_frame_count', field 'value'
        axi_debug_input_width_converter_last_frame_length_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_input_width_converter_last_frame_length', field 'value'
        axi_debug_input_width_converter_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_input_width_converter_min_max_frame_length', field 'min_frame_length'
        axi_debug_input_width_converter_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_input_width_converter_min_max_frame_length', field 'max_frame_length'
        axi_debug_input_width_converter_word_count_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_input_width_converter_word_count', field 'value'
        axi_debug_input_width_converter_strobes_s_tvalid : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_input_width_converter_strobes', field 's_tvalid'
        axi_debug_input_width_converter_strobes_s_tready : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_input_width_converter_strobes', field 's_tready'
        axi_debug_input_width_converter_strobes_m_tvalid : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_input_width_converter_strobes', field 'm_tvalid'
        axi_debug_input_width_converter_strobes_m_tready : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_input_width_converter_strobes', field 'm_tready'
        axi_debug_bb_scrambler_frame_count_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bb_scrambler_frame_count', field 'value'
        axi_debug_bb_scrambler_last_frame_length_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bb_scrambler_last_frame_length', field 'value'
        axi_debug_bb_scrambler_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bb_scrambler_min_max_frame_length', field 'min_frame_length'
        axi_debug_bb_scrambler_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bb_scrambler_min_max_frame_length', field 'max_frame_length'
        axi_debug_bb_scrambler_word_count_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bb_scrambler_word_count', field 'value'
        axi_debug_bb_scrambler_strobes_s_tvalid : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_bb_scrambler_strobes', field 's_tvalid'
        axi_debug_bb_scrambler_strobes_s_tready : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_bb_scrambler_strobes', field 's_tready'
        axi_debug_bb_scrambler_strobes_m_tvalid : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_bb_scrambler_strobes', field 'm_tvalid'
        axi_debug_bb_scrambler_strobes_m_tready : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_bb_scrambler_strobes', field 'm_tready'
        axi_debug_bch_encoder_frame_count_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bch_encoder_frame_count', field 'value'
        axi_debug_bch_encoder_last_frame_length_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bch_encoder_last_frame_length', field 'value'
        axi_debug_bch_encoder_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bch_encoder_min_max_frame_length', field 'min_frame_length'
        axi_debug_bch_encoder_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bch_encoder_min_max_frame_length', field 'max_frame_length'
        axi_debug_bch_encoder_word_count_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bch_encoder_word_count', field 'value'
        axi_debug_bch_encoder_strobes_s_tvalid : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_bch_encoder_strobes', field 's_tvalid'
        axi_debug_bch_encoder_strobes_s_tready : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_bch_encoder_strobes', field 's_tready'
        axi_debug_bch_encoder_strobes_m_tvalid : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_bch_encoder_strobes', field 'm_tvalid'
        axi_debug_bch_encoder_strobes_m_tready : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_bch_encoder_strobes', field 'm_tready'
        axi_debug_ldpc_encoder_frame_count_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_ldpc_encoder_frame_count', field 'value'
        axi_debug_ldpc_encoder_last_frame_length_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_ldpc_encoder_last_frame_length', field 'value'
        axi_debug_ldpc_encoder_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_ldpc_encoder_min_max_frame_length', field 'min_frame_length'
        axi_debug_ldpc_encoder_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_ldpc_encoder_min_max_frame_length', field 'max_frame_length'
        axi_debug_ldpc_encoder_word_count_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_ldpc_encoder_word_count', field 'value'
        axi_debug_ldpc_encoder_strobes_s_tvalid : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_ldpc_encoder_strobes', field 's_tvalid'
        axi_debug_ldpc_encoder_strobes_s_tready : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_ldpc_encoder_strobes', field 's_tready'
        axi_debug_ldpc_encoder_strobes_m_tvalid : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_ldpc_encoder_strobes', field 'm_tvalid'
        axi_debug_ldpc_encoder_strobes_m_tready : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_ldpc_encoder_strobes', field 'm_tready'
        axi_debug_bit_interleaver_frame_count_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bit_interleaver_frame_count', field 'value'
        axi_debug_bit_interleaver_last_frame_length_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bit_interleaver_last_frame_length', field 'value'
        axi_debug_bit_interleaver_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bit_interleaver_min_max_frame_length', field 'min_frame_length'
        axi_debug_bit_interleaver_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bit_interleaver_min_max_frame_length', field 'max_frame_length'
        axi_debug_bit_interleaver_word_count_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_bit_interleaver_word_count', field 'value'
        axi_debug_bit_interleaver_strobes_s_tvalid : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_bit_interleaver_strobes', field 's_tvalid'
        axi_debug_bit_interleaver_strobes_s_tready : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_bit_interleaver_strobes', field 's_tready'
        axi_debug_bit_interleaver_strobes_m_tvalid : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_bit_interleaver_strobes', field 'm_tvalid'
        axi_debug_bit_interleaver_strobes_m_tready : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_bit_interleaver_strobes', field 'm_tready'
        axi_debug_constellation_mapper_frame_count_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_constellation_mapper_frame_count', field 'value'
        axi_debug_constellation_mapper_last_frame_length_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_constellation_mapper_last_frame_length', field 'value'
        axi_debug_constellation_mapper_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_constellation_mapper_min_max_frame_length', field 'min_frame_length'
        axi_debug_constellation_mapper_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_constellation_mapper_min_max_frame_length', field 'max_frame_length'
        axi_debug_constellation_mapper_word_count_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_constellation_mapper_word_count', field 'value'
        axi_debug_constellation_mapper_strobes_s_tvalid : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_constellation_mapper_strobes', field 's_tvalid'
        axi_debug_constellation_mapper_strobes_s_tready : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_constellation_mapper_strobes', field 's_tready'
        axi_debug_constellation_mapper_strobes_m_tvalid : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_constellation_mapper_strobes', field 'm_tvalid'
        axi_debug_constellation_mapper_strobes_m_tready : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_constellation_mapper_strobes', field 'm_tready'
        axi_debug_plframe_frame_count_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_plframe_frame_count', field 'value'
        axi_debug_plframe_last_frame_length_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_plframe_last_frame_length', field 'value'
        axi_debug_plframe_min_max_frame_length_min_frame_length : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_plframe_min_max_frame_length', field 'min_frame_length'
        axi_debug_plframe_min_max_frame_length_max_frame_length : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_plframe_min_max_frame_length', field 'max_frame_length'
        axi_debug_plframe_word_count_value : std_logic_vector(15 downto 0); -- read value of register 'axi_debug_plframe_word_count', field 'value'
        axi_debug_plframe_strobes_s_tvalid : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_plframe_strobes', field 's_tvalid'
        axi_debug_plframe_strobes_s_tready : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_plframe_strobes', field 's_tready'
        axi_debug_plframe_strobes_m_tvalid : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_plframe_strobes', field 'm_tvalid'
        axi_debug_plframe_strobes_m_tready : std_logic_vector(0 downto 0); -- read value of register 'axi_debug_plframe_strobes', field 'm_tready'
    end record;

    -- User-logic ports (from register file to user-logic)
    type regs2user_t is record
        config_strobe : std_logic; -- Strobe signal for register 'config' (pulsed when the register is written from the bus}
        config_physical_layer_scrambler_shift_reg_init : std_logic_vector(17 downto 0); -- Value of register 'config', field 'physical_layer_scrambler_shift_reg_init'
        config_enable_dummy_frames : std_logic_vector(0 downto 0); -- Value of register 'config', field 'enable_dummy_frames'
        config_swap_input_data_byte_endianness : std_logic_vector(0 downto 0); -- Value of register 'config', field 'swap_input_data_byte_endianness'
        config_swap_output_data_byte_endianness : std_logic_vector(0 downto 0); -- Value of register 'config', field 'swap_output_data_byte_endianness'
        config_force_output_ready : std_logic_vector(0 downto 0); -- Value of register 'config', field 'force_output_ready'
        ldpc_fifo_status_strobe : std_logic; -- Strobe signal for register 'ldpc_fifo_status' (pulsed when the register is read from the bus}
        frames_in_transit_strobe : std_logic; -- Strobe signal for register 'frames_in_transit' (pulsed when the register is read from the bus}
        constellation_map_radius_ram_addr : std_logic_vector(4 downto 0); -- read/write address for memory 'constellation_map_radius_ram'
        constellation_map_radius_ram_wdata : std_logic_vector(31 downto 0); -- write data for memory 'constellation_map_radius_ram'
        constellation_map_radius_ram_wen : std_logic_vector(3 downto 0); -- byte-wide write-enable for memory 'constellation_map_radius_ram'
        constellation_map_radius_ram_ren : std_logic; -- read-enable for memory 'constellation_map_radius_ram'
        constellation_map_iq_ram_addr : std_logic_vector(5 downto 0); -- read/write address for memory 'constellation_map_iq_ram'
        constellation_map_iq_ram_wdata : std_logic_vector(31 downto 0); -- write data for memory 'constellation_map_iq_ram'
        constellation_map_iq_ram_wen : std_logic_vector(3 downto 0); -- byte-wide write-enable for memory 'constellation_map_iq_ram'
        constellation_map_iq_ram_ren : std_logic; -- read-enable for memory 'constellation_map_iq_ram'
        axi_debug_input_width_converter_cfg_strobe : std_logic; -- Strobe signal for register 'axi_debug_input_width_converter_cfg' (pulsed when the register is written from the bus}
        axi_debug_input_width_converter_cfg_block_data : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_input_width_converter_cfg', field 'block_data'
        axi_debug_input_width_converter_cfg_allow_word : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_input_width_converter_cfg', field 'allow_word'
        axi_debug_input_width_converter_cfg_allow_frame : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_input_width_converter_cfg', field 'allow_frame'
        axi_debug_input_width_converter_frame_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_input_width_converter_frame_count' (pulsed when the register is read from the bus}
        axi_debug_input_width_converter_last_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_input_width_converter_last_frame_length' (pulsed when the register is read from the bus}
        axi_debug_input_width_converter_min_max_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_input_width_converter_min_max_frame_length' (pulsed when the register is read from the bus}
        axi_debug_input_width_converter_word_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_input_width_converter_word_count' (pulsed when the register is read from the bus}
        axi_debug_input_width_converter_strobes_strobe : std_logic; -- Strobe signal for register 'axi_debug_input_width_converter_strobes' (pulsed when the register is read from the bus}
        axi_debug_bb_scrambler_cfg_strobe : std_logic; -- Strobe signal for register 'axi_debug_bb_scrambler_cfg' (pulsed when the register is written from the bus}
        axi_debug_bb_scrambler_cfg_block_data : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bb_scrambler_cfg', field 'block_data'
        axi_debug_bb_scrambler_cfg_allow_word : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bb_scrambler_cfg', field 'allow_word'
        axi_debug_bb_scrambler_cfg_allow_frame : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bb_scrambler_cfg', field 'allow_frame'
        axi_debug_bb_scrambler_frame_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_bb_scrambler_frame_count' (pulsed when the register is read from the bus}
        axi_debug_bb_scrambler_last_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_bb_scrambler_last_frame_length' (pulsed when the register is read from the bus}
        axi_debug_bb_scrambler_min_max_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_bb_scrambler_min_max_frame_length' (pulsed when the register is read from the bus}
        axi_debug_bb_scrambler_word_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_bb_scrambler_word_count' (pulsed when the register is read from the bus}
        axi_debug_bb_scrambler_strobes_strobe : std_logic; -- Strobe signal for register 'axi_debug_bb_scrambler_strobes' (pulsed when the register is read from the bus}
        axi_debug_bch_encoder_cfg_strobe : std_logic; -- Strobe signal for register 'axi_debug_bch_encoder_cfg' (pulsed when the register is written from the bus}
        axi_debug_bch_encoder_cfg_block_data : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bch_encoder_cfg', field 'block_data'
        axi_debug_bch_encoder_cfg_allow_word : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bch_encoder_cfg', field 'allow_word'
        axi_debug_bch_encoder_cfg_allow_frame : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bch_encoder_cfg', field 'allow_frame'
        axi_debug_bch_encoder_frame_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_bch_encoder_frame_count' (pulsed when the register is read from the bus}
        axi_debug_bch_encoder_last_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_bch_encoder_last_frame_length' (pulsed when the register is read from the bus}
        axi_debug_bch_encoder_min_max_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_bch_encoder_min_max_frame_length' (pulsed when the register is read from the bus}
        axi_debug_bch_encoder_word_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_bch_encoder_word_count' (pulsed when the register is read from the bus}
        axi_debug_bch_encoder_strobes_strobe : std_logic; -- Strobe signal for register 'axi_debug_bch_encoder_strobes' (pulsed when the register is read from the bus}
        axi_debug_ldpc_encoder_cfg_strobe : std_logic; -- Strobe signal for register 'axi_debug_ldpc_encoder_cfg' (pulsed when the register is written from the bus}
        axi_debug_ldpc_encoder_cfg_block_data : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_ldpc_encoder_cfg', field 'block_data'
        axi_debug_ldpc_encoder_cfg_allow_word : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_ldpc_encoder_cfg', field 'allow_word'
        axi_debug_ldpc_encoder_cfg_allow_frame : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_ldpc_encoder_cfg', field 'allow_frame'
        axi_debug_ldpc_encoder_frame_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_ldpc_encoder_frame_count' (pulsed when the register is read from the bus}
        axi_debug_ldpc_encoder_last_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_ldpc_encoder_last_frame_length' (pulsed when the register is read from the bus}
        axi_debug_ldpc_encoder_min_max_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_ldpc_encoder_min_max_frame_length' (pulsed when the register is read from the bus}
        axi_debug_ldpc_encoder_word_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_ldpc_encoder_word_count' (pulsed when the register is read from the bus}
        axi_debug_ldpc_encoder_strobes_strobe : std_logic; -- Strobe signal for register 'axi_debug_ldpc_encoder_strobes' (pulsed when the register is read from the bus}
        axi_debug_bit_interleaver_cfg_strobe : std_logic; -- Strobe signal for register 'axi_debug_bit_interleaver_cfg' (pulsed when the register is written from the bus}
        axi_debug_bit_interleaver_cfg_block_data : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bit_interleaver_cfg', field 'block_data'
        axi_debug_bit_interleaver_cfg_allow_word : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bit_interleaver_cfg', field 'allow_word'
        axi_debug_bit_interleaver_cfg_allow_frame : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_bit_interleaver_cfg', field 'allow_frame'
        axi_debug_bit_interleaver_frame_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_bit_interleaver_frame_count' (pulsed when the register is read from the bus}
        axi_debug_bit_interleaver_last_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_bit_interleaver_last_frame_length' (pulsed when the register is read from the bus}
        axi_debug_bit_interleaver_min_max_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_bit_interleaver_min_max_frame_length' (pulsed when the register is read from the bus}
        axi_debug_bit_interleaver_word_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_bit_interleaver_word_count' (pulsed when the register is read from the bus}
        axi_debug_bit_interleaver_strobes_strobe : std_logic; -- Strobe signal for register 'axi_debug_bit_interleaver_strobes' (pulsed when the register is read from the bus}
        axi_debug_constellation_mapper_cfg_strobe : std_logic; -- Strobe signal for register 'axi_debug_constellation_mapper_cfg' (pulsed when the register is written from the bus}
        axi_debug_constellation_mapper_cfg_block_data : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_constellation_mapper_cfg', field 'block_data'
        axi_debug_constellation_mapper_cfg_allow_word : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_constellation_mapper_cfg', field 'allow_word'
        axi_debug_constellation_mapper_cfg_allow_frame : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_constellation_mapper_cfg', field 'allow_frame'
        axi_debug_constellation_mapper_frame_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_constellation_mapper_frame_count' (pulsed when the register is read from the bus}
        axi_debug_constellation_mapper_last_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_constellation_mapper_last_frame_length' (pulsed when the register is read from the bus}
        axi_debug_constellation_mapper_min_max_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_constellation_mapper_min_max_frame_length' (pulsed when the register is read from the bus}
        axi_debug_constellation_mapper_word_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_constellation_mapper_word_count' (pulsed when the register is read from the bus}
        axi_debug_constellation_mapper_strobes_strobe : std_logic; -- Strobe signal for register 'axi_debug_constellation_mapper_strobes' (pulsed when the register is read from the bus}
        axi_debug_plframe_cfg_strobe : std_logic; -- Strobe signal for register 'axi_debug_plframe_cfg' (pulsed when the register is written from the bus}
        axi_debug_plframe_cfg_block_data : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_plframe_cfg', field 'block_data'
        axi_debug_plframe_cfg_allow_word : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_plframe_cfg', field 'allow_word'
        axi_debug_plframe_cfg_allow_frame : std_logic_vector(0 downto 0); -- Value of register 'axi_debug_plframe_cfg', field 'allow_frame'
        axi_debug_plframe_frame_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_plframe_frame_count' (pulsed when the register is read from the bus}
        axi_debug_plframe_last_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_plframe_last_frame_length' (pulsed when the register is read from the bus}
        axi_debug_plframe_min_max_frame_length_strobe : std_logic; -- Strobe signal for register 'axi_debug_plframe_min_max_frame_length' (pulsed when the register is read from the bus}
        axi_debug_plframe_word_count_strobe : std_logic; -- Strobe signal for register 'axi_debug_plframe_word_count' (pulsed when the register is read from the bus}
        axi_debug_plframe_strobes_strobe : std_logic; -- Strobe signal for register 'axi_debug_plframe_strobes' (pulsed when the register is read from the bus}
    end record;

    -- Revision number of the 'dvbs2_encoder' register map
    constant DVBS2_ENCODER_REVISION : natural := 347;

    -- Default base address of the 'dvbs2_encoder' register map
    constant DVBS2_ENCODER_DEFAULT_BASEADDR : unsigned(31 downto 0) := unsigned'(x"00000000");

    -- Size of the 'dvbs2_encoder' register map, in bytes
    constant DVBS2_ENCODER_RANGE_BYTES : natural := 4888;

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
    -- Field 'config.swap_input_data_byte_endianness'
    constant CONFIG_SWAP_INPUT_DATA_BYTE_ENDIANNESS_BIT_OFFSET : natural := 19; -- bit offset of the 'swap_input_data_byte_endianness' field
    constant CONFIG_SWAP_INPUT_DATA_BYTE_ENDIANNESS_BIT_WIDTH : natural := 1; -- bit width of the 'swap_input_data_byte_endianness' field
    constant CONFIG_SWAP_INPUT_DATA_BYTE_ENDIANNESS_RESET : std_logic_vector(19 downto 19) := std_logic_vector'("0"); -- reset value of the 'swap_input_data_byte_endianness' field
    -- Field 'config.swap_output_data_byte_endianness'
    constant CONFIG_SWAP_OUTPUT_DATA_BYTE_ENDIANNESS_BIT_OFFSET : natural := 20; -- bit offset of the 'swap_output_data_byte_endianness' field
    constant CONFIG_SWAP_OUTPUT_DATA_BYTE_ENDIANNESS_BIT_WIDTH : natural := 1; -- bit width of the 'swap_output_data_byte_endianness' field
    constant CONFIG_SWAP_OUTPUT_DATA_BYTE_ENDIANNESS_RESET : std_logic_vector(20 downto 20) := std_logic_vector'("0"); -- reset value of the 'swap_output_data_byte_endianness' field
    -- Field 'config.force_output_ready'
    constant CONFIG_FORCE_OUTPUT_READY_BIT_OFFSET : natural := 21; -- bit offset of the 'force_output_ready' field
    constant CONFIG_FORCE_OUTPUT_READY_BIT_WIDTH : natural := 1; -- bit width of the 'force_output_ready' field
    constant CONFIG_FORCE_OUTPUT_READY_RESET : std_logic_vector(21 downto 21) := std_logic_vector'("0"); -- reset value of the 'force_output_ready' field

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
    -- Field 'ldpc_fifo_status.arbiter_selected'
    constant LDPC_FIFO_STATUS_ARBITER_SELECTED_BIT_OFFSET : natural := 20; -- bit offset of the 'arbiter_selected' field
    constant LDPC_FIFO_STATUS_ARBITER_SELECTED_BIT_WIDTH : natural := 2; -- bit width of the 'arbiter_selected' field
    constant LDPC_FIFO_STATUS_ARBITER_SELECTED_RESET : std_logic_vector(21 downto 20) := std_logic_vector'("00"); -- reset value of the 'arbiter_selected' field

    -- Register 'frames_in_transit'
    constant FRAMES_IN_TRANSIT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000008"); -- address offset of the 'frames_in_transit' register
    -- Field 'frames_in_transit.value'
    constant FRAMES_IN_TRANSIT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant FRAMES_IN_TRANSIT_VALUE_BIT_WIDTH : natural := 8; -- bit width of the 'value' field
    constant FRAMES_IN_TRANSIT_VALUE_RESET : std_logic_vector(7 downto 0) := std_logic_vector'("00000000"); -- reset value of the 'value' field

    -- Register 'constellation_map_radius_ram'
    constant CONSTELLATION_MAP_RADIUS_RAM_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000010"); -- address offset of the 'constellation_map_radius_ram' register
    constant CONSTELLATION_MAP_RADIUS_RAM_DEPTH : natural := 22; -- depth of the 'constellation_map_radius_ram' memory, in elements
    constant CONSTELLATION_MAP_RADIUS_RAM_READ_LATENCY : natural := 2; -- read latency of the 'constellation_map_radius_ram' memory, in clock cycles
    -- Field 'constellation_map_radius_ram.value'
    constant CONSTELLATION_MAP_RADIUS_RAM_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant CONSTELLATION_MAP_RADIUS_RAM_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant CONSTELLATION_MAP_RADIUS_RAM_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'constellation_map_iq_ram'
    constant CONSTELLATION_MAP_IQ_RAM_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000110"); -- address offset of the 'constellation_map_iq_ram' register
    constant CONSTELLATION_MAP_IQ_RAM_DEPTH : natural := 60; -- depth of the 'constellation_map_iq_ram' memory, in elements
    constant CONSTELLATION_MAP_IQ_RAM_READ_LATENCY : natural := 2; -- read latency of the 'constellation_map_iq_ram' memory, in clock cycles
    -- Field 'constellation_map_iq_ram.value'
    constant CONSTELLATION_MAP_IQ_RAM_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant CONSTELLATION_MAP_IQ_RAM_VALUE_BIT_WIDTH : natural := 32; -- bit width of the 'value' field
    constant CONSTELLATION_MAP_IQ_RAM_VALUE_RESET : std_logic_vector(31 downto 0) := std_logic_vector'("00000000000000000000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_input_width_converter_cfg'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_CFG_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000D00"); -- address offset of the 'axi_debug_input_width_converter_cfg' register
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

    -- Register 'axi_debug_input_width_converter_frame_count'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000D04"); -- address offset of the 'axi_debug_input_width_converter_frame_count' register
    -- Field 'axi_debug_input_width_converter_frame_count.value'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_FRAME_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_input_width_converter_last_frame_length'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000D08"); -- address offset of the 'axi_debug_input_width_converter_last_frame_length' register
    -- Field 'axi_debug_input_width_converter_last_frame_length.value'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_LAST_FRAME_LENGTH_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_input_width_converter_min_max_frame_length'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000D0C"); -- address offset of the 'axi_debug_input_width_converter_min_max_frame_length' register
    -- Field 'axi_debug_input_width_converter_min_max_frame_length.min_frame_length'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET : natural := 0; -- bit offset of the 'min_frame_length' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'min_frame_length' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'min_frame_length' field
    -- Field 'axi_debug_input_width_converter_min_max_frame_length.max_frame_length'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET : natural := 16; -- bit offset of the 'max_frame_length' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'max_frame_length' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET : std_logic_vector(31 downto 16) := std_logic_vector'("0000000000000000"); -- reset value of the 'max_frame_length' field

    -- Register 'axi_debug_input_width_converter_word_count'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000D10"); -- address offset of the 'axi_debug_input_width_converter_word_count' register
    -- Field 'axi_debug_input_width_converter_word_count.value'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_WORD_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_input_width_converter_strobes'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000D14"); -- address offset of the 'axi_debug_input_width_converter_strobes' register
    -- Field 'axi_debug_input_width_converter_strobes.s_tvalid'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TVALID_BIT_OFFSET : natural := 0; -- bit offset of the 's_tvalid' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TVALID_BIT_WIDTH : natural := 1; -- bit width of the 's_tvalid' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TVALID_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 's_tvalid' field
    -- Field 'axi_debug_input_width_converter_strobes.s_tready'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TREADY_BIT_OFFSET : natural := 1; -- bit offset of the 's_tready' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TREADY_BIT_WIDTH : natural := 1; -- bit width of the 's_tready' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_S_TREADY_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 's_tready' field
    -- Field 'axi_debug_input_width_converter_strobes.m_tvalid'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TVALID_BIT_OFFSET : natural := 2; -- bit offset of the 'm_tvalid' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TVALID_BIT_WIDTH : natural := 1; -- bit width of the 'm_tvalid' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TVALID_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'm_tvalid' field
    -- Field 'axi_debug_input_width_converter_strobes.m_tready'
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TREADY_BIT_OFFSET : natural := 3; -- bit offset of the 'm_tready' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TREADY_BIT_WIDTH : natural := 1; -- bit width of the 'm_tready' field
    constant AXI_DEBUG_INPUT_WIDTH_CONVERTER_STROBES_M_TREADY_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'm_tready' field

    -- Register 'axi_debug_bb_scrambler_cfg'
    constant AXI_DEBUG_BB_SCRAMBLER_CFG_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000E00"); -- address offset of the 'axi_debug_bb_scrambler_cfg' register
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

    -- Register 'axi_debug_bb_scrambler_frame_count'
    constant AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000E04"); -- address offset of the 'axi_debug_bb_scrambler_frame_count' register
    -- Field 'axi_debug_bb_scrambler_frame_count.value'
    constant AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BB_SCRAMBLER_FRAME_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_bb_scrambler_last_frame_length'
    constant AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000E08"); -- address offset of the 'axi_debug_bb_scrambler_last_frame_length' register
    -- Field 'axi_debug_bb_scrambler_last_frame_length.value'
    constant AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BB_SCRAMBLER_LAST_FRAME_LENGTH_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_bb_scrambler_min_max_frame_length'
    constant AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000E0C"); -- address offset of the 'axi_debug_bb_scrambler_min_max_frame_length' register
    -- Field 'axi_debug_bb_scrambler_min_max_frame_length.min_frame_length'
    constant AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET : natural := 0; -- bit offset of the 'min_frame_length' field
    constant AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'min_frame_length' field
    constant AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'min_frame_length' field
    -- Field 'axi_debug_bb_scrambler_min_max_frame_length.max_frame_length'
    constant AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET : natural := 16; -- bit offset of the 'max_frame_length' field
    constant AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'max_frame_length' field
    constant AXI_DEBUG_BB_SCRAMBLER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET : std_logic_vector(31 downto 16) := std_logic_vector'("0000000000000000"); -- reset value of the 'max_frame_length' field

    -- Register 'axi_debug_bb_scrambler_word_count'
    constant AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000E10"); -- address offset of the 'axi_debug_bb_scrambler_word_count' register
    -- Field 'axi_debug_bb_scrambler_word_count.value'
    constant AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BB_SCRAMBLER_WORD_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_bb_scrambler_strobes'
    constant AXI_DEBUG_BB_SCRAMBLER_STROBES_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000E14"); -- address offset of the 'axi_debug_bb_scrambler_strobes' register
    -- Field 'axi_debug_bb_scrambler_strobes.s_tvalid'
    constant AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TVALID_BIT_OFFSET : natural := 0; -- bit offset of the 's_tvalid' field
    constant AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TVALID_BIT_WIDTH : natural := 1; -- bit width of the 's_tvalid' field
    constant AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TVALID_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 's_tvalid' field
    -- Field 'axi_debug_bb_scrambler_strobes.s_tready'
    constant AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TREADY_BIT_OFFSET : natural := 1; -- bit offset of the 's_tready' field
    constant AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TREADY_BIT_WIDTH : natural := 1; -- bit width of the 's_tready' field
    constant AXI_DEBUG_BB_SCRAMBLER_STROBES_S_TREADY_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 's_tready' field
    -- Field 'axi_debug_bb_scrambler_strobes.m_tvalid'
    constant AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TVALID_BIT_OFFSET : natural := 2; -- bit offset of the 'm_tvalid' field
    constant AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TVALID_BIT_WIDTH : natural := 1; -- bit width of the 'm_tvalid' field
    constant AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TVALID_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'm_tvalid' field
    -- Field 'axi_debug_bb_scrambler_strobes.m_tready'
    constant AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TREADY_BIT_OFFSET : natural := 3; -- bit offset of the 'm_tready' field
    constant AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TREADY_BIT_WIDTH : natural := 1; -- bit width of the 'm_tready' field
    constant AXI_DEBUG_BB_SCRAMBLER_STROBES_M_TREADY_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'm_tready' field

    -- Register 'axi_debug_bch_encoder_cfg'
    constant AXI_DEBUG_BCH_ENCODER_CFG_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000F00"); -- address offset of the 'axi_debug_bch_encoder_cfg' register
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

    -- Register 'axi_debug_bch_encoder_frame_count'
    constant AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000F04"); -- address offset of the 'axi_debug_bch_encoder_frame_count' register
    -- Field 'axi_debug_bch_encoder_frame_count.value'
    constant AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BCH_ENCODER_FRAME_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_bch_encoder_last_frame_length'
    constant AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000F08"); -- address offset of the 'axi_debug_bch_encoder_last_frame_length' register
    -- Field 'axi_debug_bch_encoder_last_frame_length.value'
    constant AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BCH_ENCODER_LAST_FRAME_LENGTH_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_bch_encoder_min_max_frame_length'
    constant AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000F0C"); -- address offset of the 'axi_debug_bch_encoder_min_max_frame_length' register
    -- Field 'axi_debug_bch_encoder_min_max_frame_length.min_frame_length'
    constant AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET : natural := 0; -- bit offset of the 'min_frame_length' field
    constant AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'min_frame_length' field
    constant AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'min_frame_length' field
    -- Field 'axi_debug_bch_encoder_min_max_frame_length.max_frame_length'
    constant AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET : natural := 16; -- bit offset of the 'max_frame_length' field
    constant AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'max_frame_length' field
    constant AXI_DEBUG_BCH_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET : std_logic_vector(31 downto 16) := std_logic_vector'("0000000000000000"); -- reset value of the 'max_frame_length' field

    -- Register 'axi_debug_bch_encoder_word_count'
    constant AXI_DEBUG_BCH_ENCODER_WORD_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000F10"); -- address offset of the 'axi_debug_bch_encoder_word_count' register
    -- Field 'axi_debug_bch_encoder_word_count.value'
    constant AXI_DEBUG_BCH_ENCODER_WORD_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BCH_ENCODER_WORD_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BCH_ENCODER_WORD_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_bch_encoder_strobes'
    constant AXI_DEBUG_BCH_ENCODER_STROBES_OFFSET : unsigned(31 downto 0) := unsigned'(x"00000F14"); -- address offset of the 'axi_debug_bch_encoder_strobes' register
    -- Field 'axi_debug_bch_encoder_strobes.s_tvalid'
    constant AXI_DEBUG_BCH_ENCODER_STROBES_S_TVALID_BIT_OFFSET : natural := 0; -- bit offset of the 's_tvalid' field
    constant AXI_DEBUG_BCH_ENCODER_STROBES_S_TVALID_BIT_WIDTH : natural := 1; -- bit width of the 's_tvalid' field
    constant AXI_DEBUG_BCH_ENCODER_STROBES_S_TVALID_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 's_tvalid' field
    -- Field 'axi_debug_bch_encoder_strobes.s_tready'
    constant AXI_DEBUG_BCH_ENCODER_STROBES_S_TREADY_BIT_OFFSET : natural := 1; -- bit offset of the 's_tready' field
    constant AXI_DEBUG_BCH_ENCODER_STROBES_S_TREADY_BIT_WIDTH : natural := 1; -- bit width of the 's_tready' field
    constant AXI_DEBUG_BCH_ENCODER_STROBES_S_TREADY_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 's_tready' field
    -- Field 'axi_debug_bch_encoder_strobes.m_tvalid'
    constant AXI_DEBUG_BCH_ENCODER_STROBES_M_TVALID_BIT_OFFSET : natural := 2; -- bit offset of the 'm_tvalid' field
    constant AXI_DEBUG_BCH_ENCODER_STROBES_M_TVALID_BIT_WIDTH : natural := 1; -- bit width of the 'm_tvalid' field
    constant AXI_DEBUG_BCH_ENCODER_STROBES_M_TVALID_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'm_tvalid' field
    -- Field 'axi_debug_bch_encoder_strobes.m_tready'
    constant AXI_DEBUG_BCH_ENCODER_STROBES_M_TREADY_BIT_OFFSET : natural := 3; -- bit offset of the 'm_tready' field
    constant AXI_DEBUG_BCH_ENCODER_STROBES_M_TREADY_BIT_WIDTH : natural := 1; -- bit width of the 'm_tready' field
    constant AXI_DEBUG_BCH_ENCODER_STROBES_M_TREADY_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'm_tready' field

    -- Register 'axi_debug_ldpc_encoder_cfg'
    constant AXI_DEBUG_LDPC_ENCODER_CFG_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001000"); -- address offset of the 'axi_debug_ldpc_encoder_cfg' register
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

    -- Register 'axi_debug_ldpc_encoder_frame_count'
    constant AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001004"); -- address offset of the 'axi_debug_ldpc_encoder_frame_count' register
    -- Field 'axi_debug_ldpc_encoder_frame_count.value'
    constant AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_LDPC_ENCODER_FRAME_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_ldpc_encoder_last_frame_length'
    constant AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001008"); -- address offset of the 'axi_debug_ldpc_encoder_last_frame_length' register
    -- Field 'axi_debug_ldpc_encoder_last_frame_length.value'
    constant AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_LDPC_ENCODER_LAST_FRAME_LENGTH_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_ldpc_encoder_min_max_frame_length'
    constant AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000100C"); -- address offset of the 'axi_debug_ldpc_encoder_min_max_frame_length' register
    -- Field 'axi_debug_ldpc_encoder_min_max_frame_length.min_frame_length'
    constant AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET : natural := 0; -- bit offset of the 'min_frame_length' field
    constant AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'min_frame_length' field
    constant AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'min_frame_length' field
    -- Field 'axi_debug_ldpc_encoder_min_max_frame_length.max_frame_length'
    constant AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET : natural := 16; -- bit offset of the 'max_frame_length' field
    constant AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'max_frame_length' field
    constant AXI_DEBUG_LDPC_ENCODER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET : std_logic_vector(31 downto 16) := std_logic_vector'("0000000000000000"); -- reset value of the 'max_frame_length' field

    -- Register 'axi_debug_ldpc_encoder_word_count'
    constant AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001010"); -- address offset of the 'axi_debug_ldpc_encoder_word_count' register
    -- Field 'axi_debug_ldpc_encoder_word_count.value'
    constant AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_LDPC_ENCODER_WORD_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_ldpc_encoder_strobes'
    constant AXI_DEBUG_LDPC_ENCODER_STROBES_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001014"); -- address offset of the 'axi_debug_ldpc_encoder_strobes' register
    -- Field 'axi_debug_ldpc_encoder_strobes.s_tvalid'
    constant AXI_DEBUG_LDPC_ENCODER_STROBES_S_TVALID_BIT_OFFSET : natural := 0; -- bit offset of the 's_tvalid' field
    constant AXI_DEBUG_LDPC_ENCODER_STROBES_S_TVALID_BIT_WIDTH : natural := 1; -- bit width of the 's_tvalid' field
    constant AXI_DEBUG_LDPC_ENCODER_STROBES_S_TVALID_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 's_tvalid' field
    -- Field 'axi_debug_ldpc_encoder_strobes.s_tready'
    constant AXI_DEBUG_LDPC_ENCODER_STROBES_S_TREADY_BIT_OFFSET : natural := 1; -- bit offset of the 's_tready' field
    constant AXI_DEBUG_LDPC_ENCODER_STROBES_S_TREADY_BIT_WIDTH : natural := 1; -- bit width of the 's_tready' field
    constant AXI_DEBUG_LDPC_ENCODER_STROBES_S_TREADY_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 's_tready' field
    -- Field 'axi_debug_ldpc_encoder_strobes.m_tvalid'
    constant AXI_DEBUG_LDPC_ENCODER_STROBES_M_TVALID_BIT_OFFSET : natural := 2; -- bit offset of the 'm_tvalid' field
    constant AXI_DEBUG_LDPC_ENCODER_STROBES_M_TVALID_BIT_WIDTH : natural := 1; -- bit width of the 'm_tvalid' field
    constant AXI_DEBUG_LDPC_ENCODER_STROBES_M_TVALID_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'm_tvalid' field
    -- Field 'axi_debug_ldpc_encoder_strobes.m_tready'
    constant AXI_DEBUG_LDPC_ENCODER_STROBES_M_TREADY_BIT_OFFSET : natural := 3; -- bit offset of the 'm_tready' field
    constant AXI_DEBUG_LDPC_ENCODER_STROBES_M_TREADY_BIT_WIDTH : natural := 1; -- bit width of the 'm_tready' field
    constant AXI_DEBUG_LDPC_ENCODER_STROBES_M_TREADY_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'm_tready' field

    -- Register 'axi_debug_bit_interleaver_cfg'
    constant AXI_DEBUG_BIT_INTERLEAVER_CFG_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001100"); -- address offset of the 'axi_debug_bit_interleaver_cfg' register
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

    -- Register 'axi_debug_bit_interleaver_frame_count'
    constant AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001104"); -- address offset of the 'axi_debug_bit_interleaver_frame_count' register
    -- Field 'axi_debug_bit_interleaver_frame_count.value'
    constant AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BIT_INTERLEAVER_FRAME_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_bit_interleaver_last_frame_length'
    constant AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001108"); -- address offset of the 'axi_debug_bit_interleaver_last_frame_length' register
    -- Field 'axi_debug_bit_interleaver_last_frame_length.value'
    constant AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BIT_INTERLEAVER_LAST_FRAME_LENGTH_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_bit_interleaver_min_max_frame_length'
    constant AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000110C"); -- address offset of the 'axi_debug_bit_interleaver_min_max_frame_length' register
    -- Field 'axi_debug_bit_interleaver_min_max_frame_length.min_frame_length'
    constant AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET : natural := 0; -- bit offset of the 'min_frame_length' field
    constant AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'min_frame_length' field
    constant AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'min_frame_length' field
    -- Field 'axi_debug_bit_interleaver_min_max_frame_length.max_frame_length'
    constant AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET : natural := 16; -- bit offset of the 'max_frame_length' field
    constant AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'max_frame_length' field
    constant AXI_DEBUG_BIT_INTERLEAVER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET : std_logic_vector(31 downto 16) := std_logic_vector'("0000000000000000"); -- reset value of the 'max_frame_length' field

    -- Register 'axi_debug_bit_interleaver_word_count'
    constant AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001110"); -- address offset of the 'axi_debug_bit_interleaver_word_count' register
    -- Field 'axi_debug_bit_interleaver_word_count.value'
    constant AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_BIT_INTERLEAVER_WORD_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_bit_interleaver_strobes'
    constant AXI_DEBUG_BIT_INTERLEAVER_STROBES_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001114"); -- address offset of the 'axi_debug_bit_interleaver_strobes' register
    -- Field 'axi_debug_bit_interleaver_strobes.s_tvalid'
    constant AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TVALID_BIT_OFFSET : natural := 0; -- bit offset of the 's_tvalid' field
    constant AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TVALID_BIT_WIDTH : natural := 1; -- bit width of the 's_tvalid' field
    constant AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TVALID_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 's_tvalid' field
    -- Field 'axi_debug_bit_interleaver_strobes.s_tready'
    constant AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TREADY_BIT_OFFSET : natural := 1; -- bit offset of the 's_tready' field
    constant AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TREADY_BIT_WIDTH : natural := 1; -- bit width of the 's_tready' field
    constant AXI_DEBUG_BIT_INTERLEAVER_STROBES_S_TREADY_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 's_tready' field
    -- Field 'axi_debug_bit_interleaver_strobes.m_tvalid'
    constant AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TVALID_BIT_OFFSET : natural := 2; -- bit offset of the 'm_tvalid' field
    constant AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TVALID_BIT_WIDTH : natural := 1; -- bit width of the 'm_tvalid' field
    constant AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TVALID_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'm_tvalid' field
    -- Field 'axi_debug_bit_interleaver_strobes.m_tready'
    constant AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TREADY_BIT_OFFSET : natural := 3; -- bit offset of the 'm_tready' field
    constant AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TREADY_BIT_WIDTH : natural := 1; -- bit width of the 'm_tready' field
    constant AXI_DEBUG_BIT_INTERLEAVER_STROBES_M_TREADY_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'm_tready' field

    -- Register 'axi_debug_constellation_mapper_cfg'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_CFG_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001200"); -- address offset of the 'axi_debug_constellation_mapper_cfg' register
    -- Field 'axi_debug_constellation_mapper_cfg.block_data'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_CFG_BLOCK_DATA_BIT_OFFSET : natural := 0; -- bit offset of the 'block_data' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_CFG_BLOCK_DATA_BIT_WIDTH : natural := 1; -- bit width of the 'block_data' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_CFG_BLOCK_DATA_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'block_data' field
    -- Field 'axi_debug_constellation_mapper_cfg.allow_word'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_WORD_BIT_OFFSET : natural := 1; -- bit offset of the 'allow_word' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_WORD_BIT_WIDTH : natural := 1; -- bit width of the 'allow_word' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_WORD_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 'allow_word' field
    -- Field 'axi_debug_constellation_mapper_cfg.allow_frame'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_FRAME_BIT_OFFSET : natural := 2; -- bit offset of the 'allow_frame' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_FRAME_BIT_WIDTH : natural := 1; -- bit width of the 'allow_frame' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_CFG_ALLOW_FRAME_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'allow_frame' field

    -- Register 'axi_debug_constellation_mapper_frame_count'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_FRAME_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001204"); -- address offset of the 'axi_debug_constellation_mapper_frame_count' register
    -- Field 'axi_debug_constellation_mapper_frame_count.value'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_FRAME_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_FRAME_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_FRAME_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_constellation_mapper_last_frame_length'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_LAST_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001208"); -- address offset of the 'axi_debug_constellation_mapper_last_frame_length' register
    -- Field 'axi_debug_constellation_mapper_last_frame_length.value'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_LAST_FRAME_LENGTH_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_constellation_mapper_min_max_frame_length'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000120C"); -- address offset of the 'axi_debug_constellation_mapper_min_max_frame_length' register
    -- Field 'axi_debug_constellation_mapper_min_max_frame_length.min_frame_length'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET : natural := 0; -- bit offset of the 'min_frame_length' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'min_frame_length' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'min_frame_length' field
    -- Field 'axi_debug_constellation_mapper_min_max_frame_length.max_frame_length'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET : natural := 16; -- bit offset of the 'max_frame_length' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'max_frame_length' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET : std_logic_vector(31 downto 16) := std_logic_vector'("0000000000000000"); -- reset value of the 'max_frame_length' field

    -- Register 'axi_debug_constellation_mapper_word_count'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_WORD_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001210"); -- address offset of the 'axi_debug_constellation_mapper_word_count' register
    -- Field 'axi_debug_constellation_mapper_word_count.value'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_WORD_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_WORD_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_WORD_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_constellation_mapper_strobes'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001214"); -- address offset of the 'axi_debug_constellation_mapper_strobes' register
    -- Field 'axi_debug_constellation_mapper_strobes.s_tvalid'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_S_TVALID_BIT_OFFSET : natural := 0; -- bit offset of the 's_tvalid' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_S_TVALID_BIT_WIDTH : natural := 1; -- bit width of the 's_tvalid' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_S_TVALID_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 's_tvalid' field
    -- Field 'axi_debug_constellation_mapper_strobes.s_tready'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_S_TREADY_BIT_OFFSET : natural := 1; -- bit offset of the 's_tready' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_S_TREADY_BIT_WIDTH : natural := 1; -- bit width of the 's_tready' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_S_TREADY_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 's_tready' field
    -- Field 'axi_debug_constellation_mapper_strobes.m_tvalid'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_M_TVALID_BIT_OFFSET : natural := 2; -- bit offset of the 'm_tvalid' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_M_TVALID_BIT_WIDTH : natural := 1; -- bit width of the 'm_tvalid' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_M_TVALID_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'm_tvalid' field
    -- Field 'axi_debug_constellation_mapper_strobes.m_tready'
    constant AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_M_TREADY_BIT_OFFSET : natural := 3; -- bit offset of the 'm_tready' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_M_TREADY_BIT_WIDTH : natural := 1; -- bit width of the 'm_tready' field
    constant AXI_DEBUG_CONSTELLATION_MAPPER_STROBES_M_TREADY_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'm_tready' field

    -- Register 'axi_debug_plframe_cfg'
    constant AXI_DEBUG_PLFRAME_CFG_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001300"); -- address offset of the 'axi_debug_plframe_cfg' register
    -- Field 'axi_debug_plframe_cfg.block_data'
    constant AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_BIT_OFFSET : natural := 0; -- bit offset of the 'block_data' field
    constant AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_BIT_WIDTH : natural := 1; -- bit width of the 'block_data' field
    constant AXI_DEBUG_PLFRAME_CFG_BLOCK_DATA_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 'block_data' field
    -- Field 'axi_debug_plframe_cfg.allow_word'
    constant AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_BIT_OFFSET : natural := 1; -- bit offset of the 'allow_word' field
    constant AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_BIT_WIDTH : natural := 1; -- bit width of the 'allow_word' field
    constant AXI_DEBUG_PLFRAME_CFG_ALLOW_WORD_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 'allow_word' field
    -- Field 'axi_debug_plframe_cfg.allow_frame'
    constant AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_BIT_OFFSET : natural := 2; -- bit offset of the 'allow_frame' field
    constant AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_BIT_WIDTH : natural := 1; -- bit width of the 'allow_frame' field
    constant AXI_DEBUG_PLFRAME_CFG_ALLOW_FRAME_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'allow_frame' field

    -- Register 'axi_debug_plframe_frame_count'
    constant AXI_DEBUG_PLFRAME_FRAME_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001304"); -- address offset of the 'axi_debug_plframe_frame_count' register
    -- Field 'axi_debug_plframe_frame_count.value'
    constant AXI_DEBUG_PLFRAME_FRAME_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_PLFRAME_FRAME_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_PLFRAME_FRAME_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_plframe_last_frame_length'
    constant AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001308"); -- address offset of the 'axi_debug_plframe_last_frame_length' register
    -- Field 'axi_debug_plframe_last_frame_length.value'
    constant AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_PLFRAME_LAST_FRAME_LENGTH_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_plframe_min_max_frame_length'
    constant AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_OFFSET : unsigned(31 downto 0) := unsigned'(x"0000130C"); -- address offset of the 'axi_debug_plframe_min_max_frame_length' register
    -- Field 'axi_debug_plframe_min_max_frame_length.min_frame_length'
    constant AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_OFFSET : natural := 0; -- bit offset of the 'min_frame_length' field
    constant AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'min_frame_length' field
    constant AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MIN_FRAME_LENGTH_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'min_frame_length' field
    -- Field 'axi_debug_plframe_min_max_frame_length.max_frame_length'
    constant AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_OFFSET : natural := 16; -- bit offset of the 'max_frame_length' field
    constant AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_BIT_WIDTH : natural := 16; -- bit width of the 'max_frame_length' field
    constant AXI_DEBUG_PLFRAME_MIN_MAX_FRAME_LENGTH_MAX_FRAME_LENGTH_RESET : std_logic_vector(31 downto 16) := std_logic_vector'("0000000000000000"); -- reset value of the 'max_frame_length' field

    -- Register 'axi_debug_plframe_word_count'
    constant AXI_DEBUG_PLFRAME_WORD_COUNT_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001310"); -- address offset of the 'axi_debug_plframe_word_count' register
    -- Field 'axi_debug_plframe_word_count.value'
    constant AXI_DEBUG_PLFRAME_WORD_COUNT_VALUE_BIT_OFFSET : natural := 0; -- bit offset of the 'value' field
    constant AXI_DEBUG_PLFRAME_WORD_COUNT_VALUE_BIT_WIDTH : natural := 16; -- bit width of the 'value' field
    constant AXI_DEBUG_PLFRAME_WORD_COUNT_VALUE_RESET : std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000000"); -- reset value of the 'value' field

    -- Register 'axi_debug_plframe_strobes'
    constant AXI_DEBUG_PLFRAME_STROBES_OFFSET : unsigned(31 downto 0) := unsigned'(x"00001314"); -- address offset of the 'axi_debug_plframe_strobes' register
    -- Field 'axi_debug_plframe_strobes.s_tvalid'
    constant AXI_DEBUG_PLFRAME_STROBES_S_TVALID_BIT_OFFSET : natural := 0; -- bit offset of the 's_tvalid' field
    constant AXI_DEBUG_PLFRAME_STROBES_S_TVALID_BIT_WIDTH : natural := 1; -- bit width of the 's_tvalid' field
    constant AXI_DEBUG_PLFRAME_STROBES_S_TVALID_RESET : std_logic_vector(0 downto 0) := std_logic_vector'("0"); -- reset value of the 's_tvalid' field
    -- Field 'axi_debug_plframe_strobes.s_tready'
    constant AXI_DEBUG_PLFRAME_STROBES_S_TREADY_BIT_OFFSET : natural := 1; -- bit offset of the 's_tready' field
    constant AXI_DEBUG_PLFRAME_STROBES_S_TREADY_BIT_WIDTH : natural := 1; -- bit width of the 's_tready' field
    constant AXI_DEBUG_PLFRAME_STROBES_S_TREADY_RESET : std_logic_vector(1 downto 1) := std_logic_vector'("0"); -- reset value of the 's_tready' field
    -- Field 'axi_debug_plframe_strobes.m_tvalid'
    constant AXI_DEBUG_PLFRAME_STROBES_M_TVALID_BIT_OFFSET : natural := 2; -- bit offset of the 'm_tvalid' field
    constant AXI_DEBUG_PLFRAME_STROBES_M_TVALID_BIT_WIDTH : natural := 1; -- bit width of the 'm_tvalid' field
    constant AXI_DEBUG_PLFRAME_STROBES_M_TVALID_RESET : std_logic_vector(2 downto 2) := std_logic_vector'("0"); -- reset value of the 'm_tvalid' field
    -- Field 'axi_debug_plframe_strobes.m_tready'
    constant AXI_DEBUG_PLFRAME_STROBES_M_TREADY_BIT_OFFSET : natural := 3; -- bit offset of the 'm_tready' field
    constant AXI_DEBUG_PLFRAME_STROBES_M_TREADY_BIT_WIDTH : natural := 1; -- bit width of the 'm_tready' field
    constant AXI_DEBUG_PLFRAME_STROBES_M_TREADY_RESET : std_logic_vector(3 downto 3) := std_logic_vector'("0"); -- reset value of the 'm_tready' field

end dvbs2_encoder_regs_pkg;
