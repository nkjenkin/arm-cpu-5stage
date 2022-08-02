`timescale 1ps/1ps

module arm_pipelined(clk, rst);
	input logic clk, rst;
	
	logic [63:0] PCin, PCout, pc_mux0, pc_mux1, se_ls; // PC calc
	logic flagenable, reg2loc, uncondbr, memtoreg, memread, memwrite, alusrc, regwrite, toadd, brtaken; // Control Logic
	logic flagenableEX, memtoregEX, memreadEX, memwriteEX, regwriteEX; // Reg/Dec to Execute registers
	logic [2:0] aluopEX;
	logic memtoregMEM, memreadMEM, memwriteMEM, regwriteMEM, regwriteWB; // Ex to Mem and Mem to Write registers
	logic [31:0] instIFETCH, instREG, instEX, instMEM, instWB; // instructions
	logic [4:0] readreg2; // ReadReg2 mux
	logic [63:0] Dw, readdat2MEM, readdat1EX, readdat2EX, readdat1REG, readdat2, mux2alu, alu_result, dat2mux, write_mux; // data streams
	logic negative, zero, overflow, carry_out; // alu flag output
	logic [2:0] aluop;
	logic [63:0] forward_out1, forward_out2, regdat2EX; // forwarding unit data
	logic [63:0] cond_addr, br_addr, uncond_addr, addr_comp, br_addr_pipe; // addressess 
	logic [63:0] add_imm, mem_imm, imm_alu; // immediate values
	logic [31:0][63:0] registersREG; // registers in REG, registers in WB
	logic [3:0] flagset; // flag set hold
	logic lessthanflag; // for less than branch
	logic [1:0] Afwd, Bfwd;	// forwarding control
	
	
	
	
	// IFetch
	
	// PC Update
	d_ff64 d0 (.out(PCout), .in(PCin), .clk, .rst, .enable(1'b1), .curr(PCin));
		
	// PC to InstrucMem
	instructmem instruction_memory (.address(PCout), .instruction(instIFETCH), .clk);
	
	
	
	
	// IFetch to RegDec Registers
	genvar i1;
	generate
		for (i1 = 0; i1 < 32; i1++) begin: instructionregister
			D_FF IFETCH2REG (.q(instREG[i1]), .d(instIFETCH[i1]), .clk, .reset(rst));
		end
	endgenerate
	
	
	
	
	// RegDec
	
	// Control Unit

	xor #50 x0 (lessthanflag, flagset[0], flagset[2]);
	control cntrl (.in(instREG[31:21]), .zero(cbz_zero), .negative(lessthanflag), .flagenable, .reg2loc, .uncondbr, .memtoreg, .memread, .memwrite, .alusrc, .regwrite, .toadd, .brtaken, .aluop);
	
	// which register
	genvar i;
	generate
		for (i=0; i<5; i++) begin : mux_IM_to_RF
			muxab_1 m0 (.out(readreg2[i]), .a(instREG[i]), .b(instREG[16+i]), .sel(reg2loc));
		end
	endgenerate
	
	// register file
	regfile r (.out(registersREG), .ReadData1(readdat1REG), .ReadData2(readdat2), .WriteData(Dw), .ReadRegister1(instREG[9:5]), .ReadRegister2(readreg2), .WriteRegister(instWB[4:0]), .RegWrite(regwriteWB), .clk, .rst);
	
	//Forwarding
	forward forwarding_unit (.Aa(instREG[9:5]), .Ab(readreg2), .regwriteEX, .regwriteMEM, .AwEX(instEX[4:0]), .AwMEM(instMEM[4:0]), .Afwd, .Bfwd);
	
	genvar f;
	generate
		for (f=0; f<64; f++) begin : forwardmuxes
			muxabcd forwardmux1 (.out(forward_out1[f]), .a(readdat1REG[f]), .b(alu_result[f]), .c(write_mux[f]), .d(1'b0), .sel(Afwd));
			muxabcd forwardmux2 (.out(forward_out2[f]), .a(readdat2[f]), .b(alu_result[f]), .c(write_mux[f]), .d(1'b0), .sel(Bfwd));
		end
	endgenerate
	
	// ALUSrc Mux
	se9 mem_addr (.in(instREG[20:12]), .out(mem_imm));
	ze12 add_addr (.in(instREG[21:10]), .out(add_imm));
	
	genvar j;
	generate
		for (j=0; j<64; j++) begin: imm_choice
			muxab_1 m1 (.out(imm_alu[j]), .a(mem_imm[j]), .b(add_imm[j]), .sel(toadd));
		end
		for (j=0; j<64; j++) begin: alu_source
			muxab_1 m2 (.out(mux2alu[j]), .a(forward_out2[j]), .b(imm_alu[j]), .sel(alusrc));
		end
	endgenerate
	
	// Accelerate Branches
	zero64 cbzcheck (.in(forward_out2), .out(cbz_zero));
	
	// PC calculation 
	adder_64bit pca0 (.A(PCout), .B(64'b0000000000000000000000000000000000000000000000000000000000000100), .out(pc_mux0));
		
	se19 condbranch_address (.in(instREG[23:5]), .out(cond_addr));
	se26 uncondbranch_address (.in(instREG[25:0]), .out(uncond_addr));
	
	// condition branch
	genvar i0;
	generate
		for (i0 = 0; i0 < 64; i0++) begin: cond_mux
			muxab_1 which_branch (.a(cond_addr[i0]), .b(uncond_addr[i0]), .out(br_addr[i0]), .sel(uncondbr));
		end
	endgenerate
	
	adder_64bit subtract_one (.A(br_addr), .B(64'b1111111111111111111111111111111111111111111111111111111111111111), .out(br_addr_pipe));
	left_shift ls (.in(br_addr_pipe), .out(se_ls));
	adder_64bit pca1 (.A(PCout), .B(se_ls), .out(pc_mux1));
		
	// branch taken mux, either PC + 4 or PC + br_addr
	genvar l;
	generate
		for (l=0; l<64; l++) begin: mux_pc
			muxab_1 m3 (.out(PCin[l]), .a(pc_mux0[l]), .b(pc_mux1[l]), .sel(brtaken));
		end
	endgenerate		
	
	
	
	
	// RegDec to Exec Registers
	genvar i2;
	generate
		for (i2 = 0; i2 < 32; i2++) begin: exinstreg
			D_FF REG2EX (.q(instEX[i2]), .d(instREG[i2]), .clk, .reset(rst));
		end
	endgenerate
	
	d_ff64 data1REG2EX (.out(readdat1EX), .in(forward_out1), .clk, .enable(1'b1), .curr(forward_out1), .rst);
	d_ff64 data2REG2EX (.out(readdat2EX), .in(mux2alu), .clk, .enable(1'b1), .curr(mux2alu), .rst);
	d_ff64 data2registerval (.out(regdat2EX), .in(forward_out2), .clk, .enable(1'b1), .curr(forward_out2), .rst);
	D_FF feREG2EX (.q(flagenableEX), .d(flagenable), .clk, .reset(rst));
	D_FF m2rREG2EX (.q(memtoregEX), .d(memtoreg), .clk, .reset(rst));
	D_FF mrREG2EX (.q(memreadEX), .d(memread), .clk, .reset(rst));
	D_FF mwREG2EX (.q(memwriteEX), .d(memwrite), .clk, .reset(rst));
	D_FF rwREG2EX (.q(regwriteEX), .d(regwrite), .clk, .reset(rst));

	genvar a;
	generate
		for (a = 0; a<3; a++) begin: aluopREG2EX
			D_FF aoREG2EX (.q(aluopEX[a]), .d(aluop[a]), .clk, .reset(rst));
		end
	endgenerate
	
	
	// Execute
	alu alu_element (.A(readdat1EX), .B(readdat2EX), .cntrl(aluopEX), .result(alu_result), .shamt(instEX[15:10]), .negative, .zero, .overflow, .carry_out);
	
	// flag register
	flags f0 (.out(flagset), .in(flagset), .enable(flagenableEX), .negative, .zero, .overflow, .carry_out, .clk, .rst);
	
	
	
	
	// EX to MEM Registers
	
	genvar i3;
	generate
		for (i3 = 0; i3 < 32; i3++) begin: meminstreg
			D_FF EX2MEM (.q(instMEM[i3]), .d(instEX[i3]), .clk, .reset(rst));
		end
	endgenerate
	
	d_ff64 aluresEX2MEM (.out(addr_comp), .in(alu_result), .clk, .enable(1'b1), .curr(alu_result), .rst);
	d_ff64 readdat2EX2MEM (.out(readdat2MEM), .in(regdat2EX), .clk, .enable(1'b1), .curr(readdat2EX), .rst); 
	D_FF m2rEX2MEM (.q(memtoregMEM), .d(memtoregEX), .clk, .reset(rst));
	D_FF mrEX2MEM (.q(memreadMEM), .d(memreadEX), .clk, .reset(rst));
	D_FF mwEX2MEM (.q(memwriteMEM), .d(memwriteEX), .clk, .reset(rst));
	D_FF rwEX2MEM (.q(regwriteMEM), .d(regwriteEX), .clk, .reset(rst));	
	
	
	// Memory
	
	datamem d (.address(addr_comp), .write_enable(memwriteMEM), .read_enable(memreadMEM), .write_data(readdat2MEM), .clk, .xfer_size(4'b1000), .read_data(dat2mux));
	
	// Mem to RegFile
	genvar k;
	generate
		for (k=0; k<64; k++) begin : mux_MEM_to_write
			muxab_1 m2 (.out(write_mux[k]), .a(addr_comp[k]), .b(dat2mux[k]), .sel(memtoregMEM)); 
		end
	endgenerate
	
	
	
	// MEM to WB Registers
	
	genvar i4;
	generate
		for (i4 = 0; i4 < 32; i4++) begin: wbinstreg
			D_FF MEM2WB (.q(instWB[i4]), .d(instMEM[i4]), .clk, .reset(rst));
		end
	endgenerate
	
	d_ff64 memout (.out(Dw), .in(write_mux), .clk, .enable(1'b1), .curr(write_mux), .rst);
	D_FF rwMEM2WB (.q(regwriteWB), .d(regwriteMEM), .clk, .reset(rst));
endmodule 





module arm_pipelined_testbench();
	logic clk, rst;
	
	parameter ClockDelay = 20000;
	
	arm_pipelined	dut (.clk, .rst);
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

   integer i;
   initial begin
      rst <= 1;
      @(posedge clk);
      rst <= 0;
      for (i = 0; i < 100; i++) begin // change loops based on program (long or short) for faster runtimes
         @(posedge clk);
      end
      $stop;
   end
endmodule 