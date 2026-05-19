# NV色心实验系统 - 时序预算分析

> **文档版本**: V1.0  
> **日期**: 2026-05-19  
> **作者**: @H 硬件工程师  
> **评审人**: @A @V

---

## 一、时钟定义

### 1.1 时钟源

| 时钟名 | 频率 | 周期 | 来源 | 用途 |
|--------|------|------|------|------|
| sys_clk | 100MHz | 10ns | PLL (50MHz×2) | 主系统时钟 |
| axi_clk | 100MHz | 10ns | PS FCLK_CLK0 | AXI接口时钟 |
| adc_clk | 50MHz | 20ns | PLL分频 | ADC采样时钟 |

### 1.2 时钟关系

```
50MHz晶振 → PLL → 100MHz sys_clk
              ↓
            PS FCLK → 100MHz axi_clk (与sys_clk异步)
              ↓
            分频器 → 50MHz adc_clk
```

---

## 二、时序约束目标

| 参数 | 目标值 | 说明 |
|------|--------|------|
| WNS (Worst Negative Slack) | > 1ns | 最差负裕量 |
| TNS (Total Negative Slack) | = 0 | 总负裕量 |
| 建立时间裕量 | > 2ns | Setup Slack |
| 保持时间裕量 | > 0.5ns | Hold Slack |

---

## 三、关键时序路径分析

### 3.1 路径1: 系统时钟域 (100MHz)

| 起点 | 终点 | 延迟预算 | 估计延迟 | 裕量 | 状态 |
|------|------|----------|----------|------|:----:|
| DDS寄存器 | DDS输出 | 8ns | 5ns | 3ns | ✅ |
| AXI寄存器 | 模块控制 | 8ns | 4ns | 4ns | ✅ |
| 扫描状态机 | 频率更新 | 10ns | 6ns | 4ns | ✅ |
| CORDIC输入 | CORDIC输出 | 10ns | 8ns | 2ns | ✅ |

### 3.2 路径2: AXI接口 (100MHz)

| 参数 | 值 | 说明 |
|------|-----|------|
| 时钟周期 | 10ns | axi_aclk |
| 输入建立时间 | 3ns | Tis |
| 输入保持时间 | 0ns | Tih |
| 输出延迟 | 2ns | Tco |

### 3.3 路径3: ADC接口 (50MHz)

| 参数 | 值 | 说明 |
|------|-----|------|
| ADC时钟周期 | 20ns | adc_clk |
| ADC数据建立时间 | 5ns | 外部ADC要求 |
| ADC数据保持时间 | 2ns | 外部ADC要求 |
| 跨时钟域延迟 | 2ns | FIFO同步 |

---

## 四、输入/输出延迟约束

### 4.1 输入延迟

| 信号 | 时钟 | Max Delay | Min Delay |
|------|------|-----------|-----------|
| adc_data_in[15:0] | adc_clk | 8ns | 2ns |
| adc_valid | adc_clk | 8ns | 2ns |
| adc_ovr | adc_clk | 8ns | 2ns |
| key[1:0] | sys_clk | 5ns | 0ns |
| scan_sync | sys_clk | 5ns | 0ns |

### 4.2 输出延迟

| 信号 | 时钟 | Max Delay | Min Delay |
|------|------|-----------|-----------|
| dds_data_out[13:0] | sys_clk | 3ns | 0ns |
| dds_clk_out | sys_clk | 3ns | 0ns |
| dds_valid | sys_clk | 3ns | 0ns |
| scan_trigger | sys_clk | 5ns | 0ns |
| led[1:0] | sys_clk | 2ns | 0ns |

---

## 五、跨时钟域处理

### 5.1 CDC路径

| 源时钟 | 目标时钟 | 信号 | 处理方法 |
|--------|----------|------|----------|
| adc_clk | sys_clk | adc_data | 异步FIFO |
| adc_clk | sys_clk | adc_valid | 握手同步 |
| axi_clk | sys_clk | 控制寄存器 | 双触发器 |
| sys_clk | axi_clk | 状态寄存器 | 双触发器 |

### 5.2 虚假路径

```tcl
# 复位信号不做时序检查
set_false_path -from [get_ports sys_rst_n]
set_false_path -from [get_ports s_axi_aresetn]

# LED指示不做严格时序要求
set_false_path -to [get_ports {led[*]}]
```

---

## 六、时序收敛策略

### 6.1 设计优化

| 策略 | 应用模块 | 说明 |
|------|----------|------|
| 流水线 | CORDIC | 插入寄存器，减少组合延迟 |
| 并行处理 | DDS | 相位累加与LUT查找并行 |
| 寄存器输出 | 所有模块 | 输出打一拍，改善时序 |

### 6.2 约束优化

| 策略 | 说明 |
|------|------|
| 多周期路径 | 扫描状态机允许多周期更新 |
| 虚假路径 | 明确设置无需检查的路径 |
| 时钟分组 | 异步时钟域正确分组 |

---

## 七、时序报告预期

### 7.1 综合后时序

| 检查项 | 预期结果 |
|--------|----------|
| WNS | > 2ns |
| TNS | 0 |
| 失败路径数 | 0 |

### 7.2 实现后时序

| 检查项 | 预期结果 |
|--------|----------|
| WNS | > 1ns |
| TNS | 0 |
| 失败路径数 | 0 |

---

## 八、版本历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| V1.0 | 2026-05-19 | 初始版本 | @H |

---

**下一步: 软件架构规划 (@S)**
