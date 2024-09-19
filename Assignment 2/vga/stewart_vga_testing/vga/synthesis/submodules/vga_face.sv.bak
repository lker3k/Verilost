module vga_face (
    input  logic        clk,             
    input  logic        reset,           
    input  logic [1:0]  face_select,     // 0: Happy, 1: Neutral, 2: Angry

    // Avalon-ST Interface:
    output logic [29:0] data,            // Data output to VGA (8 bits each for R, G, B + additional control bits)
    output logic        startofpacket,   // Start of packet signal
    output logic        endofpacket,     // End of packet signal
    output logic        valid,           // Data valid signal
    input  logic        ready            // Data ready signal from VGA
);

    // Your VGA Face Code Here!
    typedef enum logic [1:0] {Happy=2'd0, Neutral=2'd1, Angry=2'd2} face_t; // Define an enum type for readability (optional).

    localparam NumPixels     = 640 * 480; // Total number of pixels on the 640x480 screen
    localparam NumColourBits = 3;         // We are using a 3-bit colour space to fit 3 images within the 3.888 Mbits of BRAM on our FPGA.

    // Image ROMs:
    (* ram_init_file = "happy.mif" *)   logic [NumColourBits-1:0] happy_face   [NumPixels]; // The ram_init_file is a Quartus-only directive
    (* ram_init_file = "neutral.mif" *) logic [NumColourBits-1:0] neutral_face [NumPixels]; //   specifying the name of the initialisation file,
    (* ram_init_file = "angry.mif" *)   logic [NumColourBits-1:0] angry_face   [NumPixels]; //   and Verilator will ignore it.

    `ifdef VERILATOR
    initial begin : memset /* The 'ifdef VERILATOR' means this initial block is ignored in Quartus */
        $readmemh("happy.hex", happy_face);
        $readmemh("neutral.hex", neutral_face);
        $readmemh("angry.hex", angry_face);
    end
    `endif
     
    logic [18:0] pixel_index = 0, pixel_index_next; // The pixel counter/index. Set pixel_index_next in an always_comb block.
                                                    // Set pixel_index <= pixel_index_next in an always_ff block.

    logic [NumColourBits-1:0] happy_face_q, neutral_face_q, angry_face_q; // Registers for reading from each ROM.
      
    logic read_enable; // Need to have a read enable signal for the BRAM
    assign read_enable = reset | (valid & ready); // If reset, read the first pixel value. If valid&ready (handshake), read the next pixel value for the next handshake.

    always_ff @(posedge clk) begin : bram_read // This block is for correctly inferring BRAM in Quartus - we need read registers!
        if (read_enable) begin
            happy_face_q   <= happy_face[pixel_index_next];
            neutral_face_q <= neutral_face[pixel_index_next];
            angry_face_q   <= angry_face[pixel_index_next];
        end
    end
    
    /* Complete the TODOs below */

    logic [NumColourBits-1:0] current_pixel; //TODO assign this to one of happy_face_q, neutral_face_q or angry_face_q depending on the value of face_select.

    assign valid = ~reset;//TODO valid should be set to low when we are in reset - otherwise, we are constantly streaming data (valid stays high).

    assign startofpacket = pixel_index == 0;         // Start of frame
    assign endofpacket = pixel_index == NumPixels-1; // End of frame

    //assign data = { ... }; //TODO assign data. Keep in mind, each RGB channel should be 10 bits like so: {8 bits of colour data, 2 bits of zero padding}.
    // Remember, our 3-bit wide image ROMs only have 1-bit for each colour channel!! (Hint: use the replication operator to convert from 1-bit to 8-bit colour).
    always_comb begin
        if (face_select == 0) begin
            data = {{8{happy_face_q[2]}}, 2'b00, {8{happy_face_q[1]}}, 2'b00, {8{happy_face_q[0]}}, 2'b00};
        end else if (face_select == 1) begin
            data = {{8{neutral_face_q[2]}}, 2'b00, {8{neutral_face_q[1]}}, 2'b00, {8{neutral_face_q[0]}}, 2'b00};
        end else if (face_select == 2) begin
            data = {{8{angry_face_q[2]}}, 2'b00, {8{angry_face_q[1]}}, 2'b00, {8{angry_face_q[0]}}, 2'b00};
        end else;
    end

    //assign pixel_index_next = ((!reset)*(pixel_index+1));//TODO Set pixel_index_next (what **would be** the next value?)
                              //TODO ^^^ Also, make pixel_index_next = 0 if reset == 1.
    always_comb begin : next_pixel_logic
        if (reset) begin
            pixel_index_next <= 0;
        end else if (read_enable) begin
            if (pixel_index == NumPixels - 1) begin
                pixel_index_next = 0;
            end else begin
                pixel_index_next = pixel_index + 1;
            end
        end else;
    end
    always_ff @(posedge clk) begin
        //TODO Set pixel_index based on handshaking protocol. Remember the reset!!
        if (!reset) begin
            pixel_index <= pixel_index_next;
        end else begin
            pixel_index <= 0;
        end
    end


endmodule
