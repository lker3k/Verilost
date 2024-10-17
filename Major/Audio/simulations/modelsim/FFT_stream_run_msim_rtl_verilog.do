transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/mtrx3700/mic/mic/mic {D:/mtrx3700/mic/mic/mic/i2c_pll.v}
vlog -vlog01compat -work work +incdir+D:/mtrx3700/mic/mic/mic {D:/mtrx3700/mic/mic/mic/adc_pll.v}
vlog -vlog01compat -work work +incdir+D:/mtrx3700/mic/mic {D:/mtrx3700/mic/mic/async_fifo.v}
vlog -vlog01compat -work work +incdir+D:/mtrx3700/mic/mic/db {D:/mtrx3700/mic/mic/db/adc_pll_altpll.v}
vlog -vlog01compat -work work +incdir+D:/mtrx3700/mic/mic/db {D:/mtrx3700/mic/mic/db/i2c_pll_altpll.v}
vlog -vlog01compat -work work +incdir+D:/mtrx3700/mic/mic/r22sdf {D:/mtrx3700/mic/mic/r22sdf/fft.v}
vlog -vlog01compat -work work +incdir+D:/mtrx3700/mic/mic/r22sdf {D:/mtrx3700/mic/mic/r22sdf/sdfunit.v}
vlog -vlog01compat -work work +incdir+D:/mtrx3700/mic/mic/r22sdf {D:/mtrx3700/mic/mic/r22sdf/butterfly.v}
vlog -vlog01compat -work work +incdir+D:/mtrx3700/mic/mic/r22sdf {D:/mtrx3700/mic/mic/r22sdf/delaybuffer.v}
vlog -vlog01compat -work work +incdir+D:/mtrx3700/mic/mic/r22sdf {D:/mtrx3700/mic/mic/r22sdf/twiddle.v}
vlog -vlog01compat -work work +incdir+D:/mtrx3700/mic/mic/r22sdf {D:/mtrx3700/mic/mic/r22sdf/multiply.v}
vlog -sv -work work +incdir+D:/mtrx3700/mic/mic {D:/mtrx3700/mic/mic/dstream.sv}
vlog -sv -work work +incdir+D:/mtrx3700/mic/mic {D:/mtrx3700/mic/mic/seven_seg.sv}
vlog -sv -work work +incdir+D:/mtrx3700/mic/mic {D:/mtrx3700/mic/mic/display.sv}
vlog -sv -work work +incdir+D:/mtrx3700/mic/mic {D:/mtrx3700/mic/mic/fft_find_peak.sv}
vlog -sv -work work +incdir+D:/mtrx3700/mic/mic {D:/mtrx3700/mic/mic/fft_mag_sq.sv}
vlog -sv -work work +incdir+D:/mtrx3700/mic/mic/mic {D:/mtrx3700/mic/mic/mic/set_audio_encoder.sv}
vlog -sv -work work +incdir+D:/mtrx3700/mic/mic/mic {D:/mtrx3700/mic/mic/mic/i2c_master.sv}
vlog -sv -work work +incdir+D:/mtrx3700/mic/mic/mic {D:/mtrx3700/mic/mic/mic/mic_load.sv}
vlog -sv -work work +incdir+D:/mtrx3700/mic/mic {D:/mtrx3700/mic/mic/fft_pitch_detect.sv}
vlog -sv -work work +incdir+D:/mtrx3700/mic/mic {D:/mtrx3700/mic/mic/top_level.sv}
vlog -sv -work work +incdir+D:/mtrx3700/mic/mic {D:/mtrx3700/mic/mic/fft_input_buffer.sv}

vlog -sv -work work +incdir+D:/mtrx3700/mic/mic {D:/mtrx3700/mic/mic/fft_pitch_detect_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  fft_pitch_detect_tb

add wave *
view structure
view signals
run -all
