`timescale 1ps/1ps

module dec32(out, in, sel);//32 bit decoder
	// output is a 32-bit signal, either 0 or enabling one register
	output logic [31:0] out;
	
	// input signal is write enable
	input logic in;
	
	// register selection input
	input logic [4:0] sel;
	
	logic not_sel, topbit, not_topbit;
	
	// finding if write enabled and if the top bit is a 1 or 0
	not #50 n0 (not_sel, sel[4]);
	and #50 a0 (topbit, in, sel[4]);
	and #50 a1 (not_topbit, in, not_sel);
	
	// using building blocks for decoder
	dec16 d0 (.out(out[15:0]), .in(not_topbit), .sel(sel[3:0]));
	dec16 d1 (.out(out[31:16]), .in(topbit), .sel(sel[3:0]));
endmodule 

module dec32_testbench(); //testbench
	logic in;
	logic [4:0] sel;
	logic [31:0] out;
	
	dec32 dut (.out, .in, .sel);
	
	integer i;
	initial begin
		for(i=0; i<(64); i++) begin
			{in, sel[4], sel[3], sel[2], sel[1], sel[0]} = i; #400;
		end
	end
endmodule