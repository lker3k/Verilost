module robot_fsm_tb;
    // Inputs
    logic bell;
    logic [31:0] hex_data;
    logic [7:0] distance;
    logic proximity;
    logic [2:0] pixel_location;
    logic [1:0] color_mode;
    logic CLOCK_50;
    logic [1:0] KEY;

    // Outputs
    logic overwrite;
    logic[4:0] motor_state;

    // Instantiate the robot_fsm module
    robot_fsm dut (
        .bell(bell),
        .hex_data(hex_data),
        .distance(distance),
        .proximity(proximity),
        .pixel_location(pixel_location),
        .color_mode(color_mode),
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .overwrite(overwrite),
        .motor_state(motor_state)
    );

    // Clock generation
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;  // 50 MHz clock
    end

    // Test sequence
    initial begin
        // Initialize inputs
        bell = 0;
        proximity = 0;
        pixel_location = 3'b000;
        color_mode = 2'b00;
        KEY = 2'b11;  // Both keys are active (no reset)

        // Apply reset
        #15 KEY[0] = 0;  // Assert reset
        #20 KEY[0] = 1;  // De-assert reset

        // Test IDLE to SEARCH transition
        #20 bell = 1;  // Trigger bell to go to SEARCH state
        #20 bell = 0;

        // Test SEARCH to FORWARD transition
        #20 pixel_location = 3'b010;  // Pixel at center, should move to FORWARD

        // Test FORWARD behavior
        #40 pixel_location = 3'b001;  // Pixel indicates right direction
        #40 pixel_location = 3'b100;  // Pixel indicates left direction
        #40 pixel_location = 3'b010;  // Pixel indicates forward again

        // Test proximity detection to STOP
        #30 proximity = 1;  // Detected an object, should go to STOP
        #30 proximity = 0;

        // Test STOP to ARRIVED transition
        #30 pixel_location = 3'b010;  // Center pixel location to ARRIVED

        // Test ARRIVED to RESET1
        #20 KEY[1] = 1;  // Simulate button press to transition to RESET1
        #20 KEY[1] = 0;

        // Test RESET2 back to SEARCH
        #20;  // Wait and observe RESET2 transition back to SEARCH

        // Test ABORT scenario (set RESET2 state and overwrite)
        #20 bell = 1;  // Trigger bell to reset back to SEARCH

        // Complete simulation
        #100 $stop;
    end
endmodule
