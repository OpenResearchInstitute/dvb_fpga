`timescale 1 ns / 1 ps

module multiply_accumulate_behavioural #
(
    // signal width definitions
    parameter integer DATA_WIDTH = 16,
    parameter integer COEFFICIENT_WIDTH = 16,
    parameter integer CARRY_WIDTH = 48,
    parameter integer OUTPUT_OFFSET = 0,

    // operation definitions
    parameter integer DATA_IN_NUMBER_REGS = 1,
    parameter integer COEFFICIENTS_NUMBER_REGS = 1,
    parameter integer USE_SILICON_CARRY = 1,
    parameter integer FIRST_IN_CHAIN = 0,
    parameter integer LAST_IN_CHAIN = 0,

    parameter integer CARRY_NUMBER_REGS = 1
)
(
    // global signals
    input wire                          clock,
    input wire                          reset,

    // data signals
    input wire [DATA_WIDTH-1:0]         data_in,
    input wire [COEFFICIENT_WIDTH-1:0]  coefficient_in,
    input wire [CARRY_WIDTH-1:0]        carry_in,
    output wire [CARRY_WIDTH-1:0]       carry_out,
    output wire [DATA_WIDTH-1:0]        data_carry,
    output wire [DATA_WIDTH-1:0]        data_out,

    // control signals
    input wire                          ce_calculate,
    input wire                          ce_coefficient,
    input wire                          reset_coefficient,
    input wire [6:0]                    op_mode,
    input wire [4:0]                    in_mode
);

    // register to store the coefficient
    reg [COEFFICIENT_WIDTH-1:0]     coefficient_register;

    // store the coefficient
    always @(posedge clock) begin
        if (reset_coefficient) begin
            coefficient_register <= 0;
        end
        else begin
            if (reset_coefficient) begin
                coefficient_register <= 0;
            end
            else if (ce_coefficient) begin
                coefficient_register <= coefficient_in;
            end
            else begin
                coefficient_register <= coefficient_register;
            end
        end
    end

    // register to store the data
    reg [DATA_WIDTH-1:0]        data_in_register[DATA_IN_NUMBER_REGS-1:0];
    wire [DATA_WIDTH-1:0]       data_in_internal;

    integer i_data;
    always @(posedge clock) begin
        if (reset) begin
            for (i_data = 0; i_data < DATA_IN_NUMBER_REGS; i_data=i_data+1) begin
                data_in_register[i_data] <= 0;
            end
        end
        else begin
            if (ce_calculate) begin
                data_in_register[0] <= data_in;
                for (i_data = 1; i_data < DATA_IN_NUMBER_REGS; i_data=i_data+1) begin
                    data_in_register[i_data] <= data_in_register[i_data-1];
                end
            end
        end
    end

    // tap off the end of the shift register delay line and use it internally and pass it outside
    assign data_in_internal = data_in_register[DATA_IN_NUMBER_REGS-1];
    assign data_carry = data_in_internal;


    // register internal value before MAC operation
    reg [DATA_WIDTH-1:0]       data_in_internal_delay;
    always @(posedge clock) begin
        if (reset) begin
            data_in_internal_delay <= 0;
        end
        else begin
            if (ce_calculate) begin
                data_in_internal_delay <= data_in_internal;
            end
        end
    end


    // perform the core multiply and accumalate operation
    reg [CARRY_WIDTH-1:0]    mac_value;
    always @(posedge clock) begin
        if (reset) begin
            mac_value <= 0;
        end
        else begin
            if (ce_calculate) begin
                mac_value <= $signed(coefficient_register) * $signed(data_in_internal_delay) + $signed(carry_in);
            end
        end
    end


    // output the trimmed and full precision outputs
    assign carry_out = mac_value;
    assign data_out = mac_value[2*DATA_WIDTH-2-1:DATA_WIDTH-2];


    // used to create the GTKwave dump file
    `ifdef COCOTB_SIM
            initial begin
            $dumpfile ("waveform.vcd");
            $dumpvars (0, multiply_accumulate_behavioural);
            #1;
        end
    `endif

endmodule
