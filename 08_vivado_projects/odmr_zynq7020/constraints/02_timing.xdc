# ============================================================================
# NV色心实验系统 - 时序约束文件
# Timing Constraints for NV Center ODMR Experiment System
# ============================================================================
# 【负责智能体】@H 硬件工程师
# 【所属项目】NV色心实验系统（NCS_project）
# 【目标平台】正点原子领航者ZYNQ7020（XC7Z020CLG400-2）
# 【开发阶段】M4.0 PS系统集成
# ============================================================================
# 【M4变更说明】
#   - 移除 sys_clk_50m 时钟定义（M4时钟由PS7 FCLK_CLK0提供，不需要XDC定义）
#   - s_axi_aclk 频率修正为50MHz（PS7 FCLK_CLK0配置值）
#   - PL端外设延迟约束参考时钟改为 s_axi_aclk
#   - 移除AXI接口I/O延迟约束（AXI在Block Design内部，不暴露为顶层端口）
#   - 移除 sys_rst_n 虚假路径（端口已不存在）
# ============================================================================

# ============================================================================
# 1. 时钟定义
# ============================================================================

# ADC采样时钟（由外部ADC提供，典型值10MHz）
# 注意：这是唯一需要在XDC中定义的外部时钟
# s_axi_aclk由PS7 FCLK_CLK0内部提供，不需要create_clock
create_clock -period 100.000 -name adc_clk_in [get_ports adc_clk_in]

# ============================================================================
# 2. 时钟分组（异步时钟域）
# ============================================================================

# s_axi_aclk (PS7 FCLK_CLK0 50MHz) 与 adc_clk_in (10MHz) 为异步关系
# 注意：s_axi_aclk由PS7 IP核内部管理，Vivado会自动识别
# 这里只需声明adc_clk_in与其他时钟异步
set_clock_groups -asynchronous \
    -group [get_clocks adc_clk_in]

# ============================================================================
# 3. 输入延迟约束
# ============================================================================

# 按键输入（相对s_axi_aclk域，即PS7 FCLK_CLK0 50MHz）
set_input_delay -clock [get_clocks -include_generated_clocks] -max 5.000 [get_ports {key[*]}]
set_input_delay -clock [get_clocks -include_generated_clocks] -min 0.000 [get_ports {key[*]}]

# ADC数据输入（相对adc_clk_in）
set_input_delay -clock adc_clk_in -max 8.000 [get_ports {adc_data_in[*]}]
set_input_delay -clock adc_clk_in -min 2.000 [get_ports {adc_data_in[*]}]

# ADC控制信号输入（相对adc_clk_in）
set_input_delay -clock adc_clk_in -max 8.000 [get_ports adc_valid]
set_input_delay -clock adc_clk_in -min 2.000 [get_ports adc_valid]
set_input_delay -clock adc_clk_in -max 8.000 [get_ports adc_ovr]
set_input_delay -clock adc_clk_in -min 2.000 [get_ports adc_ovr]

# 扫描同步信号输入（相对s_axi_aclk域）
set_input_delay -clock [get_clocks -include_generated_clocks] -max 5.000 [get_ports scan_sync]
set_input_delay -clock [get_clocks -include_generated_clocks] -min 0.000 [get_ports scan_sync]

# ============================================================================
# 4. 输出延迟约束
# ============================================================================

# LED输出（相对s_axi_aclk域）
set_output_delay -clock [get_clocks -include_generated_clocks] -max 2.000 [get_ports {led[*]}]
set_output_delay -clock [get_clocks -include_generated_clocks] -min 0.000 [get_ports {led[*]}]

# DDS时钟输出（相对s_axi_aclk域）
set_output_delay -clock [get_clocks -include_generated_clocks] -max 3.000 [get_ports dds_clk_out]
set_output_delay -clock [get_clocks -include_generated_clocks] -min 0.000 [get_ports dds_clk_out]

# DDS数据输出（相对s_axi_aclk域）
set_output_delay -clock [get_clocks -include_generated_clocks] -max 3.000 [get_ports {dds_data_out[*]}]
set_output_delay -clock [get_clocks -include_generated_clocks] -min 0.000 [get_ports {dds_data_out[*]}]

# DDS数据有效指示（相对s_axi_aclk域）
set_output_delay -clock [get_clocks -include_generated_clocks] -max 3.000 [get_ports dds_valid]
set_output_delay -clock [get_clocks -include_generated_clocks] -min 0.000 [get_ports dds_valid]

# 扫描触发信号输出（相对s_axi_aclk域）
set_output_delay -clock [get_clocks -include_generated_clocks] -max 5.000 [get_ports scan_trigger]
set_output_delay -clock [get_clocks -include_generated_clocks] -min 0.000 [get_ports scan_trigger]

# ============================================================================
# 5. 虚假路径设置
# ============================================================================

# s_axi_aresetn由PS7内部提供，不做时序检查
set_false_path -from [get_ports s_axi_aresetn]

# LED闪烁逻辑不做严格时序要求
set_false_path -to [get_ports {led[*]}]
