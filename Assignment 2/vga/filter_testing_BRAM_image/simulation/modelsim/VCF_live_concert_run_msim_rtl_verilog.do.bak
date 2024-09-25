transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlib vga
vmap vga vga
vlog -vlog01compat -work vga +incdir+C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis {C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/vga.v}
vlog -vlog01compat -work vga +incdir+C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules {C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules/altera_reset_controller.v}
vlog -vlog01compat -work vga +incdir+C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules {C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules/altera_reset_synchronizer.v}
vlog -vlog01compat -work vga +incdir+C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules {C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules/altera_up_avalon_video_vga_timing.v}
vlog -vlog01compat -work vga +incdir+C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules {C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules/vga_video_vga_controller_0.v}
vlog -vlog01compat -work vga +incdir+C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules {C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules/vga_video_pll_0.v}
vlog -vlog01compat -work vga +incdir+C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules {C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules/altera_up_avalon_reset_from_locked_signal.v}
vlog -vlog01compat -work vga +incdir+C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules {C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules/altera_up_altpll.v}
vlog -sv -work vga +incdir+C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules {C:/Users/leban/MTRX3700/assignment_2_vga_testing/vga/synthesis/submodules/vga_face.sv}
vlog -sv -work work +incdir+C:/Users/leban/MTRX3700/assignment_2_vga_testing {C:/Users/leban/MTRX3700/assignment_2_vga_testing/top_level.sv}

