# ============================================================================
# NV色心实验系统 - 时序约束文件
# Timing Constraints for NV Center ODMR Experiment System
# ============================================================================
# 【负责智能体】@H 硬件工程师
# 【所属项目】NV色心实验系统（NCS_project）
# 【目标平台】正点原子领航者ZYNQ7020（XC7Z020CLG400-2）
# 【开发阶段】M3.0 顶层模块框架
# ============================================================================

# ============================================================================
# 1. 时钟定义
# ============================================================================

# 系统时钟（50MHz，来自板载晶振）
create_clock -period 20.000 -name sys_clk_50m [get_ports sys_clk_50m]

# AXI时钟（100MHz，来自PS端FCLK_CLK0）
create_clock -period 10.000 -name s_axi_aclk [get_ports s_axi_aclk]

# ADC采样时钟（由外部ADC提供，典型值10MHz）
create_clock -period 100.000 -name adc_clk_in [get_ports adc_clk_in]

# ============================================================================
# 2. 时钟分组（异步时钟域）
# ============================================================================

set_clock_groups -asynchronous \
    -group [get_clocks sys_clk_50m] \
    -group [get_clocks s_axi_aclk] \
    -group [get_clocks adc_clk_in]

# ============================================================================
# 3. 输入延迟约束
# ============================================================================

# 系统复位输入（异步信号）
set_false_path -from [get_ports sys_rst_n]

# 按键输入
set_input_delay -clock sys_clk_50m -max 5.000 [get_ports {key[*]}]
set_input_delay -clock sys_clk_50m -min 0.000 [get_ports {key[*]}]

# ADC数据输入
set_input_delay -clock adc_clk_in -max 8.000 [get_ports {adc_data_in[*]}]
set_input_delay -clock adc_clk_in -min 2.000 [get_ports {adc_data_in[*]}]

# ADC控制信号输入
set_input_delay -clock adc_clk_in -max 8.000 [get_ports adc_valid]
set_input_delay -clock adc_clk_in -min 2.000 [get_ports adc_valid]
set_input_delay -clock adc_clk_in -max 8.000 [get_ports adc_ovr]
set_input_delay -clock adc_clk_in -min 2.000 [get_ports adc_ovr]

# 扫描同步信号输入
set_input_delay -clock sys_clk_50m -max 5.000 [get_ports scan_sync]
set_input_delay -clock sys_clk_50m -min 0.000 [get_ports scan_sync]

# ============================================================================
# 4. 输出延迟约束
# ============================================================================

# LED输出
set_output_delay -clock sys_clk_50m -max 2.000 [get_ports {led[*]}]
set_output_delay -clock sys_clk_50m -min 0.000 [get_ports {led[*]}]

# DDS时钟输出
set_output_delay -clock sys_clk_50m -max 3.000 [get_ports dds_clk_out]
set_output_delay -clock sys_clk_50m -min 0.000 [get_ports dds_clk_out]

# DDS数据输出
set_output_delay -clock sys_clk_50m -max 3.000 [get_ports {dds_data_out[*]}]
set_output_delay -clock sys_clk_50m -min 0.000 [get_ports {dds_data_out[*]}]

# DDS数据有效指示
set_output_delay -clock sys_clk_50m -max 3.000 [get_ports dds_valid]
set_output_delay -clock sys_clk_50m -min 0.000 [get_ports dds_valid]

# 扫描触发信号输出
set_output_delay -clock sys_clk_50m -max 5.000 [get_ports scan_trigger]
set_output_delay -clock sys_clk_50m -min 0.000 [get_ports scan_trigger]

# ============================================================================
# 5. AXI接口时序约束
# ============================================================================

# AXI写地址通道
set_input_delay -clock s_axi_aclk -max 2.000 [get_ports {s_axi_awaddr[*]}]
set_input_delay -clock s_axi_aclk -min 0.000 [get_ports {s_axi_awaddr[*]}]
set_input_delay -clock s_axi_aclk -max 2.000 [get_ports s_axi_awvalid]
set_input_delay -clock s_axi_aclk -min 0.000 [get_ports s_axi_awvalid]
set_output_delay -clock s_axi_aclk -max 2.000 [get_ports s_axi_awready]
set_output_delay -clock s_axi_aclk -min 0.000 [get_ports s_axi_awready]

# AXI写数据通道
set_input_delay -clock s_axi_aclk -max 2.000 [get_ports {s_axi_wdata[*]}]
set_input_delay -clock s_axi_aclk -min 0.000 [get_ports {s_axi_wdata[*]}]
set_input_delay -clock s_axi_aclk -max 2.000 [get_ports s_axi_wvalid]
set_input_delay -clock s_axi_aclk -min 0.000 [get_ports s_axi_wvalid]
set_output_delay -clock s_axi_aclk -max 2.000 [get_ports s_axi_wready]
set_output_delay -clock s_axi_aclk -min 0.000 [get_ports s_axi_wready]

# AXI写响应通道
set_output_delay -clock s_axi_aclk -max 2.000 [get_ports {s_axi_bresp[*]}]
set_output_delay -clock s_axi_aclk -min 0.000 [get_ports {s_axi_bresp[*]}]
set_output_delay -clock s_axi_aclk -max 2.000 [get_ports s_axi_bvalid]
set_output_delay -clock s_axi_aclk -min 0.000 [get_ports s_axi_bvalid]
set_input_delay -clock s_axi_aclk -max 2.000 [get_ports s_axi_bready]
set_input_delay -clock s_axi_aclk -min 0.000 [get_ports s_axi_bready]

# AXI读地址通道
set_input_delay -clock s_axi_aclk -max 2.000 [get_ports {s_axi_araddr[*]}]
set_input_delay -clock s_axi_aclk -min 0.000 [get_ports {s_axi_araddr[*]}]
set_input_delay -clock s_axi_aclk -max 2.000 [get_ports s_axi_arvalid]
set_input_delay -clock s_axi_aclk -min 0.000 [get_ports s_axi_arvalid]
set_output_delay -clock s_axi_aclk -max 2.000 [get_ports s_axi_arready]
set_output_delay -clock s_axi_aclk -min 0.000 [get_ports s_axi_arready]

# AXI读数据通道
set_output_delay -clock s_axi_aclk -max 2.000 [get_ports {s_axi_rdata[*]}]
set_output_delay -clock s_axi_aclk -min 0.000 [get_ports {s_axi_rdata[*]}]
set_output_delay -clock s_axi_aclk -max 2.000 [get_ports s_axi_rvalid]
set_output_delay -clock s_axi_aclk -min 0.000 [get_ports s_axi_rvalid]
set_input_delay -clock s_axi_aclk -max 2.000 [get_ports s_axi_rready]
set_input_delay -clock s_axi_aclk -min 0.000 [get_ports s_axi_rready]

# ============================================================================
# 6. 虚假路径设置
# ============================================================================

# 复位信号不做时序检查
set_false_path -from [get_ports sys_rst_n]
set_false_path -from [get_ports s_axi_aresetn]

# LED闪烁逻辑不做严格时序要求
set_false_path -to [get_ports {led[*]}]
