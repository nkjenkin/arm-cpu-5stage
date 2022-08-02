module mux4_1(out, in, sel); // a 4 to 1 multiplexer to use in 32 to 1
	// one output bit
	output logic out;
	
	// four input bits
	input logic [3:0] in;
	
	// two selection bits, for choosing input
	input logic [1:0] sel;
	
	logic [1:0] WIRE;
	
	mux2_1 m0(.out(WIRE[0]), .in(in[1:0]), .sel(sel[0]));
	mux2_1 m1(.out(WIRE[1]), .in(in[3:2]), .sel(sel[0]));
	mux2_1 m (.out(out), .in(WIRE[1:0]), .sel(sel[1]));
endmodule 