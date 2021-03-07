/*
    Interpolating polyphase filter.

    Currently only supports interpolation.
*/

`timescale 1 ns / 1 ns

module polyphase_filter #(
    parameter integer NUMBER_TAPS               = 32,
    parameter integer DATA_IN_WIDTH             = 16,
    parameter integer DATA_OUT_WIDTH            = 16,
    parameter integer COEFFICIENT_WIDTH         = 16,
    parameter integer RATE_CHANGE               = 8,
    parameter integer DECIMATE_INTERPOLATE      = 1, // 0 = decimate, 1 = interpolate
    parameter integer C_AXI_ADDR_WIDTH          = 32,
    parameter integer C_AXI_DATA_WIDTH          = 32,
    parameter [0:0]   OPT_SKIDBUFFER            = 1'b0,
    parameter [0:0]   OPT_LOWPOWER              = 0,
    parameter integer ADDRLSB                   = $clog2(C_AXI_DATA_WIDTH)-3
)
(
    // input data interface
    input wire                              data_in_aclk,
    input wire                              data_in_aresetn,
    output wire                             data_in_tready,
    input wire     [DATA_IN_WIDTH-1:0]      data_in_tdata,
    input wire                              data_in_tlast,
    input wire                              data_in_tvalid,

    // output data interface
    input wire                              data_out_aclk,
    input wire                              data_out_aresetn,
    input wire                              data_out_tready,
    output wire [DATA_OUT_WIDTH-1:0]        data_out_tdata,
    output wire                             data_out_tlast,
    output wire                             data_out_tvalid,

    // coeffs input interface
    input  wire                             coeffs_wren,
    input  wire [$clog2(NUMBER_TAPS)-1:0]	coeffs_addr,
    input  wire [COEFFICIENT_WIDTH-1:0]	    coeffs_wdata
);

    // internal parameters
    localparam AXI_WIDTH                    = 32;
    localparam INPUT_DELAY                  = 1;
    localparam SUB_LENGTH                   = NUMBER_TAPS/RATE_CHANGE;
    localparam CARRY_LENGTH                 = SUB_LENGTH + RATE_CHANGE + INPUT_DELAY;
    localparam INTERP_WIDTH                 = $clog2(RATE_CHANGE);
    localparam RATE_COUNT_WIDTH             = $clog2(RATE_CHANGE);
    localparam SUB_COUNT_WIDTH              = $clog2(SUB_LENGTH);
    localparam DATA_CARRY_LENGTH            = RATE_CHANGE+2;
    localparam DATA_REV_CARRY_LENGTH        = RATE_CHANGE+2;
    localparam CALC_CARRY_LENGTH            = RATE_CHANGE;        // there's two delays lacking in the carry path in the DSP48 so need to add them here
    localparam DATA_REV_DELAY_CARRY_LENGTH  = RATE_CHANGE+2;
    localparam OUTPUT_SHIFT                 = $clog2(NUMBER_TAPS)*0;

    // global signals
    wire                                clock;
    wire                                reset;

    // monitor the current phase in the upsampling/downsampling
    reg [$clog2(RATE_CHANGE)-1:0]       phase_counter;


    // FIR filter connection signals
    reg [DATA_IN_WIDTH-1:0]             data_in_tdata_array [RATE_CHANGE-1:0];
    wire [RATE_CHANGE-1:0]              data_in_tready_array;
    reg [RATE_CHANGE-1:0]               data_in_tvalid_array;
    reg [RATE_CHANGE-1:0]               data_in_tlast_array;
    reg                                 data_in_tlast_latched;
    wire [DATA_OUT_WIDTH-1:0]           data_out_tdata_array [RATE_CHANGE-1:0];
    wire [RATE_CHANGE-1:0]              data_out_tready_array;
    wire [RATE_CHANGE-1:0]              data_out_tvalid_array;
    wire [RATE_CHANGE-1:0]              data_out_tlast_array;

    wire [RATE_CHANGE-1:0]              samples_remaining_array;


    // select the highest frequency clock
    assign clock = DECIMATE_INTERPOLATE ? data_out_aclk : data_in_aclk;

    // flip the logic of the reset signal
    assign reset = !data_in_aresetn | (data_out_tlast & data_out_tvalid & data_out_tready);


    ////// Control logic to arrange data into and out of the FIR filter stages

    genvar i;
    generate
        if (DECIMATE_INTERPOLATE == 0) begin

            // DECIMATION IS STILL TO BE IMPLEMENTED

        end
        else begin

            // map signals to each of the filter sections
            for (i = 0; i < RATE_CHANGE; i = i + 1) begin

                // register the input data
                always @(posedge clock) begin
                    if(reset) begin
                        data_in_tdata_array[i] <= 0;
                    end
                    else begin
                        if (data_in_tvalid & data_in_tready) begin
                            data_in_tdata_array[i] = data_in_tdata;
                        end
                        else begin
                            data_in_tdata_array[i] = data_in_tdata_array[i];
                        end
                    end
                end

                // register the input last signal to each filter section
                always @(posedge clock) begin
                    if(reset) begin
                        data_in_tlast_array[i] <= 0;
                    end
                    else begin
                        if (data_in_tvalid & data_in_tready & data_in_tlast) begin
                            data_in_tlast_array[i] <= data_in_tlast;
                        end
                        else begin
                            data_in_tlast_array[i] <= data_in_tlast_array[i];
                        end
                    end
                end
            end

            // form the input ready signal when filter sections are ready and we're at the correct
            // phase
            assign data_in_tready = (|data_in_tready_array) & (phase_counter == (RATE_CHANGE-1));

            // the output ready array depends on the current phase
            assign data_out_tready_array = {RATE_CHANGE{data_out_tready}} & 2**phase_counter;


            // create the data valid signals for each filter
            always @(posedge clock) begin
                if(reset) begin
                    data_in_tvalid_array <= 0;
                end
                else begin

                    // register input valid signals for each filter section
                    if (data_in_tvalid & data_in_tvalid) begin
                        data_in_tvalid_array <= {RATE_CHANGE{data_in_tvalid}};
                    end
                    else begin
                        data_in_tvalid_array <= data_in_tvalid_array;
                    end
                end
            end

            // use a phase counter to control how the polyphase filter moves between
            // each phase
            always @(posedge clock) begin
                if(reset) begin
                    phase_counter <= RATE_CHANGE-1;
                end
                else begin

                    // increment the phase counter if the input is valid, ready and the output is ready or if we're trying to clear
                    //   samples out at the end
                    if ((data_in_tvalid & data_out_tready & (|data_in_tready_array)) | (data_out_tready & data_in_tlast_latched)) begin
                        phase_counter <= (phase_counter + 1) % RATE_CHANGE;
                    end
                    else begin
                        phase_counter <= phase_counter;
                    end

                end
            end

            // map the correct filter output signal to the modules output
            //  depending on the phase counter
            assign data_out_tdata = data_out_tdata_array[(phase_counter-1)%RATE_CHANGE];

            // latch the input last sample signals
            always @(posedge clock) begin
                if(reset) begin
                    data_in_tlast_latched <= 0;
                end
                else begin
                    data_in_tlast_latched <= !data_out_tlast & (data_in_tlast_latched | data_in_tlast);
                end
            end

            // use the last sample signal from the last filter
            assign data_out_tlast = data_out_tlast_array[RATE_CHANGE-1];

            // change which signal is mapped to the output depending of the phase of the filter
            assign data_out_tvalid = data_out_tvalid_array[(phase_counter-1) % RATE_CHANGE] ;
        end
    endgenerate

    wire [$clog2(RATE_CHANGE)-1:0] target_fir = coeffs_addr[$clog2(RATE_CHANGE)-1:0];
    wire [$clog2(SUB_LENGTH)-1:0] fir_addr = coeffs_addr[$clog2(NUMBER_TAPS)-1:$clog2(NUMBER_TAPS)-$clog2(SUB_LENGTH)];


    // create the parallel FIR filters
    genvar dsp_array;
    generate
    for (dsp_array=0; dsp_array < RATE_CHANGE; dsp_array=dsp_array+1)
        begin : fir_filter

            fir_filter #(
                .NUMBER_TAPS       (SUB_LENGTH),
                .DATA_IN_WIDTH     (DATA_IN_WIDTH),
                .COEFFICIENT_WIDTH (COEFFICIENT_WIDTH),
                .DATA_OUT_WIDTH    (DATA_OUT_WIDTH)
            ) fir_filter_inst (
                .data_in_aclk     (data_in_aclk),
                .data_in_aresetn  (data_in_aresetn & !reset),
                .data_in_tready   (data_in_tready_array[dsp_array]),
                .data_in_tdata    (data_in_tdata_array[dsp_array]),
                .data_in_tlast    (data_in_tlast_array[dsp_array]),
                .data_in_tvalid   (data_in_tvalid_array[dsp_array]),
                .data_out_aclk    (data_out_aclk),
                .data_out_aresetn (data_out_aresetn),
                .data_out_tready  (data_out_tready_array[dsp_array]),
                .data_out_tdata   (data_out_tdata_array[dsp_array]),
                .data_out_tlast   (data_out_tlast_array[dsp_array]),
                .data_out_tvalid  (data_out_tvalid_array[dsp_array]),
                //
                .samples_remaining(),
                // Upper bits address the coefficient. Lower bits address FIR instance
                .coeffs_wren      (target_fir == dsp_array ? coeffs_wren : 1'b0),
                .coeffs_addr      (fir_addr),
                .coeffs_wdata     (coeffs_wdata));
        end
    endgenerate



    // used to create the GTKwave dump file
    `ifdef COCOTB_SIM
        initial begin
            $dumpfile ("waveform.vcd");
            $dumpvars (0, polyphase_filter);
            #1;
        end
    `endif

endmodule
