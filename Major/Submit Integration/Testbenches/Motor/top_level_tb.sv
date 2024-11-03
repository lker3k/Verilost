`timescale 1 ps / 1 ps

module top_level_tb;
    // Parameters
    localparam CLK_PERIOD = 20;  // Clock period (20ns = 50MHz)

    // Testbench signals
    logic clk;                    // Clock signal
    logic [4:0] motor_cmd;              // Switches input (equivalent to motor state)
    logic reset;                  // Reset signal (active high)
    logic trigger;                // Trigger input
    logic gpio;                   // GPIO output (UART output)

    // Instantiate the top_level module
    top_level dut (
        .CLOCK_50(clk),
        .motor_cmd(motor_cmd),
        .reset(reset),
        .gpio(gpio),
        .trigger(trigger)
    );

    // Clock generation
    initial begin : clk_gen
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Testbench procedure
    initial begin : procedure
        $dumpfile("waveform.vcd");
        $dumpvars(0, top_level_tb);

        // Initialize signals
        motor_cmd = 18'b0;              // All switches initially off
        reset = 1'b1;            // Assert reset
        trigger = 1'b0;          // No trigger initially

        // Hold reset for a few cycles
        #(10 * CLK_PERIOD);
        reset = 1'b0;            // Deassert reset

        // Wait a few cycles for initialization
        #(10 * CLK_PERIOD);

        // Set a motor command (motor_cmd[1] high)
        motor_cmd[1] = 1'b1;
        trigger = 1'b1;          // Set trigger to start UART transmission
        #(CLK_PERIOD);
        trigger = 1'b0;          // Release trigger
		  
		  #(5000)
		  trigger = 1'b1;          // Set trigger to start UART transmission
        #(CLK_PERIOD);
        trigger = 1'b0;          // Release trigger
		  motor_cmd[1] = 0;
		  motor_cmd[2] = 1;
		  
		  #25000
		  trigger = 1'b1;          // Set trigger to start UART transmission
        #(CLK_PERIOD);
        trigger = 1'b0;          // Release trigger

        // Wait for UART transmission to complete
        #(20000 * CLK_PERIOD);   // Adjust timing as needed for UART completion

        // Stop the simulation
        $finish();
    end

    // Monitor the UART output (gpio) and display it
    always_ff @(posedge clk) begin : uart_monitor
        $display("UART TX Output (gpio): %b", gpio);
    end

endmodule
