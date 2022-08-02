`timescale 1ps/1ps
// really bad delays when lots of carry, expected?

module alu(A, B, cntrl, shamt, result, negative, zero, overflow, carry_out);
	// inputs 64 bit A and B
	//        3 bit control sequence
	input logic [63:0] A, B;
	input logic [2:0] cntrl;
	input logic [5:0] shamt;
	
	
	// outputs 64 bit result,
	//         flags for negative, zero, overflow, and carry out
	output logic [63:0] result;
	output logic negative, zero, overflow, carry_out;
	
	// negative: whether the result output is negative if interpreted as 2's comp.
	// zero: whether the result output was a 64-bit zero.
	// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
	// carry_out: on an add or subtract, whether the computation produced a carry-out.

	// cntrl			Operation						Notes:
	// 000:			result = B						value of overflow and carry_out unimportant
	// 010:			result = A + B
	// 011:			result = A - B
	// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
	// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
	// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
	// 111:			result = A >> Shamt
	
	// 65 wire to mark carry out for each ALU bit, which will be carry-in for next ALU bit
	logic [64:0] carry_in_out;
	logic [63:0] WIRE0, WIRE1;
	logic shift;
	
	// will add 1 to the least significant bit after flipping B IFF cntrl signals for subtract (or bitwise OR -- where carry_out doesn't matter)
	assign carry_in_out[0] = cntrl[0]; 
	
	// generate 64 1-bit ALUs to make a 64 bit ALU
	// carry-in is current, carry-out is next
	genvar i;
	generate
		for (i=0; i<64; i++) begin : eachALU
			alu_1bit alu_64bit (.A(A[i]), .B(B[i]), .shamt(shamt), .carry_in(carry_in_out[i]), .cntrl, .result(WIRE0[i]), .carry_out(carry_in_out[i+1]));
		end
	endgenerate
	
	//shifter
	shifter lsr (.value(A), .direction(1'b1), .distance(shamt), .result(WIRE1));
	and #50 shiftOrNo (shift, cntrl[0], cntrl[1], cntrl[2]);
	
	// output of ALU OR shifter
	genvar j;
	generate
		for (j=0; j<64; j++) begin: shiftDecide
			muxab_1 resulting (.out(result[j]), .a(WIRE0[j]), .b(WIRE1[j]), .sel(shift));
		end
	endgenerate
	
	//overflow
	xor #50 x0 (overflow, carry_in_out[63], carry_in_out[64]); // Last bit -> carry-out XOR carry-in
	
	// negative
	assign negative = result[63]; // if most-sig bit is 1
	
	//carry-out
	assign carry_out = carry_in_out[64]; // carry-out of most-sig bit
	
	//zero
	zero64 z (.out(zero), .in(result[63:0])); // check if all 64 bits are zero
endmodule
 
module alu_testbench(); //testbench for ALU 1bit
	logic [63:0] A, B;
	logic [2:0] cntrl;
	logic [63:0] result;
	logic negative, zero, overflow, carry_out;
	
	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);
	
	integer i;
	
	initial begin
		// check zero flag
		// also checking subtraction by 0
		assign A = 0;
		assign B = 0;
		for(i=0; i<(8); i++) begin
			cntrl = i; #100000;
		end
		
		// check negative flag
		assign B = 64'b1000000000000000000000000000000000000000000000000000000000000000;
		assign cntrl = 0; #100000;
		
		// check overflow and carry-out flag
		assign A = 64'b1000000000000000000000000000000000000000000000000000000000000000;
		assign B = 64'b1000000000000000000000000000000000000000000000000000000000000000;
		assign cntrl = 'b010; #100000;
		
		// check all basic functions with easy A and B
		assign A = 0;
		assign B = 1;
		for(i=0; i<(8); i++) begin
			assign cntrl = i; #100000;
		end
		
		assign A = 1;
		assign B = 0;
		for(i=0; i<(8); i++) begin
			cntrl = i; #100000;
		end
		
		assign A = 1;
		assign B = 1;
		for(i=0; i<(8); i++) begin
			cntrl = i; #100000;
		end
		
		// check AND, OR, XOR with the following random numbers
		// checking addition and subtraction with positive numbers
		assign A = 250;
		assign B = 150;
		for(i=0; i<(8); i++) begin
			cntrl = i; #100000;
		end
		
		// checking addition and subtraction with one negative number
		assign A = 3784;
		assign B = -1259;
		for(i=0; i<(8); i++) begin
			cntrl = i; #100000;
		end
		
		// checking addition and subtraction with negative numbers
		assign A = -648;
		assign B = -1024;
		for(i=0; i<(8); i++) begin
			cntrl = i; #100000;
		end
		
		// checking subtraction with B>A
		assign A = 2;
		assign B = 4;
		for (i=0; i<(8); i++) begin
			cntrl = i; #100000;
		end
	end
endmodule 