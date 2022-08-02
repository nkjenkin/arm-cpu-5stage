`timescale 1ps/1ps

module alu_1bit(A, B, shamt, carry_in, cntrl, result, carry_out);
	// inputs 1 bit A, B, carry_in
	//        3 bit control sequence
	input logic A, B, carry_in;
	input logic [2:0] cntrl;
	input logic [5:0] shamt;
	
	// outputs 1 bit result, carry out
	output logic result, carry_out;

	// cntrl			Operation						Notes:
	// 000:			result = B						value of overflow and carry_out unimportant
	// 010:			result = A + B
	// 011:			result = A - B
	// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
	// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
	// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
	// 111:			result = A >> Shamt
	
	
	logic [7:0] WIRE0; // results of above operations TO 8x1 mux
	logic [2:0] WIRE1; // carry-out wire
	logic arthB; // wire for the arthmetic B (flipped for sub, not flipped for add)
	
	xor #50 xarth (arthB, B, cntrl[0]); // B XOR cntrl[0], will flip B if sub
	
	// result = B
	assign WIRE0[0] = B;
	
	// result = A + B
	xor #50 add0 (WIRE0[2], A, arthB, carry_in); // A + B = A XOR B XOR carry-in
	
	// result = A - B
	xor #50 add1 (WIRE0[3], A, arthB, carry_in); // A - B = A + (-B) = A XOR notB XOR carry-in
	
	// result = bitwise A&B;
	and #50 a0 (WIRE0[4], A, B); // A AND B
	
	// result = bitwise A|B
	or #50 o0 (WIRE0[5], A, B); // A OR B
	
	// result = bitwise A XOR B
	xor #50 x0 (WIRE0[6], A, B); // A XOR B
	
	// assigning unused mux bus wires to be 0
	assign WIRE0[1] = 0;
	assign WIRE0[7] = 0;
		
	// 8_1 cntrl deciding mux, output result
	mux8_1 m0 (.out(result), .in(WIRE0[7:0]), .sel(cntrl[2:0]));
	
	//carry out
	and #50 a1 (WIRE1[0], A, arthB); 
	and #50 a2 (WIRE1[1], arthB, carry_in);
	and #50 a3 (WIRE1[2], A, carry_in);
	or #50 o1 (carry_out, WIRE1[0], WIRE1[1], WIRE1[2]); // carryout is A*B + B*carry-in + A*carry-in
endmodule 

module alu_1bit_testbench(); //testbench for ALU 1bit
	logic A, B, carry_in;
	logic [2:0] cntrl;
	logic result, carry_out;
	
	alu_1bit dut (.A, .B, .carry_in, .cntrl, .result, .carry_out);
	
	integer i;
	
	initial begin
		assign A = 0;
		assign B = 0;
		assign carry_in = 0;
		for(i=0; i<(8); i++) begin
			cntrl = i; #5000;
		end
		
		assign A = 0;
		assign B = 0;
		assign carry_in = 1;
		for(i=0; i<(8); i++) begin
			cntrl = i; #5000;
		end
		
		assign A = 0;
		assign B = 1;
		assign carry_in = 1;
		for(i=0; i<(8); i++) begin
			cntrl = i; #5000;
		end
		
		assign A = 1;
		assign B = 1;
		assign carry_in = 1;
		for(i=0; i<(8); i++) begin
			cntrl = i; #5000;
		end
	end
endmodule 