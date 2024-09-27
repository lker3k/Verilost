
module vga (
	clk_clk,
	end_p_end_p,
	in_data_in_data,
	reset_reset_n,
	start_p_start_p,
	vga_CLK,
	vga_HS,
	vga_VS,
	vga_BLANK,
	vga_SYNC,
	vga_R,
	vga_G,
	vga_B,
	vga_face_0_reset_reset,
	vga_ready_vga_ready,
	mic_en_mic_en,
	filter_mode_filter_mode,
	face_select_face_select);	

	input		clk_clk;
	input		end_p_end_p;
	input	[11:0]	in_data_in_data;
	input		reset_reset_n;
	input		start_p_start_p;
	output		vga_CLK;
	output		vga_HS;
	output		vga_VS;
	output		vga_BLANK;
	output		vga_SYNC;
	output	[7:0]	vga_R;
	output	[7:0]	vga_G;
	output	[7:0]	vga_B;
	input		vga_face_0_reset_reset;
	output		vga_ready_vga_ready;
	input		mic_en_mic_en;
	input	[2:0]	filter_mode_filter_mode;
	input	[1:0]	face_select_face_select;
endmodule
