import ascii_inst_pkg::*;
	
module motor_commander (
    input  logic clk,
    input  logic reset,
    input   logic [4:0] motor_state,
    input   logic uart_tx_ready,
    output logic uart_tx_valid,
    output logic [7:0] uart_tx_data
);
    // State encoding for FSM
    typedef enum logic [1:0] {IDLE, SEND_OP} state_t;
    state_t current_state, next_state;
	 
    enum {MOTOR_STOP, MOTOR_FORWARD, MOTOR_RIGHT, MOTOR_LEFT, MOTOR_SPIN} motor_cmd, current_motor_cmd;

    always_comb begin
			  case(motor_state)
					5'b00001: motor_cmd = MOTOR_STOP;
					5'b00010: motor_cmd = MOTOR_FORWARD;
					5'b00100: motor_cmd = MOTOR_RIGHT;
					5'b01000: motor_cmd = MOTOR_LEFT;
					5'b10000: motor_cmd = MOTOR_SPIN;
			  default:  motor_cmd = MOTOR_STOP; // Default to stop if input doesn't match
			  endcase
    end

    // output instructions
    localparam N_INSTRS = 26; // Change this to the number of instructions you have below:
    logic [8:0] instructions [N_INSTRS];//= '{CLEAR_DISPLAY, _H, _e, _l, _l, _o, _SPACE, _W, _o, _r, _l, _d, _EXCLAMATION}; // Clear display then display "Hi".
    // In the above array, **bit-8 is the 1-bit `address`** and bits 7 down-to 0 give the 8-bit data. "T":1,"L":0.5,"R":0.5}
    always_comb begin
        case(current_motor_cmd)
            // {"T":1,"L":0.0,"R":0.0}
            MOTOR_STOP:   begin instructions    =    '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                                                    _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _0, _COMMA,
                                                                    _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _0, _CLOSE_BRACE, _LINE_FEED};
            end      

            // {"T":1,"L":0.1,"R":0.1}
            MOTOR_FORWARD: begin instructions   =    '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                                                    _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _5, _COMMA,
                                                                    _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _5, _CLOSE_BRACE, _LINE_FEED};
            end                                            

            // {"T":1,"L":0.0,"R":0.1}
            MOTOR_RIGHT: begin instructions     =    '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                                                    _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _0, _COMMA,
                                                                    _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _5, _CLOSE_BRACE, _LINE_FEED};
            end                                 

            // {"T":1,"L":0.1,"R":0.0}
            MOTOR_LEFT: begin instructions      =    '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                                                    _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _5, _COMMA,
                                                                    _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _0, _CLOSE_BRACE, _LINE_FEED};
            end                                  

            // {"T":1,"L":0.0,"R":0.0}
            MOTOR_SPIN: begin instructions      =    '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                                                    _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _MINUS, _0, _PERIOD, _1, _COMMA,
                                                                    _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _1, _0, _CLOSE_BRACE, _LINE_FEED};
            end                                     

            // {"T":1,"L":0.0,"R":0.0}                                       
            default: begin instructions         =        '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                                                    _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _0, _COMMA,
                                                                    _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _0, _CLOSE_BRACE, _LINE_FEED};
            end                                    
        endcase
    end

    // FSM
    integer instruction_index = 0;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            instruction_index <= 0;
            current_state <= IDLE;

        end else begin
            current_state <= next_state;
             case (current_state)
                SEND_OP: begin
                    if (uart_tx_ready == 1) begin
                        instruction_index <= instruction_index + 1;
                    end
                end
					 IDLE: begin
						current_motor_cmd <= motor_cmd;
						instruction_index <= 0;
					 end
             endcase
        end
    end

    always_comb begin: next_state_logic
        next_state = IDLE;
        case (current_state) 
            IDLE:       next_state = (instruction_index < N_INSTRS) ? SEND_OP : IDLE;
            SEND_OP:   next_state = (instruction_index < N_INSTRS) ? SEND_OP : IDLE;
        endcase
    end

	always_comb begin: fsm_output
		uart_tx_valid  = 0;
		uart_tx_data   = 'h00;

        case (current_state) 
            SEND_OP:   begin
                uart_tx_valid       = 1;
                uart_tx_data   = instructions[instruction_index][7:0];
            end
        endcase
    end
endmodule
