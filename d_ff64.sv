`timescale 1ps/1ps

module d_ff64(out, in, clk, enable, curr, rst);
	// outputs a d flip flop with 64 bits, aka a register
	output logic [63:0] out;
	
	//inputs are the write data, clock, and enable
	input logic [63:0] in, curr;
	input logic clk, enable, rst;
		
	logic [63:0] WIRE0;
	logic [63:0] WIRE1;
	logic [63:0] WIRE2;
	logic not_enable;
	
	not #50 n0 (not_enable, enable);
	
	//if not enable, out stays same
	//if enable, then out is in
	
	//generate function to create 64 d flip flops (aka 64bit register)
	genvar i; 
	generate
		for (i=0; i<64; i++) begin : eachDFF
			//if enable and in, then out is in
			and #50 a0 (WIRE0[i], in[i], enable);
			//if not enable, then out is unchanged
			and #50 a2 (WIRE1[i], curr[i], not_enable);
			
			or #50 o0 (WIRE2[i], WIRE1[i], WIRE0[i]);
			
			D_FF d0 (.q(out[i]), .d(WIRE2[i]), .clk(clk), .reset(rst));
		end
	endgenerate
endmodule 