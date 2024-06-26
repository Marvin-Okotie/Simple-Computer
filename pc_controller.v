////////////////////////////////////////////////////////////////////////////////////////////////////
//
// File: pc_controller.v
// Author:	 Marvin Okotie 
//
// Description: This is a model of the Program Counter controller for the Simple Computer.
//
//              The Program Counter's next value depends on the kind of instruction being executed.
//              - The Jump instruction uses an address value from the instruction's target register
//                as its destination.
//              - The Branch instructions use an address offset contained in the instruction code,
//                and are also dependent in part upon status flags N and Z.
//              - All other instructions cause PC to advance to the next consecutive instruction.
//
// 
// Modified by Marvin Okotie April 23, 2024. 
// 					Added Logic for Branch on Greated than 0.
//
// 
////////////////////////////////////////////////////////////////////////////////////////////////////

module pc_controller(clock, reset, V, C, N, Z, PL, JB, BC, branch_offset, jump_addr, PC);
	input         clock;				// CPU clock
	input         reset;				// CPU reset
	input         V;					// Overflow status bit
	input         C;					// Carry status bit
	input         N;					// Negative status bit
	input         Z;					// Zero status bit
	input         PL;					// Program Counter Load
	input         JB;					// Jump/Branch Control
	input         BC;					// Branch Condition
	input  [15:0] jump_addr;		// Jump Address
	input  [15:0] branch_offset;	// Branch Offset
	output [15:0] PC;					// PC value
	reg    [15:0] PC;

	wire   [15:0] next_pc;
	wire   [15:0] pc_inc;
	wire 	 [15:0] carry;
	wire 	 [15:0] branch;
	wire 			  RGZ;

	// Register that increments the PC at every positive clock edge
	always@(posedge clock) begin
		if(reset)
			PC <= 16'h0000;
		else
			PC <= next_pc;
	end
	
	// Logic to decide what is the next PC value based upon the control bits (PL, JB, BC) and the status bits (N, Z)
				
	assign RGZ = (~N | ~Z);
	
   assign next_pc = (reset == 1'b1)                           ? 16'h0000           :	// Reset: next_PC = 0
                    (PL&JB == 1'b1)                           ? jump_addr          :	// JUMP: next_PC = jump_address
						  ((RGZ & (BC & PL)) == 1'b1)		  			  ? branch		  		  :	// branch on grater than 0
                                                                pc_inc;			         // Default: next_PC = PC + 1 

   incrementer PCINC (pc_inc, PC);
	branch_logic BRGZ (branch, PC, branch_offset);
	
endmodule


	
module incrementer (inc_output, inc_input);
   input [15:0] inc_input;
	output [15:0] inc_output;
	wire [16:1] C;
	
	halfadd HA0 (inc_output[0], C[1], inc_input[0], 1'b1);
	halfadd HA1 (inc_output[1], C[2], inc_input[1], C[1]);
	halfadd HA2 (inc_output[2], C[3], inc_input[2], C[2]);
	halfadd HA3 (inc_output[3], C[4], inc_input[3], C[3]);
	halfadd HA4 (inc_output[4], C[5], inc_input[4], C[4]);
	halfadd HA5 (inc_output[5], C[6], inc_input[5], C[5]);
	halfadd HA6 (inc_output[6], C[7], inc_input[6], C[6]);
	halfadd HA7 (inc_output[7], C[8], inc_input[7], C[7]);
	halfadd HA8 (inc_output[8], C[9], inc_input[8], C[8]);
	halfadd HA9 (inc_output[9], C[10], inc_input[9], C[9]);
	halfadd HA10 (inc_output[10], C[11], inc_input[10], C[10]);
	halfadd HA11 (inc_output[11], C[12], inc_input[11], C[11]);
	halfadd HA12 (inc_output[12], C[13], inc_input[12], C[12]);
	halfadd HA13 (inc_output[13], C[14], inc_input[13], C[13]);
	halfadd HA14 (inc_output[14], C[15], inc_input[14], C[14]);
	halfadd HA15 (inc_output[15], C[16], inc_input[15], C[15]);

endmodule 


module branch_logic (sum, PC_in, branch_off);
   input [15:0] branch_off;
	input [15:0] PC_in;
	output [15:0] sum;
	wire [15:0] C;
	
	Full_adder FA_1 (sum[0], C[0], PC_in[0], branch_off[0], 1'b0);   
	Full_adder FA_2 (sum[1], C[1], PC_in[1], branch_off[1], C[0]);
	Full_adder FA_3 (sum[2], C[2], PC_in[2], branch_off[2], C[1]);
	Full_adder FA_4 (sum[3], C[3], PC_in[3], branch_off[3], C[2]);
	Full_adder FA_5 (sum[4], C[4], PC_in[4], branch_off[4], C[3]);
	Full_adder FA_6 (sum[5], C[5], PC_in[5], branch_off[5], C[4]);
	Full_adder FA_7 (sum[6], C[6], PC_in[6], branch_off[6], C[5]);
	Full_adder FA_8 (sum[7], C[7], PC_in[7], branch_off[7], C[6]);
	Full_adder FA_9 (sum[8], C[8], PC_in[8], branch_off[8], C[7]);
	Full_adder FA_10 (sum[9], C[9], PC_in[9], branch_off[9], C[8]);
	Full_adder FA_11 (sum[10], C[10], PC_in[10], branch_off[10], C[9]);
	Full_adder FA_12 (sum[11], C[11], PC_in[11], branch_off[11], C[10]); 
	Full_adder FA_13 (sum[12], C[12], PC_in[12], branch_off[12], C[11]); 
	Full_adder FA_14 (sum[13], C[13], PC_in[13], branch_off[13], C[12]); 
	Full_adder FA_15 (sum[14], C[14], PC_in[14], branch_off[14], C[13]); 
	Full_adder FA_16 (sum[15], C[15], PC_in[15], branch_off[15], C[14]); 

endmodule

module halfadd (S,C,X,Y);
   input X, Y;
	output S, C;
	assign S = X^Y;
	assign C = X&Y;
endmodule 