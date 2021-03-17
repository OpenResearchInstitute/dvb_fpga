// -----------------------------------------------------------------------------
// 'dvbs2_tx_wrapper_regmap' Register Definitions
// Revision: 41
// -----------------------------------------------------------------------------
// Generated on 2021-03-16 at 19:31 (UTC) by airhdl version 2021.03.1
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

#ifndef DVBS2_TX_WRAPPER_REGMAP_REGS_H
#define DVBS2_TX_WRAPPER_REGMAP_REGS_H

/* Revision number of the 'dvbs2_tx_wrapper_regmap' register map */
#define DVBS2_TX_WRAPPER_REGMAP_REVISION 41

/* Default base address of the 'dvbs2_tx_wrapper_regmap' register map */
#define DVBS2_TX_WRAPPER_REGMAP_DEFAULT_BASEADDR 0x00000000

/* Register 'config' */
#define CONFIG_OFFSET 0x00000000 /* address offset of the 'config' register */

/* Field  'config.enable_dummy_frames' */
#define CONFIG_ENABLE_DUMMY_FRAMES_BIT_OFFSET 0 /* bit offset of the 'enable_dummy_frames' field */
#define CONFIG_ENABLE_DUMMY_FRAMES_BIT_WIDTH 1 /* bit width of the 'enable_dummy_frames' field */
#define CONFIG_ENABLE_DUMMY_FRAMES_BIT_MASK 0x00000001 /* bit mask of the 'enable_dummy_frames' field */
#define CONFIG_ENABLE_DUMMY_FRAMES_RESET 0x0 /* reset value of the 'enable_dummy_frames' field */

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

/* Register 'frames_in_transit' */
#define FRAMES_IN_TRANSIT_OFFSET 0x00000008 /* address offset of the 'frames_in_transit' register */

/* Field  'frames_in_transit.value' */
#define FRAMES_IN_TRANSIT_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define FRAMES_IN_TRANSIT_VALUE_BIT_WIDTH 8 /* bit width of the 'value' field */
#define FRAMES_IN_TRANSIT_VALUE_BIT_MASK 0x000000FF /* bit mask of the 'value' field */
#define FRAMES_IN_TRANSIT_VALUE_RESET 0x0 /* reset value of the 'value' field */

/* Register 'bit_mapper_ram' */
#define BIT_MAPPER_RAM_OFFSET 0x0000000C /* address offset of the 'bit_mapper_ram' register */
#define BIT_MAPPER_RAM_DEPTH 240 /* depth of the 'bit_mapper_ram' memory, in elements */

/* Field  'bit_mapper_ram.data' */
#define BIT_MAPPER_RAM_DATA_BIT_OFFSET 0 /* bit offset of the 'data' field */
#define BIT_MAPPER_RAM_DATA_BIT_WIDTH 32 /* bit width of the 'data' field */
#define BIT_MAPPER_RAM_DATA_BIT_MASK 0xFFFFFFFF /* bit mask of the 'data' field */
#define BIT_MAPPER_RAM_DATA_RESET 0x0 /* reset value of the 'data' field */

/* Register 'polyphase_filter_coefficients' */
#define POLYPHASE_FILTER_COEFFICIENTS_OFFSET 0x000003CC /* address offset of the 'polyphase_filter_coefficients' register */
#define POLYPHASE_FILTER_COEFFICIENTS_DEPTH 512 /* depth of the 'polyphase_filter_coefficients' memory, in elements */

/* Field  'polyphase_filter_coefficients.value' */
#define POLYPHASE_FILTER_COEFFICIENTS_VALUE_BIT_OFFSET 0 /* bit offset of the 'value' field */
#define POLYPHASE_FILTER_COEFFICIENTS_VALUE_BIT_WIDTH 32 /* bit width of the 'value' field */
#define POLYPHASE_FILTER_COEFFICIENTS_VALUE_BIT_MASK 0xFFFFFFFF /* bit mask of the 'value' field */
#define POLYPHASE_FILTER_COEFFICIENTS_VALUE_RESET 0x0 /* reset value of the 'value' field */

#endif  /* DVBS2_TX_WRAPPER_REGMAP_REGS_H */
