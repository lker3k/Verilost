
module vga (
	clk_clk,
	reset_reset_n,
	vga_CLK,
	vga_HS,
	vga_VS,
	vga_BLANK,
	vga_SYNC,
	vga_R,
	vga_G,
	vga_B,
	end_p_end_p,
	start_p_start_p,
	in_data_in_data,
	vga_ready_vga_ready);	

	input		clk_clk;
	input		reset_reset_n;
	output		vga_CLK;
	output		vga_HS;
	output		vga_VS;
	output		vga_BLANK;
	output		vga_SYNC;
	output	[7:0]	vga_R;
	output	[7:0]	vga_G;
	output	[7:0]	vga_B;
	input		end_p_end_p;
	input		start_p_start_p;
	input	[11:0]	in_data_in_data;
	output		vga_ready_vga_ready;
endmodule
