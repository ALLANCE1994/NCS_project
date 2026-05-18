# XC7Z020CLG400-2 完整引脚定义知识库

> **归属智能体**：@H 硬件工程师
> **文档来源**：Xilinx官方 xc7z020clg400pkg.csv
> **生成日期**：2026-05-18
> **芯片型号**：XC7Z020CLG400-2（ZYNQ7020，CLG400封装）

【知识来源】
- 文档名称：《xc7z020clg400pkg.csv》（Xilinx官方引脚定义文件）
- 核心出处：Xilinx 7系列FPGA封装引脚定义
- 关键词标签：XC7Z020、CLG400、引脚、Bank、MIO、HR、DDR、CONFIG、XDC、VCCO

---

## 一、引脚总览

| 维度 | 数值 |
|------|------|
| 总引脚数 | 402 |
| 可用引脚（排除No-Connect） | 375 |
| No-Connect引脚 | 27 |
| PL Bank数量 | 4个（Bank 0/13/34/35） |
| PS MIO Bank数量 | 3个（Bank 500/501/502） |

### 1.1 按I/O类型分布

| I/O类型 | 数量 | 说明 |
|---------|------|------|
| CONFIG | 21 | 配置引脚（JTAG、时钟、电源、ADC） |
| HR | 125 | High Range通用I/O（PL端，支持1.2V~3.3V） |
| MIO | 58 | PS端多用途I/O（ARM直接控制） |
| DDR | 75 | DDR存储器专用引脚（PS端DDR控制器） |
| OTHER | 121 | 电源/地/特殊功能引脚 |

### 1.2 按Bank分布

| Bank | 引脚数 | 说明 |
|------|--------|------|
| Bank 0 | 22 | PL Bank 0（配置Bank，含JTAG/时钟/ADC） |
| Bank 13 | 29 | PL Bank 13（仅7Z010可用，7Z020为No-Connect） |
| Bank 34 | 56 | PL Bank 34（通用I/O） |
| Bank 35 | 56 | PL Bank 35（通用I/O） |
| Bank 500 | 20 | PS MIO Bank 500（固定1.8V） |
| Bank  | 2 |  |
| Bank 501 | 44 | PS MIO Bank 501（固定1.8V） |
| Bank 502 | 85 | PS MIO Bank 502（固定1.8V，含DDR） |
| Bank CONFIG | 88 | 配置/电源/特殊引脚 |

## 二、CONFIG引脚（JTAG/配置/电源）

| 引脚 | Pin Name | 说明 |
|------|----------|------|
| R11 | DONE_0 | 配置完成指示 |
| M9 | DXP_0 | 配置解密正端 |
| J10 | GNDADC_0 | ADC地 |
| J9 | VCCADC_0 | ADC供电 |
| L9 | VREFP_0 | ADC正参考电压 |
| L10 | VN_0 | ADC负端 |
| F11 | VCCBATT_0 | 电池备份供电 |
| F9 | TCK_0 | JTAG时钟 |
| M10 | DXN_0 | 配置解密负端 |
| K10 | VREFN_0 | ADC负参考电压 |
| K9 | VP_0 | ADC正端 |
| F10 | RSVDGND | 保留地 |
| N6 | RSVDVCC3 | 保留电源 |
| R6 | RSVDVCC2 | 保留电源 |
| R10 | INIT_B_0 | 配置初始化 |
| G6 | TDI_0 | JTAG数据输入 |
| F6 | TDO_0 | JTAG数据输出 |
| T6 | RSVDVCC1 | 保留电源 |
| M6 | CFGBVS_0 | 配置Bank电压选择 |
| L6 | PROGRAM_B_0 | 配置复位（低有效） |
| J6 | TMS_0 | JTAG模式选择 |

## 三、MIO引脚（PS端多用途I/O）

MIO引脚由ARM PS端直接控制，不经过FPGA PL端，用于UART、I2C、SPI、SD、USB、以太网、QSPI等外设。

| 引脚 | Pin Name | Bank |
|------|----------|------|
| E7 | PS_CLK_500 | Bank 500 |
| E11 | PS_MIO_VREF_501 | Bank 501 |
| C7 | PS_POR_B_500 | Bank 500 |
| C8 | PS_MIO15_500 | Bank 500 |
| E14 | PS_MIO17_501 | Bank 501 |
| D10 | PS_MIO19_501 | Bank 501 |
| F14 | PS_MIO21_501 | Bank 501 |
| D11 | PS_MIO23_501 | Bank 501 |
| F15 | PS_MIO25_501 | Bank 501 |
| D13 | PS_MIO27_501 | Bank 501 |
| C13 | PS_MIO29_501 | Bank 501 |
| E16 | PS_MIO31_501 | Bank 501 |
| D15 | PS_MIO33_501 | Bank 501 |
| F12 | PS_MIO35_501 | Bank 501 |
| E13 | PS_MIO38_501 | Bank 501 |
| D14 | PS_MIO40_501 | Bank 501 |
| E12 | PS_MIO42_501 | Bank 501 |
| F13 | PS_MIO44_501 | Bank 501 |
| D16 | PS_MIO46_501 | Bank 501 |
| B12 | PS_MIO48_501 | Bank 501 |
| B13 | PS_MIO50_501 | Bank 501 |
| C10 | PS_MIO52_501 | Bank 501 |
| B10 | PS_SRST_B_501 | Bank 501 |
| C5 | PS_MIO14_500 | Bank 500 |
| A19 | PS_MIO16_501 | Bank 501 |
| B18 | PS_MIO18_501 | Bank 501 |
| A17 | PS_MIO20_501 | Bank 501 |
| B17 | PS_MIO22_501 | Bank 501 |
| A16 | PS_MIO24_501 | Bank 501 |
| A15 | PS_MIO26_501 | Bank 501 |
| C16 | PS_MIO28_501 | Bank 501 |
| C15 | PS_MIO30_501 | Bank 501 |
| A14 | PS_MIO32_501 | Bank 501 |
| A12 | PS_MIO34_501 | Bank 501 |
| A11 | PS_MIO36_501 | Bank 501 |
| A10 | PS_MIO37_501 | Bank 501 |
| C18 | PS_MIO39_501 | Bank 501 |
| C17 | PS_MIO41_501 | Bank 501 |
| A9 | PS_MIO43_501 | Bank 501 |
| B15 | PS_MIO45_501 | Bank 501 |
| B14 | PS_MIO47_501 | Bank 501 |
| C12 | PS_MIO49_501 | Bank 501 |
| B9 | PS_MIO51_501 | Bank 501 |
| C11 | PS_MIO53_501 | Bank 501 |
| E8 | PS_MIO13_500 | Bank 500 |
| D9 | PS_MIO12_500 | Bank 500 |
| C6 | PS_MIO11_500 | Bank 500 |
| E9 | PS_MIO10_500 | Bank 500 |
| B5 | PS_MIO9_500 | Bank 500 |
| D5 | PS_MIO8_500 | Bank 500 |
| D8 | PS_MIO7_500 | Bank 500 |
| A5 | PS_MIO6_500 | Bank 500 |
| A6 | PS_MIO5_500 | Bank 500 |
| B7 | PS_MIO4_500 | Bank 500 |
| D6 | PS_MIO3_500 | Bank 500 |
| B8 | PS_MIO2_500 | Bank 500 |
| A7 | PS_MIO1_500 | Bank 500 |
| E6 | PS_MIO0_500 | Bank 500 |

## 四、HR引脚（PL端通用I/O）

HR（High Range）引脚为PL端通用I/O，支持1.2V~3.3V电压范围，可配置为LVCMOS、LVTTL、SSTL等多种I/O标准。

### 4.34 Bank 34

| 引脚 | Pin Name | Byte Group | 说明 |
|------|----------|------------|------|
| R19 | IO_0_34 | NA |  |
| T11 | IO_L1P_T0_34 | 0 |  |
| T10 | IO_L1N_T0_34 | 0 |  |
| T12 | IO_L2P_T0_34 | 0 |  |
| U12 | IO_L2N_T0_34 | 0 |  |
| U13 | IO_L3P_T0_DQS_PUDC_B_34 | 0 | DQS数据选通 |
| V13 | IO_L3N_T0_DQS_34 | 0 | DQS数据选通 |
| V12 | IO_L4P_T0_34 | 0 |  |
| W13 | IO_L4N_T0_34 | 0 |  |
| T14 | IO_L5P_T0_34 | 0 |  |
| T15 | IO_L5N_T0_34 | 0 |  |
| P14 | IO_L6P_T0_34 | 0 |  |
| R14 | IO_L6N_T0_VREF_34 | 0 | 参考电压 |
| Y16 | IO_L7P_T1_34 | 1 |  |
| Y17 | IO_L7N_T1_34 | 1 |  |
| W14 | IO_L8P_T1_34 | 1 |  |
| Y14 | IO_L8N_T1_34 | 1 |  |
| T16 | IO_L9P_T1_DQS_34 | 1 | DQS数据选通 |
| U17 | IO_L9N_T1_DQS_34 | 1 | DQS数据选通 |
| V15 | IO_L10P_T1_34 | 1 |  |
| W15 | IO_L10N_T1_34 | 1 |  |
| U14 | IO_L11P_T1_SRCC_34 | 1 | 单区域时钟输入 |
| U15 | IO_L11N_T1_SRCC_34 | 1 | 单区域时钟输入 |
| U18 | IO_L12P_T1_MRCC_34 | 1 | 多区域时钟输入 |
| U19 | IO_L12N_T1_MRCC_34 | 1 | 多区域时钟输入 |
| N18 | IO_L13P_T2_MRCC_34 | 2 | 多区域时钟输入 |
| P19 | IO_L13N_T2_MRCC_34 | 2 | 多区域时钟输入 |
| N20 | IO_L14P_T2_SRCC_34 | 2 | 单区域时钟输入 |
| P20 | IO_L14N_T2_SRCC_34 | 2 | 单区域时钟输入 |
| T20 | IO_L15P_T2_DQS_34 | 2 | DQS数据选通 |
| U20 | IO_L15N_T2_DQS_34 | 2 | DQS数据选通 |
| V20 | IO_L16P_T2_34 | 2 |  |
| W20 | IO_L16N_T2_34 | 2 |  |
| Y18 | IO_L17P_T2_34 | 2 |  |
| Y19 | IO_L17N_T2_34 | 2 |  |
| V16 | IO_L18P_T2_34 | 2 |  |
| W16 | IO_L18N_T2_34 | 2 |  |
| R16 | IO_L19P_T3_34 | 3 |  |
| R17 | IO_L19N_T3_VREF_34 | 3 | 参考电压 |
| T17 | IO_L20P_T3_34 | 3 |  |
| R18 | IO_L20N_T3_34 | 3 |  |
| V17 | IO_L21P_T3_DQS_34 | 3 | DQS数据选通 |
| V18 | IO_L21N_T3_DQS_34 | 3 | DQS数据选通 |
| W18 | IO_L22P_T3_34 | 3 |  |
| W19 | IO_L22N_T3_34 | 3 |  |
| N17 | IO_L23P_T3_34 | 3 |  |
| P18 | IO_L23N_T3_34 | 3 |  |
| P15 | IO_L24P_T3_34 | 3 |  |
| P16 | IO_L24N_T3_34 | 3 |  |
| T19 | IO_25_34 | NA |  |

### 4.35 Bank 35

| 引脚 | Pin Name | Byte Group | 说明 |
|------|----------|------------|------|
| G14 | IO_0_35 | NA |  |
| C20 | IO_L1P_T0_AD0P_35 | 0 |  |
| B20 | IO_L1N_T0_AD0N_35 | 0 |  |
| B19 | IO_L2P_T0_AD8P_35 | 0 |  |
| A20 | IO_L2N_T0_AD8N_35 | 0 |  |
| E17 | IO_L3P_T0_DQS_AD1P_35 | 0 | DQS数据选通 |
| D18 | IO_L3N_T0_DQS_AD1N_35 | 0 | DQS数据选通 |
| D19 | IO_L4P_T0_35 | 0 |  |
| D20 | IO_L4N_T0_35 | 0 |  |
| E18 | IO_L5P_T0_AD9P_35 | 0 |  |
| E19 | IO_L5N_T0_AD9N_35 | 0 |  |
| F16 | IO_L6P_T0_35 | 0 |  |
| F17 | IO_L6N_T0_VREF_35 | 0 | 参考电压 |
| M19 | IO_L7P_T1_AD2P_35 | 1 |  |
| M20 | IO_L7N_T1_AD2N_35 | 1 |  |
| M17 | IO_L8P_T1_AD10P_35 | 1 |  |
| M18 | IO_L8N_T1_AD10N_35 | 1 |  |
| L19 | IO_L9P_T1_DQS_AD3P_35 | 1 | DQS数据选通 |
| L20 | IO_L9N_T1_DQS_AD3N_35 | 1 | DQS数据选通 |
| K19 | IO_L10P_T1_AD11P_35 | 1 |  |
| J19 | IO_L10N_T1_AD11N_35 | 1 |  |
| L16 | IO_L11P_T1_SRCC_35 | 1 | 单区域时钟输入 |
| L17 | IO_L11N_T1_SRCC_35 | 1 | 单区域时钟输入 |
| K17 | IO_L12P_T1_MRCC_35 | 1 | 多区域时钟输入 |
| K18 | IO_L12N_T1_MRCC_35 | 1 | 多区域时钟输入 |
| H16 | IO_L13P_T2_MRCC_35 | 2 | 多区域时钟输入 |
| H17 | IO_L13N_T2_MRCC_35 | 2 | 多区域时钟输入 |
| J18 | IO_L14P_T2_AD4P_SRCC_35 | 2 | 单区域时钟输入 |
| H18 | IO_L14N_T2_AD4N_SRCC_35 | 2 | 单区域时钟输入 |
| F19 | IO_L15P_T2_DQS_AD12P_35 | 2 | DQS数据选通 |
| F20 | IO_L15N_T2_DQS_AD12N_35 | 2 | DQS数据选通 |
| G17 | IO_L16P_T2_35 | 2 |  |
| G18 | IO_L16N_T2_35 | 2 |  |
| J20 | IO_L17P_T2_AD5P_35 | 2 |  |
| H20 | IO_L17N_T2_AD5N_35 | 2 |  |
| G19 | IO_L18P_T2_AD13P_35 | 2 |  |
| G20 | IO_L18N_T2_AD13N_35 | 2 |  |
| H15 | IO_L19P_T3_35 | 3 |  |
| G15 | IO_L19N_T3_VREF_35 | 3 | 参考电压 |
| K14 | IO_L20P_T3_AD6P_35 | 3 |  |
| J14 | IO_L20N_T3_AD6N_35 | 3 |  |
| N15 | IO_L21P_T3_DQS_AD14P_35 | 3 | DQS数据选通 |
| N16 | IO_L21N_T3_DQS_AD14N_35 | 3 | DQS数据选通 |
| L14 | IO_L22P_T3_AD7P_35 | 3 |  |
| L15 | IO_L22N_T3_AD7N_35 | 3 |  |
| M14 | IO_L23P_T3_35 | 3 |  |
| M15 | IO_L23N_T3_35 | 3 |  |
| K16 | IO_L24P_T3_AD15P_35 | 3 |  |
| J16 | IO_L24N_T3_AD15N_35 | 3 |  |
| J15 | IO_25_35 | NA |  |

## 五、DDR引脚

DDR引脚用于PS端DDR存储器控制器，连接DDR3 SDRAM。

| 引脚 | Pin Name | Bank | 说明 |
|------|----------|------|------|
| B4 | PS_DDR_DRST_B_502 | Bank 502 |  |
| C3 | PS_DDR_DQ0_502 | Bank 502 | DDR数据总线 |
| B3 | PS_DDR_DQ1_502 | Bank 502 | DDR数据总线 |
| A2 | PS_DDR_DQ2_502 | Bank 502 | DDR数据总线 |
| A4 | PS_DDR_DQ3_502 | Bank 502 | DDR数据总线 |
| A1 | PS_DDR_DM0_502 | Bank 502 | DDR数据掩码 |
| C2 | PS_DDR_DQS_P0_502 | Bank 502 | DDR数据总线 |
| B2 | PS_DDR_DQS_N0_502 | Bank 502 | DDR数据总线 |
| D3 | PS_DDR_DQ4_502 | Bank 502 | DDR数据总线 |
| D1 | PS_DDR_DQ5_502 | Bank 502 | DDR数据总线 |
| C1 | PS_DDR_DQ6_502 | Bank 502 | DDR数据总线 |
| E1 | PS_DDR_DQ7_502 | Bank 502 | DDR数据总线 |
| E2 | PS_DDR_DQ8_502 | Bank 502 | DDR数据总线 |
| E3 | PS_DDR_DQ9_502 | Bank 502 | DDR数据总线 |
| G3 | PS_DDR_DQ10_502 | Bank 502 | DDR数据总线 |
| H3 | PS_DDR_DQ11_502 | Bank 502 | DDR数据总线 |
| F1 | PS_DDR_DM1_502 | Bank 502 | DDR数据掩码 |
| G2 | PS_DDR_DQS_P1_502 | Bank 502 | DDR数据总线 |
| F2 | PS_DDR_DQS_N1_502 | Bank 502 | DDR数据总线 |
| J3 | PS_DDR_DQ12_502 | Bank 502 | DDR数据总线 |
| H2 | PS_DDR_DQ13_502 | Bank 502 | DDR数据总线 |
| H1 | PS_DDR_DQ14_502 | Bank 502 | DDR数据总线 |
| J1 | PS_DDR_DQ15_502 | Bank 502 | DDR数据总线 |
| F4 | PS_DDR_A14_502 | Bank 502 |  |
| D4 | PS_DDR_A13_502 | Bank 502 |  |
| E4 | PS_DDR_A12_502 | Bank 502 |  |
| G4 | PS_DDR_A11_502 | Bank 502 |  |
| F5 | PS_DDR_A10_502 | Bank 502 |  |
| J4 | PS_DDR_A9_502 | Bank 502 |  |
| K1 | PS_DDR_A8_502 | Bank 502 |  |
| K4 | PS_DDR_A7_502 | Bank 502 |  |
| L4 | PS_DDR_A6_502 | Bank 502 |  |
| L1 | PS_DDR_A5_502 | Bank 502 |  |
| M4 | PS_DDR_A4_502 | Bank 502 |  |
| K3 | PS_DDR_A3_502 | Bank 502 |  |
| G5 | PS_DDR_VRN_502 | Bank 502 |  |
| H5 | PS_DDR_VRP_502 | Bank 502 |  |
| L2 | PS_DDR_CKP_502 | Bank 502 | DDR时钟 |
| M2 | PS_DDR_CKN_502 | Bank 502 | DDR时钟 |
| M3 | PS_DDR_A2_502 | Bank 502 |  |
| K2 | PS_DDR_A1_502 | Bank 502 |  |
| N2 | PS_DDR_A0_502 | Bank 502 |  |
| J5 | PS_DDR_BA2_502 | Bank 502 | DDR Bank地址 |
| R4 | PS_DDR_BA1_502 | Bank 502 | DDR Bank地址 |
| L5 | PS_DDR_BA0_502 | Bank 502 | DDR Bank地址 |
| N5 | PS_DDR_ODT_502 | Bank 502 | DDR片上终端 |
| N1 | PS_DDR_CS_B_502 | Bank 502 |  |
| N3 | PS_DDR_CKE_502 | Bank 502 | DDR时钟 |
| M5 | PS_DDR_WE_B_502 | Bank 502 |  |
| P5 | PS_DDR_CAS_B_502 | Bank 502 |  |
| P4 | PS_DDR_RAS_B_502 | Bank 502 |  |
| P1 | PS_DDR_DQ16_502 | Bank 502 | DDR数据总线 |
| P3 | PS_DDR_DQ17_502 | Bank 502 | DDR数据总线 |
| R3 | PS_DDR_DQ18_502 | Bank 502 | DDR数据总线 |
| R1 | PS_DDR_DQ19_502 | Bank 502 | DDR数据总线 |
| T1 | PS_DDR_DM2_502 | Bank 502 | DDR数据掩码 |
| R2 | PS_DDR_DQS_P2_502 | Bank 502 | DDR数据总线 |
| T2 | PS_DDR_DQS_N2_502 | Bank 502 | DDR数据总线 |
| T4 | PS_DDR_DQ20_502 | Bank 502 | DDR数据总线 |
| U4 | PS_DDR_DQ21_502 | Bank 502 | DDR数据总线 |
| U2 | PS_DDR_DQ22_502 | Bank 502 | DDR数据总线 |
| U3 | PS_DDR_DQ23_502 | Bank 502 | DDR数据总线 |
| V1 | PS_DDR_DQ24_502 | Bank 502 | DDR数据总线 |
| Y3 | PS_DDR_DQ25_502 | Bank 502 | DDR数据总线 |
| W1 | PS_DDR_DQ26_502 | Bank 502 | DDR数据总线 |
| Y4 | PS_DDR_DQ27_502 | Bank 502 | DDR数据总线 |
| Y1 | PS_DDR_DM3_502 | Bank 502 | DDR数据掩码 |
| W5 | PS_DDR_DQS_P3_502 | Bank 502 | DDR数据总线 |
| W4 | PS_DDR_DQS_N3_502 | Bank 502 | DDR数据总线 |
| Y2 | PS_DDR_DQ28_502 | Bank 502 | DDR数据总线 |
| W3 | PS_DDR_DQ29_502 | Bank 502 | DDR数据总线 |
| V2 | PS_DDR_DQ30_502 | Bank 502 | DDR数据总线 |
| V3 | PS_DDR_DQ31_502 | Bank 502 | DDR数据总线 |
| H6 | PS_DDR_VREF0_502 | Bank 502 | DDR参考电压 |
| P6 | PS_DDR_VREF1_502 | Bank 502 | DDR参考电压 |

## 六、XDC约束编写指南

### 6.1 引脚约束模板

```tcl
# CONFIG引脚约束
set_property PACKAGE_PIN R11 [get_ports DONE_0]
set_property PACKAGE_PIN L6  [get_ports PROGRAM_B_0]

# PL HR引脚约束（Bank 34/35）
set_property PACKAGE_PIN <Pin> [get_ports <port_name>]
set_property IOSTANDARD LVCMOS33 [get_ports <port_name>]
set_property VCCO 3.3 [get_ports <port_name>]

# 时钟引脚约束
set_property PACKAGE_PIN <Pin> [get_ports clk]
create_clock -period <period_ns> [get_ports clk]
```

### 6.2 Bank电压规划

| Bank | 推荐VCCO | 典型应用 |
|------|----------|----------|
| Bank 0 | 1.8V | 配置Bank，固定电压 |
| Bank 13 | 3.3V | 仅7Z010可用，7Z020中为No-Connect |
| Bank 34 | 3.3V | 通用I/O（LED/按键/UART等） |
| Bank 35 | 3.3V | 通用I/O（HDMI/以太网等） |
| Bank 500 | 1.8V | PS MIO（固定） |
| Bank 501 | 1.8V | PS MIO（固定） |
| Bank 502 | 1.8V | PS MIO + DDR（固定） |

### 6.3 I/O标准选择

| I/O标准 | 电压范围 | 典型应用 |
|----------|----------|----------|
| LVCMOS33 | 3.3V | LED、按键、UART、SPI |
| LVCMOS18 | 1.8V | 高速信号 |
| SSTL135 | 1.35V | DDR3 |
| LVDS | 差分 | 高速差分信号 |

## 七、No-Connect引脚（禁止使用）

| 引脚 | Pin Name | Bank |
|------|----------|------|
| V5 | IO_L6N_T0_VREF_13 | Bank 13 |
| U7 | IO_L11P_T1_SRCC_13 | Bank 13 |
| V7 | IO_L11N_T1_SRCC_13 | Bank 13 |
| T9 | IO_L12P_T1_MRCC_13 | Bank 13 |
| U10 | IO_L12N_T1_MRCC_13 | Bank 13 |
| Y7 | IO_L13P_T2_MRCC_13 | Bank 13 |
| Y6 | IO_L13N_T2_MRCC_13 | Bank 13 |
| Y9 | IO_L14P_T2_SRCC_13 | Bank 13 |
| Y8 | IO_L14N_T2_SRCC_13 | Bank 13 |
| V8 | IO_L15P_T2_DQS_13 | Bank 13 |
| W8 | IO_L15N_T2_DQS_13 | Bank 13 |
| W10 | IO_L16P_T2_13 | Bank 13 |
| W9 | IO_L16N_T2_13 | Bank 13 |
| U9 | IO_L17P_T2_13 | Bank 13 |
| U8 | IO_L17N_T2_13 | Bank 13 |
| W11 | IO_L18P_T2_13 | Bank 13 |
| Y11 | IO_L18N_T2_13 | Bank 13 |
| T5 | IO_L19P_T3_13 | Bank 13 |
| U5 | IO_L19N_T3_VREF_13 | Bank 13 |
| Y12 | IO_L20P_T3_13 | Bank 13 |
| Y13 | IO_L20N_T3_13 | Bank 13 |
| V11 | IO_L21P_T3_DQS_13 | Bank 13 |
| V10 | IO_L21N_T3_DQS_13 | Bank 13 |
| V6 | IO_L22P_T3_13 | Bank 13 |
| W6 | IO_L22N_T3_13 | Bank 13 |
|  |  | Bank  |
| Total Number of Pins |  400 | Bank  |

> ⚠️ **警告**：No-Connect引脚在PCB上必须悬空，禁止连接任何信号。

## 八、完整引脚列表

| 引脚 | Pin Name | Bank | I/O Type | No-Connect |
|------|----------|------|----------|------------|
| R11 | DONE_0 | 0 | CONFIG | - |
| M9 | DXP_0 | 0 | CONFIG | - |
| J10 | GNDADC_0 | 0 | CONFIG | - |
| J9 | VCCADC_0 | 0 | CONFIG | - |
| L9 | VREFP_0 | 0 | CONFIG | - |
| L10 | VN_0 | 0 | CONFIG | - |
| F11 | VCCBATT_0 | 0 | CONFIG | - |
| F9 | TCK_0 | 0 | CONFIG | - |
| M10 | DXN_0 | 0 | CONFIG | - |
| K10 | VREFN_0 | 0 | CONFIG | - |
| K9 | VP_0 | 0 | CONFIG | - |
| F10 | RSVDGND | 0 | CONFIG | - |
| N6 | RSVDVCC3 | 0 | CONFIG | - |
| R6 | RSVDVCC2 | 0 | CONFIG | - |
| R10 | INIT_B_0 | 0 | CONFIG | - |
| G6 | TDI_0 | 0 | CONFIG | - |
| F6 | TDO_0 | 0 | CONFIG | - |
| T6 | RSVDVCC1 | 0 | CONFIG | - |
| M6 | CFGBVS_0 | 0 | CONFIG | - |
| L6 | PROGRAM_B_0 | 0 | CONFIG | - |
| J6 | TMS_0 | 0 | CONFIG | - |
| V5 | IO_L6N_T0_VREF_13 | 13 | HR | 7Z010 |
| U7 | IO_L11P_T1_SRCC_13 | 13 | HR | 7Z010 |
| V7 | IO_L11N_T1_SRCC_13 | 13 | HR | 7Z010 |
| T9 | IO_L12P_T1_MRCC_13 | 13 | HR | 7Z010 |
| U10 | IO_L12N_T1_MRCC_13 | 13 | HR | 7Z010 |
| Y7 | IO_L13P_T2_MRCC_13 | 13 | HR | 7Z010 |
| Y6 | IO_L13N_T2_MRCC_13 | 13 | HR | 7Z010 |
| Y9 | IO_L14P_T2_SRCC_13 | 13 | HR | 7Z010 |
| Y8 | IO_L14N_T2_SRCC_13 | 13 | HR | 7Z010 |
| V8 | IO_L15P_T2_DQS_13 | 13 | HR | 7Z010 |
| W8 | IO_L15N_T2_DQS_13 | 13 | HR | 7Z010 |
| W10 | IO_L16P_T2_13 | 13 | HR | 7Z010 |
| W9 | IO_L16N_T2_13 | 13 | HR | 7Z010 |
| U9 | IO_L17P_T2_13 | 13 | HR | 7Z010 |
| U8 | IO_L17N_T2_13 | 13 | HR | 7Z010 |
| W11 | IO_L18P_T2_13 | 13 | HR | 7Z010 |
| Y11 | IO_L18N_T2_13 | 13 | HR | 7Z010 |
| T5 | IO_L19P_T3_13 | 13 | HR | 7Z010 |
| U5 | IO_L19N_T3_VREF_13 | 13 | HR | 7Z010 |
| Y12 | IO_L20P_T3_13 | 13 | HR | 7Z010 |
| Y13 | IO_L20N_T3_13 | 13 | HR | 7Z010 |
| V11 | IO_L21P_T3_DQS_13 | 13 | HR | 7Z010 |
| V10 | IO_L21N_T3_DQS_13 | 13 | HR | 7Z010 |
| V6 | IO_L22P_T3_13 | 13 | HR | 7Z010 |
| W6 | IO_L22N_T3_13 | 13 | HR | 7Z010 |
| R19 | IO_0_34 | 34 | HR | - |
| T11 | IO_L1P_T0_34 | 34 | HR | - |
| T10 | IO_L1N_T0_34 | 34 | HR | - |
| T12 | IO_L2P_T0_34 | 34 | HR | - |
| U12 | IO_L2N_T0_34 | 34 | HR | - |
| U13 | IO_L3P_T0_DQS_PUDC_B_34 | 34 | HR | - |
| V13 | IO_L3N_T0_DQS_34 | 34 | HR | - |
| V12 | IO_L4P_T0_34 | 34 | HR | - |
| W13 | IO_L4N_T0_34 | 34 | HR | - |
| T14 | IO_L5P_T0_34 | 34 | HR | - |
| T15 | IO_L5N_T0_34 | 34 | HR | - |
| P14 | IO_L6P_T0_34 | 34 | HR | - |
| R14 | IO_L6N_T0_VREF_34 | 34 | HR | - |
| Y16 | IO_L7P_T1_34 | 34 | HR | - |
| Y17 | IO_L7N_T1_34 | 34 | HR | - |
| W14 | IO_L8P_T1_34 | 34 | HR | - |
| Y14 | IO_L8N_T1_34 | 34 | HR | - |
| T16 | IO_L9P_T1_DQS_34 | 34 | HR | - |
| U17 | IO_L9N_T1_DQS_34 | 34 | HR | - |
| V15 | IO_L10P_T1_34 | 34 | HR | - |
| W15 | IO_L10N_T1_34 | 34 | HR | - |
| U14 | IO_L11P_T1_SRCC_34 | 34 | HR | - |
| U15 | IO_L11N_T1_SRCC_34 | 34 | HR | - |
| U18 | IO_L12P_T1_MRCC_34 | 34 | HR | - |
| U19 | IO_L12N_T1_MRCC_34 | 34 | HR | - |
| N18 | IO_L13P_T2_MRCC_34 | 34 | HR | - |
| P19 | IO_L13N_T2_MRCC_34 | 34 | HR | - |
| N20 | IO_L14P_T2_SRCC_34 | 34 | HR | - |
| P20 | IO_L14N_T2_SRCC_34 | 34 | HR | - |
| T20 | IO_L15P_T2_DQS_34 | 34 | HR | - |
| U20 | IO_L15N_T2_DQS_34 | 34 | HR | - |
| V20 | IO_L16P_T2_34 | 34 | HR | - |
| W20 | IO_L16N_T2_34 | 34 | HR | - |
| Y18 | IO_L17P_T2_34 | 34 | HR | - |
| Y19 | IO_L17N_T2_34 | 34 | HR | - |
| V16 | IO_L18P_T2_34 | 34 | HR | - |
| W16 | IO_L18N_T2_34 | 34 | HR | - |
| R16 | IO_L19P_T3_34 | 34 | HR | - |
| R17 | IO_L19N_T3_VREF_34 | 34 | HR | - |
| T17 | IO_L20P_T3_34 | 34 | HR | - |
| R18 | IO_L20N_T3_34 | 34 | HR | - |
| V17 | IO_L21P_T3_DQS_34 | 34 | HR | - |
| V18 | IO_L21N_T3_DQS_34 | 34 | HR | - |
| W18 | IO_L22P_T3_34 | 34 | HR | - |
| W19 | IO_L22N_T3_34 | 34 | HR | - |
| N17 | IO_L23P_T3_34 | 34 | HR | - |
| P18 | IO_L23N_T3_34 | 34 | HR | - |
| P15 | IO_L24P_T3_34 | 34 | HR | - |
| P16 | IO_L24N_T3_34 | 34 | HR | - |
| T19 | IO_25_34 | 34 | HR | - |
| G14 | IO_0_35 | 35 | HR | - |
| C20 | IO_L1P_T0_AD0P_35 | 35 | HR | - |
| B20 | IO_L1N_T0_AD0N_35 | 35 | HR | - |
| B19 | IO_L2P_T0_AD8P_35 | 35 | HR | - |
| A20 | IO_L2N_T0_AD8N_35 | 35 | HR | - |
| E17 | IO_L3P_T0_DQS_AD1P_35 | 35 | HR | - |
| D18 | IO_L3N_T0_DQS_AD1N_35 | 35 | HR | - |
| D19 | IO_L4P_T0_35 | 35 | HR | - |
| D20 | IO_L4N_T0_35 | 35 | HR | - |
| E18 | IO_L5P_T0_AD9P_35 | 35 | HR | - |
| E19 | IO_L5N_T0_AD9N_35 | 35 | HR | - |
| F16 | IO_L6P_T0_35 | 35 | HR | - |
| F17 | IO_L6N_T0_VREF_35 | 35 | HR | - |
| M19 | IO_L7P_T1_AD2P_35 | 35 | HR | - |
| M20 | IO_L7N_T1_AD2N_35 | 35 | HR | - |
| M17 | IO_L8P_T1_AD10P_35 | 35 | HR | - |
| M18 | IO_L8N_T1_AD10N_35 | 35 | HR | - |
| L19 | IO_L9P_T1_DQS_AD3P_35 | 35 | HR | - |
| L20 | IO_L9N_T1_DQS_AD3N_35 | 35 | HR | - |
| K19 | IO_L10P_T1_AD11P_35 | 35 | HR | - |
| J19 | IO_L10N_T1_AD11N_35 | 35 | HR | - |
| L16 | IO_L11P_T1_SRCC_35 | 35 | HR | - |
| L17 | IO_L11N_T1_SRCC_35 | 35 | HR | - |
| K17 | IO_L12P_T1_MRCC_35 | 35 | HR | - |
| K18 | IO_L12N_T1_MRCC_35 | 35 | HR | - |
| H16 | IO_L13P_T2_MRCC_35 | 35 | HR | - |
| H17 | IO_L13N_T2_MRCC_35 | 35 | HR | - |
| J18 | IO_L14P_T2_AD4P_SRCC_35 | 35 | HR | - |
| H18 | IO_L14N_T2_AD4N_SRCC_35 | 35 | HR | - |
| F19 | IO_L15P_T2_DQS_AD12P_35 | 35 | HR | - |
| F20 | IO_L15N_T2_DQS_AD12N_35 | 35 | HR | - |
| G17 | IO_L16P_T2_35 | 35 | HR | - |
| G18 | IO_L16N_T2_35 | 35 | HR | - |
| J20 | IO_L17P_T2_AD5P_35 | 35 | HR | - |
| H20 | IO_L17N_T2_AD5N_35 | 35 | HR | - |
| G19 | IO_L18P_T2_AD13P_35 | 35 | HR | - |
| G20 | IO_L18N_T2_AD13N_35 | 35 | HR | - |
| H15 | IO_L19P_T3_35 | 35 | HR | - |
| G15 | IO_L19N_T3_VREF_35 | 35 | HR | - |
| K14 | IO_L20P_T3_AD6P_35 | 35 | HR | - |
| J14 | IO_L20N_T3_AD6N_35 | 35 | HR | - |
| N15 | IO_L21P_T3_DQS_AD14P_35 | 35 | HR | - |
| N16 | IO_L21N_T3_DQS_AD14N_35 | 35 | HR | - |
| L14 | IO_L22P_T3_AD7P_35 | 35 | HR | - |
| L15 | IO_L22N_T3_AD7N_35 | 35 | HR | - |
| M14 | IO_L23P_T3_35 | 35 | HR | - |
| M15 | IO_L23N_T3_35 | 35 | HR | - |
| K16 | IO_L24P_T3_AD15P_35 | 35 | HR | - |
| J16 | IO_L24N_T3_AD15N_35 | 35 | HR | - |
| J15 | IO_25_35 | 35 | HR | - |
| E7 | PS_CLK_500 | 500 | MIO | - |
| E11 | PS_MIO_VREF_501 | 501 | MIO | - |
| C7 | PS_POR_B_500 | 500 | MIO | - |
| C8 | PS_MIO15_500 | 500 | MIO | - |
| E14 | PS_MIO17_501 | 501 | MIO | - |
| D10 | PS_MIO19_501 | 501 | MIO | - |
| F14 | PS_MIO21_501 | 501 | MIO | - |
| D11 | PS_MIO23_501 | 501 | MIO | - |
| F15 | PS_MIO25_501 | 501 | MIO | - |
| D13 | PS_MIO27_501 | 501 | MIO | - |
| C13 | PS_MIO29_501 | 501 | MIO | - |
| E16 | PS_MIO31_501 | 501 | MIO | - |
| D15 | PS_MIO33_501 | 501 | MIO | - |
| F12 | PS_MIO35_501 | 501 | MIO | - |
| E13 | PS_MIO38_501 | 501 | MIO | - |
| D14 | PS_MIO40_501 | 501 | MIO | - |
| E12 | PS_MIO42_501 | 501 | MIO | - |
| F13 | PS_MIO44_501 | 501 | MIO | - |
| D16 | PS_MIO46_501 | 501 | MIO | - |
| B12 | PS_MIO48_501 | 501 | MIO | - |
| B13 | PS_MIO50_501 | 501 | MIO | - |
| C10 | PS_MIO52_501 | 501 | MIO | - |
| B10 | PS_SRST_B_501 | 501 | MIO | - |
| C5 | PS_MIO14_500 | 500 | MIO | - |
| A19 | PS_MIO16_501 | 501 | MIO | - |
| B18 | PS_MIO18_501 | 501 | MIO | - |
| A17 | PS_MIO20_501 | 501 | MIO | - |
| B17 | PS_MIO22_501 | 501 | MIO | - |
| A16 | PS_MIO24_501 | 501 | MIO | - |
| A15 | PS_MIO26_501 | 501 | MIO | - |
| C16 | PS_MIO28_501 | 501 | MIO | - |
| C15 | PS_MIO30_501 | 501 | MIO | - |
| A14 | PS_MIO32_501 | 501 | MIO | - |
| A12 | PS_MIO34_501 | 501 | MIO | - |
| A11 | PS_MIO36_501 | 501 | MIO | - |
| A10 | PS_MIO37_501 | 501 | MIO | - |
| C18 | PS_MIO39_501 | 501 | MIO | - |
| C17 | PS_MIO41_501 | 501 | MIO | - |
| A9 | PS_MIO43_501 | 501 | MIO | - |
| B15 | PS_MIO45_501 | 501 | MIO | - |
| B14 | PS_MIO47_501 | 501 | MIO | - |
| C12 | PS_MIO49_501 | 501 | MIO | - |
| B9 | PS_MIO51_501 | 501 | MIO | - |
| C11 | PS_MIO53_501 | 501 | MIO | - |
| E8 | PS_MIO13_500 | 500 | MIO | - |
| D9 | PS_MIO12_500 | 500 | MIO | - |
| C6 | PS_MIO11_500 | 500 | MIO | - |
| E9 | PS_MIO10_500 | 500 | MIO | - |
| B5 | PS_MIO9_500 | 500 | MIO | - |
| D5 | PS_MIO8_500 | 500 | MIO | - |
| D8 | PS_MIO7_500 | 500 | MIO | - |
| A5 | PS_MIO6_500 | 500 | MIO | - |
| A6 | PS_MIO5_500 | 500 | MIO | - |
| B7 | PS_MIO4_500 | 500 | MIO | - |
| D6 | PS_MIO3_500 | 500 | MIO | - |
| B8 | PS_MIO2_500 | 500 | MIO | - |
| A7 | PS_MIO1_500 | 500 | MIO | - |
| E6 | PS_MIO0_500 | 500 | MIO | - |
| B4 | PS_DDR_DRST_B_502 | 502 | DDR | - |
| C3 | PS_DDR_DQ0_502 | 502 | DDR | - |
| B3 | PS_DDR_DQ1_502 | 502 | DDR | - |
| A2 | PS_DDR_DQ2_502 | 502 | DDR | - |
| A4 | PS_DDR_DQ3_502 | 502 | DDR | - |
| A1 | PS_DDR_DM0_502 | 502 | DDR | - |
| C2 | PS_DDR_DQS_P0_502 | 502 | DDR | - |
| B2 | PS_DDR_DQS_N0_502 | 502 | DDR | - |
| D3 | PS_DDR_DQ4_502 | 502 | DDR | - |
| D1 | PS_DDR_DQ5_502 | 502 | DDR | - |
| C1 | PS_DDR_DQ6_502 | 502 | DDR | - |
| E1 | PS_DDR_DQ7_502 | 502 | DDR | - |
| E2 | PS_DDR_DQ8_502 | 502 | DDR | - |
| E3 | PS_DDR_DQ9_502 | 502 | DDR | - |
| G3 | PS_DDR_DQ10_502 | 502 | DDR | - |
| H3 | PS_DDR_DQ11_502 | 502 | DDR | - |
| F1 | PS_DDR_DM1_502 | 502 | DDR | - |
| G2 | PS_DDR_DQS_P1_502 | 502 | DDR | - |
| F2 | PS_DDR_DQS_N1_502 | 502 | DDR | - |
| J3 | PS_DDR_DQ12_502 | 502 | DDR | - |
| H2 | PS_DDR_DQ13_502 | 502 | DDR | - |
| H1 | PS_DDR_DQ14_502 | 502 | DDR | - |
| J1 | PS_DDR_DQ15_502 | 502 | DDR | - |
| F4 | PS_DDR_A14_502 | 502 | DDR | - |
| D4 | PS_DDR_A13_502 | 502 | DDR | - |
| E4 | PS_DDR_A12_502 | 502 | DDR | - |
| G4 | PS_DDR_A11_502 | 502 | DDR | - |
| F5 | PS_DDR_A10_502 | 502 | DDR | - |
| J4 | PS_DDR_A9_502 | 502 | DDR | - |
| K1 | PS_DDR_A8_502 | 502 | DDR | - |
| K4 | PS_DDR_A7_502 | 502 | DDR | - |
| L4 | PS_DDR_A6_502 | 502 | DDR | - |
| L1 | PS_DDR_A5_502 | 502 | DDR | - |
| M4 | PS_DDR_A4_502 | 502 | DDR | - |
| K3 | PS_DDR_A3_502 | 502 | DDR | - |
| G5 | PS_DDR_VRN_502 | 502 | DDR | - |
| H5 | PS_DDR_VRP_502 | 502 | DDR | - |
| L2 | PS_DDR_CKP_502 | 502 | DDR | - |
| M2 | PS_DDR_CKN_502 | 502 | DDR | - |
| M3 | PS_DDR_A2_502 | 502 | DDR | - |
| K2 | PS_DDR_A1_502 | 502 | DDR | - |
| N2 | PS_DDR_A0_502 | 502 | DDR | - |
| J5 | PS_DDR_BA2_502 | 502 | DDR | - |
| R4 | PS_DDR_BA1_502 | 502 | DDR | - |
| L5 | PS_DDR_BA0_502 | 502 | DDR | - |
| N5 | PS_DDR_ODT_502 | 502 | DDR | - |
| N1 | PS_DDR_CS_B_502 | 502 | DDR | - |
| N3 | PS_DDR_CKE_502 | 502 | DDR | - |
| M5 | PS_DDR_WE_B_502 | 502 | DDR | - |
| P5 | PS_DDR_CAS_B_502 | 502 | DDR | - |
| P4 | PS_DDR_RAS_B_502 | 502 | DDR | - |
| P1 | PS_DDR_DQ16_502 | 502 | DDR | - |
| P3 | PS_DDR_DQ17_502 | 502 | DDR | - |
| R3 | PS_DDR_DQ18_502 | 502 | DDR | - |
| R1 | PS_DDR_DQ19_502 | 502 | DDR | - |
| T1 | PS_DDR_DM2_502 | 502 | DDR | - |
| R2 | PS_DDR_DQS_P2_502 | 502 | DDR | - |
| T2 | PS_DDR_DQS_N2_502 | 502 | DDR | - |
| T4 | PS_DDR_DQ20_502 | 502 | DDR | - |
| U4 | PS_DDR_DQ21_502 | 502 | DDR | - |
| U2 | PS_DDR_DQ22_502 | 502 | DDR | - |
| U3 | PS_DDR_DQ23_502 | 502 | DDR | - |
| V1 | PS_DDR_DQ24_502 | 502 | DDR | - |
| Y3 | PS_DDR_DQ25_502 | 502 | DDR | - |
| W1 | PS_DDR_DQ26_502 | 502 | DDR | - |
| Y4 | PS_DDR_DQ27_502 | 502 | DDR | - |
| Y1 | PS_DDR_DM3_502 | 502 | DDR | - |
| W5 | PS_DDR_DQS_P3_502 | 502 | DDR | - |
| W4 | PS_DDR_DQS_N3_502 | 502 | DDR | - |
| Y2 | PS_DDR_DQ28_502 | 502 | DDR | - |
| W3 | PS_DDR_DQ29_502 | 502 | DDR | - |
| V2 | PS_DDR_DQ30_502 | 502 | DDR | - |
| V3 | PS_DDR_DQ31_502 | 502 | DDR | - |
| A8 | GND | NA | NA | - |
| A18 | GND | NA | NA | - |
| B1 | GND | NA | NA | - |
| B11 | GND | NA | NA | - |
| C4 | GND | NA | NA | - |
| C14 | GND | NA | NA | - |
| K11 | GND | NA | NA | - |
| D17 | GND | NA | NA | - |
| E10 | GND | NA | NA | - |
| E20 | GND | NA | NA | - |
| F3 | GND | NA | NA | - |
| F7 | GND | NA | NA | - |
| G10 | GND | NA | NA | - |
| G12 | GND | NA | NA | - |
| G16 | GND | NA | NA | - |
| H7 | GND | NA | NA | - |
| H9 | GND | NA | NA | - |
| H11 | GND | NA | NA | - |
| H13 | GND | NA | NA | - |
| H19 | GND | NA | NA | - |
| J2 | GND | NA | NA | - |
| J8 | GND | NA | NA | - |
| J12 | GND | NA | NA | - |
| K5 | GND | NA | NA | - |
| K7 | GND | NA | NA | - |
| C9 | GND | NA | NA | - |
| K13 | GND | NA | NA | - |
| K15 | GND | NA | NA | - |
| L8 | GND | NA | NA | - |
| L12 | GND | NA | NA | - |
| L18 | GND | NA | NA | - |
| M1 | GND | NA | NA | - |
| M7 | GND | NA | NA | - |
| M11 | GND | NA | NA | - |
| M13 | GND | NA | NA | - |
| N4 | GND | NA | NA | - |
| N8 | GND | NA | NA | - |
| N10 | GND | NA | NA | - |
| N12 | GND | NA | NA | - |
| N14 | GND | NA | NA | - |
| P7 | GND | NA | NA | - |
| P9 | GND | NA | NA | - |
| P11 | GND | NA | NA | - |
| P13 | GND | NA | NA | - |
| P17 | GND | NA | NA | - |
| R8 | GND | NA | NA | - |
| R12 | GND | NA | NA | - |
| R20 | GND | NA | NA | - |
| T3 | GND | NA | NA | - |
| T7 | GND | NA | NA | - |
| T13 | GND | NA | NA | - |
| U6 | GND | NA | NA | - |
| U16 | GND | NA | NA | - |
| V9 | GND | NA | NA | - |
| V19 | GND | NA | NA | - |
| W2 | GND | NA | NA | - |
| W12 | GND | NA | NA | - |
| Y5 | GND | NA | NA | - |
| Y15 | GND | NA | NA | - |
| G13 | VCCINT | NA | NA | - |
| H12 | VCCINT | NA | NA | - |
| J13 | VCCINT | NA | NA | - |
| K12 | VCCINT | NA | NA | - |
| L13 | VCCINT | NA | NA | - |
| M12 | VCCINT | NA | NA | - |
| N13 | VCCINT | NA | NA | - |
| P12 | VCCINT | NA | NA | - |
| R13 | VCCINT | NA | NA | - |
| J11 | VCCAUX | NA | NA | - |
| L11 | VCCAUX | NA | NA | - |
| N9 | VCCAUX | NA | NA | - |
| P10 | VCCAUX | NA | NA | - |
| R9 | VCCAUX | NA | NA | - |
| N11 | VCCAUX | NA | NA | - |
| K6 | VCCO_0 | 0 | NA | - |
| T8 | VCCO_13 | 13 | NA | - |
| U11 | VCCO_13 | 13 | NA | - |
| W7 | VCCO_13 | 13 | NA | - |
| Y10 | VCCO_13 | 13 | NA | - |
| N19 | VCCO_34 | 34 | NA | - |
| R15 | VCCO_34 | 34 | NA | - |
| T18 | VCCO_34 | 34 | NA | - |
| V14 | VCCO_34 | 34 | NA | - |
| W17 | VCCO_34 | 34 | NA | - |
| Y20 | VCCO_34 | 34 | NA | - |
| C19 | VCCO_35 | 35 | NA | - |
| F18 | VCCO_35 | 35 | NA | - |
| H14 | VCCO_35 | 35 | NA | - |
| J17 | VCCO_35 | 35 | NA | - |
| K20 | VCCO_35 | 35 | NA | - |
| M16 | VCCO_35 | 35 | NA | - |
| G11 | VCCBRAM | NA | NA | - |
| H10 | VCCBRAM | NA | NA | - |
| A3 | VCCO_DDR_502 | 502 | NA | - |
| D2 | VCCO_DDR_502 | 502 | NA | - |
| E5 | VCCO_DDR_502 | 502 | NA | - |
| G1 | VCCO_DDR_502 | 502 | NA | - |
| H4 | VCCO_DDR_502 | 502 | NA | - |
| L3 | VCCO_DDR_502 | 502 | NA | - |
| P2 | VCCO_DDR_502 | 502 | NA | - |
| R5 | VCCO_DDR_502 | 502 | NA | - |
| U1 | VCCO_DDR_502 | 502 | NA | - |
| V4 | VCCO_DDR_502 | 502 | NA | - |
| G8 | VCCPLL | NA | NA | - |
| G9 | VCCPAUX | NA | NA | - |
| F8 | VCCPAUX | NA | NA | - |
| H8 | VCCPAUX | NA | NA | - |
| K8 | VCCPAUX | NA | NA | - |
| M8 | VCCPAUX | NA | NA | - |
| G7 | VCCPINT | NA | NA | - |
| J7 | VCCPINT | NA | NA | - |
| L7 | VCCPINT | NA | NA | - |
| N7 | VCCPINT | NA | NA | - |
| P8 | VCCPINT | NA | NA | - |
| R7 | VCCPINT | NA | NA | - |
| B6 | VCCO_MIO0_500 | 500 | NA | - |
| D7 | VCCO_MIO0_500 | 500 | NA | - |
| A13 | VCCO_MIO1_501 | 501 | NA | - |
| B16 | VCCO_MIO1_501 | 501 | NA | - |
| D12 | VCCO_MIO1_501 | 501 | NA | - |
| E15 | VCCO_MIO1_501 | 501 | NA | - |
| H6 | PS_DDR_VREF0_502 | 502 | DDR | - |
| P6 | PS_DDR_VREF1_502 | 502 | DDR | - |
|  |  |  |  |  |
| Total Number of Pins |  400 |  |  |  |