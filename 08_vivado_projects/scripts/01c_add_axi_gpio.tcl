# ============================================================================
# NV色心实验系统 - Step 1.5b: 添加AXI GPIO + PL连接
# ============================================================================
# 【负责智能体】@H 硬件工程师
# 【开发阶段】M4.0.1 PS系统集成
# 【前置条件】01b_create_block_design.tcl 已执行
# ============================================================================

set bd_name "odmr_block_design"
current_bd_design $bd_name

# ---- 添加AXI GPIO（用于PS控制PL端寄存器） ----
# GPIO0: 32位输出（频率控制、扫描参数等）
set axi_gpio_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_ctrl]
set_property -dict [list \
    CONFIG.C_GPIO_WIDTH {32} \
    CONFIG.C_GPIO_WIDTH_2 {32} \
    CONFIG.C_IS_DUAL {1} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_ALL_INPUTS_2 {1} \
] $axi_gpio_0

# ---- 添加AXI Interconnect（PS GP0 → GPIO） ----
set axi_interconnect [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0]

# ---- 添加SmartConnect（简化连接） ----
# 使用PS7自动连接功能
apply_bd_automation -rule xilinx.com:bd_rule:axi_interconnect \
    -config { \
        "Number of Master Interfaces" "1" \
        "Number of Slave Interfaces" "1" \
        "Master Interface" "M_AXI_GP0" \
        "Slave Interface" "/axi_gpio_ctrl/S_AXI" \
    } [get_bd_cells axi_interconnect_0]

# ---- 连接PS7到AXI Interconnect ----
connect_bd_net [get_bd_pins ps7/M_AXI_GP0] [get_bd_pins axi_interconnect_0/S00_AXI]

# ---- 连接AXI Interconnect到GPIO ----
connect_bd_net [get_bd_pins axi_interconnect_0/M00_AXI] [get_bd_pins axi_gpio_ctrl/S_AXI]

# ---- 连接PS7时钟到GPIO ----
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins axi_gpio_ctrl/s_axi_aclk]
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins axi_interconnect_0/ACLK]
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins axi_interconnect_0/S00_ACLK]
connect_bd_net [get_bd_pins ps7/FCLK_CLK0] [get_bd_pins axi_interconnect_0/M00_ACLK]

# ---- 连接PS7复位到GPIO ----
connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins axi_gpio_ctrl/s_axi_aresetn]
connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins axi_interconnect_0/ARESETN]
connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins axi_interconnect_0/S00_ARESETN]
connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins axi_interconnect_0/M00_ARESETN]

# ---- 外部化PL端口 ----
make_bd_pins_external [get_bd_pins ps7/FCLK_CLK0]
make_bd_pins_external [get_bd_pins ps7/FCLK_RESET0_N]
make_bd_pins_external [get_bd_pins axi_gpio_ctrl/gpio_io_o]
make_bd_pins_external [get_bd_pins axi_gpio_ctrl/gpio2_io_i]

puts "INFO: AXI GPIO + Interconnect已添加并连接"
