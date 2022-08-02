module mux8_1 (out, in, sel); //8 to 1 mux
	// output bit
	output logic out;
	
	// 8-bit input
	input logic [7:0] in;
	
	// 3-bit select
	input logic [2:0] sel;
	
	logic [1:0] WIRE;
	
	// use two 4x1 mux and one 2x1 mux to make 8x1
	mux4_1 m0(.out(WIRE[0]), .in(in[3:0]), .sel(sel[1:0]));
	mux4_1 m1(.out(WIRE[1]), .in(in[7:4]), .sel(sel[1:0]));
	mux2_1 m (.out(out), .in(WIRE[1:0]), .sel(sel[2]));
endmodule 