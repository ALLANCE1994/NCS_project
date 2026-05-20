# FPGA+ZYNQ平台通用开发常识

> **适用角色**：资深硬件工程师  
> **知识类型**：通用基础能力  
> **更新日期**：2026-05-16

---

## 一、FPGA基础概念

### 1.1 FPGA架构概述

**FPGA**（Field Programmable Gate Array）是一种可编程逻辑器件，由可配置逻辑块、互连资源和IO块组成。

```
基本组成：
- CLB（可配置逻辑块）：实现组合和时序逻辑
- BRAM（块RAM）：片上存储资源
- DSP（数字信号处理）：专用乘法器/累加器
- IOB（输入输出块）：外部接口
- 互连资源：连接各组件
```

### 1.2 开发流程

```
1. 需求分析
   ↓
2. 系统设计
   ↓
3. RTL编码（VHDL/Verilog）
   ↓
4. 功能仿真
   ↓
5. 综合（Synthesis）
   ↓
6. 实现（Implementation）
   ↓
7. 时序分析
   ↓
8. 比特流生成
   ↓
9. 下载调试
```

### 1.3 资源类型

| 资源 | 功能 | 典型用途 |
|------|------|----------|
| LUT | 查找表，实现组合逻辑 | 逻辑函数、状态机 |
| FF | 触发器，存储状态 | 时序逻辑、流水线 |
| BRAM | 块存储器 | FIFO、缓存、查找表 |
| DSP | 数字信号处理单元 | 乘法、FIR滤波、FFT |
| IO | 输入输出 | 外部接口、电平转换 |
| CLK | 时钟资源 | 时钟分配、PLL |

---

## 二、ZYNQ平台特性

### 2.1 ZYNQ架构

```
ZYNQ = PS（Processing System）+ PL（Programmable Logic）

PS（处理系统）：
- ARM Cortex-A9双核处理器
- 外设控制器（USB、ETH、SD等）
- DDR控制器
- 中断控制器

PL（可编程逻辑）：
- 传统FPGA资源
- 与PS通过AXI总线互联
```

### 2.2 PS-PL接口

#### AXI接口类型
```
AXI_GP（通用端口）：
- 32位数据宽度
- 中低带宽控制
- 4个主端口 + 4个从端口

AXI_HP（高性能端口）：
- 64位数据宽度
- 高带宽数据传输
- 4个从端口

AXI_ACP（加速器一致性端口）：
- 直接访问L2缓存
- 硬件一致性支持
```

#### 中断系统
```
PL到PS中断：
- 16个共享中断
- 16个快速中断

PS到PL中断：
- 通过IRQ_F2P接口
```

### 2.3 启动流程

```
阶段0：BootROM
- 固化在芯片中
- 初始化基本硬件
- 加载FSBL

阶段1：FSBL（First Stage Boot Loader）
- 初始化PS外设
- 配置PL（可选）
- 加载U-Boot或应用程序

阶段2：U-Boot/Linux/应用程序
- 操作系统或裸机程序
```

---

## 三、VHDL通用编码基础规范

### 3.1 代码风格

#### 文件组织
```vhdl
-- 文件头注释
-- 库声明
-- 实体声明
-- 架构体声明
-- 组件声明（如有）
-- 信号声明
-- 常量声明
-- 类型定义
-- 逻辑实现
```

#### 命名约定
```vhdl
-- 实体/架构：PascalCase
entity DataProcessor is
end entity;

-- 信号：snake_case
signal data_valid : std_logic;
signal fifo_empty : std_logic;

-- 常量：UPPER_CASE
constant DATA_WIDTH : integer := 32;
constant CLK_FREQ   : integer := 100_000_000;

-- 类型：t_前缀
type state_t is (IDLE, BUSY, DONE);
type data_array_t is array(0 to 7) of std_logic_vector(31 downto 0);
```

### 3.2 常用结构

#### 组合逻辑
```vhdl
-- 使用when/else
output <= "00" when input = "00" else
          "01" when input = "01" else
          "10" when input = "10" else
          "11";

-- 使用with/select
with sel select
    output <= a when "00",
              b when "01",
              c when "10",
              d when others;
```

#### 时序逻辑
```vhdl
-- 同步复位
process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            -- 复位逻辑
        else
            -- 正常工作
        end if;
    end if;
end process;

-- 异步复位、同步释放（推荐）
process(clk, rst_n)
begin
    if rst_n = '0' then
        -- 异步复位
    elsif rising_edge(clk) then
        -- 同步逻辑
    end if;
end process;
```

#### 状态机
```vhdl
type state_t is (IDLE, READ, PROCESS, WRITE, DONE);
signal state, next_state : state_t;

-- 状态寄存器
process(clk, rst_n)
begin
    if rst_n = '0' then
        state <= IDLE;
    elsif rising_edge(clk) then
        state <= next_state;
    end if;
end process;

-- 次态逻辑
process(state, inputs)
begin
    case state is
        when IDLE =>
            if start = '1' then
                next_state <= READ;
            else
                next_state <= IDLE;
            end if;
        -- 其他状态...
        when others =>
            next_state <= IDLE;
    end case;
end process;
```

### 3.3 代码规范

#### 必须遵守
```
1. 所有信号必须声明类型
2. 所有进程必须有标签
3. 所有条件必须完整（包括others）
4. 避免组合逻辑环路
5. 避免锁存器推断
```

#### 推荐做法
```
1. 使用标准库（IEEE.STD_LOGIC_1164）
2. 使用NUMERIC_STD进行算术运算
3. 限制进程长度（<100行）
4. 模块化设计，功能单一
5. 充分注释（>30%）
```

---

## 四、数字电路设计通用准则

### 4.1 时序设计

#### 时钟域
```
单时钟域：
- 所有触发器使用同一时钟
- 设计简单，时序清晰

多时钟域：
- 需要跨时钟域处理
- 使用同步器或FIFO
- 注意亚稳态问题
```

#### 跨时钟域处理
```vhdl
-- 单bit信号：打两拍
signal sync_ff1, sync_ff2 : std_logic;
begin
    process(clk_dst, rst_n)
    begin
        if rst_n = '0' then
            sync_ff1 <= '0';
            sync_ff2 <= '0';
        elsif rising_edge(clk_dst) then
            sync_ff1 <= signal_src;
            sync_ff2 <= sync_ff1;
        end if;
    end process;

-- 多bit信号：使用FIFO或握手
```

### 4.2 复位设计

#### 复位类型
```
同步复位：
- 优点：抗干扰、时序分析简单
- 缺点：需要时钟才能复位

异步复位：
- 优点：立即响应
- 缺点：可能产生亚稳态

推荐：异步复位、同步释放
```

#### 复位策略
```vhdl
-- 全局复位
signal rst_n : std_logic;  -- 低有效

-- 局部复位（按模块）
signal module_rst_n : std_logic;

-- 软件复位（通过寄存器）
signal sw_rst : std_logic;
```

### 4.3 功耗优化

#### 静态功耗
```
来源：漏电流
优化：
- 选择低功耗器件
- 关闭未使用模块时钟
- 使用门控时钟
```

#### 动态功耗
```
来源：开关功耗
公式：P = C·V²·f
优化：
- 降低时钟频率
- 减少信号翻转
- 优化数据通路
```

---

## 五、官方IP核通用使用基础逻辑

### 5.1 常用IP核

| IP核 | 功能 | 典型应用 |
|------|------|----------|
| Clocking Wizard | 时钟管理 | PLL/MMCM配置 |
| FIFO Generator | FIFO存储 | 数据缓冲、跨时钟域 |
| Block Memory | 块存储器 | 查找表、缓存 |
| DDS Compiler | 直接数字合成 | 波形生成 |
| FIR Compiler | FIR滤波器 | 信号处理 |
| FFT | 快速傅里叶变换 | 频谱分析 |
| AXI Interconnect | 总线互联 | 系统互联 |
| DMA | 直接存储器访问 | 高速数据传输 |

### 5.2 IP核配置原则

```
1. 明确需求
   - 功能要求
   - 性能指标
   - 资源限制

2. 选择IP核
   - 官方IP优先
   - 评估资源占用
   - 考虑可移植性

3. 参数配置
   - 数据位宽
   - 时钟频率
   - 缓冲深度

4. 接口连接
   - 遵循标准协议
   - 注意时钟域
   - 处理复位信号
```

### 5.3 AXI接口IP

#### AXI4-Lite（控制）
```
特点：
- 简单、低吞吐
- 寄存器访问
- 地址映射

应用：
- 配置寄存器
- 状态读取
- 低速控制
```

#### AXI4-Stream（数据流）
```
特点：
- 无地址、连续传输
- 高吞吐
- 握手协议

应用：
- 数据流传输
- 信号处理链
- 视频数据
```

---

## 六、时序设计基础常识

### 6.1 时序参数

#### 建立时间与保持时间
```
建立时间（Setup Time）：
- 数据在时钟沿前必须稳定的时间
- 违反：建立时间违例

保持时间（Hold Time）：
- 数据在时钟沿后必须稳定的时间
- 违反：保持时间违例
```

#### 传播延迟
```
时钟到输出（Tco）：
- 时钟沿到数据输出的延迟

逻辑延迟（Tlogic）：
- 组合逻辑的传播延迟

布线延迟（Troute）：
- 信号在互连资源上的延迟
```

### 6.2 时序约束

#### 时钟约束
```tcl
# 创建时钟
create_clock -period 10.000 -name clk [get_ports clk]

# 创建生成时钟
create_generated_clock -name clk_div -source [get_pins clk] -divide_by 2 [get_pins clk_div_reg/Q]
```

#### IO约束
```tcl
# 输入延迟
set_input_delay -clock clk -max 2.0 [get_ports data_in]
set_input_delay -clock clk -min 0.5 [get_ports data_in]

# 输出延迟
set_output_delay -clock clk -max 2.0 [get_ports data_out]
set_output_delay -clock clk -min 0.5 [get_ports data_out]
```

#### 时序例外
```tcl
# 多周期路径
set_multicycle_path -setup 2 -from [get_pins reg1/C] -to [get_pins reg2/D]

# 假路径
set_false_path -from [get_pins rst_reg/C] -to [get_pins */D]
```

### 6.3 时序收敛

#### 时序报告分析
```
关键路径：
- 建立时间最差路径
- 保持时间最差路径

优化方法：
- 插入流水线
- 优化逻辑
- 调整布局
- 放宽约束（谨慎）
```

---

## 七、板级硬件开发通用注意事项

### 7.1 电源设计

#### 电源要求
```
ZYNQ电源：
- VCCINT（内核）：1.0V
- VCCBRAM：1.0V
- VCCAUX（辅助）：1.8V
- VCCO（IO）：1.8V/2.5V/3.3V

上电时序：
- 先内核，后辅助，最后IO
- 使用电源管理IC控制
```

#### 去耦电容
```
原则：
- 每个电源引脚就近放置去耦电容
- 大电容（10-100uF）+ 小电容（0.1uF）
- 高频噪声用小电容滤除
```

### 7.2 时钟设计

#### 时钟源
```
类型：
- 晶振：低成本、一般精度
- 有源晶振：高精度、低抖动
- 时钟发生器：多频率、可配置

要求：
- 抖动 < 1 ps（对于高速接口）
- 稳定性 < 50 ppm
```

#### 时钟分配
```
原则：
- 使用专用时钟引脚
- 差分时钟优于单端
- 避免时钟分叉（使用BUFG）
```

### 7.3 信号完整性

#### 高速信号
```
注意事项：
- 阻抗匹配（50Ω或100Ω差分）
- 走线长度匹配
- 避免过孔和stub
- 参考平面完整
```

#### 差分信号
```
要求：
- 等长匹配（< 10 mil）
- 等距走线
- 差分阻抗100Ω
- 避免跨越分割平面
```

### 7.4 调试接口

#### 必备接口
```
JTAG：
- 调试和编程
- 至少保留TCK、TMS、TDI、TDO

UART：
- 调试信息输出
- 至少保留TX、RX

LED/按键：
- 状态指示
- 简单输入
```

#### 测试点
```
建议：
- 关键信号预留测试点
- 电源测试点
- 时钟测试点
- 便于示波器测量
```
