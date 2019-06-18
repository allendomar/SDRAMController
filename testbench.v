`timescale 1 ns / 1 ns
`include "sm_sdram_settings.vh"

module testbench;
	
	parameter Tt = 500;
	reg clk;
	integer count;
	initial begin
		clk = 0;
		for (count = 0; count < 100; count = count + 1)
			clk = #(Tt/2) ~clk;
	end
	
	reg rst_n, cs, we;
	wire re;
	reg  [ 5: 0] a;
	reg  [31: 0] wd;
	wire [31: 0] rd;
	wire ready;
	
	// sdram signals
	wire sd_clk, sd_cke, sd_cs, sd_we, sd_cas, sd_ras, sd_ldqm, sd_udqm;
	wire [1:0] sd_bs;
	wire [11:0] s_a;
	wire [15:0] s_dq;
	wire [3:0] cmd;
	
	wire [31:0] ctrl_wmem, ctrl_rmem;
	wire [3:0] ctrl_iter, ctrl_cl;
	wire [15:0] ctrl_wdata, ctrl_rdata;
	wire ctrl_we_state;
	
	localparam ADDR = 6'b001011;
	localparam DATA = 32'h5F2B091A;
	localparam INIT_DELAY = 2;
	localparam LOAD_MODE_DELAY = 2;
	
	reg [31:0] ram [0:31];
	reg ram_enable;
	
	assign cmd = { sd_cs, sd_ras, sd_cas, sd_we };
	//assign rev_addr = { s_a[4], s_a[3], s_a[2], s_a[1], s_a[0] };
	
	assign ctrl_wmem = ram_ctrl.wmem;
	assign ctrl_rmem = ram_ctrl.rmem;
	assign ctrl_iter = ram_ctrl.iter;
	assign ctrl_cl = ram_ctrl.cl;
	assign ctrl_wdata = ram_ctrl.wdata;
	assign ctrl_rdata = ram_ctrl.rdata;
	assign ctrl_we_state = ram_ctrl.we_state;
	
	reg [15:0] result;
	assign s_dq = ~ctrl_we_state ? result : 16'bz;
	
	initial begin
		sdram_init;
		
		rst_n = `HIGHT;
		cs = `HIGHT;
		we = `LOW;
		a = { 6 { `LOW } };
		wd = { 32 { 1'bx } };
		ram_enable = `HIGHT;
		repeat (9 + INIT_DELAY * 2 + LOAD_MODE_DELAY)  @(posedge clk);
		
		a = ADDR;
		repeat (1) @(posedge clk);
		
		a = { 6 { `LOW } };
		repeat (8) @(posedge clk);
		
		we = `HIGHT;
		a = ADDR;
		wd = DATA;
		repeat (1) @(posedge clk);
		
		we = `LOW;
		a = { 6 { `LOW } };
		wd = { 32 { 1'bx } };
		repeat (4) @(posedge clk);
		
		a = ADDR;
		repeat (1) @(posedge clk);
		
		a = { 6 { `LOW } };
		
	end
	
	always @(posedge sd_clk) begin
		sdram_read(ram_ctrl.command, result);
		sdram_write(ram_ctrl.command, s_dq);
	end
	
	sm_sdram_controller #(3, INIT_DELAY) ram_ctrl
	(
		.clkIn   (clk),
		.rst_n   (rst_n),
		.cs      (cs),
		.we      (we),
		.re      (re),
		.ready   (ready),
		.a       (a),
		.wd      (wd),
		.rd      (rd),
	
		// sdram signals
		.sd_clk  (sd_clk),
		.sd_cke  (sd_cke),
		.sd_cs   (sd_cs),
		.sd_we   (sd_we),
		.sd_cas  (sd_cas),
		.sd_ras  (sd_ras),
		.sd_ldqm (sd_ldqm),
		.sd_udqm (sd_udqm),
		.sd_bs   (sd_bs),
		.s_a     (s_a), 
		.s_dq    (s_dq)
	);
	
	task sdram_init;
		begin
			ram[0] = 32'hffff;
			ram[ADDR] = 32'hAAAAAAAA;
			ram_enable = `LOW;
		end
	endtask
	
	task sdram_read
	(
		input      [ 4:0] ram_cmd,
		output reg [15:0] out_result
	);
		reg [31:0] buffer;
		reg [15:0] cl1_result, cl2_result;
		reg [5:0] rev_addr;
		reg [1:0] put;
	
		begin
			out_result = cl2_result;
			cl2_result = cl1_result;
			if (ram_cmd == `CMD_ACTIV && ram_enable) begin
				rev_addr = s_a[4:0];
				put = 1;
			end
			else
			if (ram_cmd == `CMD_ANOP) begin
				put = 1;
			end
			else
			if (ram_ctrl.command == `CMD_READ) begin
				cl1_result = buffer[15:0];
				buffer = ram[rev_addr];
			end
			else
			if (ram_cmd == `CMD_NOP && ~we && put != 0) begin
				if (put == 1) begin
					cl1_result = buffer[15:0];
					put = put + 1;
				end
				else if (put == 2) begin
					cl1_result = buffer[31:16];
					put = 0;
				end
			end
			else begin
				rev_addr = 6'bx;
				cl1_result = 16'bx;
				buffer = 32'bx;
				put = 0;
			end
		end
	endtask
	
	task sdram_write
	(
		input      [ 4:0] ram_cmd,
		input      [15:0] dq
	);
		reg [5:0] rev_addr;
		reg [1:0] get;
		
		begin
			if (ram_cmd == `CMD_ACTIV && ram_enable) begin
				rev_addr = s_a[4:0];
			end
			else
			if (ram_cmd == `CMD_WRITE && ram_enable) begin
				ram[rev_addr][15:0] = dq;
				get = 1;
			end
			else
			if (ram_cmd == `CMD_NOP && ram_enable && get == 1) begin
				ram[rev_addr][31:16] = dq;
				get = 0;
			end
		end
	endtask
	
endmodule
