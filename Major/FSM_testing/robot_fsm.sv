module robot_fsm (
	/*
    input logic bell,
    input logic [31:0] hex_data,
    input logic [7:0] distance,
    input logic proximity,
    input logic [2:0] pixel_location,
    input logic [1:0] color_mode,
    input logic CLOCK_50,
    input logic [3:0] KEY,   // Assuming KEY[0] is used for reset, and KEY[1] could be button1
    output logic overwrite,
    output [4:0] motor_state
	 */
	 input [17:0] SW,
	 input [3:0] KEY,
	 input CLOCK_50,
	 
	 output [17:0] LEDR,
	 output [7:0] LEDG
);
		
	logic bell;
	logic proximity;
	logic [2:0] pixel_location;
	logic button1;
	logic overwrite;
	
	assign bell = SW[0];
	assign proximity = SW[1];
	assign pixel_location = SW[4:2];
	assign button1 = SW[5];
	assign overwrite = LEDG[0];
	
	
    typedef enum logic [4:0] {
        MOTOR_STOP    = 5'b00001,
        MOTOR_FORWARD = 5'b00010,
        MOTOR_RIGHT   = 5'b00100,
        MOTOR_LEFT    = 5'b01000,
        MOTOR_SPIN    = 5'b10000
    } motor_state_t;
	
	motor_state_t motor_state_out;
	
    enum { IDLE, SEARCH, FORWARD, LEFT, RIGHT, STOP, ARRIVED, RESET1, RESET2, ILLEGAL} next_state, current_state;

    // State transition logic
    always_comb begin
        case (current_state)
            IDLE:       next_state =    (bell == 1) ? SEARCH : IDLE; 
            SEARCH:     next_state =    (pixel_location == 3'b010) ? FORWARD :
                                        (pixel_location == 3'b001) ? RIGHT :
                                        (pixel_location == 3'b100) ? LEFT : SEARCH;
            FORWARD:    next_state =    (proximity == 1) ? STOP : 
                                        //(bell == 1) ? RESET2 :
                                        (pixel_location == 3'b010) ? FORWARD :
                                        (pixel_location == 3'b001) ? RIGHT :
                                        (pixel_location == 3'b100) ? LEFT : SEARCH;
            RIGHT:      next_state =    (proximity == 1) ? STOP : 
                                        //(bell == 1) ? RESET2 :
                                        (pixel_location == 3'b010) ? FORWARD :
                                        (pixel_location == 3'b001) ? RIGHT :
                                        (pixel_location == 3'b100) ? LEFT : SEARCH;
            LEFT:       next_state =    (proximity == 1) ? STOP : 
                                        //(bell == 1) ? RESET2 :
                                        (pixel_location == 3'b010) ? FORWARD :
                                        (pixel_location == 3'b001) ? RIGHT :
                                        (pixel_location == 3'b100) ? LEFT : SEARCH;
            STOP:       next_state =    (pixel_location == 3'b010) ? ARRIVED : 
													 (proximity == 0) ? SEARCH :
													 //(bell == 1) ? RESET2 : 
													 STOP;
            ARRIVED:    next_state =    RESET1;
            RESET1:     next_state =    (button1) ? IDLE : (bell == 1) ? RESET2 : RESET1;
            RESET2:     next_state =    SEARCH;
				ILLEGAL: 	next_state = 	 (SW[17]) ? IDLE : ILLEGAL;
            default:    next_state = ILLEGAL;
        endcase
    end

	 
	logic [$clog2(500)-1:0] timer_value;
			
	transmission_timer #(
								.MAX_MS 			(200),            // Maximum millisecond value
								.CLKS_PER_MS 	(50000)				// 50000 clock cylces per ms (clock 50)
							) u_slow_clock (
								.clk				(CLOCK_50),
								.reset			(reset),
								.enable			(1),					// this timer will always run
								.timer_value	(timer_value)
							);
    // FSM state variable flip-flops
    always_ff @(posedge timer_value) begin
        if (~KEY[0]) begin
            current_state <= IDLE;
        end
		  else begin
            current_state <= next_state;
        end
    end

    // Output logic
    always_comb begin : output_logic
        motor_state_out = MOTOR_STOP;
        overwrite = 0;
		  LEDR[16:7] = 10'b0;
		  if (timer_value == 0) begin
				LEDG[6] = 1;
		  end else LEDG[6] = 0;
        case (current_state)
            IDLE: begin 
					motor_state_out = MOTOR_STOP;
					LEDR[7] = 1;
				end
            SEARCH: begin
					motor_state_out = MOTOR_SPIN;
					LEDR[8] = 1;
				end
            FORWARD: begin
					motor_state_out = MOTOR_FORWARD;
					LEDR[9] = 1;
				end
            LEFT: begin     
					motor_state_out = MOTOR_LEFT;
					LEDR[10] = 1;
				end
            RIGHT: begin     
					motor_state_out = MOTOR_RIGHT;
					LEDR[11] = 1;
				end
            STOP: begin      
					motor_state_out = MOTOR_STOP;
					LEDR[12] = 1;
				end
            ARRIVED: begin
					motor_state_out = MOTOR_STOP;
					LEDR[13] = 1;
				end
            RESET1: begin    
					motor_state_out = MOTOR_STOP;
					LEDR[14] = 1;
				end
            RESET2: begin
                motor_state_out = MOTOR_STOP;
                overwrite = 1;
					 LEDR[15] = 1;
            end
				ILLEGAL: LEDR[16] = 1;
            default:    motor_state_out = MOTOR_STOP;
        endcase
    end
	assign LEDR[4:0] = motor_state_out;
endmodule
