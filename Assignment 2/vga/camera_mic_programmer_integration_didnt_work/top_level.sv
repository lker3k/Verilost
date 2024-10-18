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
output wire vga_hsync,
output wire vga_vsync,
output wire [7:0] vga_r,
output wire [7:0] vga_g,
output wire [7:0] vga_b,
output wire vga_blank_N,
output wire vga_sync_N,
output wire vga_CLK,
input wire ov7670_pclk,
output wire ov7670_xclk,
input wire ov7670_vsync,
input wire ov7670_href,
input wire [7:0] ov7670_data,
output wire ov7670_sioc,
inout wire ov7670_siod,
output wire ov7670_pwdn,
output wire ov7670_reset,



inout  wire [7:0] LCD_DATA,    // external_interface.DATA
output wire       LCD_ON,      //                   .ON
output wire       LCD_BLON,    //                   .BLON
output wire       LCD_EN,      //                   .EN
output wire       LCD_RS,      //                   .RS
output wire       LCD_RW      //                   .RW

/*
output	I2C_SCLK,
inout		I2C_SDAT,
output [6:0] HEX0,
output [6:0] HEX1,
output [6:0] HEX2,
output [6:0] HEX3,
input		AUD_ADCDAT,
input    AUD_BCLK,
output   AUD_XCK,
input    AUD_ADCLRCK,
output logic [17:0] LEDR
*/
);




// DE2-115 board has an Altera Cyclone V E, which has ALTPLL's'
wire clk_50_camera;
wire clk_25_vga;
wire wren;
wire resend;
wire nBlank;
wire vSync;
wire [16:0] wraddress;
wire [11:0] wrdata;
wire [16:0] rdaddress;
wire [11:0] rddata;
wire [2:0] 	filter_mode;
wire       address;     //   avalon_lcd_slave.address
wire       chipselect;  //                   .chipselect
wire       read;        //                   .read
wire       write;       //                   .write
wire [7:0] writedata;   //                   .writedata
wire [7:0] readdata;    //                   .readdata
wire       waitrequest; //                   .waitrequest

/*

localparam W        = 16;   //NOTE: To change this, you must also change the Twiddle factor initialisations in r22sdf/Twiddle.v. You can use r22sdf/twiddle_gen.pl.
localparam NSamples = 1024; //NOTE: To change this, you must also change the SdfUnit instantiations in r22sdf/FFT.v accordingly.

reg adc_clk; adc_pll adc_pll_u (.areset(1'b0),.inclk0(CLOCK_50),.c0(adc_clk)); // generate 18.432 MHz clock
reg i2c_clk; i2c_pll i2c_pll_u (.areset(1'b0),.inclk0(CLOCK_50),.c0(i2c_clk)); // generate 20 kHz clock

set_audio_encoder set_codec_u (.i2c_clk(i2c_clk), .I2C_SCLK(I2C_SCLK), .I2C_SDAT(I2C_SDAT));

dstream #(.N(W))                audio_input ();
dstream #(.N($clog2(NSamples))) pitch_output ();
 
mic_load #(.N(W)) u_mic_load (
 .adclrc(AUD_ADCLRCK),
 .bclk(AUD_BCLK),
 .adcdat(AUD_ADCDAT),
 .sample_data(audio_input.data),
 .valid(audio_input.valid)
);
		
assign AUD_XCK = adc_clk;

fft_pitch_detect #(.W(W), .NSamples(NSamples)) DUT (
	 .clk(adc_clk),
	 .audio_clk(AUD_BCLK),
	 .reset(~KEY[0]),
	 .audio_input(audio_input),
	 .pitch_output(pitch_output)
 );

reg [$clog2(NSamples)-1:0] display_value;

always_ff @(posedge adc_clk) begin
	if (pitch_output.valid) display_value <= pitch_output.data;
end

display u_display (.clk(adc_clk),.value(display_value),.display0(HEX0),.display1(HEX1),.display2(HEX2),.display3(HEX3));

*/

  my_altpll Inst_vga_pll(
      .inclk0(CLOCK_50),
    .c0(clk_50_camera),
    .c1(clk_25_vga));

  // take the inverted push button because KEY0 on DE2-115 board generates
  // a signal 111000111; with 1 with not pressed and 0 when pressed/pushed;
  assign resend =  ~KEY[0];
  assign vga_vsync = vSync;
  assign vga_blank_N = nBlank;


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

vga u_vga (
		.clk_clk(clk_25_vga),
		.reset_reset_n(KEY[0]),
		.face_select_face_select(SW[1:0]),
		.filter_mode_filter_mode(filter_mode),
		.mic_en_mic_en(SW[5]),
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
		.vga_B(vga_b),
		.pitch_pitch(pitch)
	);

	logic [15:0] pitch;
	
always_comb begin
	if (SW[7]) begin
		pitch = 3500;
	end else if (SW[8]) begin
		pitch = 4500;
	end else if (SW[9]) begin
		pitch = 5500;
	end else begin
		pitch = 2000;
	end
end


integer row = 0, col = 0;
integer row_old = 0, col_old = 0;
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

assign rdaddress = ((row*320) + col);



programmer u_programmer(
	 .clk(CLOCK_50),
	 .reset(~KEY[0]),
	 // Avalon-MM signals to LCD_Controller slave
	 .address(address),          // Address line for LCD controller
	 .chipselect(chipselect),
	 .byteenable(),
	 .read(),
	 .write(write),
	 .waitrequest(waitrequest),
	 .readdata(),
	 .response(),
	 .writedata(writedata),
	 .left(~KEY[3]),
	 .right(~KEY[1]),
	 .select(~KEY[2]),
	 .filter_mode(filter_mode)
);

char_display u_char_display (
	.clk         (CLOCK_50),         //                clk.clk
	.reset       (~KEY[0]),       //              reset.reset
	.address     (address),     //   avalon_lcd_slave.address
	.chipselect  (chipselect),  //                   .chipselect
	.read        (read),        //                   .read
	.write       (write),       //                   .write
	.writedata   (writedata),   //                   .writedata
	.readdata    (readdata),    //                   .readdata
	.waitrequest (waitrequest), //                   .waitrequest
	.LCD_DATA    (LCD_DATA),    // external_interface.export
	.LCD_ON      (LCD_ON),      //                   .export
	.LCD_BLON    (LCD_BLON),    //                   .export
	.LCD_EN      (LCD_EN),      //                   .export
	.LCD_RS      (LCD_RS),      //                   .export
	.LCD_RW      (LCD_RW)       //                   .export
);



endmodule
