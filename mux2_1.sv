`timescale 1ps/1ps

module mux2_1 (out, in, sel); // building block for 32-to-1 multiplexer
	output logic out;
	input logic [1:0] in;
	input logic sel;
	
	logic [1:0] WIRE;
	logic not_sel;
	
	not #50 n0 (not_sel, sel);
	
	and #50 a0 (WIRE[0], in[0], not_sel);
	and #50 a1 (WIRE[1], in[1], sel);
	
	or #50 o0 (out, WIRE[0], WIRE[1]);
	
endmodule 

module mux2_1_testbench(); //testbench for 2-to-1
	logic [1:0] in;
	logic sel;
	logic out;
	
	mux2_1 dut (.out, .in, .sel);
	
	integer i;
	initial begin
		for(i=0; i<(8); i++) begin
			{sel, in[0], in[1]} = i; #250;
		end
	end
endmodule 