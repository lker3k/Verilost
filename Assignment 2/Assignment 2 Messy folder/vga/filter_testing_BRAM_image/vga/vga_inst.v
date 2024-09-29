	vga u0 (
		.clk_clk                 (<connected-to-clk_clk>),                 //         clk.clk
		.face_select_face_select (<connected-to-face_select_face_select>), // face_select.face_select
		.reset_reset_n           (<connected-to-reset_reset_n>),           //       reset.reset_n
		.vga_CLK                 (<connected-to-vga_CLK>),                 //         vga.CLK
		.vga_HS                  (<connected-to-vga_HS>),                  //            .HS
		.vga_VS                  (<connected-to-vga_VS>),                  //            .VS
		.vga_BLANK               (<connected-to-vga_BLANK>),               //            .BLANK
		.vga_SYNC                (<connected-to-vga_SYNC>),                //            .SYNC
		.vga_R                   (<connected-to-vga_R>),                   //            .R
		.vga_G                   (<connected-to-vga_G>),                   //            .G
		.vga_B                   (<connected-to-vga_B>),                   //            .B
		.filter_mode_filter_mode (<connected-to-filter_mode_filter_mode>), // filter_mode.filter_mode
		.mic_en_mic_en           (<connected-to-mic_en_mic_en>)            //      mic_en.mic_en
	);

