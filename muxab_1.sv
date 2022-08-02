`timescale 1ps/1ps

module muxab_1 (out, a, b, sel);
	output logic out;
	input logic a, b;
	input logic sel;
	
	logic [1:0] WIRE;
	
	assign WIRE[0] = a;
	assign WIRE[1] = b;
	
	mux2_1 m (.out, .in(WIRE), .sel);
	
endmodule 

module muxab_1_testbench(); //testbench for 2-to-1
	logic a, b;
	logic sel;
	logic out;
	
	muxab_1 dut (.out, .a, .b, .sel);
	
	integer i;
	initial begin
		for(i=0; i<(8); i++) begin
			{sel, a, b} = i; #250;
		end
	end
endmodule 