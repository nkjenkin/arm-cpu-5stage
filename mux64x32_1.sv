module mux64x32_1(out, in, sel); // 64 32-to-1 multiplexers, for the 32 64-bit registers (one multiplexer per bit)
	// output is a 64-bit signal
	output logic [63:0] out;
	
	//input is 32 64-bit signals
	input logic [2047:0] in;
	
	//5-bit selection input
	input logic [4:0] sel;
	
	logic [63:0][31:0] WIRE;
	
	//takes in one bit from each register (32 bits total) at a time and passes through 32-to-1 mux so correct bit is being read
	genvar i, j;
	generate
		for (i=0; i<64; i++) begin : eachMUX
			for (j=0; j<32; j++) begin: eachREG
				assign WIRE[i][j] = in[(64*j)+i];
			end
			mux32_1 m0 (.out(out[i]), .in(WIRE[i][31:0]), .sel(sel[4:0]));
		end
	endgenerate
	
endmodule 