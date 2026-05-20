# ============================================================================
# NV色心实验系统 - 引脚约束文件
# Pin Constraints for NV Center ODMR Experiment System
# ============================================================================
# 【负责智能体】@H 硬件工程师
# 【所属项目】NV色心实验系统（NCS_project）
# 【目标平台】正点原子领航者ZYNQ7020（XC7Z020CLG400-2）
# 【开发阶段】M3.6 顶层集成
# 【更新记录】2026-05-20：ADC引脚全部移至Bank 34，避开Bank 35 XADC域
# ============================================================================
# 【注意】M3阶段引脚分配为占位值，M4阶段需根据实际硬件原理图调整
# ============================================================================

# ============================================================================
# 1. 系统时钟（Bank 34）
# ============================================================================

set_property PACKAGE_PIN U18 [get_ports sys_clk_50m]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk_50m]

# ============================================================================
# 2. 系统复位（Bank 34）
# ============================================================================

set_property PACKAGE_PIN N15 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]

# ============================================================================
# 3. LED指示（Bank 34）
# ============================================================================

set_property PACKAGE_PIN M14 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

set_property PACKAGE_PIN M15 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

set_property PACKAGE_PIN K16 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

set_property PACKAGE_PIN J16 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

# ============================================================================
# 4. 按键输入（Bank 34）
# ============================================================================

set_property PACKAGE_PIN J15 [get_ports {key[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[0]}]

set_property PACKAGE_PIN N16 [get_ports {key[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[1]}]

set_property PACKAGE_PIN P16 [get_ports {key[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[2]}]

set_property PACKAGE_PIN P15 [get_ports {key[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[3]}]

# ============================================================================
# 5. DDS信号发生器接口（14位数据，Bank 34）
# ============================================================================

set_property PACKAGE_PIN T15 [get_ports dds_clk_out]
set_property IOSTANDARD LVCMOS33 [get_ports dds_clk_out]
set_property DRIVE 8 [get_ports dds_clk_out]
set_property SLEW FAST [get_ports dds_clk_out]

set_property PACKAGE_PIN P14 [get_ports {dds_data_out[0]}]
set_property PACKAGE_PIN R14 [get_ports {dds_data_out[1]}]
set_property PACKAGE_PIN T11 [get_ports {dds_data_out[2]}]
set_property PACKAGE_PIN T10 [get_ports {dds_data_out[3]}]
set_property PACKAGE_PIN T12 [get_ports {dds_data_out[4]}]
set_property PACKAGE_PIN U12 [get_ports {dds_data_out[5]}]
set_property PACKAGE_PIN V12 [get_ports {dds_data_out[6]}]
set_property PACKAGE_PIN W13 [get_ports {dds_data_out[7]}]
set_property PACKAGE_PIN V13 [get_ports {dds_data_out[8]}]
set_property PACKAGE_PIN T14 [get_ports {dds_data_out[9]}]
set_property PACKAGE_PIN U14 [get_ports {dds_data_out[10]}]
set_property PACKAGE_PIN U15 [get_ports {dds_data_out[11]}]
set_property PACKAGE_PIN V15 [get_ports {dds_data_out[12]}]
set_property PACKAGE_PIN W15 [get_ports {dds_data_out[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_data_out[*]}]
set_property DRIVE 8 [get_ports {dds_data_out[*]}]
set_property SLEW FAST [get_ports {dds_data_out[*]}]

set_property PACKAGE_PIN Y17 [get_ports dds_valid]
set_property IOSTANDARD LVCMOS33 [get_ports dds_valid]
set_property DRIVE 8 [get_ports dds_valid]

# ============================================================================
# 6. ADC采集接口（14位数据，Bank 34）
# ============================================================================

set_property PACKAGE_PIN Y16 [get_ports adc_clk_in]
set_property IOSTANDARD LVCMOS33 [get_ports adc_clk_in]

set_property PACKAGE_PIN W14 [get_ports {adc_data_in[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[0]}]
set_property PACKAGE_PIN Y14 [get_ports {adc_data_in[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[1]}]
set_property PACKAGE_PIN V20 [get_ports {adc_data_in[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[2]}]
set_property PACKAGE_PIN W20 [get_ports {adc_data_in[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[3]}]
set_property PACKAGE_PIN Y18 [get_ports {adc_data_in[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[4]}]
set_property PACKAGE_PIN Y19 [get_ports {adc_data_in[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[5]}]
set_property PACKAGE_PIN V16 [get_ports {adc_data_in[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[6]}]
set_property PACKAGE_PIN W16 [get_ports {adc_data_in[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[7]}]
set_property PACKAGE_PIN R16 [get_ports {adc_data_in[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[8]}]
set_property PACKAGE_PIN T17 [get_ports {adc_data_in[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[9]}]
set_property PACKAGE_PIN R18 [get_ports {adc_data_in[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[10]}]
set_property PACKAGE_PIN W18 [get_ports {adc_data_in[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[11]}]
set_property PACKAGE_PIN W19 [get_ports {adc_data_in[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[12]}]
set_property PACKAGE_PIN N17 [get_ports {adc_data_in[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_data_in[13]}]

set_property PACKAGE_PIN P18 [get_ports adc_valid]
set_property IOSTANDARD LVCMOS33 [get_ports adc_valid]

set_property PACKAGE_PIN N18 [get_ports adc_ovr]
set_property IOSTANDARD LVCMOS33 [get_ports adc_ovr]

# ============================================================================
# 7. 扫描同步接口（Bank 34）
# ============================================================================

set_property PACKAGE_PIN U13 [get_ports scan_sync]
set_property IOSTANDARD LVCMOS33 [get_ports scan_sync]

set_property PACKAGE_PIN U19 [get_ports scan_trigger]
set_property IOSTANDARD LVCMOS33 [get_ports scan_trigger]
set_property DRIVE 8 [get_ports scan_trigger]
set_property SLEW FAST [get_ports scan_trigger]
