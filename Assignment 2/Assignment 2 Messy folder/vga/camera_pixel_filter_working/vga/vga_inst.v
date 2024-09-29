	vga u0 (
		.clk_clk                 (<connected-to-clk_clk>),                 //              clk.clk
		.end_p_end_p             (<connected-to-end_p_end_p>),             //            end_p.end_p
		.in_data_in_data         (<connected-to-in_data_in_data>),         //          in_data.in_data
		.reset_reset_n           (<connected-to-reset_reset_n>),           //            reset.reset_n
		.start_p_start_p         (<connected-to-start_p_start_p>),         //          start_p.start_p
		.vga_CLK                 (<connected-to-vga_CLK>),                 //              vga.CLK
		.vga_HS                  (<connected-to-vga_HS>),                  //                 .HS
		.vga_VS                  (<connected-to-vga_VS>),                  //                 .VS
		.vga_BLANK               (<connected-to-vga_BLANK>),               //                 .BLANK
		.vga_SYNC                (<connected-to-vga_SYNC>),                //                 .SYNC
		.vga_R                   (<connected-to-vga_R>),                   //                 .R
		.vga_G                   (<connected-to-vga_G>),                   //                 .G
		.vga_B                   (<connected-to-vga_B>),                   //                 .B
		.vga_face_0_reset_reset  (<connected-to-vga_face_0_reset_reset>),  // vga_face_0_reset.reset
		.vga_ready_vga_ready     (<connected-to-vga_ready_vga_ready>),     //        vga_ready.vga_ready
		.mic_en_mic_en           (<connected-to-mic_en_mic_en>),           //           mic_en.mic_en
		.filter_mode_filter_mode (<connected-to-filter_mode_filter_mode>), //      filter_mode.filter_mode
		.face_select_face_select (<connected-to-face_select_face_select>)  //      face_select.face_select
	);

