module motor (
		input  		  clk,
		input 			reset,
      input  [4:0] motor_cmd,
      inout  [35:0] gpio
);
		//logic [4:0] motor_cmd
      logic [7:0] uart_data;						// Uart output
      logic uart_valid, uart_ready;				// uart ready and valid
		logic [$clog2(500)-1:0] timer_value;
		
		/*
      // Motor command based on switches
      always_comb begin
            motor_cmd = SW[4:0];  // Assign switches to motor command
      end
		assign LEDR = SW;
		*/
		
      json_uart_sender json_uart_u (
            .clk				(clk),				
            .rst				(reset),
            .motor_cmd		(motor_cmd),		// One hot motor commands
            .uart_data		(uart_data),     // Now provides data to be transmitted
            .uart_valid		(uart_valid),
            .uart_ready		(uart_ready),
				.timer_value	(timer_value)
      );

		
      uart_tx #(
            .CLKS_PER_BIT(50_000_000/115200),  // Set baud rate to 115200
            .BITS_N(8),                        // 8-bit data
            .PARITY_TYPE(0)                    // No parity
      ) uart_tx_u (
            .clk(clk),
            .rst(reset),
            .data_tx(uart_data),               // Data from json_uart_sender
            .uart_out(gpio[5]),                // UART output signal
            .valid(uart_valid),                // Valid signal from json_uart_sender
            .ready(uart_ready)                 // Ready signal from uart_tx
      );
		
		
		transmission_timer #(
			.MAX_MS 			(200),            // Maximum millisecond value
			.CLKS_PER_MS 	(50000)				// 50000 clock cylces per ms (clock 50)
		) transmission_timer_u (
			.clk				(clk),
			.reset			(reset),
			.enable			(1),					// this timer will always run
			.timer_value	(timer_value)
		);

endmodule
