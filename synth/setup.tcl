#!/usr/bin/env tclsh

# *********************************************************
# * Script Name  : Genus initialization script
# *********************************************************
date

if {[file exists /proc/cpuinfo]} {
  sh grep "model name" /proc/cpuinfo
  sh grep "cpu MHz"    /proc/cpuinfo
}

puts "Hostname : [info hostname]"

set LOCAL_DIR "[exec pwd]"
#set ALL_DIR ${LOCAL_DIR}/../..

set SYNTH_DIR ${LOCAL_DIR}/work
set TCL_PATH		"${LOCAL_DIR}/synth $LOCAL_DIR/constraints_MMMC"
set REPORTS_PATH        "${LOCAL_DIR}/work/reports" 

#set LIB_PATH		"${LOCAL_DIR}/libraries/LEF ${LOCAL_DIR}/libraries/LIB "
set LIB_PATH		"${LOCAL_DIR}/libs/nangate45/lef ${LOCAL_DIR}/libs/nangate45/lib "

set RTL_PATH		"$LOCAL_DIR/src"
set DESIGN 		"neuron_network"
set OUTPUT_DIR "./work/outputs"
set NETLIST_DIR "${OUTPUT_DIR}/netlists"
set SDC_DIR "./constraints_MMMC"

set SYN_EFF medium  
set MAP_EFF medium 
set OPT_EFF medium 

set_db max_cpus_per_server 24 

set MSGS_TO_BE_SUPRESSED {LBR-58 LBR-40 LBR-41 VLOGPT-35}

set_db hdl_track_filename_row_col true
set_db lp_power_unit mW
set_db init_lib_search_path $LIB_PATH
set_db script_search_path $TCL_PATH
set_db init_hdl_search_path $RTL_PATH
set_db error_on_lib_lef_pin_inconsistency true

set current_time [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]

set_db information_level 9 

set_db tns_opto true 
set_db lp_insert_clock_gating true

puts "Now load RTL LIST"


set LEF_LIST { \
	NangateOpenCellLibrary.tech.lef \
	NangateOpenCellLibrary.macro.lef \
	NangateOpenCellLibrary.macro.rect.lef \
	NangateOpenCellLibrary.macro.mod.lef
}

# Baseline RTL
set RTL_LIST { \
reconfigurable_adder.v \
decoder.v \
imem.v \
omem.v \
parameter.v \
neuron_block.v \
neuron_core.v \
neuron_network.v 
}

## Reading in MMMC defination file and lef files
read_mmmc ./synth/mmmc.tcl

read_physical -lefs { \
	NangateOpenCellLibrary.tech.lef \
	NangateOpenCellLibrary.macro.lef \
	NangateOpenCellLibrary.macro.rect.lef \
	NangateOpenCellLibrary.macro.mod.lef
}

suppress_messages {LBR-30 LBR-31 LBR-40 LBR-41 LBR-72 LBR-77 LBR-162}
