# ZYNQ 架构设计知识库

> 归属智能体：@P 架构师
> 知识范围：Vivado流程、AXI互联、IP核封装、TCL脚本、RTL架构、HLS综合、VDMA/OSD/I2S等IP核、系统架构设计等
> 生成日期：2026-05-18

---

## 1. Zynq-7000 SoC 系统架构

### 1.1 PS-PL架构总览

【知识来源】
- 文档名称：《ds190-Zynq-7000-Overview.pdf》
- 核心出处：Zynq-7000 SoC集成ARM Cortex-A9 PS与28nm PL，通过AMBA AXI总线互联，PS始终先启动管理PL配置
- 关键词标签：`ZYNQ` `SoC` `PS-PL` `AXI` `系统架构` `互联` `XC7Z020`

**核心技术要点：**

- **PS四大模块**：APU（应用处理器单元）、Memory Interfaces（存储接口）、IOP（I/O外设）、Interconnect（互联）
- **AXI互联矩阵**：
  - 2x AXI 32-bit Master（PS访问PL）
  - 2x AXI 32-bit Slave（PL访问PS）
  - 4x AXI 64/32-bit HP Slave（PL直连DDR/OCM，高性能数据通道）
  - 1x AXI 64-bit ACP（加速器一致性端口，PL缓存一致性访问）
- **DMA通道**：8通道DMA控制器，4通道专用于PL，支持memory-to-memory/peripheral-to-memory/scatter-gather
- **中断系统**：16根PL到PS中断线，PS内部GIC（通用中断控制器）管理所有中断源
- **存储映射**：4GB统一地址空间，DDR从0x0000_0000开始，PL地址空间可自定义映射
- **启动流程**：PS ROM Boot -> BootROM加载第一阶段 -> FSBL（First Stage Boot Loader）加载bitstream和U-Boot/Linux

### 1.2 MIO/EMIO外设路由

【知识来源】
- 文档名称：《ds190-Zynq-7000-Overview.pdf》
- 核心出处：PS外设可通过MIO直接引出或通过EMIO扩展到PL，PCW工具用于外设引脚映射配置
- 关键词标签：`MIO` `EMIO` `外设路由` `PCW` `引脚映射`

**核心技术要点：**

- **MIO（Multiplexed I/O）**：54位PS引脚，直接连接PS外设（UART/SPI/I2C/SDIO/USB/GigE等）
- **EMIO（Extendable MIO）**：将PS外设信号路由到PL，通过PL引脚实现，增加灵活性
- **设计权衡**：MIO节省PL资源但引脚固定；EMIO灵活但消耗PL引脚和布线资源
- **GigE接口**：MIO支持RGMII v2.0，EMIO支持GMII/RGMII/MII/SGMII/1000BASE-X

---

## 2. Vivado设计流程与TCL脚本

### 2.1 Vivado工程流程

【知识来源】
- 文档名称：《1_【正点原子】领航者ZYNQ之FPGA开发指南V3.3.pdf》
- 核心出处：Vivado设计流程包含工程创建、Block Design、RTL编码、IP核配置、综合、实现、比特流生成
- 关键词标签：`Vivado` `Block Design` `IP核` `综合` `实现` `比特流` `上板`

**核心技术要点：**

- **Block Design**：图形化系统设计，通过拖拽IP核并连线构建PS-PL系统
- **设计流程**：Block Design -> Generate Output Products -> 创建HDL Wrapper -> 添加自定义RTL -> 综合 -> 实现 -> 生成比特流
- **TCL自动化**：所有Vivado操作均可通过TCL脚本自动化，支持批量工程创建和CI/CD集成
- **版本管理**：Vivado工程可导出为TCL脚本（write_project_tcl），实现工程版本控制

### 2.2 XDC约束在架构设计中的应用

【知识来源】
- 文档名称：《ug903-vivado-using-constraints.pdf》
- 核心出处：XDC约束文件贯穿综合和实现阶段，TCL命令格式，涵盖物理约束和时序约束
- 关键词标签：`XDC` `Tcl` `约束` `时序约束` `物理约束` `CDC`

**核心技术要点：**

- **约束分层**：物理约束（引脚/IO标准）-> 时序约束（时钟/延迟/路径）-> 跨时钟域约束（CDC）
- **TCL脚本化约束**：通过`set_property`、`create_clock`、`set_input_delay`等TCL命令编写约束
- **架构师关注点**：系统时钟规划、跨时钟域策略、总线时序预算、复位释放时序

---

## 3. AXI总线互联架构

### 3.1 AXI4-Lite IPIF

【知识来源】
- 文档名称：《pg155-axi-lite-ipif.pdf》
- 核心出处：AXI4-Lite IPIF v3.0提供AXI4-Lite从设备接口，支持32位地址和数据，含地址译码和I/O寄存器
- 关键词标签：`AXI4-Lite` `IPIF` `IP接口` `寄存器` `地址译码` `从设备`

**核心技术要点：**

- **接口特性**：5通道AXI4-Lite从接口（AW/AR/W/R/B），32位地址/数据宽度
- **地址译码**：内置地址译码逻辑，支持多个寄存器空间映射
- **I/O寄存器**：提供可配置的I/O寄存器模板，用于自定义IP的寄存器接口
- **TCL参数化**：通过TCL参数配置地址宽度、数据宽度、寄存器数量
- **应用场景**：自定义PL IP核的标准AXI4-Lite控制接口，连接到PS的GP或HP AXI互联

### 3.2 AXI互联矩阵设计

【知识来源】
- 文档名称：《ds190-Zynq-7000-Overview.pdf》《pg155-axi-lite-ipif.pdf》
- 核心出处：Zynq PS-PL通过AXI互联矩阵连接，支持多个Master和Slave的交叉互联
- 关键词标签：`AXI互联` `Interconnect` `Master` `Slave` `HP端口` `ACP`

**核心技术要点：**

- **GP端口（General Purpose）**：2x 32-bit Master + 2x 32-bit Slave，适合低带宽控制类通信
- **HP端口（High Performance）**：4x 64/32-bit Slave，带FIFO缓冲，直连DDR控制器和OCM，适合大数据吞吐
- **ACP端口**：1x 64-bit Slave，支持PL与ARM L2 Cache的一致性访问，适合加速器场景
- **互联策略**：
  - 控制类IP -> GP Master/Slave
  - 视频处理/数据采集 -> HP端口
  - AI加速器/协处理器 -> ACP端口
- **带宽规划**：HP端口64-bit@150MHz理论带宽约1.2GB/s，需根据实际数据流规划端口分配

---

## 4. IP核封装与自定义IP开发

### 4.1 IP核封装流程

【知识来源】
- 文档名称：《ug1118-vivado-creating-packaging-custom-ip.pdf》
- 核心出处：Vivado IP Packager将RTL设计封装为可复用IP核，支持AXI接口自动识别、TCL参数化、IP-XACT描述
- 关键词标签：`IP封装` `AXI` `Tcl` `IP-XACT` `RTL` `自定义IP` `Overlay`

**核心技术要点：**

- **封装流程**：Tools -> Create and Package New IP -> 选择封装方式（目录/工程/Block Design） -> 配置IP参数
- **IP分类**：
  - **AXI4-Lite IP**：控制寄存器类IP，通过AXI4-Lite IPIF模板快速创建
  - **AXI4 Stream IP**：数据流处理IP，适合视频/音频/传感器数据流水线
  - **AXI4 Memory Mapped IP**：全功能AXI4 IP，支持突发传输
- **IP参数化**：通过TCL GUI参数（GUI页面/参数名/默认值/范围）实现IP可配置
- **全局Include文件**：支持跨模块共享参数定义
- **IP输出**：IP Packager输出包含.xci文件、RTL源码、约束文件、文档
- **Overlay架构**：多个自定义IP封装后可组合为Overlay，实现完整PL加速子系统

### 4.2 自定义IP设计模式

【知识来源】
- 文档名称：《ug1118-vivado-creating-packaging-custom-ip.pdf》《pg155-axi-lite-ipif.pdf》
- 核心出处：自定义IP需遵循AXI协议规范，通过Vivado IP Packager封装后可在Block Design中复用
- 关键词标签：`自定义IP` `AXI协议` `IP封装` `Block Design` `复用`

**核心技术要点：**

- **AXI4-Lite控制接口模式**：
  ```
  [PS Master] -> [AXI Interconnect] -> [AXI4-Lite Slave IP] -> [自定义逻辑]
  ```
  - 适合配置类IP（寄存器读写、状态查询）
  - 通过IPIF模板自动生成AXI协议逻辑
- **AXI4-Stream数据流模式**：
  ```
  [VDMA/Source] -> [AXI4-Stream Master IP] -> [AXI4-Stream Slave IP] -> [Sink]
  ```
  - 适合视频/音频处理流水线
  - 支持背压（backpressure）和侧带信号（tuser/tlast/tkeep）
- **AXI4 Memory Mapped模式**：
  - 适合需要直接访问DDR内存的IP（如自定义DMA引擎）

---

## 5. HLS高层次综合

### 5.1 Vitis HLS开发流程

【知识来源】
- 文档名称：《4_【正点原子】领航者ZYNQ之Vitis HLS开发指南_V1.0.pdf》
- 核心出处：Vitis HLS将C/C++算法综合为RTL，支持AXI4接口自动生成，实现软件算法到硬件加速的快速转化
- 关键词标签：`HLS` `C/C++` `RTL` `AXI4` `IP核` `综合` `Overlay` `加速`

**核心技术要点：**

- **开发流程**：C/C++算法编写 -> C仿真验证 -> HLS综合 -> C/RTL协同仿真 -> IP导出 -> Vivado集成
- **接口综合**：
  - `#pragma HLS INTERFACE m_axi` -> 生成AXI4 Master接口（访问DDR）
  - `#pragma HLS INTERFACE axis` -> 生成AXI4-Stream接口（数据流）
  - `#pragma HLS INTERFACE s_axilite` -> 生成AXI4-Lite控制接口
- **优化指令**：
  - `#pragma HLS PIPELINE` -> 流水线优化
  - `#pragma HLS UNROLL` -> 循环展开
  - `#pragma HLS ARRAY_PARTITION` -> 数组分割（BRAM/URAM优化）
  - `#pragma HLS DATAFLOW` -> 任务级并行
- **Overlay集成**：HLS生成的IP核封装后作为Overlay的一部分集成到Block Design中
- **适用场景**：NV色心控制算法（脉冲序列、信号处理）、图像预处理、数据滤波等计算密集型任务

---

## 6. 视频处理IP核架构

### 6.1 AXI VDMA

【知识来源】
- 文档名称：《xapp742-axi-vdma-reference-design.pdf》
- 核心出处：AXI VDMA实现视频数据在AXI4-Stream（视频IP间）和AXI Memory Mapped（DDR）之间的搬运
- 关键词标签：`VDMA` `视频` `AXI` `VTC` `IP核` `Tcl` `参考设计`

**核心技术要点：**

- **功能**：2D帧缓冲管理，支持多帧缓冲（2~32帧），实现视频流到内存映射的双向转换
- **通道**：读通道（MM2S，DDR->视频IP）和写通道（S2MM，视频IP->DDR）独立配置
- **帧缓冲**：支持帧起始地址列表，实现ping-pong缓冲或多缓冲
- **参考设计架构**：
  ```
  [Video TPG] -> [AXI4-Stream] -> [VDMA MM2S] -> [DDR]
  [DDR] -> [VDMA S2MM] -> [AXI4-Stream] -> [OSD] -> [Display]
  ```
- **动态配置**：帧率、分辨率、像素格式等参数可通过AXI4-Lite控制接口动态调整
- **带宽优化**：支持垂直/水平方向独立配置stride，适配不同分辨率

### 6.2 Video OSD (On-Screen Display)

【知识来源】
- 文档名称：《pg010_v_osd.pdf》
- 核心出处：LogiCORE IP Video On-Screen Display，在视频流上叠加Alpha混合的图形层
- 关键词标签：`OSD` `Alpha混合` `视频` `AXI4-Lite` `Overlay` `IP核`

**核心技术要点：**

- **功能**：在主视频流上叠加一层或多层图形/文字信息，支持Alpha透明度混合
- **接口**：AXI4-Stream视频数据通路 + AXI4-Lite控制接口
- **Alpha混合**：支持全局Alpha和像素级Alpha，实现半透明叠加效果
- **应用场景**：NV色心实验状态信息显示、参数实时标注、UI覆盖层
- **配置参数**：视频分辨率、色彩空间、Alpha值、图层位置/尺寸等通过AXI4-Lite寄存器配置

---

## 7. 音频处理IP核架构

### 7.1 AXI I2S Transmitter/Receiver

【知识来源】
- 文档名称：《pg308-i2s.pdf》
- 核心出处：LogiCORE IP AXI I2S提供I2S音频接口的发送和接收功能，通过AXI4-Lite控制
- 关键词标签：`I2S` `音频` `AXI-Lite` `IP核` `收发器` `Overlay`

**核心技术要点：**

- **功能**：将AXI4-Stream音频数据转换为I2S格式输出，或将I2S输入转换为AXI4-Stream
- **接口**：
  - AXI4-Stream数据接口（音频数据流）
  - AXI4-Lite控制接口（配置寄存器）
  - I2S物理接口（BCLK/LRCLK/SDATA）
- **支持格式**：I2S标准格式、Left-Justified、Right-Justified
- **通道支持**：立体声（2通道），可扩展多通道
- **时钟管理**：需外部提供BCLK（位时钟）和MCLK（主时钟），MCLK通常为采样率的256x或384x
- **应用场景**：连接ES8388 CODEC，实现音频输入/输出通路

---

## 8. PS软件开发与系统架构

### 8.1 Zynq软件开发架构

【知识来源】
- 文档名称：《ug821-zynq-7000-swdev.pdf》
- 核心出处：Zynq-7000软件开发支持裸机、Linux和RTOS，PS-PL协同通过AXI总线和中断实现
- 关键词标签：`ARM` `裸机` `Linux` `Boot` `PS-PL` `AXI` `驱动` `Tcl`

**核心技术要点：**

- **软件栈**：
  ```
  [用户应用] -> [Linux/RTOS/裸机] -> [驱动程序] -> [PS外设/PL IP] -> [硬件]
  ```
- **PS-PL通信机制**：
  - AXI总线：PS通过GP/HP端口读写PL IP寄存器和内存
  - 中断：PL事件通过中断线通知PS处理
  - 共享内存：通过HP端口或OCM共享数据缓冲区
  - DMA：PS DMA控制器或PL DMA引擎实现高效数据搬运
- **Boot流程**：BootROM -> FSBL（加载PL bitstream + U-Boot） -> Linux内核 -> 根文件系统
- **Tcl辅助**：XSCT（Xilinx Software Command-line Tool）通过Tcl脚本自动化软件构建和调试

### 8.2 系统架构设计模式

【知识来源】
- 文档名称：《ds190-Zynq-7000-Overview.pdf》《ug821-zynq-7000-swdev.pdf》《ug1118-vivado-creating-packaging-custom-ip.pdf》
- 核心出处：Zynq系统架构需合理规划PS-PL分工、AXI互联拓扑、中断分配和存储映射
- 关键词标签：`系统架构` `PS-PL分工` `AXI拓扑` `中断分配` `存储映射`

**核心技术要点：**

- **PS-PL分工原则**：
  - PS负责：控制逻辑、通信协议、文件系统、网络栈、用户界面
  - PL负责：实时信号处理、高速数据采集、并行计算、时序关键操作
- **AXI互联拓扑设计**：
  - 控制类IP共享GP Master端口（通过AXI Interconnect扩展）
  - 高带宽IP独占HP端口
  - ACP端口保留给需要缓存一致性的加速器
- **中断架构**：
  - PL中断汇聚后通过PL到PS中断线通知
  - Linux下使用GIC中断控制器管理
  - 裸机下直接配置GIC寄存器
- **存储映射规划**：
  - 0x0000_0000 ~ 0x3FFF_FFFF：DDR内存（1GB）
  - 0xFFFC_0000 ~ 0xFFFF_FFFF：PS外设寄存器
  - 0x4000_0000 ~ 0x7FFF_FFFF：PL地址空间（可自定义）
  - 0xFFFF_0000 ~ 0xFFFF_FFFF：OCM（256KB）

---

## 9. NV色心项目架构参考

### 9.1 系统架构建议

基于以上知识，NV色心控制系统的ZYNQ架构建议：

- **PS端**：运行Linux，负责上位机通信（以太网/USB）、参数管理、GUI显示、数据存储
- **PL端**：
  - 脉冲序列发生器（AXI4-Lite控制 + AXI4-Stream数据输出）
  - 信号采集与处理（ADC接口 + 数字滤波 + HLS加速）
  - 视频处理链路（VDMA + OSD + HDMI输出）
  - 音频处理链路（I2S + ES8388 CODEC）
- **互联方案**：
  - 脉冲序列发生器 -> GP AXI4-Lite Slave
  - 信号采集DMA -> HP AXI4 Slave（直连DDR）
  - 视频处理链路 -> HP AXI4 Slave（VDMA直连DDR）
  - HLS加速器 -> ACP端口（缓存一致性）

### 9.2 关键IP核清单

| IP核 | 接口类型 | 用途 | AXI端口 |
|------|----------|------|---------|
| AXI GPIO | AXI4-Lite | LED/按键控制 | GP |
| AXI UART | AXI4-Lite | 调试串口 | GP |
| AXI I2C | AXI4-Lite | 触控/传感器 | GP |
| AXI SPI | AXI4-Lite | 外设通信 | GP |
| AXI VDMA | AXI4-MM + Stream | 视频帧缓冲 | HP |
| Video OSD | AXI4-Lite + Stream | 视频叠加 | HP |
| AXI I2S | AXI4-Lite + Stream | 音频收发 | GP |
| HLS加速IP | AXI4-Master + Lite | 算法加速 | ACP/HP |
| 自定义脉冲IP | AXI4-Lite | 脉冲序列生成 | GP |
