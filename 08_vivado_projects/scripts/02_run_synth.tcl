# ============================================================================
# NV色心实验系统 - Step 2: 运行综合
# ============================================================================
# 使用方法：
#   vivado -mode batch -source 02_run_synth.tcl
# ============================================================================

set script_dir [file normalize [file dirname [info script]]]
set proj_dir  [file normalize [file join $script_dir ".."]]
set project_name "odmr_zynq7020"
set xpr_file  [file join $proj_dir $project_name "${project_name}.xpr"]

if {[catch {current_project}]} {
    open_project $xpr_file
}

set_property strategy Flow_PerfOptimized_high [get_runs synth_1]

reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: 综合失败"
    return -code 1
}

open_run synth_1

file mkdir [file join $proj_dir "reports"]
report_utilization -file [file join $proj_dir "reports/synth_utilization.rpt"]
report_timing_summary -file [file join $proj_dir "reports/synth_timing.rpt"]

puts "INFO: 综合完成"
