module convolution #(parameter W = 12, parameter image_width = 64) (
    input clk,
    input logic [W-1:0] x_data,    // 12-bit input data stream (e.g., RGB pixel)
    input logic x_valid,           // input valid signal
    output logic x_ready,          // input ready signal
    output logic [W-1:0] y_data,   // 12-bit output data stream
    output logic y_valid           // output valid signal
);

    // 3x3 kernel (signed, 2's complement), scaled to work with 12-bit inputs
	 // 12'sh = 12 bit signed hex
    logic signed [W-1:0] h_3x3 [0:2][0:2] = '{
        '{12'sh000, 12'sh014, 12'sh03f},
        '{12'sh050, 12'sh000, -12'sh00b},
        '{-12'sh2aa, -12'sh4f8, -12'sh75f}
    };

    // Shift register for 2D window (3 rows with 3 columns each)
    logic signed [W-1:0] shift_reg [0:2][0:2];

    // Row buffer: Current, previous, and next rows
    logic signed [W-1:0] row_buffer [0:2][image_width-1]; 

    always_ff @(posedge clk) begin : shift_register_update
        if (x_valid & x_ready) begin
            // Shift row data through the row buffer
            row_buffer[2] <= row_buffer[1];
            row_buffer[1] <= row_buffer[0];
            row_buffer[0][0] <= x_data;  // Assigning x_data to the correct position

            // Shift the 3x3 window
            for (int row = 2; row > 0; row--) begin
                for (int col = 2; col > 0; col--) begin
                    shift_reg[row][col] <= shift_reg[row][col-1];
                end
            end
            
            // Load new data into the first column of the shift register
            shift_reg[0][0] <= row_buffer[0][0];
            shift_reg[1][0] <= row_buffer[1][0];
            shift_reg[2][0] <= row_buffer[2][0];
        end
    end

    // Multiply each pixel in the 3x3 window by the kernel value
    logic signed [2*W-1:0] mult_result [0:2][0:2]; // 2*W to handle multiplication result size
    always_comb begin : h_multiply
        for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 3; j++) begin
                mult_result[i][j] = shift_reg[i][j] * h_3x3[i][j];
            end
        end
    end

    // Add all of the multiplication results together
    logic signed [$clog2(9)+2*W:0] macc;  // Accumulation width to accommodate all additions
    always_comb begin : MAC
        macc = 0;
        for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 3; j++) begin
                macc = macc + mult_result[i][j];
            end
        end
    end

    // Output
    logic x_valid_q = 1'b0;  // Delay x.valid by 1 clock cycle
    always_ff @(posedge clk) begin : output_reg
        if (x_valid & x_ready) begin
            y_data <= macc[W-1:0];  // Take the relevant bits from the MAC result
            x_valid_q <= 1'b1;  // Delay valid signal
        end else begin
            x_valid_q <= 1'b0;
        end
        y_valid <= x_valid_q;  // Output valid delayed by 1 clock cycle
    end

    assign x_ready = y_valid;  // Feedback ready signal
endmodule
