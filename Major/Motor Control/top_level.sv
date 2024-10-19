`timescale 1 ps / 1 ps
module top_level (
		input  wire       	CLOCK_50,        //                clk.clk
		input   		[3:0] 	KEY,       //              reset.reset
		input  		[4:0]		SW,
		inout  wire [35:0] 	GPIO,
		output  		[4:0] 	LEDR,
		output		[7:0]		LEDG
		
		//tb signals
		/*input  wire       CLOCK_50,
		input wire  reset,
		input   [4:0] motor_state,
		output wire uart_out*/
	);
	
		wire [7:0] 	uart_data;
		wire			uart_ready;
		wire			uart_valid;
		assign LEDR = SW;
		assign LEDG = KEY;

	motor_commander u_motor_commander (
		.clk					(CLOCK_50),
		.reset				(~KEY[0]),
		.motor_state		(SW[4:0]),
		.uart_tx_ready		(uart_ready),
		.uart_tx_valid		(uart_valid),
		.uart_tx_data		(uart_data),
		.button_pressed	(~KEY[1])
		
		//tb signals
		/*.clk					(CLOCK_50),
		.reset				(reset),
		.motor_state		(motor_state),
		.uart_tx_ready		(uart_ready),
		.uart_tx_valid		(uart_valid),
		.uart_tx_data		(uart_data)*/
	);

	uart_tx u_uart_tx (
		.clk			(CLOCK_50),
      .rst			(~KEY[0]),
      .data_tx		(uart_data),
      .uart_out	(GPIO[3]),
      .valid		(uart_valid),            // Handshake protocol: valid (when `data_tx` is valid to be sent onto the UART).
      .ready		(uart_ready)   // Handshake protocol: ready (when this UART module is ready to send data).
		
		//tb signals
		/*.clk			(CLOCK_50),
      .rst			(reset),
      .data_tx		(uart_data),
      .uart_out	(uart_out),
      .valid		(uart_valid),            // Handshake protocol: valid (when `data_tx` is valid to be sent onto the UART).
      .ready		(uart_ready)*/  
	
	);

endmodule