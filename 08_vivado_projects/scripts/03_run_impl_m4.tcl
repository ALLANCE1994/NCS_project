# ============================================================================
# NV色心实验系统 - Step 3+4: 实现 + Bitstream + HWH导出（M4版）
# ============================================================================
# 功能：运行实现、生成比特流、导出.hwh和.xsa文件
# 前置条件：综合已成功完成
# 使用：source 03_run_impl_m4.tcl
# ============================================================================

set project_name "odmr_zynq7020"
set proj_dir "C:/Users/YXCOA/Desktop/lxb/NCS_project-main/08_vivado_projects/odmr_zynq7020"

# 打开工程（如果未打开）
if {[catch {current_project}]} {
    open_project [file join $proj_dir $project_name "${project_name}.xpr"]
}

puts "========================================"
puts "  M4.0 开始实现..."
puts "========================================"

# ---- 运行实现 ----
reset_run impl_1
launch_runs impl_1 -jobs 4
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: 实现失败！请检查Vivado日志。"
    return -code 1
}

puts "INFO: 实现完成"

# ---- 打开实现结果，生成报告 ----
open_run impl_1

file mkdir [file join $proj_dir reports]
report_timing_summary -file [file join $proj_dir reports impl_timing_m4.rpt]
report_utilization -file [file join $proj_dir reports impl_utilization_m4.rpt]
report_drc -file [file join $proj_dir reports impl_drc_m4.rpt]
report_power -file [file join $proj_dir reports impl_power_m4.rpt]

# ---- 生成Bitstream ----
puts "INFO: 开始生成Bitstream..."
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: Bitstream生成失败！"
    return -code 1
}

puts "INFO: Bitstream生成完成"

# ---- 导出.hwh文件（PYNQ Overlay必需） ----
set hwh_file [file join $proj_dir $project_name.runs impl_1 "${project_name}.hwh"]
write_hw_platform -file $hwh_file -force
puts "INFO: .hwh文件已导出: $hwh_file"

# ---- 导出.xsa文件（Vitis开发用） ----
set xsa_file [file join $proj_dir $project_name.runs impl_1 "${project_name}.xsa"]
write_hw_platform -fixed -include_bit -force -file $xsa_file
puts "INFO: .xsa文件已导出: $xsa_file"

# ---- 输出总结 ----
puts ""
puts "========================================"
puts "  M4.0 PS集成版 - 全部完成！"
puts "========================================"
puts ""
puts "输出文件:"
puts "  Bitstream: $proj_dir/$project_name.runs/impl_1/${project_name}_wrapper.bit"
puts "  HWH:       $hwh_file"
puts "  XSA:       $xsa_file"
puts ""
puts "报告文件:"
puts "  - reports/impl_timing_m4.rpt"
puts "  - reports/impl_utilization_m4.rpt"
puts "  - reports/impl_drc_m4.rpt"
puts "  - reports/impl_power_m4.rpt"
puts ""
puts "PYNQ使用方法:"
puts "  1. 将 .bit 和 .hwh 文件复制到PYNQ板卡"
puts "  2. Python: from pynq import Overlay"
puts "  3. ol = Overlay('odmr_zynq7020.bit')"
puts "========================================"
