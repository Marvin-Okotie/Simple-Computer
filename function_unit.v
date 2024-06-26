////////////////////////////////////////////////////////////////////////////////////////////////////
//
// File: function_unit.v
//
// Author:	 Marvin Okotie 
// Version:  1 
// 
// Description: This is an implementation of a 16bit function unit for the Datapath section of a simple computer, 
// 				 it takes 3 inputs, the 4bit Function Select Code, the 16bit OperandA and the  16bit OperandB.
// 				 It has 5 outputs, The 16bit result, and 1bit status bits V,C.N, and Z. This module uses a combination
//					 of continous assign statements, and dataflow verilog. 
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module function_unit(FS, OpA, OpB, result, V, C, N, Z);
	input   [3:0] FS;				// Function Unit select code.
   input  [15:0] OpA;				// Function Unit operand A
   input  [15:0] OpB;				// Function Unit operand B
   output [15:0] result;		// Function Unit result
   output        V;				// Overflow status bit
   output        C;				// Carry-out status bit
   output        N;				// Negative status bit
   output        Z;				// Zero status bit

  wire [15:0]  wA;
  wire [15:0]  wB;    
  wire [15:0] carry;                              
  wire [15:0] arith;
  wire [15:0] logic; 
  wire N_A, N_L;
  wire Z_A, Z_L;

// Arithmetic  Function Unit
	arith_16_bit_8_by_1_mux MUX_A(wA, FS, OpA, OpA, OpA, ~OpA, 16'bx, 16'b0, 16'bx, ~OpA);
	arith_16_bit_8_by_1_mux MUX_B(wB, FS, OpB, ~OpB, 16'b0, OpB, 16'bx, ~OpB, 16'bx, 16'b0);

	Full_adder FA_1(arith[0], carry[0], wA[0], wB[0], FS[0]);    //FS 0 is the Carry in bit because functions that need a +1 have a FS 4 bit code ending in 1
	Full_adder FA_2(arith[1], carry[1], wA[1], wB[1], carry[0]);
	Full_adder FA_3(arith[2], carry[2], wA[2], wB[2], carry[1]);
	Full_adder FA_4(arith[3], carry[3], wA[3], wB[3], carry[2]);
	Full_adder FA_5(arith[4], carry[4], wA[4], wB[4], carry[3]);
	Full_adder FA_6(arith[5], carry[5], wA[5], wB[5], carry[4]);
	Full_adder FA_7(arith[6], carry[6], wA[6], wB[6], carry[5]);
	Full_adder FA_8(arith[7], carry[7], wA[7], wB[7], carry[6]);
	Full_adder FA_9(arith[8], carry[8], wA[8], wB[8], carry[7]);
	Full_adder FA_10(arith[9], carry[9], wA[9], wB[9], carry[8]);
	Full_adder FA_11(arith[10], carry[10], wA[10], wB[10], carry[9]);
	Full_adder FA_12(arith[11], carry[11], wA[11], wB[11], carry[10]);
	Full_adder FA_13(arith[12], carry[12], wA[12], wB[12], carry[11]);
	Full_adder FA_14(arith[13], carry[13], wA[13], wB[13], carry[12]);
	Full_adder FA_15(arith[14], carry[14], wA[14], wB[14], carry[13]);
	Full_adder FA_16(arith[15], carry[15], wA[15], wB[15], carry[14]);
	
// Logic Function Unit
	logic_16_bit_8_by_1_mux block0(logic, FS, (OpA & OpB), ~OpA, (OpA | OpB), ~OpB, {OpB[15],OpB[15],OpB[15],OpB[15],OpB[14:3]},(~(OpA | OpB)), {16'b0000000000000011 & OpB},16'bx );

	mux2_by_1_16bit a_orl(result, FS[3],arith,logic); 
	
// Status Bits
	assign V = (carry[15] ^ carry[14]);
	assign C = carry[15];
	
	assign N_A = arith[15];
	assign N_L = logic[15];
	
	
	assign Z_A = ~(arith[0] | arith[1] | arith[2] | arith[3] | arith[4] | arith[5] | arith[6] | arith[7] | arith[8] | arith[9] | arith[10] | arith[11] | arith[12] | arith[13] | arith[14] | arith[15]);
	assign Z_L = ~(logic[0] | logic[1] | logic[2] | logic[3] | logic[4] | logic[5] | logic[6] | logic[7] | logic[8] | logic[9] | logic[10] | logic[11] | logic[12] | logic[13] | logic[14] | logic[15]);

	mux2_by_1_1bit Zstatus(Z, FS[3], Z_A, Z_L);
	mux2_by_1_1bit Nstatus(N, FS[3], N_A, N_L);


endmodule

//Hardware for Function Unit

module mux2_by_1_16bit(out, in, sel0, sel1);
   input        in;
   input  [15:0] sel0;
   input  [15:0] sel1;
   output [15:0] out;
	
	assign out = (in == 1'b0) ? sel0 :
	             (in == 1'b1) ? sel1 : 16'bx;

endmodule

module mux2_by_1_1bit(out, in, sel0, sel1);
   input   in;
   input   sel0;
   input   sel1;
   output  out;
	
	assign out = (in == 1'b0) ? sel0 :
	             (in == 1'b1) ? sel1 : 1'bx;

endmodule 

module arith_16_bit_8_by_1_mux(outAB, in, sel0, sel1, sel2, sel3, sel4, sel5, sel6, sel7);
		input [3:0] in;
		input [15:0] sel0, sel1, sel2, sel3, sel4, sel5, sel6, sel7;
		output [15:0] outAB;
		
		assign outAB = (in == 4'b0000) ? sel0:  //ADDA_B
		               (in == 4'b0001) ? sel1:  //SUBA_B
		               (in == 4'b0010) ? sel2:  //MOVA 
		               (in == 4'b0011) ? sel3:  //SUBB_A
		               (in == 4'b0100) ? sel4:	 //DC
		               (in == 4'b0101) ? sel5:	 //NEGB
		               (in == 4'b0110) ? sel6:	 //DC
		               (in == 4'b0111) ? sel7:  //NEGA
													16'bx;
endmodule
			
module logic_16_bit_8_by_1_mux(outAB, in, sel0, sel1, sel2, sel3, sel4, sel5, sel6, sel7);
		input [3:0] in;
		input [15:0] sel0, sel1, sel2, sel3, sel4, sel5, sel6, sel7;
		output [15:0] outAB;
		
		assign outAB = (in == 4'b1000) ? sel0:   //ANDA_B
		               (in == 4'b1001) ? sel1:   //NOTA
		               (in == 4'b1010) ? sel2:   //ORA_B
		               (in == 4'b1011) ? sel3:   //NOTB
		               (in == 4'b1100) ? sel4:   //DIV8
		               (in == 4'b1101) ? sel5:   //NORA_B
		               (in == 4'b1110) ? sel6:	  //MOD4_B
		               (in == 4'b1111) ? sel7:   //DC
													16'bx; 

endmodule	

module Full_adder (sum,carry,x,y,cin);
	input x,y,cin;
	output sum, carry;
	assign sum = x^y^cin;
	assign carry = x&y |(cin & (x^y));
endmodule	 
