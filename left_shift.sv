module left_shift(in, out);
	input logic [63:0] in;
	output logic [63:0] out;
	
	// shift by 2 to the left: take all but two most significant bits and move to the left two, pad with zeros
	assign out[63:2] = in[61:0];
	
	assign out[1:0] = 2'b00;
endmodule 

module left_shift_testbench(); // testbench for left_shift
	logic [63:0] in, out;
	
	left_shift dut (.in, .out);
	
	initial begin
		assign in = 1; #5000;
		assign in = 2; #5000;
		assign in = 256; #5000;
		assign in = 51803; #5000;
	end
endmodule 