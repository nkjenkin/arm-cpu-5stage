`timescale 1ps/1ps

module muxabcd(out, a, b, c, d, sel); // mux with four different signals
	input logic a, b, c, d;
	input logic [1:0] sel;
	output logic out;

	logic [3:0] WIRE;
	
	// assign each of the four bits to a four-bit array to use in mux4_1
	assign WIRE[0] = a;
	assign WIRE[1] = b;
	assign WIRE[2] = c;
	assign WIRE[3] = d;
	
	mux4_1 m (.out, .in(WIRE), .sel);
endmodule

module muxabcd_testbench();
	logic out; 
	logic a, b, c, d;
	logic [1:0] sel;
	
	muxabcd dut (.out, .a, .b, .c, .d, .sel);
	
	initial begin
		assign a = 0;
		assign b = 1;
		assign c = 1;
		assign d = 0;
		assign sel = 2'b10; #500;
		
		assign sel = 2'b00; #500;
		
		assign sel = 2'b01; #500;
	end
endmodule 