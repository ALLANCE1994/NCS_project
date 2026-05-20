# ============================================================================
# NV色心实验系统 - Step 3+4: 实现 + Bitstream + HWH导出（M4版）
# ============================================================================
# 【负责智能体】@H 硬件工程师
# 【开发阶段】M4.0.1 PS系统集成
# ============================================================================

set project_name "odmr_zynq7020"
set script_dir [file normalize [file dirname [info script]]]
set proj_dir  [file normalize [file join $script_dir ".."]]

open_project [file join $proj_dir $project_name "${project_name}.xpr"]

# ---- 运行实现 ----
reset_run impl_1
launch_runs impl_1 -jobs 4
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: 实现失败"
    return -code 1
}

# ---- 打开实现结果 ----
open_run impl_1

# ---- 报告 ----
report_timing_summary -file [file join $proj_dir "reports" "impl_timing_m4.rpt"]
report_utilization -file [file join $proj_dir "reports" "impl_utilization_m4.rpt"]

# ---- 生成Bitstream ----
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: Bitstream生成失败"
    return -code 1
}

# ---- 导出.hwh文件（PYNQ Overlay必需） ----
set hwh_file [file join $proj_dir $project_name.runs "impl_1" "${project_name}.hwh"]
write_hw_def -file $hwh_file -force
puts "INFO: .hwh文件已导出: $hwh_file"

# ---- 导出.xsa文件（Vitis开发用） ----
set xsa_file [file join $proj_dir $project_name.runs "impl_1" "${project_name}.xsa"]
write_hw_platform -fixed -include_bit -force -file $xsa_file
puts "INFO: .xsa文件已导出: $xsa_file"

puts "INFO: M4 PS集成版 - Bitstream + HWH + XSA 生成完成"
