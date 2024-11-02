module vga_face (
    input  logic        clk,             
    input  logic        reset,               // 0: Happy, 1: Neutral, 2: Angry
	 input  logic			[11:0] in_data,
	 input  logic 			start_p,
	 input  logic 			end_p,
	 

    // Avalon-ST Interface:
    output logic [29:0] data,            // Data output to VGA (8 bits each for R, G, B + additional control bits)
    output logic        startofpacket,   // Start of packet signal
    output logic        endofpacket,     // End of packet signal
    output logic        valid,           // Data valid signal
    input  logic        ready,            // Data ready signal from VGA
	 output logic 			vga_ready
);

    // Your VGA Face Code Here!
	 //logic [15:0] pitch = 4000;
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
	
	assign data = {{2{current_pixel[11:8]}}, 2'b00,
						{2{current_pixel[7:4]}}, 2'b00,
						{2{current_pixel[3:0]}}, 2'b00};


endmodule