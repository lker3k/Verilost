module robot_fsm (
    input logic bell,
    input logic proximity,
	input logic [2:0] pixel_location,
    input logic clk,
    input logic reset,   
    input logic button1,		// this is the red button from the IR remote
	 
    output logic overwrite,		// sets the IR module as if the red button was pressed
    output [4:0] motor_state,
	output [8:0] state_logic	// led test signals showing the state, not connected in final project
	 
);

// state encoding for output motor states
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
	    IDLE:       next_state =    (bell == 1) ? SEARCH : IDLE; 	// begin search on bell trigger

		// set direction based on colour location
            SEARCH:     next_state =    (pixel_location == 3'b010) ? FORWARD :
                                        (pixel_location == 3'b001) ? RIGHT :
                                        (pixel_location == 3'b100) ? LEFT : SEARCH;
		// stop if object detected, set direction based on colour location
	    FORWARD:    next_state =    (proximity == 1) ? STOP : 
                                        (pixel_location == 3'b010) ? FORWARD :		
                                        (pixel_location == 3'b001) ? RIGHT :
                                        (pixel_location == 3'b100) ? LEFT : SEARCH;
            RIGHT:      next_state =    (proximity == 1) ? STOP : 
                                        (pixel_location == 3'b010) ? FORWARD :
                                        (pixel_location == 3'b001) ? RIGHT :
                                        (pixel_location == 3'b100) ? LEFT : SEARCH;
            LEFT:       next_state =    (proximity == 1) ? STOP : 
                                        (pixel_location == 3'b010) ? FORWARD :
                                        (pixel_location == 3'b001) ? RIGHT :
                                        (pixel_location == 3'b100) ? LEFT : SEARCH;
		// robot has arrived at the table if there is an obstacle and the colour is infront of the robot
		// can sometimes cause issues if approaching the table at an angle
            STOP:       next_state =    (proximity == 0) ? SEARCH :
					(pixel_location == 3'b010) ? ARRIVED : 
					STOP;
		
            ARRIVED:    next_state =    RESET1;
		// reset handling, if the destination is red (button1) then it has arrived at the kitchen
		// otherwise it waits for the bell to ring before continuing
            RESET1:     next_state =    (button1) ? IDLE : (bell == 1) ? RESET2 : RESET1;
		// state used to set overwrite
            RESET2:     next_state =    SEARCH;
				//ILLEGAL: 	next_state = 	 (SW[17]) ? IDLE : ILLEGAL;
            default:    next_state = IDLE;
        endcase
    end


	// timer initialisation
	logic [$clog2(500)-1:0] timer_value;		
	transmission_timer #(
								.MAX_MS 			(100),            // Maximum millisecond value
								.CLKS_PER_MS 	(50000)				// 50000 clock cylces per ms (clock 50)
							) u_slow_clock (
								.clk				(clk),
								.reset			(reset),
								.enable			(1),					// this timer will always run
								.timer_value	(timer_value)
							);
	logic trigger; // slower pulse based on the timer
    // FSM state variable flip-flops
    always_ff @(posedge trigger) begin
        if (reset) begin
            current_state <= IDLE;
        end
		  else begin
            current_state <= next_state;
        end
    end
	 
	 logic overwrite_old;

	// latches the overwrite state
	 always_ff @(posedge trigger) begin
		if (reset) begin
			overwrite_old <= 0;
		end else begin
			overwrite_old <= overwrite;
		end
	 end
	 
	 
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
					overwrite = 0;
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
				end
            RESET2: begin
                			motor_state_out = MOTOR_STOP;
                			overwrite = 1;
					 state_logic[8] = 1;
            end

            default:    motor_state_out = MOTOR_STOP;
        endcase
    end
	assign motor_state = motor_state_out;
endmodule
