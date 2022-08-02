module se19(in, out);
	input logic [18:0] in;
	output logic [63:0] out;
	
	// bottom bits the same as in
	assign out[18:0] = in;
	
	// top bits the same as sign bit of in
	genvar i;
	generate
		for (i=0; i<45; i++) begin : extend
			assign out[i+19] = in[18];
		end
	endgenerate
endmodule

module se19_testbench(); //testbench for sign extend
	logic [18:0] in;
	logic [63:0] out;
	
	se19 dut (.out, .in);
	
	initial begin
		assign in = 'b1000000000000000000; #5000;
		assign in = 'b0111111111111111111; #5000;
	end
endmodule  