# ============================================================================
# NV色心实验系统 - Step 3: 运行实现
# ============================================================================
# 使用方法：
#   vivado -mode batch -source 03_run_impl.tcl
# ============================================================================

set script_dir [file normalize [file dirname [info script]]]
set proj_dir  [file normalize [file join $script_dir ".."]]
set project_name "odmr_zynq7020"
set xpr_file  [file join $proj_dir $project_name "${project_name}.xpr"]

if {[catch {current_project}]} {
    open_project $xpr_file
}

set_property strategy Performance_Explore [get_runs impl_1]

launch_runs impl_1 -jobs 4
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: 实现失败"
    return -code 1
}

open_run impl_1

report_utilization -file [file join $proj_dir "reports/impl_utilization.rpt"]
report_timing_summary -file [file join $proj_dir "reports/impl_timing.rpt"]
report_power -file [file join $proj_dir "reports/impl_power.rpt"]

set wns [get_property STATS.WNS [get_runs impl_1]]
set tns [get_property STATS.TNS [get_runs impl_1]]

puts "\n===== 时序收敛检查 ====="
puts "  WNS: $wns ns"
puts "  TNS: $tns ns"
if {$wns >= 0 && $tns == 0} {
    puts "  结果: PASS"
} else {
    puts "  结果: FAIL"
}

puts "INFO: 实现完成"
