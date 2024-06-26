////////////////////////////////////////////////////////////////////////////////////////////////////
//
// File: cpu.v
// Author: Marvin Okotie
//
// Description: This module specifies the top-level component for a single-cycle computer. 
//					 It is mainly a structural module whose units are implemented in other modules in this project.
//
////////////////////////////////////////////////////////////////////////////////////////////////////



module cpu(clock, reset, r0, r1, r2, r3, r4, r5, r6, r7, IR, PC, status);
	input clock;
	input reset;

	output [15:0] r0;	// CPU registers
	output [15:0] r1;
	output [15:0] r2;
	output [15:0] r3;
	output [15:0] r4;
	output [15:0] r5;
	output [15:0] r6;
	output [15:0] r7;
	output [15:0] IR;	// CPU Instruction Register
	output [15:0] PC;	// CPU Program Counter
	output [3:0]  status;	// status bit vector VCNZ

// End module and port declaration

// Wire declaration

	wire   [15:0] instr;	// Machine Instruction 
	wire    [2:0] DA;	// Decoded Destination Register Address field
	wire    [2:0] AA;	// Decoded Operand A Register Address field
	wire    [2:0] BA;	// Decoded Operand B Register Address field
	wire          MB;	// Decoded Multiplexer B Select
	wire    [3:0] FS;	// Decoded Function Unit Select
	wire          MD;	// Decoded Multiplexer D Select
	wire          RW;	// Decoded Register Write
	wire          MW;	// Decoded Memory Write
	wire          PL;	// Decoded Program Counter Load
	wire          JB;	// Decoded Jump/Branch Control
	wire          BC;	// Decoded Branch Condition 
	wire   [15:0] AD;	// Sign-extended address offset.
	wire          V;	// Overflow status bit
	wire          C;	// Carry-out status bit
	wire          N;	// Negative status bit
	wire          Z;	// Zero status bit
	wire   [15:0] data_mem_out;	// Data Memory output
	wire   [15:0] Bus_D ;	// Register file input, BuS D	
	wire   [15:0] constant;	// Immediate operand
	wire   [15:0] A;	// Register file output A
	wire   [15:0] B;	// Register file output B
	wire   [15:0] mux_b_out;	// Multiplexer B output
	wire   [15:0] function_unit_out;	// Function Unit output
	wire   [15:0] mux_d_out;	// Multiplexer D output

// End wire declaration 
	
////////////  CONTROL UNIT  ////////////
	
// PC CONTROLLER
// - Generate the 16-bit sign-extended address offset.
// - YOU WILL HAVE TO CREATE THIS VALUE IN LEARNING EXPERIENCE F.3.

	assign AD = {instr[8], instr[8], instr[8], instr[8], instr[8], instr[8], instr[8], instr[8], instr[8], instr[8], instr[8:6], instr[2:0]};


// - PC Controller Instantiation

	pc_controller pc_ctrl(clock, reset, V, C, N, Z, PL, JB, BC, AD, A, PC);

// INSTUCTION MEMORY
// - Instruction Memory instantiation, as 1K x 16 unit.
// - These parameters control the size of the memory.

	single_port_rom #(10, 16) instr_mem(clock, reset, PC[9:0], instr);

// INSTRUCTION DECODER
// - Instruction Decoder instantiation

	instruction_decoder instr_decoder(instr, DA, AA, BA, MB, FS, MD, RW, MW, PL, JB, BC);

////////////  DATA  MEMORY  ////////////

// DATA MEMORY
// - Data Memory instantiation, as 256 x 16 unit.
// - These parameters control the size of the memory.

	single_port_ram #(8, 16) data_mem(clock, MW, A[7:0], mux_b_out, data_mem_out);

////////////    DATAPATH    //////////// 
	
// REGISTER FILE
// - Clear the data input to the register file on a reset.

	assign Bus_D = (reset == 1'b0) ? mux_d_out : (reset == 1'b1) ? 8'b00000000 : 8'bxxxxxxxx;

// - Register file instantiation.	

	dual_port_ram register_file(clock, reset, Bus_D, RW, DA, AA, BA, A, B, r0, r1, r2, r3, r4, r5, r6, r7);

// MULTIPLEXER B
// - Generate the 16-bit zero filled immediate operand. 

	assign constant = {13'b0000000000000, instr[2:0]};

// - Instantiate Multiplexer B.

	mux2to1_16bit mux_b(MB, B, constant, mux_b_out);

// FUNCTION UNIT
// - Instantiate Function Unit.

	function_unit func_unit(FS, A, mux_b_out, function_unit_out, V, C, N, Z);
	
// MULTIPLEXER D
// - Instatiate Multiplexer D.

	mux2to1_16bit mux_d(MD, function_unit_out, data_mem_out, mux_d_out);

// Make the instruction register value visible outside the CPU.

	assign IR = instr;

// Make the status bits visible outside the CPU.

	assign status = {V, C, N, Z};

endmodule
