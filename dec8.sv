`timescale 1ps/1ps

module dec8(out, in, sel); // another building block for 32-bit decoder
	output logic [7:0] out;
	input logic in;
	input logic [2:0] sel;
	
	logic not_sel, topbit, not_topbit;
	
	not #50 n0 (not_sel, sel[2]);
	and #50 a0 (topbit, in, sel[2]);
	and #50 a1 (not_topbit, in, not_sel);
	
	dec4 d0 (.out(out[3:0]), .in(not_topbit), .sel(sel[1:0]));
	dec4 d1 (.out(out[7:4]), .in(topbit), .sel(sel[1:0]));
endmodule 