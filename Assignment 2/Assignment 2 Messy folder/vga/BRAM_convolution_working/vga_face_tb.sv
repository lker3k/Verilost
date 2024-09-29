module vga_face_tb;

    logic        clk;
    logic        reset;
    logic [2:0]  filter_mode;
    logic [29:0] data;
    logic        startofpacket;
    logic        endofpacket;
    logic        valid;
    logic        ready = 1'b0;
	 logic [11:0] in_data;

    // Instantiate the vga_face module
    vga_face uut (
        .clk(clk),
        .reset(reset),
		  .in_data(in_data),
        .filter_mode(filter_mode),
        .data(data),
        .startofpacket(startofpacket),
        .endofpacket(endofpacket),
        .valid(valid),
        .ready(ready)
    );

    localparam CLK_T = 20;

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_T/2) clk = ~clk; // 50 MHz clock
    end

    // Simulation procedure
    initial begin : procedure
        $dumpfile("waveform.vcd");
        $dumpvars();
        // Initialize signals
        reset = 1'b1;
        filter_mode = 3'b000; // Happy face
		  in_data = 12'b0;

        // Apply reset
        #CLK_T reset = 1'b0;
		  
			  
		  repeat(10) begin
				{in_data} = ($urandom());
			  // Run for some time with Happy face
			  #(CLK_T*100) filter_mode = 3'b000; // Switch to Neutral face
			  

			  // Run for some time with Neutral face
			  #(CLK_T*100) filter_mode = 3'b000; // Switch to Angry face

			  // Run for some time with Angry face
			  #(CLK_T*100);
				#1000;
				//#2100000
			  // End the simulation
			end
			
        $finish();
    end

    // Monitor signals to verify behavior
    always_ff @(posedge clk) begin : monitor
        if (valid && ready) begin
            $display("Received pixel: pixel_index =%d, filter_mode = %d, data = %b", 
                      uut.pixel_index, filter_mode, data);
        end
    end

    always_ff @(posedge clk) begin : vga_stall
        ready <= ($urandom() % 8 >= 2); // VGA is ready to receive 75% of the time.
    end

endmodule

