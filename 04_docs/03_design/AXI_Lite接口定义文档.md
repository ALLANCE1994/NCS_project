# AXI-Lite接口定义文档（M4 PS集成）

> **文档编号**: NCS-SPEC-20260520-AXI
> **负责智能体**: @P 架构师
> **审核**: @V 工程规则管理师
> **日期**: 2026-05-20
> **知识来源**: arch_base.md / sw_engineer_base/03_zynq_software_knowledge.md / M2_exit_checklist.md

---

## 一、设计原则

- **通信模型**: 同步优先；AXI-Lite优先（arch_base.md）
- **总线协议**: AXI4-Lite（单数据传输，用于低速外设寄存器访问）
- **地址空间**: 单个AXI-Lite从接口，统一地址映射
- **时钟**: PS7 FCLK_CLK0 (50MHz)
- **数据宽度**: 32位

---

## 二、AXI-Lite从接口信号定义

### 2.1 标准AXI4-Lite信号

| 信号名 | 方向 | 位宽 | 说明 |
|--------|:----:|:----:|------|
| s_axi_aclk | input | 1 | AXI时钟（PS7 FCLK_CLK0） |
| s_axi_aresetn | input | 1 | AXI复位（PS7 FCLK_RESET0_N） |
| s_axi_awaddr | input | 12 | 写地址（4KB地址空间） |
| s_axi_awprot | input | 3 | 写保护（未使用） |
| s_axi_awvalid | input | 1 | 写地址有效 |
| s_axi_awready | output | 1 | 写地址就绪 |
| s_axi_wdata | input | 32 | 写数据 |
| s_axi_wstrb | input | 4 | 写字节选通 |
| s_axi_wvalid | input | 1 | 写数据有效 |
| s_axi_wready | output | 1 | 写数据就绪 |
| s_axi_bresp | output | 2 | 写响应（00=OK） |
| s_axi_bvalid | output | 1 | 写响应有效 |
| s_axi_bready | input | 1 | 写响应就绪 |
| s_axi_araddr | input | 12 | 读地址 |
| s_axi_arprot | input | 3 | 读保护（未使用） |
| s_axi_arvalid | input | 1 | 读地址有效 |
| s_axi_arready | output | 1 | 读地址就绪 |
| s_axi_rdata | output | 32 | 读数据 |
| s_axi_rresp | output | 2 | 读响应（00=OK） |
| s_axi_rvalid | output | 1 | 读数据有效 |
| s_axi_rready | input | 1 | 读数据就绪 |

---

## 三、寄存器地址映射

### 3.1 全局控制/状态

| 地址 | 名称 | 类型 | 位宽 | 复位值 | 说明 |
|:----:|------|:----:|:----:|:------:|------|
| 0x000 | CTRL | R/W | 32 | 0x00000000 | 全局控制寄存器 |
| 0x004 | STATUS | R | 32 | 0x00000000 | 全局状态寄存器 |

#### CTRL寄存器位域

| 位域 | 名称 | R/W | 说明 |
|:----:|------|:---:|------|
| [0] | GLOBAL_EN | R/W | 全局使能（1=使能所有模块） |
| [1] | DDS_EN | R/W | DDS使能 |
| [2] | SCAN_EN | R/W | 扫描使能 |
| [3] | SOFT_RST | R/W | 软件复位（自清零） |
| [31:4] | Reserved | - | 保留 |

#### STATUS寄存器位域

| 位域 | 名称 | R | 说明 |
|:----:|------|:-:|------|
| [0] | SCAN_BUSY | R | 扫描进行中 |
| [1] | SCAN_DONE | R | 扫描完成（脉冲） |
| [2] | ADC_OVF | R | ADC溢出标志 |
| [3] | LIA_BUSY | R | 锁相忙碌 |
| [31:4] | Reserved | - | 保留 |

### 3.2 DDS控制

| 地址 | 名称 | 类型 | 位宽 | 复位值 | 说明 |
|:----:|------|:----:|:----:|:------:|------|
| 0x008 | DDS_FREQ | R/W | 32 | 0x00000000 | DDS频率控制字 |
| 0x00C | DDS_PHASE | R/W | 32 | 0x00000000 | DDS相位偏移 |

### 3.3 扫描控制

| 地址 | 名称 | 类型 | 位宽 | 复位值 | 说明 |
|:----:|------|:----:|:----:|:------:|------|
| 0x010 | SCAN_START_FREQ | R/W | 32 | 0x00000000 | 扫描起始频率 |
| 0x014 | SCAN_STOP_FREQ | R/W | 32 | 0x00000000 | 扫描终止频率 |
| 0x018 | SCAN_STEP | R/W | 32 | 0x00000000 | 扫描步进 |
| 0x01C | SCAN_DWELL | R/W | 32 | 0x000003E8 | 驻留时间（默认1000） |
| 0x020 | SCAN_POINTS | R/W | 32 | 0x00000000 | 扫描总点数（PS预计算） |
| 0x024 | SCAN_CTRL | R/W | 32 | 0x00000000 | 扫描控制寄存器 |

#### SCAN_CTRL寄存器位域

| 位域 | 名称 | R/W | 说明 |
|:----:|------|:---:|------|
| [0] | START | R/W | 写1启动扫描（自清零） |
| [1] | STOP | R/W | 写1停止扫描（自清零） |
| [31:2] | Reserved | - | 保留 |

### 3.4 数据读取

| 地址 | 名称 | 类型 | 位宽 | 说明 |
|:----:|------|:----:|:----:|------|
| 0x028 | ADC_DATA | R | 32 | ADC采集数据（[15:0]有效） |
| 0x02C | LIA_MAG | R | 32 | 锁相幅值（[15:0]有效） |
| 0x030 | LIA_PHASE | R | 32 | 锁相相位（[15:0]有效） |
| 0x034 | IIR_DATA | R | 32 | IIR滤波数据（[15:0]有效） |
| 0x038 | POINT_COUNT | R | 32 | 当前扫描点计数 |
| 0x03C | CURRENT_FREQ | R | 32 | 当前DDS输出频率 |

---

## 四、架构图

```
PS7 (ARM Cortex-A9)
    │
    ├── M_AXI_GP0 (AXI4 Master)
    │       │
    │   AXI Interconnect
    │       │
    │   top_odmr_axi (AXI4-Lite Slave)
    │       │
    │       ├── CTRL/STATUS → 全局控制
    │       ├── DDS_FREQ/PHASE → dds_generator
    │       ├── SCAN_* → scan_controller
    │       ├── ADC_DATA → adc_interface
    │       ├── LIA_MAG/PHASE → cordic_lia
    │       └── IIR_DATA → iir_lowpass
    │
    ├── FCLK_CLK0 (50MHz) → PL时钟
    └── FCLK_RESET0_N → PL复位
```

---

## 五、实现要求

### 5.1 对@H的要求

1. 在`top_odmr.vhd`中新增AXI-Lite从接口端口
2. 内部实现AXI-Lite读写逻辑（地址解码+寄存器映射）
3. 各子模块保持不变，通过内部信号连接
4. 时钟/复位改为从AXI接口获取

### 5.2 对@S的要求

1. PYNQ Overlay自动识别AXI-Lite IP
2. 通过`overlay.ip_dict`获取地址映射
3. 直接读写寄存器地址控制PL端

### 5.3 约束

- 地址空间: 4KB (12位地址)
- 总线宽度: 32位
- 时钟频率: 50MHz
- 无DMA（V1阶段不需要，数据量小）

---

## 六、@V审核

| 检查项 | 状态 |
|--------|:----:|
| 接口信号完整 | ✅ |
| 地址映射无冲突 | ✅ |
| 位域定义清晰 | ✅ |
| 符合AXI4-Lite协议 | ✅ |
| 符合arch_base设计原则 | ✅ |

**@V签字**: ____________  **日期**: 2026-05-20
