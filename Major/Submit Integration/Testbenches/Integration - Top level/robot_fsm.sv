module robot_fsm (
	
    input logic bell,
    input logic proximity,
    input logic [2:0] pixel_location,
    input logic CLOCK_50,
    input logic reset,   // Assuming KEY[0] is used for reset, and KEY[1] could be button1
    output logic overwrite,
	 input logic button1,
    output [4:0] motor_state
	 
	 /*
	 input [17:0] SW,
	 input [3:0] KEY,
	 input CLOCK_50,
	 
	 output [17:0] LEDR,
	 output [7:0] LEDG
	 */
);
		/*
	logic bell;
	logic proximity;
	logic [2:0] pixel_location;
	logic button1;
	logic overwrite;
	*/
	/*
	assign bell = SW[0];
	assign proximity = SW[1];
	assign pixel_location = SW[4:2];
	assign button1 = SW[5];
	assign LEDG[0] = overwrite;
	*/
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
            STOP:       next_state =    (proximity == 0) ? SEARCH :
													 (pixel_location == 3'b010) ? ARRIVED : 
													 //(bell == 1) ? RESET2 : 
													 STOP;
            ARRIVED:    next_state =    RESET1;
            RESET1:     next_state =    (button1 || overwrite) ? IDLE : (bell == 1) ? RESET2 : RESET1;
            RESET2:     next_state =    SEARCH;
				//ILLEGAL: 	next_state = 	 (SW[17]) ? IDLE : ILLEGAL;
            default:    next_state = IDLE;
        endcase
    end

	 
	logic [$clog2(500)-1:0] timer_value;
			
	transmission_timer #(
								.MAX_MS 			(200),            // Maximum millisecond value
								.CLKS_PER_MS 	(50000)				// 50000 clock cylces per ms (clock 50)
							) u_slow_clock (
								.clk				(clk),
								.reset			(reset),
								.enable			(1),					// this timer will always run
								.timer_value	(timer_value)
							);
	logic trigger;
    // FSM state variable flip-flops
    always_ff @(posedge CLOCK_50) begin
        if (reset) begin
            current_state <= IDLE;
        end
		  else begin
            current_state <= next_state;
        end
    end
	 
	 logic overwrite_old;
	 
	 always_ff @(posedge CLOCK_50) begin
		if (reset) begin
			overwrite_old <= 0;
		end else begin
			overwrite_old <= overwrite;
		end
	 end
	 
	 logic [8:0] state_logic;
    // Output logic
    always_comb begin : output_logic
        motor_state_out = MOTOR_STOP;
        overwrite = overwrite_old;
		  state_logic[8:0] = 0;
		  if (timer_value == 0) begin
				trigger = 1;
		  end else trigger = 0;
        case (current_state)
            IDLE: begin 
					motor_state_out = MOTOR_STOP;
					state_logic[0] = 1;
				end
            SEARCH: begin
					motor_state_out = MOTOR_SPIN;
					state_logic[1] = 1;
				end
            FORWARD: begin
					motor_state_out = MOTOR_FORWARD;
					state_logic[2] = 1;
				end
            LEFT: begin     
					motor_state_out = MOTOR_LEFT;
					state_logic[3] = 1;
				end
            RIGHT: begin     
					motor_state_out = MOTOR_RIGHT;
					state_logic[4] = 1;
				end
            STOP: begin      
					motor_state_out = MOTOR_STOP;
					state_logic[5] = 1;
				end
            ARRIVED: begin
					motor_state_out = MOTOR_STOP;
					state_logic[6] = 1;
				end
            RESET1: begin    
					motor_state_out = MOTOR_STOP;
					state_logic[7] = 1;
					overwrite = 0;
				end
            RESET2: begin
                motor_state_out = MOTOR_STOP;
                overwrite = 1;
					 state_logic[8] = 1;
            end
				//ILLEGAL: LEDR[16] = 1;
            default:    motor_state_out = MOTOR_STOP;
        endcase
    end
	assign motor_state = motor_state_out;
	/*
	assign LEDR[17:13] = motor_state;
	assign LEDG[7] = overwrite;
	assign LEDR[8:0] = state_logic;
	*/
endmodule
