`timescale 1ns/1ns /* This directive () specifies simulation <time unit>/<time precision>. */

module timer #(
    parameter MAX_MS = 2047,            // Maximum nanoseconds before the output goes high
    parameter CLKS_PER_MS = 50000        // Number of clock cycles in a nanosecond for a 20 MHz clock (1/20MHz = 50ns)
) (
    input                       clk,
    input                       reset,
    input                       up,
    input  [$clog2(MAX_MS)-1:0] start_value, // Calculates the number of bits needed to represent MAX_NS
    input                       enable,
    output reg                  max_reached, // Output goes high when MAX_NS is reached
    output 							  timer_value  // Output the current value of the timer
);

    reg [15:0] counter1 = 0;                        // Clock cycle counter
    reg [$clog2(MAX_MS)-1:0] count2 = 0;            // Nanosecond counter
    wire count_up = up;                                   // Direction flag for counting up or down

    always @(posedge clk) begin
        if (reset) begin                            // Synchronous reset
            counter1 <= 0;
            max_reached <= 0;                       // Reset max_reached flag
            if (up) begin
                count2 <= 0;                        // Start counting from 0 if counting up
            end else begin
                count2 <= start_value;              // Start from start_value if counting down
            end
        end else if (enable) begin
            if (counter1 >= CLKS_PER_MS - 1) begin
                counter1 <= 0;
                if (count_up) begin
                    if (count2 < MAX_MS - 1) begin
                        count2 <= count2 + 1;       // Increment nanosecond counter
                        max_reached <= 0;           // Ensure max_reached is low until MAX_NS is reached
                    end else begin
                        count2 <= 0;                // Reset count2 when MAX_NS is reached
                        max_reached <= 1;           // Set max_reached high when MAX_NS is reached
                    end
                end else begin
                    if (count2 > 0) begin
                        count2 <= count2 - 1;       // Decrement nanosecond counter
                        max_reached <= 0;           // Ensure max_reached is low when counting down
                    end else begin
                        count2 <= start_value;      // Reset count2 to start_value
                        max_reached <= 0;           // Reset max_reached flag
                    end
                end
            end else begin
                counter1 <= counter1 + 1;           // Increment clock cycle counter
            end
        end
    end

    assign timer_value = count2;  // Assign the nanosecond counter to the output

endmodule
