transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/AllenDomar/Documents/Quartus_II_Projects/SDRAMController {C:/Users/AllenDomar/Documents/Quartus_II_Projects/SDRAMController/sm_altpll.v}
vlog -vlog01compat -work work +incdir+C:/Users/AllenDomar/Documents/Quartus_II_Projects/SDRAMController/db {C:/Users/AllenDomar/Documents/Quartus_II_Projects/SDRAMController/db/sm_altpll_altpll.v}
vlog -vlog01compat -work work +incdir+C:/Users/AllenDomar/Documents/Quartus_II_Projects/SDRAMController {C:/Users/AllenDomar/Documents/Quartus_II_Projects/SDRAMController/SDRAMController.v}
vlog -vlog01compat -work work +incdir+C:/Users/AllenDomar/Documents/Quartus_II_Projects/SDRAMController {C:/Users/AllenDomar/Documents/Quartus_II_Projects/SDRAMController/sm_sdram_controller.v}

vlog -vlog01compat -work work +incdir+C:/Users/AllenDomar/Documents/Quartus_II_Projects/SDRAMController {C:/Users/AllenDomar/Documents/Quartus_II_Projects/SDRAMController/testbench.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
