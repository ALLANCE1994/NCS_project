# NV项目硬件设计错题库

> 本文件记录Vivado/TCL使用中的典型错误及解决方案
> 负责智能体：【@H 硬件工程师】
> 更新日期：2026-05-19

---

## 错误记录

### HW-2026-001: Block Design端口未分配IOSTANDARD和LOC约束

**发现日期**: 2026-05-19  
**发现场景**: Vivado Bitstream生成阶段  
**错误类型**: DRC设计规则检查失败

---

#### 错误信息

```
[DRC NSTD-1] Unspecified I/O Standard: 57 out of 57 logical ports 
use I/O standard (IOSTANDARD) value 'DEFAULT', instead of a user 
assigned specific value.

[DRC UCIO-1] Unconstrained Logical Port: 57 out of 57 logical 
ports have no user assigned specific location constraint (LOC).
```

#### 问题端口列表

| 端口类型 | 端口名 | 位宽 |
|----------|--------|:----:|
| 数据端口 | data_out | 8 |
| 计数端口 | sample_cnt | 32 |
| 速率端口 | sample_rate | 8 |
| ADC接口 | adc_clk, adc_oe_n | - |
| FIFO接口 | data_ready, data_valid, fifo_empty, fifo_full | - |
| 控制信号 | rst_n, sample_en, sys_clk | - |

**总计**: 57个端口

---

#### 根因分析

| 错误类型 | 说明 |
|----------|------|
| **遗漏型错误** | Block Design端口创建后未分配IOSTANDARD |
| **遗漏型错误** | Block Design端口创建后未分配引脚位置(LOC) |
| **设计不规范** | VHDL模块的端口未与顶层端口正确映射 |

---

#### 解决方案

**方案1: 在TCL脚本中添加完整约束**

```tcl
# 创建端口时指定IOSTANDARD
create_bd_port -dir O -from 7 -to 0 data_out
set_property CONFIG.IS_LVCMOS33 true [get_bd_ports data_out]

# 创建端口时指定LOC（示例，需根据实际开发板调整）
create_bd_port -dir I sys_clk
set_property CONFIG.LOC "H16" [get_bd_ports sys_clk]
```

**方案2: 创建完整XDC约束文件**

```tcl
# NV ODMR系统引脚约束
# ADC接口
set_property PACKAGE_PIN W13 [get_ports {adc_clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_clk}]
set_property PACKAGE_PIN U12 [get_ports adc_oe_n]
set_property IOSTANDARD LVCMOS33 [get_ports adc_oe_n]

# 数据端口
set_property PACKAGE_PIN V17 [get_ports {data_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_out[*]}]

# FIFO接口
set_property PACKAGE_PIN W16 [get_ports data_ready]
set_property IOSTANDARD LVCMOS33 [get_ports data_ready]

# 控制信号
set_property PACKAGE_PIN U18 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
```

**方案3: 在综合前使用set_property批量设置**

```tcl
# 设置所有未约束端口为LVCMOS33
set_property IOSTANDARD LVCMOS33 [get_ports [list \
    data_out[*] sample_cnt[*] sample_rate[*] \
    adc_clk adc_oe_n data_ready data_valid \
    fifo_empty fifo_full rst_n sample_en sys_clk \
]]
```

---

#### 预防措施

| 措施 | 说明 |
|------|------|
| **创建端口时立即设置约束** | 在create_bd_port后立即设置IOSTANDARD和LOC |
| **建立约束模板** | 为不同类型的端口建立标准约束模板 |
| **综合前检查** | 运行`report_property [get_ports]`检查未约束端口 |
| **使用BD自动化** | 使用`apply_bd_automation`时选择board preset |

---

#### 知识来源

- Xilinx UG835 Vivado TCL Command Reference
- 正点原子领航者ZYNQ7020原理图
- Xilinx 7 Series FPGA SelectIO Resources (UG471)

---

#### 相关文件

- `create_project.tcl` - 需要添加端口约束
- `constraints.xdc` - 约束文件路径

---

## 常见DRC错误速查表

| 错误代码 | 错误名称 | 解决方案 |
|:--------:|----------|----------|
| NSTD-1 | 未指定I/O标准 | set_property IOSTANDARD |
| UCIO-1 | 未指定引脚位置 | set_property LOC |
| RPBF-1 | Block RAM端口未连接 | 连接所有端口或忽略 |
| SYNTH-8 | 时序约束缺失 | 添加时序约束 |
| TIMING-9 | 建立/保持时间违例 | 优化时序路径 |

---

### HW-2026-002: 硬件工程师任务规划不完整

**发现日期**: 2026-05-19  
**发现人**: @C老板  
**发现场景**: 审查Vivado工程构建脚本

---

#### 问题描述

| 问题项 | 说明 |
|--------|------|
| **遗漏交付物** | TCL脚本中未包含约束文件(XDC) |
| **规划缺失** | 只规划了Block Design，未规划引脚约束 |
| **违反规则** | P1_03规划深度、P1_04上下文质量、@H硬件工程师职责 |

#### 违反的规则

| 规则编号 | 规则内容 | 违反情况 |
|----------|----------|----------|
| P1_03 | 规划深度 - 任务拆解必须包含所有子任务 | ❌ 未规划约束文件 |
| P1_04 | 上下文质量 - 输出必须完整 | ❌ 交付物不完整 |
| @H职责 | 引脚约束是硬件工程师基本工作 | ❌ 遗漏引脚约束 |

#### 根因分析

| 原因 | 说明 |
|------|------|
| **规划疏忽** | TCL脚本规划时只关注Block Design |
| **知识盲区** | 认为约束可以在GUI中手动添加 |
| **自检缺失** | 未按P1_02三层回滚防线自检 |

#### 解决方案

**立即补全约束文件**：

| 文件 | 内容 | 状态 |
|------|------|:----:|
| `01_pins.xdc` | 引脚约束 | ✅ 已创建 |
| `02_timing.xdc` | 时序约束 | ✅ 已创建 |
| `03_config.xdc` | 配置约束 | ✅ 已创建 |

#### 预防措施

| 措施 | 说明 |
|------|------|
| **建立检查清单** | 硬件工程任务必须包含约束文件 |
| **任务规划模板** | 明确列出所有交付物 |
| **@V审核** | 任务规划提交前必须经过@V审核 |

#### 相关文件

- `constraints/01_pins.xdc` - 引脚约束 ✅
- `constraints/02_timing.xdc` - 时序约束 ✅
- `constraints/03_config.xdc` - 配置约束 ✅

---

**最后更新**: 2026-05-19  
**维护责任人**: 【@H 硬件工程师】, 【@V 工程规则管理师】
