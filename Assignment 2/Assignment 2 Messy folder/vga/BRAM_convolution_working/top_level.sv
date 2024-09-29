module top_level (
		input  wire        CLOCK_50,
		input  wire [17:0] SW,
		
		output wire        VGA_CLK,    
		output wire        VGA_HS,     
		output wire        VGA_VS,     
		output wire        VGA_BLANK,  
		output wire        VGA_SYNC,   
		output wire [7:0]  VGA_R,        
		output wire [7:0]  VGA_G,        
		output wire [7:0]  VGA_B         
);

wire ready;

vga u_vga (
		.clk_clk(CLOCK_50),
		.filter_mode_filter_mode(SW[3:1]),
		.reset_reset_n(1'b1),
		//.mic_en_mic_en(SW[4]),
		//.filter_mode_filter_mode(SW[3:2]),
		.x_ready_x_ready(ready),
		.vga_CLK(VGA_CLK),
		.vga_HS(VGA_HS),
		.vga_VS(VGA_VS),
		.vga_BLANK(VGA_BLANK),
		.vga_SYNC(VGA_SYNC),
		.vga_R(VGA_R),
		.vga_G(VGA_G),
		.vga_B(VGA_B)
	);

endmodule

