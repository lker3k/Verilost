
module vga (
	clk_clk,
	face_select_face_select,
	reset_reset_n,
	vga_CLK,
	vga_HS,
	vga_VS,
	vga_BLANK,
	vga_SYNC,
	vga_R,
	vga_G,
	vga_B,
	filter_mode_filter_mode,
	mic_en_mic_en);	

	input		clk_clk;
	input	[1:0]	face_select_face_select;
	input		reset_reset_n;
	output		vga_CLK;
	output		vga_HS;
	output		vga_VS;
	output		vga_BLANK;
	output		vga_SYNC;
	output	[7:0]	vga_R;
	output	[7:0]	vga_G;
	output	[7:0]	vga_B;
	input	[2:0]	filter_mode_filter_mode;
	input		mic_en_mic_en;
endmodule
