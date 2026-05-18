# ZYNQ 硬件工程知识库

> 归属智能体：@H 硬件工程师
> 知识范围：XDC约束、引脚分配、时序约束、VHDL/Verilog、FPGA资源、RTL设计、原理图引脚、DDR3、PHY芯片、外设芯片(CH340/SP3232/GT917S)、电源复位等
> 生成日期：2026-05-18

---

## 1. Zynq-7000 SoC 硬件概览

### 1.1 器件架构与资源

【知识来源】
- 文档名称：《ds190-Zynq-7000-Overview.pdf》
- 核心出处：Zynq-7000 SoC集成双核/单核ARM Cortex-A9处理系统(PS)与28nm Xilinx可编程逻辑(PL)，PS与PL位于独立电源域
- 关键词标签：`ZYNQ` `SoC` `ARM` `Cortex-A9` `PS` `PL` `XC7Z020` `电源域`

**核心技术要点：**

- **PS-PL接口**：2x AXI 32-bit Master、2x AXI 32-bit Slave、4x AXI 64-bit/32-bit HP端口（直连DDR和OCM）、1x AXI 64-bit ACP、16根中断线
- **PL资源（XC7Z020）**：基于Artix-7，53,200个逻辑单元、106,400个Flip-Flop、4.9Mb Block RAM、220个DSP Slice、4个CMT（MMCM+PLL）
- **I/O分类**：HR I/O支持1.2V~3.3V，HP I/O支持1.2V~1.8V，每Bank 50个引脚，共用Vcco
- **MIO/EMIO**：PS提供54位MIO引脚直接连接外设，EMIO可将PS外设扩展至PL
- **外设映射**：Quad-SPI/NAND/NOR/SRAM/USB/SDIO/SPI/I2C/CAN/GPIO/GigE均可通过MIO或EMIO映射
- **电源管理**：PS与PL独立电源域，PS先启动管理PL配置；支持PL Power Off(Sleep)、PS Clock Gating、单处理器模式
- **时钟管理**：PS内3个PLL，PL内最多8个CMT（每个含1个MMCM+1个PLL）；6种时钟线类型（BUFG/BUFR/BUFIO/BUFH/BUFMR/高性能时钟）
- **复位系统**：外部/内部上电复位、热复位、看门狗复位、PL用户复位、软件/JTAG复位、安全违规复位

### 1.2 SelectIO与引脚特性

【知识来源】
- 文档名称：《ds190-Zynq-7000-Overview.pdf》
- 核心出处：I/O支持LVCMOS/LVDS/SSTL标准，SSTL支持DDR3最高1866Mb/s；内置可编程I/O延迟和SerDes
- 关键词标签：`SelectIO` `LVCMOS` `LVDS` `SSTL` `DDR3` `I/O标准` `Bank`

**核心技术要点：**

- 单端输出采用CMOS推挽结构，可配置压摆率和输出强度
- 每引脚可选弱上拉/弱下拉，差分对可配100欧内部终端电阻
- ISERDES支持1:2~1:8位宽转换，级联可达10/14位
- OSERDES支持2:1~8:1并行转串行
- GTX收发器最高12.5Gb/s（flip-chip封装），GTP最高6.25Gb/s（wire-bond封装）

---

## 2. XDC约束与时序约束

### 2.1 约束文件体系

【知识来源】
- 文档名称：《ug903-vivado-using-constraints.pdf》
- 核心出处：Vivado使用XDC（Xilinx Design Constraints）格式约束，基于SDC标准扩展，涵盖物理约束和时序约束
- 关键词标签：`XDC` `约束` `时序` `Tcl` `SDC` `引脚约束` `时钟约束` `物理约束`

**核心技术要点：**

- **约束优先级**：XDC约束按读取顺序应用，需注意约束文件加载顺序
- **物理约束**：引脚分配（set_property PACKAGE_PIN）、I/O标准（set_property IOSTANDARD）、驱动强度（DRIVE）、压摆率（SLEW）
- **时序约束**：时钟定义（create_clock）、时钟分组（set_clock_groups）、输入延迟（set_input_delay）、输出延迟（set_output_delay）、虚假路径（set_false_path）、多周期路径（set_multicycle_path）
- **CDC约束**：跨时钟域约束，包含总线偏斜约束（Bus Skew）
- **约束Tcl命令**：所有约束均通过Tcl命令在XDC文件中编写，Vivado综合和实现阶段分别读取

### 2.2 关键约束语法

```tcl
# 引脚分配
set_property PACKAGE_PIN <pin_name> [get_ports <port_name>]
# I/O标准
set_property IOSTANDARD <standard> [get_ports <port_name>]
# 时钟定义
create_clock -period <period_ns> -name <clk_name> [get_ports <clk_port>]
# 时钟分组（异步时钟）
set_clock_groups -asynchronous -group [get_clocks <clk_a>] -group [get_clocks <clk_b>]
# 输入/输出延迟
set_input_delay -clock <clk> -max <delay_ns> [get_ports <port>]
set_output_delay -clock <clk> -max <delay_ns> [get_ports <port>]
```

---

## 3. FPGA资源与RTL设计基础

### 3.1 7系列FPGA资源

【知识来源】
- 文档名称：《ds180_7_Series_Overview.pdf》
- 核心出处：7系列FPGA采用28nm HPL HKMG工艺，包含Artix/Kintex/Virtex/Zynq四个系列
- 关键词标签：`FPGA` `7系列` `LUT` `BRAM` `DSP` `时钟` `XC7Z020` `CLB`

**核心技术要点：**

- **CLB结构**：每个CLB含2个Slice，每个Slice含4个6-input LUT + 8个Flip-Flop + 进位链 + 多路复用器
- **LUT功能**：可配置为逻辑函数、分布式RAM（64x1或32x2）、移位寄存器（SRL32/SRL16）
- **Block RAM**：36Kb双端口BRAM，可拆分为2个18Kb；内置FIFO控制器，支持ECC（单bit纠错双bit检错）
- **DSP48E1 Slice**：25x18乘法器 + 48位累加器 + 25位预加器，最高741MHz
- **CMT**：每个含1个MMCM + 1个PLL，支持频率合成、相位偏移、抖动滤波

### 3.2 Verilog/VHDL RTL设计

【知识来源】
- 文档名称：《1_【正点原子】领航者ZYNQ之FPGA开发指南V3.3.pdf》
- 核心出处：Vivado工程创建、Verilog/VHDL编码、RTL仿真、综合实现、比特流生成、上板调试完整流程
- 关键词标签：`Vivado` `Verilog` `VHDL` `RTL` `IP核` `综合` `实现` `上板`

**核心技术要点：**

- **工程流程**：创建工程 -> 添加/编写RTL源文件 -> RTL分析 -> 综合 -> 实现 -> 生成比特流 -> 上板
- **编码规范**：推荐同步设计风格，避免锁存器（latch），时序逻辑使用非阻塞赋值（<=），组合逻辑使用阻塞赋值（=）
- **IP核使用**：通过Vivado IP Catalog例化IP核（Clocking Wizard、FIFO、Block Memory Generator等）
- **仿真验证**：使用Vivado Simulator进行行为仿真和时序仿真
- **调试工具**：ILA（集成逻辑分析仪）用于在线信号抓取，VIO用于虚拟IO

---

## 4. 原理图引脚与板级资源

### 4.1 领航者ZYNQ底板原理图

【知识来源】
- 文档名称：《领航者ZYNQ底板原理图_V3.6.pdf》
- 核心出处：领航者ZYNQ开发板底板V3.6完整原理图，涵盖HDMI/以太网/SD卡/USB/UART/I2C/SPI/电源/复位等所有外设接口
- 关键词标签：`引脚` `原理图` `HDMI` `以太网` `SD卡` `USB` `UART` `I2C` `SPI` `电源` `复位`

**核心技术要点：**

- **ZYNQ核心**：XC7Z020CLG400-1，CLG400封装
- **HDMI输出**：通过PL端引脚连接HDMI发送器，含HDMI_HPD热插拔检测
- **以太网**：板载YT8531C PHY芯片，RGMII接口连接PS端GigE0
- **USB接口**：PS端USB ULPI PHY
- **UART**：PS端UART0/UART1，通过CH340 USB转串口芯片引出
- **SD卡**：PS端SDIO0接口
- **I2C/SPI**：PS端I2C0/I2C1、SPI0/SPI1通过EMIO或MIO引出
- **电源系统**：多路DC-DC转换器提供1.0V(PL核心)/1.0V(PS)/1.8V(PL I/O)/3.3V(PS I/O)等
- **复位电路**：包含系统复位按键和复位芯片

### 4.2 板级快速体验

【知识来源】
- 文档名称：《【正点原子】领航者ZYNQ开发板用户快速体验3.1.pdf》
- 核心出处：开发板硬件测试流程，包括LED/按键/串口/EEPROM读写/SD卡/以太网/音频等外设测试
- 关键词标签：`快速体验` `硬件测试` `LED` `按键` `串口` `EEPROM` `SD卡`

**核心技术要点：**

- 板载外设测试：LED、按键、蜂鸣器、串口通信、EEPROM读写、SD卡读写、以太网通信、音频输入输出
- 硬件连接确认：通过串口终端观察测试结果验证各外设功能正常

---

## 5. DDR3 SDRAM 硬件设计

### 5.1 DDR3芯片规格

【知识来源】
- 文档名称：《4Gb_DDR3_E_Die_component_Datasheet.PDF》
- 核心出处：NT5CB512M8EQ/NT5CB256M16ER DDR3(L) 4Gb SDRAM，8n预取架构，支持x8/x16位宽
- 关键词标签：`DDR3` `SDRAM` `时序` `初始化` `MIG` `XDC` `引脚`

**核心技术要点：**

- **器件规格**：4Gb密度，组织为512Mx8或256Mx16，78-Ball封装
- **关键信号**：Bank地址(BA0-BA2)、行地址(A0-A15)、列地址、自动预充电(A10/AP)、突发长度切换(A12/BC)
- **初始化时序**：上电后需严格遵循DDR3初始化序列（复位释放 -> CKE使能 -> NOP -> ZQCL -> MRS等）
- **刷新要求**：标准刷新率8192次/64ms，高温(>85C)需2x刷新（3.9us间隔）
- **MIG接口**：通过Xilinx MIG IP核连接，需配置XDC约束（引脚分配、I/O标准SSTL-15、ODT、时序约束）
- **引脚分配**：地址/控制/数据/时钟/STROBE/DQS/DM信号需按Bank规则分配到HR I/O Bank

---

## 6. 以太网PHY芯片

### 6.1 RTL8211E千兆以太网PHY

【知识来源】
- 文档名称：《RTL8211E.pdf》
- 核心出处：RTL8211E集成10/100/1000M以太网收发器，支持RGMII/SGMII/MII/GMII MAC接口
- 关键词标签：`RTL8211` `PHY` `RGMII` `SGMII` `引脚` `寄存器` `时序`

**核心技术要点：**

- **接口模式**：RGMII（精简GMII，需125MHz时钟）、SGMII（串行GMII）、MII（10/100M）、GMII（千兆）
- **RGMII时序**：在RGMII模式下，TX/RX时钟与数据需满足1.5ns~2.0ns的延迟补偿要求
- **MDIO/MDC**：管理接口用于读写PHY寄存器，MDC最高2.5MHz
- **LED引脚**：支持速率/活动/双工状态LED指示
- **复位时序**：硬件复位后需等待PHY内部初始化完成（约数十毫秒）

### 6.2 YT8521千兆以太网PHY

【知识来源】
- 文档名称：《YT8521SH-CA_YT8521SC-CA_Datasheet_v1.02.pdf》《YT8521S_reference_design_V1.2_20200612.pdf》
- 核心出处：YT8521SH-CA/YT8521SC-CA集成10/100/1000M以太网收发器，支持RGMII/SGMII/SFP
- 关键词标签：`YT8521` `PHY` `RGMII` `引脚` `寄存器` `时序` `复位` `LED`

**核心技术要点：**

- **封装引脚**：QFN-40封装，支持RGMII MAC接口和SGMII MAC接口
- **参考设计要点**：
  - RGMII TX/RX需加延迟线补偿（PCB走线或PHY内部延迟）
  - LED配置引脚需上拉/下拉电阻设定工作模式
  - 复位引脚需外接RC电路或由GPIO控制
  - 25MHz晶振连接XTAL1/XTAL2引脚
- **上拉下拉配置**：通过引脚上拉/下拉选择PHY工作模式（RGMII/SGMII、速率自协商等）

### 6.3 裕太以太网PHY软件开发

【知识来源】
- 文档名称：《裕太以太网phy芯片软件开发说明-20210224(1).pdf》
- 核心出处：YT PHY芯片Linux驱动开发指南，包含设备树配置、MDIO寄存器读写、RGMII接口时序
- 关键词标签：`以太网` `PHY` `Linux` `设备树` `RGMII` `驱动` `MDIO`

**核心技术要点：**

- **设备树配置**：需在DTS中配置PHY节点（compatible、reg地址、reset-gpios等）
- **MDIO访问**：通过Linux MDIO总线读写PHY寄存器（0x00~0x1F基本寄存器，0x1E扩展页选择）
- **RGMII时序约束**：TX/RX延迟需在设备树中通过`tx-delay`/`rx-delay`属性配置
- **PHY层统计**：收发包计数通过MDIO寄存器读取

---

## 7. 外设芯片

### 7.1 CH340 USB转串口芯片

【知识来源】
- 文档名称：《CH340.pdf》
- 核心出处：CH340是USB总线转接芯片，实现USB转串口/红外/打印口，支持全速USB（12Mbps）
- 关键词标签：`CH340` `USB` `串口` `UART` `引脚` `电平`

**核心技术要点：**

- **封装**：SSOP-20（5.30mm宽，209mil间距）和SOP-16
- **电源**：支持5V和3.3V供电
- **引脚功能**：TXD（串行数据输出）、RXD（串行数据输入，内置上下拉）、CTS#/DSR#/RI#/DCD#/DTR#/RTS#（MODEM联络信号）、NOS#（禁止USB挂起）
- **波特率**：支持300bps~2Mbps
- **电平兼容**：CH340G的TXD/RXD为3.3V电平，可直接连接ZYNQ PS端UART
- **驱动兼容**：软件兼容CH341，可直接使用CH341驱动

### 7.2 SP3232 RS-232收发器

【知识来源】
- 文档名称：《SP3232.pdf》
- 核心出处：SP3232是3.3V供电的RS-232收发器，含2个驱动器和2个接收器，支持120kbps数据速率
- 关键词标签：`SP3232` `RS-232` `串口` `UART` `引脚` `电平`

**核心技术要点：**

- **供电**：单3.3V供电，内部电荷泵生成RS-232所需的双极性电压
- **通道**：2个Driver（TTL->RS-232）+ 2个Receiver（RS-232->TTL）
- **数据速率**：最高120kbps
- **关断模式**：SHDN引脚拉低进入关断，电流降至<1uA
- **负载电容**：最大负载电容2330pF
- **应用连接**：TTL端连接ZYNQ UART TX/RX，RS-232端连接DB9连接器

### 7.3 GT917S 触控芯片

【知识来源】
- 文档名称：《GT917S编程指南.pdf》
- 核心出处：GT917S电容触控控制器，通过I2C接口与主控通信，支持多点触控和手势识别
- 关键词标签：`GT917S` `触控` `I2C` `寄存器` `中断` `时序`

**核心技术要点：**

- **通信接口**：I2C从设备模式，支持标准模式(100kHz)和快速模式(400kHz)
- **中断信号**：INT引脚低电平有效，触控事件发生时拉低通知主控
- **坐标读取**：读取0x814E获取手势/触摸状态，0x814D获取触摸点数，0xBDA8~0xBEA7获取坐标数据
- **寄存器映射**：0x8040~0x8042（控制命令）、0x814A~0x814F（状态/坐标）、0x81A8（状态寄存器）
- **工作模式**：Normal模式、Gesture手势模式、Sleep休眠模式、HotKnot传输模式
- **上电初始化**：需通过I2C发送配置参数（分辨率、通道数、灵敏度等）
- **坐标校验**：支持8位校验和方式，主控读取坐标后需校验数据完整性

---

## 8. ES8388 音频CODEC

### 8.1 芯片规格

【知识来源】
- 文档名称：《es8388.pdf》
- 核心出处：ES8388是高性能低功耗立体声音频CODEC，集成耳机放大器，支持I2S/Left-Justified/DSP/PCM模式
- 关键词标签：`ES8388` `CODEC` `I2S` `I2C` `寄存器` `音频`

**核心技术要点：**

- **音频规格**：24-bit，8kHz~96kHz采样率，ADC SNR 98dB，DAC SNR 100dB
- **供电**：1.8V~3.3V工作电压，播放功耗7mW
- **接口**：I2S数字音频接口（Master/Slave）、I2C控制接口
- **输出**：内置耳机放大器（无电容模式），支持立体声增强、低音/高音调节
- **时钟**：支持256Fs/384Fs/USB 12MHz/24MHz系统时钟
- **应用**：MP3/MP4/PMP、无线音频设备、便携式媒体播放器

---

## 9. 硬件设计检查清单

### 9.1 XDC约束检查

- [ ] 所有PL端引脚PACKAGE_PIN已正确分配
- [ ] IOSTANDARD与板级电平匹配（LVCMOS33/LVCMOS18/SSTL15等）
- [ ] 差分对引脚分配在相邻P/N对上
- [ ] 时钟引脚使用MRCC/SRCC专用时钟输入
- [ ] DDR3引脚分配遵守Bank规则（地址/控制/数据分组）
- [ ] 所有时钟已定义create_clock约束
- [ ] 异步时钟间已设置set_clock_groups
- [ ] 跨时钟域路径已正确约束

### 9.2 电源与复位检查

- [ ] PS与PL电源域独立供电
- [ ] 上电时序满足PS先于PL要求
- [ ] 复位电路正确（复位芯片/按键/RC延迟）
- [ ] DDR3电源（1.5V VDDQ/VTT）稳定
- [ ] PHY芯片复位时序满足要求

### 9.3 外设接口检查

- [ ] UART/CH340电平匹配（3.3V TTL）
- [ ] I2C上拉电阻正确（4.7K典型值）
- [ ] SPI片选信号极性正确
- [ ] RGMII延迟补偿配置
- [ ] HDMI_HPD信号连接
- [ ] GT917S INT中断引脚连接
