`timescale 1 ns / 1 ps

module multiply_accumulate #
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
	parameter integer LAST_IN_CHAIN = 0
)
(
	// global signals
	input wire  						clock,
	input wire  						reset,

	// data signals
	input wire [DATA_WIDTH-1:0]			data_in,
	input wire [COEFFICIENT_WIDTH-1:0]	coefficient_in,
	input wire [CARRY_WIDTH-1:0]		carry_in,
	output wire [CARRY_WIDTH-1:0]		carry_out,
	output wire [DATA_WIDTH-1:0]		data_carry,
	output wire [DATA_WIDTH-1:0]		data_out,

	// control signals
	input wire							ce_calculate,
	input wire							ce_coefficient,
	input wire							reset_coefficient,
	input wire [6:0]					op_mode,
	input wire [4:0]					in_mode
);

	// DSP48E1 parameters
	localparam integer ACASCREG = 1;
	localparam integer ADREG = 1;
	localparam integer ALUMODEREG = 1;
	localparam integer AREG = 1;
	localparam AUTORESET_PATDET = "NO_RESET";  // {NO_RESET, RESET_MATCH, RESET_NOT_MATCH}
	localparam A_INPUT = "DIRECT";
	localparam integer BCASCREG = 1;
	localparam integer BREG = 1;
	// localparam B_INPUT = "DIRECT";
	localparam B_INPUT = FIRST_IN_CHAIN == 1 ? "DIRECT" : "CASCADE";
	localparam integer CARRYINREG = 1;
	localparam integer CARRYINSELREG = 1;
	localparam integer CREG = 1;
	localparam integer DREG = 1;
	localparam integer INMODEREG = 1;
	localparam integer MREG = 1;
	localparam integer OPMODEREG = 1;
	localparam integer PREG = 1;
	localparam SEL_MASK = "MASK";
	localparam SEL_PATTERN = "PATTERN";
	localparam USE_DPORT = "FALSE";
	localparam USE_MULT = "MULTIPLY";
	localparam USE_PATTERN_DETECT = "NO_PATDET";
	localparam USE_SIMD = "ONE48";
	localparam [47:0] MASK = 48'h3FFFFFFFFFFF;
	localparam [47:0] PATTERN = 48'h000000000000;
	localparam [3:0] IS_ALUMODE_INVERTED = 4'b0;
	localparam [0:0] IS_CARRYIN_INVERTED = 1'b0;
	localparam [0:0] IS_CLK_INVERTED = 1'b0;
	localparam [4:0] IS_INMODE_INVERTED = 5'b0;
	localparam [6:0] IS_OPMODE_INVERTED = 7'b0;
	localparam integer PCIN_WIDTH = 48;

	localparam integer A_WIDTH = 30;
	localparam integer B_WIDTH = 18;
	localparam integer C_WIDTH = 48;
	localparam integer D_WIDTH = 25;

	// TODO 

	// DSP48E1 signals
	wire [29:0] 	ACOUT;
	wire [17:0] 	BCOUT;
	wire 			CARRYCASCOUT;
	wire [3:0] 		CARRYOUT;
	wire 			MULTSIGNOUT;
	wire 			OVERFLOW;
	wire [47:0] 	P;
	wire 			PATTERNBDETECT;
	wire 			PATTERNDETECT;
	wire [47:0] 	PCOUT;
	wire 			UNDERFLOW;
	wire [29:0] 	A;
	wire [29:0] 	ACIN;
	wire [3:0] 		ALUMODE;
	wire [17:0] 	B;
	wire [17:0] 	BCIN;
	wire [47:0] 	C;
	wire 			CARRYCASCIN;
	wire 			CARRYIN;
	wire [2:0] 		CARRYINSEL;
	wire 			CEA1;
	wire 			CEA2;
	wire 			CEAD;
	wire 			CEALUMODE;
	wire 			CEB1;
	wire 			CEB2;
	wire 			CEC;
	wire 			CECARRYIN;
	wire 			CECTRL;
	wire 			CED;
	wire 			CEINMODE;
	wire 			CEM;
	wire 			CEP;
	wire 			CLK;
	wire [24:0] 	D;
	wire 			MULTSIGNIN;
	wire [6:0] 		OPMODE;
	wire [47:0] 	PCIN;
	wire 			RSTA;
	wire 			RSTALLCARRYIN;
	wire 			RSTALUMODE;
	wire 			RSTB;
	wire 			RSTC;
	wire 			RSTCTRL;
	wire 			RSTD;
	wire 			RSTINMODE;
	wire 			RSTM;
	wire 			RSTP;

	// connect the clock
	assign CLK = clock;

	// connect the resets
	// assign RSTA = reset_coefficient | reset;
	assign RSTA = reset_coefficient;
	assign RSTALLCARRYIN = reset;
	assign RSTALUMODE = reset;
	assign RSTB = reset;
	assign RSTC = reset;
	assign RSTCTRL = reset;
	assign RSTD = reset;
	assign RSTINMODE = reset;
	assign RSTM = reset;
	assign RSTP = reset;

	// determine whether the input and output signals should be routed
	//  through the hardware carry lines to the adjecent DSP48 or connected
	//  to the external fabric
	generate
		if (USE_SILICON_CARRY) begin

			// decicde whether inputs should be from hardware carrys or 
			//  exposed inputs
			if (FIRST_IN_CHAIN) begin
				// assign A = {{(A_WIDTH-DATA_IN_WIDTH){data_in_A[DATA_IN_WIDTH-1]}}, data_in_A};
				assign B = {{(B_WIDTH-DATA_WIDTH){data_in[DATA_WIDTH-1]}}, data_in};
				assign PCIN = 0;
			end
			else begin
				assign BCIN = {{(B_WIDTH-DATA_WIDTH){data_in[DATA_WIDTH-1]}}, data_in};
				assign PCIN = {{(PCIN_WIDTH-CARRY_WIDTH){carry_in[CARRY_WIDTH-1]}}, carry_in};
			end

			// assign carry out signals
			assign data_carry = BCOUT;

			// for the moment coefficient must come from external
			//  could change this in the future
			assign A = {{(A_WIDTH-COEFFICIENT_WIDTH){coefficient_in[COEFFICIENT_WIDTH-1]}}, coefficient_in};

			assign data_out = P[DATA_WIDTH+COEFFICIENT_WIDTH+OUTPUT_OFFSET-1:COEFFICIENT_WIDTH+OUTPUT_OFFSET];
			assign carry_out = PCOUT;
			
		end
		else begin
			assign A = {{(A_WIDTH-COEFFICIENT_WIDTH){coefficient_in[COEFFICIENT_WIDTH-1]}}, coefficient_in};
			assign B = {{(B_WIDTH-DATA_WIDTH){data_in[DATA_WIDTH-1]}}, data_in};
			assign PCIN = 0;
			assign data_out = P[DATA_WIDTH+COEFFICIENT_WIDTH+OUTPUT_OFFSET-1:COEFFICIENT_WIDTH+OUTPUT_OFFSET];
		end
	endgenerate


	// connect the clock enables
	assign CEA1 = ce_coefficient;
	assign CEA2 = ce_coefficient;
	assign CEAD = ce_coefficient;

	assign CEB1 = ce_calculate;
	assign CEB2 = ce_calculate;
	assign CEALUMODE = ce_calculate;
	assign CEC = ce_calculate;
	assign CECARRYIN = ce_calculate;
	assign CECTRL = ce_calculate;
	assign CED = ce_calculate;
	assign CEINMODE = ce_calculate;
	assign CEM = ce_calculate;
	assign CEP = ce_calculate;


	//// unconnected signals
	assign ACIN = 0;
	assign ALUMODE = 0;
	// assign BCIN = 0;
	assign CARRYCASCIN = 0;
	assign CARRYINSEL = 0;
	assign CARRYIN = 0;
	assign MULTSIGNIN = 0;


	// instantiate the DSP48E1
	DSP48E1 #(
		.ACASCREG(ACASCREG),
		.ADREG(ADREG),
		.ALUMODEREG(ALUMODEREG),
		.AREG(COEFFICIENTS_NUMBER_REGS),
		.AUTORESET_PATDET(AUTORESET_PATDET),
		.A_INPUT(A_INPUT),
		.BCASCREG(DATA_IN_NUMBER_REGS),
		.BREG(DATA_IN_NUMBER_REGS),
		.B_INPUT(B_INPUT),
		.CARRYINREG(CARRYINREG),
		.CARRYINSELREG(CARRYINSELREG),
		.CREG(CREG),
		.DREG(DREG),
		.INMODEREG(INMODEREG),
		.MREG(MREG),
		.OPMODEREG(OPMODEREG),
		.PREG(PREG),
		.SEL_MASK(SEL_MASK),
		.SEL_PATTERN(SEL_PATTERN),
		.USE_DPORT(USE_DPORT),
		.USE_MULT(USE_MULT),
		.USE_PATTERN_DETECT(USE_PATTERN_DETECT),
		.USE_SIMD(USE_SIMD),
		.MASK(MASK),
		.PATTERN(PATTERN),
		.IS_ALUMODE_INVERTED(IS_ALUMODE_INVERTED),
		.IS_CARRYIN_INVERTED(IS_CARRYIN_INVERTED),
		.IS_CLK_INVERTED(IS_CLK_INVERTED),
		.IS_INMODE_INVERTED(IS_INMODE_INVERTED),
		.IS_OPMODE_INVERTED(IS_OPMODE_INVERTED)
	) DSP48E1_inst(
		.ACOUT(ACOUT), 
		.BCOUT(BCOUT), 
		.CARRYCASCOUT(CARRYCASCOUT),
		.CARRYOUT(CARRYOUT),
		.MULTSIGNOUT(MULTSIGNOUT),
		.OVERFLOW(OVERFLOW),
		.P(P), 
		.PATTERNBDETECT(PATTERNBDETECT),
		.PATTERNDETECT(PATTERNDETECT),
		.PCOUT(PCOUT),
		.UNDERFLOW(UNDERFLOW),
		.A(A),
		.ACIN(ACIN),
		.ALUMODE(ALUMODE),
		.B(B),
		.BCIN(BCIN),
		.C(C),
		.CARRYCASCIN(CARRYCASCIN),
		.CARRYIN(CARRYIN),
		.CARRYINSEL(CARRYINSEL),
		.CEA1(CEA1),
		.CEA2(CEA2),
		.CEAD(CEAD),
		.CEALUMODE(CEALUMODE),
		.CEB1(CEB1),
		.CEB2(CEB2),
		.CEC(CEC),
		.CECARRYIN(CECARRYIN),
		.CECTRL(CECTRL),
		.CED(CED),
		.CEINMODE(CEINMODE),
		.CEM(CEM), 
		.CEP(CEP),
		.CLK(CLK),
		.D(D),
		.INMODE(in_mode),
		.MULTSIGNIN(MULTSIGNIN),
		.OPMODE(op_mode),
		.PCIN(PCIN),
		.RSTA(RSTA),
		.RSTALLCARRYIN(RSTALLCARRYIN),
		.RSTALUMODE(RSTALUMODE),
		.RSTB(RSTB),
		.RSTC(RSTC),
		.RSTCTRL(RSTCTRL),
		.RSTD(RSTD),
		.RSTINMODE(RSTINMODE), 
		.RSTM(RSTM),  
		.RSTP(RSTP)
	);

	// used to create the GTKwave dump file
	`ifdef COCOTB_SIM
			initial begin
			$dumpfile ("waveform.vcd");
			$dumpvars (0, multiply_accumulate);
			#1;
		end
	`endif

endmodule