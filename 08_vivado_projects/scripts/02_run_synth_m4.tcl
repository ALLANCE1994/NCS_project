# ============================================================================
# NV色心实验系统 - Step 2: 综合（M4 PS集成版）
# ============================================================================
# 【负责智能体】@H 硬件工程师
# 【开发阶段】M4.0.1 PS系统集成
# ============================================================================

set project_name "odmr_zynq7020"
set script_dir [file normalize [file dirname [info script]]]
set proj_dir  [file normalize [file join $script_dir ".."]]

open_project [file join $proj_dir $project_name "${project_name}.xpr"]

# 更新约束文件路径（M4阶段XDC需更新，移除sys_clk_50m外部时钟约束）
# PS7提供FCLK_CLK0，不再需要外部50MHz时钟约束

# 运行综合
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: 综合失败"
    return -code 1
}

# 打开综合结果
open_run synth_1

# 报告资源利用率
report_utilization -file [file join $proj_dir "reports" "synth_utilization_m4.rpt"]
report_timing_summary -file [file join $proj_dir "reports" "synth_timing_m4.rpt"]

puts "INFO: 综合完成 - M4 PS集成版"
