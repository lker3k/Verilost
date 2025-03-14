module whackmole_tb;
    // Step 1: Define test bench variables and clock:
    reg   [17:0]      SW; // Inputs as register data type (so we can assign them in the initial block)
	 reg		[17:0]	 moles;
    wire    [17:0]    LEDR;
    wire    [17:0]    hit_reg; // Outputs as wire data type (as they are assigned by the DUT)
	 


    reg clk = 0;  // Clock signal for sequential logic

    // Step 2: Instantiate Device Under Test:
    whackmole DUT( // Instantiate the 'Device Under Test' (DUT), an instance of the whackmole module.
			.clk(clk),
			.moles(moles),
        .SW(SW), // Connect inputs to their respective testbench variables.
        .LEDR(LEDR), .hit_reg(hit_reg) // Connect outputs to their respective testbench variables.
    );
    // ^^^ Connects ports of the instantiated module to variables in this module with the same port/variable name.

    // Step 3: Toggle the clock variable every 10 time units to create a clock signal **with period = 20 time units**:
    initial forever #10 clk = ~clk; // forever is an infinite loop!

    // Step 4: Initial block to specify input values starting from time = 0. To specify inputs for time > 0, use the delay operator `#`.
    initial begin  // Run the following code starting from the beginning of the simulation:
        $dumpfile("waveform.vcd");  // Tell the simulator to dump variables into the 'waveform.vcd' file during the simulation. Required to produce a waveform .vcd file.
        $dumpvars();                // Also required to tell simulator to dump variables into a waveform (with filename specified above).

        repeat(15) begin // Generate random input stimuli (15 times):
            // Set each input bit to random value (0 or 1):
            {SW} = ($urandom()); // Generate a random unsigned 32-bit value ($urandom), then cast it (1') to a 1-bit value. The inputs SW are then assigned to each bit of this value (in the order: MSB to LSB).
            {moles} = ($urandom());
				// ^^^ We use the LHS concatenation operator here to efficiently assign each of the 1 inputs to a random 1-bit value.
            // Log input and output values:
            $display("Inputs: \tSW: %b, moles: %b", SW, moles); // Print inputs to stdout.
            #10; // Delay for 10 time units to ensure the simulator evaluates the DUT outputs before the next line.
            $display("Outputs:\tLEDR: %b, hit_reg: %b", LEDR, hit_reg); // Print outputs to stdout.
            $display("======================================");
            #10; // Delay for a further 10 time units to provide a total of 20 time units between input changes (as the clock period is 20 time units).
        end

        $finish(); // Important: must end simulation (or it will go on forever!)
    end
endmodule
