# Vivado综合与实现经验知识库

> **文档编号**：KB-EXP-VIVADO-001
> **版本**：V1.0
> **创建日期**：2026-05-19
> **来源**：M3阶段实际开发经验总结
> **维护责任**：【@H 硬件工程师】
> **适用范围**：ZYNQ7020 Vivado 2020.2工程

---

## 一、VHDL编码经验

### 1.1 端口映射禁止表达式

**规则**：VHDL端口映射（port map）中禁止使用任何逻辑表达式。

**错误写法**：
```vhdl
port map (
    rst_n   => not rst_sync,        -- ❌ 禁止
    enable  => sys_active and en,   -- ❌ 禁止
    start   => not key(3)           -- ❌ 禁止
);
```

**正确写法**：
```vhdl
-- 在architecture声明区定义中间信号
signal rst_n_i    : std_logic;
signal enable_i   : std_logic;
signal start_i    : std_logic;

begin
    -- 在begin后、实例化前赋值
    rst_n_i   <= not rst_sync;
    enable_i  <= sys_active and en;
    start_i   <= not key(3);

    -- 端口映射使用中间信号
    port map (
        rst_n   => rst_n_i,     -- ✅ 正确
        enable  => enable_i,    -- ✅ 正确
        start   => start_i      -- ✅ 正确
    );
```

**综合错误**：`[Synth 8-1565] actual is neither a static name nor a globally static expression`

---

### 1.2 out端口禁止读取

**规则**：VHDL中禁止读取`out`方向端口。

**错误写法**：
```vhdl
led(0) <= dds_valid;  -- dds_valid是out端口 ❌
```

**正确写法**：
```vhdl
-- 声明内部信号
signal dds_valid_i : std_logic;

-- 实例化时连接到内部信号
port map (
    valid_out => dds_valid_i
);

-- 内部信号赋值给输出端口
dds_valid <= dds_valid_i;
led(0) <= dds_valid_i;  -- ✅ 读取内部信号
```

**综合错误**：`cannot read from 'out' object`

---

### 1.3 乘法位宽必须匹配

**规则**：乘法结果的位宽等于两个操作数位宽之和，赋值目标必须匹配。

**常见错误**：
```vhdl
-- x_reg: 20位, GAIN_COMP: 16位
variable mag_temp : signed(39 downto 0);  -- ❌ 40位，实际乘积36位
```

**正确写法**：
```vhdl
-- 乘积位宽 = 20 + 16 = 36位
variable mag_temp : signed(35 downto 0);  -- ✅ 36位
```

**提取子位时也要注意**：
```vhdl
-- mag_comp是20位，需要从36位中提取20位
-- mag_temp(35 downto 16) = 20位 ✅
-- mag_temp(34 downto 15) = 20位 ✅
-- mag_temp(34 downto 17) = 18位 ❌
mag_comp := mag_temp(35 downto 16);
```

**综合错误**：`[Synth 8-690] width mismatch in assignment`

---

### 1.4 位宽提取计算公式

**公式**：`signal(high downto low)` 的位宽 = `high - low + 1`

**示例**：
- `35 downto 16` → 35-16+1 = **20位**
- `34 downto 17` → 34-17+1 = **18位**
- `2*INTERNAL_WIDTH-1 downto 0` → 当INTERNAL_WIDTH=20时 = **40位**
- `INTERNAL_WIDTH+COEFF_WIDTH-1 downto 0` → 当I=32,C=16时 = **48位**

---

## 二、XDC约束经验

### 2.1 引脚不能重复分配

**错误**：两个端口分配同一个引脚
```xdc
set_property PACKAGE_PIN N15 [get_ports sys_rst_n]
set_property PACKAGE_PIN N15 [get_ports {key[0]}]  -- ❌ 冲突
```

**后果**：DRC报错 `UCIO-1`，其中一个端口无有效约束。

---

### 2.2 总线引脚必须全部约束

**规则**：如果约束了总线的任何一位，必须约束所有位。

**错误**：缺少`adc_data_in[10]`和`adc_data_in[11]`
```xdc
set_property PACKAGE_PIN V15 [get_ports {adc_data_in[9]}]
# 缺少 [10] 和 [11]
set_property PACKAGE_PIN W15 [get_ports {adc_data_in[12]}]
```

**后果**：DRC报错 `PLIO-3` Partially locked IO Bus。

---

### 2.3 XDC中禁止TCL工程命令

**以下命令不能放在XDC文件中**：
- `set_property PART` — 只读属性
- `set_property strategy` — 工程命令
- `get_runs` — 工程命令
- `set_property BITSTREAM.CONFIG.CONFIGRATE` — 不存在的属性

**正确做法**：这些命令放在TCL脚本中，不放在XDC中。

---

### 2.4 配置约束应放在XDC中

**以下约束可以放在XDC中**：
```xdc
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
```

---

## 三、时序收敛经验

### 3.1 时序不收敛的常见原因

| 原因 | 典型延迟 | 解决方案 |
|------|:--------:|----------|
| 32位加法/比较组合路径 | ~25ns | 添加流水线寄存器 |
| CORDIC多次迭代 | ~15ns | 减少迭代次数或流水线 |
| 乘法器链 | ~10ns | 使用DSP原语或流水线 |
| 高扇出信号 | ~5ns | 增加缓冲寄存器 |

### 3.2 流水线设计原则（来自UG949）

1. **设计早期规划**：不要等时序不收敛才加流水线
2. **平衡控制路径和数据路径**：优先在控制路径添加流水线节省触发器
3. **深流水线用SRL**：便于综合推断移位寄存器
4. **BRAM/DSP用内部流水线**：可工作在500MHz以上

### 3.3 时序收敛系统化流程

```
1. check_timing — 确认约束完整
2. report_qor_suggestions — 获取自动优化建议
3. 解决每个时钟域的WNS
4. 增量实现验证
```

---

## 四、Vivado工程管理经验

### 4.1 TCL脚本拆分原则

按P0_08小步快跑规则，TCL脚本应拆分为独立步骤：

| 脚本 | 功能 | 可独立运行 |
|------|------|:----------:|
| 01_create_project.tcl | 创建工程+添加源文件 | ✅ |
| 02_run_synth.tcl | 综合+报告 | ✅ |
| 03_run_impl.tcl | 实现+时序检查 | ✅ |
| 04_run_bitstream.tcl | 生成Bitstream | ✅ |
| run_all.tcl | 一键全流程 | ✅ |

### 4.2 综合策略放在TCL中

综合策略和实现策略必须放在TCL脚本中，不能放在XDC中：
```tcl
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property strategy Performance_Explore [get_runs impl_1]
```

### 4.3 工程路径不能太长

Windows路径限制260字符，Vivado建议路径不超过80字符。如遇问题：
- 缩短工程路径
- 使用`subst`命令映射驱动器

---

## 五、Bug修复经验

### 5.1 修复Bug后必须检查同类问题

按P2_02第八节规则，修复一个Bug后必须全局搜索同类问题。

**检查清单**：
- 位宽不匹配 → 检查所有乘法/resize操作
- out端口读取 → 检查所有out端口
- 引脚冲突 → 检查所有PACKAGE_PIN
- 表达式端口映射 → 检查所有port map

### 5.2 位宽修改的连锁反应

修改一个信号的位宽后，必须检查：
1. 乘法结果位宽是否匹配
2. 提取子位范围是否正确
3. resize目标位宽是否正确
4. 比较操作数位宽是否一致

---

## 版本历史

| 版本 | 日期 | 更新内容 | 作者 |
|:----:|------|----------|------|
| V1.0 | 2026-05-19 | 初始版本，M3阶段经验总结 | @H |
