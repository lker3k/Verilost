module cam_detect(
	input logic        clk,             
	input logic        reset,
	input logic [11:0]	in_data, 		// 12bit RGB pixel
	input logic [1:0]		color_mode, 	// 4 color mode for 3 table colour (rgb) and 1 for the kitchen
	
	input logic [18:0]	row,
	input logic [18:0]	col,
	
	
	
	output logic [2:0]	operate_mode	// 2 mode for motor behaviour, 0 for scanning, 1 for going forward	
);

	localparam NumColourBits = 12;
	localparam image_width = 320;
	localparam image_height = 240;
	
	// the size is 320x240 - 320 col, 240 row
	
	logic [2:0] current_pixel;
	
	logic red_logic, green_logic, blue_logic;
	
	assign red_logic = ((in_data[11:8] > 4'b0110) /* 70% red */ && (in_data[7:4] < 4'b0011) /* 10% green */ && (in_data[3:0] < 4'b0011)); /*10% blue*/
	
	assign green_logic = ((in_data[11:8] < 4'b0100) /* 10% red */ && (in_data[7:4] > 4'b0110) /* 70% green */ && (in_data[3:0] < 4'b0100)); /*10% blue*/

	assign blue_logic = ((in_data[11:8] < 4'b0101) /* 10% red */ && (in_data[7:4] < 4'b0101) /* 10% green */ && (in_data[3:0] > 4'b0110)); /*70% blue*/
	
	// thresholded the color
	always_comb begin
		if (red_logic) begin
			current_pixel = 3'b100;
		end else if (green_logic) begin
			current_pixel = 3'b010;
		end else if (blue_logic) begin
			current_pixel = 3'b001;
		end else current_pixel = 3'b000;
	end
	
	logic [2:0] red = 3'b100;
	logic [2:0] green = 3'b010;
	logic [2:0] blue = 3'b001;
	logic [2:0] white = 3'b111;
	
	typedef enum logic [1:0] {Red = 2'b00, Green = 2'b01, Blue = 2'b10, White = 2'b11} color_t;
	
	logic [2:0] color_check; // checking color for different mode
	
	always_comb begin
		case(color_mode)
			Red: color_check = red;
			Blue: color_check = blue;
			Green: color_check = green;
			White: color_check = white;
			default: color_check = white;
		endcase
	end
	
	typedef enum logic [2:0] {LEFT = 3'b100, RIGHT = 3'b001, MIDDLE = 3'b010, NO_COLOR = 3'b000} operate_t;
	
	
	//integer row = 0, col = 0;	// pixel address of the camera
	
	/*
	always_ff @(posedge clk) begin
		if(reset) begin
			row <= 0;
			col <= 0;
		end else begin
			if (col >= image_width-1) begin
				col <= 0;
				if (row >= image_height-1) begin
					row <= 0;
				end else row <= row + 1;
			end else col <= col + 1;
		end
	end
	*/

	logic [$clog2(image_height) + 1: 0] sum [0:image_width-1]; // summing all of the pixels
	
	logic condition_buffer [0:image_width - 1]; // to do the summing - thresholded image
	
	logic [2:0] row_buffer [0:image_width-1]; // store data to do condition
	
	always_comb begin
		for (int i = 0; i < image_width; i = i + 1) begin
			if (row_buffer[i] == color_check) begin
				condition_buffer[i] = 1;
			end else condition_buffer[i] = 0;
		end
	end
	
	always_ff @(posedge clk) begin
		if (reset) begin 
			for (int j = 0; j < image_width; j = j + 1) begin
				row_buffer[j] <= 3'b0;
				sum[j] <= 0;
			end
		end else begin
			row_buffer[col] <= current_pixel;
			if (col == 0 && row == 0) begin
				for (int j = 0; j < image_width; j = j + 1) begin
					sum[j] <= 0;
				end
			end else if (col == 0) begin
				for (int j = 0; j < image_width; j = j + 1) begin
					sum[j] <= sum[j] + condition_buffer[j];
				end
			end
		end
	end
	
	// checking image
	
	logic [((image_width - 3)/2)*$clog2(image_height) + 1: 0] left_acc;
	logic [((image_width - 3)/2)*$clog2(image_height) + 1: 0] right_acc;
	logic [3*$clog2(image_height) + 1: 0] mid_acc;
	
	always_comb begin
		mid_acc = 0;
		left_acc = 0;
		right_acc = 0;
		if (row == (image_height-1) && col == (image_width-1))begin
		// left accumulate
			for (int k = 0; k < ((image_width/3)-3); k = k + 1) begin
				left_acc = left_acc + sum[k];
			end
			
			// middle accumulate
			for (int k = ((image_width/3)-3); k <= ((2*image_width/3)+3); k = k + 1) begin
				mid_acc = mid_acc + sum[k];
			end
			
			// right accumulate
			for (int k = (2*image_width/3 + 4); k < image_width; k = k + 1) begin
				right_acc = right_acc + sum[k];
			end
		end
	end
	
	logic [2:0] operate_mode_old;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			operate_mode_old <= NO_COLOR;
		end else begin
			operate_mode_old <= operate_mode;
		end
	end
	
	always_comb begin
		if (reset) begin
			operate_mode = NO_COLOR;
		end else begin
			if (mid_acc == 0 && left_acc == 0 && right_acc == 0 && row == (image_height - 1) && col == (image_width - 1)) begin
				operate_mode = NO_COLOR;
			end else if (mid_acc == 0 && left_acc == 0 && right_acc == 0) begin
			//new frame so avoid overwrite condition
				operate_mode = operate_mode_old;
			end else if (mid_acc >= left_acc && mid_acc >= right_acc) begin
			// most color detect in the middle
				operate_mode = MIDDLE;
			end else if (right_acc >= mid_acc && right_acc >= left_acc) begin
			// most color detect in the right
				operate_mode = RIGHT;
			end else if (left_acc >= mid_acc && left_acc >= right_acc) begin
			// most color detect in the left
				operate_mode = LEFT;
			end else operate_mode = operate_mode_old;
		end
	end
	
endmodule
	
	