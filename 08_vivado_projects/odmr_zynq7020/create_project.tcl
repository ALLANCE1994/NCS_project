# ============================================================================
# Vivado TCL脚本 - 创建NV ODMR实验系统工程
# ============================================================================
# 功能：自动化创建Vivado工程，添加源文件和约束，运行综合实现
# 使用：vivado -mode batch -source create_project.tcl
# ============================================================================
# 版本：v1.1
# 日期：2026-05-19
# 所属阶段：M3.0
# 负责人：@H 硬件工程师
# 修复记录：
#   Bug#001 - 将set_property移到工程创建后
#   Bug#002 - 删除不支持的set_property属性
#   Bug#003 - 使用绝对路径避免glob匹配失败
#   Bug#004 - 创建缺失的约束文件目录和文件
#   Bug#005 - 创建reports目录
#   Bug#006 - project_dir使用绝对路径
#   Bug#007 - 修正引脚分配，使用正确的HR Bank引脚
# ============================================================================

# ============================================================================
# 1. 工程基础配置
# ============================================================================

# 工程名称
set project_name "odmr_zynq7020"

# 工程路径（使用绝对路径）
set project_dir "C:/Users/YXCOA/Desktop/lxb/NCS_project-main/08_vivado_projects/odmr_zynq7020"

# 目标器件
set part_name "xc7z020clg400-2"

# ============================================================================
# 2. 创建工程
# ============================================================================

# 创建工程（如果已存在则打开）
if {[file exists $project_dir/$project_name.xpr]} {
    puts "INFO: Project exists, opening..."
    open_project $project_dir/$project_name.xpr
} else {
    puts "INFO: Creating new project..."
    create_project $project_name $project_dir -part $part_name -force
}

# ============================================================================
# 3. 设置设计源文件目录
# ============================================================================

# 使用绝对路径避免相对路径问题
set src_dir "C:/Users/YXCOA/Desktop/lxb/NCS_project-main/03_code/01_vhdl_modules"
set constraint_dir "C:/Users/YXCOA/Desktop/lxb/NCS_project-main/08_vivado_projects/odmr_zynq7020/constraints"

# ============================================================================
# 4. 添加源文件
# ============================================================================

puts "INFO: Adding source files..."

# 添加顶层模块
add_files -norecurse [glob $src_dir/top_odmr.vhd]

# 设置顶层模块
set_property top top_odmr [current_fileset]

# ============================================================================
# 5. 添加约束文件
# ============================================================================

puts "INFO: Adding constraint files..."

# 添加引脚约束
add_files -fileset constrs_1 -norecurse $constraint_dir/01_pins.xdc

# 添加时序约束
add_files -fileset constrs_1 -norecurse $constraint_dir/02_timing.xdc

# 添加配置约束
add_files -fileset constrs_1 -norecurse $constraint_dir/03_config.xdc

# ============================================================================
# 6. 运行综合
# ============================================================================

puts "INFO: Running synthesis..."

# 更新设计
update_compile_order -fileset sources_1

# 运行综合
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# 检查综合结果
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: Synthesis failed!"
    exit 1
}

set synth_status [get_property STATUS [get_runs synth_1]]
puts "INFO: Synthesis status: $synth_status"

# ============================================================================
# 7. 报告综合结果
# ============================================================================

puts "INFO: Generating synthesis report..."

# 打开综合后的设计
open_run synth_1

# 报告资源利用率
report_utilization -file $project_dir/reports/utilization_synth.rpt

# 报告时序
report_timing_summary -file $project_dir/reports/timing_synth.rpt

# ============================================================================
# 8. 运行实现
# ============================================================================

puts "INFO: Running implementation..."

# 运行实现
reset_run impl_1
launch_runs impl_1 -jobs 4
wait_on_run impl_1

# 检查实现结果
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: Implementation failed!"
    exit 1
}

set impl_status [get_property STATUS [get_runs impl_1]]
puts "INFO: Implementation status: $impl_status"

# ============================================================================
# 9. 报告实现结果
# ============================================================================

puts "INFO: Generating implementation report..."

# 打开实现后的设计
open_run impl_1

# 报告资源利用率
report_utilization -file $project_dir/reports/utilization_impl.rpt

# 报告时序
report_timing_summary -file $project_dir/reports/timing_impl.rpt

# 报告DRC
report_drc -file $project_dir/reports/drc.rpt

# 报告功耗
report_power -file $project_dir/reports/power.rpt

# ============================================================================
# 10. 生成比特流
# ============================================================================

puts "INFO: Generating bitstream..."

# 启动比特流生成
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

# 检查比特流生成结果
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: Bitstream generation failed!"
    exit 1
}

puts "INFO: Bitstream generated successfully!"

# ============================================================================
# 11. 输出总结
# ============================================================================

puts ""
puts "========================================"
puts "  M3.0 Vivado工程完成报告"
puts "========================================"
puts ""
puts "工程路径: $project_dir/$project_name.xpr"
puts "比特流文件: $project_dir/$project_name.runs/impl_1/top_odmr.bit"
puts ""
puts "报告文件:"
puts "  - reports/utilization_synth.rpt  (综合资源)"
puts "  - reports/timing_synth.rpt       (综合时序)"
puts "  - reports/utilization_impl.rpt   (实现资源)"
puts "  - reports/timing_impl.rpt        (实现时序)"
puts "  - reports/drc.rpt                (DRC检查)"
puts "  - reports/power.rpt              (功耗报告)"
puts ""
puts "========================================"

# 关闭工程（可选）
# close_project
