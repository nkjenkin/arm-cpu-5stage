module ze12(in, out);
	input logic [11:0] in;
	output logic [63:0] out;
	
	// bottom bits the same as in
	assign out[11:0] = in;
	
	// top bits zero
	genvar i;
	generate
		for (i=0; i<52; i++) begin : extend
			assign out[i+12] = 0;
		end
	endgenerate
endmodule

module ze12_testbench(); //testbench for zero extend
	logic [11:0] in;
	logic [63:0] out;
	
	ze12 dut (.out, .in);
	
	initial begin
		assign in = 'b11111111111; #5000;
		assign in = 'b00000000000; #5000;
	end
endmodule  