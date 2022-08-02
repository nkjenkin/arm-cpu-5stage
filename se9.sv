module se9(in, out);
	input logic [8:0] in;
	output logic [63:0] out;
	
	// bottom bits the same as in
	assign out[8:0] = in;
	
	// top bits the same as sign bit of in
	genvar i;
	generate
		for (i=0; i<55; i++) begin : extend
			assign out[i+9] = in[8];
		end
	endgenerate
endmodule

module se9_testbench(); //testbench for sign extend
	logic [31:0] in;
	logic [63:0] out;
	
	se9 dut (.out, .in);
	
	initial begin
		assign in = 'b100000000; #5000;
		assign in = 'b011111111; #5000;
	end
endmodule  