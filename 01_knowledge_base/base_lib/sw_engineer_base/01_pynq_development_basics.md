# PYNQ框架通用开发基础

> **适用角色**：资深软件工程师
> **知识类型**：通用基础能力
> **更新日期**：2026-05-16

---

## 一、PYNQ框架概述

### 1.1 什么是PYNQ

**PYNQ**（Python Productivity for ZYNQ）是一个开源框架，允许开发者使用Python进行ZYNQ SoC的软硬件协同开发。

```
核心特点：
- 使用Python控制PL（可编程逻辑）
- Jupyter Notebook交互式开发
- 丰富的硬件库支持
- 社区驱动的Overlay生态
```

### 1.2 架构组成

```
PYNQ架构：
├── Python API
│   ├── Overlay：加载比特流
│   ├── MMIO：内存映射IO
│   ├── DMA：直接内存访问
│   └── GPIO：通用IO控制
├── Jupyter Notebook
│   ├── 交互式开发
│   ├── 文档与代码结合
│   └── 可视化展示
└── Linux系统
    ├── Ubuntu/Debian
    ├── 设备驱动
    └── 硬件抽象层
```

### 1.3 开发优势

| 优势 | 说明 |
|------|------|
| 快速原型 | 无需编写底层驱动，快速验证想法 |
| 易于调试 | 交互式开发，即时反馈 |
| 生态丰富 | Python庞大的库支持 |
| 文档完善 | Jupyter Notebook自文档化 |
| 社区活跃 | 开源项目，持续更新 |

---

## 二、Python科研上位机开发通用规范

### 2.1 代码结构

#### 项目组织
```
project/
├── src/
│   ├── __init__.py
│   ├── hardware/
│   │   ├── __init__.py
│   │   ├── overlay.py
│   │   └── driver.py
│   ├── logic/
│   │   ├── __init__.py
│   │   ├── control.py
│   │   └── analysis.py
│   └── utils/
│       ├── __init__.py
│       └── helpers.py
├── notebooks/
│   ├── 01_setup.ipynb
│   ├── 02_basic.ipynb
│   └── 03_advanced.ipynb
├── tests/
│   └── test_module.py
├── config/
│   └── settings.yaml
└── README.md
```

#### 模块设计
```python
# 单一职责原则
class DataAcquisition:
    """数据采集模块"""
    def __init__(self, overlay):
        self.overlay = overlay
    
    def configure(self, params):
        """配置采集参数"""
        pass
    
    def start(self):
        """开始采集"""
        pass
    
    def stop(self):
        """停止采集"""
        pass
```

### 2.2 编码规范

#### 命名规范
```python
# 模块名：小写+下划线
data_acquisition.py

# 类名：驼峰命名
class DataProcessor:
    pass

# 函数名：小写+下划线
def process_data():
    pass

# 常量：大写+下划线
MAX_BUFFER_SIZE = 1024

# 私有变量：下划线前缀
_private_var = None
```

#### 文档规范
```python
def configure_adc(sample_rate: int, channels: list) -> bool:
    """
    配置ADC采集参数
    
    Args:
        sample_rate: 采样率(Hz)
        channels: 通道列表,如[0, 1, 2]
    
    Returns:
        bool: 配置是否成功
    
    Raises:
        ValueError: 参数超出范围
    
    Example:
        >>> configure_adc(1000000, [0, 1])
        True
    """
    pass
```

### 2.3 错误处理

#### 异常分类
```python
class HardwareError(Exception):
    """硬件相关错误"""
    pass

class ConfigurationError(Exception):
    """配置错误"""
    pass

class DataError(Exception):
    """数据处理错误"""
    pass
```

#### 处理模式
```python
try:
    data = acquire_data()
except HardwareError as e:
    logger.error(f"硬件错误: {e}")
    # 尝试恢复或通知用户
except TimeoutError:
    logger.warning("采集超时")
    # 重试或跳过
finally:
    # 清理资源
    cleanup()
```

---

## 三、PS与PL交互通用基础逻辑

### 3.1 内存映射IO（MMIO）

#### 基本原理
```python
from pynq import MMIO

# 映射物理地址到虚拟地址
mmio = MMIO(physical_address, address_range)

# 读写操作
mmio.write(offset, value)      # 写入32位数据
value = mmio.read(offset)      # 读取32位数据
```

#### 寄存器访问
```python
class CustomDriver:
    """自定义驱动示例"""
    
    REG_CONTROL = 0x00    # 控制寄存器
    REG_STATUS  = 0x04    # 状态寄存器
    REG_DATA    = 0x08    # 数据寄存器
    
    def __init__(self, overlay):
        self.mmio = MMIO(overlay.ip_dict['custom_ip']['phys_addr'], 
                         overlay.ip_dict['custom_ip']['addr_range'])
    
    def start(self):
        """启动操作"""
        self.mmio.write(self.REG_CONTROL, 0x01)
    
    def is_busy(self):
        """检查是否忙"""
        return self.mmio.read(self.REG_STATUS) & 0x01
```

### 3.2 DMA数据传输

#### 发送数据
```python
from pynq import allocate

# 分配连续物理内存
input_buffer = allocate(shape=(1024,), dtype=np.int32)

# 填充数据
input_buffer[:] = data_array[:]

# 启动DMA传输
overlay.dma.sendchannel.transfer(input_buffer)
overlay.dma.sendchannel.wait()
```

#### 接收数据
```python
# 分配输出缓冲区
output_buffer = allocate(shape=(1024,), dtype=np.int32)

# 启动接收
overlay.dma.recvchannel.transfer(output_buffer)
overlay.dma.recvchannel.wait()

# 处理数据
result = np.array(output_buffer)
```

### 3.3 GPIO控制

#### 基本操作
```python
from pynq import GPIO

# 创建GPIO对象
gpio = GPIO(GPIO.get_gpio_pin(0), 'out')

# 设置高低电平
gpio.write(1)   # 高电平
gpio.write(0)   # 低电平

# 读取状态
value = gpio.read()
```

---

## 四、实验自动化脚本编写通用思路

### 4.1 自动化框架

#### 实验流程控制
```python
class ExperimentController:
    """实验控制器"""
    
    def __init__(self, config):
        self.config = config
        self.overlay = None
        self.logger = logging.getLogger(__name__)
    
    def initialize(self):
        """初始化硬件"""
        self.overlay = Overlay(self.config['bitstream'])
        self.logger.info("硬件初始化完成")
    
    def run_experiment(self, parameters):
        """运行实验"""
        try:
            self.before_experiment()
            data = self.execute(parameters)
            self.after_experiment()
            return data
        except Exception as e:
            self.handle_error(e)
            raise
    
    def before_experiment(self):
        """实验前准备"""
        pass
    
    def execute(self, parameters):
        """执行实验"""
        pass
    
    def after_experiment(self):
        """实验后处理"""
        pass
```

#### 参数扫描
```python
def parameter_scan(controller, param_name, param_range):
    """
    参数扫描实验
    
    Args:
        controller: 实验控制器
        param_name: 参数名称
        param_range: 参数范围
    """
    results = []
    
    for value in param_range:
        params = {param_name: value}
        data = controller.run_experiment(params)
        results.append({
            'parameter': value,
            'data': data
        })
    
    return results
```

### 4.2 数据采集策略

#### 连续采集
```python
def continuous_acquisition(duration, sample_rate):
    """
    连续数据采集
    
    Args:
        duration: 采集时长(秒)
        sample_rate: 采样率(Hz)
    """
    samples = int(duration * sample_rate)
    buffer = allocate(shape=(samples,), dtype=np.float32)
    
    start_time = time.time()
    for i in range(samples):
        buffer[i] = read_adc()
        time.sleep(1/sample_rate)
    
    elapsed = time.time() - start_time
    actual_rate = samples / elapsed
    
    return buffer, actual_rate
```

#### 触发采集
```python
def triggered_acquisition(trigger_level, timeout=10):
    """
    触发式数据采集
    
    Args:
        trigger_level: 触发电平
        timeout: 超时时间(秒)
    """
    start_time = time.time()
    
    # 等待触发
    while read_adc() < trigger_level:
        if time.time() - start_time > timeout:
            raise TimeoutError("等待触发超时")
    
    # 采集数据
    return acquire_data()
```

### 4.3 错误恢复机制

#### 重试策略
```python
from functools import wraps

def retry_on_error(max_retries=3, delay=1):
    """错误重试装饰器"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_retries - 1:
                        raise
                    logging.warning(f"尝试{attempt+1}失败: {e}")
                    time.sleep(delay)
        return wrapper
    return decorator

@retry_on_error(max_retries=3)
def acquire_with_retry():
    """带重试的数据采集"""
    return acquire_data()
```

---

## 五、数据采集程序基础设计准则

### 5.1 实时性考虑

#### 缓冲区设计
```python
class CircularBuffer:
    """环形缓冲区"""
    
    def __init__(self, capacity):
        self.capacity = capacity
        self.buffer = np.zeros(capacity)
        self.write_ptr = 0
        self.read_ptr = 0
    
    def write(self, data):
        """写入数据"""
        self.buffer[self.write_ptr] = data
        self.write_ptr = (self.write_ptr + 1) % self.capacity
    
    def read(self):
        """读取数据"""
        if self.read_ptr == self.write_ptr:
            return None
        data = self.buffer[self.read_ptr]
        self.read_ptr = (self.read_ptr + 1) % self.capacity
        return data
```

#### 多线程采集
```python
import threading
import queue

class AsyncDataAcquisition:
    """异步数据采集"""
    
    def __init__(self):
        self.data_queue = queue.Queue()
        self.stop_event = threading.Event()
        self.acquisition_thread = None
    
    def start(self):
        """启动采集线程"""
        self.acquisition_thread = threading.Thread(target=self._acquire)
        self.acquisition_thread.start()
    
    def _acquire(self):
        """采集循环"""
        while not self.stop_event.is_set():
            data = read_hardware()
            self.data_queue.put(data)
    
    def stop(self):
        """停止采集"""
        self.stop_event.set()
        self.acquisition_thread.join()
    
    def get_data(self, timeout=1):
        """获取数据"""
        return self.data_queue.get(timeout=timeout)
```

### 5.2 数据完整性

#### 校验机制
```python
def verify_data_integrity(data, checksum):
    """
    验证数据完整性
    
    Args:
        data: 原始数据
        checksum: 校验和
    
    Returns:
        bool: 验证是否通过
    """
    calculated = calculate_checksum(data)
    return calculated == checksum

def calculate_checksum(data):
    """计算校验和"""
    return sum(data) & 0xFFFF
```

#### 数据备份
```python
import json
from datetime import datetime

def save_data_with_metadata(data, filename):
    """
    保存数据及元数据
    
    Args:
        data: 采集数据
        filename: 文件名
    """
    metadata = {
        'timestamp': datetime.now().isoformat(),
        'data_shape': data.shape,
        'data_type': str(data.dtype),
        'checksum': calculate_checksum(data)
    }
    
    package = {
        'metadata': metadata,
        'data': data.tolist()
    }
    
    with open(filename, 'w') as f:
        json.dump(package, f)
```

### 5.3 性能优化

#### 向量化操作
```python
# 不推荐：循环处理
result = []
for i in range(len(data)):
    result.append(data[i] * 2)

# 推荐：向量化操作
result = data * 2
```

#### 内存预分配
```python
# 不推荐：动态扩容
result = []
for i in range(1000000):
    result.append(i)

# 推荐：预分配内存
result = np.zeros(1000000)
for i in range(1000000):
    result[i] = i
```

---

## 六、Jupyter Notebook开发规范

### 6.1 文档结构

```markdown
# 实验标题

## 1. 实验目的
简要说明实验目标

## 2. 实验设置
### 2.1 硬件配置
### 2.2 软件环境
### 2.3 参数设置

## 3. 实验步骤
### 3.1 初始化
### 3.2 数据采集
### 3.3 数据处理

## 4. 结果分析
### 4.1 数据可视化
### 4.2 结果讨论

## 5. 结论与建议
```

### 6.2 代码组织

```python
# 单元格1：导入库
import numpy as np
import matplotlib.pyplot as plt
from pynq import Overlay

# 单元格2：配置参数
SAMPLE_RATE = 1000000
DURATION = 1.0

# 单元格3：初始化硬件
overlay = Overlay('design.bit')

# 单元格4：数据采集
data = acquire_data(SAMPLE_RATE, DURATION)

# 单元格5：结果展示
plt.figure(figsize=(10, 6))
plt.plot(data)
plt.xlabel('Time (samples)')
plt.ylabel('Amplitude')
plt.title('Acquired Signal')
plt.show()
```

### 6.3 最佳实践

1. **模块化代码**：将可复用代码封装为函数或类
2. **参数化配置**：关键参数集中管理
3. **错误处理**：添加异常处理机制
4. **日志记录**：记录关键操作和状态
5. **结果保存**：自动保存数据和图表
