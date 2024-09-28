module convolution #(parameter W = 12, parameter image_width = 10) (
    input clk,
	 input reset,
    input logic 	[W-1:0] 	x_data,    		// 12-bit input data stream (e.g., RGB pixel)
    input logic 				x_valid,       // input valid signal
	 input logic 	[2:0] 	filter_mode,	// input which filter is active
	 input logic				mic_en,			// input microphone enabled
    output logic 				x_ready,       // input ready signal
    output logic 	[W-1:0] 	y_data,   		// 12-bit output data stream
    output logic 				y_valid,       // output valid signal
	 output logic  [8:0]		data_index
);

    // 3x3 kernel (signed, 2's complement)
	    // 3x3 kernel (signed, 2's complement)
	logic signed [W-1:0] h_3x3 [0:2][0:2];
	always_ff @(posedge clk) begin: kernel_setting
		case (filter_mode)
			0: begin
				h_3x3 = '{	'{4'sh0, 4'sh0, 4'sh0},
								'{4'sh0, 4'sh1, 4'sh0},
								'{4'sh0, 4'sh0, 4'sh0}};
			end
			1: begin
				h_3x3 = '{	'{4'sh0, 4'sh0, 4'sh0},
								'{4'sh0, 4'sh1, 4'sh0},
								'{4'sh0, 4'sh0, 4'sh0}};
			end
			2 : begin
				h_3x3 = '{	'{4'sh0, 4'sh0, 4'sh0},
								'{4'sh0, 4'sh1, 4'sh0},
								'{4'sh0, 4'sh0, 4'sh0}};
			end
			// blur kernel
			3: begin
				h_3x3 = '{	'{4'sh0, 4'sh1, 4'sh0},
								'{4'sh1, 4'sh2, 4'sh1},
								'{4'sh0, 4'sh1, 4'sh0}};
			end
			// outline kernel
			4: begin
				h_3x3 = '{	'{4'shF, 4'shF, 4'shF},
								'{4'shF, 4'sh8, 4'shF},
								'{4'shF, 4'shF, 4'shF}};
			end
			// no convolution filter
			default: begin
				h_3x3 = '{	'{4'sh0, 4'sh0, 4'sh0},
								'{4'sh0, 4'sh1, 4'sh0},
								'{4'sh0, 4'sh0, 4'sh0}};
			end
		endcase
	end
    // Shift registers for each channel (3 rows with 3 columns each)
    logic signed [3:0] shift_reg_0 [0:2][0:2]; // Bits 0 to 3
    logic signed [3:0] shift_reg_1 [0:2][0:2]; // Bits 4 to 7
    logic signed [3:0] shift_reg_2 [0:2][0:2]; // Bits 8 to 11

    // Row buffers for each channel
   logic signed [3:0] row_buffer_0 [0:2][0:image_width-1]; // red Channel 0
   logic signed [3:0] row_buffer_1 [0:2][0:image_width-1]; // green Channel 1
   logic signed [3:0] row_buffer_2 [0:2][0:image_width-1]; // blue Channel 2

   // Split the input data into three channels
   logic [3:0] channel_0;
   logic [3:0] channel_1;
   logic [3:0] channel_2;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			channel_0 <= 0;	// change to 29: 20 for 30bit
			channel_1 <= 0;					//19:10
			channel_2 <= 0;	
		end else begin
			channel_0 <= x_data[11:8];	// change to 29: 20 for 30bit
			channel_1 <= x_data[7:4];					//19:10
			channel_2 <= x_data[3:0];					//9:0
		end
	end
	
	logic [8:0] delay = 0;
	
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
		end else if (x_valid & x_ready) begin
            // Shift row data through the row buffers
				// Put new data into the row_buffer
				// Shift every pixel for every clk cycle
				delay <= delay + 1;
				
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
				// Kernel's center index will be row + 1 and col + 1 aka (row+1)(col+1), from the input index
        end
    end

    // Pipelined multiplication with register stages
    logic signed [2*4-1:0] stage1_mult_result_0 [0:2][0:2]; // Stage 1 pipeline registers
    logic signed [2*4-1:0] stage1_mult_result_1 [0:2][0:2];
    logic signed [2*4-1:0] stage1_mult_result_2 [0:2][0:2];

    logic signed [2*4-1:0] stage2_mult_result_0 [0:2][0:2]; // Stage 2 pipeline registers
    logic signed [2*4-1:0] stage2_mult_result_1 [0:2][0:2];
    logic signed [2*4-1:0] stage2_mult_result_2 [0:2][0:2];

    always_ff @(posedge clk) begin : pipelined_h_multiply
		if(reset) begin
		  for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 3; j++) begin
                stage1_mult_result_0[i][j] <= 0;
                stage1_mult_result_1[i][j] <= 0;
                stage1_mult_result_2[i][j] <= 0;
            end
        end
        // Second stage of multiplication, registered results
        for (int i = 0; i < 3; i++) begin
            for (int j = 0; j < 3; j++) begin
                stage2_mult_result_0[i][j] <= 0;
                stage2_mult_result_1[i][j] <= 0;
                stage2_mult_result_2[i][j] <= 0;
            end
        end
		 end else begin
			  // First stage of multiplication
			  for (int i = 0; i < 3; i++) begin
					for (int j = 0; j < 3; j++) begin
						 stage1_mult_result_0[i][j] <= shift_reg_0[i][j] * h_3x3[i][j];
						 stage1_mult_result_1[i][j] <= shift_reg_1[i][j] * h_3x3[i][j];
						 stage1_mult_result_2[i][j] <= shift_reg_2[i][j] * h_3x3[i][j];
					end
			  end
			  // Second stage of multiplication, registered results
			  for (int i = 0; i < 3; i++) begin
					for (int j = 0; j < 3; j++) begin
						 stage2_mult_result_0[i][j] <= stage1_mult_result_0[i][j];
						 stage2_mult_result_1[i][j] <= stage1_mult_result_1[i][j];
						 stage2_mult_result_2[i][j] <= stage1_mult_result_2[i][j];
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
                macc_0 = macc_0 + stage2_mult_result_0[i][j];
                macc_1 = macc_1 + stage2_mult_result_1[i][j];
                macc_2 = macc_2 + stage2_mult_result_2[i][j];
            end
        end
    end

    // Combine the results back into the 12-bit output
    logic [11:0] combined_result;
	 
	 localparam NumPixels     = 320 * 240;
	 
	 logic [18:0] pixel_index = 0, pixel_index_next; // The pixel counter/index. Set pixel_index_next in an always_comb block.
																 // Set pixel_index <= pixel_index_next in an always_ff block.
	 assign pixel_index_next =   (reset) ? 0 : 
                                (pixel_index == NumPixels - 1) ? 0 :
                                pixel_index + 1;
	 
    always_ff @(posedge clk) begin : output_reg
		if (mic_en) begin
		// we have delay to skip the first few cycle to do calculation
		// timing is crucial
		// remember start_of_packet and end_of_packet signal have to be delay by 1 cycle
			if (delay >= image_width + 2 /* center kernel index */ + 1 /* shift_reg*/+ 1/*mult_result*/ + 1/*macc*/) begin
				if (x_valid & x_ready) begin
					combined_result = {macc_2[3:0], macc_1[3:0], macc_0[3:0]}; // Combine 4 bits from each channel
					y_data <= combined_result;
					y_valid <= 1'b1;
					pixel_index <= pixel_index_next;
				end else begin
					y_valid <= 1'b0;
				end
			end else pixel_index <= 0;
			data_index <= pixel_index;
		end else y_data <= x_data;
    end
	 
	 // delay 1 cycle for start_of_packet and end_of_packet
	 // put condition base on data_index

    assign x_ready = 1;  // Feedback ready signal
endmodule
