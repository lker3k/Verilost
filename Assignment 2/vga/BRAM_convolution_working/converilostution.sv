module converilostution #(parameter W, image_width) (
    input clk,
    input reset,
    input filter_mode,   // Add filter mode input for selecting kernels
    dstream.in x,
    dstream.out y
);

    // 1. Assign x.ready: we are ready for data if the module we output to (y.ready) is ready (this module does not exert backpressure).
    assign x.ready = y.ready;

    // 3x3 kernel (signed, 2's complement) stored in a 1D array
    logic signed [W-1:0] h_3x3 [0:8];
    
    always_ff @(posedge clk) begin : kernel_setting
        if (reset) begin
            // Reset kernel to zero on reset
            h_3x3 <= '{default: 0};
        end else begin
            case (filter_mode)
                0: begin
                    h_3x3 <= '{  4'sh0, 4'sh0, 4'sh0, 
                                 4'sh0, 4'sh1, 4'sh0, 
                                 4'sh0, 4'sh0, 4'sh0};
                end
                1: begin
                    h_3x3 <= '{  4'sh0, 4'sh0, 4'sh0, 
                                 4'sh0, 4'sh1, 4'sh0, 
                                 4'sh0, 4'sh0, 4'sh0};
                end
                // Blur kernel
                3: begin
                    h_3x3 <= '{  4'sh1, 4'sh2, 4'sh1, 
                                 4'sh2, 4'sh4, 4'sh2, 
                                 4'sh1, 4'sh1, 4'sh1};
                end
                // Outline kernel
                4: begin
                    h_3x3 <= '{  4'shF, 4'shF, 4'shF, 
                                 4'shF, 4'sh8, 4'shF, 
                                 4'shF, 4'shF, 4'shF};
                end
                // No convolution filter
                default: begin
                    h_3x3 <= '{  4'sh0, 4'sh0, 4'sh0, 
                                 4'sh0, 4'sh1, 4'sh0, 
                                 4'sh0, 4'sh0, 4'sh0};
                end
            endcase
        end
    end

    // 2. Shift register with 3x3 kernel (1D array of length 9 to store pixels)
    logic signed [W-1:0] shift_reg [0:8];  // 1D shift register for 3x3 pixel window

    always_ff @(posedge clk) begin : h_shift_register
        if (reset) begin
            shift_reg <= '{default: 0}; // Reset shift register to zero
        end else if (x.valid & x.ready) begin
            // Shift data into the shift register, sliding the window of pixels
            shift_reg[0] <= shift_reg[1];  // Row 1
            shift_reg[1] <= shift_reg[2];
            shift_reg[2] <= shift_reg[3];  // Row 2
            shift_reg[3] <= shift_reg[4];
            shift_reg[4] <= shift_reg[5];
            shift_reg[5] <= shift_reg[6];  // Row 3
            shift_reg[6] <= shift_reg[7];
            shift_reg[7] <= shift_reg[8];
            shift_reg[8] <= signed'(x.data);  // New pixel input at the end
        end
    end

    // 3. Multiply each register in the shift register by its respective h[n] value
    logic signed [2*W-1:0] mult_result [0:8];  // 2*W as the multiply doubles width
    always_comb begin : h_multiply
        for (int i = 0; i < 9; i++) begin
            mult_result[i] = shift_reg[i] * h_3x3[i];
        end
    end

    // 4. Add all of the multiplication results together and accumulate into the output
    logic signed [$clog2(9)+2*W:0] macc;  // Accumulator wide enough for 9 adds
    always_comb begin : MAC
        macc = 0;
        for (int i = 0; i < 9; i++) begin
            macc = macc + mult_result[i];
        end
    end

    // 5. Output result: y.data holds the final convolved value
    logic x_valid_q = 1'b0;  // Delayed valid signal
    always_ff @(posedge clk) begin : output_reg
        if (reset) begin
            y.data <= 0;
            y.valid <= 0;
            x_valid_q <= 1'b0;
        end else if (x.valid & x.ready) begin
            // Output the result without fractional truncation
            y.data <= macc[W-1:0];  // Directly assign the result, no fixed-point truncation
            x_valid_q <= 1'b1;  // Delay valid signal by 1 clock cycle
            y.valid <= x_valid_q;  // 2 clock cycles for data to propagate
        end else begin
            y.valid <= 1'b0;  // Set y.valid low if not ready
        end
    end

endmodule
