`timescale 1ns/1ns /* This directive (`) specifies simulation <time unit>/<time precision>. */

module transmission_timer #(
    parameter MAX_MS = 200,            // Maximum millisecond value
    parameter CLKS_PER_MS = 50000 // What is the number of clock cycles in a millisecond?
) (
    input                       clk,
    input                       reset,
    input                       enable,
    output [$clog2(MAX_MS)-1:0] timer_value
);

    // Your code here!
    reg [$clog2(CLKS_PER_MS)-1:0] countClockCylces;
    reg [$clog2(MAX_MS)-1:0] countMilliseconds;

    always @(posedge clk) begin

            if (reset) begin
                countClockCylces <= 0;
                countMilliseconds <= 0;
            end
            
            else if (enable) begin
                if (countClockCylces >= (CLKS_PER_MS - 1)) begin
                    countClockCylces <= 0;
                    countMilliseconds <= countMilliseconds + 1;
                end
                else begin
                    countClockCylces <= countClockCylces + 1;
                end
            end
        end

    assign timer_value = countMilliseconds;

endmodule
