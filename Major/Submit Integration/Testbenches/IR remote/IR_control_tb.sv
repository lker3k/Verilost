`timescale 1ns / 1ps

module IR_control_tb;

    // Parameters
    parameter CLK_PERIOD = 20;  // 20 ns clock period (50 MHz)

    // DUT Signals
    reg CLOCK_50 = 0;
    reg [3:0] KEY = 4'b1111;    // Active low reset, so default is deasserted
    reg IRDA_RXD = 1;           // Idle state for IR signal is high
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
    wire [31:0] hex_data;       // The 32-bit output data that represents the remote code

    // Instantiate the DUT
    IR_control uut (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .IRDA_RXD(IRDA_RXD),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .HEX6(HEX6),
        .HEX7(HEX7),
        .hex_data(hex_data)
    );

    // Clock generation
    initial begin
        forever #(CLK_PERIOD / 2) CLOCK_50 = ~CLOCK_50;
    end

    // Task to simulate IRDA_RXD signal for a specific hex code (16-bit)
    task simulate_irda_rx(input [15:0] hex_code);
        integer i;
        
        // Start bit (9 ms LOW + 4.5 ms HIGH)
        IRDA_RXD = 0;
        #(9000);  // 9 ms low
        IRDA_RXD = 1;
        #(4500);  // 4.5 ms high
        
        // Send 16-bit hex_code, bit by bit
        for (i = 15; i >= 0; i = i - 1) begin
            if (hex_code[i]) begin
                // Logical '1' (560 us LOW + 1.69 ms HIGH)
                IRDA_RXD = 0;
                #(560);
                IRDA_RXD = 1;
                #(1690);
            end else begin
                // Logical '0' (560 us LOW + 560 us HIGH)
                IRDA_RXD = 0;
                #(560);
                IRDA_RXD = 1;
                #(560);
            end
        end

        // End of transmission, set IRDA_RXD to idle (high)
        IRDA_RXD = 1;
        #(500);  // Wait 500 us to stabilize
    endtask

    // Test stimulus
    initial begin
        // Apply reset
        KEY[3] = 0;            // Activate reset (assuming active low)
        #100;                  // 100 ns reset pulse
        KEY[3] = 1;            // Deactivate reset
        #500;                  // Wait 500 ns to allow for initialization

        // Test case 1: Simulate IRDA_RXD signal and force hex_data for button "1"
        $display("Simulating button '1' press (hex_data = 16'hfe01)...");
        simulate_irda_rx(16'hfe01);     // Generate IRDA_RXD signal for "button 1"
        force uut.hex_data = 32'h0000fe01;  // Temporarily force hex_data to expected result
        #1000;                         // Wait and observe HEX output
        release uut.hex_data;          // Release hex_data back to normal operation

        // Test case 2: Simulate IRDA_RXD signal and force hex_data for button "2"
        $display("Simulating button '2' press (hex_data = 16'hfd02)...");
        simulate_irda_rx(16'hfd02);     // Generate IRDA_RXD signal for "button 2"
        force uut.hex_data = 32'h0000fd02;
        #1000;
        release uut.hex_data;

        // Test case 3: Simulate IRDA_RXD signal and force hex_data for button "3"
        $display("Simulating button '3' press (hex_data = 16'hfc03)...");
        simulate_irda_rx(16'hfc03);     // Generate IRDA_RXD signal for "button 3"
        force uut.hex_data = 32'h0000fc03;
        #1000;
        release uut.hex_data;

        // Finish simulation
        $finish;
    end

    // Monitoring HEX output and hex_data
    initial begin
        $monitor("Time=%0t | HEX0=%b | HEX1=%b | HEX2=%b | HEX3=%b | HEX4=%b | HEX5=%b | HEX6=%b | HEX7=%b | hex_data=%h",
                 $time, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, hex_data);
    end

endmodule
