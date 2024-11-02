	vga u0 (
		.clk_clk             (<connected-to-clk_clk>),             //       clk.clk
		.reset_reset_n       (<connected-to-reset_reset_n>),       //     reset.reset_n
		.vga_CLK             (<connected-to-vga_CLK>),             //       vga.CLK
		.vga_HS              (<connected-to-vga_HS>),              //          .HS
		.vga_VS              (<connected-to-vga_VS>),              //          .VS
		.vga_BLANK           (<connected-to-vga_BLANK>),           //          .BLANK
		.vga_SYNC            (<connected-to-vga_SYNC>),            //          .SYNC
		.vga_R               (<connected-to-vga_R>),               //          .R
		.vga_G               (<connected-to-vga_G>),               //          .G
		.vga_B               (<connected-to-vga_B>),               //          .B
		.end_p_end_p         (<connected-to-end_p_end_p>),         //     end_p.end_p
		.start_p_start_p     (<connected-to-start_p_start_p>),     //   start_p.start_p
		.in_data_in_data     (<connected-to-in_data_in_data>),     //   in_data.in_data
		.vga_ready_vga_ready (<connected-to-vga_ready_vga_ready>)  // vga_ready.vga_ready
	);

