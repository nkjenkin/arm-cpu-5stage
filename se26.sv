module se26(in, out);
	input logic [25:0] in;
	output logic [63:0] out;
	
	// bottom bits the same as in
	assign out[25:0] = in;
	
	// top bits the same as sign bit of in
	genvar i;
	generate
		for (i=0; i<38; i++) begin : extend
			assign out[i+26] = in[25];
		end
	endgenerate
endmodule

module se26_testbench(); //testbench for sign extend
	logic [25:0] in;
	logic [63:0] out;
	
	se26 dut (.out, .in);
	
	initial begin
		assign in = 'b10000000000000000000000000; #5000;
		assign in = 'b01111111111111111111111111; #5000;
	end
endmodule  