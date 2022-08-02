`timescale 1ps/1ps

module flags(out, in, enable, zero, negative, overflow, carry_out, clk, rst); // to set the flags
	// flagset[0] = negative
	// flagset[1] = zero
	// flagset[2] = overflow
	// flagset[3] = carry out

	input logic enable, zero, negative, overflow, carry_out, clk, rst;
	input logic [3:0] in;
	output logic [3:0] out;
	
	logic [3:0] WIRE0, WIRE1, WIRE2, update;
	logic not_enable, inv_clk;
	not #50 n0 (not_enable, enable);
	not #50 n1 (inv_clk, clk); // invert clock so that ALU can compute flags before storing in this flag register
	
	
	assign update[0] = negative;
	assign update[1] = zero;
	assign update[2] = overflow;
	assign update[3] = carry_out;
	
	
	// update flags if enable
	genvar i;
	generate 
		for (i = 0; i<4; i++) begin : flagupdate
			and #50 a0 (WIRE0[i], update[i], enable);
			and #50 a1 (WIRE1[i], in[i], not_enable);
			or #50 o0 (WIRE2[i], WIRE0[i], WIRE1[i]);
			D_FF d0 (.q(out[i]), .d(WIRE2[i]), .clk(inv_clk), .reset(rst));
		end
	endgenerate
endmodule 

module flags_testbench(); //testbench for 2-to-1
	logic enable, zero, negative, overflow, carry_out, clk, rst;
	logic [3:0] in;
	logic [3:0] out;	
	
	
	parameter ClockDelay = 5000;
	
	flags dut (.out, .in, .enable, .zero, .negative, .overflow, .carry_out, .clk, .rst);
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
		rst <= 1;
		@(posedge clk);
		rst <= 0;
		enable <= 1;
		zero <= 1;
		negative <= 1;
		overflow <= 1;
		carry_out <= 1;
		in <= 4'b0010; #20000;
		
		@(posedge clk);
		enable <= 0;
		zero <= 1;
		negative <= 1;
		overflow <= 1;
		carry_out <= 1;
		in <= 4'b0010; #20000;
	end
endmodule 