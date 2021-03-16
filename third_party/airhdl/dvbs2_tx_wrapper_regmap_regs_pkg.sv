// -----------------------------------------------------------------------------
// 'dvbs2_tx_wrapper_regmap' Register Definitions
// Revision: 39
// -----------------------------------------------------------------------------
// Generated on 2021-03-07 at 16:11 (UTC) by airhdl version 2021.02.1
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
    } user2regs_t;
    
    // User-logic ports (from register file to user-logic)
    typedef struct {
        logic config_strobe; // Strobe logic for register 'config' (pulsed when the register is written from the bus)
        logic [0:0] config_enable_dummy_frames; // Value of register 'config', field 'enable_dummy_frames'
        logic ldpc_fifo_status_strobe; // Strobe logic for register 'ldpc_fifo_status' (pulsed when the register is read from the bus)
        logic frames_in_transit_strobe; // Strobe logic for register 'frames_in_transit' (pulsed when the register is read from the bus)
        logic [7:0] bit_mapper_ram_addr; // read/write address for memory 'bit_mapper_ram'
        logic [31:0] bit_mapper_ram_wdata; // write data for memory 'bit_mapper_ram'         
        logic [3:0] bit_mapper_ram_wen; // byte-wide write-enable for memory 'bit_mapper_ram'
        logic [6:0] polyphase_filter_coefficients_addr; // read/write address for memory 'polyphase_filter_coefficients'
        logic [31:0] polyphase_filter_coefficients_wdata; // write data for memory 'polyphase_filter_coefficients'         
        logic [3:0] polyphase_filter_coefficients_wen; // byte-wide write-enable for memory 'polyphase_filter_coefficients'
    } regs2user_t;

    // Revision number of the 'dvbs2_tx_wrapper_regmap' register map
    localparam DVBS2_TX_WRAPPER_REGMAP_REVISION = 39;

    // Default base address of the 'dvbs2_tx_wrapper_regmap' register map 
    localparam logic [31:0] DVBS2_TX_WRAPPER_REGMAP_DEFAULT_BASEADDR = 32'h00000000;
    
    // Register 'config'
    localparam logic [31:0] CONFIG_OFFSET = 32'h00000000; // address offset of the 'config' register
    // Field 'config.enable_dummy_frames'
    localparam CONFIG_ENABLE_DUMMY_FRAMES_BIT_OFFSET = 0; // bit offset of the 'enable_dummy_frames' field
    localparam CONFIG_ENABLE_DUMMY_FRAMES_BIT_WIDTH = 1; // bit width of the 'enable_dummy_frames' field
    localparam logic [0:0] CONFIG_ENABLE_DUMMY_FRAMES_RESET = 1'b0; // reset value of the 'enable_dummy_frames' field
    
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
    localparam POLYPHASE_FILTER_COEFFICIENTS_DEPTH = 128; // depth of the 'polyphase_filter_coefficients' memory, in elements
    localparam POLYPHASE_FILTER_COEFFICIENTS_READ_LATENCY = 1; // read latency of the 'polyphase_filter_coefficients' memory, in clock cycles
    // Field 'polyphase_filter_coefficients.value'
    localparam POLYPHASE_FILTER_COEFFICIENTS_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam POLYPHASE_FILTER_COEFFICIENTS_VALUE_BIT_WIDTH = 32; // bit width of the 'value' field
    localparam logic [31:0] POLYPHASE_FILTER_COEFFICIENTS_VALUE_RESET = 32'b00000000000000000000000000000000; // reset value of the 'value' field

endpackage: dvbs2_tx_wrapper_regmap_regs_pkg
