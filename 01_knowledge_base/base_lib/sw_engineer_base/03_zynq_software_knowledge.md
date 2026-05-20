# ZYNQ 软件工程知识库 -- 嵌入式系统开发

> 本知识库面向 @S 软件工程师，聚焦 ZYNQ SoC 嵌入式软件开发核心技术领域。
> 知识来源：项目粗加工提取数据中归属 @S 的 PDF 文档结构化精炼。

---

## 目录

1. [ZYNQ SoC 架构概览](#1-zynq-soc-架构概览)
2. [ARM 裸机开发](#2-arm-裸机开发)
3. [Vitis 嵌入式开发环境](#3-vitis-嵌入式开发环境)
4. [PS-PL 通信与 AXI 总线](#4-ps-pl-通信与-axi-总线)
5. [Boot 启动流程](#5-boot-启动流程)
6. [AMP 双核开发](#6-amp-双核开发)
7. [外设驱动开发](#7-外设驱动开发)
8. [LwIP 网络协议栈](#8-lwip-网络协议栈)
9. [以太网 PHY 驱动](#9-以太网-phy-驱动)
10. [FatFs 文件系统](#10-fatfs-文件系统)
11. [Linux 设备树与驱动](#11-linux-设备树与驱动)
12. [触控芯片 I2C 驱动](#12-触控芯片-i2c-驱动)
13. [PYNQ 框架中的 Linux 驱动层](#13-pynq-框架中的-linux-驱动层)

---

## 1. ZYNQ SoC 架构概览

### 1.1 处理系统 (PS) 核心架构

【知识来源】
- 文档名称：《ds190-Zynq-7000-Overview.pdf》
- 核心出处：Zynq-7000 SoC 集成双核/单核 ARM Cortex-A9 MPCore 处理器、内存接口、I/O 外设和互联模块，与 28nm 可编程逻辑 (PL) 共处单一器件
- 关键词标签：`ZYNQ` `SoC` `ARM` `Cortex-A9` `PS` `PL` `XC7Z020` `架构`

**核心技术要点：**

- **APU (Application Processor Unit)**：双核 ARM Cortex-A9 MPCore，主频最高 1GHz (-2 速度等级)，支持对称/非对称多处理 (SMP/AMP)
- **内存子系统**：多协议 DDR 控制器，支持 DDR3/DDR3L/LPDDR2，16/32 位宽，最高 1333 Mb/s；256KB 片上 RAM (OCM)
- **缓存**：每核 32KB L1 指令缓存 + 32KB L1 数据缓存，共享 512KB L2 缓存
- **MMU**：集成内存管理单元，支持 TrustZone 安全模式
- **PS-PL 接口**：2x AXI 32-bit Master、2x AXI 32-bit Slave、4x AXI 64/32-bit HP Slave、1x AXI 64-bit ACP Slave
- **电源管理**：PS 与 PL 独立电源域，支持 PL 电源关闭、单处理器模式、时钟门控等省电模式
- **时钟系统**：3 个 PLL，APU/DDR/IOP 三个时钟域可独立配置

### 1.2 PS 外设资源

【知识来源】
- 文档名称：《ds190-Zynq-7000-Overview.pdf》
- 核心出处：PS 包含丰富的 I/O 外设：2x USB 2.0 OTG、2x 千兆以太网 MAC (IEEE 802.3/1588)、2x SD/SDIO、2x SPI、2x I2C、2x CAN 2.0B、2x UART、8 通道 DMA、3 个看门狗定时器、2 个三重定时器/计数器、通用中断控制器 (GIC)
- 关键词标签：`外设` `USB` `以太网` `SDIO` `SPI` `I2C` `CAN` `UART` `DMA` `GIC`

**核心技术要点：**

- **MIO (Multiplexed I/O)**：最多 54 个 PS 引脚，软件可配置连接任意内部外设
- **EMIO (Extendable MIO)**：通过 PL 引脚扩展外设接口，最多 64 个 GPIO
- **以太网 MAC**：支持 RGMII v2.0、GMII、MII、SGMII、1000BASE-X，支持 IEEE 1588 PTP
- **DMA 控制器**：8 通道，支持 memory-to-memory、memory-to-peripheral、scatter-gather

---

## 2. ARM 裸机开发

### 2.1 裸机驱动架构

【知识来源】
- 文档名称：《ug821-zynq-7000-swdev.pdf》
- 核心出处：Zynq-7000 AP SoC 提供完整的裸机 (Standalone) BSP，包含所有 PS 外设驱动，基于 Xilinx Standalone BSP (UG652)
- 关键词标签：`裸机` `BSP` `Standalone` `驱动架构` `Xil_printf` `中断`

**核心技术要点：**

- **Standalone BSP**：Xilinx 提供的裸机板级支持包，包含所有 PS 外设驱动（GPIO、UART、SPI、I2C、Timer、DMA 等）
- **驱动 API 体系**：所有驱动遵循统一的 `Xxx_Initialize()` / `Xxx_Setxxx()` / `Xxx_Read()` / `Xxx_Write()` 命名规范
- **中断框架**：基于 GIC (Generic Interrupt Controller)，支持私有外设中断 (PPI)、软件生成中断 (SGI)、共享外设中断 (SPI)
- **调试支持**：ARM CoreSight 架构，支持 ETB、PTM、ITM，双 JTAG 端口（ARM DS-5 + Xilinx ChipScope 共享）

### 2.2 GPIO 裸机驱动

【知识来源】
- 文档名称：《2_【正点原子】领航者ZYNQ之嵌入式Vitis开发指南v1_2.pdf》
- 核心出处：PS GPIO 通过 MIO 和 EMIO 两种方式访问外设。MIO 引脚编号 0-53，EMIO 引脚编号 54-117。使用 XGpioPs 驱动库操作
- 关键词标签：`GPIO` `MIO` `EMIO` `XGpioPs` `引脚控制` `LED` `按键`

**核心技术要点：**

- **驱动初始化**：`XGpioPs_Config *Config = XGpioPs_LookupConfig(GPIO_DEVICE_ID); XGpioPs_CfgInitialize(&Gpio, Config, Config->BaseAddr);`
- **方向设置**：`XGpioPs_SetDirectionPin(&Gpio, PinNumber, Direction);` 其中 1=输出，0=输入
- **输出使能**：`XGpioPs_SetOutputEnablePin(&Gpio, PinNumber, 1);`
- **读写操作**：`XGpioPs_WritePin(&Gpio, PinNumber, Value);` / `XGpioPs_ReadPin(&Gpio, PinNumber);`
- **EMIO 使用**：EMIO GPIO 编号从 54 开始，需要通过 PL 引脚约束分配物理引脚位置

### 2.3 UART 串口驱动

【知识来源】
- 文档名称：《2_【正点原子】领航者ZYNQ之嵌入式Vitis开发指南v1_2.pdf》
- 核心出处：ZYNQ PS 内置 2 个 UART 控制器，通过 MIO 引脚连接。领航者开发板使用 MIO14/15 连接 UART0，经 CH340 USB 转串口芯片与 PC 通信
- 关键词标签：`UART` `串口` `MIO14` `MIO15` `CH340` `波特率` `115200`

**核心技术要点：**

- **串口配置**：波特率 115200，8 数据位，1 停止位，无校验
- **打印函数**：使用 `print()` (xil_printf.h) 而非标准 `printf()`，需包含 `xil_printf.h`
- **初始化**：`init_platform()` 使能 caches 和初始化 UART

### 2.4 中断系统

【知识来源】
- 文档名称：《2_【正点原子】领航者ZYNQ之嵌入式Vitis开发指南v1_2.pdf》
- 核心出处：ZYNQ 中断控制器 (GIC) 支持三种中断来源：PPI (私有外设中断)、SGI (软件生成中断)、SPI (共享外设中断)。GPIO 中断通过 SPI 连接到 GIC
- 关键词标签：`中断` `GIC` `PPI` `SGI` `SPI` `FIQ` `IRQ` `按键中断`

**核心技术要点：**

- **中断配置流程**：设置 GPIO 中断类型 -> 注册中断处理函数 -> 使能 GIC 中断 -> 使能 GPIO 中断
- **中断处理函数**：通过 `XScuGic_Connect()` 连接中断 ID 到处理函数，`XScuGic_Enable()` 使能

---

## 3. Vitis 嵌入式开发环境

### 3.1 Vitis 统一软件平台

【知识来源】
- 文档名称：《2_【正点原子】领航者ZYNQ之嵌入式Vitis开发指南v1_2.pdf》
- 核心出处：Vitis 统一软件平台（前身 Xilinx SDK，从 Vivado 2019.2 整合），支持 C/C++/Python 开发嵌入式系统，可运行在 FPGA、SoC、Versal ACAP 上
- 关键词标签：`Vitis` `SDK` `嵌入式` `C/C++` `BSP` `XSA` `ELF`

**核心技术要点：**

- **开发流程**：Vivado 创建工程 -> IP Integrator 创建 Processing System -> 导出硬件 (XSA) -> Vitis 创建平台 -> 创建应用工程 -> 编译下载
- **硬件导出**：`File > Export > Export hardware`，使用 PL 资源时需勾选 `Include bitstream`
- **应用工程**：支持 Empty Application 和各种模板（Hello World、GPIO 示例等）
- **BSP 自动生成**：基于 XSA 文件自动生成板级支持包，包含所有外设驱动
- **调试**：支持单应用调试 (Single Application Debugger)、系统调试

### 3.2 嵌入式最小系统搭建

【知识来源】
- 文档名称：《2_【正点原子】领航者ZYNQ之嵌入式Vitis开发指南v1_2.pdf》
- 核心出处：ZYNQ 嵌入式最小系统 = ARM Cortex-A9 + DDR3 + UART。在 IP Integrator 中添加 ZYNQ7 Processing System，配置 UART0 (MIO14/15)，生成 Block Design
- 关键词标签：`最小系统` `Processing System` `Block Design` `DDR3` `IP Integrator`

**核心技术要点：**

- **器件选型**：领航者核心板 XC7Z020 (clg400, -2 速度等级) 或 XC7Z010 (clg400, -1 速度等级)
- **PS 配置**：通过 ZYNQ7 Processing System 配置界面设置 UART、GPIO、时钟、DDR 等参数
- **时钟配置**：APU 时钟、DDR 时钟、外设时钟可独立配置，有频率范围约束
- **PS-PL 接口裁剪**：不需要 PL 交互时可关闭 FCLK_CLK0、FCLK_RESET0_N、GP Master AXI Interface

---

## 4. PS-PL 通信与 AXI 总线

### 4.1 AXI 总线协议体系

【知识来源】
- 文档名称：《ds190-Zynq-7000-Overview.pdf》《2_【正点原子】领航者ZYNQ之嵌入式Vitis开发指南v1_2.pdf》
- 核心出处：PS 与 PL 之间通过 AMBA AXI 互联通信，包含 9 路 AXI 接口：4x HP Master、2x GP Master、2x GP Slave、1x ACP Slave
- 关键词标签：`AXI` `AXI4` `AXI4-Lite` `AXI4-Stream` `HP` `GP` `ACP` `PS-PL`

**核心技术要点：**

- **AXI4**：支持突发传输，用于处理器访问存储器等高速数据传输
- **AXI4-Lite**：简化版，单数据传输，用于访问低速外设寄存器
- **AXI4-Stream**：无地址接口，主从设备间连续数据流，用于视频、高速 AD、DMA 等
- **HP 端口**：64/32 位可配置，直接访问 DDR 和 OCM，高性能数据通道
- **GP 端口**：32 位，通用目的，用于少量数据传输和 IP 控制
- **ACP 端口**：64 位，缓存一致性端口，PL 加速器可直接访问 CPU 缓存

### 4.2 AXI GPIO IP 控制

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：AXI GPIO IP 通过 AXI4-Lite 接口连接到 PS，提供双通道 GPIO 控制。每个通道可配置方向和位宽，支持输入/输出/双向模式
- 关键词标签：`AXI GPIO` `AXI4-Lite` `IP核` `寄存器` `通道`

**核心技术要点：**

- **寄存器空间**：GPIO_DATA (偏移 0x0) 数据寄存器，GPIO_TRI (偏移 0x4) 三态寄存器
- **三态控制**：GPIO_TRI 位为 0 配置为输出，位为 1 配置为输入
- **驱动函数**：`XGpio_Initialize()`、`XGpio_SetDataDirection()`、`XGpio_DiscreteWrite()`、`XGpio_DiscreteRead()`

### 4.3 AXI DMA 数据传输

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：AXI DMA IP 通过 AXI Stream 接口连接 PL IP，通过 HP 端口访问 DDR。支持简单模式和 Scatter-Gather 模式。DMA 传输需设置 TLAST 信号
- 关键词标签：`AXI DMA` `Scatter-Gather` `HP端口` `中断` `缓冲区`

**核心技术要点：**

- **DMA 通道**：读通道 (S2MM) 和写通道 (MM2S)
- **最大事务大小**：默认 14 位 (16KB)，可在 Vivado 中增大
- **中断控制器**：DMA 需配合 AXI Interrupt Controller IP，连接到 ZYNQ IRQ_F2P
- **数据流**：input_buffer -> DMA sendchannel -> AXI Stream -> PL IP -> DMA recvchannel -> output_buffer

---

## 5. Boot 启动流程

### 5.1 多阶段启动过程

【知识来源】
- 文档名称：《ug821-zynq-7000-swdev.pdf》
- 核心出处：Zynq-7000 采用多阶段启动过程。BootROM (Stage-0) 从启动设备加载 FSBL 到 OCM，FSBL (Stage-1) 初始化 PS 外设并加载第二阶段引导程序或裸机应用
- 关键词标签：`Boot` `BootROM` `FSBL` `OCM` `U-Boot` `Bootgen` `BIF`

**核心技术要点：**

- **启动模式**：PS Master Non-secure Boot、PS Master Secure Boot、JTAG/PJTAG Boot
- **启动设备**：NAND、NOR、Quad-SPI、SD、JTAG
- **FSBL 大小限制**：加载到 OCM 的 FSBL 最大 192KB（OCM 总共 256KB）
- **FSBL 职责**：初始化 PS 配置数据、编程 PL bitstream、加载第二阶段引导程序
- **Bootgen 工具**：将 FSBL、bitstream、U-Boot、应用等分区打包为 boot image，由 BIF 文件驱动

### 5.2 安全启动

【知识来源】
- 文档名称：《ug821-zynq-7000-swdev.pdf》
- 核心出处：安全启动支持 AES-256 加密和 RSA-2048 认证。密钥存储在 eFUSE 或 BBRAM 中。支持 Fallback 机制，主镜像损坏时自动切换到备用镜像
- 关键词标签：`安全启动` `AES` `RSA` `eFUSE` `BBRAM` `认证` `加密` `Fallback`

**核心技术要点：**

- **加密流程**：BootROM 使用 eFUSE/BBRAM 中的 AES 密钥解密 FSBL
- **认证流程**：使用 RSA 公钥认证 (PPK/SPK 层级密钥体系)
- **Fallback**：支持非安全 Fallback 和 RSA-only Fallback，BootROM 搜索下一个有效镜像
- **Multiboot**：支持多镜像切换，通过 `calculate_multiboot()` API 实现

### 5.3 U-Boot 引导加载器

【知识来源】
- 文档名称：《ug821-zynq-7000-swdev.pdf》
- 核心出处：U-Boot 作为第二阶段引导加载器，支持从 Ethernet、Flash、SD/MMC、USB 加载和执行镜像，提供命令解释器
- 关键词标签：`U-Boot` `引导加载器` `Linux` `命令行` `网络启动`

**核心技术要点：**

- **U-Boot 功能**：从多种介质加载镜像、内存读写命令、网络操作 (ping 等)
- **Linux 启动链**：BootROM -> FSBL -> U-Boot -> Linux Kernel -> RootFS

---

## 6. AMP 双核开发

### 6.1 非对称多处理架构

【知识来源】
- 文档名称：《ug821-zynq-7000-swdev.pdf》
- 核心出处：AMP (Asymmetric Multiprocessing) 模式下，每个 CPU 执行不同的操作系统镜像，共享同一物理内存。通常一个运行 Linux（网络/UI），另一个运行裸机或 RTOS（实时控制）
- 关键词标签：`AMP` `双核` `SMP` `非对称` `共享内存` `实时` `Linux`

**核心技术要点：**

- **SMP vs AMP**：SMP 对程序员透明，由 OS 自动管理多核；AMP 由程序员指定 CPU 执行进程
- **内存共享**：两个 CPU 共享 DDR 物理内存，需通过软件协议协调访问
- **通信机制**：共享内存、中断 (SGI)、软件事件
- **启动方式**：CPU0 先启动并加载 CPU1 的代码到指定内存地址，然后释放 CPU1

---

## 7. 外设驱动开发

### 7.1 I2C 驱动

【知识来源】
- 文档名称：《ds190-Zynq-7000-Overview.pdf》
- 核心出处：PS 包含 2 个主从 I2C 接口控制器，支持标准模式 (100kHz) 和快速模式 (400kHz)，通过 MIO 或 EMIO 引出
- 关键词标签：`I2C` `主从` `100kHz` `400kHz` `MIO` `EMIO`

**核心技术要点：**

- **I2C 控制器**：支持 7 位和 10 位地址模式，支持多主模式
- **驱动 API**：`XIic_Initialize()`、`XIic_Start()`、`XIic_Send()`、`XIic_Recv()`

### 7.2 SPI 驱动

【知识来源】
- 文档名称：《ds190-Zynq-7000-Overview.pdf》
- 核心出处：PS 包含 2 个全双工 SPI 端口，每个支持 3 个片选信号。支持 1/2/4 线模式
- 关键词标签：`SPI` `全双工` `片选` `Quad-SPI` `Flash`

**核心技术要点：**

- **Quad-SPI**：支持 1/2/4 线 SPI NOR Flash，用于启动和存储
- **驱动 API**：`XSpi_Initialize()`、`XSpi_Transfer()`、`XSpi_SetSlaveSelect()`

### 7.3 定时器驱动

【知识来源】
- 文档名称：《ds190-Zynq-7000-Overview.pdf》
- 核心出处：PS 包含 2 个三重定时器/计数器 (TTC) 和 3 个看门狗定时器 (WDT)。TTC 每个包含 3 个独立计数器，支持多种时钟模式
- 关键词标签：`定时器` `TTC` `WDT` `看门狗` `计数器` `PWM`

**核心技术要点：**

- **TTC 功能**：定时中断、事件计数、PWM 生成
- **WDT 功能**：CPU0/CPU1 各一个私有 WDT + 一个系统 WDT

### 7.4 音频编解码器 WM8960 驱动

【知识来源】
- 文档名称：《2_【正点原子】领航者ZYNQ之嵌入式Vitis开发指南v1_2.pdf》
- 核心出处：WM8960 音频编解码器通过 I2S 接口连接 ZYNQ PS，I2S 音频数据接口和 I2C 控制接口
- 关键词标签：`WM8960` `I2S` `音频` `编解码器` `DAC` `ADC`

**核心技术要点：**

- **I2S 接口**：PS 的 I2S 控制器通过 EMIO 连接 WM8960
- **I2C 配置**：通过 I2C 总线配置 WM8960 的寄存器（音量、采样率、输入输出通道等）

---

## 8. LwIP 网络协议栈

### 8.1 LwIP 协议栈架构

【知识来源】
- 文档名称：《LwIP协议栈的设计与实现_中文译稿.pdf》
- 核心出处：LwIP (Lightweight IP) 是专为嵌入式系统设计的轻量级 TCP/IP 协议栈，具有小代码量、低 RAM 占用的特点，支持 IP、ICMP、UDP、TCP、DHCP、ARP 等协议
- 关键词标签：`LwIP` `TCP/IP` `UDP` `DHCP` `ARP` `Socket` `内存管理` `嵌入式网络`

**核心技术要点：**

- **设计目标**：减少 RAM 使用（约几十 KB），适合资源受限的嵌入式系统
- **协议支持**：IPv4/IPv6、ICMP、UDP、TCP、DHCP、ARP、IGMP、AUTOIP
- **API 接口**：提供 Raw API (回调机制) 和 Socket API (类 BSD 接口)
- **内存管理**：pbuf (packet buffer) 管理机制，支持池分配和动态分配
- **网络接口抽象**：netif 结构体抽象物理网络接口，支持以太网、PPP 等

### 8.2 Socket 编程

【知识来源】
- 文档名称：《LwIP协议栈的设计与实现_中文译稿.pdf》
- 核心出处：LwIP 的 Socket API 兼容标准 BSD Socket，支持 `socket()`、`bind()`、`listen()`、`accept()`、`connect()`、`send()`、`recv()` 等标准调用
- 关键词标签：`Socket` `BSD` `TCP服务器` `UDP` `send` `recv` `connect`

**核心技术要点：**

- **TCP 通信**：支持服务器模式 (bind/listen/accept) 和客户端模式 (connect)
- **UDP 通信**：无连接数据报传输，适合实时性要求高的场景
- **回调机制**：Raw API 使用回调函数处理网络事件，效率更高但编程复杂度更大

---

## 9. 以太网 PHY 驱动

### 9.1 裕太以太网 PHY 芯片

【知识来源】
- 文档名称：《裕太以太网phy芯片软件开发说明-20210224(1).pdf》
- 核心出处：裕太电子以太网 PHY 芯片（YT8521 系列）支持 RGMII 接口，兼容 Linux 驱动框架。驱动通过 MDIO/MDC 接口配置 PHY 寄存器
- 关键词标签：`以太网` `PHY` `RGMII` `MDIO` `Linux驱动` `设备树` `裕太`

**核心技术要点：**

- **接口协议**：RGMII (Reduced Gigabit Media Independent Interface)，125MHz 时钟双倍数据速率
- **MDIO 管理**：通过 PS 的 MDIO 接口读写 PHY 寄存器，配置速率、双工模式、自协商等
- **Linux 设备树**：在设备树中描述 PHY 节点，绑定对应驱动

### 9.2 RTL8211E 以太网 PHY

【知识来源】
- 文档名称：《RTL8211E.pdf》
- 核心出处：Realtek RTL8211E 千兆以太网 PHY 收发器，支持 RGMII/SGMII/MII/RMII 接口，集成 10/100/1000M 收发器
- 关键词标签：`RTL8211E` `千兆` `RGMII` `SGMII` `Realtek` `PHY`

**核心技术要点：**

- **支持速率**：10Mbps/100Mbps/1000Mbps
- **自协商**：支持 IEEE 802.3 自协商
- **LED 配置**：可配置 LED 活动指示模式

---

## 10. FatFs 文件系统

### 10.1 FatFs 概述

【知识来源】
- 文档名称：《FATFS浅谈.pdf》
- 核心出处：FatFs 是一个通用的 FAT 文件系统模块，专为小型嵌入式系统设计，支持 FAT12/FAT16/FAT32，提供开放、可移植的 API
- 关键词标签：`FatFs` `FAT32` `SD卡` `文件系统` `API` `读写` `嵌入式`

**核心技术要点：**

- **API 函数**：`f_open()`、`f_read()`、`f_write()`、`f_close()`、`f_lseek()`、`f_opendir()`、`f_readdir()`、`f_stat()`、`f_mkdir()`
- **存储介质**：SD 卡 (通过 SDIO 控制器)、SPI Flash、USB 等
- **配置选项**：通过 `ffconf.h` 配置代码页、长文件名支持、Unicode 支持等
- **可移植性**：与硬件平台无关，只需实现底层磁盘 I/O 接口 (`disk_initialize()`、`disk_read()`、`disk_write()`)

---

## 11. Linux 设备树与驱动

### 11.1 Linux BSP 与设备树

【知识来源】
- 文档名称：《ug821-zynq-7000-swdev.pdf》
- 核心出处：Xilinx Zynq-7000 Linux 基于 kernel.org 开源内核，提供 Linux BSP。设备树 (Device Tree) 描述硬件平台信息，内核通过设备树匹配驱动
- 关键词标签：`Linux` `设备树` `BSP` `内核` `U-Boot` `驱动匹配` `DTS`

**核心技术要点：**

- **Linux BSP 内容**：内核源码、设备树文件 (DTS/DTB)、U-Boot、根文件系统
- **设备树结构**：描述处理器、外设、内存映射、中断、时钟等硬件信息
- **自定义 IP 驱动**：PL 中的自定义 IP 需要在设备树中添加节点，并编写对应的 platform driver
- **驱动加载**：支持编译进内核和动态加载 (ko 模块) 两种方式

---

## 12. 触控芯片 I2C 驱动

### 12.1 GT917S 触控芯片

【知识来源】
- 文档名称：《GT917S编程指南.pdf》
- 核心出处：GT917S 电容触控芯片通过 I2C 接口与主控通信，支持多点触控。驱动通过 I2C 读写寄存器配置触控参数，通过中断引脚通知触控事件
- 关键词标签：`GT917S` `触控` `I2C` `寄存器` `中断` `多点触控` `手势`

**核心技术要点：**

- **I2C 地址**：7 位从设备地址，需根据硬件配置确认
- **通信协议**：标准 I2C 读写时序，支持寄存器地址 + 数据的读写模式
- **中断机制**：INT 引脚低电平有效，触控事件发生后拉低通知主控
- **初始化流程**：上电 -> 等待复位完成 -> 通过 I2C 读取配置 -> 写入固件/配置参数 -> 使能中断

---

## 13. PYNQ 框架中的 Linux 驱动层

### 13.1 PYNQ Linux 驱动架构

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：PYNQ 框架运行在 Ubuntu-based Linux 上，底层通过 Linux 驱动实现 PS-PL 交互。fpga_manager 驱动下载 bitstream、sysgpio 驱动控制 EMIO、uio 驱动实现中断管理、devmem 驱动实现 AXI GP 访问、xrt 驱动实现 AXI HP 访问
- 关键词标签：`PYNQ` `Linux驱动` `fpga_manager` `uio` `xrt` `devmem` `bitstream`

**核心技术要点：**

- **fpga_manager**：Linux 内核框架，用于将 bitstream 文件下载到 PL
- **sysgpio**：控制 PS 与 PL 之间的 EMIO 接口
- **uio (Userspace I/O)**：将 PL 中断映射到用户空间，Python 可通过 uio 接收中断
- **xrt (Xilinx Runtime)**：替代旧版 Xlnk 分配器，管理 PS-PL 共享内存分配
- **devmem**：提供用户空间直接访问物理内存的能力，用于 AXI GP 接口操作

---

> 本知识库版本：v1.0 | 生成时间：2026-05-18 | 归属智能体：@S
