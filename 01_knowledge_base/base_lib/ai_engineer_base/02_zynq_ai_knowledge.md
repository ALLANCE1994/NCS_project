# ZYNQ AI 应用开发知识库

> 本知识库面向 @A AI 使用工程师，聚焦 ZYNQ SoC 平台上的 AI 应用开发、PYNQ 框架、Python 编程、图像处理、Overlay 设计与部署等核心技术领域。
> 知识来源：项目粗加工提取数据中归属 @A 的 PDF 文档结构化精炼。

---

## 目录

1. [PYNQ 框架概述](#1-pynq-框架概述)
2. [PYNQ 开发环境搭建](#2-pynq-开发环境搭建)
3. [Overlay 设计与部署](#3-overlay-设计与部署)
4. [Jupyter Notebook 交互开发](#4-jupyter-notebook-交互开发)
5. [Python 编程与 NumPy 数据处理](#5-python-编程与-numpy-数据处理)
6. [OpenCV 图像处理](#6-opencv-图像处理)
7. [AXI GPIO 与 PL 控制](#7-axi-gpio-与-pl-控制)
8. [AXI DMA 高速数据传输](#8-axi-dma-高速数据传输)
9. [HLS 高层次综合加速](#9-hls-高层次综合加速)
10. [Qt 环境搭建与交叉编译](#10-qt-环境搭建与交叉编译)
11. [Vitis AI 与深度学习部署](#11-vitis-ai-与深度学习部署)
12. [PYNQ Linux 系统与网络配置](#12-pynq-linux-系统与网络配置)
13. [PYNQ 中断与事件处理](#13-pynq-中断与事件处理)

---

## 1. PYNQ 框架概述

### 1.1 PYNQ 架构与设计理念

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：PYNQ (Python Productivity for Zynq) 是 Xilinx 开发的开源框架，通过 Python + Jupyter Notebook 实现对 ZYNQ PL 可编程逻辑的快速原型开发。核心思想是将 PL 编程抽象为 Overlay，通过 Python API 控制
- 关键词标签：`PYNQ` `Overlay` `Python` `Jupyter` `ZYNQ` `开源框架` `快速原型`

**核心技术要点：**

- **架构分层**：Python API 层 -> Jupyter Notebook 交互层 -> PYNQ Python 库 -> Linux 驱动层 -> PL 硬件
- **Overlay 概念**：将 PL 硬比特流封装为 Python 可操作的 Overlay 对象，一行代码即可加载：`overlay = Overlay("base.bit")`
- **设计哲学**：让软件工程师和 AI 研究人员无需掌握 HDL 即可利用 FPGA 加速
- **支持平台**：Zynq-7000 (PYNQ-Z1/Z2)、Zynq UltraScale+ (PYNQ-ZCU104 等)

### 1.2 PYNQ 系统组成

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：PYNQ 系统由三部分组成：(1) PYNQ 镜像 -- 基于 Ubuntu 的 Linux 系统，预装 Python/Jupyter/驱动；(2) PYNQ Python 库 -- pynq.overlay、pynq.mmio 等模块；(3) Overlay 比特流 -- Vivado 生成的硬件设计
- 关键词标签：`PYNQ镜像` `Python库` `pynq` `Overlay` `比特流` `Ubuntu`

**核心技术要点：**

- **PYNQ 镜像**：基于 Ubuntu 18.04/20.04，预装 Python 3.6+、Jupyter Notebook、PYNQ Python 包
- **pynq 包**：`pip install pynq`，核心模块包括 `pynq.overlay`、`pynq.mmio`、`pynq.interrupt`、`pynq.pl`
- **Overlay 加载**：`from pynq import Overlay; ol = Overlay("design.bit")`，自动解析地址映射
- **IP 核访问**：`ol.ip_dict` 查看所有 IP 核信息，`ol.ip_name_0.read(offset)` / `.write(offset, value)` 读写寄存器

---

## 2. PYNQ 开发环境搭建

### 2.1 网络与镜像烧录

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：PYNQ 开发板通过网线连接 PC，PC 端配置静态 IP (如 192.168.1.100)，PYNQ 板默认 IP 为 192.168.1.10。通过浏览器访问 http://192.168.1.10:9090 进入 Jupyter Notebook
- 关键词标签：`网络配置` `静态IP` `Jupyter` `镜像烧录` `SD卡` `Win32DiskImager`

**核心技术要点：**

- **镜像烧录**：使用 Win32DiskImager 将 PYNQ 镜像写入 SD 卡（推荐 16GB+ Class10）
- **网络连接**：PC 与 PYNQ 板直连网线，配置同网段静态 IP
- **Jupyter 访问**：浏览器打开 `http://pynq:9090` 或 `http://<board_ip>:9090`
- **默认账号**：用户名 `xilinx`，密码 `xilinx`

### 2.2 PYNQ 板卡信息

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：领航者 PYNQ 开发板基于 XC7Z020 SoC，搭载 1GB DDR3、32MB Quad-SPI Flash、Micro SD 卡槽、千兆以太网、USB-UART (CH340)、HDMI 输出、Arduino/Pmod 扩展接口
- 关键词标签：`XC7Z020` `DDR3` `千兆以太网` `HDMI` `Pmod` `Arduino接口`

**核心技术要点：**

- **硬件资源**：XC7Z020 CLG400，85K 逻辑单元，220 个 DSP48E1 切片，4.9Mb Block RAM
- **板载外设**：LED、按键、拨码开关、蜂鸣器、温度传感器 (ADT7420)、EEPROM (24C02)
- **扩展接口**：2x Pmod、1x Arduino，支持自定义扩展板

---

## 3. Overlay 设计与部署

### 3.1 Overlay 硬件设计流程

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：Overlay 硬件在 Vivado 中设计，通过 IP Integrator 搭建 Block Design，包含 ZYNQ7 PS + PL IP 核 + AXI 互联。设计完成后导出 XSA 文件，生成 bitstream
- 关键词标签：`Vivado` `Overlay` `Block Design` `XSA` `bitstream` `IP Integrator`

**核心技术要点：**

- **设计约束**：Overlay 必须包含 ZYNQ7 Processing System IP，PS-PL AXI 接口需正确连接
- **地址分配**：Vivado 自动分配 AXI 外设地址，PYNQ 通过 `ol.ip_dict` 获取地址映射
- **中断连接**：PL 中断需连接到 PS 的 IRQ_F2P[0:0] 端口
- **导出流程**：Vivado -> File -> Export -> Export Hardware (XSA) -> 生成 bitstream

### 3.2 Overlay Python API

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：PYNQ Overlay 通过 Python API 控制 PL 硬件。`Overlay` 类自动解析 bitstream 中的 IP 核地址映射，提供 `read()`/`write()` 方法直接访问 AXI 寄存器
- 关键词标签：`Overlay API` `read` `write` `ip_dict` `MMIO` `Python控制`

**核心技术要点：**

- **加载 Overlay**：`from pynq import Overlay; ol = Overlay("gpio_led.bit")`
- **查看 IP 信息**：`ol.ip_dict` 返回所有 IP 核的地址、类型、状态信息
- **MMIO 访问**：`ol.ip_name.read(offset)` / `ol.ip_name.write(offset, value)`
- **GPIO 控制**：`ol.axi_gpio_0.channel1[0].write(1)` -- 控制 LED
- **Overlay 卸载**：`ol.download()` 重新下载，`ol.free()` 释放资源

---

## 4. Jupyter Notebook 交互开发

### 4.1 Jupyter 开发模式

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：PYNQ 通过 Jupyter Notebook 提供交互式开发环境，支持代码单元执行、Markdown 文档、实时绘图、图像显示等功能
- 关键词标签：`Jupyter` `Notebook` `交互式` `代码单元` `Markdown` `实时绘图`

**核心技术要点：**

- **开发流程**：打开 Jupyter -> 创建 Notebook -> 导入 pynq 库 -> 加载 Overlay -> 编写控制逻辑 -> 执行验证
- **实时反馈**：每个代码单元可独立执行，支持即时查看输出和图像
- **文档集成**：Markdown 单元可记录实验步骤、参数配置、结果分析
- **图像显示**：`from IPython.display import display; display(Image.open("image.png"))`

### 4.2 Jupyter Lab

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：新版 PYNQ 支持 JupyterLab，提供更现代的 IDE 界面，支持多标签页、文件浏览器、终端、变量查看器等功能
- 关键词标签：`JupyterLab` `IDE` `多标签` `文件浏览器` `终端`

**核心技术要点：**

- **访问方式**：`http://<board_ip>:9090/lab`
- **功能增强**：代码补全、变量检查、GPU/PL 资源监控

---

## 5. Python 编程与 NumPy 数据处理

### 5.1 NumPy 在 PYNQ 中的应用

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：PYNQ 中 NumPy 数组可直接通过 DMA 传输到 PL IP。NumPy 的 `numpy.array()` 创建的数据缓冲区可作为 DMA 源/目标地址
- 关键词标签：`NumPy` `DMA` `数据传输` `numpy.array` `缓冲区` `PL交互`

**核心技术要点：**

- **数据准备**：`import numpy as np; data = np.array([1,2,3,4], dtype=np.uint32)`
- **DMA 传输**：NumPy 数组可直接传给 DMA 驱动，无需手动地址转换
- **数据类型**：使用 `np.uint8`/`np.uint16`/`np.uint32`/`np.int32` 匹配硬件位宽
- **连续内存**：`np.ascontiguousarray()` 确保内存连续，DMA 要求物理连续缓冲区
- **物理地址获取**：`pynq.allocate()` 分配连续物理内存，支持 DMA 直接访问

### 5.2 PYNQ 内存管理

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：PYNQ 提供 `pynq.allocate()` 和 `pynq.Xlnk` 进行物理连续内存分配。分配的缓冲区可获取物理地址，供 DMA 使用
- 关键词标签：`内存管理` `物理连续` `pynq.allocate` `Xlnk` `DMA缓冲`

**核心技术要点：**

- **内存分配**：`from pynq import allocate; buf = allocate(shape=(1024,), dtype=np.uint32)`
- **物理地址**：`buf.physical_address` 获取物理地址，供 PL DMA 使用
- **同步机制**：`buf.sync_to_device()` / `buf.sync_from_device()` 在 CPU/PL 之间同步缓存
- **Xlnk (旧版)**：`Xlnk().cma_array()` 分配 CMA 连续内存

---

## 6. OpenCV 图像处理

### 6.1 OpenCV 在 PYNQ 上的使用

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：PYNQ 镜像预装 OpenCV-Python，可直接在 Jupyter Notebook 中使用 cv2 模块进行图像读取、处理和显示
- 关键词标签：`OpenCV` `cv2` `图像处理` `PYNQ` `Jupyter` `实时显示`

**核心技术要点：**

- **图像读取**：`import cv2; img = cv2.imread("image.jpg")`
- **颜色转换**：`gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)` -- BGR 转灰度
- **图像显示**：`from matplotlib import pyplot as plt; plt.imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB)); plt.show()`
- **摄像头**：`cap = cv2.VideoCapture(0)` -- USB 摄像头采集
- **视频处理**：`ret, frame = cap.read()` -- 逐帧读取处理

### 6.2 图像数据格式与 PL 交互

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：OpenCV 图像数据 (numpy array) 可直接通过 DMA 传输到 PL 进行硬件加速处理。需注意 BGR/RGB 格式转换和数据对齐
- 关键词标签：`图像数据` `DMA传输` `格式转换` `BGR` `RGB` `数据对齐`

**核心技术要点：**

- **数据格式**：OpenCV 默认 BGR 格式，PL IP 通常期望 RGB 或灰度格式
- **连续内存**：`np.ascontiguousarray(img)` 确保 DMA 可访问
- **位宽匹配**：8-bit 灰度图用 `np.uint8`，24-bit 彩色图用 `np.uint8` 三通道
- **处理流程**：OpenCV 读取 -> 格式转换 -> DMA 发送到 PL -> PL 处理 -> DMA 读回 -> OpenCV 显示

---

## 7. AXI GPIO 与 PL 控制

### 7.1 Python 控制 AXI GPIO

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：PYNQ 通过 pynq.overlay 模块控制 AXI GPIO IP。AXI GPIO 提供双通道，每个通道可独立配置方向和位宽
- 关键词标签：`AXI GPIO` `Python` `LED` `按键` `pynq.overlay` `channel`

**核心技术要点：**

- **加载 Overlay**：`from pynq import Overlay; ol = Overlay("gpio_led.bit")`
- **LED 控制**：`ol.axi_gpio_0.channel1[0].write(1)` -- 点亮 LED0
- **按键读取**：`btn_state = ol.axi_gpio_1.channel1[0].read()` -- 读取按键状态
- **批量操作**：`ol.axi_gpio_0.channel1.write(0xFF)` -- 同时控制 8 个 LED

### 7.2 自定义 IP 核 Python 控制

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：自定义 IP 核通过 AXI4-Lite 接口连接 PS，PYNQ 通过 MMIO (Memory Mapped I/O) 直接读写 IP 核寄存器
- 关键词标签：`自定义IP` `AXI4-Lite` `MMIO` `寄存器` `Python控制`

**核心技术要点：**

- **IP 核访问**：`ol.ip_name.read(offset)` / `ol.ip_name.write(offset, value)`
- **地址映射**：Vivado 中分配的 AXI 地址在 `ol.ip_dict` 中自动解析
- **数据位宽**：MMIO 默认 32 位读写，与 AXI4-Lite 数据宽度匹配

---

## 8. AXI DMA 高速数据传输

### 8.1 Python DMA 编程

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：PYNQ 提供 `pynq.lib.dma` 模块封装 AXI DMA 操作。支持简单 DMA 传输和 Scatter-Gather DMA 传输
- 关键词标签：`DMA` `pynq.lib.dma` `Scatter-Gather` `高速传输` `中断`

**核心技术要点：**

- **DMA 初始化**：`from pynq import Overlay, allocate; ol = Overlay("dma_test.bit"); dma = ol.axi_dma_0`
- **简单传输**：`dma.send(data)` / `dma.recv(output)` -- 同步阻塞传输
- **异步传输**：`dma.sendchannel.transfer(data)` / `dma.recvchannel.transfer(output)` -- 非阻塞
- **缓冲区分配**：`input_buf = allocate(shape=(1024,), dtype=np.uint32); output_buf = allocate(shape=(1024,), dtype=np.uint32)`
- **缓存同步**：`input_buf.sync_to_device()` 发送前同步，`output_buf.sync_from_device()` 接收后同步

### 8.2 DMA 数据流设计模式

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：典型 DMA 数据流：PS 端 NumPy 数组 -> DMA MM2S 通道 -> AXI Stream -> PL IP (处理) -> AXI Stream -> DMA S2MM 通道 -> PS 端 NumPy 数组
- 关键词标签：`数据流` `MM2S` `S2MM` `AXI Stream` `PL处理` `NumPy`

**核心技术要点：**

- **MM2S (Memory Mapped to Stream)**：PS DDR -> PL IP 输入
- **S2MM (Stream to Memory Mapped)**：PL IP 输出 -> PS DDR
- **TLAST 信号**：AXI Stream 帧结束信号，PL IP 必须在最后一个数据时拉高
- **中断驱动**：DMA 传输完成产生中断，Python 通过 `dma.recvchannel.wait()` 等待

---

## 9. HLS 高层次综合加速

### 9.1 Vitis HLS 概述

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：Vitis HLS (High-Level Synthesis) 将 C/C++ 函数综合为 RTL 硬件，自动实现流水线、数组分割等优化。生成的 IP 核可集成到 Vivado Overlay 中
- 关键词标签：`HLS` `Vitis HLS` `C/C++` `RTL` `流水线` `IP核` `硬件加速`

**核心技术要点：**

- **开发流程**：编写 C/C++ 算法 -> 编写 Testbench -> C 仿真验证 -> HLS 综合 -> 导出 IP
- **优化指令**：`#pragma HLS PIPELINE` (流水线)、`#pragma HLS ARRAY_PARTITION` (数组分割)、`#pragma HLS UNROLL` (循环展开)
- **数据类型**：`ap_int<N>` 任意精度整数，`ap_fixed<M,N>` 定点数
- **接口综合**：`#pragma HLS INTERFACE m_axi` (AXI Master)、`#pragma HLS INTERFACE axis` (AXI Stream)
- **IP 集成**：HLS 生成的 IP 核添加到 Vivado Block Design，通过 AXI 接口连接

### 9.2 HLS 加速图像处理

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：HLS 特别适合图像处理算法的硬件加速，如滤波、边缘检测、颜色转换等。通过 AXI Stream 接口实现像素级流水线处理
- 关键词标签：`HLS图像` `滤波` `边缘检测` `流水线` `AXI Stream` `像素`

**核心技术要点：**

- **图像流接口**：`hls::Mat` 或 `hls::stream<ap_uint<24>>` 表示图像数据流
- **行缓冲**：`#pragma HLS LINE_BUFFER` 自动管理图像行缓存
- **窗口函数**：`#pragma HLS WINDOW` 自动管理滑动窗口
- **性能优化**：像素级流水线可实现每时钟周期处理一个像素

---

## 10. Qt 环境搭建与交叉编译

### 10.1 Qt 交叉编译环境

【知识来源】
- 文档名称：《2_【正点原子】领航者ZYNQ之嵌入式Vitis开发指南v1_2.pdf》
- 核心出处：在 PYNQ/ZYNQ Linux 系统上搭建 Qt 环境，需在 PC 端配置交叉编译工具链 (aarch64-linux-gnu-gcc)，编译 Qt 库和应用程序
- 关键词标签：`Qt` `交叉编译` `aarch64` `工具链` `CMake` `qmake`

**核心技术要点：**

- **工具链**：`aarch64-linux-gnu-gcc` / `aarch64-linux-gnu-g++` 交叉编译器
- **Qt 配置**：交叉编译 Qt Base 库，配置 `-device linux-arm-gnueabi-g++` 参数
- **部署流程**：PC 端编译 -> 拷贝到 PYNQ 板 -> 设置 `LD_LIBRARY_PATH` -> 运行
- **CMake 集成**：使用 CMake 交叉编译配置文件 (`toolchain.cmake`) 管理构建

### 10.2 SDK 配置与开发

【知识来源】
- 文档名称：《2_【正点原子】领航者ZYNQ之嵌入式Vitis开发指南v1_2.pdf》
- 核心出处：Vitis SDK 支持为 ZYNQ 配置嵌入式 Linux SDK，包含 sysroot、库文件和头文件，用于交叉编译用户应用程序
- 关键词标签：`SDK` `sysroot` `交叉编译` `库文件` `头文件` `Vitis`

**核心技术要点：**

- **sysroot**：包含目标系统的库和头文件，交叉编译时链接使用
- **库路径**：编译时指定 `--sysroot=<path>` 参数
- **应用部署**：编译后的可执行文件拷贝到 PYNQ 板卡运行

---

## 11. Vitis AI 与深度学习部署

### 11.1 Vitis AI 概述

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：Vitis AI 是 Xilinx 的统一 AI 推理开发环境，支持在 ZYNQ UltraScale+ 上部署量化后的 DNN 模型。提供模型量化、编译、运行时 API
- 关键词标签：`Vitis AI` `DNN` `量化` `推理` `部署` `DPU`

**核心技术要点：**

- **模型量化**：将 FP32 模型量化为 INT8，减少存储和计算量
- **模型编译**：`vai_c_xir` 将量化模型编译为 DPU 指令
- **运行时 API**：Python/C++ API 加载模型并执行推理
- **DPU IP 核**：专用深度学习处理单元，集成到 Overlay 中

### 11.2 AI 推理在 PYNQ 上的部署

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：在 PYNQ 上部署 AI 推理，需要将 DPU IP 核集成到 Overlay，使用 Vitis AI Python API 加载模型并执行推理。输入图像通过 NumPy/OpenCV 准备
- 关键词标签：`AI部署` `DPU` `PYNQ` `推理` `Python API` `模型加载`

**核心技术要点：**

- **Overlay 设计**：Vivado 中添加 DPU IP，配置 AXI Master 接口访问 DDR
- **模型加载**：`from xir import Graph; graph = Graph.deserialize("model.xmodel")`
- **推理执行**：`runner = Runner(graph); output = runner.run(input_data)`
- **预处理**：OpenCV 读取图像 -> resize -> normalize -> numpy array

---

## 12. PYNQ Linux 系统与网络配置

### 12.1 PYNQ Linux 系统管理

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：PYNQ 运行基于 Ubuntu 的 Linux 系统，可通过 SSH 远程登录 (`ssh xilinx@192.168.1.10`)，支持 apt 包管理器安装额外软件
- 关键词标签：`Linux` `SSH` `apt` `Ubuntu` `系统管理` `PYNQ`

**核心技术要点：**

- **SSH 访问**：`ssh xilinx@<board_ip>`，密码 `xilinx`
- **包管理**：`sudo apt-get update && sudo apt-get install <package>`
- **文件传输**：`scp` 命令在 PC 与 PYNQ 板之间传输文件
- **系统信息**：`cat /proc/cpuinfo`、`free -m`、`df -h`

### 12.2 网络配置

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：PYNQ 板默认通过 eth0 接口配置静态 IP 192.168.1.10/24。可通过 `nmcli` 或修改 `/etc/network/interfaces` 修改网络配置
- 关键词标签：`网络` `静态IP` `eth0` `nmcli` `DHCP`

**核心技术要点：**

- **查看网络**：`ifconfig` 或 `ip addr`
- **修改 IP**：`sudo ifconfig eth0 192.168.1.20 netmask 255.255.255.0`
- **DHCP 模式**：`sudo dhclient eth0`

---

## 13. PYNQ 中断与事件处理

### 13.1 Python 中断处理

【知识来源】
- 文档名称：《5_【正点原子】领航者ZYNQ之PYNQ开发指南_V3.0.pdf》
- 核心出处：PYNQ 通过 `pynq.interrupt` 模块实现 PL 中断的 Python 层处理。PL 中断通过 UIO 驱动映射到用户空间
- 关键词标签：`中断` `pynq.interrupt` `UIO` `事件` `回调` `Python`

**核心技术要点：**

- **中断注册**：`from pynq import Interrupt; intr = Interrupt("ip_name"); intr.register_callback(handler_func)`
- **事件等待**：`intr.wait()` -- 阻塞等待中断事件
- **中断使能**：`intr.enable()` / `intr.disable()`
- **应用场景**：按键检测、DMA 传输完成通知、外部传感器数据就绪

---

> 本知识库版本：v1.0 | 生成时间：2026-05-18 | 归属智能体：@A
