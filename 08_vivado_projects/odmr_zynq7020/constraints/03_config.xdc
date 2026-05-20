# ============================================================================
# NV色心实验系统 - 配置约束文件
# Configuration Constraints for NV Center ODMR Experiment System
# ============================================================================
# 【负责智能体】@H 硬件工程师
# 【所属项目】NV色心实验系统（NCS_project）
# 【目标平台】正点原子领航者ZYNQ7020（XC7Z020CLG400-2）
# 【开发阶段】M3.0 顶层模块框架
# ============================================================================

# ============================================================================
# 1. 比特流配置
# ============================================================================

# 启用比特流压缩
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# 配置速率（MHz）
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

# SPI总线宽度（4-bit模式）
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

# 未使用引脚处理（不连接）
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]

# ============================================================================
# 2. 电源配置
# ============================================================================

# 配置电压
set_property CONFIG_VOLTAGE 3.3 [current_design]

# 配置Bank电压选择
set_property CFGBVS VCCO [current_design]

# ============================================================================
# 3. 调试配置
# ============================================================================

# 禁用JTAG端口（生产环境可启用）
# set_property BITSTREAM.CONFIG.JTAG_XADC DISABLE [current_design]

# 启用内部配置监控
set_property BITSTREAM.CONFIG.OVERTEMPPOWERDOWN ENABLE [current_design]
