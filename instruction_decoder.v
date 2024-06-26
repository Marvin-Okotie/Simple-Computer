////////////////////////////////////////////////////////////////////////////////////////////////////
//
// File: instruction_decoder.v
// Author:	 Marvin Okotie 
//
// Description: This module corresponds to the Simple Computer's Instruction Decoder, as shown in
//              Figure 8-16 on Page 462.
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module instruction_decoder(instr, DA, AA, BA, MB, FS, MD, RW, MW, PL, JB, BC);
	input  [15:0] instr;	// Machine instruction
	output  [2:0] DA;		// Decoded Destination Register Address field
	output  [2:0] AA;		// Decoded Operand A Register Address field
	output  [2:0] BA;		// Decoded Operand B Register Address field
	output        MB;		// Decoded Multiplexer B Select
	output  [3:0] FS;		// Decoded Function Unit Select
	output        MD;		// Decoded Multiplexer D Select
	output        RW;		// Decoded Register Write
	output        MW;		// Decoded Memory Write
	output        PL;		// Decoded Program Counter Load
	output        JB;		// Decoded Jump/Branch Control
	output        BC;		// Decoded Branch Condition 
	
	assign DA = instr[8:6];
	assign AA = instr[5:3];
	assign BA = instr[2:0];
	assign MB = instr[15];
	assign FS = {instr[12:10], (instr[9] & (~PL))};
	assign MD = instr[13];
	assign RW = ~instr[14];
	assign MW = ~instr[15] & instr[14];
	assign PL = instr[15] & instr[14];
	assign JB = instr[13];
	assign BC = instr[9];

endmodule
