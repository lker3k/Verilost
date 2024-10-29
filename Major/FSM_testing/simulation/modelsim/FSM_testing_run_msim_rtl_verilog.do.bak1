transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+E:/University/Year\ 2/Semester\ 2/MTRX3700/major\ project/FSM_testing {E:/University/Year 2/Semester 2/MTRX3700/major project/FSM_testing/robot_fsm.sv}

vlog -sv -work work +incdir+E:/University/Year\ 2/Semester\ 2/MTRX3700/major\ project/FSM_testing {E:/University/Year 2/Semester 2/MTRX3700/major project/FSM_testing/robot_fsm_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  robot_fsm_tb

add wave *
view structure
view signals
run -all
