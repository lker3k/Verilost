`timescale 1ns/1ns /* This directive specifies simulation <time unit>/<time precision>. */

module timer #(
    parameter MAX_MS = 5000,            // Maximum milliseconds before the output goes high
    parameter CLKS_PER_MS = 50000       // Number of clock cycles in a millisecond for a 20 MHz clock (1/20MHz = 50ns)
) (
    input                       clk,
    input                       reset,
    input                       enable,
    output reg                  max_reached  // Output goes high when MAX_MS is reached
);

    reg [15:0] counter1 = 0;                        // Clock cycle counter
    reg [$clog2(MAX_MS)-1:0] count2 = 0;            // Millisecond counter

    always @(posedge clk) begin
        if (!reset) begin                            // Synchronous reset
            counter1 <= 0;
            count2 <= 0;
            max_reached <= 0;                       // Reset max_reached flag
        end else if (enable == 0 || enable == 1) begin
            if (counter1 >= CLKS_PER_MS - 1) begin
                counter1 <= 0;
                if (count2 < MAX_MS - 1) begin
                    count2 <= count2 + 1;           // Increment millisecond counter
                    max_reached <= 0;               // Ensure max_reached is low until MAX_MS is reached
                end else begin
                    count2 <= 0;                    // Reset count2 when MAX_MS is reached
                    max_reached <= 1;               // Set max_reached high when MAX_MS is reached
                end
            end else begin
                counter1 <= counter1 + 1;           // Increment clock cycle counter
            end
        end
    end

endmodule