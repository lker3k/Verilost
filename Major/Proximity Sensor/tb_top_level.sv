`timescale 1ns / 1ps

module tb_top_level;

// Signal Declarations
logic CLOCK_50 = 0;
logic [3:0] KEY = 4'b0;
logic [7:0] LEDR;
logic [7:0] LEDG;
logic echo;
wire [35:0] GPIO;  // Change GPIO to wire for inout behavior

// Clock Period Parameter
parameter CLK_PERIOD = 20;

// Clock Generation
initial CLOCK_50 = 1'b0;
always #(CLK_PERIOD / 2) CLOCK_50 = ~CLOCK_50;

// Tri-state buffer for GPIO[35] (trigger)

// Drive echo with GPIO[34]

// Top-Level Instance
top_level uut (
    .CLOCK_50(CLOCK_50),
    .GPIO(GPIO),
    .KEY(KEY),
    .LEDR(LEDR),
    .LEDG(LEDG)
);

// Testbench Logic
initial begin
    // Initialize inputs
    KEY = 4'b1111;  // Buttons not pressed
    GPIO[34] = 0;       // Echo starts low

    // Wait for global reset to finish
    #100;

    // Test case: Press and release reset button (KEY[2])
    #(1 * CLK_PERIOD);
    KEY[2] = 0;   // Simulate reset button press
    #(1 * CLK_PERIOD);
    GPIO[34] = 1;   // Release reset button

    // Simulate trigger and echo interaction
    #(1 * CLK_PERIOD);
    GPIO[34] = 1'b0;  // Echo starts low
    
    #(1 * CLK_PERIOD);
    #100;
    GPIO[34] = 1;     // Set echo high after trigger

    #(50 + $urandom_range(0, 150));
    GPIO[34] = 0;     // Set echo low after some random delay

    // Finish simulation
    #(10 * CLK_PERIOD);
    $finish;
end

endmodule
