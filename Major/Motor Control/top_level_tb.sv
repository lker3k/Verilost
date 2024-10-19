`timescale 1 ps / 1 ps
module top_level_tb;
    // Parameters
    localparam CLK_PERIOD = 10; // Clock period (20ns = 50MHz)

    // Testbench signals
    logic       clk;         // Clock signal
    logic       reset;       // Reset signal
    logic [4:0] motor_state; // Motor state input
    logic 		 uart_out;    // UART output signal
	 
	 
    // Instantiate the top_level module
    top_level dut (
        .CLOCK_50(clk),
        .reset(reset),
        .motor_state(motor_state),
        .uart_out(uart_out)
    );

    // Clock generation
    initial begin : clk_gen
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Testbench procedure
    initial begin : procedure
        $dumpfile("waveform.vcd");
        $dumpvars();
        // Initialize signals
        reset = 1;
        motor_state = 5'b10000; // Set initial motor state to stop spin

        // Wait for a few clock cycles
        #(5 * CLK_PERIOD);

        // Release reset
        reset = 0;

        // Wait for a few clock cycles to observe IDLE state
        #(10 * CLK_PERIOD);

        // Test different motor commands
 /*       motor_state = 5'b00010; // Motor forward
        #(10 * CLK_PERIOD);

        motor_state = 5'b00100; // Motor right
        #(10 * CLK_PERIOD);

        motor_state = 5'b01000; // Motor left
        #(10 * CLK_PERIOD);

        motor_state = 5'b10000; // Motor spin
        #(10 * CLK_PERIOD);
*/
        // Wait for the sequence to complete
        #(20000 * CLK_PERIOD); // Adjust timing as needed

        // Stop the simulation
        $finish();
    end

    // Monitor the UART output and display it
    always_ff @(posedge clk) begin : uart_monitor
        
            $display("UART TX Output: %b", uart_out);
        
    end

endmodule


