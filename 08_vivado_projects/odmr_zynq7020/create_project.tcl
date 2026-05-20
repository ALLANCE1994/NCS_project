# ============================================================================
# Vivado TCL脚本 - 创建NV ODMR实验系统工程（M4.0 PS集成版）
# ============================================================================
# 功能：创建Vivado工程，添加所有VHDL源文件和约束文件
# 使用：在Vivado TCL Console中执行: source create_project.tcl
# 注意：M4版不自动运行综合，综合由 master_build_m4.tcl 统一调度
# ============================================================================
# 版本：v2.0 (M4)
# 日期：2026-05-20
# 所属阶段：M4.0 PS系统集成
# 负责人：@H 硬件工程师
# 变更记录：
#   v1.1 (M3) - 初始版本，纯PL综合实现
#   v2.0 (M4) - 添加所有子模块VHDL，不设顶层（顶层由BD Wrapper担任）
#               不自动运行综合，由master脚本调度
# ============================================================================

# ============================================================================
# 1. 工程基础配置
# ============================================================================

set project_name "odmr_zynq7020"
set project_dir  "C:/Users/YXCOA/Desktop/lxb/NCS_project-main/08_vivado_projects/odmr_zynq7020"
set part_name    "xc7z020clg400-2"

# 源文件目录
set src_dir       "C:/Users/YXCOA/Desktop/lxb/NCS_project-main/03_code/01_vhdl_modules"
set constraint_dir "C:/Users/YXCOA/Desktop/lxb/NCS_project-main/08_vivado_projects/odmr_zynq7020/constraints"
set scripts_dir   "C:/Users/YXCOA/Desktop/lxb/NCS_project-main/08_vivado_projects/scripts"

# ============================================================================
# 2. 创建工程
# ============================================================================

# 如果已存在则删除重建（M4需要干净的工程）
if {[file exists $project_dir/$project_name.xpr]} {
    puts "INFO: 删除旧工程..."
    close_project -quiet
    file delete -force $project_dir/$project_name.cache
    file delete -force $project_dir/$project_name.gen
    file delete -force $project_dir/$project_name.hw
    file delete -force $project_dir/$project_name.ip_user_files
    file delete -force $project_dir/$project_name.runs
    file delete -force $project_dir/$project_name.srcs
    file delete -force $project_dir/$project_name.xpr
    file delete -force $project_dir/vivado.jou
    file delete -force $project_dir/vivado.log
}

puts "INFO: 创建新工程..."
create_project $project_name $project_dir -part $part_name -force

# ============================================================================
# 3. 设置目标语言为VHDL
# ============================================================================

set_property target_language VHDL [current_project]

# ============================================================================
# 4. 添加所有VHDL源文件（子模块 + 顶层）
# ============================================================================

puts "INFO: 添加VHDL源文件..."

# 子模块（按依赖顺序添加）
add_files -norecurse [list \
    $src_dir/dds_generator.vhd \
    $src_dir/adc_interface.vhd \
    $src_dir/cordic_lia.vhd \
    $src_dir/iir_lowpass.vhd \
    $src_dir/scan_controller.vhd \
]

# 顶层模块（M4版，含AXI-Lite接口）
add_files -norecurse $src_dir/top_odmr.vhd

# 更新编译顺序
update_compile_order -fileset sources_1

puts "INFO: VHDL源文件添加完成（6个模块）"

# ============================================================================
# 5. 添加约束文件
# ============================================================================

puts "INFO: 添加约束文件..."

add_files -fileset constrs_1 -norecurse [list \
    $constraint_dir/01_pins.xdc \
    $constraint_dir/02_timing.xdc \
    $constraint_dir/03_config.xdc \
]

puts "INFO: 约束文件添加完成（3个XDC）"

# ============================================================================
# 6. 创建reports目录
# ============================================================================

file mkdir $project_dir/reports

# ============================================================================
# 7. 完成提示
# ============================================================================

puts ""
puts "========================================"
puts "  M4.0 工程创建完成"
puts "========================================"
puts "工程路径: $project_dir/$project_name.xpr"
puts ""
puts "已添加VHDL模块:"
puts "  - dds_generator.vhd"
puts "  - adc_interface.vhd"
puts "  - cordic_lia.vhd"
puts "  - iir_lowpass.vhd"
puts "  - scan_controller.vhd"
puts "  - top_odmr.vhd (M4 AXI-Lite版)"
puts ""
puts "已添加约束文件:"
puts "  - 01_pins.xdc (M4版，已移除sys_clk/sys_rst)"
puts "  - 02_timing.xdc (M4版，已移除sys_clk定义)"
puts "  - 03_config.xdc"
puts ""
puts "下一步: 在Vivado TCL Console中执行:"
puts "  source $scripts_dir/01b_create_block_design.tcl"
puts "========================================"
