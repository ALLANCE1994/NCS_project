# ============================================================================
# NV色心实验系统 - Step 2: 综合（M4 PS集成版）
# ============================================================================
# 功能：运行Vivado综合，生成综合报告
# 前置条件：Block Design已创建，Wrapper已设为顶层
# 使用：source 02_run_synth_m4.tcl
# ============================================================================

set project_name "odmr_zynq7020"
set proj_dir "C:/Users/YXCOA/Desktop/lxb/NCS_project-main/08_vivado_projects/odmr_zynq7020"

# 打开工程（如果未打开）
if {[catch {current_project}]} {
    open_project [file join $proj_dir $project_name "${project_name}.xpr"]
}

puts "========================================"
puts "  M4.0 开始综合..."
puts "========================================"

# 运行综合
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# 检查结果
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: 综合失败！请检查Vivado日志。"
    return -code 1
}

set synth_status [get_property STATUS [get_runs synth_1]]
puts "INFO: 综合状态: $synth_status"

# 打开综合结果，生成报告
open_run synth_1

file mkdir [file join $proj_dir reports]
report_utilization -file [file join $proj_dir reports synth_utilization_m4.rpt]
report_timing_summary -file [file join $proj_dir reports synth_timing_m4.rpt]

puts "========================================"
puts "  M4.0 综合完成"
puts "========================================"
puts "报告:"
puts "  - reports/synth_utilization_m4.rpt"
puts "  - reports/synth_timing_m4.rpt"
puts ""
puts "下一步: source C:/Users/YXCOA/Desktop/lxb/NCS_project-main/08_vivado_projects/scripts/03_run_impl_m4.tcl"
puts "========================================"
