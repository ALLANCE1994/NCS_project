# ============================================================================
# NV色心实验系统 - 引脚约束文件
# Pin Constraints for NV Center ODMR Experiment System
# ============================================================================
# 【负责智能体】@H 硬件工程师
# 【所属项目】NV色心实验系统（NCS_project）
# 【目标平台】正点原子领航者ZYNQ7020（XC7Z020CLG400-2）
# 【开发阶段】M3.0 顶层模块框架
# 【修复记录】Bug#007 - 修正引脚分配，使用正确的HR Bank引脚
# ============================================================================

# ============================================================================
# 1. 系统时钟与复位 - Bank 34
# ============================================================================

# 50MHz系统时钟（来自板载晶振）- Bank 34 MRCC
set_property PACKAGE_PIN U18 [get_ports sys_clk_50m]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk_50m]

# 系统复位（低电平有效）- Bank 35
set_property PACKAGE_PIN J15 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]

# ============================================================================
# 2. PL端外设接口 - Bank 35
# ============================================================================

# LED指示（2个LED）
set_property PACKAGE_PIN M14 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

set_property PACKAGE_PIN M15 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

# 按键输入（2个按键）
set_property PACKAGE_PIN K18 [get_ports {key[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[0]}]

set_property PACKAGE_PIN P16 [get_ports {key[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[1]}]

# ============================================================================
# 3. DDS信号发生器接口（M3.1子模块）- Bank 34
# ============================================================================

# DDS时钟输出
set_property PACKAGE_PIN T16 [get_ports dds_clk_out]
set_property IOSTANDARD LVCMOS33 [get_ports dds_clk_out]
set_property DRIVE 12 [get_ports dds_clk_out]
set_property SLEW FAST [get_ports dds_clk_out]

# DDS数据输出（14位）- 使用Bank 34的HR引脚
set_property PACKAGE_PIN R17 [get_ports {dds_data_out[0]}]
set_property PACKAGE_PIN T17 [get_ports {dds_data_out[1]}]
set_property PACKAGE_PIN R18 [get_ports {dds_data_out[2]}]
set_property PACKAGE_PIN V17 [get_ports {dds_data_out[3]}]
set_property PACKAGE_PIN V18 [get_ports {dds_data_out[4]}]
set_property PACKAGE_PIN W18 [get_ports {dds_data_out[5]}]
set_property PACKAGE_PIN W19 [get_ports {dds_data_out[6]}]
set_property PACKAGE_PIN N17 [get_ports {dds_data_out[7]}]
set_property PACKAGE_PIN P18 [get_ports {dds_data_out[8]}]
set_property PACKAGE_PIN P15 [get_ports {dds_data_out[9]}]
set_property PACKAGE_PIN T19 [get_ports {dds_data_out[10]}]
set_property PACKAGE_PIN R16 [get_ports {dds_data_out[11]}]
set_property PACKAGE_PIN Y18 [get_ports {dds_data_out[12]}]
set_property PACKAGE_PIN Y19 [get_ports {dds_data_out[13]}]

set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_out[*]}]
set_property DRIVE 12 [get_ports {dds_data_out[*]}]
set_property SLEW FAST [get_ports {dds_data_out[*]}]

# DDS数据有效指示
set_property PACKAGE_PIN V16 [get_ports dds_valid]
set_property IOSTANDARD LVCMOS33 [get_ports dds_valid]

# ============================================================================
# 4. ADC采集接口（M3.2子模块）- Bank 34
# ============================================================================

# ADC采样时钟输入 - Bank 34 MRCC
set_property PACKAGE_PIN U19 [get_ports adc_clk_in]
set_property IOSTANDARD LVCMOS33 [get_ports adc_clk_in]

# ADC数据输入（16位）- Bank 34 HR引脚
set_property PACKAGE_PIN W14 [get_ports {adc_data_in[0]}]
set_property PACKAGE_PIN Y14 [get_ports {adc_data_in[1]}]
set_property PACKAGE_PIN Y16 [get_ports {adc_data_in[2]}]
set_property PACKAGE_PIN Y17 [get_ports {adc_data_in[3]}]
set_property PACKAGE_PIN V15 [get_ports {adc_data_in[4]}]
set_property PACKAGE_PIN W15 [get_ports {adc_data_in[5]}]
set_property PACKAGE_PIN U14 [get_ports {adc_data_in[6]}]
set_property PACKAGE_PIN U15 [get_ports {adc_data_in[7]}]
set_property PACKAGE_PIN T14 [get_ports {adc_data_in[8]}]
set_property PACKAGE_PIN T15 [get_ports {adc_data_in[9]}]
set_property PACKAGE_PIN P14 [get_ports {adc_data_in[10]}]
set_property PACKAGE_PIN R14 [get_ports {adc_data_in[11]}]
set_property PACKAGE_PIN T11 [get_ports {adc_data_in[12]}]
set_property PACKAGE_PIN T10 [get_ports {adc_data_in[13]}]
set_property PACKAGE_PIN T12 [get_ports {adc_data_in[14]}]
set_property PACKAGE_PIN U12 [get_ports {adc_data_in[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[*]}]

# ADC数据有效指示
set_property PACKAGE_PIN V13 [get_ports adc_valid]
set_property IOSTANDARD LVCMOS33 [get_ports adc_valid]

# ADC溢出指示
set_property PACKAGE_PIN V12 [get_ports adc_ovr]
set_property IOSTANDARD LVCMOS33 [get_ports adc_ovr]

# ============================================================================
# 5. 扫描控制接口（M3.4子模块）- Bank 34
# ============================================================================

# 扫描触发信号输出
set_property PACKAGE_PIN W13 [get_ports scan_trigger]
set_property IOSTANDARD LVCMOS33 [get_ports scan_trigger]

# 扫描同步信号输入
set_property PACKAGE_PIN U13 [get_ports scan_sync]
set_property IOSTANDARD LVCMOS33 [get_ports scan_sync]

# ============================================================================
# 6. 配置约束
# ============================================================================

# 配置电压
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

# 配置模式（使用JTAG + SPI Flash）
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

# 将未使用引脚设置为三态，避免浮空
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]
