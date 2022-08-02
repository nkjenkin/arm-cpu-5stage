`timescale 1ps/1ps

module adder(A, B, carry_in, out, carry_out);
	input logic A, B, carry_in;
	output logic out, carry_out;
	
	logic [2:0] WIRE1;
	
	xor #50 add0 (out, A, B, carry_in); // A + B = A XOR B XOR carry-in

	//carry out
	and #50 a1 (WIRE1[0], A, B); 
	and #50 a2 (WIRE1[1], B, carry_in);
	and #50 a3 (WIRE1[2], A, carry_in);
	or #50 o1 (carry_out, WIRE1[0], WIRE1[1], WIRE1[2]); // carryout is A*B + B*carry-in + A*carry-in
endmodule 

module adder_testbench(); // testbench for single bit adder
	logic A, B, carry_in, out, carry_out;
	
	adder dut (.A, .B, .carry_in, .out, .carry_out);
	
	initial begin
		assign A = 0;
		assign B = 0;
		assign carry_in = 0; #5000;
		
		assign A = 0;
		assign B = 1;
		assign carry_in = 0; #5000;
		
		assign A = 1;
		assign B = 0;
		assign carry_in = 1; #5000;
		
		assign A = 1;
		assign B = 1;
		assign carry_in = 0; #5000;
		
		assign A = 1;
		assign B = 1;
		assign carry_in = 1; #5000;
	end
endmodule 