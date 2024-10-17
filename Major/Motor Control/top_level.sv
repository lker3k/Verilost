`timescale 1 ps / 1 ps
module top_level (
		input  wire       CLOCK_50,         //                clk.clk
		input  wire 		reset,       //              reset.reset
		input logic [4:0] motor_state,
		output wire uart_out
	);
	
		wire [7:0] 	uart_data;
		wire			uart_ready;
		wire			uart_valid;

	motor_commander u_motor_commander (
		.clk					(CLOCK_50),
		.reset				(reset),
		.motor_state		(motor_state),
		.uart_tx_ready		(uart_ready),
		.uart_tx_valid		(uart_valid),
		.uart_tx_data		(uart_data)
	);

	uart_tx u_uart_tx (
		.clk			(CLOCK_50),
      .rst			(reset),
      .data_tx		(uart_data),
      .uart_out	(uart_out),
      .valid		(uart_valid),            // Handshake protocol: valid (when `data_tx` is valid to be sent onto the UART).
      .ready		(uart_ready)      // Handshake protocol: ready (when this UART module is ready to send data).
	);

endmodule