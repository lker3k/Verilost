module motor_top_level (
      input  		  CLOCK_50,
      input  [17:0] SW,
		input	 [7:0]  KEY,
      inout  [35:0] GPIO,
      output [17:0] LEDR
);

      logic [4:0] motor_cmd;
      logic [7:0] uart_data;						// Uart output
      logic uart_valid, uart_ready;				// uart ready and valid
		logic [$clog2(500)-1:0] timer_value;
		

      // Motor command based on switches
      always_comb begin
            motor_cmd = SW[4:0];  // Assign switches to motor command
      end
		assign LEDR = SW;
		
		
      json_uart_sender json_uart_u (
            .clk				(CLOCK_50),				
            .rst				(~KEY[0]),
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
            .clk(CLOCK_50),
            .rst(~KEY[0]),
            .data_tx(uart_data),               // Data from json_uart_sender
            .uart_out(GPIO[5]),                // UART output signal
            .valid(uart_valid),                // Valid signal from json_uart_sender
            .ready(uart_ready)                 // Ready signal from uart_tx
      );
		
		
		transmission_timer #(
			.MAX_MS 			(200),            // Maximum millisecond value
			.CLKS_PER_MS 	(50000)				// 50000 clock cylces per ms (clock 50)
		) transmission_timer_u (
			.clk				(CLOCK_50),
			.reset			(~KEY[0]),
			.enable			(1),					// this timer will always run
			.timer_value	(timer_value)
		);

endmodule
