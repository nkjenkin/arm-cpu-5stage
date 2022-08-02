`timescale 1ps/1ps

module mux32_1 (out, in, sel); //32-to-1 multiplexer
	//outputs single bit
	output logic out;
	
	//takes one bit from the 32 registers as input
	input logic [31:0] in;
	
	//5 bit selection input
	input logic [4:0] sel;
	
	logic [1:0] WIRE;
	
	//uses 16 to 1 and 2 to 1 mux's to create 32-to-1
	mux16_1 m0(.out(WIRE[0]), .in(in[15:0]), .sel(sel[3:0]));
	mux16_1 m1(.out(WIRE[1]), .in(in[31:16]), .sel(sel[3:0]));
	mux2_1 m (.out(out), .in(WIRE[1:0]), .sel(sel[4]));
endmodule 

module mux32_1_testbench(); //testbench for 32-to-1
	logic [31:0] in;
	logic [4:0] sel;
	logic out;
	
	mux32_1 dut (.out, .in, .sel);
	
	initial begin
		assign in = 'b10101010011010111000101001101011;
		assign sel = 'b11111; #5000; // bit-31 should be 1
		assign sel = 'b00000; #5000; // bit-0 should be 1
		assign sel = 'b00010; #5000; // bit-2 should be 0
		assign sel = 'b11011; #5000; // bit-27 should be 1
		assign in = 'b00000000000000000000000000100000;
		assign sel = 'b00101; #5000; // bit-5 should be 1
	end
endmodule 