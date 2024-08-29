module timer_tb;

    reg clk;
    reg reset_n;
    wire timeout;

    // Instantiate the Timer module with a 1 ms interval
    timer #(.INTERVAL_MS(1)) UUT (
        .clk(clk),
        .reset_n(reset_n),
        .timeout(timeout)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;  // 50 MHz clock (20 ns period)
    end

    // Test sequence
    initial begin
        $dumpfile("timer_waveform.vcd");  // Tell the simulator to dump variables into the 'waveform.vcd' file during the simulation. Required to produce a waveform .vcd file.
        $dumpvars();

        // Initialize signals
        reset_n = 1'b0;
        
        // Apply reset
        #10;
        reset_n = 1'b1;

        // Observe the timer output for a few intervals
        #100000;  // Wait for a significant amount of time to see the timeout pulses

        // Stop the simulation
        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | Reset: %b | Timeout: %b", $time, reset_n, timeout);
    end

endmodule

