# NV色心实验系统 - 系统架构设计

> **文档版本**：V1.0  
> **日期**：2026-05-19  
> **作者**：@A 架构师  
> **评审人**：@V @P

---

## 一、系统概述

### 1.1 设计目标

构建一个基于ZYNQ7020的NV色心ODMR实验控制系统，实现：
- 微波脉冲精确控制（10ns分辨率）
- 光子计数与Lock-in解调
- 频率扫描与数据采集
- 实时反馈控制

### 1.2 设计原则

| 原则 | 说明 |
|------|------|
| 模块化 | 各功能模块独立，接口标准化 |
| 实时性 | PL端硬实时，PS端软实时 |
| 可扩展 | 预留接口，支持功能扩展 |
| 可靠性 | 跨时钟域处理，异常保护 |

---

## 二、系统架构图

```mermaid
graph TB
    subgraph PS["PS端 - 软件控制"]
        CPU["ARM Cortex-A9<br/>Linux + PYNQ"]
        DMA["DMA控制器"]
        ETH["以太网<br/>远程控制"]
    end
    
    subgraph PL["PL端 - 硬件逻辑"]
        subgraph AXI["AXI Interconnect"]
            AXILite["AXI4-Lite<br/>寄存器控制"]
            AXIStream["AXI4-Stream<br/>数据流"]
        end
        
        subgraph CORE["核心功能模块"]
            DDS["DDS信号发生器<br/>M3.1"]
            ADC["ADC采集接口<br/>M3.2"]
            CORDIC["CORDIC数字锁相<br/>M3.3"]
            SCAN["扫描状态机<br/>M3.4"]
            IIR["IIR低通滤波<br/>M3.5"]
        end
        
        subgraph IO["I/O接口"]
            DDS_IO["DDS输出<br/>14-bit"]
            ADC_IO["ADC输入<br/>16-bit"]
            SCAN_IO["扫描控制"]
        end
    end
    
    subgraph EXT["外部设备"]
        AD9910["AD9910 DDS"]
        APD["APD探测器"]
        AMP["微波放大器"]
        MAGNET["磁场线圈"]
    end
    
    CPU --> AXILite
    AXILite --> DDS
    AXILite --> ADC
    AXILite --> CORDIC
    AXILite --> SCAN
    AXILite --> IIR
    
    DDS --> DDS_IO --> AD9910 --> AMP
    ADC_IO --> ADC --> APD
    SCAN --> SCAN_IO --> MAGNET
    
    ADC --> CORDIC --> IIR --> DMA --> CPU
    
    ETH -.-> CPU
```

---

## 三、模块划分

### 3.1 模块清单

| 模块名 | 功能 | 负责人 | 状态 |
|--------|------|--------|:----:|
| top_odmr | 顶层模块，集成所有子模块 | @H | M3.0 |
| dds_generator | DDS信号发生器控制 | @H | M3.1 |
| adc_interface | ADC数据采集接口 | @H | M3.2 |
| cordic_lockin | CORDIC数字锁相放大 | @H | M3.3 |
| scan_controller | 频率扫描状态机 | @H | M3.4 |
| iir_filter | IIR低通滤波器 | @H | M3.5 |
| axi_reg_if | AXI寄存器接口 | @S @H | M3.0 |

### 3.2 模块关系图

```mermaid
graph LR
    A[top_odmr] --> B[dds_generator]
    A --> C[adc_interface]
    A --> D[cordic_lockin]
    A --> E[scan_controller]
    A --> F[iir_filter]
    A --> G[axi_reg_if]
    
    G -.-> B
    G -.-> C
    G -.-> D
    G -.-> E
    G -.-> F
    
    C --> D --> F
    E -.-> B
```

---

## 四、数据流设计

### 4.1 控制流（PS→PL）

```
用户 → Jupyter Notebook → Python驱动 → AXI寄存器 → 各功能模块
```

### 4.2 数据流（PL→PS）

```
ADC → CORDIC → IIR → DMA → DDR → Python → Jupyter → 用户
```

### 4.3 数据流图

```mermaid
flowchart LR
    subgraph Control["控制流（下行）"]
        direction TB
        C1[实验参数] --> C2[Python驱动]
        C2 --> C3[AXI写寄存器]
        C3 --> C4[DDS频率]
        C3 --> C5[扫描参数]
        C3 --> C6[Lock-in配置]
    end
    
    subgraph Data["数据流（上行）"]
        direction TB
        D1[ADC原始数据] --> D2[CORDIC解调]
        D2 --> D3[IIR滤波]
        D3 --> D4[DMA传输]
        D4 --> D5[Python处理]
        D5 --> D6[HDF5存储]
    end
```

---

## 五、时钟架构

### 5.1 时钟树

```mermaid
graph TB
    subgraph CLK["时钟树"]
        OSC["50MHz晶振<br/>板载"]
        PSCLK["PS FCLK_CLK0<br/>100MHz"]
        
        OSC --> PLL["PLLE2_ADV<br/>时钟管理"]
        PLL --> CLK100["sys_clk<br/>100MHz"]
        PLL --> CLK50["adc_div_clk<br/>50MHz"]
        
        PSCLK --> AXI_CLK["axi_aclk<br/>100MHz"]
    end
    
    CLK100 --> DDS_CLK["DDS模块"]
    CLK100 --> SCAN_CLK["扫描模块"]
    CLK100 --> CORDIC_CLK["CORDIC模块"]
    CLK100 --> IIR_CLK["IIR模块"]
    
    AXI_CLK --> AXI_REG["AXI寄存器"]
```

### 5.2 时钟域划分

| 时钟域 | 频率 | 用途 | 模块 |
|--------|------|------|------|
| sys_clk | 100MHz | 主系统时钟 | DDS, SCAN, CORDIC, IIR |
| axi_clk | 100MHz | AXI接口时钟 | AXI寄存器 |
| adc_clk | 50MHz | ADC采样时钟 | ADC接口 |

### 5.3 跨时钟域处理

| 跨时钟域路径 | 处理方法 | 说明 |
|--------------|----------|------|
| sys_clk → adc_clk | 异步FIFO | ADC数据缓冲 |
| adc_clk → sys_clk | 握手同步 | 控制信号同步 |
| axi_clk → sys_clk | 双触发器 | 寄存器控制 |

---

## 六、复位策略

### 6.1 复位树

```mermaid
graph TB
    RST["外部复位<br/>sys_rst_n"]
    
    RST --> PS_RST["PS复位<br/>peripheral_aresetn"]
    RST --> PL_RST["PL复位<br/>rst_sync"]
    
    PL_RST --> RST100["sys_rst_n<br/>100MHz域"]
    PL_RST --> RST50["adc_rst_n<br/>50MHz域"]
    
    PS_RST --> AXI_RST["axi_aresetn<br/>AXI域"]
```

### 6.2 复位策略表

| 复位域 | 复位源 | 同步方式 | 释放顺序 |
|--------|--------|----------|----------|
| 全局复位 | 外部按键 | 异步复位同步释放 | 第1 |
| PS复位 | PS端输出 | 异步复位同步释放 | 第2 |
| PL系统复位 | 全局复位同步 | 同步复位 | 第3 |
| AXI复位 | PS复位 | 同步复位 | 第4 |

---

## 七、版本历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| V1.0 | 2026-05-19 | 初始版本 | @A |

---

**下一步：模块接口定义文档**
