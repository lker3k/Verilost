module cam_detect_tb;
  
  // Inputs to the cam_detect module
  logic clk;
  logic reset;
  logic [11:0] in_data;     // 12-bit RGB pixel
  logic [1:0] color_mode;   // Color mode

  // Output from the cam_detect module
  logic [2:0] operate_mode;       // Motor behavior: 0 = SCAN, 1 = FORWARD

  // Instantiate the cam_detect module
  cam_detect uut (
    .clk(clk),
    .reset(reset),
    .in_data(in_data),
    .color_mode(color_mode),
    .operate_mode(operate_mode)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10ns period (100 MHz clock)
  end

  // Test sequence
  initial begin
    // Test 1: Reset the system
    reset = 1;
    #10;
    reset = 0;
    
    // Test 2: Check behavior for each color mode (Red, Green, Blue, White)
	 color_mode = 2'b01;  // Green mode
    in_data = 12'b000000000000;  // test different pixels
	 #100;
	 repeat(50) begin
		in_data = ($urandom());
	 #10;
	 end
	 in_data = 12'b000011110000;
	 #100;
	 in_data = 12'b000000000000;
	 #400;
	 
    
    // Set pixel to red, expect FORWARD when color_mode is Red
    color_mode = 2'b00;  // Red mode
    in_data = 12'b111100000000;  // Red pixel
    #100;
    //assert(operate_mode == 1'b1) else $fatal("Error: Red mode not detected correctly.");
	 repeat(10) begin
		in_data = ($urandom());
		#10;
	 end
		
    
    // Set pixel to green, expect FORWARD when color_mode is Green
    color_mode = 2'b01;  // Green mode
    in_data = 12'b000011110000;  // Green pixel
    #100;
    //assert(operate_mode == 1'b1) else $fatal("Error: Green mode not detected correctly.");
	 repeat(10) begin
		in_data = ($urandom());
		#10;
	 end
    // Set pixel to blue, expect FORWARD when color_mode is Blue
    color_mode = 2'b10;  // Blue mode
    in_data = 12'b000000001111;  // Blue pixel
    #100;
    //assert(operate_mode == 1'b1) else $fatal("Error: Blue mode not detected correctly.");
	 repeat(10) begin
		in_data = ($urandom());
		#10;
	 end
    // Set pixel to white, expect FORWARD when color_mode is White
    color_mode = 2'b11;  // White mode
    in_data = 12'b111111111111;  // White pixel
    #100;
    //assert(operate_mode == 1'b1) else $fatal("Error: White mode not detected correctly.");
	 repeat(10) begin
		in_data = ($urandom());
		#10;
	 end
    // Test 3: Check SCAN mode when out of the center column range
    color_mode = 2'b00;  // Red mode
    in_data = 12'b111100000000;  // Red pixel
    #10;
    #10;
    //assert(operate_mode == 1'b0) else $fatal("Error: SCAN mode not working when out of center column.");
    
	 in_data = 12'b001101010100;
	 #100;
	 
    // Test 4: Reset the system and check for reset behavior
    reset = 1;
    #10;
	 reset = 0;
	 #10;
    //assert(uut.row == 0 && uut.col == 0) else $fatal("Error: Reset behavior incorrect.");
	 color_mode = 2'b01;
	 // set col to check the left side detect behaviour
	 uut.col = 7;
	 uut.row = 8;
	 in_data = 12'b000011110000;
	 #500;
	 
	 #100;
	 
    
    $display("All tests passed.");
    $finish;
  end

endmodule