onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /vga_face_tb/filter_mode
add wave -noupdate /vga_face_tb/endofpacket
add wave -noupdate /vga_face_tb/uut/read_enable
add wave -noupdate /vga_face_tb/uut/current_pixel
add wave -noupdate /vga_face_tb/uut/delay_logic
add wave -noupdate /vga_face_tb/uut/hand_shake
add wave -noupdate /vga_face_tb/ready
add wave -noupdate /vga_face_tb/valid
add wave -noupdate /vga_face_tb/clk
add wave -noupdate /vga_face_tb/reset
add wave -noupdate /vga_face_tb/uut/delay
add wave -noupdate /vga_face_tb/in_data
add wave -noupdate /vga_face_tb/data
add wave -noupdate /vga_face_tb/uut/out_pixel
add wave -noupdate /vga_face_tb/startofpacket
add wave -noupdate /vga_face_tb/uut/channel_0
add wave -noupdate /vga_face_tb/uut/row_buffer_0
add wave -noupdate /vga_face_tb/uut/shift_reg_0
add wave -noupdate /vga_face_tb/uut/stage1_mult_result_0
add wave -noupdate /vga_face_tb/uut/macc_0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6563 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 275
configure wave -valuecolwidth 208
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {6477 ps} {7073 ps}
