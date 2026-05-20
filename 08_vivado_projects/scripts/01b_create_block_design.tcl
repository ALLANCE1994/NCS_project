# ============================================================================
# NV色心实验系统 - M4 Block Design创建脚本 (修正版)
# ============================================================================
# 【负责智能体】@H 硬件工程师
# 【开发阶段】M4.0 PS系统集成
# 【知识来源】arch_base.md / 02_zynq_architecture_knowledge.md
# ============================================================================
# 【架构】
#   PS7 (M_AXI_GP0) -> AXI Interconnect -> top_odmr (AXI4-Lite Slave)
#   PS7 (FCLK_CLK0) -> top_odmr (PL时钟)
#   PS7 (FCLK_RESET0_N) -> proc_sys_reset -> top_odmr (PL同步复位)
# ============================================================================
# 【修正说明】
#   - AXI总线接口使用 connect_bd_intf_net 而非 connect_bd_net
#   - 时钟/复位信号使用 connect_bd_net
#   - 添加Processor System Reset生成同步复位
# ============================================================================

set project_name "odmr_zynq7020"
set bd_name "odmr_block_design"
set script_dir [file normalize [file dirname [info script]]]
set proj_dir  [file normalize [file join $script_dir ".."]]

# ---- 打开工程 ----
open_project [file join $proj_dir $project_name "${project_name}.xpr"]

# 注意: 工程已设置part=xc7z020clg400-2，board_part警告可忽略

# ---- 创建Block Design（如果已存在则删除重建） ----
if {[get_bd_designs -quiet $bd_name] != ""} {
    puts "INFO: Block Design $bd_name 已存在，删除后重建..."
    remove_bd_design [get_bd_designs $bd_name]
}
create_bd_design $bd_name

# ==== 1. 添加ZYNQ PS7 ====
set ps7 [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps7]

# 应用ZYNQ7020板级预设
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config { \
    apply_board_preset "1" \
} $ps7

# 配置PS7: 使能FCLK_CLK0 (50MHz), 使能M_AXI_GP0
# 注意: 参数名在apply_board_preset后可能不同，使用正确的参数名
set_property -dict [list \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_USE_M_AXI_GP0 {1} \
] $ps7

# ==== 2. 添加AXI Interconnect ====
set axi_interconnect [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0]
set_property -dict [list \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {1} \
] $axi_interconnect

# ==== 3. 添加Processor System Reset模块（生成同步复位） ====
set proc_sys_reset [create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0]

# ==== 4. 将top_odmr作为RTL模块添加到BD ====
# 注意: top_odmr必须已在Vivado工程中添加为设计源文件
set odmr_ip [create_bd_cell -type module -reference top_odmr inst_top_odmr]

# 配置AXI接口参数（确保被识别为AXI4-Lite从接口）
set_property -dict [list \
    CONFIG.C_S_AXI_ADDR_WIDTH {12} \
    CONFIG.C_S_AXI_DATA_WIDTH {32} \
] $odmr_ip

# 确保AXI接口被正确识别为总线接口（而非普通端口）
set_property CONFIG.ASSOCIATED_BUSIF {s_axi} [get_bd_pins inst_top_odmr/s_axi_aclk]

# ==== 5. 连接AXI总线接口 (使用 connect_bd_intf_net) ====
# PS7 M_AXI_GP0 -> Interconnect S00_AXI
connect_bd_intf_net [get_bd_intf_pins ps7/M_AXI_GP0] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
# Interconnect M00_AXI -> top_odmr AXI-Lite Slave
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins inst_top_odmr/s_axi]

# ==== 6. 连接时钟 (使用 connect_bd_net) ====
# PS7 FCLK_CLK0 -> PS7 AXI时钟（M_AXI_GP0_ACLK必须先连接）
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins ps7/M_AXI_GP0_ACLK]
# 注意: S_AXI_GP0_ACLK不存在，因为S_AXI_GP0未使能
# PS7 FCLK_CLK0 -> Processor System Reset
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
# PS7 FCLK_CLK0 -> top_odmr s_axi_aclk
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins inst_top_odmr/s_axi_aclk]
# PS7 FCLK_CLK0 -> Interconnect时钟
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins axi_interconnect_0/ACLK]
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins axi_interconnect_0/S00_ACLK]
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins axi_interconnect_0/M00_ACLK]

# ==== 7. 连接复位 (使用 connect_bd_net) ====
# PS7 FCLK_RESET0_N -> Processor System Reset（异步复位输入）
connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins proc_sys_reset_0/ext_reset_in]
# Processor System Reset -> 同步复位输出 -> top_odmr
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins inst_top_odmr/s_axi_aresetn]
# Processor System Reset -> 同步复位输出 -> Interconnect
# AXI Interconnect使用peripheral_aresetn（ARESETN是总复位，S00/M00是各端口复位）
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_interconnect_0/ARESETN]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_interconnect_0/S00_ARESETN]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN]

# ==== 8. 外部化PL端口 ====
make_bd_pins_external [get_bd_pins inst_top_odmr/led]
make_bd_pins_external [get_bd_pins inst_top_odmr/key]
make_bd_pins_external [get_bd_pins inst_top_odmr/dds_clk_out]
make_bd_pins_external [get_bd_pins inst_top_odmr/dds_data_out]
make_bd_pins_external [get_bd_pins inst_top_odmr/dds_valid]
make_bd_pins_external [get_bd_pins inst_top_odmr/adc_clk_in]
make_bd_pins_external [get_bd_pins inst_top_odmr/adc_data_in]
make_bd_pins_external [get_bd_pins inst_top_odmr/adc_valid]
make_bd_pins_external [get_bd_pins inst_top_odmr/adc_ovr]
make_bd_pins_external [get_bd_pins inst_top_odmr/scan_sync]
make_bd_pins_external [get_bd_pins inst_top_odmr/scan_trigger]

# ==== 9. 地址分配 ====
assign_bd_address [get_bd_addr_segs {ps7/Data }]
assign_bd_address [get_bd_addr_segs {inst_top_odmr/s_axi/Reg }]

# ==== 10. 保存并验证 ====
save_bd_design
validate_bd_design

puts "INFO: Block Design创建完成 - $bd_name"
puts "INFO: top_odmr已作为AXI4-Lite从设备连接到PS7"
puts "INFO: 地址分配: [get_bd_addr_segs inst_top_odmr/s_axi/Reg]"
