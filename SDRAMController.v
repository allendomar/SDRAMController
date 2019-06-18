`include "sm_sdram_settings.vh"

module SDRAMController 
( 
	input         CLK,
	input         RESET,
	output        SD_CLK,
	output        SD_CKE,
	output        SD_CS,
	output        SD_WE,
	output        SD_CAS,
	output        SD_RAS,
	output        SD_LDQM,
	output        SD_UDQM,
	output [ 1:0] SD_BS, // bank address
	output [11:0] S_A, // row address
	inout  [15:0] S_DQ,
	//input         cs,
	//input         we,
	output        re,
	//input  [ 5:0] a,
	//output        ready,
	input  [ 3:0] s,
	output [ 3:0] led
);

	wire sd_clk0, ready;
	reg [31:0] wd, rd;
	reg [5:0] a;
	wire [31:0] sd_rd;
	reg cs, we;
	//assign led[3] = ready;
	
	sm_altpll altpll(CLK, sd_clk0);

	integer iter;
	initial iter = 0;
	initial rd = 0;
	
	assign led[3:0] = (s == 4'b1110) ? rd[7:4] :
	                  (s == 4'b1101) ? rd[11:8] :
							(s == 4'b1011) ? rd[15:12] :
							(s == 4'b0111) ? rd[19:16] :
	                                   rd[3:0];
	
	always @(posedge sd_clk0) begin
		cs = `HIGHT;
		if (ready && iter == 0) begin
			a = 6'b000011;
			wd = 32'h87654321;
			we = `HIGHT;
			iter = iter + 1;
		end
		else
		if (ready && iter == 1) begin
			a = 6'b001010;
			wd = 32'h00074f6b;
			iter = iter + 1;
		end
		else
		if (ready && iter == 2) begin
			a = 6'b000011;
			we = `LOW;
			iter = iter + 1;
		end
		if (ready && iter > 2) rd = sd_rd;
	end

	//CL = 2 don't change this number!
	sm_sdram_controller #(2, 100) ram_ctrl
	(
		.clkIn   (sd_clk0),
		.rst_n   (RESET),
		.cs      (cs),
		.we      (we),
		.re      (re),
		.ready   (ready),
		.a       (a),
		.wd      (wd),
		.rd      (sd_rd),
	
		// sdram signals
		.sd_clk  (SD_CLK),
		.sd_cke  (SD_CKE),
		.sd_cs   (SD_CS),
		.sd_we   (SD_WE),
		.sd_cas  (SD_CAS),
		.sd_ras  (SD_RAS),
		.sd_ldqm (SD_LDQM),
		.sd_udqm (SD_UDQM),
		.sd_bs   (SD_BS),
		.s_a     (S_A), 
		.s_dq    (S_DQ)
	);

endmodule
