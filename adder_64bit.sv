module adder_64bit(A, B, out);
	input logic [63:0] A, B;
	output logic [63:0] out;

	logic [64:0] carry_out;
	
	// first carry_in is 0
	assign carry_out[0] = 0;
	
	//generate 64 1-bit adders
	genvar i;
	generate
		for (i=0; i<64; i++) begin : mux_IM_to_RF
			adder a0 (.A(A[i]), .B(B[i]), .carry_in(carry_out[i]), .carry_out(carry_out[i+1]), .out(out[i]));
		end
	endgenerate 
endmodule 

module adder_64bit_testbench(); // testbench for single bit adder
	logic [63:0] A, B, out;
	
	adder_64bit  dut (.A, .B, .out);
	
	initial begin
		assign A = 0;
		assign B = 0; #5000;
		
		assign A = 0;
		assign B = 1; #5000;
		
		assign A = 456;
		assign B = 1200; #5000;
		
		assign A = 2340;
		assign B = 129; #5000;
		
		assign A = 349;
		assign B = 1002; #5000;
	end
endmodule 