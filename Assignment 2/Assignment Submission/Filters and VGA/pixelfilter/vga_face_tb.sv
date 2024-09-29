module vga_face_tb;

    // Parameters for the testbench
    localparam CLK_PERIOD = 10;  // 100 MHz clock

    // Inputs to the DUT
    logic clk;
    logic reset;
    logic [1:0] face_select;
    logic mic_en;
    logic [2:0] filter_mode;
    logic [11:0] in_data;

    // Outputs from the DUT
    logic [29:0] data;
    logic startofpacket;
    logic endofpacket;
    logic valid;
    logic ready;

    // Instantiate the DUT (Device Under Test)
    vga_face dut (
        .clk(clk),
        .reset(reset),
        .face_select(face_select),
        .mic_en(mic_en),
        .filter_mode(filter_mode),
        .in_data(in_data),
        .data(data),
        .startofpacket(startofpacket),
        .endofpacket(endofpacket),
        .valid(valid),
        .ready(ready)
    );

    // Clock generation
    always begin
        clk = 0;
        # (CLK_PERIOD / 2);
        clk = 1;
        # (CLK_PERIOD / 2);
    end

    // Test different scenarios
    initial begin
        // Initialize inputs
		  reset = 1;
        face_select = 2'b00;
        mic_en = 0;
        filter_mode = 3'b000;
        in_data = 12'h000;
        ready = 1;  // Always ready for data
        #CLK_PERIOD;
        reset = 0;

        // Test 1: Simple happy face selection, no mic, no filter
        face_select = 2'b00;  // Happy face
        in_data = 12'hAF1;    // Random pixel data
        filter_mode = 3'b000; // No filter
        mic_en = 0;

        // Run for a few clock cycles
        repeat (6) @(posedge clk);

        // Test 2: Angry face selection, mic enabled, greyscale filter
        face_select = 2'b10;  // Angry face
        filter_mode = 3'b001; // Greyscale filter
        mic_en = 0;

        // Provide different input data for angry face
        in_data = 12'hF03;

        // Run for a few clock cycles
        repeat (6) @(posedge clk);

        // Test 3: Color shift filter with mic enabled
        filter_mode = 3'b010; // Color shift filter

        // Run for a few clock cycles
        repeat (6) @(posedge clk);
		  mic_en = 1;
		  repeat (20) @(posedge clk);

        // Finish simulation
        $finish;
    end

    // Monitor output signals
    /*initial begin
        $monitor("Time: %0t | in_Data: %b |Data: %b |Filter: %b| StartOfPacket: %b | EndOfPacket: %b | Valid: %b",
                 $time, in_data, data, filter_mode, startofpacket, endofpacket, valid);
    end*/
	 always @(posedge clk) begin
    $display("Time %0t: filter_mode=%d, in_data=%b, data=%b, startofpacket=%b, endofpacket=%b, valid=%b", 
             $time, filter_mode, in_data, data, startofpacket, endofpacket, valid);
		end

endmodule