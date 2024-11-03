import ascii_inst_pkg::*;

module json_uart_sender (
      input        clk,
      input        rst,
		input trigger,
		//input 	logic [$clog2(200)-1:0] timer_value,
      input  [4:0] motor_cmd,    // One-hot motor command input
      output logic [7:0] uart_data,  // Data byte to send via UART
      output logic uart_valid,       // Valid signal to indicate data is ready
      input  logic uart_ready        // Ready signal from uart_tx to indicate it's ready to accept data
);

      // Motor states (one-hot encoding)
      typedef enum logic [4:0] {
            MOTOR_STOP    = 5'b00001,
            MOTOR_FORWARD = 5'b00010,
            MOTOR_RIGHT   = 5'b00100,
            MOTOR_LEFT    = 5'b01000,
            MOTOR_SPIN    = 5'b10000
      } motor_cmd_e;

      localparam N_INSTRS = 28;
      
      logic [7:0] instructions [N_INSTRS];
      integer instruction_index = 0;

      // Predefined JSON messages for each motor command
      always_comb begin
            case (motor_cmd)
                  MOTOR_STOP: begin // {"T":1,"L":0.000,"R":0.000}
                        instructions = '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                        _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _0, _0, _COMMA,
                                        _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _0, _0, _CLOSE_BRACE, _LINE_FEED};
                  end
                  MOTOR_FORWARD: begin // {"T":1,"L":0.100,"R":0.100}
                        instructions = '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                        _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _1, _0, _0, _COMMA,
                                        _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _1, _0, _0, _CLOSE_BRACE, _LINE_FEED};
                  end
                  MOTOR_RIGHT: begin // {"T":1,"L":0.000,"R":0.050}
                        instructions = '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                        _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _0, _0, _COMMA,
                                        _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _5, _0, _CLOSE_BRACE, _LINE_FEED};
                  end
                  MOTOR_LEFT: begin // {"T":1,"L":0.050,"R":0.000}
                        instructions = '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                        _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _5, _0, _COMMA,
                                        _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _0, _0, _CLOSE_BRACE, _LINE_FEED};
                  end
                  MOTOR_SPIN: begin // {"T":1,"L":-0.05,"R":0.050}
                        instructions = '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                        _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _MINUS, _0, _PERIOD, _0, _5, _COMMA,
                                        _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, 			_0, _PERIOD, _0, _5, _0, _CLOSE_BRACE, _LINE_FEED};
                  end
                  default: begin // {"T":1,"L":0.000,"R":0.000}
                        instructions = '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                        _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _0, _0, _COMMA,
                                        _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _0, _0, _CLOSE_BRACE, _LINE_FEED};
                  end
            endcase
      end

      // State machine to send the JSON string
      always_ff @(posedge clk or posedge rst) begin
            if (rst) begin
                  instruction_index <= 0;
                  uart_valid <= 1'b0;
            end else if (!uart_valid && trigger) begin
                  // Start sending the first byte when UART is ready
                  uart_valid <= 1'b1;
                  uart_data <= instructions[0];
                  instruction_index <= 1;
            end else if (uart_valid && uart_ready) begin
					if (instruction_index >= N_INSTRS) begin
						// Finished sending the JSON string
						uart_valid <= 1'b0;
               end
					// Continue sending the next byte
					uart_data <= instructions[instruction_index];
					instruction_index <= instruction_index + 1;
                 
            end
      end

endmodule
