# ============================================================================
# NV色心实验系统 - 一键全流程脚本
# ============================================================================
# 使用方法：
#   vivado -mode batch -source run_all.tcl
# ============================================================================

set script_dir [file normalize [file dirname [info script]]]

source [file join $script_dir "01_create_project.tcl"]
source [file join $script_dir "02_run_synth.tcl"]
source [file join $script_dir "03_run_impl.tcl"]
source [file join $script_dir "04_run_bitstream.tcl"]

puts "\n===== 全流程完成 ====="
