module convolution #(parameter W = 12, parameter W_frac = 2, parameter image_width = 10) (
    input clk,
    input reset,
    input logic [W-1:0] x_data,    // 12-bit input data stream (e.g., RGB pixel)
    input logic x_valid,           // input valid signal
    input logic [2:0] filter_mode, // input which filter is active
    input logic mic_en,            // input microphone enabled
    output logic x_ready,          // input ready signal
    output logic [W-1:0] y_data,   // 12-bit output data stream
    output logic y_valid,          // output valid signal
    output logic [8:0] data_index  // pixel data index
);

    // Declare the convolution kernel (signed, fixed point 4 bit with 2 fractional bits)
    logic signed [W-1:0] h_3x3 [0:2][0:2];
    
    // Shift registers for each channel (3 rows with 3 columns each)
    logic signed [3:0] shift_reg_0 [0:2][0:2]; // Bits 0 to 3
    logic signed [3:0] shift_reg_1 [0:2][0:2]; // Bits 4 to 7
    logic signed [3:0] shift_reg_2 [0:2][0:2]; // Bits 8 to 11

    // Row buffers for each channel
    logic signed [3:0] row_buffer_0 [0:2][0:image_width-1]; // Red Channel 0
    logic signed [3:0] row_buffer_1 [0:2][0:image_width-1]; // Green Channel 1
    logic signed [3:0] row_buffer_2 [0:2][0:image_width-1]; // Blue Channel 2

    // Split the input data into three channels
    logic [3:0] channel_0;
    logic [3:0] channel_1;
    logic [3:0] channel_2;

    // Declare delay register for synchronization
    logic [8:0] delay = 0;

    // Declare pixel index registers
    localparam NumPixels = 320 * 240;
    logic [18:0] pixel_index = 0, pixel_index_next;

    // Set the 3x3 kernel coefficients based on the filter_mode
    always_ff @(posedge clk) begin : kernel_setting
        case (filter_mode)
            // Identity kernel
            0: begin
                h_3x3 = '{'{4'sb0000, 4'sb0000, 4'sb0000},
                          '{4'sb0000, 4'sb0100, 4'sb0000}, // 1.00 in fixed-point s2.2
                          '{4'sb0000, 4'sb0000, 4'sb0000}};
            end
            // Blur kernel
            3: begin
                h_3x3 = '{'{4'sb0001, 4'sb0010, 4'sb0001},  // 0.25, 0.5, 0.25
                          '{4'sb0010, 4'sb0100, 4'sb0010},  // 0.5, 1.00, 0.5
                          '{4'sb0001, 4'sb0010, 4'sb0001}}; // 0.25, 0.5, 0.25
            end
            // Outline kernel
            4: begin
                h_3x3 = '{'{4'sb1100, 4'sb1100, 4'sb1100},  // -1.00 in fixed-point s2.2
                          '{4'sb1100, 4'sb1000, 4'sb1100},  // -1.00, -2.00, -1.00
                          '{4'sb1100, 4'sb1100, 4'sb1100}}; // -1.00
            end
            // Default kernel (identity)
            default: begin
                h_3x3 = '{'{4'sb0000, 4'sb0000, 4'sb0000},
                          '{4'sb0000, 4'sb0100, 4'sb0000},  // 1.00 in fixed-point s2.2
                          '{4'sb0000, 4'sb0000, 4'sb0000}};
            end
        endcase
    end
	 
	 logic [NumColourBits-1:0] stewart_q;
	 	logic read_enable; // Need to have a read enable signal for the BRAM


	always_ff @(posedge clk) begin : bram_read // This block is for correctly inferring BRAM in Quartus - we need read registers!
		//stewart_q <= stewart_face[pixel_index_next];
		stewart_q <= in_data;
	end
	
	   logic [NumColourBits-1:0] current_pixel; //TODO assign this to one of happy_face_q, neutral_face_q or angry_face_q depending on the value of face_select.
   logic [NumColourBits-1:0] out_pixel; // output after filter (12 bit rgb)
	always_comb begin
		current_pixel = stewart_q;
   end

    // Same shift registers, row buffers, and channel separation logic as before
	always_ff @(posedge clk) begin
		if (reset) begin
			channel_0 <= 0;	// change to 29: 20 for 30bit
			channel_1 <= 0;					//19:10
			channel_2 <= 0;	
		end else if (read_enable) begin
			channel_0 <= current_pixel[11:8];	// change to 29: 20 for 30bit
			channel_1 <= current_pixel[7:4];					//19:10
			channel_2 <= current_pixel[3:0];					//9:0
		end
	end

    	always_ff @(posedge clk) begin : shift_register_update
		if (reset) begin
			for (int i = 0; i < 3; i++) begin // row index
				for (int j = 0; j < image_width; j++) begin // col index
					row_buffer_0[i][j] <= 0;
					row_buffer_1[i][j] <= 0;
					row_buffer_2[i][j] <= 0;
				end
			end
			for (int i = 0; i < 3; i++) begin
				 for (int j = 0; j < 3; j++) begin
					  shift_reg_0[i][j] <= 0;
					  shift_reg_1[i][j] <= 0;
					  shift_reg_2[i][j] <= 0;
				 end
			end
			delay <= 0;
		end else if (read_enable) begin
            // Shift row data through the row buffers
				// Put new data into the row_buffer
				// Shift every pixel for every clk cycle
				if (delay_logic) begin
					delay <= delay + 1; // becareful with overflow
				end
				
				for (int i = 0; i < 3; i++) begin // row index
					for (int j = 1; j < image_width; j++) begin // col index
						row_buffer_0[i][j] <= row_buffer_0[i][j-1];
						row_buffer_1[i][j] <= row_buffer_0[i][j-1];
						row_buffer_2[i][j] <= row_buffer_0[i][j-1];
					end
				end
				row_buffer_0[0][0] <= channel_0;
            row_buffer_1[0][0] <= channel_1;
				row_buffer_2[0][0] <= channel_2;

				row_buffer_0[1][0] <= row_buffer_0[0][image_width - 1];
				row_buffer_1[1][0] <= row_buffer_1[0][image_width - 1];
				row_buffer_2[1][0] <= row_buffer_2[0][image_width - 1];
				
				row_buffer_0[2][0] <= row_buffer_0[1][image_width - 1];
				row_buffer_1[2][0] <= row_buffer_1[1][image_width - 1];
				row_buffer_2[2][0] <= row_buffer_2[1][image_width - 1];

            // Shift the 3x3 window for each channel
				
				// extract data from the row_buffer
            for (int i = 0; i < 3; i++) begin
                for (int j = 0; j < 3; j++) begin
                    shift_reg_0[i][j] <= row_buffer_0[i][j];
                    shift_reg_1[i][j] <= row_buffer_1[i][j];
                    shift_reg_2[i][j] <= row_buffer_2[i][j];
                end
            end
				// Kernel's center index will be row + 1 and col + 1 aka (row+1)*320 + (col+1), from the input index
        end
    end

    // Pipelined multiplication with register stages (adjusted for fixed-point multiplication)
    logic signed [2*4-1:0] stage1_mult_result_0 [0:2][0:2]; // Stage 1 pipeline registers
    logic signed [2*4-1:0] stage1_mult_result_1 [0:2][0:2];
    logic signed [2*4-1:0] stage1_mult_result_2 [0:2][0:2];

    always_ff @(posedge clk) begin : pipelined_h_multiply
        if (reset) begin
            for (int i = 0; i < 3; i++) begin
                for (int j = 0; j < 3; j++) begin
                    stage1_mult_result_0[i][j] <= 0;
                    stage1_mult_result_1[i][j] <= 0;
                    stage1_mult_result_2[i][j] <= 0;
                end
            end
        end else begin
            // First stage of multiplication (fixed-point multiplication)
            for (int i = 0; i < 3; i++) begin
                for (int j = 0; j < 3; j++) begin
                    stage1_mult_result_0[i][j] <= shift_reg_0[i][j] * h_3x3[i][j];
                    stage1_mult_result_1[i][j] <= shift_reg_1[i][j] * h_3x3[i][j];
                    stage1_mult_result_2[i][j] <= shift_reg_2[i][j] * h_3x3[i][j];
                end
            end
        end
    end

    // Add all of the multiplication results together for each channel
    logic signed [$clog2(9)+2*4:0] macc_0;  // Accumulator for channel 0
    logic signed [$clog2(9)+2*4:0] macc_1;  // Accumulator for channel 1
    logic signed [$clog2(9)+2*4:0] macc_2;  // Accumulator for channel 2

    always_comb begin : MAC
        macc_0 = 0; // red
        macc_1 = 0; // green
        macc_2 = 0; // blue
        for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 3; j++) begin
                macc_0 = macc_0 + stage1_mult_result_0[i][j];
                macc_1 = macc_1 + stage1_mult_result_1[i][j];
                macc_2 = macc_2 + stage1_mult_result_2[i][j];
            end
        end
        // Adjust for fixed-point scaling: shift right by W_frac after MAC
        macc_0 = macc_0 >>> W_frac;
        macc_1 = macc_1 >>> W_frac;
        macc_2 = macc_2 >>> W_frac;
    end

    // Combine the results back into the 12-bit output
    logic [11:0] combined_result;

    always_ff @(posedge clk) begin : output_reg
        if (mic_en) begin
            if (delay >= image_width + 6) begin // Adjust delay for kernel, shift_reg, macc timing
                if (x_valid & x_ready) begin
                    combined_result = {macc_2[3:0], macc_1[3:0], macc_0[3:0]}; // Combine 4 bits from each channel
                    y_data <= combined_result;
                    y_valid <= 1'b1;
                    pixel_index <= pixel_index_next;
                end else begin
                    y_valid <= 1'b0;
                end
            end
        end else begin
            y_data <= x_data;
        end
    end

    assign x_ready = 1;  // Feedback ready signal
endmodule
