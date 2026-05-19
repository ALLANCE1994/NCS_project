# NV色心实验系统 - 引脚分配规划

> **文档版本**：V1.0  
> **日期**：2026-05-19  
> **作者**：@H 硬件工程师  
> **评审人**：@A @V

---

## 一、引脚分配原则

### 1.1 分配策略

| 策略 | 说明 |
|------|------|
| 功能分区 | 按功能模块分配Bank |
| 时钟优先 | 时钟信号优先使用MRCC/SRCC |
| 高速隔离 | DDS/ADC高速信号与其他信号隔离 |
| 电源避让 | 严格避开VCCO/GND引脚 |

### 1.2 Bank分配

| Bank | 电压 | 用途 | 模块 |
|------|------|------|------|
| Bank 34 | 3.3V | 高速信号 | DDS, ADC, 扫描 |
| Bank 35 | 3.3V | 低速控制 | LED, 按键, 复位 |

---

## 二、引脚分配表

### 2.1 系统时钟与复位 - Bank 34/35

| 信号名 | 引脚 | Bank | 类型 | I/O标准 | 备注 |
|--------|------|------|------|---------|------|
| sys_clk_50m | U18 | 34 | MRCC | LVCMOS33 | 50MHz晶振输入 |
| sys_rst_n | J15 | 35 | HR | LVCMOS33 | 系统复位 |

### 2.2 LED与按键 - Bank 35

| 信号名 | 引脚 | Bank | 类型 | I/O标准 | 备注 |
|--------|------|------|------|---------|------|
| led[0] | M14 | 35 | HR | LVCMOS33 | LED0 |
| led[1] | M15 | 35 | HR | LVCMOS33 | LED1 |
| key[0] | K18 | 35 | HR | LVCMOS33 | 按键0 |
| key[1] | P16 | 35 | HR | LVCMOS33 | 按键1 |

### 2.3 DDS信号发生器 - Bank 34

| 信号名 | 引脚 | Bank | 类型 | I/O标准 | 驱动 | 备注 |
|--------|------|------|------|---------|------|------|
| dds_clk_out | T16 | 34 | HR | LVCMOS33 | 12mA | DDS时钟输出 |
| dds_data_out[0] | R17 | 34 | HR | LVCMOS33 | 12mA | 数据位0 |
| dds_data_out[1] | T17 | 34 | HR | LVCMOS33 | 12mA | 数据位1 |
| dds_data_out[2] | R18 | 34 | HR | LVCMOS33 | 12mA | 数据位2 |
| dds_data_out[3] | V17 | 34 | HR | LVCMOS33 | 12mA | 数据位3 |
| dds_data_out[4] | V18 | 34 | HR | LVCMOS33 | 12mA | 数据位4 |
| dds_data_out[5] | W18 | 34 | HR | LVCMOS33 | 12mA | 数据位5 |
| dds_data_out[6] | W19 | 34 | HR | LVCMOS33 | 12mA | 数据位6 |
| dds_data_out[7] | N17 | 34 | HR | LVCMOS33 | 12mA | 数据位7 |
| dds_data_out[8] | P18 | 34 | HR | LVCMOS33 | 12mA | 数据位8 |
| dds_data_out[9] | P15 | 34 | HR | LVCMOS33 | 12mA | 数据位9 |
| dds_data_out[10] | T19 | 34 | HR | LVCMOS33 | 12mA | 数据位10 |
| dds_data_out[11] | R16 | 34 | HR | LVCMOS33 | 12mA | 数据位11 |
| dds_data_out[12] | Y18 | 34 | HR | LVCMOS33 | 12mA | 数据位12 |
| dds_data_out[13] | Y19 | 34 | HR | LVCMOS33 | 12mA | 数据位13 |
| dds_valid | V16 | 34 | HR | LVCMOS33 | 8mA | 数据有效 |

### 2.4 ADC采集接口 - Bank 34

| 信号名 | 引脚 | Bank | 类型 | I/O标准 | 备注 |
|--------|------|------|------|---------|------|
| adc_clk_in | U19 | 34 | MRCC | LVCMOS33 | ADC采样时钟 |
| adc_data_in[0] | W14 | 34 | HR | LVCMOS33 | 数据位0 |
| adc_data_in[1] | Y14 | 34 | HR | LVCMOS33 | 数据位1 |
| adc_data_in[2] | Y16 | 34 | HR | LVCMOS33 | 数据位2 |
| adc_data_in[3] | Y17 | 34 | HR | LVCMOS33 | 数据位3 |
| adc_data_in[4] | V15 | 34 | HR | LVCMOS33 | 数据位4 |
| adc_data_in[5] | W15 | 34 | HR | LVCMOS33 | 数据位5 |
| adc_data_in[6] | U14 | 34 | HR | LVCMOS33 | 数据位6 |
| adc_data_in[7] | U15 | 34 | HR | LVCMOS33 | 数据位7 |
| adc_data_in[8] | T14 | 34 | HR | LVCMOS33 | 数据位8 |
| adc_data_in[9] | T15 | 34 | HR | LVCMOS33 | 数据位9 |
| adc_data_in[10] | P14 | 34 | HR | LVCMOS33 | 数据位10 |
| adc_data_in[11] | R14 | 34 | HR | LVCMOS33 | 数据位11 |
| adc_data_in[12] | T11 | 34 | HR | LVCMOS33 | 数据位12 |
| adc_data_in[13] | T10 | 34 | HR | LVCMOS33 | 数据位13 |
| adc_data_in[14] | T12 | 34 | HR | LVCMOS33 | 数据位14 |
| adc_data_in[15] | U12 | 34 | HR | LVCMOS33 | 数据位15 |
| adc_valid | V13 | 34 | HR | LVCMOS33 | 数据有效 |
| adc_ovr | V12 | 34 | HR | LVCMOS33 | 溢出指示 |

### 2.5 扫描控制 - Bank 34

| 信号名 | 引脚 | Bank | 类型 | I/O标准 | 备注 |
|--------|------|------|------|---------|------|
| scan_trigger | W13 | 34 | HR | LVCMOS33 | 扫描触发输出 |
| scan_sync | U13 | 34 | HR | LVCMOS33 | 扫描同步输入 |

---

## 三、引脚验证

### 3.1 验证清单

- [x] 所有引脚已查官方XC7Z020CLG400 Pinout
- [x] 无VCCO/GND引脚误用
- [x] 时钟引脚使用MRCC（U18, U19）
- [x] 高速信号使用Bank 34 HR引脚
- [x] I/O标准统一为LVCMOS33
- [x] 驱动能力按信号类型配置

### 3.2 Bank 34 引脚统计

| 类型 | 数量 | 说明 |
|------|------|------|
| MRCC | 2 | U18, U19（时钟） |
| HR | 36 | 数据/控制信号 |
| **总计** | **38** | |

### 3.3 Bank 35 引脚统计

| 类型 | 数量 | 说明 |
|------|------|------|
| HR | 5 | LED/按键/复位 |
| **总计** | **5** | |

---

## 四、约束文件生成

基于本规划，生成XDC约束文件：`constraints/01_pins.xdc`

---

## 五、版本历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| V1.0 | 2026-05-19 | 初始版本 | @H |

---

**下一步：时序预算分析**
