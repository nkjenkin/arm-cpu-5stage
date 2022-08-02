module forward(Aa, Ab, regwriteEX, regwriteMEM, AwEX, AwMEM, Afwd, Bfwd);
	input logic [4:0] Aa, Ab, AwEX, AwMEM;
	input logic regwriteEX, regwriteMEM;
	output logic [1:0] Afwd, Bfwd;
	
	always_comb begin
		if (Aa == 5'b11111) Afwd = 2'b00; // if REG 31, do not forward
		else if ((AwEX == Aa) & (regwriteEX)) Afwd = 2'b01; // else if value in EX is being written (priority over MEM)
		else if ((AwMEM == Aa) & (regwriteMEM)) Afwd = 2'b10; // else if value in MEM is being written
		else Afwd = 2'b00; // no forwarding
		
		if (Ab == 5'b11111) Afwd = 2'b00; // if REG 31, do not forward
		else if ((AwEX == Ab) & (regwriteEX)) Bfwd = 2'b01; // else if value in EX is being written (priority over MEM)
		else if ((AwMEM == Ab) & (regwriteMEM)) Bfwd = 2'b10; // else if value in MEM is being written
		else Bfwd = 2'b00; // no forwarding
	end
endmodule 

module forward_testbench();
	logic [4:0] Aa, Ab, AwEX, AwMEM;
	logic regwriteEX, regwriteMEM;
	logic [1:0] Afwd, Bfwd;
	
	forward dut (.Aa, .Ab, .regwriteEX, .regwriteMEM, .AwEX, .AwMEM, .Afwd, .Bfwd);
	
	initial begin
		assign Aa = 5'b00001;
		assign Ab = 5'b00000;
		assign AwEX = 5'b00000;
		assign AwMEM = 5'b00001;
		assign regwriteEX = 0;
		assign regwriteMEM = 1;#5000;
		
		assign Aa = 5'b00000;
		assign Ab = 5'b00000;
		assign AwEX = 5'b00000;
		assign AwMEM = 5'b00000;
		assign regwriteEX = 1;
		assign regwriteMEM = 0;#5000;
		
		assign Aa = 5'b00000;
		assign Ab = 5'b00000;
		assign AwEX = 5'b00000;
		assign AwMEM = 5'b00000;
		assign regwriteEX = 0;
		assign regwriteMEM = 1;#5000;
		
		
		assign Aa = 5'b00000;
		assign Ab = 5'b00000;
		assign AwEX = 5'b00000;
		assign AwMEM = 5'b00000;
		assign regwriteEX = 1;
		assign regwriteMEM = 1;#5000;
		
		
		assign Aa = 5'b00000;
		assign Ab = 5'b00000;
		assign AwEX = 5'b00001;
		assign AwMEM = 5'b00001;
		assign regwriteEX = 0;
		assign regwriteMEM = 1;#5000;
		
		assign Aa = 5'b00000;
		assign Ab = 5'b00000;
		assign AwEX = 5'b00001;
		assign AwMEM = 5'b00001;
		assign regwriteEX = 1;
		assign regwriteMEM = 0;#5000;
		
		assign Aa = 5'b00000;
		assign Ab = 5'b00000;
		assign AwEX = 5'b00001;
		assign AwMEM = 5'b00001;
		assign regwriteEX = 1;
		assign regwriteMEM = 1;#5000;
		
	end
endmodule 