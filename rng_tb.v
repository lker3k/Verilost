module counter_tb;
    // Step 1: Define test bench variables and clock:
    reg         clk = 0;
    reg         reset = 1;
    reg         change = 0; // Inputs as register data type (so we can assign them in the initial block)
    wire  [17:0]      random_value; // Outputs as wire data type (as they are assigned by the DUT)

    // reg clk; // (Clock not needed for this simulation.)

    // Step 2: Instantiate Device Under Test:
    counter DUT( // Instantiate the 'Device Under Test' (DUT), an instance of the counter module.
        .clk(clk), .reset(reset), .change(change), // Connect inputs to their respective testbench variables.
        .random_value(random_value)  // Connect outputs to their respective testbench variables.
    );
    // ^^^ Connects ports of the instantiated module to variables in this module with the same port/variable name.

    // Step 3: Toggle the clock variable every 10 time units to create a clock signal **with period = 20 time units**:
    initial forever #10 clk = ~clk; // forever is an infinite loop!
    // (Clock not needed for this simulation.)

    // Step 4: Initial block to specify input values starting from time = 0. To specify inputs for time > 0, use the delay operator `#`.
    initial begin  // Run the following code starting from the beginning of the simulation:
        $dumpfile("waveform.vcd");  // Tell the simulator to dump variables into the 'waveform.vcd' file during the simulation. Required to produce a waveform .vcd file.
        $dumpvars();                // Also required to tell simulator to dump variables into a waveform (with filename specified above).

        repeat(15) begin // Generate random input stimuli (15 times):
            // Set each input bit to random value (0 or 1):
            {change} = ($urandom()); // Generate a random unsigned 32-bit value ($urandom), then cast it (3') to a 3-bit value. The inputs clk, reset, change are then assigned to each bit of this value (in the order: MSB to LSB).
            // ^^^ We use the LHS concatenation operator here to efficiently assign each of the 3 inputs to a random 1-bit value.
            // Log input and output values:
            $display("Inputs: \tclk: %b, reset: %b, change: %b", clk, reset, change); // Print inputs to stdout.
            #10; // Delay for 10 time units to ensure the simulator evaluates the DUT outputs before the next line.
            $display("Outputs:\trandom_value: %b", random_value); // Print outputs to stdout.
            $display("======================================");
            #10; // Delay for a further 10 time units to provide a total of 20 time units between input changes (as the clock period is 20 time units).
        end

        $finish(); // Important: must end simulation (or it will go on forever!)
    end
endmodule
