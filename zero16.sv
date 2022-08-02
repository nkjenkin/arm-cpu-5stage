`timescale 1ps/1ps

module zero16(in, out);
	// building block for zero64, checks if 16-bit input is zero

	// input 16-bit in
	input logic [15:0] in;
	
	// output 1-bit out, (y/n if zero)
	output logic out;
	
	logic [3:0] WIRE; // wire to connect NORs
	
	// NOR gates output 1 only if all inputs are 0
	nor #50 nor0 (WIRE[0], in[0], in[1], in[2], in[3]);
	nor #50 nor1 (WIRE[1], in[4], in[5], in[6], in[7]);
	nor #50 nor2 (WIRE[2], in[8], in[9], in[10], in[11]);
	nor #50 nor3 (WIRE[3], in[12], in[13], in[14], in[15]);
	
	// AND gate, only true if all NOR gates output 1, which they do only if all their inputs are 0
	and #50 a	 (out, WIRE[0], WIRE[1], WIRE[2], WIRE[3]);
endmodule 

module zero16_testbench(); //testbench for zero16
	logic [15:0] in;
	logic out;
	
	zero16 dut (.out, .in);
	
	initial begin
		assign in = 'b0000000000000000; #5000;
		assign in = 'b0000011101010101; #5000;
		assign in = 'b0000000000000100; #5000;
		assign in = 'b1000000000000000; #5000;
		assign in = 'b0000000000000000; #5000;
		assign in = 'b1111111111111111; #5000;
	end
endmodule 