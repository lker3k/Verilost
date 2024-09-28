module vga_face (
    input  logic        clk,             
    input  logic        reset,               // 0: Happy, 1: Neutral, 2: Angry
	 input  logic			[11:0] in_data,
	 input  logic 			start_p,
	 input  logic 			end_p,
	 
	 input  logic [1:0]  face_select,     // 0: Happy, 1: Neutral, 2: Angry
	 input  logic [15:0] pitch,
	 input  logic        mic_en,  // microphone enabled
	 input  logic [2:0]	filter_mode,

    // Avalon-ST Interface:
    output logic [29:0] data,            // Data output to VGA (8 bits each for R, G, B + additional control bits)
    output logic        startofpacket,   // Start of packet signal
    output logic        endofpacket,     // End of packet signal
    output logic        valid,           // Data valid signal
    input  logic        ready,            // Data ready signal from VGA
	 output logic 			vga_ready
);

    // Your VGA Face Code Here!
	 //logic [15:0] pitch = 5001;
	 //logic        mic_en = 1;
	 //logic [2:0]	filter_mode = 1; // 0 for no filter, 1 for grey, 2 for shift

    //localparam NumPixels     = 320*240; // Total number of pixels on the 640x480 screen
    localparam NumColourBits = 12;         // We are using a 3-bit colour space to fit 3 images within the 3.888 Mbits of BRAM on our FPGA.


    //logic [NumColourBits-1:0] cam_q;
    logic read_enable; // Need to have a read enable signal for the BRAM
    assign read_enable = reset | (valid & ready); // If reset, read the first pixel value. If valid&ready (handshake), read the next pixel value for the next handshake.


    
    /* Complete the TODOs below */

    logic [NumColourBits-1:0] current_pixel; //TODO assign this to one of happy_face_q, neutral_face_q or angry_face_q depending on the value of face_select.

    assign valid = ~reset;//TODO valid should be set to low when we are in reset - otherwise, we are constantly streaming data (valid stays high).

    assign startofpacket = start_p;         // Start of frame
    assign endofpacket = end_p; // End of frame
	assign vga_ready = ready;

	 assign current_pixel = in_data;
	
   logic [9:0] grey_scale;
	logic [9:0] grey_scale_addition;
	logic [9:0] grey_scale_acc;
	
	
	always_comb begin: greyscale_mac_addition
		grey_scale_addition = {2{current_pixel[11:8]}} + {2{current_pixel[7:4]}} + {2{current_pixel[3:0]}};
	end
	
	always_comb begin: greyscale_mac_accumulate
		grey_scale_acc = (grey_scale_addition);
	end

	assign grey_scale = grey_scale_acc;
    // assign data. Keep in mind, each RGB channel should be 10 bits like so: {8 bits of colour data, 2 bits of zero padding}.
   always_ff @(posedge clk) begin: pixel_filters
		case (filter_mode)
			// greyscale filter
			1: begin 
				if (~mic_en) begin // normal greyscale when no mic input
					data <= {3{grey_scale}};
				end else if (pitch <= 3000 /*|| ~mic_en*/) begin // low pitch, red is kept
					data <= {	{2{current_pixel[11:8]}},  2'b00,
								{2{grey_scale}}};
				end else if (pitch <= 5000) begin // medium pitch, non green is filtered out
					data <= {	{1{grey_scale}},
								{2{current_pixel[7:4]}},  2'b00,
								{1{grey_scale}}};
				end else if (pitch <= 8000) begin // high pitch blue is kept
					data <= {	{2{grey_scale}},
								{2{current_pixel[3:0]}},  2'b00};
				end 
			end
			
			// colour shift fitler
			2: begin
				if (~mic_en || pitch <= 4000) begin // default state, colour is left shifted
					data <= {	{2{current_pixel[7:4]}},  2'b00, 	// value of green is shifted to red
								{2{current_pixel[3:0]}},  2'b00,	// value of blue is shifted to green
								{2{current_pixel[11:8]}},  2'b00};	// value of red is shifted to blue
				end else if (pitch > 4000) begin // low pitch, colour is right shifted
				data <= {	{2{current_pixel[3:0]}}, 2'b00,
							{2{current_pixel[11:8]}}, 2'b00,
							{2{current_pixel[7:4]}}, 2'b00};
				end 
			end
			// other filter selected
			0:	begin // no filter is selected
				data <= {	{2{current_pixel[11:8]}}, 2'b00,
							{2{current_pixel[7:4]}}, 2'b00,
							{2{current_pixel[3:0]}}, 2'b00};
			end
			3:	begin // no filter is selected
				data <= {	{2{current_pixel[11:8]}}, 2'b00,
							{2{current_pixel[7:4]}}, 2'b00,
							{2{current_pixel[3:0]}}, 2'b00};
			end
			4:	begin // no filter is selected
				data <= {	{2{current_pixel[11:8]}}, 2'b00,
							{2{current_pixel[7:4]}}, 2'b00,
							{2{current_pixel[3:0]}}, 2'b00};
			end
			default:	begin // no filter is selected
				data <= {	{2{current_pixel[11:8]}}, 2'b00,
							{2{current_pixel[7:4]}}, 2'b00,
							{2{current_pixel[3:0]}}, 2'b00};
			end
		endcase	  
	end // 210 normal
			// 102 shift left
			// 021 shift right
			// 120 rg swap
			// 012 rb swap
			// 201 gb swap

endmodule