`timescale 1ps/1ps
module mic_load #(parameter N=16) (
	input bclk, // Assume a 18.432 MHz clock
    input adclrc,
	input adcdat,

    output logic valid,
    output logic [N-1:0] sample_data
);

    // Your code here!
   // Assume that i2c has already configured the CODEC for LJ data, MSB-first and N-bit samples.

    // Rising edge detect on ADCLRC to sense left channel
    logic redge_adclrc, adclrc_q;
    logic [N-1:0] ADCDAT_temp;
    logic [4:0] bit_index; // 5 bit number since it goes greater than 16. In addition we have to use this flip the bits since it takes MSB first before LSB
    always_ff @(posedge  bclk) begin : adclrc_rising_edge_ff
        adclrc_q <= adclrc;
    end
    assign redge_adclrc = ~adclrc_q & adclrc; // rising edge detected!

    /*
     * Implement the Timing diagram.
     * -----------------------------
     * You should use a temporary N-bit RX register to store the ADCDAT bitstream from MSB to LSB.
     * Remember that MSB is first, LSB is last.
     * Use `temp_rx_data[(N-1)-bit_index] <= adcdat;`
     * BCLK rising is your trigger to sample the value of ADCDAT into the register at the appropriate bit index.
     * ADCLRC rising (see `redge_adclrc`) signals that the MSB should be sampled on the next rising edge of BCLK.
     * With the above, think about when and how you would reset your bit_index counter.
     */

always_ff @(posedge bclk or posedge redge_adclrc) begin
    if (redge_adclrc) begin
        bit_index <= 0;
    end else begin
        if (bit_index <= N) begin
            ADCDAT_temp[(N-1) - bit_index] <= adcdat;
            bit_index <= bit_index + 1;
        end
        if (bit_index == N) begin
            valid <= 1;
            sample_data <= ADCDAT_temp;
        end else begin
            valid <= 0;
        end
    end
end

endmodule

