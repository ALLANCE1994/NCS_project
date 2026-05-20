# ============================================================================
# NV色心实验系统 - Step 1: 创建Vivado工程
# ============================================================================
# 【负责智能体】@H 硬件工程师
# 【开发阶段】M3.6 顶层集成
# ============================================================================
# 使用方法：
#   vivado -mode batch -source 01_create_project.tcl
# ============================================================================

# 工程参数
set project_name "odmr_zynq7020"
set script_dir [file normalize [file dirname [info script]]]
set proj_dir  [file normalize [file join $script_dir ".."]]
set src_dir   [file normalize [file join $script_dir "../../03_code/01_vhdl_modules"]]
set xdc_dir   [file normalize [file join $script_dir "../../03_code/02_constraints"]]
set part_name "xc7z020clg400-2"
set top_module "top_odmr"

# 关闭已有工程
catch {close_project}

# 删除旧工程
if {[file exists [file join $proj_dir $project_name]]} {
    file delete -force [file join $proj_dir $project_name]
}

# 创建新工程
create_project $project_name [file join $proj_dir $project_name] -part $part_name -force

# 工程属性
set_property target_language VHDL [current_project]
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property strategy Performance_Explore [get_runs impl_1]

# 添加VHDL源文件（6个模块）
add_files [file join $src_dir "top_odmr.vhd"]
add_files [file join $src_dir "dds_generator.vhd"]
add_files [file join $src_dir "adc_interface.vhd"]
add_files [file join $src_dir "cordic_lia.vhd"]
add_files [file join $src_dir "scan_controller.vhd"]
add_files [file join $src_dir "iir_lowpass.vhd"]
update_compile_order -fileset sources_1

# 添加约束文件（3个）
add_files -fileset constrs_1 [file join $xdc_dir "01_pins.xdc"]
add_files -fileset constrs_1 [file join $xdc_dir "02_timing.xdc"]
add_files -fileset constrs_1 [file join $xdc_dir "03_config.xdc"]

# 设置顶层模块
set_property top $top_module [current_fileset]

puts "INFO: 工程创建完成 - $project_name"
