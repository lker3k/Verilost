`timescale 1ns/1ns
module fft_find_peak #(
    parameter NSamples = 1024, // 1024 N-points
    parameter W        = 33,   // For 16x2 + 1
    parameter NBits    = $clog2(NSamples)
) (
    input                        clk,
    input                        reset,
    input  [W-1:0]               mag,
    input                        mag_valid,
    output logic [W-1:0]         peak = 0,
    output logic [NBits-1:0]     peak_k = 0,
    output logic                 peak_valid
);
    logic [NBits-1:0] i = 0, k;

    always_comb begin
        // Bit-reversed index computation
        for (integer j = 0; j < NBits; j = j + 1) begin
            k[j] = i[NBits - 1 - j];
        end
    end

    always_ff @(posedge clk or posedge reset) begin : find_peak
        if (reset) begin
            i          <= 0;
            peak       <= 0;
            peak_k     <= 0;
            peak_valid <= 1'b0;
        end else begin
            if (mag_valid) begin
                // Increment index i
                if (i == NSamples - 1) begin
                    i <= 0;
                    // Set peak_valid high for one clock cycle
                    peak_valid <= 1'b1;
                end else begin
                    i <= i + 1;
                    peak_valid <= 1'b0;
                end

                // Ignore negative frequencies (MSB of k is 1)
                if (k[NBits - 1] == 1'b0) begin
                    // At the beginning of a new window or if current mag is greater
                    if ( (i == 0) || (mag > peak) ) begin
                        peak   <= mag;
                        peak_k <= k;
                    end
                end

                // Reset peak and peak_k at the start of a new window
                if (i == 0) begin
                    peak       <= mag;
                    peak_k     <= k;
                end

            end else begin
                peak_valid <= 1'b0;
            end
        end
    end
endmodule
