# ============================================================================
# NV色心实验系统 - Step 4: 生成Bitstream
# ============================================================================
# 使用方法：
#   vivado -mode batch -source 04_run_bitstream.tcl
# ============================================================================

set script_dir [file normalize [file dirname [info script]]]
set proj_dir  [file normalize [file join $script_dir ".."]]
set project_name "odmr_zynq7020"
set xpr_file  [file join $proj_dir $project_name "${project_name}.xpr"]

if {[catch {current_project}]} {
    open_project $xpr_file
}

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: Bitstream生成失败"
    return -code 1
}

# ============================================================================
# 【新增】导出.hwh硬件设计文件（PYNQ Overlay必需）
# ============================================================================
set hwh_file [file join $proj_dir $project_name.runs "impl_1" "${project_name}.hwh"]
open_run impl_1
write_hw_def -file $hwh_file
puts "INFO: .hwh硬件设计文件已导出: $hwh_file"

puts "INFO: Bitstream生成完成"
