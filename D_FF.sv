module D_FF (q, d, clk, reset); // D flip flop given in specs, reset taken out because no reset for this lab (no reset in regstim.v)
	output reg q;
	input d, clk;
	input reset;
	
	always_ff @(posedge clk)
	if (reset)
		q <= 0; // On reset, set to 0
	else
		q <= d; // Otherwise out = d
endmodule 