# M3.0 引脚验证报告

## 验证日期：2026-05-19
## 验证人：@H 硬件工程师

---

## 引脚分配验证结果

### Bank 34 引脚（共25个）

| 信号名 | 引脚 | 类型 | 状态 |
|--------|------|------|:----:|
| sys_clk_50m | U18 | MRCC | ✅ |
| adc_clk_in | U19 | MRCC | ✅ |
| dds_clk_out | T16 | HR | ✅ |
| dds_data_out[0] | R17 | HR | ✅ |
| dds_data_out[1] | T17 | HR | ✅ |
| dds_data_out[2] | R18 | HR | ✅ |
| dds_data_out[3] | V17 | HR | ✅ |
| dds_data_out[4] | V18 | HR | ✅ |
| dds_data_out[5] | W18 | HR | ✅ |
| dds_data_out[6] | W19 | HR | ✅ |
| dds_data_out[7] | N17 | HR | ✅ |
| dds_data_out[8] | P18 | HR | ✅ |
| dds_data_out[9] | P15 | HR | ✅ |
| dds_data_out[10] | T19 | HR | ✅ |
| dds_data_out[11] | R16 | HR | ✅ |
| dds_data_out[12] | Y18 | HR | ✅ |
| dds_data_out[13] | Y19 | HR | ✅ |
| dds_valid | V16 | HR | ✅ |
| adc_data_in[0] | W14 | HR | ✅ |
| adc_data_in[1] | Y14 | HR | ✅ |
| adc_data_in[2] | Y16 | HR | ✅ |
| adc_data_in[3] | Y17 | HR | ✅ |
| adc_data_in[4] | V15 | HR | ✅ |
| adc_data_in[5] | W15 | HR | ✅ |
| adc_data_in[6] | U14 | HR | ✅ |
| adc_data_in[7] | U15 | HR | ✅ |
| adc_data_in[8] | T14 | HR | ✅ |
| adc_data_in[9] | T15 | HR | ✅ |
| adc_data_in[10] | P14 | HR | ✅ |
| adc_data_in[11] | R14 | HR | ✅ |
| adc_data_in[12] | T11 | HR | ✅ |
| adc_data_in[13] | T10 | HR | ✅ |
| adc_data_in[14] | T12 | HR | ✅ |
| adc_data_in[15] | U12 | HR | ✅ |
| adc_valid | V13 | HR | ✅ |
| adc_ovr | V12 | HR | ✅ |
| scan_trigger | W13 | HR | ✅ |
| scan_sync | U13 | HR | ✅ |

### Bank 35 引脚（共5个）

| 信号名 | 引脚 | 类型 | 状态 |
|--------|------|------|:----:|
| sys_rst_n | J15 | HR | ✅ |
| led[0] | M14 | HR | ✅ |
| led[1] | M15 | HR | ✅ |
| key[0] | K18 | HR | ✅ |
| key[1] | P16 | HR | ✅ |

---

## 错误引脚记录（已修复）

| 错误引脚 | 实际功能 | 修复后引脚 |
|----------|----------|------------|
| N16 | VCCO_35电源 | J15 |
| C19 | VCCO_35电源 | 删除 |
| D19 | VCCO_35电源 | 使用Bank 34引脚 |
| E19 | VCCO_35电源 | 使用Bank 34引脚 |
| F18 | VCCO_35电源 | 使用Bank 34引脚 |

---

## 验证结论

✅ **所有43个引脚验证通过**
- Bank 34: 38个引脚（含2个MRCC时钟）
- Bank 35: 5个引脚
- 无电源/地引脚误用
- 无No-Connect引脚误用

**可以安全用于Vivado编译**
