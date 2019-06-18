`timescale 1 us / 1 us
`include "sm_sdram_settings.vh"

module sm_sdram_controller
#(
    parameter CAS_LATENCY = 3,
	 parameter INIT_CYCL   = 100
)
(
	// control signals
	input              clkIn,
	input              rst_n,
	input              cs,
	input              we,
	output reg         re,
	output reg         ready,
	input      [ 5: 0] a, // row address
	input      [31: 0] wd,
	output     [31: 0] rd,
	
	// sdram signals
	output             sd_clk,
	output             sd_cke,
	output             sd_cs,
	output             sd_we,
	output             sd_cas,
	output             sd_ras,
	output             sd_ldqm,
	output             sd_udqm,
	output     [ 1: 0] sd_bs, // bank address
	output reg [11: 0] s_a, 
	inout      [15: 0] s_dq
);

	localparam CMD_CYCL = 5;

	assign sd_clk = clkIn;
	assign sd_cke = `HIGHT;
	assign sd_bs  = 2'b01;
	reg [4:0] command;
	reg [15:0] wdata, rdata;
	reg [31:0] wmem, rmem;
	reg we_state;
	reg [3:0] iter, cl, end_cycl;
	
	assign s_dq = we_state ? wdata : `UNDEF16;
	assign rd = rmem;
	
	reg init;
	
	initial begin
		initialize;
		load_register_mode;
	end
	
	always @(posedge clkIn) begin
		if (~rst_n) begin
			initialize;
		end
		else if (cs & ~init) begin
			ready = `LOW;
			if (we && iter == 4'h0) begin
				wmem = wd;
				we_state = `HIGHT;
			end
			case (iter)
				4'h0  : command = `CMD_ACTIV;
				4'h1  : command = `CMD_ANOP;
				4'h2  : command = we_state ? `CMD_WRITE : `CMD_READ;
				4'h5  : command = `CMD_PRECH;
				default : command = `CMD_NOP;
			endcase
			if (command == `CMD_ACTIV) end_cycl = we ? CMD_CYCL : CMD_CYCL + CAS_LATENCY;
			iter = iter == end_cycl ? 4'h0 :
			       we_state && iter == 4'h3 ? 4'h5 : iter + 4'h1;
			if (we_state) begin
				wdata = command == `CMD_WRITE ? wmem[15:0] :
			           command == `CMD_NOP ? wmem[31:16] : 16'b0;
				cl = cl == CAS_LATENCY + 1 || cl == CAS_LATENCY + 2 ? cl + 3'b001 : 3'b000;
			end
			else begin
				if (command == `CMD_READ) cl = 3'b0;
				else if (command == `CMD_ACTIV || command[3:0] == `CMD_NOP || command == `CMD_PRECH) 
					cl = cl + 3'b001;
			end
			rmem[31:16] = cl == CAS_LATENCY + 3 ? s_dq : `UNDEF16;
			rmem[15:0] = cl == CAS_LATENCY + 3 ? rdata : `UNDEF16;
			rdata = cl == CAS_LATENCY + 1 || cl == CAS_LATENCY + 2 ? s_dq : `UNDEF16;
			if (command == `CMD_ACTIV) begin
				s_a[11:6] = 6'b0;
				s_a[5:0] = a[5:0];
			end
			else if (command != `CMD_PRECH) begin
				s_a[11:1] = 10'h0;
				s_a[0] = command == `CMD_NOP ? 1'h1 : 1'h0;
			end
			re = cl == CAS_LATENCY + 3 ? `HIGHT : `LOW;
			if (we_state && command == `CMD_ACTIV) ready = `LOW;
			if ((we_state && command == `CMD_PRECH) || cl == CAS_LATENCY + 3) begin
				we_state = `LOW;
				ready = `HIGHT;
				s_a = 12'b0;
				wmem = `UNDEF32;
				wdata = `UNDEF16;
			end
		end
	end
	
	assign sd_cs  = command[3];
	assign sd_ras = command[2];
	assign sd_cas = command[1];
	assign sd_we  = command[0];
	assign sd_ldqm = `LOW;
	assign sd_udqm = `LOW;
	
	task initialize;
		begin
			init = `HIGHT;
			command = `CMD_NOP;
			wmem = `UNDEF32;
			rmem = `UNDEF32;
			s_a = 12'b0;
			wdata = `UNDEF16;
			rdata = `UNDEF16;
			we_state = `LOW;
			re = `LOW;
			iter = 4'h0;
			cl = 3'b0;
			ready = `LOW;
			#INIT_CYCL init = `LOW;
		end
	endtask
	
	task load_register_mode;
		begin
			init = `HIGHT;
			repeat (1) @(posedge clkIn);
			command = `CMD_MODE;
			s_a = `REG_MODE;
			repeat (1) @(posedge clkIn);
			ready = `HIGHT;
			command = `CMD_NOP;
			s_a = 12'b0;
			iter = 4'h0;
			cl = 3'b0;
			init = `LOW;
		end
	endtask

endmodule
