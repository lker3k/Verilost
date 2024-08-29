module timer #(
    parameter INTERVAL_MS = 1000  // 1000 ms = 1 second default interval
)(
    input wire clk,
    input wire reset_n,
    output reg timeout
);

    localparam COUNT_MAX = INTERVAL_MS * 50000; // Calculate COUNT_MAX based on interval
    reg [31:0] count;  // 32-bit counter to count clock cycles

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            count <= 32'd0;
            timeout <= 1'b0;
        end else begin
            if (count >= COUNT_MAX) begin
                count <= 32'd0;  // Reset count
                timeout <= 1'b1; // Generate timeout pulse
            end else begin
                count <= count + 1;
                timeout <= 1'b0; // Keep timeout low during counting
            end
        end
    end

endmodule

