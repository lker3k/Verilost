`timescale 1ns/1ns /* This directive specifies simulation <time unit>/<time precision>. */
module integration_tb;
    // Step 1: Define test bench variables and clock:
    reg   [17:0]      SW;
    reg   [3:0]      KEY; // Inputs as register data type (so we can assign them in the initial block)
    wire  [17:0]      LEDR;
    wire  [6:0]      HEX0;
    wire  [6:0]      HEX1;
    wire  [6:0]      HEX2;
    wire  [6:0]      HEX3; // Outputs as wire data type (as they are assigned by the DUT)

    reg clk = 0;  // Clock signal for sequential logic

    // Step 2: Instantiate Device Under Test:
    integration DUT( // Instantiate the 'Device Under Test' (DUT), an instance of the integration module.
        .CLOCK_50(clk),
        .SW(SW), .KEY(KEY), // Connect inputs to their respective testbench variables.
        .LEDR(LEDR), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3)  // Connect outputs to their respective testbench variables.
    );
    // ^^^ Connects ports of the instantiated module to variables in this module with the same port/variable name.

    // Step 3: Toggle the clock variable every 10 time units to create a clock signal **with period = 20 time units**:
    initial forever #10 clk = ~clk; // forever is an infinite loop!

    // Step 4: Initial block to specify input values starting from time = 0. To specify inputs for time > 0, use the delay operator `#`.
    initial begin  // Run the following code starting from the beginning of the simulation:
        $dumpfile("waveform.vcd");  // Tell the simulator to dump variables into the 'waveform.vcd' file during the simulation. Required to produce a waveform .vcd file.
        $dumpvars();                // Also required to tell simulator to dump variables into a waveform (with filename specified above).
	
		  /*
		  {KEY[0]} = (1);
        {KEY[3]} = (1);
        #50;
        {KEY[3]} = (0);
        #10;
		  */
		  {KEY[0]} = (1);
        repeat(100) begin // Generate random input stimuli (15 times):
            // Set each input bit to random value (0 or 1):
            {SW} = ($urandom()); // Generate a random unsigned 32-bit value ($urandom), then cast it (2') to a 2-bit value. The inputs SW, KEY are then assigned to each bit of this value (in the order: MSB to LSB).
            {KEY[3]} = ($urandom());
				// ^^^ We use the LHS concatenation operator here to efficiently assign each of the 2 inputs to a random 1-bit value.
            // Log input and output values:
            $display("Inputs: \tSW: %b, KEY: %b", SW, KEY); // Print inputs to stdout.
            #10; // Delay for 10 time units to ensure the simulator evaluates the DUT outputs before the next line.
            $display("Outputs:\tLEDR: %b, HEX0: %b, HEX1: %b, HEX2: %b, HEX3: %b", LEDR, HEX0, HEX1, HEX2, HEX3); // Print outputs to stdout.
            $display("======================================");
            #10; // Delay for a further 10 time units to provide a total of 20 time units between input changes (as the clock period is 20 time units).
        end

        $finish(); // Important: must end simulation (or it will go on forever!)
    end
endmodule
