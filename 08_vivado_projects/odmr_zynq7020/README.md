# Vivado工程TCL脚本使用指南

> 版本：v1.0
> 日期：2026-05-19
> 所属阶段：M3.0

---

## 📋 脚本清单

| 脚本 | 功能 |
|------|------|
| `create_project.tcl` | 创建工程 + 添加源文件 + 综合实现 + 生成比特流 |

---

## 🚀 使用方法

### 方法1：命令行模式（推荐）

```bash
# 进入Vivado TCL控制台
cd 08_vivado_projects/odmr_zynq7020
vivado -mode batch -source create_project.tcl
```

### 方法2：Vivado GUI中运行

```tcl
# 在Vivado TCL Console中
cd 08_vivado_projects/odmr_zynq7020
source create_project.tcl
```

---

## 📊 脚本流程

```
1. 工程配置
   ├── 项目名称：odmr_zynq7020
   ├── 目标器件：XC7Z020CLG400-2
   └── 源文件目录：../../03_code/01_vhdl_modules

2. 添加源文件
   └── top_odmr.vhd

3. 添加约束文件
   ├── 01_pins.xdc      (引脚约束)
   ├── 02_timing.xdc    (时序约束)
   └── 03_config.xdc    (配置约束)

4. 综合 (synth_1)
   ├── 运行综合
   └── 生成报告
       ├── utilization_synth.rpt  (资源利用率)
       └── timing_synth.rpt       (时序摘要)

5. 实现 (impl_1)
   ├── 布局布线
   └── 生成报告
       ├── utilization_impl.rpt   (资源利用率)
       ├── timing_impl.rpt        (时序摘要)
       ├── drc.rpt               (DRC检查)
       └── power.rpt             (功耗报告)

6. 比特流生成
   └── top_odmr.bit
```

---

## 📁 输出文件结构

```
08_vivado_projects/odmr_zynq7020/
├── odmr_zynq7020.xpr          # Vivado工程文件
├── odmr_zynq7020.runs/        # 综合/实现运行结果
│   └── impl_1/
│       └── top_odmr.bit       # 比特流文件
├── odmr_zynq7020.cache/       # 综合缓存
├── odmr_zynq7020.hw/          # 硬件管理
├── odmr_zynq7020.ip_user_files/  # IP用户文件
└── reports/                   # 报告目录
    ├── utilization_synth.rpt
    ├── timing_synth.rpt
    ├── utilization_impl.rpt
    ├── timing_impl.rpt
    ├── drc.rpt
    └── power.rpt
```

---

## ✅ 验收标准

| 标准 | 检查项 |
|------|--------|
| 综合成功 | 无ERROR，关键警告可接受 |
| 实现成功 | WNS > 0, TNS = 0 |
| DRC通过 | 无Critical警告 |
| 比特流生成 | .bit文件存在 |

---

## ⚠️ 注意事项

1. **首次运行**：脚本会自动创建`reports/`目录
2. **重复运行**：会覆盖之前的报告和比特流
3. **清理**：删除`.runs/`、`.cache/`目录后可重新运行
4. **修改**：编辑TCL脚本后重新source即可

---

## 🔧 常见问题

### Q: 提示"Project exists"
A: 正常，脚本会自动打开现有工程

### Q: 综合失败
A: 检查VHDL代码语法错误，查看`vivado.log`

### Q: 时序违例
A: 检查`reports/timing_impl.rpt`，调整约束

---

## 📝 后续子模块流程

M3.1-M3.5每个子模块完成后，需要：

1. 更新`create_project.tcl`添加新模块
2. 创建模块专用约束文件
3. 重新运行TCL脚本
4. 验证编译结果
