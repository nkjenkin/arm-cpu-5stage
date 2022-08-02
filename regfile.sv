`timescale 1ps/1ps

module regfile(out, ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk, rst);
	// output: read data 1 and read data 2
	output logic [63:0] ReadData1, ReadData2;
	output logic [31:0][63:0] out;
	// inputs: read register 1 and 2, write register, write data, and register write
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData;
	input logic RegWrite, clk, rst;
	
	// inverted clock
	logic inv_clk;
	// logic (wires) from the decoder to the registers (32 wires) and from the registers to the multiplexer (32 "blocks" of 64 bits, 2048 bits total)
	logic [31:0] decoderTOregister;
	logic [2047:0] registerTOmux;
	
	not #50 n0 (inv_clk, clk);
	
	// decoder
	dec32 dec (.out(decoderTOregister[31:0]), .in(RegWrite), .sel(WriteRegister[4:0]));
	
	// generate function for generating each register with a 64bit D flip flop
	genvar i;
	generate
		for (i=0; i<31; i++) begin : eachREG
			d_ff64 d_ff32x64 (.out(registerTOmux[64*(i+1)-1:64*i]), .in(WriteData[63:0]), .clk(inv_clk), .rst(rst), .enable(decoderTOregister[i]), .curr(registerTOmux[64*(i+1)-1:64*i]));
		end
	endgenerate
	
	// hard wire x31 to be 0
	assign registerTOmux[2047:1984] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
	
	// multiplexers, 64 32to1 multiplexers (one mux for each bit, 32 registers to one write out)
	mux64x32_1 mux0 (.out(ReadData1[63:0]), .in(registerTOmux[2047:0]), .sel(ReadRegister1[4:0]));
	mux64x32_1 mux1 (.out(ReadData2[63:0]), .in(registerTOmux[2047:0]), .sel(ReadRegister2[4:0]));
	
	//assigning registers to out
	genvar j;
	generate
		for (j=0; j<32; j++) begin: registers
			assign out[j] = registerTOmux[64*(j+1)-1 : 64*j];
		end
	endgenerate
endmodule 