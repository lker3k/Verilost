// File digital_cam_impl1/top_level.vhd translated with vhd2vl v3.0 VHDL to Verilog RTL translator
// vhd2vl settings:
//  * Verilog Module Declaration Style: 2001

// vhd2vl is Free (libre) Software:
//   Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd
//     http://www.ocean-logic.com
//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
//   Modifications (C) 2010 Shankar Giri
//   Modifications Copyright (C) 2002-2017 Larry Doolittle
//     http://doolittle.icarus.com/~larry/vhd2vl/
//   Modifications (C) 2017 Rodrigo A. Melo
//
//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting
//   Verilog for correctness, ideally with a formal verification tool.
//
//   You are welcome to redistribute vhd2vl under certain conditions.
//   See the license (GPLv2) file included with the source for details.

// The result of translation follows.  Its copyright status should be
// considered unchanged from the original VHDL.

// cristinel ababei; Jan.29.2015; CopyLeft (CL);
// code name: "digital cam implementation #1";
// project done using Quartus II 13.1 and tested on DE2-115;
//
// this design basically connects a CMOS camera (OV7670 module) to
// DE2-115 board; video frames are picked up from camera, buffered
// on the FPGA (using embedded RAM), and displayed on the VGA monitor,
// which is also connected to the board; clock signals generated
// inside FPGA using ALTPLL's that take as input the board's 50MHz signal
// from on-board oscillator; 
//
// this whole project is an adaptation of Mike Field's original implementation 
// that can be found here:
// http://hamsterworks.co.nz/mediawiki/index.php/OV7670_camera
// no timescale needed

module top_level(
input wire CLOCK_50,
input wire [3:0] KEY,
input wire [17:0] SW,
output wire led_config_finished,
/*
output wire vga_hsync,
output wire vga_vsync,
output wire [7:0] vga_r,
output wire [7:0] vga_g,
output wire [7:0] vga_b,
output wire vga_blank_N,
output wire vga_sync_N,
output wire vga_CLK,
*/
input wire ov7670_pclk,
output wire ov7670_xclk,
input wire ov7670_vsync,
input wire ov7670_href,
input wire [7:0] ov7670_data,
output wire ov7670_sioc,
inout wire ov7670_siod,
output wire ov7670_pwdn,
output wire ov7670_reset,	
output wire [7:1] LEDG,
output wire [17:0] LEDR				
);




// DE2-115 board has an Altera Cyclone V E, which has ALTPLL's'
wire clk_50_camera;
wire clk_25_vga;
wire wren;
wire resend;


//wire nBlank;
//wire vSync;


wire [16:0] wraddress;
wire [11:0] wrdata;
wire [16:0] rdaddress;
wire [11:0] rddata;
//wire [7:0] red; wire [7:0] green; wire [7:0] blue;
//wire activeArea;

  //assign vga_r = red[7:0];
  //assign vga_g = green[7:0];
  //assign vga_b = blue[7:0];
  my_altpll Inst_vga_pll(
      .inclk0(CLOCK_50),
    .c0(clk_50_camera),
    .c1(clk_25_vga));

  // take the inverted push button because KEY0 on DE2-115 board generates
  // a signal 111000111; with 1 with not pressed and 0 when pressed/pushed;
  assign resend =  ~KEY[0];
  /*
  assign vga_vsync = vSync;
  assign vga_blank_N = nBlank;
	*/


  ov7670_controller Inst_ov7670_controller(
      .clk(clk_50_camera),
    .resend(resend),
    .config_finished(led_config_finished),
    .sioc(ov7670_sioc),
    .siod(ov7670_siod),
    .reset(ov7670_reset),
    .pwdn(ov7670_pwdn),
    .xclk(ov7670_xclk));

  ov7670_capture Inst_ov7670_capture(
      .pclk(ov7670_pclk),
    .vsync(ov7670_vsync),
    .href(ov7670_href),
    .d(ov7670_data),
    .addr(wraddress),
    .dout(wrdata),
    .we(wren));

  frame_buffer Inst_frame_buffer(
      .rdaddress(rdaddress),
    .rdclock(clk_25_vga),
    .q(rddata),
    .wrclock(ov7670_pclk),
    .wraddress(wraddress[16:0]),
    .data(wrdata),
    .wren(wren));
	 
integer row = 0, col = 0;
integer row_old = 0, col_old = 0;



always @(posedge clk_25_vga) begin
	if(resend) begin
		row <= 0;
		col <= 0;
	end else begin
		if (col >= 319) begin
			col <= 0;
			if (row >= 239) begin
				row <= 0;
			end else row <= row + 1;
		end else col <= col + 1;
	end
end

/*
reg vga_start, vga_end, vga_ready;
always @(posedge clk_25_vga) begin
	if(resend) begin
		row = 0;
		col = 0;
	end else if (vga_ready) begin
		if (col >= 319) begin
			col <= 0;
			if (row >= 239) begin
				row <= 0;
			end else row <= row + 1;
		end else col <= col + 1;
		
		row_old <= row;
		col_old <= col;
	end
end


always @(*) begin
	if (col_old == 0 && row_old == 0) begin
		vga_start = 1;
	end else vga_start = 0;
	
	if (col_old == 319 && row_old == 239) begin
		vga_end = 1;
	end else vga_end = 0;
end
*/
assign rdaddress = ((row*320) + col);


 cam_detect u_cam_detect (
		.clk(clk_25_vga),
		.reset(resend),
		.in_data(rddata),
		.color_mode(SW[1:0]),
		.row(row),
		.col(col),
		.color_condition(LEDR[17:15]),
		.operate_mode(LEDG[3:1])
 );
 /*
 reg check;
 
 assign LEDG[4] = check;
 assign LEDG[5] = ~check;

 */
reg [11:0] led;

always @(posedge clk_25_vga) begin
	if (row == 120 && col == 160) begin
		//check = 1;
		led <= rddata;
	end else;
end

assign LEDR[11:0] = led;

 /*
 vga u_vga (
		.clk_clk(clk_25_vga),
		.reset_reset_n(KEY[0]),
		.vga_ready_vga_ready(vga_ready),
		.in_data_in_data(rddata),
		.start_p_start_p(vga_start),
		.end_p_end_p(vga_end),
		.vga_CLK(vga_CLK),
		.vga_HS(vga_hsync),
		.vga_VS(vSync),
		.vga_BLANK(nBlank),
		.vga_SYNC(vga_sync_N),
		.vga_R(vga_r),
		.vga_G(vga_g),
		.vga_B(vga_b)
	);
*/
	
endmodule
