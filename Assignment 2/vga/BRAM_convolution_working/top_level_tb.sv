`timescale 1ns / 1ps

module top_level_tb;

    // Inputs
    reg CLOCK_50;
    reg [17:0] SW;

    // Outputs
    wire VGA_CLK;
    wire VGA_HS;
    wire VGA_VS;
    wire VGA_BLANK;
    wire VGA_SYNC;
    wire [7:0] VGA_R;
    wire [7:0] VGA_G;
    wire [7:0] VGA_B;

    // Instantiate the top-level module
    top_level uut (
        .CLOCK_50(CLOCK_50),
        .SW(SW),
        .VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK(VGA_BLANK),
        .VGA_SYNC(VGA_SYNC),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B)
    );

    // Clock generation: 50 MHz clock
    always #10 CLOCK_50 = ~CLOCK_50; // 50 MHz = 20ns period, so toggle every 10ns

    initial begin
        // Initialize Inputs
        CLOCK_50 = 0;
        SW = 0;

        // Wait for 100 ns for the global reset to finish
        #100;

        // Test stimulus
		  repeat(10) begin
			  SW[0] = 1'b1; // Toggle filter mode
			  #50;
			  SW[0] = 1'b0; // Toggle it back
			  #50;

			  // Test various switch settings (if needed)
			  SW[0] = 1'b1; // Set some other switch settings for testing filter modes
			  #50;
			  SW[0] = 1'b0;
			  #50;
			end
        // Additional test cases
        // Further stimulus can be applied here to test the design more thoroughly
        // e.g., cycling through more SW values, adjusting timing, or adding edge cases.
        
        // Finish simulation after some time
        #500 $stop;
    end

endmodule