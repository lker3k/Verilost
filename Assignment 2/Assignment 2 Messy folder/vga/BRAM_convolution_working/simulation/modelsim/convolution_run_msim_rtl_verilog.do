transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/leban/MTRX3700/assignment_2_convolution {C:/Users/leban/MTRX3700/assignment_2_convolution/vga_face.sv}

vlog -sv -work work +incdir+C:/Users/leban/MTRX3700/assignment_2_convolution {C:/Users/leban/MTRX3700/assignment_2_convolution/vga_face_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  vga_face_tb

do C:/Users/leban/MTRX3700/assignment_2_convolution/simulation/modelsim/wave.do
