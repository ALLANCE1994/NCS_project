# NV色心实验系统 - 模块接口定义

> **文档版本**：V1.0  
> **日期**：2026-05-19  
> **作者**：@A 架构师  
> **评审人**：@V @P

---

## 一、顶层模块 top_odmr

### 1.1 端口定义

| 信号名 | 方向 | 位宽 | 说明 | I/O标准 |
|--------|------|------|------|---------|
| sys_clk_50m | input | 1 | 50MHz晶振输入 | LVCMOS33 |
| sys_rst_n | input | 1 | 系统复位，低有效 | LVCMOS33 |
| s_axi_aclk | input | 1 | AXI时钟 | - |
| s_axi_aresetn | input | 1 | AXI复位，低有效 | - |
| s_axi_awaddr | input | 8 | AXI写地址 | - |
| s_axi_awvalid | input | 1 | AXI写地址有效 | - |
| s_axi_awready | output | 1 | AXI写地址就绪 | - |
| s_axi_wdata | input | 32 | AXI写数据 | - |
| s_axi_wvalid | input | 1 | AXI写数据有效 | - |
| s_axi_wready | output | 1 | AXI写数据就绪 | - |
| s_axi_bresp | output | 2 | AXI写响应 | - |
| s_axi_bvalid | output | 1 | AXI写响应有效 | - |
| s_axi_bready | input | 1 | AXI写响应就绪 | - |
| s_axi_araddr | input | 8 | AXI读地址 | - |
| s_axi_arvalid | input | 1 | AXI读地址有效 | - |
| s_axi_arready | output | 1 | AXI读地址就绪 | - |
| s_axi_rdata | output | 32 | AXI读数据 | - |
| s_axi_rvalid | output | 1 | AXI读数据有效 | - |
| s_axi_rready | input | 1 | AXI读数据就绪 | - |
| led | output | 2 | LED指示 | LVCMOS33 |
| key | input | 2 | 按键输入 | LVCMOS33 |
| dds_clk_out | output | 1 | DDS时钟输出 | LVCMOS33 |
| dds_data_out | output | 14 | DDS数据输出 | LVCMOS33 |
| dds_valid | output | 1 | DDS数据有效 | LVCMOS33 |
| adc_clk_in | input | 1 | ADC采样时钟 | LVCMOS33 |
| adc_data_in | input | 16 | ADC数据输入 | LVCMOS33 |
| adc_valid | input | 1 | ADC数据有效 | LVCMOS33 |
| adc_ovr | input | 1 | ADC溢出指示 | LVCMOS33 |
| scan_trigger | output | 1 | 扫描触发输出 | LVCMOS33 |
| scan_sync | input | 1 | 扫描同步输入 | LVCMOS33 |

---

## 二、DDS信号发生器模块 dds_generator

### 2.1 功能说明

生成DDS控制信号，输出频率控制字到外部AD9910芯片。

### 2.2 端口定义

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| clk | input | 1 | 100MHz系统时钟 |
| rst_n | input | 1 | 复位，低有效 |
| freq_word | input | 32 | 频率控制字 |
| phase_out | output | 14 | DDS输出数据 |
| valid | output | 1 | 数据有效指示 |
| update | input | 1 | 频率更新触发 |

### 2.3 参数配置

| 参数名 | 默认值 | 说明 |
|--------|--------|------|
| PHASE_WIDTH | 32 | 相位累加器位宽 |
| DATA_WIDTH | 14 | 输出数据位宽 |

---

## 三、ADC采集接口模块 adc_interface

### 3.1 功能说明

采集外部ADC数据，进行跨时钟域处理。

### 3.2 端口定义

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| adc_clk | input | 1 | ADC采样时钟（50MHz） |
| sys_clk | input | 1 | 系统时钟（100MHz） |
| rst_n | input | 1 | 复位，低有效 |
| adc_data | input | 16 | ADC原始数据 |
| adc_valid | input | 1 | ADC数据有效 |
| data_out | output | 16 | 同步后数据 |
| valid_out | output | 1 | 同步后有效 |

---

## 四、CORDIC数字锁相模块 cordic_lockin

### 4.1 功能说明

实现数字锁相放大，提取信号幅值和相位。

### 4.2 端口定义

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| clk | input | 1 | 100MHz系统时钟 |
| rst_n | input | 1 | 复位，低有效 |
| signal_in | input | 16 | 输入信号 |
| valid_in | input | 1 | 输入有效 |
| ref_phase | input | 16 | 参考相位 |
| amplitude | output | 32 | 输出幅值 |
| phase | output | 16 | 输出相位 |
| valid_out | output | 1 | 输出有效 |

---

## 五、扫描状态机模块 scan_controller

### 5.1 功能说明

控制频率扫描过程，生成扫描触发信号。

### 5.2 端口定义

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| clk | input | 1 | 100MHz系统时钟 |
| rst_n | input | 1 | 复位，低有效 |
| start_freq | input | 32 | 扫描起始频率 |
| stop_freq | input | 32 | 扫描终止频率 |
| step_freq | input | 32 | 扫描步进 |
| dwell_time | input | 16 | 驻留时间（10ns单位） |
| scan_en | input | 1 | 扫描使能 |
| freq_out | output | 32 | 当前频率输出 |
| trigger | output | 1 | 扫描触发信号 |
| busy | output | 1 | 扫描进行中 |
| done | output | 1 | 扫描完成 |

---

## 六、IIR低通滤波模块 iir_filter

### 6.1 功能说明

实现IIR低通滤波，平滑解调后的信号。

### 6.2 端口定义

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| clk | input | 1 | 100MHz系统时钟 |
| rst_n | input | 1 | 复位，低有效 |
| data_in | input | 32 | 输入数据 |
| valid_in | input | 1 | 输入有效 |
| coeff_a | input | 16 | 滤波器系数A |
| coeff_b | input | 16 | 滤波器系数B |
| data_out | output | 32 | 滤波后数据 |
| valid_out | output | 1 | 输出有效 |

---

## 七、AXI寄存器接口模块 axi_reg_if

### 7.1 功能说明

实现AXI4-Lite从接口，提供寄存器访问。

### 7.2 端口定义

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| s_axi_aclk | input | 1 | AXI时钟 |
| s_axi_aresetn | input | 1 | AXI复位 |
| s_axi_awaddr | input | 8 | 写地址 |
| s_axi_awvalid | input | 1 | 写地址有效 |
| s_axi_awready | output | 1 | 写地址就绪 |
| s_axi_wdata | input | 32 | 写数据 |
| s_axi_wvalid | input | 1 | 写数据有效 |
| s_axi_wready | output | 1 | 写数据就绪 |
| s_axi_bresp | output | 2 | 写响应 |
| s_axi_bvalid | output | 1 | 写响应有效 |
| s_axi_bready | input | 1 | 写响应就绪 |
| s_axi_araddr | input | 8 | 读地址 |
| s_axi_arvalid | input | 1 | 读地址有效 |
| s_axi_arready | output | 1 | 读地址就绪 |
| s_axi_rdata | output | 32 | 读数据 |
| s_axi_rvalid | output | 1 | 读数据有效 |
| s_axi_rready | input | 1 | 读数据就绪 |
| reg_ctrl | output | 32 | 控制寄存器 |
| reg_dds_freq | output | 32 | DDS频率寄存器 |
| reg_scan_start | output | 32 | 扫描起始寄存器 |
| reg_scan_stop | output | 32 | 扫描终止寄存器 |
| reg_scan_step | output | 32 | 扫描步进寄存器 |
| reg_status | input | 32 | 状态寄存器 |

---

## 八、版本历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| V1.0 | 2026-05-19 | 初始版本 | @A |

---

**下一步：AXI寄存器映射表**
