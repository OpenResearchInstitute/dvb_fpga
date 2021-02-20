`timescale 1 ns / 1 ps

module fir_filter #
(
	parameter integer NUMBER_TAPS 			= 16,
	parameter integer DATA_IN_WIDTH 		= 16,
	parameter integer COEFFICIENT_WIDTH 	= 16,
	parameter integer DATA_OUT_WIDTH 		= 16,
	parameter integer FIR_OFFSET 			= -2,
	parameter integer EMPTY_ON_TLAST		= 1
)
(
	// input data interface
	input wire  							data_in_aclk,
	input wire  							data_in_aresetn,
	output wire								data_in_tready,
	input wire 	[DATA_IN_WIDTH-1:0] 		data_in_tdata,
	input wire  							data_in_tlast,
	input wire  							data_in_tvalid,

	// output data interface
	input wire  							data_out_aclk,
	input wire  							data_out_aresetn,
	input wire 								data_out_tready,
	output wire [DATA_OUT_WIDTH-1:0] 		data_out_tdata,
	output wire 							data_out_tlast,
	output wire 							data_out_tvalid,

	// coefficients input interface
	input wire  							coefficients_in_aclk,
	input wire  							coefficients_in_aresetn,
	output wire 							coefficients_in_tready,
	input wire 	[COEFFICIENT_WIDTH-1 : 0]	coefficients_in_tdata,
	input wire  							coefficients_in_tlast,
	input wire  							coefficients_in_tvalid,

	// flags
	output wire								samples_remaining
);
	// internal parameters
	localparam INPUT_DELAY 	= 0;
	localparam CARRY_LENGTH = INPUT_DELAY+NUMBER_TAPS;
	localparam CARRY_WIDTH 	= 48;
	localparam MAC_DELAY 	= 2;
	localparam FILTER_DELAY	= NUMBER_TAPS+MAC_DELAY;
	localparam TLAST_DELAY	= FILTER_DELAY+NUMBER_TAPS-1;

	// global signals
	wire 							clock;
	wire 							reset;
	wire 							empty_remaining;

	wire [DATA_IN_WIDTH-1:0]		filter_data_in;
	wire [DATA_OUT_WIDTH-1:0]		data_out;

	// propagating signals
	reg [CARRY_LENGTH-1:0] 			ce_carry;
	reg [CARRY_LENGTH-1:0] 			tlast_carry;
	wire [DATA_IN_WIDTH-1:0] 		data_carry [CARRY_LENGTH-1:0];
	wire [CARRY_WIDTH-1:0] 			calc_carry [CARRY_LENGTH-1:0];

	// coeffient signals
	wire 							coefficient_reset;
	wire [COEFFICIENT_WIDTH-1:0]	coefficient_in;
	reg [$clog2(NUMBER_TAPS)-1:0]	coefficient_index;
	reg [NUMBER_TAPS-1:0] 			coefficient_load_en;

	// filter delay lines
	reg [FILTER_DELAY-1:0]			tvalid_delay_line;
	reg [TLAST_DELAY-1:0]			tlast_delay_line;


	reg 							tlast_latch;
	reg [$clog2(TLAST_DELAY)-1:0]	tlast_clear_count;




	// map the input data clock
	assign clock = data_in_aclk;

	// reset either from external assertion or output of frame complete
	assign reset = !data_in_aresetn | (data_out_tlast & data_out_tvalid & data_out_tready);

	// pass the output ready signal to the input
	assign data_in_tready = data_out_tready;

	// map the output
	assign data_out_tdata = data_out;

	// combine the enable signals
	assign empty_remaining = |tlast_delay_line & data_out_tready;

	// signal that there is still samples in the delay line
	assign samples_remaining = |tvalid_delay_line;

	// output is valid as long as the previous clock enable of the last
	// DSP48E1 was high
	assign data_out_tvalid = tvalid_delay_line[FILTER_DELAY-1];

	// pass through the tlast signal
	assign data_out_tlast = tlast_delay_line[TLAST_DELAY-1];

	// create delay lines for the valid and last signals
	//  TODO I'm not happy with this yet as it will not clear if the number of valid inputs is 
	//       less than the delay line width.  Ideally this should be fixed
	assign filter_data_in = tlast_latch ? 0 : data_in_tdata;


	// latch the last signal once it's been read in
	always @(posedge clock) begin
		if (reset) begin
			tlast_latch <= 0;
		end
		else begin
			if (data_in_tvalid & data_in_tready) begin
				tlast_latch <= tlast_latch | data_in_tlast;
			end
			else begin
				tlast_latch <= tlast_latch;
			end
		end
	end


	// operate the delay line of the valid and last signals
	always @(posedge clock) begin
		if (reset) begin
			tvalid_delay_line <= 0;
			tlast_delay_line <= 0;
			tlast_clear_count <= 0;
		end
		else begin

			// we need to clear out remaining samples within the delay line			
			if (tlast_latch & empty_remaining) begin
				tlast_clear_count <= tlast_clear_count + 1;
				tvalid_delay_line <= {tvalid_delay_line[FILTER_DELAY-2:0], 1'b1};
				tlast_delay_line <= {tlast_delay_line[TLAST_DELAY-2:0], data_in_tlast};
			end

			// a valid input sample has been provided or we're clearing the output
			//  so increment the delay line
			else if ((data_in_tready & data_in_tvalid) | empty_remaining) begin
				tlast_clear_count <= tlast_clear_count;
				tvalid_delay_line <= {tvalid_delay_line[FILTER_DELAY-2:0], data_in_tvalid};
				tlast_delay_line <= {tlast_delay_line[TLAST_DELAY-2:0], data_in_tlast};
			end

			// register the signal
			else begin
				tlast_clear_count <= tlast_clear_count;
				tvalid_delay_line <= tvalid_delay_line;
				tlast_delay_line <= tlast_delay_line;
			end
		end
	end



	//// create the coefficient loading signals

	// TODO: For now assume that coefficients AXI interface is clocked
	// 		 at the same rate as the DSP48E1.  This will need to change
	//		 for serial/parallel implementation where we will want to 
	//		 clock the DSP48E1 at a much higher rate.  Need to figure out
	//		 the best way to clock in at a lower rate possibly with the
	//		 interaction between the coefficient bus clock and register A
	//		 clock enable. 

	// allow the AXI interface to reset the loaded coefficients
	assign coefficient_reset = !coefficients_in_aresetn; 

	// coefficients always ready - maybe not a good idea?
	assign coefficients_in_tready = 1;

	// map the input coefficients to the instance
	assign coefficient_in = coefficients_in_tdata[COEFFICIENT_WIDTH-1:0];

	// increment the coefficient index if a coefficient has been loaded
	always @(posedge clock) begin
		if (coefficient_reset) begin
			coefficient_index <= 0;
		end
		else begin
			if (coefficients_in_tvalid & coefficients_in_tready) begin
				coefficient_index <= coefficient_index + 1;
			end
		end
	end

	// create coefficient load enable signals
	integer i=0;
	always @* begin
		for (i=0; i < NUMBER_TAPS; i=i+1) begin
			coefficient_load_en[i] <= (coefficient_index == i & coefficients_in_tvalid) ? 1: 0;
		end
	end

	// shift the clock enable signal
	always @(posedge clock) begin
		if(reset) begin
			ce_carry <= 0;
			tlast_carry <= 0;
		end
		else begin
			// only propagate if the output is ready to receive data
			if(data_out_tready) begin

				// shift the signals along
				ce_carry <= {ce_carry[CARRY_LENGTH-2:0], data_in_tvalid};
				tlast_carry <= {tlast_carry[CARRY_LENGTH-2:0], data_in_tlast};
			end
		end
	end




	// create the DSP chain
	genvar index;
	generate
	for (index=0; index < NUMBER_TAPS; index=index+1)
		begin : macs

			if (index==0) begin
				multiply_accumulate_behavioural #(
					.DATA_WIDTH(DATA_IN_WIDTH),
					.COEFFICIENT_WIDTH(COEFFICIENT_WIDTH),
					.CARRY_WIDTH(CARRY_WIDTH),
					.OUTPUT_OFFSET(FIR_OFFSET),
					.DATA_IN_NUMBER_REGS(1),
					.COEFFICIENTS_NUMBER_REGS(2),
					.USE_SILICON_CARRY(1),
					.FIRST_IN_CHAIN(1),
					.LAST_IN_CHAIN(0)
				) mac_inst (
					.clock(clock),
					.reset(reset),
					.data_in(filter_data_in),
					.coefficient_in(coefficient_in),
					.carry_in({CARRY_WIDTH{1'b0}}),
					.carry_out(calc_carry[index]),
					.data_carry(data_carry[index]),
					.data_out(),
					.ce_calculate((data_in_tvalid & data_in_tready & data_in_tvalid) | empty_remaining),
					.ce_coefficient(coefficient_load_en[index]),
					.reset_coefficient(coefficient_reset),
					.op_mode(7'b0000101),
					.in_mode(5'b00001)
				);
			end
			else if (index==NUMBER_TAPS-1) begin
				multiply_accumulate_behavioural #(
					.DATA_WIDTH(DATA_IN_WIDTH),
					.COEFFICIENT_WIDTH(COEFFICIENT_WIDTH),
					.CARRY_WIDTH(CARRY_WIDTH),
					.OUTPUT_OFFSET(FIR_OFFSET),
					.DATA_IN_NUMBER_REGS(2),
					.COEFFICIENTS_NUMBER_REGS(2),
					.USE_SILICON_CARRY(1),
					.FIRST_IN_CHAIN(0),
					.LAST_IN_CHAIN(1)
				) mac_inst (
					.clock(clock),
					.reset(reset),
					.data_in(data_carry[index-1]),
					.coefficient_in(coefficient_in),
					.carry_in(calc_carry[index-1]),
					.carry_out(),
					.data_carry(data_carry[index]),
					.data_out(data_out),
					.ce_calculate((tvalid_delay_line[index-1] & data_in_tready & data_in_tvalid) | empty_remaining),
					.ce_coefficient(coefficient_load_en[index]),
					.reset_coefficient(coefficient_reset),
					.op_mode(7'b0010101),
					.in_mode(5'b00001)
				);
			end
			else begin
				multiply_accumulate_behavioural #(
					.DATA_WIDTH(DATA_IN_WIDTH),
					.COEFFICIENT_WIDTH(COEFFICIENT_WIDTH),
					.CARRY_WIDTH(CARRY_WIDTH),
					.OUTPUT_OFFSET(FIR_OFFSET),
					.DATA_IN_NUMBER_REGS(2),
					.COEFFICIENTS_NUMBER_REGS(2),
					.USE_SILICON_CARRY(1),
					.FIRST_IN_CHAIN(0),
					.LAST_IN_CHAIN(0)
				) mac_inst (
					.clock(clock),
					.reset(reset),
					.data_in(data_carry[index-1]),
					.coefficient_in(coefficient_in),
					.carry_in(calc_carry[index-1]),
					.carry_out(calc_carry[index]),
					.data_carry(data_carry[index]),
					.data_out(),
					.ce_calculate((tvalid_delay_line[index-1] & data_in_tready & data_in_tvalid) | empty_remaining),
					.ce_coefficient(coefficient_load_en[index]),
					.reset_coefficient(coefficient_reset),
					.op_mode(7'b0010101),
					.in_mode(5'b00001)
				);
			end
		end
	endgenerate


	// used to create the GTKwave dump file
	`ifdef COCOTB_SIM
			initial begin
			$dumpfile ("waveform.vcd");
			$dumpvars (0, fir_filter);
			#1;
		end
	`endif

endmodule
