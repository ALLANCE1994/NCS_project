# NV色心实验系统 - AXI寄存器映射表

> **文档版本**：V1.0  
> **日期**：2026-05-19  
> **作者**：@S 软件工程师 / @A 架构师  
> **评审人**：@V @P

---

## 一、寄存器概览

| 地址偏移 | 名称 | 类型 | 位宽 | 说明 |
|----------|------|------|------|------|
| 0x00 | CTRL | R/W | 32 | 全局控制寄存器 |
| 0x04 | STATUS | RO | 32 | 状态寄存器 |
| 0x08 | DDS_FREQ | R/W | 32 | DDS频率控制字 |
| 0x0C | DDS_PHASE | R/W | 32 | DDS相位偏移 |
| 0x10 | SCAN_START | R/W | 32 | 扫描起始频率 |
| 0x14 | SCAN_STOP | R/W | 32 | 扫描终止频率 |
| 0x18 | SCAN_STEP | R/W | 32 | 扫描步进 |
| 0x1C | SCAN_DWELL | R/W | 32 | 扫描驻留时间 |
| 0x20 | SCAN_CTRL | R/W | 32 | 扫描控制寄存器 |
| 0x24 | CORDIC_CTRL | R/W | 32 | CORDIC控制寄存器 |
| 0x28 | IIR_COEFF_A | R/W | 32 | IIR滤波器系数A |
| 0x2C | IIR_COEFF_B | R/W | 32 | IIR滤波器系数B |
| 0x30 | DATA_AMPLITUDE | RO | 32 | 解调幅值数据 |
| 0x34 | DATA_PHASE | RO | 32 | 解调相位数据 |
| 0x38 | INT_MASK | R/W | 32 | 中断屏蔽寄存器 |
| 0x3C | INT_STATUS | RO | 32 | 中断状态寄存器 |
| 0x40 | VERSION | RO | 32 | 版本寄存器 |

---

## 二、寄存器详细定义

### 2.1 CTRL - 全局控制寄存器 (0x00)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 0 | GLOBAL_EN | R/W | 0 | 全局使能 |
| 1 | DDS_EN | R/W | 0 | DDS使能 |
| 2 | ADC_EN | R/W | 0 | ADC采集使能 |
| 3 | CORDIC_EN | R/W | 0 | CORDIC锁相使能 |
| 4 | IIR_EN | R/W | 0 | IIR滤波使能 |
| 5 | DMA_EN | R/W | 0 | DMA传输使能 |
| 7:6 | Reserved | - | 0 | 保留 |
| 15:8 | LED_CTRL | R/W | 0 | LED控制（2位有效） |
| 31:16 | Reserved | - | 0 | 保留 |

### 2.2 STATUS - 状态寄存器 (0x04)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 0 | READY | RO | 0 | 系统就绪 |
| 1 | DDS_BUSY | RO | 0 | DDS更新中 |
| 2 | SCAN_BUSY | RO | 0 | 扫描进行中 |
| 3 | DATA_VALID | RO | 0 | 数据有效 |
| 4 | ADC_OVR | RO | 0 | ADC溢出指示 |
| 5 | DMA_BUSY | RO | 0 | DMA传输中 |
| 7:6 | Reserved | - | 0 | 保留 |
| 15:8 | KEY_STATUS | RO | 0 | 按键状态（2位有效） |
| 31:16 | Reserved | - | 0 | 保留 |

### 2.3 DDS_FREQ - DDS频率控制字 (0x08)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 31:0 | FREQ_WORD | R/W | 0 | 频率控制字（32位） |

**计算公式：**
```
输出频率 = FREQ_WORD × f_clk / 2^32
其中 f_clk = 100MHz
```

**示例：**
- 2.87GHz输出（AD9910）：FREQ_WORD = 0xB3333333
- 频率分辨率：0.023Hz（100MHz/2^32）

### 2.4 DDS_PHASE - DDS相位偏移 (0x0C)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 31:0 | PHASE_OFFSET | R/W | 0 | 相位偏移（32位） |

### 2.5 SCAN_START - 扫描起始频率 (0x10)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 31:0 | START_FREQ | R/W | 0 | 扫描起始频率控制字 |

### 2.6 SCAN_STOP - 扫描终止频率 (0x14)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 31:0 | STOP_FREQ | R/W | 0 | 扫描终止频率控制字 |

### 2.7 SCAN_STEP - 扫描步进 (0x18)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 31:0 | STEP_FREQ | R/W | 0 | 扫描步进频率控制字 |

### 2.8 SCAN_DWELL - 扫描驻留时间 (0x1C)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 15:0 | DWELL_TIME | R/W | 1000 | 驻留时间（10ns单位） |
| 31:16 | Reserved | - | 0 | 保留 |

**示例：**
- DWELL_TIME = 1000 → 10μs驻留
- DWELL_TIME = 10000 → 100μs驻留

### 2.9 SCAN_CTRL - 扫描控制寄存器 (0x20)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 0 | SCAN_EN | R/W | 0 | 扫描使能（上升沿触发） |
| 1 | SCAN_MODE | R/W | 0 | 扫描模式：0=单次，1=连续 |
| 2 | SCAN_DIR | R/W | 0 | 扫描方向：0=增频，1=减频 |
| 3 | SCAN_TRIG | WO | 0 | 软件触发扫描（写1触发） |
| 4 | SCAN_ABORT | WO | 0 | 中止扫描（写1中止） |
| 7:5 | Reserved | - | 0 | 保留 |
| 15:8 | SYNC_SEL | R/W | 0 | 同步源选择 |
| 31:16 | Reserved | - | 0 | 保留 |

### 2.10 CORDIC_CTRL - CORDIC控制寄存器 (0x24)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 7:0 | ITER_NUM | R/W | 16 | CORDIC迭代次数 |
| 15:8 | Reserved | - | 0 | 保留 |
| 31:16 | REF_PHASE | R/W | 0 | 参考相位（16位） |

### 2.11 IIR_COEFF_A - IIR滤波器系数A (0x28)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 15:0 | COEFF_A0 | R/W | 0x4000 | 系数A0（1.0 in Q14） |
| 31:16 | COEFF_A1 | R/W | 0x0000 | 系数A1 |

### 2.12 IIR_COEFF_B - IIR滤波器系数B (0x2C)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 15:0 | COEFF_B0 | R/W | 0x2000 | 系数B0（0.5 in Q14） |
| 31:16 | COEFF_B1 | R/W | 0x2000 | 系数B1（0.5 in Q14） |

### 2.13 DATA_AMPLITUDE - 解调幅值数据 (0x30)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 31:0 | AMPLITUDE | RO | 0 | CORDIC解调幅值（32位） |

### 2.14 DATA_PHASE - 解调相位数据 (0x34)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 31:0 | PHASE | RO | 0 | CORDIC解调相位（32位） |

### 2.15 INT_MASK - 中断屏蔽寄存器 (0x38)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 0 | MASK_SCAN_DONE | R/W | 0 | 屏蔽扫描完成中断 |
| 1 | MASK_DATA_READY | R/W | 0 | 屏蔽数据就绪中断 |
| 2 | MASK_DMA_DONE | R/W | 0 | 屏蔽DMA完成中断 |
| 3 | MASK_ADC_OVR | R/W | 0 | 屏蔽ADC溢出中断 |
| 31:4 | Reserved | - | 0 | 保留 |

### 2.16 INT_STATUS - 中断状态寄存器 (0x3C)

| 位 | 名称 | 类型 | 默认值 | 说明 | 优先级 |
|----|------|------|--------|------|:------:|
| 0 | INT_SCAN_DONE | RO | 0 | 扫描完成中断 | 2 |
| 1 | INT_DATA_READY | RO | 0 | 数据就绪中断 | 3 |
| 2 | INT_DMA_DONE | RO | 0 | DMA完成中断 | 1（最高） |
| 3 | INT_ADC_OVR | RO | 0 | ADC溢出中断 | 0（最低） |
| 31:4 | Reserved | - | 0 | 保留 | - |

**注意：** 读此寄存器自动清除中断标志

---

## 三、中断优先级定义

### 3.1 优先级分配表

| 优先级 | 中断源 | 说明 | 响应要求 |
|:------:|--------|------|----------|
| 1（最高） | INT_DMA_DONE | DMA传输完成 | 必须立即响应，避免数据丢失 |
| 2 | INT_SCAN_DONE | 扫描完成 | 及时响应，准备下一次扫描 |
| 3 | INT_DATA_READY | 数据就绪 | 正常响应，读取解调数据 |
| 0（最低） | INT_ADC_OVR | ADC溢出 | 可延迟处理，记录错误状态 |

### 3.2 优先级仲裁逻辑

```
中断仲裁器（固定优先级）
    │
    ├─ 优先级1: DMA_DONE ─────┐
    ├─ 优先级2: SCAN_DONE ────┼─> 中断向量输出
    ├─ 优先级3: DATA_READY ───┤
    └─ 优先级0: ADC_OVR ──────┘
```

**仲裁规则：**
- 固定优先级，DMA完成中断最高
- 同周期多中断：高优先级先响应
- 中断嵌套：高优先级可打断低优先级

### 3.3 软件中断处理建议

```python
# 中断处理优先级（PYNQ示例）
def interrupt_handler(irq_status):
    if irq_status & 0x04:      # 优先级1: DMA完成
        handle_dma_done()
        return                  # 高优先级处理完可返回
    
    if irq_status & 0x01:      # 优先级2: 扫描完成
        handle_scan_done()
    
    if irq_status & 0x02:      # 优先级3: 数据就绪
        handle_data_ready()
    
    if irq_status & 0x08:      # 优先级0: ADC溢出
        handle_adc_overflow()
```

---

## 四、DMA通道配置

### 4.1 DMA通道数确认

**确认结果：2通道DMA**

| 通道 | 方向 | 用途 | 数据宽度 | 缓冲区大小 |
|:----:|:----:|------|:--------:|:----------:|
| CH0 | PL→PS | 解调数据（幅值+相位） | 64bit | 8KB |
| CH1 | PL→PS | 原始ADC数据（调试/标定） | 32bit | 4KB |

### 4.2 通道详细配置

#### CH0 - 解调数据传输

| 参数 | 配置值 | 说明 |
|------|--------|------|
| 通道类型 | AXI DMA SG（Scatter-Gather） | 支持连续数据传输 |
| 数据宽度 | 64bit | 幅值(32bit) + 相位(32bit) |
| 突发长度 | 16 | 优化DDR写入效率 |
| 缓冲区 | 双缓冲（Ping-Pong） | 8KB × 2 |
| 中断方式 | 每帧完成中断 | 通知软件读取数据 |

#### CH1 - 原始ADC数据（可选）

| 参数 | 配置值 | 说明 |
|------|--------|------|
| 通道类型 | AXI DMA Simple | 简单传输模式 |
| 数据宽度 | 32bit | ADC原始数据 |
| 突发长度 | 8 | 标定/调试使用 |
| 缓冲区 | 单缓冲 | 4KB |
| 中断方式 | 按需触发 | 非正常运行模式 |

### 4.3 DMA与AXI寄存器映射关系

```
┌─────────────────────────────────────────────────────────┐
│                      PS (Zynq)                          │
│  ┌─────────────┐    AXI GP    ┌─────────────────────┐   │
│  │   CPU       │◄────────────►│  AXI Register Block │   │
│  │             │              │  (控制寄存器)        │   │
│  └─────────────┘              └─────────────────────┘   │
│         ▲                                               │
│         │ 中断信号                                       │
│         │ INT_DMA_DONE                                   │
│         ▼                                               │
│  ┌─────────────┐    AXI HP    ┌─────────────────────┐   │
│  │  DMA CH0    │◄────────────►│  PL Data FIFO       │   │
│  │  (解调数据)  │              │  (幅值+相位)         │   │
│  └─────────────┘              └─────────────────────┘   │
│  ┌─────────────┐              ┌─────────────────────┐   │
│  │  DMA CH1    │◄────────────►│  PL ADC FIFO        │   │
│  │  (原始ADC)   │              │  (调试模式)          │   │
│  └─────────────┘              └─────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 4.4 DMA控制寄存器位定义

在 **CTRL寄存器 (0x00)** 中DMA相关位：

| 位 | 名称 | 说明 |
|----|------|------|
| 5 | DMA_EN | DMA全局使能 |
| 8 | DMA_CH0_EN | CH0（解调数据）使能 |
| 9 | DMA_CH1_EN | CH1（原始ADC）使能 |

在 **INT_MASK/INT_STATUS** 中DMA中断位：

| 位 | 名称 | 说明 |
|----|------|------|
| 2 | DMA_DONE | DMA传输完成（CH0或CH1） |
| 10 | DMA_CH0_DONE | CH0单独完成（可选） |
| 11 | DMA_CH1_DONE | CH1单独完成（可选） |

### 2.17 VERSION - 版本寄存器 (0x40)

| 位 | 名称 | 类型 | 默认值 | 说明 |
|----|------|------|--------|------|
| 7:0 | VER_MAJOR | RO | 0x01 | 主版本号 |
| 15:8 | VER_MINOR | RO | 0x00 | 次版本号 |
| 31:16 | VER_PATCH | RO | 0x0000 | 补丁版本号 |

---

## 五、寄存器访问示例

### 5.1 Python访问示例（PYNQ）

```python
from pynq import Overlay

# 加载Overlay
ol = Overlay('nv_odmr.bit')

# 获取寄存器访问对象
regs = ol.nv_odmr.register_map

# 使能系统
regs.CTRL = 0x01  # GLOBAL_EN = 1

# 设置DDS频率（2.87GHz）
regs.DDS_FREQ = 0xB3333333

# 设置扫描参数
regs.SCAN_START = 0xA0000000  # 2.68GHz
regs.SCAN_STOP = 0xC6666666   # 3.06GHz
regs.SCAN_STEP = 0x00147AE1   # 1MHz步进
regs.SCAN_DWELL = 10000       # 100μs驻留

# 启动扫描
regs.SCAN_CTRL = 0x09  # SCAN_EN=1, SCAN_TRIG=1

# 等待扫描完成
while not (regs.STATUS & 0x01):
    pass

# 读取解调数据
amplitude = regs.DATA_AMPLITUDE
phase = regs.DATA_PHASE
```

### 5.2 寄存器地址宏定义（C/C++）

```c
// 寄存器基地址
#define NV_ODMR_BASE_ADDR 0x43C00000

// 寄存器偏移
#define REG_CTRL         0x00
#define REG_STATUS       0x04
#define REG_DDS_FREQ     0x08
#define REG_DDS_PHASE    0x0C
#define REG_SCAN_START   0x10
#define REG_SCAN_STOP    0x14
#define REG_SCAN_STEP    0x18
#define REG_SCAN_DWELL   0x1C
#define REG_SCAN_CTRL    0x20
#define REG_CORDIC_CTRL  0x24
#define REG_IIR_COEFF_A  0x28
#define REG_IIR_COEFF_B  0x2C
#define REG_DATA_AMP     0x30
#define REG_DATA_PHASE   0x34
#define REG_INT_MASK     0x38
#define REG_INT_STATUS   0x3C
#define REG_VERSION      0x40
```

---

## 六、版本历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| V1.0 | 2026-05-19 | 初始版本 | @S @A |
| V1.1 | 2026-05-19 | 补充中断优先级定义、DMA通道配置 | @S |

---

**【知识来源】**
- M2合规检查报告 - 整改项4：中断定义需补充优先级
- M2合规检查报告 - 整改项5：需确认DMA通道数
- 系统架构设计 - PS-PL数据流规划
