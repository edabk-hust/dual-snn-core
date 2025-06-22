# Library Sets with SKY130 Libraries
create_library_set -name wcl_slow_h_60 -timing { 
  NangateOpenCellLibrary_typical.lib
}
create_library_set -name wcl_slow_l_60 -timing { 
  NangateOpenCellLibrary_typical.lib
}

# Operating Conditions for New Libraries
create_opcond -name op_cond_wcl_slow_h_60 -process 1 -voltage 1 -temperature 100
create_opcond -name op_cond_wcl_slow_l_60 -process 1 -voltage 1 -temperature -40

# Timing Conditions for Updated Library Sets
create_timing_condition -name timing_cond_wcl_slow_h_60 -opcond op_cond_wcl_slow_h_60 -library_sets { wcl_slow_h_60 }
create_timing_condition -name timing_cond_wcl_slow_l_60 -opcond op_cond_wcl_slow_l_60 -library_sets { wcl_slow_l_60 }

# RC Corner Creation
create_rc_corner -name rc_corner -qrc_tech ./QRC/nangate45qrc.tch

# Delay Corners with RC Corner
create_delay_corner -name delay_corner_wcl_slow_h_60 -early_timing_condition timing_cond_wcl_slow_h_60 \
                    -late_timing_condition timing_cond_wcl_slow_h_60 -early_rc_corner rc_corner \
                    -late_rc_corner rc_corner

create_delay_corner -name delay_corner_wcl_slow_l_60 -early_timing_condition timing_cond_wcl_slow_l_60 \
                    -late_timing_condition timing_cond_wcl_slow_l_60 -early_rc_corner rc_corner \
                    -late_rc_corner rc_corner

# Constraint Modes for Each Library Set
create_constraint_mode -name functional_wcl_slow_h_60 -sdc_files { \
   ./constraints_MMMC/snn_nan_gate_slow_h_60.sdc
}

create_constraint_mode -name functional_wcl_slow_l_60 -sdc_files { \
   ./constraints_MMMC/snn_nan_gate_slow_l_60.sdc
}

# Analysis Views for Each Library Set
create_analysis_view -name view_wcl_slow_h_60 -constraint_mode functional_wcl_slow_h_60 -delay_corner delay_corner_wcl_slow_h_60
create_analysis_view -name view_wcl_slow_l_60 -constraint_mode functional_wcl_slow_l_60 -delay_corner delay_corner_wcl_slow_l_60

# Setup Views for Multicorner Multimode Analysis
set_analysis_view -setup { view_wcl_slow_h_60 view_wcl_slow_l_60 }  


# sky130_fd_sc_hd__ss_100C_1v60.lib
# sky130_sram_2kbyte_2rw_32x512_1_TT_1p8V_25C.lib
