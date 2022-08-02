module mux16_1 (out, in, sel); //16-to-1 multiplexer, building block for 32-to-1
	// output bit
	output logic out;
	
	// 16-bit input
	input logic [15:0] in;
	
	// 4-bit select
	input logic [3:0] sel;
	
	logic [1:0] WIRE;
	
	// 2 8x1 mux and 1 2x1 mux to create 16x1 mux
	mux8_1 m0(.out(WIRE[0]), .in(in[7:0]), .sel(sel[2:0]));
	mux8_1 m1(.out(WIRE[1]), .in(in[15:8]), .sel(sel[2:0]));
	mux2_1 m (.out(out), .in(WIRE[1:0]), .sel(sel[3]));
endmodule 