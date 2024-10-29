module top_level(
	// general inputs
	input 	 	CLOCK_50,
	input  		[3:0] KEY,
	input  		[17:0] SW,
	inout 		[35:0] GPIO,
	
	// IR remote 
	inout [3:0]	SD_DAT,
	inout AUD_ADCLRCK,
	inout AUD_DACLRCK,
	inout [3:0] HSMC_D,
	inout	[6:0]	EX_IO,
	input IRDA_RXD,
	
	//Microphone
	output   I2C_SCLK,
	inout    I2C_SDAT,
	input    AUD_ADCDAT,
	input    AUD_BCLK,
	output   AUD_XCK,

	// general output
	output wire [17:0] LEDR,
	output wire [7:0] LEDG,
	output  [6:0] HEX0,
	output  [6:0] HEX1,
	output  [6:0] HEX2,
	output  [6:0] HEX3,
	output  [6:0] HEX4,
	output  [6:0] HEX5,
	output  [6:0] HEX6,
	output  [6:0] HEX7,
	
	// debugging camera
	
	output wire VGA_HS,
	output wire VGA_VS,
	output wire [7:0] VGA_R,
	output wire [7:0] VGA_G,
	output wire [7:0] VGA_B,
	output wire VGA_BLANK_N,
	output wire VGA_SYNC_N,
	output wire VGA_CLK
	


);

	logic bell;

	logic [31:0] hex_data;


	logic [7:0] distance;
	logic proximity;
	logic [4:0] motor_state;
	logic [2:0] pixel_location;
	logic [1:0] color_mode;

robot_fsm  u_fsm (
	.clk		(CLOCK_50),
	.reset		(~KEY[0]),
	.bell		(bell),
	.proximity	(proximity),
	.pixel_location	(pixel_location),
	.button1	(button1),
	.overwrite	(overwrite),
	.motor_state	(motor_state),
	.state_logic	(LEDR[8:0])
);

						/*
microphone u_microphone	(
								.clk(CLOCK_50),
								.reset(~KEY[0]),
								.i2c_sclk(I2C_SCLK),
								.i2c_sdat(I2C_SDAT),
								.aud_ADCDAT(AUD_ADCDAT),
								.aud_BCLK(AUD_BCLK),
								.aud_XCK(AUD_XCK),
								.aud_ADCLRCK(AUD_ADCLRCK),
								.bell_detected(bell)
								);
								*/
assign LEDG[4] = bell;
assign bell = SW[0];


//assign LEDR[11:0] = hex_data[11:0];


								
IR_control u_IR	(
	.clk		(CLOCK_50),
	.reset		(KEY[0]),
	.sd_DAT		(SD_DAT),
	.hsmc_d		(HSMC_D),
	.ex_io		(EX_IO),
	.irda_rxd	(IRDA_RXD),
	.aud_adclrck	(AUD_ADCLRCK),
	.aud_daclrck	(AUD_DACLRCK),
	.gpio		(GPIO),
	.overwrite	(overwrite),
	.hex_output	(hex_data),
	.HEX0		(HEX0),
	.HEX1		(HEX1),
	.HEX2		(HEX2),
	.HEX3		(HEX3),
	.HEX4		(HEX4),
	.HEX5		(HEX5),
	.HEX6		(HEX6),
	.HEX7		(HEX7)
);
logic button1, button2, button3;

assign button1 = (hex_data[31:16] == 16'hfe01);
assign button2 = (hex_data[31:16] == 16'hfd02);
assign button3 = (hex_data[31:16] == 16'hfc03);

assign LEDG[6] = button1;
assign LEDG[7] = button2;

always_comb begin
	if (button1) begin
		color_mode = 2'b00; // red
	end else if (button2) begin
		color_mode = 2'b01; // green
	end else if (button3) begin
		color_mode = 2'b10; // blue
	end else begin
		color_mode = 2'b00; // red - kitchen
	end
end				

logic [11:0] pixel_value;								
camera u_camera	(
	.clk		(CLOCK_50),
	.reset		(KEY[0]),
	.operation_mode	(pixel_location),
	.color_mode	(color_mode),
	.vga_hs		(VGA_HS),
	.vga_vs		(VGA_VS),
	.vga_r		(VGA_R),
	.vga_g		(VGA_G),
	.vga_b		(VGA_B),
	.vga_blank_n	(VGA_BLANK_N),
	.vga_sync_n	(VGA_SYNC_N),
	.vga_clk	(VGA_CLK),
	.gpio		(GPIO),
	.pixel_value	(pixel_value),
	.led_config	(LEDG[0])
);
//assign color_mode = SW[1:0];
assign LEDG[3:1] = pixel_location;
//assign LEDR[11:0] = pixel_value;

proximity u_proximity	(
	.clk			(CLOCK_50),
	.gpio			(GPIO),
	.distance		(distance),
	.proximity_sensor	(proximity)
);
assign LEDG[5] = proximity;
		
motor u_motor	(
	.clk		(CLOCK_50),
	.reset		(~KEY[0]),
	.motor_cmd	(motor_state),
	.gpio		(GPIO)
);
		
assign  LEDR[17:13] = motor_state;
always_comb begin
	if (motor_state == 5'b00000) begin
		LEDR[12] = 1;
	end else LEDR[12] = 0;
end

endmodule
