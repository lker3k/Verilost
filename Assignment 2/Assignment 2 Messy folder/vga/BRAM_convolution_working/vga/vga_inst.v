	vga u0 (
		.clk_clk                 (<connected-to-clk_clk>),                 //         clk.clk
		.filter_mode_filter_mode (<connected-to-filter_mode_filter_mode>), // filter_mode.filter_mode
		.reset_reset_n           (<connected-to-reset_reset_n>),           //       reset.reset_n
		.vga_CLK                 (<connected-to-vga_CLK>),                 //         vga.CLK
		.vga_HS                  (<connected-to-vga_HS>),                  //            .HS
		.vga_VS                  (<connected-to-vga_VS>),                  //            .VS
		.vga_BLANK               (<connected-to-vga_BLANK>),               //            .BLANK
		.vga_SYNC                (<connected-to-vga_SYNC>),                //            .SYNC
		.vga_R                   (<connected-to-vga_R>),                   //            .R
		.vga_G                   (<connected-to-vga_G>),                   //            .G
		.vga_B                   (<connected-to-vga_B>),                   //            .B
		.x_ready_x_ready         (<connected-to-x_ready_x_ready>)          //     x_ready.x_ready
	);

