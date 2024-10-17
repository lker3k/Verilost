module fft_mag_sq #(
    parameter W = 16
) (
    input                clk,
    input                reset,
    input                fft_valid,
    input  signed [W-1:0] fft_imag,
    input  signed [W-1:0] fft_real,
    output logic [W*2:0] mag_sq,
    output logic         mag_valid
);

    // Pipeline registers
    logic signed [W*2-1:0] multiply_stage_real_reg, multiply_stage_imag_reg;
    logic signed [W*2:0]   add_stage_reg;
    logic [1:0]            valid_shift_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset pipeline registers
            multiply_stage_real_reg <= '0;
            multiply_stage_imag_reg <= '0;
            add_stage_reg           <= '0;
            valid_shift_reg         <= 2'b0;
        end else begin
            // Stage 1: Multiply the inputs
            multiply_stage_real_reg <= signed'(fft_real) * signed'(fft_real);
            multiply_stage_imag_reg <= signed'(fft_imag) * signed'(fft_imag);

            // Stage 2: Add the multiplication results
            add_stage_reg <= multiply_stage_real_reg + multiply_stage_imag_reg;

            // Shift register for valid signal (delays fft_valid by two cycles)
            valid_shift_reg <= {valid_shift_reg[0], fft_valid};
        end
    end

    // Assign outputs
    assign mag_sq    = add_stage_reg;
    assign mag_valid = valid_shift_reg[1]; // Valid after two pipeline stages

endmodule
