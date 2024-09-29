module vga_face #(parameter W = 12, parameter image_width = 320)(
	input  logic        clk,             
	input  logic        reset,           
	//input  logic [1:0]  face_select,     // 0: Happy, 1: Neutral, 2: Angry
	//input  logic [15:0] pitch,
	//input  logic        mic_en,  // microphone enabled
	input  logic 	[2:0] filter_mode, // 0: no filter, 1: convolution
	//input  logic 	[11:0] in_data,

   // Avalon-ST Interface:
	output logic [29:0] data,            // Data output to VGA (8 data bits + 2 padding bits for each colour Red, Green and Blue = 30 bits)
   output logic        startofpacket,   // Start of packet signal
   output logic        endofpacket,     // End of packet signal
   output logic        valid,           // Data valid signal
   input  logic        ready,           // Data ready signal from VGA Module
	
	output logic 		  x_ready
);

	//logic [15:0] pitch = 4000;
	//logic        mic_en = 1;
	//logic [2:0]	filter_mode = 1; // 0 for no filter, 1 for grey, 2 for shift

	
	localparam NumPixels     = 320 * 240; // Total number of pixels on the 640x480 screen
	localparam NumColourBits = 12;         // We are using a 3-bit colour space to fit 3 images within the 3.888 Mbits of BRAM on our FPGA.

	// Image ROMs:
	//(* ram_init_file = "happy.mif" *)   logic [NumColourBits-1:0] happy_face   [NumPixels]; // The ram_init_file is a Quartus-only directive
	//(* ram_init_file = "neutral.mif" *) logic [NumColourBits-1:0] neutral_face [NumPixels]; //   specifying the name of the initialisation file,
	//(* ram_init_file = "angry.mif" *)   logic [NumColourBits-1:0] angry_face   [NumPixels]; //   and Verilator will ignore it.
	
	(* ram_init_file = "stewart.mif" *)   logic [NumColourBits-1:0] stewart_face   [NumPixels];
    
	 // this one is to extract from BRAM
	logic [18:0] pixel_index = 0, pixel_index_next; // The pixel counter/index. Set pixel_index_next in an always_comb block.
																 // Set pixel_index <= pixel_index_next in an always_ff block.
	
	// this one is for output index - controlling start_p and end_p
	logic [18:0] data_index = 0, data_index_next, data_index_old;
	
	logic [NumColourBits-1:0] stewart_q;
	
	logic read_enable; // Need to have a read enable signal for the BRAM


	always_ff @(posedge clk) begin : bram_read // This block is for correctly inferring BRAM in Quartus - we need read registers!
		stewart_q <= stewart_face[pixel_index_next];
	end
	

	
	//assign stewart_q = 12'b111111111111;
    /* Complete the TODOs below */

   logic [NumColourBits-1:0] current_pixel; //TODO assign this to one of happy_face_q, neutral_face_q or angry_face_q depending on the value of face_select.
   logic [NumColourBits-1:0] out_pixel; // output after filter (12 bit rgb)
	always_comb begin
		current_pixel = stewart_q;
   end
	
	//logic x_valid;
	//logic x_ready;
	logic y_valid;

   //assign valid = ~reset;//TODO valid should be set to low when we are in reset - otherwise, we are constantly streaming data (valid stays high).
	


	always_ff @(posedge clk) begin
        // Set pixel_index based on handshaking protocol. Remember the reset!!
		if (reset) begin
			pixel_index <= 0;
		end else if (valid && ready) begin
			pixel_index <= pixel_index_next; // only increment the pixel if handshake
		end
	end
	

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
		end else if (read_enable) begin
			channel_0 <= current_pixel[11:8];	// change to 29: 20 for 30bit
			channel_1 <= current_pixel[7:4];					//19:10
			channel_2 <= current_pixel[3:0];					//9:0
		end
	end
	
	logic [8:0] delay = 0; // delay first few cycle to load data
	logic delay_logic;
	
	// valid to push data on the row buffer for the first few cycle then depend on the output
	assign delay_logic = (delay < image_width + 2 /* center kernel index */ + 1 /* shift_reg*/+ 2/*mult_result*/ + 1/*macc*/);
	// delay logic will be HIGH when pushing data into the row buffer then always set LOW
	
	
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
		 end else if (read_enable) begin
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
	 assign combined_result = {macc_2[3:0], macc_1[3:0], macc_0[3:0]}; // Combine 4 bits from each channel
    always_ff @(posedge clk) begin : output_reg
		if(reset) begin
			data_index <= 0;
			out_pixel <= 12'b0;
			valid <= 1'b0;
		end else begin
		// we have delay to skip the first few cycle to do calculation
		// timing is crucial
		// remember start_of_packet and end_of_packet signal have to be delay by 1 cycle
			if (~delay_logic) begin
				out_pixel <= combined_result;
				// Constantly streaming data
				valid <= 1'b1;
				
				// output data index (after delay)
				data_index <= data_index_next;
			end else valid <= 1'b0;
			// delay by 1 clk cycle - start of packet and end of packet
			data_index_old <= data_index;
		end
	end
	
	assign x_valid = valid;
	
	
	logic hand_shake;
	
	logic read_valid;
	// valid to push data on the row buffer for the first few cycle then depend on the output
	assign read_valid = delay_logic || valid;
	
	assign hand_shake = (valid && ready);
	
	assign read_enable = reset || (read_valid && ready); // If reset, read the first pixel value. If valid&ready (handshake), read the next pixel value for the next handshake.
	 
   assign x_ready = ready;  // Feedback ready signal
	
	//Note: Startofpacket and endofpacket only available after the delay
   assign startofpacket = ((~delay_logic) && (data_index_old == 0));         // Start of frame
   assign endofpacket = ((~delay_logic) && (data_index_old == NumPixels-1)); // End of frame


	always_comb begin
		if (reset || pixel_index == NumPixels - 1) begin
			pixel_index_next = 0;
			data_index_next = 0;
		end else if (~read_enable) begin
			pixel_index_next = pixel_index;
			data_index_next = data_index;
		end else begin
			pixel_index_next = pixel_index + 1;
			data_index_next = data_index + 1;
		end
	end
	 
	assign data = {{2{out_pixel[11:8]}}, 2'b00, {2{out_pixel[7:4]}}, 2'b00, {2{out_pixel[3:0]}}, 2'b00};
	

endmodule