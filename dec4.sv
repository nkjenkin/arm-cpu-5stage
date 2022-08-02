`timescale 1ps/1ps

module dec4(out, in, sel); // 4 bit decoder, building block for 32 bit decoder
	output logic [3:0] out;
	input logic in;
	input logic [1:0]sel;
	
	logic [1:0] not_sel;
	
	// nots of the selection input
	not #50 n0 (not_sel[0], sel[0]);
	not #50 n1 (not_sel[1], sel[1]);
	
	// selecting the correct register (if enabled, ie in==1)
	and #50 a0 (out[0], not_sel[0], not_sel[1], in);
	and #50 a1 (out[1], sel[0], not_sel[1], in);
	and #50 a2 (out[2], not_sel[0], sel[1], in);
	and #50 a3 (out[3], sel[0], sel[1], in);
endmodule

module dec4_testbench(); //testbench
	logic in;
	logic [1:0] sel;
	logic [3:0] out;
	
	dec4 dut (.out, .in, .sel);
	
	integer i;
	initial begin
		for(i=0; i<(8); i++) begin
			{sel[1], sel[0], in} = i; #250;
		end
	end
endmodule