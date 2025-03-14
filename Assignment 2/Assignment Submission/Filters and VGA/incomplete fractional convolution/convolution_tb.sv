module convolution_tb;

    // Parameters
    parameter W = 12;
    parameter image_width = 10;

    // Testbench signals
    reg clk;
	 reg reset;
    reg [W-1:0] x_data;
    reg x_valid;
    reg [2:0] filter_mode;
    reg mic_en;
    wire x_ready;
    wire [W-1:0] y_data;
    wire y_valid;
	 reg [8:0] data_index;

    // Instantiate the convolution module
    convolution #(W, image_width) uut (
        .clk(clk),
		  .reset(reset),
        .x_data(x_data),
        .x_valid(x_valid),
        .filter_mode(filter_mode),
        .mic_en(mic_en),
        .x_ready(x_ready),
        .y_data(y_data),
        .y_valid(y_valid),
		  .data_index(data_index)
    );

    // Clock generation
    initial begin
        clk = 0;

        forever #10 clk = ~clk;  // 10 ns clock period (100 MHz)
    end

    // Test stimulus
    initial begin
		$dumpfile("waveform.vcd");  // Tell the simulator to dump variables into the 'waveform.vcd' file during the simulation. Required to produce a waveform .vcd file.
        $dumpvars();    
        // Initialize inputs
        x_data = 12'b0;
        x_valid = 0;
        filter_mode = 3'b011;
        mic_en = 1'b0;
		  reset = 1;

        // Wait for a few clock cycles
        repeat(5) @(posedge clk);
			reset = 0;
        // Enable valid signal and send data stream
        x_valid = 1;
        filter_mode = 3'b011;  // Select blur filter for the test
        mic_en = 1'b1;

        // Provide input pixel data (example stream)
        @(posedge clk);
        x_data = 12'b110011001100;  // Example pixel value
        
        @(posedge clk);
        x_data = 12'b001111000011;  // Another pixel value
        
        @(posedge clk);
        x_data = 12'b111000111000;  // Another pixel value

        @(posedge clk);
        x_data = 12'b000111011000;  // Another pixel value
		  
		  @(posedge clk);
        x_data = 12'b000111000111;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b000001110000;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b000111000111;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b111000111010;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b000111111111;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b111000111010;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b000101101011;  // Another pixel value
		  
		          @(posedge clk);
        x_data = 12'b110011001100;  // Example pixel value
        
        @(posedge clk);
        x_data = 12'b001111000011;  // Another pixel value
        
        @(posedge clk);
        x_data = 12'b111000111000;  // Another pixel value

        @(posedge clk);
        x_data = 12'b000111011000;  // Another pixel value
		  
		  @(posedge clk);
        x_data = 12'b000111000111;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b000001110000;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b000111000111;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b111000111010;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b000111111111;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b111000111010;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b000101101011;  // Another pixel value
		  
		          @(posedge clk);
        x_data = 12'b110011001100;  // Example pixel value
        
        @(posedge clk);
        x_data = 12'b001111000011;  // Another pixel value
        
        @(posedge clk);
        x_data = 12'b111000111000;  // Another pixel value

        @(posedge clk);
        x_data = 12'b000111011000;  // Another pixel value
		  
		  @(posedge clk);
        x_data = 12'b000111000111;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b000001110000;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b000111000111;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b111000111010;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b000111111111;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b111000111010;  // Another pixel value
		  @(posedge clk);
        x_data = 12'b000101101011;  // Another pixel value
			
			
		#100
        // Turn off valid signal
        @(posedge clk);
        x_valid = 0;
        x_data = 12'b0;

        // Wait for output data
        //wait(y_valid);
        @(posedge clk);
        $display("Output Data: %b", y_data);

        // Finish simulation
        $finish();
    end

endmodule
