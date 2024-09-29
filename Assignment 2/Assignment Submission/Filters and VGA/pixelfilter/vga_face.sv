module vga_face (
	input  logic        clk,             
	input  logic        reset,           
	input  logic [1:0]  face_select,     // 0: Happy, 1: Neutral, 2: Angry
	//input  logic [15:0] pitch,
	input  logic        mic_en,  // microphone enabled
	input  logic [2:0]	filter_mode,
	input  logic [11:0] in_data,

   // Avalon-ST Interface:
	output logic [29:0] data,            // Data output to VGA (8 data bits + 2 padding bits for each colour Red, Green and Blue = 30 bits)
   output logic        startofpacket,   // Start of packet signal
   output logic        endofpacket,     // End of packet signal
   output logic        valid,           // Data valid signal
   input  logic        ready            // Data ready signal from VGA Module
);

	logic [15:0] pitch = 5000;
	//logic        mic_en = 1;
	//logic [2:0]	filter_mode = 1; // 0 for no filter, 1 for grey, 2 for shift

	
	typedef enum logic [1:0] {Happy=2'd0, Neutral=2'd1, Angry=2'd2} face_t; // Define an enum type for readability (optional).

	localparam NumPixels     = 320 * 240; // Total number of pixels on the 640x480 screen
	localparam NumColourBits = 12;         // We are using a 3-bit colour space to fit 3 images within the 3.888 Mbits of BRAM on our FPGA.

	// Image ROMs:
	//(* ram_init_file = "happy.mif" *)   logic [NumColourBits-1:0] happy_face   [NumPixels]; // The ram_init_file is a Quartus-only directive
	//(* ram_init_file = "neutral.mif" *) logic [NumColourBits-1:0] neutral_face [NumPixels]; //   specifying the name of the initialisation file,
	//(* ram_init_file = "angry.mif" *)   logic [NumColourBits-1:0] angry_face   [NumPixels]; //   and Verilator will ignore it.
	
	//(* ram_init_file = "stewart.mif" *)   logic [NumColourBits-1:0] stewart_face   [NumPixels];
    
	logic [18:0] pixel_index = 0, pixel_index_next; // The pixel counter/index. Set pixel_index_next in an always_comb block.
																 // Set pixel_index <= pixel_index_next in an always_ff block.

	logic [NumColourBits-1:0] stewart_q;
	
	logic read_enable; // Need to have a read enable signal for the BRAM
	assign read_enable = reset | (valid & ready); // If reset, read the first pixel value. If valid&ready (handshake), read the next pixel value for the next handshake.

	always_ff @(posedge clk) begin : bram_read // This block is for correctly inferring BRAM in Quartus - we need read registers!
		if (read_enable) begin
			//stewart_q <= stewart_face[pixel_index_next];
			stewart_q <= in_data;
		end
	end
 
    /* Complete the TODOs below */

   logic [NumColourBits-1:0] current_pixel; //TODO assign this to one of happy_face_q, neutral_face_q or angry_face_q depending on the value of face_select.
   always_comb begin
		current_pixel = stewart_q;
   end


   assign valid = ~reset;//TODO valid should be set to low when we are in reset - otherwise, we are constantly streaming data (valid stays high).

   assign startofpacket = pixel_index == 0;         // Start of frame
   assign endofpacket = pixel_index == NumPixels-1; // End of frame


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
				end else if (pitch > 4000) begin // high pitch, colour is right shifted
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
			3:	begin // convolution filter is selected
				data <= {	{2{current_pixel[11:8]}}, 2'b00,
							{2{current_pixel[7:4]}}, 2'b00,
							{2{current_pixel[3:0]}}, 2'b00};
			end
			4:	begin // convolution filter is selected
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
	end 
	
    //Set pixel_index_next (what **would be** the next value?)
    //^^^ Also, make pixel_index_next = 0 if reset == 1.
   assign pixel_index_next =   (reset) ? 0 : 
                                (pixel_index == NumPixels - 1) ? 0 :
                                pixel_index + 1;

	always_ff @(posedge clk) begin
        // Set pixel_index based on handshaking protocol. Remember the reset!!
		if (reset) begin
			pixel_index <= 0;
		end else if (valid && ready) begin
			pixel_index <= pixel_index_next; // only increment the pixel if handshake
		end
	end

endmodule