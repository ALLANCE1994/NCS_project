# ============================================================================
# NV色心实验系统 - Block Design创建脚本（M4.0 PS集成版）
# ============================================================================
# 功能：在已创建的Vivado工程中，创建PS7+AXI Interconnect+top_odmr的Block Design
# 前置条件：必须先执行 create_project.tcl 创建工程并添加VHDL源文件
# 使用：在Vivado TCL Console中执行: source 01b_create_block_design.tcl
# ============================================================================
# 版本：v2.0 (M4)
# 日期：2026-05-20
# 负责人：@H 硬件工程师
# 知识来源：M2补充_PS-PL接口架构决策文档.md
# ============================================================================

set project_name "odmr_zynq7020"
set design_name  "odmr_block_design"
set proj_dir     "C:/Users/YXCOA/Desktop/lxb/NCS_project-main/08_vivado_projects/odmr_zynq7020"

# ============================================================================
# 0. 前置检查：确保工程已打开
# ============================================================================

if {[catch {current_project}]} {
    puts "ERROR: 没有打开的工程！请先执行:"
    puts "  source C:/Users/YXCOA/Desktop/lxb/NCS_project-main/08_vivado_projects/odmr_zynq7020/create_project.tcl"
    return -code 1
}

# ============================================================================
# 1. 检查并删除已存在的Block Design
# ============================================================================

if {[get_files -quiet ${design_name}.bd] ne ""} {
    puts "WARN: 删除已存在的Block Design: ${design_name}"
    remove_files [get_files ${design_name}.bd]
}

# ============================================================================
# 2. 创建Block Design
# ============================================================================

puts "INFO: 创建Block Design: ${design_name}"
create_bd_design ${design_name}

# ============================================================================
# 3. 添加ZYNQ7 Processing System
# ============================================================================

puts "INFO: 添加PS7..."
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps7
endgroup

# 应用ZYNQ7020预设配置（正点原子领航者板卡）
# 使用Vivado GUI中导出的配置，只保留必要参数
set_property -dict [list \
    CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
    CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
    CONFIG.PCW_USE_M_AXI_GP0 {1} \
    CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {0} \
    CONFIG.PCW_M_AXI_GP0_SUPPORT_NARROW_BURST {0} \
    CONFIG.PCW_M_AXI_GP0_THREAD_ID_WIDTH {12} \
    CONFIG.PCW_USE_S_AXI_GP0 {0} \
    CONFIG.PCW_USE_S_AXI_HP0 {0} \
    CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
    CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
    CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
    CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART1_UART1_IO {MIO 48 .. 49} \
    CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
    CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
    CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
    CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
    CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
    CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
] [get_bd_cells ps7]

# 单独配置FCLK0频率（通过属性设置）
set_property CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50} [get_bd_cells ps7]

puts "INFO: PS7配置完成"

# ============================================================================
# 4. 添加AXI Interconnect
# ============================================================================

puts "INFO: 添加AXI Interconnect..."
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0
endgroup

set_property -dict [list \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {1} \
] [get_bd_cells axi_interconnect_0]

puts "INFO: AXI Interconnect配置完成 (1主1从)"

# ============================================================================
# 5. 添加top_odmr RTL模块
# ============================================================================

puts "INFO: 添加top_odmr RTL模块..."
startgroup
create_bd_cell -type module -reference top_odmr top_odmr_0
endgroup

puts "INFO: top_odmr模块添加完成"

# ============================================================================
# 6. 连接AXI接口（使用connect_bd_intf_net）
# ============================================================================

puts "INFO: 连接AXI接口..."

# PS7 M_AXI_GP0 -> AXI Interconnect S00_AXI
connect_bd_intf_net [get_bd_intf_pins ps7/M_AXI_GP0] \
                    [get_bd_intf_pins axi_interconnect_0/S00_AXI]

# AXI Interconnect M00_AXI -> top_odmr S_AXI
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M00_AXI] \
                    [get_bd_intf_pins top_odmr_0/S_AXI]

puts "INFO: AXI接口连接完成"

# ============================================================================
# 7. 连接时钟（所有时钟来自PS7 FCLK_CLK0）
# ============================================================================

puts "INFO: 连接时钟..."

# PS7 FCLK_CLK0 -> AXI Interconnect各端口
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins axi_interconnect_0/ACLK]
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins axi_interconnect_0/S00_ACLK]
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins axi_interconnect_0/M00_ACLK]

# PS7 FCLK_CLK0 -> top_odmr s_axi_aclk
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins top_odmr_0/s_axi_aclk]

# PS7 FCLK_CLK0 -> PS7 M_AXI_GP0_ACLK（关键！）
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins ps7/M_AXI_GP0_ACLK]

puts "INFO: 时钟连接完成 (FCLK_CLK0 = 50MHz)"

# ============================================================================
# 8. 连接复位（所有复位来自PS7 FCLK_RESET0_N）
# ============================================================================

puts "INFO: 连接复位..."

connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins axi_interconnect_0/ARESETN]
connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins axi_interconnect_0/S00_ARESETN]
connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins axi_interconnect_0/M00_ARESETN]
connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins top_odmr_0/s_axi_aresetn]

puts "INFO: 复位连接完成"

# ============================================================================
# 9. 创建外部端口（PL端外设引脚）
# ============================================================================

puts "INFO: 创建外部端口..."

# LED [3:0]
make_bd_pins_external  [get_bd_pins top_odmr_0/led]
set_property NAME led [get_bd_ports led_0]

# KEY [3:0]
make_bd_pins_external  [get_bd_pins top_odmr_0/key]
set_property NAME key [get_bd_ports key_0]

# DDS接口
make_bd_pins_external  [get_bd_pins top_odmr_0/dds_clk_out]
set_property NAME dds_clk_out [get_bd_ports dds_clk_out_0]

make_bd_pins_external  [get_bd_pins top_odmr_0/dds_data_out]
set_property NAME dds_data_out [get_bd_ports dds_data_out_0]

make_bd_pins_external  [get_bd_pins top_odmr_0/dds_valid]
set_property NAME dds_valid [get_bd_ports dds_valid_0]

# ADC接口
make_bd_pins_external  [get_bd_pins top_odmr_0/adc_clk_in]
set_property NAME adc_clk_in [get_bd_ports adc_clk_in_0]

make_bd_pins_external  [get_bd_pins top_odmr_0/adc_data_in]
set_property NAME adc_data_in [get_bd_ports adc_data_in_0]

make_bd_pins_external  [get_bd_pins top_odmr_0/adc_valid]
set_property NAME adc_valid [get_bd_ports adc_valid_0]

make_bd_pins_external  [get_bd_pins top_odmr_0/adc_ovr]
set_property NAME adc_ovr [get_bd_ports adc_ovr_0]

# 扫描同步接口
make_bd_pins_external  [get_bd_pins top_odmr_0/scan_sync]
set_property NAME scan_sync [get_bd_ports scan_sync_0]

make_bd_pins_external  [get_bd_pins top_odmr_0/scan_trigger]
set_property NAME scan_trigger [get_bd_ports scan_trigger_0]

puts "INFO: 外部端口创建完成"

# ============================================================================
# 10. 配置AXI地址映射
# ============================================================================

puts "INFO: 配置AXI地址映射..."

# 为top_odmr分配地址空间：0x4000_0000 ~ 0x4000_0FFF (4KB)
# 先获取地址段，然后分配
set addr_seg [get_bd_addr_segs -of_objects [get_bd_cells top_odmr_0]]
assign_bd_address -offset 0x40000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces ps7/Data] $addr_seg

puts "INFO: AXI地址映射: 0x40000000 - 0x40000FFF (4KB)"

# ============================================================================
# 11. 验证并保存
# ============================================================================

puts "INFO: 验证Block Design..."
validate_bd_design

puts "INFO: 保存Block Design..."
save_bd_design

# ============================================================================
# 12. 生成HDL Wrapper并设为顶层
# ============================================================================

puts "INFO: 生成HDL Wrapper..."
set wrapper_file [make_wrapper -files [get_files ${design_name}.bd] -top]
add_files -norecurse $wrapper_file

# 设置Wrapper为顶层模块
set_property top ${design_name}_wrapper [current_fileset]
update_compile_order -fileset sources_1

puts ""
puts "========================================"
puts "  Block Design创建完成！"
puts "========================================"
puts "组件:"
puts "  - PS7 Processing System"
puts "  - AXI Interconnect (1主1从)"
puts "  - top_odmr (AXI-Lite从设备)"
puts "时钟: PS7 FCLK_CLK0 = 50MHz"
puts "复位: PS7 FCLK_RESET0_N"
puts "AXI地址: 0x40000000 - 0x40000FFF"
puts "顶层模块: ${design_name}_wrapper"
puts ""
puts "下一步: 运行综合"
puts "  source C:/Users/YXCOA/Desktop/lxb/NCS_project-main/08_vivado_projects/scripts/02_run_synth_m4.tcl"
puts "========================================"
