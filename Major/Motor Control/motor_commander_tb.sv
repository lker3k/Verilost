module motor_commander_tb;
    // Parameters
    localparam CLK_PERIOD = 20; // Clock period (20ns = 50MHz)

    // Testbench signals
    logic clk;
    logic reset;
    logic [4:0] motor_state;
    logic uart_tx_ready;
    logic uart_tx_valid;
    logic [7:0] uart_tx_data;

    // Instantiate the motor_commander module
    motor_commander dut (
        .clk(clk),
        .reset(reset),
        .motor_state(motor_state),
        .uart_tx_ready(uart_tx_ready),
        .uart_tx_valid(uart_tx_valid),
        .uart_tx_data(uart_tx_data)
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
        motor_state = 5'b00001; // Set initial motor state to stop
        uart_tx_ready = 1;

        // Wait for a few clock cycles
        #(5 * CLK_PERIOD);

        // Release reset
        reset = 0;

        // Wait for a few clock cycles to observe IDLE state
        #(10 * CLK_PERIOD);

        // Test different motor commands
        motor_state = 5'b00010; // Motor forward
        #(10 * CLK_PERIOD);

        motor_state = 5'b00100; // Motor right
        #(10 * CLK_PERIOD);

        motor_state = 5'b01000; // Motor left
        #(10 * CLK_PERIOD);

        motor_state = 5'b10000; // Motor spin
        #(10 * CLK_PERIOD);

        // Test when uart_tx_ready goes low (simulate UART busy)
        uart_tx_ready = 0;
        #(10 * CLK_PERIOD);
        uart_tx_ready = 1;

        // Wait for the sequence to complete
        #(dut.N_INSTRS * CLK_PERIOD * 2);

        // Stop the simulation
        $finish();
    end

    // Monitor the UART TX data and display the sent characters
    always_ff @(posedge clk) begin : uart_monitor
        if (uart_tx_valid && uart_tx_ready) begin
            $display("UART TX Data: %c", uart_tx_data);
        end
    end

endmodule
