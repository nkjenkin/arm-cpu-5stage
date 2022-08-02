`timescale 1ps/1ps

module dec16(out, in, sel); //building block for 32bit decoder
	output logic [15:0] out;
	input logic in;
	input logic [3:0] sel;
	
	logic not_sel, topbit, not_topbit;
	
	not #50 n0 (not_sel, sel[3]);
	and #50 a0 (topbit, in, sel[3]);
	and #50 a1 (not_topbit, in, not_sel);
	
	dec8 d0 (.out(out[7:0]), .in(not_topbit), .sel(sel[2:0]));
	dec8 d1 (.out(out[15:8]), .in(topbit), .sel(sel[2:0]));
endmodule 