#!/bin/tclsh

# Nạp file setup chứa các biến cần thiết cho thiết kế
source ./synth/setup.tcl

# Đọc các file RTL
read_hdl -language sv $RTL_LIST

# Elaborate và khởi tạo thiết kế
elaborate $DESIGN
init_design

time_info init_design
check_timing_intent
check_design -unresolved

####################################################################################################
## Synthesizing the design
####################################################################################################
set_db auto_ungroup none
set_db syn_generic_effort high
syn_generic

write_snapshot -directory $OUTPUT_DIR -tag syn_generic 
report_summary -directory $REPORTS_PATH
puts "Runtime & Memory after 'syn_generic'"
time_info GENERIC

set_db syn_map_effort high
syn_map

write_snapshot -directory $OUTPUT_DIR -tag syn_map 
report_summary -directory $REPORTS_PATH
puts "Runtime & Memory after 'syn_map'"
time_info MAPPED

set_db syn_opt_effort high
syn_opt

## Ghi ra các báo cáo Innovus (ví dụ: các thông số về thời gian, bộ nhớ,...)
write_snapshot -innovus -directory $OUTPUT_DIR -tag syn_opt
report_summary -directory $REPORTS_PATH
puts "Runtime & Memory after syn_opt"
time_info OPT

# Ghi ra database và netlist với timestamp
write_db $DESIGN -to_file ${OUTPUT_DIR}/${DESIGN}_${current_time}.db
write_netlist > ${NETLIST_DIR}/${DESIGN}_syn_${current_time}.v

# Ghi file SDC theo chế độ đơn (không lặp qua timing views vì không có MMMC)
write_sdc -view view_wcl_slow_h_60 > ${OUTPUT_DIR}/${DESIGN}_${current_time}_view_wcl_slow_h_60.sdc
write_sdc -view view_wcl_slow_l_60 > ${OUTPUT_DIR}/${DESIGN}_${current_time}_view_wcl_slow_l_60.sdc

# Ghi ra Do file cho LEC (Logical Equivalence Checking)
write_do_lec -golden_design rtl -logfile lec.log -revised_design ${NETLIST_DIR}/${DESIGN}_syn_${current_time}.v -top $DESIGN > lec.tcl

puts "Final Runtime & Memory."
time_info FINAL
puts "============================"
puts "Synthesis Finished ........."
puts "============================"
gui_show
#exit
