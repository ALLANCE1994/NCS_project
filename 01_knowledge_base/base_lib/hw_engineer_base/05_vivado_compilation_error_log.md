# Vivado编译错题本

> **文档编号**：KB-EXP-VIVADO-002
> **版本**：V1.0
> **创建日期**：2026-05-19
> **维护责任**：【@H 硬件工程师】
> **适用范围**：ZYNQ7020 Vivado 2020.2工程

---

## 说明

本错题本记录M3阶段Vivado编译过程中遇到的所有编码Bug，包括错误信息、根因、修复方案。
与幻觉错误汇总台账不同，这里记录的是**编码技术错误**而非AI信息幻觉。

---

## 错题记录

### E-001：VHDL out端口读取

**错误信息**：`[Synth 8-1779] cannot read from 'out' object`
**文件**：top_odmr.vhd
**根因**：直接读取`out`方向端口`dds_valid`
**修复**：添加内部信号`dds_valid_i`中转
**经验**：VHDL中`out`端口不能被读取，与Verilog不同

---

### E-002：乘法位宽不匹配（cordic_lia mag_temp）

**错误信息**：`[Synth 8-690] width mismatch; target 40 bits, source 36 bits`
**文件**：cordic_lia.vhd:288
**根因**：`mag_temp`声明为`2*INTERNAL_WIDTH`(40位)，实际乘积为`INTERNAL_WIDTH+16`(36位)
**修复**：改为`signed(INTERNAL_WIDTH+16-1 downto 0)`，提取范围`35 downto 16`
**经验**：乘积位宽 = 两个操作数位宽之和，不是2倍最大位宽

---

### E-003：乘法位宽提取范围错误（cordic_lia mag_comp）

**错误信息**：`[Synth 8-690] width mismatch; target 20 bits, source 18 bits`
**文件**：cordic_lia.vhd:289
**根因**：提取范围`34 downto 17`=18位，但`mag_comp`是20位。计算公式用错
**修复**：改为`35 downto 16`=20位
**经验**：`signal(H downto L)`位宽 = H-L+1，必须手算验证

---

### E-004：乘法位宽不匹配（iir_lowpass mult信号）

**错误信息**：`[Synth 8-690] width mismatch; target 32 bits, source 48 bits`
**文件**：iir_lowpass.vhd
**根因**：`mult_a1`声明为`ACC_WIDTH`(32位)，实际乘积为`ACC_WIDTH+COEFF_WIDTH`(48位)
**修复**：改为`signed(ACC_WIDTH+COEFF_WIDTH-1 downto 0)`
**经验**：修复E-002后未全局检查同类问题，违反P2_02第八节规则

---

### E-005：端口映射使用表达式

**错误信息**：`[Synth 8-1565] actual is neither a static name nor a globally static expression`
**文件**：top_odmr.vhd（9处）
**根因**：端口映射中使用了`not rst_sync`、`sys_active and dds_enable`等表达式
**修复**：添加中间信号`rst_n`、`dds_enable_i`等，端口映射只使用信号名
**经验**：VHDL端口映射要求静态名称，Verilog允许表达式

---

### E-006：XDC引脚冲突

**错误信息**：`[DRC UCIO-1] Unconstrained Logical Port`
**文件**：01_pins.xdc
**根因**：`sys_rst_n`和`key[0]`都分配了引脚`N15`
**修复**：`key[0]`改为`J15`
**经验**：XDC引脚必须唯一，编写后必须全局搜索重复

---

### E-007：XDC中放置TCL工程命令

**错误信息**：多个WARNING（PART只读、get_runs不支持、CONFIGRATE不存在）
**文件**：03_config.xdc
**根因**：在XDC中放置了`set_property PART`、`get_runs`、`set_property strategy`等命令
**修复**：工程命令移到TCL脚本，XDC只保留约束
**经验**：XDC = 约束文件，TCL = 工程脚本，功能边界要分清

---

### E-008：process内使用并发语句

**错误信息**：`[Synth 8-2757] this construct is only supported in VHDL 1076-2008`
**文件**：scan_controller.vhd:215
**根因**：在`process`内使用`when...else`并发信号赋值
**修复**：改为`if...then...else`顺序语句
**经验**：`when...else`是并发语句，只能在architecture中process外使用

---

### E-009：boolean赋值给std_logic

**错误信息**：`[Synth 8-944] 0 definitions of operator "<=" match here`
**文件**：scan_controller.vhd:215
**根因**：`(a <= b)`返回boolean，不能直接赋值给std_logic信号
**修复**：改为`if...then...else`分别赋值'1'和'0'
**经验**：VHDL是强类型语言，boolean和std_logic不能隐式转换

---

### E-010：XDC通配符解析错误

**错误信息**：`'T18'U16'K15' is not a valid site or package pin name`
**文件**：01_pins.xdc:108
**根因**：`get_ports {adc_data_in[*]}`通配符导致Vivado解析异常
**修复**：将通配符改为逐位IOSTANDARD约束
**经验**：XDC通配符在某些场景下不可靠，关键约束建议逐位写

---

### E-011：XDC无效引脚

**错误信息**：`'T18' is not a valid site or package pin name`
**文件**：01_pins.xdc
**根因**：T18、U16、K15在XC7Z020CLG400-2封装上不存在
**修复**：T18→L17，U16→K18，K15→J17
**经验**：引脚分配必须基于实际器件封装验证，不能随意编造

---

## 统计

### 按错误类型

| 类型 | 次数 | 典型案例 |
|------|:----:|----------|
| VHDL语法（Verilog混淆） | 4 | E-001, E-005, E-008, E-009 |
| 位宽计算 | 3 | E-002, E-003, E-004 |
| XDC约束 | 4 | E-006, E-007, E-010, E-011 |

### 按严重程度

| 程度 | 次数 | 说明 |
|------|:----:|------|
| 致命（阻止综合） | 8 | 综合失败 |
| 中等（警告） | 3 | 不阻止但需修复 |

---

## 版本历史

| 版本 | 日期 | 更新内容 |
|:----:|------|----------|
| V1.0 | 2026-05-19 | 初始版本，M3阶段11条错题 |
