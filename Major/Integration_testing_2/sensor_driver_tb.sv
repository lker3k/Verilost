`timescale 1ns / 1ps

module sensor_driver_tb;


// Signal Declarations
logic CLOCK_50 = 0;
logic [3:0] KEY;
logic [7:0] LEDR;
logic [7:0] LEDG;
logic [35:0] GPIO_drive; // Signal used to drive the GPIO
wire [35:0] GPIO;        // Actual GPIO wire

// Tristate buffer: drive GPIO when GPIO_drive is not high-impedance (z)
assign GPIO = GPIO_drive;

// Clock Period Parameter
parameter CLK_PERIOD = 20;

initial CLOCK_50 = 1'b0;
always #(CLK_PERIOD / 2) CLOCK_50 = ~CLOCK_50;

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
   KEY = 4'b1111;        // Buttons not pressed
	LEDG = 8'b0;
   GPIO_drive = 36'b0;   // Set GPIO to high impedance initially
	KEY[0] = 1;
	uut.enable = 0;
    // Wait for global reset to finish
   #100;

    // Test case: Press and release reset button (KEY[2])
    #(1 * CLK_PERIOD);
	 KEY[0] = 0; 
	 uut.enable = 1;
	 // Simulate reset button press
    #(1 * CLK_PERIOD);
    GPIO_drive[34] = 1;   // Release reset button
	 KEY[0] = 0;
	 


    // Simulate trigger and echo interaction
	 repeat(5) begin
    #(10000 * CLK_PERIOD);
    GPIO_drive[34] = 1'b0; // Echo starts low

    #(1 * CLK_PERIOD);
    GPIO_drive[34] = 1;    // Set echo high after trigger


    #(500 + $urandom_range(0, 100000));
    GPIO_drive[34] = 0;    // Set echo low after some random delay
	 
	 end

    // Finish simulation
    #(10 * CLK_PERIOD);
    $finish;
end

endmodule
