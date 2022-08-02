`timescale 1ps/1ps

module zero64(in, out);
	// checks if all 64-bits are zero
	
	// input 64-bit in
	input logic [63:0] in;
	
	// output 1-bit out (y/n if zero)
	output logic out;
	
	// Wire to connect zero16's
	logic [3:0] WIRE;
	
	zero16 z0 (.out(WIRE[0]), .in(in[15:0]));
	zero16 z1 (.out(WIRE[1]), .in(in[31:16]));
	zero16 z2 (.out(WIRE[2]), .in(in[47:32]));
	zero16 z3 (.out(WIRE[3]), .in(in[63:48]));
	and #50 a (out, WIRE[0], WIRE[1], WIRE[2], WIRE[3]); // if all zero16's output 1 (meaning each 16-bit sequence is all zero), output 1
endmodule 

module zero64_testbench(); //testbench for zero64
	logic [63:0] in;
	logic out;
	
	zero64 dut (.out, .in);
	
	initial begin
		assign in = 'b00000000000000000000000000000000; #5000;
		assign in = 'b00000111010101010000011101010101; #5000;
		assign in = 'b00000000000001000000000000000100; #5000;
		assign in = 'b10000000000000000000000000000000; #5000;
		assign in = 'b00000000000000000000000000000000; #5000;
		assign in = 'b11111111111111111111111111111111; #5000;
	end
endmodule 