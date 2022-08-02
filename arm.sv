`timescale 1ps/1ps

module arm(clk, rst);
	input logic clk, rst;
	
	logic [63:0] PCin, PCout, pc_mux0, pc_mux1, se_ls;
	logic flagenable, reg2loc, uncondbr, memtoreg, memread, memwrite, alusrc, regwrite, toadd, brtaken;
	logic [31:0] instruction;
	logic [4:0] readreg2;
	logic [63:0] readdat1, readdat2, mux2alu, alu_result, dat2mux, write_mux;
	logic negative, zero, overflow, carry_out;
	logic [2:0] aluop;
	logic [63:0] cond_addr, br_addr, uncond_addr;
	logic [63:0] add_imm, mem_imm, imm_alu;
	logic [31:0][63:0] registers;
	logic [3:0] flagset;
	logic lessthanflag;
	
	//PC calc
	
	//PC + 4
	adder_64bit pca0 (.A(PCout), .B(64'b0000000000000000000000000000000000000000000000000000000000000100), .out(pc_mux0));
		
	// PC + Addr left shift
	se19 condbranch_address (.in(instruction[23:5]), .out(cond_addr));
	se26 uncondbranch_address (.in(instruction[25:0]), .out(uncond_addr));
	
	genvar i0;
	generate
		for (i0 = 0; i0 < 64; i0++) begin: cond_mux
			muxab_1 which_branch (.a(cond_addr[i0]), .b(uncond_addr[i0]), .out(br_addr[i0]), .sel(uncondbr));
		end
	endgenerate
	left_shift ls (.in(br_addr), .out(se_ls)); // shift address by 2
	adder_64bit pca1 (.A(PCout), .B(se_ls), .out(pc_mux1));
		
	// branch taken mux, either PC + 4 or PC + br_addr
	genvar l;
	generate
		for (l=0; l<64; l++) begin: mux_pc
			muxab_1 m3 (.out(PCin[l]), .a(pc_mux0[l]), .b(pc_mux1[l]), .sel(brtaken));
		end
	endgenerate	
	
	// PC
	d_ff64 d0 (.out(PCout), .in(PCin), .clk, .rst, .enable(1), .curr(PCin));
		
	// PC to InstrucMem
	instructmem instruction_memory (.address(PCout), .instruction, .clk);
	
	xor #50 x0 (lessthanflag, flagset[0], flagset[2]);
	
	// Conrol Unit
	control cntrl (.in(instruction[31:21]), .zero(zero), .negative(lessthanflag), .flagenable, .reg2loc, .uncondbr, .memtoreg, .memread, .memwrite, .alusrc, .regwrite, .toadd, .brtaken, .aluop);
	
	// InstrucMem to RegFile
	genvar i;
	generate
		for (i=0; i<5; i++) begin : mux_IM_to_RF
			muxab_1 m0 (.out(readreg2[i]), .a(instruction[i]), .b(instruction[16+i]), .sel(reg2loc));
		end
	endgenerate
	
	regfile r (.out(registers), .ReadData1(readdat1), .ReadData2(readdat2), .WriteData(write_mux), .ReadRegister1(instruction[9:5]), .ReadRegister2(readreg2), .WriteRegister(instruction[4:0]), .RegWrite(regwrite), .clk, .rst);
		
	// ALUSrc Mux
	se9 mem_addr (.in(instruction[20:12]), .out(mem_imm));
	ze12 add_addr (.in(instruction[21:10]), .out(add_imm));
	
	genvar j;
	generate
		for (j=0; j<64; j++) begin: imm_choice
			muxab_1 m1 (.out(imm_alu[j]), .a(mem_imm[j]), .b(add_imm[j]), .sel(toadd));
		end
		for (j=0; j<64; j++) begin: alu_source
			muxab_1 m2 (.out(mux2alu[j]), .a(readdat2[j]), .b(imm_alu[j]), .sel(alusrc));
		end
	endgenerate
	
	//ALU
	alu a (.A(readdat1), .B(mux2alu), .cntrl(aluop), .result(alu_result), .shamt(instruction[15:10]), .negative, .zero, .overflow, .carry_out);
	
	flags f0 (.out(flagset), .in(flagset), .enable(flagenable), .negative, .zero, .overflow, .carry_out, .clk, .rst);
	
	// Memory
	datamem d (.address(alu_result), .write_enable(memwrite), .read_enable(memread), .write_data(readdat2), .clk, .xfer_size(4'b1000), .read_data(dat2mux));
	
	// Mem to RegFile
	genvar k;
	generate
		for (k=0; k<64; k++) begin : mux_MEM_to_write
			muxab_1 m2 (.out(write_mux[k]), .a(alu_result[k]), .b(dat2mux[k]), .sel(memtoreg)); 
		end
	endgenerate
endmodule 

module arm_testbench();
	logic clk, rst;
	
	parameter ClockDelay = 50000;
	
	arm dut (.clk, .rst);
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

   integer i;
   initial begin
      rst <= 1;
      @(posedge clk);
      rst <= 0;
      for (i = 0; i < 50; i++) begin
         @(posedge clk);
      end
      $stop;
   end
endmodule 