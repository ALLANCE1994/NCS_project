# ============================================================================
# NV色心实验系统 - Step 1.5c: 生成BD Wrapper + 修改PL顶层
# ============================================================================
# 【负责智能体】@H 硬件工程师
# 【开发阶段】M4.0.1 PS系统集成
# 【前置条件】01c_add_axi_gpio.tcl 已执行
# ============================================================================
# 【设计说明】
#   PS7 FCLK_CLK0 → PL端50MHz主时钟（替代外部sys_clk_50m）
#   AXI GPIO CH1输出 → PL端控制寄存器（频率/扫描参数）
#   AXI GPIO CH2输入 → PL端状态寄存器（扫描状态/数据）
# ============================================================================

set bd_name "odmr_block_design"
current_bd_design $bd_name

# ---- 分配地址 ----
assign_bd_address [get_bd_addr_segs {ps7/Data }]
assign_bd_address [get_bd_addr_segs {axi_gpio_ctrl/S_AXI/Reg }]

# ---- 保存Block Design ----
save_bd_design

# ---- 生成Wrapper（VHDL） ----
set wrapper [make_wrapper -files [get_files ${bd_name}.bd] -top -import]
set_property FILE_TYPE {VHDL 2008} $wrapper

# ---- 设置Wrapper为顶层 ----
set_property top odmr_block_design_wrapper [current_fileset]

puts "INFO: BD Wrapper已生成 - 顶层模块: odmr_block_design_wrapper"
puts "INFO: AXI GPIO地址映射:"
puts "  [get_bd_addr_segs axi_gpio_ctrl/S_AXI/Reg]"
