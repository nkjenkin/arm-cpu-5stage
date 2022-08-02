module control (in, zero, negative,	flagenable, reg2loc, uncondbr, memtoreg, memread, memwrite, alusrc, regwrite, toadd, brtaken, aluop);
	input logic [10:0] in;
	input logic zero, negative;
	output logic flagenable, reg2loc, uncondbr, memtoreg, memread, memwrite, alusrc, regwrite, toadd, brtaken;
	output logic [2:0] aluop;
	
	
	
	
	always_comb begin
		casez(in)
			11'b1001000100?: begin //ADDI
				flagenable = 0;
				reg2loc = 1'bX; 
				uncondbr = 1'bX;
				memtoreg = 0;
				memread = 1'bX;
				memwrite = 0;
				alusrc = 1;
				regwrite = 1;
				toadd = 1;
				brtaken = 0;
				aluop = 3'b010;
				end
			11'b10101011000: begin // ADDS
				flagenable = 1;
				reg2loc = 1;
				uncondbr = 1'bX;
				memtoreg = 0;
				memread = 1'bX;
				memwrite = 0;
				alusrc = 0;
				regwrite = 1;
				toadd = 1'bX;
				brtaken = 0;
				aluop = 3'b010;
				end
			11'b10001010000: begin // AND
				flagenable = 0;
				reg2loc = 1;
				uncondbr = 1'bX;
				memtoreg = 0;
				memread = 1'bX;
				memwrite = 0;
				alusrc = 0;
				regwrite = 1;
				toadd = 1'bX;
				brtaken = 0;
				aluop = 3'b100;
				end
			11'b000101?????: begin // B
				flagenable = 0;
				reg2loc = 1'bX;
				uncondbr = 1;
				memtoreg = 1'bX;
				memread = 1'bX;
				memwrite = 0;
				alusrc = 1'bX;
				regwrite = 0;
				toadd = 1'bX;
				brtaken = 1;
				aluop = 3'bXXX;
				end
			11'b01010100???: begin //B.LT
				flagenable = 0;
				reg2loc = 1'bX;
				uncondbr = 0;
				memtoreg = 1'bX;
				memread = 1'bX;
				memwrite = 0;
				alusrc = 1'bX;
				regwrite = 0;
				toadd = 1'bX;
				brtaken = negative;
				aluop = 3'bXXX;
				end
			11'b10110100???: begin // CBZ
				flagenable = 1;
				reg2loc = 0;
				uncondbr = 0;
				memtoreg = 1'bX;
				memread = 1'bX;
				memwrite = 0;
				alusrc = 0;
				regwrite = 0;
				toadd = 1'bX;
				brtaken = zero;
				aluop = 3'b000;
				end
			11'b11001010000: begin // EOR
				flagenable = 0;
				reg2loc = 1;
				uncondbr = 1'bX;
				memtoreg = 0;
				memread = 1'bX;
				memwrite = 0;
				alusrc = 0;
				regwrite = 1;
				toadd = 1'bX;
				brtaken = 0;
				aluop = 3'b110;
				end
			11'b11111000010: begin // LDUR
				flagenable = 0;
				reg2loc = 0;
				uncondbr = 1'bX;
				memtoreg = 1;
				memread = 1;
				memwrite = 0;
				alusrc = 1;
				regwrite = 1;
				toadd = 0;
				brtaken = 0;
				aluop = 3'b010;
				end
			11'b11010011010: begin // LSR
				flagenable = 0;
				reg2loc = 1'bX;
				uncondbr = 1'bX;
				memtoreg = 0;
				memread = 1'bX;
				memwrite = 0;
				alusrc = 1'bX;
				regwrite = 1;
				toadd = 1'bX;
				brtaken = 0;
				aluop = 3'b111;
				end
			11'b11111000000: begin // STUR
				flagenable = 0;
				reg2loc = 0;
				uncondbr = 1'bX;
				memtoreg = 1'bX;
				memread = 0;
				memwrite = 1;
				alusrc = 1;
				regwrite = 0;
				toadd = 0;
				brtaken = 0;
				aluop = 3'b010;
				end
			11'b11101011000: begin // SUBS
				flagenable = 1;
				reg2loc = 1;
				uncondbr = 1'bX;
				memtoreg = 0;
				memread = 1'bX;
				memwrite = 0;
				alusrc = 0;
				regwrite = 1;
				toadd = 1'bX;
				brtaken = 0;
				aluop = 3'b011;
				end
			default: begin
				flagenable = 0;
				reg2loc = 0;
				uncondbr = 0;
				memtoreg = 0;
				memread = 0;
				memwrite = 0;
				alusrc = 0;
				regwrite = 0;
				toadd = 0;
				brtaken = 0;
				end
		endcase
	end
endmodule 

module control_testbench();
	logic [10:0] in;
	logic reg2loc, uncondbr, memtoreg, memread, memwrite, alusrc, regwrite, toadd, brtaken;
	logic [2:0] aluop;
	
	control dut (.in, .reg2loc, .uncondbr, .memtoreg, .memread, .memwrite, .alusrc, .regwrite, .toadd, .brtaken, .aluop);
	
	initial begin
		assign in = 11'b00010100000; #5000;
		assign in = 11'b10010001001; #5000;
	end
endmodule 