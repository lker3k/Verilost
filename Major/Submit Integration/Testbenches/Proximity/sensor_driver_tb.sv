`timescale 1ns / 1ps

module sensor_driver_tb;

// Signal Declarations
reg clk;
reg echo;
reg trigger = 1;
reg start;
reg reset;
reg [7:0] LEDR;
reg LEDG;

// Clock Period Parameter
parameter CLK_PERIOD = 20;

// Clock Generation
initial clk = 1'b0;
always #(CLK_PERIOD / 2) clk = ~clk;

// Sensor Driver Instance
sensor_driver u0 (
	.clk(clk),
	.echo(echo),
	.measure(start),
	.rst(reset),
	.trig(trigger),
	.distance(LEDR),
	.proximity_sensor(LEDG)
);

// Testbench Logic
initial begin
	#(1 * CLK_PERIOD)
	reset = 1;
	start = 1;
	LEDR = 0;

	#(1 * CLK_PERIOD)
	reset = 0;
	start = 1;
	
	#(1 * CLK_PERIOD)
	start = 1;
	
	#(500 * CLK_PERIOD)
	repeat (5) begin // Repeat the echo high-low cycle a few times
		echo = 1;
		#($urandom_range(1000000)); // Random amount of time echo stays high
		echo = 0;
		#($urandom_range(1000000)); // Random amount of time echo stays low
	end
	reset = 1;
	#(1 * CLK_PERIOD)
	reset = 0;
	#(1 * CLK_PERIOD)
	
	#(500 * CLK_PERIOD)
	echo = 1;
	#(100000 * CLK_PERIOD)
	echo = 0;
	#(100000 * CLK_PERIOD)
	echo = 1;
	#(50000 * CLK_PERIOD)
	echo = 0;
	#(50000 * CLK_PERIOD)
	
	#(500 * CLK_PERIOD)
	echo = 1;
	#(1000000 * CLK_PERIOD)
	echo = 0;
	#(1000000 * CLK_PERIOD)
	echo = 1;
	#(50000 * CLK_PERIOD)
	echo = 0;
	#(50000 * CLK_PERIOD)

	
	
	#(10 * CLK_PERIOD)
	
	$finish();
end

endmodule