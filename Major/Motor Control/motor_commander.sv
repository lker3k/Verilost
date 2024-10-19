import ascii_inst_pkg::*;
	
module motor_commander (
    input  logic clk,
    input  logic reset,
    input   logic [4:0] motor_state,
    input   logic uart_tx_ready,
	 input logic button_pressed,
    output logic uart_tx_valid,
    output logic [7:0] uart_tx_data
);

	    logic button_q0, button_edge;
    always_ff @(posedge clk) begin : edge_detect
    button_q0 <= button_pressed;
    end : edge_detect
    assign button_edge = (button_pressed > button_q0);

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
    logic [7:0] instructions [N_INSTRS];
  
    always_comb begin
        case(current_motor_cmd)
            // {"T":1,"L":0.00,"R":0.00}
            MOTOR_STOP:   begin instructions    =    '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                                                    _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _2, _0, _COMMA,
                                                                    _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _2, _0, _CLOSE_BRACE, _LINE_FEED};
																						/*  '{_A, _B, _C, _D, _E, _F, _G, _H, _I, _J, _K, _L, _M,
																			  _N, _O, _P, _Q, _R, _S, _T, _U, _V, _W, _X, _Y, _LINE_FEED};*/
            end      

            // {"T":1,"L":0.10,"R":0.10}
            MOTOR_FORWARD: begin instructions   =    '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                                                    _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _1, _0, _COMMA,
                                                                    _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _1, _0, _CLOSE_BRACE, _LINE_FEED};
            end                                            

            // {"T":1,"L":0.00,"R":0.10}
            MOTOR_RIGHT: begin instructions     =    '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                                                    _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _0, _COMMA,
                                                                    _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _1, _0, _CLOSE_BRACE, _LINE_FEED};
            end                                 

            // {"T":1,"L":0.1,"R":0.0}
            MOTOR_LEFT: begin instructions      =    '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                                                    _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _1, _0, _COMMA,
                                                                    _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _0, _0, _CLOSE_BRACE, _LINE_FEED};
            end                                  

            // {"T":1,"L":-0.1,"R":0.10}
            MOTOR_SPIN: begin instructions      =    '{_OPEN_BRACE, _DOUBLE_QUOTE, _T, _DOUBLE_QUOTE, _COLON, _1, _COMMA,
                                                                    _DOUBLE_QUOTE, _L, _DOUBLE_QUOTE, _COLON, _MINUS, _0, _PERIOD, _1, _COMMA,
                                                                    _DOUBLE_QUOTE, _R, _DOUBLE_QUOTE, _COLON, _0, _PERIOD, _1, _0, _CLOSE_BRACE, _LINE_FEED};
            end                                     

            // {"T":1,"L":0.0,"R":0.0}                                       
            default: begin instructions         =        '{_A, _B, _C, _D, _E, _F, _G, _H, _I, _J, _K, _L, _M,
																			  _N, _O, _P, _Q, _R, _S, _T, _U, _V, _W, _X, _Y, _Z};
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
            //IDLE:       next_state = (instruction_index < N_INSTRS) ? SEND_OP : IDLE;
				IDLE:       next_state = (button_edge) ? SEND_OP : IDLE;
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
