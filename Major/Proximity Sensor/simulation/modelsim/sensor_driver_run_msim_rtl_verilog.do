transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/georg/Downloads/MTRX3700/Quartus_Extracted/Major\ Project {C:/Users/georg/Downloads/MTRX3700/Quartus_Extracted/Major Project/sensor_driver.sv}
vlog -sv -work work +incdir+C:/Users/georg/Downloads/MTRX3700/Quartus_Extracted/Major\ Project {C:/Users/georg/Downloads/MTRX3700/Quartus_Extracted/Major Project/top_level.sv}
vlog -sv -work work +incdir+C:/Users/georg/Downloads/MTRX3700/Quartus_Extracted/Major\ Project {C:/Users/georg/Downloads/MTRX3700/Quartus_Extracted/Major Project/debounce.sv}

vlog -sv -work work +incdir+C:/Users/georg/Downloads/MTRX3700/Quartus_Extracted/Major\ Project {C:/Users/georg/Downloads/MTRX3700/Quartus_Extracted/Major Project/tb_top_level.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_top_level

add wave *
view structure
view signals
run -all
