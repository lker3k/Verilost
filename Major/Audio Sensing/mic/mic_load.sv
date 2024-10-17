`timescale 1ps/1ps
module mic_load #(parameter N=16) (
    input bclk,      // Assume an 18.432 MHz clock
    input adclrc,
    input adcdat,
    output logic valid,
    output logic [N-1:0] sample_data
);

    logic redge_adclrc, adclrc_q;
    logic [N-1:0] temp_rx_data;
    logic [4:0] bit_index;  
    logic valid_pulse;      

    // Flip-flop to detect rising edge of adclrc
    always_ff @(posedge bclk) begin
        adclrc_q <= adclrc;
    end
    assign redge_adclrc = ~adclrc_q & adclrc; // Rising edge detected!

    // Combined logic for temp_rx_data, bit_index, valid, and sample_data
    always_ff @(posedge bclk) begin
        if (redge_adclrc) begin
            // Reset bit_index at the rising edge of adclrc
            bit_index <= 0;
            valid <= 0;
        end else begin
            if (bit_index < N) begin
                // Store ADCDAT and increment bit_index
                temp_rx_data[(N-1)-bit_index] <= adcdat;  
                bit_index <= bit_index + 1;
                valid <= 0;
            end else if (bit_index == N) begin
                // When a full sample is collected
                sample_data <= temp_rx_data;
                valid <= 1; // Set valid high for 1 clock cycle
                bit_index <= bit_index + 1; // Increment to avoid re-entering this block
            end else begin
                valid <= 0; // Keep valid low otherwise
            end
        end
    end

endmodule

