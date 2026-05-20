# PYNQ 开发指南 -- 核心知识提取

> 面向 ZYNQ7020 + PYNQ 平台的 NV 色心实验系统项目
> 来源：《领航者 ZYNQ 之 PYNQ 开发指南》

---

## 第一章 初识 PYNQ（page_0008 ~ page_0014）

### 1.1 核心概念和定义

#### PYNQ 是什么

- **PYNQ** = **Python Productivity for Zynq**，即 Zynq 的 Python 生产力，可简记为 **PYNQ = Python + ZYNQ**。
- PYNQ 是 Xilinx 推出的一种**开放源代码框架**，使用 Python 语言和库，使设计人员可以利用 ZYNQ 中**可编程逻辑（PL）**和**微处理器（PS）**的优势来快速构建高性能的嵌入式应用程序。
- PYNQ 的主要目标是使嵌入式系统的设计人员更容易在其应用程序中利用 Xilinx 器件的独特优势，**无需使用 ASIC 风格的设计工具**来设计可编程逻辑电路。
- PYNQ 可与以下平台一起使用：**Zynq、Zynq UltraScale+ MPSoC、Zynq RFSoC、Alveo 加速卡、AWS-F1**。
- 典型高性能应用场景：**并行硬件执行、高帧率视频处理、硬件加速算法、实时信号处理**。

#### PYNQ 不是什么

- **PYNQ 并不是通过 Python 语言直接对 FPGA 进行编程**。PYNQ 框架下不能通过 Python 对 FPGA 进行编程来取代传统的 RTL 编程方式。
- PYNQ 框架是为软件开发者提供了**访问 FPGA 资源的 Python 接口**，Python 开发者可以忽略实现细节，通过 Python 即可轻松访问 FPGA，动态加载各种预编译好的 FPGA 应用，像调用函数一样去调用各种通过 FPGA 加速的应用或者访问连接到 FPGA 的外设。
- 各种 FPGA 应用依然需要专业的硬件工程师使用 **Vivado 工具**进行开发。

#### PYNQ 的三个核心要素

1. 一种高级生产力语言（Python）
2. 带有全面 API 的 FPGA overlays，以 Python 库的形式提供使用
3. 由嵌入式处理器提供基于 Web 体系结构的服务，以及在嵌入式上下文中部署的 Jupyter Notebook 框架

#### Overlay（硬件库）

- **Overlay** 也可称为**硬件库**，是 ZYNQ 的 PL（FPGA）设计，可将用户应用程序从 Zynq 的处理系统 PS 扩展到可编程逻辑 PL。
- Overlay 可用于**加速软件应用程序**，也可为特定应用程序**定制硬件平台**。
- Overlay 可以根据需要**动态加载**到 FPGA，就像软件库一样。
- Overlay 的设计理念：**一次构建，多次使用**。类似于由专家开发人员创建的软件库，然后由应用程序级别的许多其他软件开发人员使用。
- **base overlay**：在启动时默认下载到 PL 中的 overlay（bitstream），可视为开发板的参考设计。

### 1.2 关键技术要点

#### PYNQ 系统架构（三层架构）

| 层级 | 组成 | 说明 |
|------|------|------|
| **硬件层** | FPGA 设计（Overlay） | 实现PS与PL的协同交互，可面向多用户、多应用生成不同的 bitstream 文件，通过软件 API 动态切换 FPGA 上的逻辑功能 |
| **软件层** | Ubuntu 操作系统 + Python + PYNQ API 库 | 运行在 ZYNQ 的 PS 中，PYNQ API 库连接软硬件，通过 Python 访问 FPGA 侧的处理单元 |
| **应用层** | Jupyter Notebook + IPython | 基于浏览器的交互式计算环境，支持记录代码、运行代码并查看结果、可视化数据分析 |

#### PYNQ 使用基于 Ubuntu 的 Linux 的原因

相比嵌入式 Linux，基于 Ubuntu 的 Linux 在以下 5 个方面有优势：

1. **优化方向**：优化开发人员的生产力（而非部署效率）
2. **Linux 库和驱动程序**：支持用户期望的所有 Linux 库和驱动程序
3. **存储媒介**：有预编译的 SD 卡镜像
4. **生态系统和社区**：基于 Ubuntu 和 Debian 的生态系统和社区
5. **社区活跃度**：Google 点击率有 3 个数量级的差异

最大好处：可以使用 Ubuntu 的**根文件系统**和**apt 包管理工具**，几乎囊括所有 Linux 软件和库，省去移植麻烦。

#### Overlay 的三个组成部分

1. **bitstream 文件**：用于配置 FPGA 架构
2. **hwh 文件**（早期使用 Tcl 文件）：确定 Vivado 设计可用 IP
3. **Python API**（归属于 PYNQ 库）：将 IP 公开为属性

### 1.3 重要操作步骤

#### 加载 Overlay 的代码

```python
from pynq import Overlay
overlay_design = Overlay("base.bit")
```

- 实例化 overlay 会**默认下载 bitstream 文件**并**解析 hwh 文件**。
- 实例化后可使用 `help()` 方法了解 overlay 中的内容：`help(overlay_design)`。

### 1.4 代码示例

```python
from pynq import Overlay

# 加载 base overlay（默认下载 bitstream 并解析 hwh 文件）
overlay_design = Overlay("base.bit")

# 查看 overlay 的帮助信息
help(overlay_design)
```

### 1.5 注意事项和避坑要点

1. **PYNQ 不是 FPGA 编程工具**：不能通过 Python 直接对 FPGA 编程，FPGA 应用仍需硬件工程师使用 Vivado 开发。
2. **PYNQ 应用同时包含硬件和软件**：PL bitstreams 和 Python 包，用户必须同时部署这两部分内容才能顺利运行。
3. **Overlay 由硬件工程师创建**：软件开发人员只使用 Python 接口来编程和控制 overlay，无需自己设计。
4. **PYNQ 使用 CPython**：是用 C 编写的，集成了成千上万的 C 库，可以使用 C 编写的优化代码进行扩展。在可行的情况下使用 Python，效率要求高时使用 C 代码。
5. **浏览器兼容性**：PYNQ 使用基于 Web 的体系结构，与浏览器无关，可在任何现代浏览器上运行。

### 1.6 PYNQ 学习资源

| 资源 | 地址 |
|------|------|
| PYNQ 官方网站 | http://www.pynq.io/ |
| PYNQ 官方说明文档 | https://pynq.readthedocs.io/en/latest/ |
| PYNQ 源码 | https://github.com/xilinx/pynq |
| PYNQ 官方 workshop | https://github.com/Xilinx/PYNQ_Workshop |

---

## 第二章 PYNQ 初体验（page_0015 ~ page_0028）

### 2.1 核心概念和定义

本章从烧写 PYNQ 镜像开始，到启动 PYNQ 镜像、打开浏览器进入 Jupyter Notebook，运行图像 resize 实验，对比纯 PS 的运行时间和用 PL 进行硬件加速所需的时间，初步体验 PYNQ 的使用。

### 2.2 关键技术要点

#### 准备工作清单（缺一不可）

| 序号 | 材料 | 说明 |
|------|------|------|
| 1 | 领航者开发板 | 以 7020 核心板为例，7010 类似 |
| 2 | 千兆以太网线 | 连接路由器或直连电脑 |
| 3 | USB Type-C 线 | 连接开发板 USB_UART 接口与电脑 USB 接口 |
| 4 | Micro SD 卡 | 最小 8GB，最大不超过 32GB |
| 5 | 兼容的浏览器 | 推荐 Microsoft Edge；Chrome、Firefox、Safari 可尝试但不保证功能正常 |
| 6 | 串口终端软件 | putty、MobaXterm、SecureCRT 等 |

#### PYNQ 镜像信息

- **镜像版本**：PYNQ v2.7.0
- **7020 镜像文件**：`ZYNQ-7020-2.7.0.zip` -> 解压后得到 `ZYNQ-7020-2.7.0.img`（约 7GB+）
- **7010 镜像文件**：`ZYNQ-7010-2.7.0.zip`
- **镜像路径**：领航者 ZYNQ 开发板资料盘(A盘)\4_SourceCode\5_PYNQ_Design\IMG 目录下
- **注意**：领航者开发板出厂镜像不支持 PYNQ，需要单独烧写 PYNQ 镜像

#### PYNQ 系统信息

- **操作系统**：Ubuntu 20.04
- **用户名**：xilinx
- **密码**：xilinx
- **Linux 内核版本**：5.4.0
- **Jupyter Notebook 密码**：xilinx

#### 串口终端配置

| 参数 | 值 |
|------|------|
| 波特率 | 115200 baud |
| 数据位 | 8 data bits |
| 停止位 | 1 stop bit |
| 奇偶校验 | No Parity |
| 流控制 | No Flow Control |

#### 网络连接

**有联网的路由器**：
- 开发板通过 DHCP 获取动态 IP 地址
- 使用 `ifconfig` 或 `ip a s` 命令查看 IP
- eth0 有两个 IP：一个 DHCP 动态 IP，一个默认静态 IP（192.168.2.99）
- 公众场合建议使用动态 IP；私人场合两种均可
- 可在浏览器中输入 `http://pynq:9090` 访问

**无联网的路由器（直连电脑）**：
- 以太网线直连电脑与开发板
- 需修改电脑以太网适配器的 IPv4 属性
- 在浏览器中输入 `http://192.168.2.99` 访问

#### 图像 resize 性能对比

| 方式 | 耗时 | 说明 |
|------|------|------|
| 纯 PS（软件） | ~427ms | 使用双线性插值法，调用 Python 的 PIL、numpy、matplotlib 库 |
| PL 硬件加速 | ~60.6ms | 将图像 resize 功能封装成 IP 放到 PL 中 |
| **性能提升** | **约 6 倍** | 效率提升计算公式：(1/60.6 - 1/427) / (1/427) * 100% |

#### Samba 文件共享

- PYNQ 默认运行 Samba 服务
- 访问方式：在 Windows 文件资源管理器地址栏输入 `\\pynq` 或 `\\<开发板IP地址>`
- 凭据：用户名 xilinx，密码 xilinx（某些环境只需密码）
- 访问目录对应：`/home/xilinx`（用户家目录）
- Jupyter Notebook 默认工作目录：`/home/xilinx/jupyter_notebooks`

### 2.3 重要操作步骤

#### 步骤一：烧写 PYNQ 镜像到 Micro SD 卡

1. 解压镜像压缩包得到 `.img` 文件
2. 使用 imageUSB 工具（Windows）或 `dd` 命令（Linux）烧写镜像到 SD 卡
3. imageUSB 操作流程：
   - 插入 SD 卡和读卡器
   - 点击刷新按钮识别 USB 设备
   - 勾选目标 USB 设备
   - 选择 "Write image to USB drive"
   - 点击 Browse 选择 `.img` 文件
   - 点击 Write 确认烧录

#### 步骤二：启动 PYNQ 镜像

1. USB Type-C 线连接开发板 USB_UART 与电脑
2. 千兆以太网线连接开发板 PS 以太网口与路由器/电脑
3. SD 卡插入底板 Micro SD 卡槽
4. 启动模式设置为 "SD CARD"
5. 连接电源，打开电源开关
6. 打开串口终端软件，配置端口参数
7. 等待启动完成（如未成功，按 PS 复位键重启）

#### 步骤三：访问 Jupyter Notebook

1. 通过串口终端获取 IP 地址（`ifconfig` 或 `ip a s`）
2. 打开浏览器，输入 IP 地址或 `http://pynq:9090`
3. 输入密码 `xilinx`，点击 "Log in"
4. 进入 Jupyter Notebook 主页面

#### 步骤四：运行 pynq_helloworld

1. 进入 `pynq_helloworld` 文件夹
2. 打开 `resizer_ps.ipynb`，选择 "Cell" -> "Run ALL" 执行，观察纯软件 resize 耗时
3. 打开 `resizer_pl.ipynb`，选择 "Cell" -> "Run ALL" 执行，观察 PL 硬件加速 resize 耗时
4. 对比两者性能差异
5. 关闭 notebook：选择 "File" -> "Close and Halt"

### 2.4 注意事项和避坑要点

1. **SD 卡容量限制**：最小 8GB，最大不超过 32GB，务必使用符合要求的卡。
2. **出厂镜像不支持 PYNQ**：必须单独烧写 PYNQ 镜像。
3. **浏览器兼容性**：最好使用 Microsoft Edge，其他浏览器不保证功能正常。
4. **首次运行警告**：第一次运行 notebook 会出现 Matplotlib 编译 font cache 的用户警告，属于正常现象，等待即可。
5. **内核状态判断**：Python3 kernel 旁的黑色实心圆点表示正在运行，空心圆点表示空闲。
6. **网络连接建议**：应将开发板连接到可访问 Internet 的网络，以便更新和安装新软件包。无 Internet 会导致无法更新或加载新软件包。
7. **自定义图片**：用户可使用自己的图片进行实验，将图片放在 `images` 目录下，并在 notebook 中修改 `image_path` 变量。
8. **Samba 访问**：一定要使用反斜杠 `\\pynq`，不需要引号。

---

## 第三章 初识 Jupyter Notebook 与 IPython（page_0029 ~ page_0050）

### 3.1 核心概念和定义

#### Python / IPython / Jupyter / SciPy 生态系统关系

| 概念 | 说明 |
|------|------|
| **Python** | 高级开源通用编程语言，由 Guido van Rossum 在 1980 年代后期构思，名称来自英国喜剧片 Monty Python's Flying Circus |
| **IPython** | Python 库，最初旨在改善 Python 默认交互式控制台，使其对科学家友好。2011 年推出 IPython Notebook |
| **Jupyter** | 2014 年从 IPython 项目中独立出来，旨在改善 Notebook 实现并使其与语言无关。名称反映三种主要科学计算语言：**Julia、Python、R** |
| **SciPy** | 用于科学计算的 Python 程序包集合，包含 NumPy、SciPy、matplotlib、pandas 等核心库 |

#### SciPy 生态系统核心组件

| 组件 | 创建者 | 功能 |
|------|--------|------|
| **NumPy** | Travis Oliphant 等 | 处理数值数据（从 Numeric -> Numarray -> NumPy 演进） |
| **SciPy** | 在 NumPy 之上创建 | 实现数值计算算法 |
| **matplotlib** | John Hunter | 科学图形 |
| **IPython** | Fernando Perez | 提高 Python 交互性和生产率 |
| **pandas** | Wes McKinney | 处理和分析数值表和时间序列 |

#### Jupyter Notebook 定义

Jupyter Notebook 是一个**开源的、基于 Web 的用于交互式计算的应用程序**，可应用于全过程计算：**开发、文档编写、运行代码和展示结果**。

### 3.2 关键技术要点

#### Jupyter Notebook 的三个组件

1. **Notebook Web 应用程序**：交互式 Web 应用程序，用于交互地编写和运行代码以及编写 Notebook 文档
2. **Kernels（内核）**：Notebook Web 应用程序启动的单独进程，以给定语言运行用户代码并将输出返回给 Web 应用程序。还处理交互式小部件的计算、tab 补全等
3. **Notebook 文档**：包含所有内容的表示形式，保存为 `.ipynb` 的 JSON 格式文件，可导出为 HTML、LaTeX、PDF 等格式。每个 Notebook 文档有自己的 Kernel

#### Jupyter Notebook 主要特点

- 在浏览器中编辑代码，具有**语法高亮、自动缩进、tab 补全**功能
- 直接通过浏览器运行代码，计算结果展示在代码块下方
- 以**富媒体形式**展示计算结果（HTML、LaTeX、PNG、SVG 等）
- 使用 **Markdown 标记语言**编辑富文本
- 使用 **LaTeX** 书写数学符号，由 MathJax 本地呈现

#### 四种单元格类型

| 类型 | 说明 |
|------|------|
| **Code cells（代码单元格）** | 在内核中运行的实时代码的输入和输出 |
| **Markdown cells（Markdown 单元格）** | 带有嵌入式 LaTeX 方程的叙述文本 |
| **Heading cells（标题单元格）** | 已弃用，Markdown 单元格支持标题 |
| **Raw cells（Raw 单元格）** | 未经格式化的文本，使用 nbconvert 转换时才渲染 |

#### Jupyter Notebook 的两种模式

| 模式 | 指示 | 进入方式 | 功能 |
|------|------|----------|------|
| **编辑模式** | 绿色单元格边框 + 光标 | 按 Enter 或单击单元格编辑区域 | 键入代码和文本 |
| **命令模式** | 蓝色左边界 + 灰色边框 | 按 Esc 或单击编辑区域外 | 整体编辑 notebook（复制、粘贴等），键盘映射到快捷方式 |

#### 单元格执行快捷键

| 快捷键 | 功能 |
|--------|------|
| **Shift + Enter** | 运行当前单元格，并在下方插入一个新单元格 |
| **Alt + Enter** | 运行当前单元格，并在下方插入一个新单元格（效果同 Shift+Enter） |
| **Ctrl + Enter** | 运行当前单元格，不插入新单元格 |

#### 命令模式常用快捷键

| 按键 | 功能 |
|------|------|
| `c` | 复制当前单元格 |
| `v` | 在当前单元格下方粘贴 |
| `x` | 剪切当前单元格 |

#### Jupyter Notebook 主界面选项卡

| 选项卡 | 说明 |
|--------|------|
| **Files** | 文件和文件夹管理（类似 Windows 文件资源管理器） |
| **Running** | 显示正在运行的 Notebook 和终端 |
| **Clusters** | 已由 IPython parallel 对接，使用频率较低 |

#### Notebook 文档内部结构

- Notebook 文档使用 **base64 编码的二进制值的 JSON 数据**
- 对版本控制友好
- 可通过 "File" -> "Download as" 导出为 HTML、reStructeredText、LaTeX、PDF 等格式
- "File" -> "Close and Halt"：终止内核并关闭 Notebook

#### Jupyter Notebook 服务器目录

- 默认工作目录：`/home/xilinx/jupyter_notebooks`
- 主界面 "Files" 选项卡下的文件和文件夹来源于该目录

#### 内核（Kernel）管理

- 右上角 "Python 3" 旁边的**黑色实心圆点**表示内核正在运行
- **空心圆点**表示内核处于空闲状态
- 可通过工具栏"停止"按钮**中断内核运行**
- 可通过**重新启动内核**来重置计算状态
- 内核维护 notebook 计算的状态

### 3.3 IPython 关键技术要点

#### IPython 定义

IPython 是一个功能强大的交互式 Python shell，支持变量自动补全、自动缩进、支持 bash shell 命令，内置了许多有用的功能和函数。同时也是供 Jupyter Notebook 使用的一个 Jupyter 内核。

#### IPython 帮助系统

| 命令 | 说明 |
|------|------|
| `?` | IPython 介绍和主要特性概览 |
| `object?` 或 `?object` | 查看 object 的详细信息 |
| `object??` 或 `??object` | 查看 object 的更详细、完整信息（不截断长字符串） |
| `%quickref` | 所有可用 IPython 命令的快速参考 |
| `help()` | 进入 Python 帮助系统，可交互查询 |
| `help(object)` | 单次查询 object 的帮助信息 |
| `%pdoc object` | 查看 object 的 docstring |
| `%magic` | 查看 IPython magic 子系统的信息 |
| `%lsmagic` | 获得所有可用 magic 的列表 |

#### IPython Magic Functions（魔术函数）

Magic functions 是 IPython 的一种特殊功能，也是 IPython 包的关键部分。

**两种类型**：

| 类型 | 前缀 | 作用范围 |
|------|------|----------|
| **行 magic（Line magic）** | `%` | 单行语句，把当前行的其余部分作为参数 |
| **单元 magic（Cell magic）** | `%%` | 多行语句，把当前行及下方整个单元作为参数 |

**常用 magic 函数**：

| Magic 函数 | 说明 |
|------------|------|
| `%timeit` | 多次执行一条语句，返回平均时间 |
| `%%timeit` | 多次执行多条语句，返回平均时间 |
| `%time` | 返回执行一条语句的时间（单次） |
| `%%time` | 返回执行多条语句的时间（单次） |
| `%run` | 运行外部代码 |
| `%reset` | 删除当前空间的全部变量 |
| `%matplotlib inline` | 将 matplotlib 图表直接嵌入到 notebook 中 |

**参数传递规则**：参数传递时不带括号或引号，甚至不需要逗号。

#### `%timeit` 输出解读

```
每个回路 1.61 ms +/- 3.37 us (mean +/- std. dev. of 7 runs, 1000 loops each)
```

- `7 runs`：一共 repeat 了 7 次（调用了 7 次 %timeit）
- `1000 loops each`：每次 repeat 执行语句 1000 次（loops）
- `mean +/- std. dev. of 7 runs`：取 7 次 repeat 后的平均值 +/- 标准偏差

#### `%time` 输出解读

- **CPU time total**：语句执行的总 CPU 时间
- **user**：程序运行在用户态所花的时间
- **sys**：程序运行在内核态所花的时间
- **Wall time**：程序从开始执行到执行结束的总时间（包含 CPU 中断、进程切换等）

#### 在 IPython 中运行 Shell 命令

- 在任何代码单元中，以 `!` 开头的命令被重定向到操作系统 shell（PYNQ 默认使用 bash shell）
- 示例：
  - `!pwd`：获取当前工作目录
  - `!cat /proc/cpuinfo`：获取 CPU 信息
  - `!cat /proc/meminfo | grep 'Mem*'`：使用管道命令获取内存信息
- **Shell 命令与 Python 代码的交互**：
  ```python
  files = !ls | head -3
  print(files)
  ```

#### IPython 的 display 模块

IPython 提供显示模块，可在 notebook 中插入丰富的 Web 元素：
- HTML 列表
- SVG（可缩放矢量图形）
- YouTube 视频（国内不支持）
- 其他富媒体内容

**重要注意**：由于 IPython 在 PS 的 ARM 中运行，所有输出在内核中生成时都是**异步显示**的。一次循环中只能看到一个输出，而不是最后一次全部输出。

### 3.4 重要操作步骤

#### 创建新 Notebook

1. 单击 Jupyter Notebook 主界面右上角的 "New" 按钮
2. 从下拉列表中选择 "Python3"
3. 进入新创建的 notebook 界面

#### 重命名 Notebook

1. 单击页面顶部的 notebook 名称（如 "Untitled"）
2. 在弹出的对话框中输入新名称
3. 点击确认

#### 更改单元格类型

1. 通过工具栏上的下拉菜单（默认为 "Code"）选择单元格类型
2. 或使用菜单栏 "Insert" -> "Insert Cell Below" 插入新单元格后更改类型

#### 使用 Markdown 单元格

1. 将单元格类型改为 Markdown
2. 输入 Markdown 格式文本（支持标题、粗体、斜体、链接、LaTeX 方程、代码块、图片等）
3. 执行单元格（Shift + Enter）渲染显示

#### 中断/重启内核

1. **中断内核**：单击工具栏中的"停止"按钮（内核运行时可用）
2. **重启内核**：通过菜单栏操作重启内核以重置计算状态

#### 导出 Notebook

1. 选择菜单栏 "File" -> "Download as"
2. 选择目标格式（HTML、reStructeredText、LaTeX、PDF 等）

#### 关闭 Notebook

1. 选择菜单栏 "File" -> "Close and Halt"
2. 终止内核并关闭该 Notebook

### 3.5 代码示例

#### 斐波那契数生成函数

```python
def generate_fibonacci_list(limit, output=False):
    nums = []
    current, ne_xt = 0, 1

    while current < limit:
        current, ne_xt = ne_xt, ne_xt + current
        nums.append(current)

    if output == True:
        print(f'{len(nums[:-1])} Fibonacci numbers below the number '
              f'{limit} are:\n{nums[:-1]}')

    return nums[:-1]


limit = 1000
fib = generate_fibonacci_list(limit, True)
```

#### 使用 matplotlib 绘制斐波那契数图形

```python
%matplotlib inline
import matplotlib.pyplot as plt
from ipywidgets import *

limit = 1000000
fib = generate_fibonacci_list(limit)
plt.plot(fib)
plt.plot(range(len(fib)), fib, 'ro')

plt.show()
```

#### 使用 IPython display 模块动态创建 SVG 图形

```python
from IPython.display import SVG
SVG('''<svg width="600" height="80">''' +
''.join([f'''<circle
cx="{(30 + 3*i) * (10 - i)}"
cy="30"
r="{3. * float(i)}"
fill="red"
stroke-width="2"
stroke="black">
</circle>''' for i in range(10)]) +
'''</svg>''')
```

#### Markdown 单元格示例

```markdown
# 一级标题
这是 *轻量级* **标记语言** Markdown 的[链接](http://daringfireball.net/projects/markdown)，
可以书写方程：
$$\hat{f}(\xi) = \int_{-\infty}^{+\infty} f(x)\, \exp \left(-2i\pi x \xi \right) dx$$
和 $e^x=\sum_{i=0}^\infty \frac{1}{i!}x^i$
可以写具有语法高亮的代码：
```python
print("hello to pynq!")
```
可以附有图片：
![jupyter](https://jupyter.org/assets/main-logo.svg)
```

#### %timeit 使用示例

```python
# 单行语句计时（自动多次执行取平均）
%timeit L = [n ** 2 for n in range(1000)]

# 多行语句计时
%%timeit
L = []
for n in range(1000):
    L.append(n ** 2)

# 单次执行计时
%time L = [n ** 2 for n in range(1000)]
```

#### Shell 命令与 Python 交互示例

```python
# 获取当前工作目录
!pwd

# 获取 CPU 信息
!cat /proc/cpuinfo

# 使用管道命令获取内存信息
!cat /proc/meminfo | grep 'Mem*'

# Shell 命令输出赋值给 Python 变量
files = !ls | head -3
print(files)
```

### 3.6 彩蛋：开启 Jupyter Lab

- **Jupyter Lab** 是 Jupyter 的下一代 Notebook 界面，基于 web 的交互式开发环境
- PYNQ 镜像支持 Jupyter Lab，但默认使用 Jupyter Notebook
- **开启方法**：将浏览器地址栏 URL 中的 `tree` 改为 `lab`
  - Jupyter Notebook URL：`http://192.168.2.99:9090/tree`
  - Jupyter Lab URL：`http://192.168.2.99:9090/lab`
- Jupyter Lab 界面右侧的启动器（Launcher）可通过左侧 "+" 号打开
- 退出 notebook 等应用可使用快捷键 **Ctrl + Shift + q**

### 3.7 注意事项和避坑要点

1. **Markdown 单元格中的网络图片**：需要连接可以联网的路由器才可以显示（如 `![jupyter](https://jupyter.org/assets/main-logo.svg)`）。
2. **命令模式 vs 编辑模式**：在命令模式下不要尝试键入代码或文本，以防意外操作（如按 `c` 会复制单元格而非输入字母 c）。
3. **异步输出**：IPython 在 PS 的 ARM 中运行，所有输出在内核中生成时都是异步显示的，循环中的 print 语句一次只能看到一个输出。
4. **代码缩进**：Python 代码缩进要用 Tab，否则编译会报错。
5. **性能考虑**：由于 IPython 运行在 ZYNQ 的 PS（ARM 处理器）上，对于大数据量的计算（如生成 1000000 以内的斐波那契数图形），结果生成较慢。
6. **%timeit 自动多次执行**：对于短命令，%timeit 会自动执行多次以获取可靠结果，不适合有副作用的语句。
7. **%time vs %timeit**：不想多次重复执行时应使用 %time（单次执行），而非 %timeit。
8. **内核状态维护**：内核维护 notebook 计算的状态，变量在不同单元格之间共享。如需重置，应重启内核。
9. **每个 Notebook 有自己的 Kernel**：不同 Notebook 之间的变量和状态是隔离的。
10. **getting_started 目录**：Jupyter Notebook 主界面中 `getting_started` 文件夹包含一些 Jupyter 入门的 Notebook，其中 `3_jupyter_notebooks_advanced_features.ipynb` 包含 Matplotlib 高级用法代码。


---


# PYNQ 开发指南 -- 第四章至第六章核心知识提取

> 适用平台：ZYNQ7020 + PYNQ（领航者开发板）
> 项目背景：NV 色心实验系统

---

## 第四章 PS 与 PL 的交互

### 4.1 核心概念和定义

ZYNQ 芯片中 PS（Processing System，处理系统）与 PL（Programmable Logic，可编程逻辑）之间通过多种 AXI 接口进行交互。PYNQ 框架基于 Linux 操作系统，运行在 PS 侧，通过 Linux 驱动和 Python 封装库实现对 PL 的控制。

#### ZYNQ PS 与 PL 之间的 AXI 接口（共 9 路）

| 接口类型 | 数量 | 方向 | 说明 |
|----------|------|------|------|
| AXI Master HP（High Performance） | 4 路 | PL -> PS | 高性能接口，PL 主动访问 PS |
| AXI Master GP（General Purpose） | 2 路 | PL -> PS | 通用接口，PL 主动访问 PS |
| AXI Slave GP（General Purpose） | 2 路 | PS -> PL | 通用接口，PS 主动访问 PL |
| AXI Master ACP（Accelerator Coherency Port） | 1 路 | PL -> PS | 加速器一致性端口 |

此外，PS 中还有连接到 PL 的 **GPIO 控制器**（即 EMIO 接口）。

### 4.2 关键技术要点 -- Linux 驱动与 PS/PL 接口的对应关系

| Linux 驱动 | 对应的 PS-PL 接口 | 功能 |
|------------|-------------------|------|
| `fpga_manager` | -- | 下载 bitstream 文件到 PL |
| `sysgpio` | EMIO（PS GPIO 控制器） | 控制 PS 与 PL 之间的 EMIO 接口 |
| `uio` | -- | 实现 PL 到 PS 的中断管理 |
| `devmem` | AXI Master GP | PS 侧的 AXI Master GP 接口访问 |
| `xrt` | AXI Slave HP / AXI Slave GP | PS 侧的高性能和通用 Slave 接口访问 |

> **注意**：在 PYNQ 2.7 版本以后的镜像中，官方删除了 Xlnk 分配器和库，替换为 XRT 分配。

### 4.3 PYNQ 四个核心接口类

PYNQ 将上述 Linux 驱动封装为 Python 库，提供以下四个接口类来管理 PS（包括 PS DRAM）和 PL 接口之间的数据移动：

| 类名 | 全称 | 功能说明 | 适用场景 |
|------|------|----------|----------|
| `GPIO` | General Purpose Input/Output | 通用输入/输出 | 控制 PL 侧 GPIO 外设、IP 的中断或复位信号 |
| `MMIO` | Memory Mapped IO | 内存映射 IO | Python 代码访问与 PS AXI Master GP 接口相连的、具有 PL AXI Slave 接口的 IP |
| `Xrt` | Memory allocation | 内存分配 | 为具有 AXI Master 接口的 IP 分配 DRAM 内存 |
| `DMA` | Direct Memory Access | 直接内存访问 | PS DRAM 与 IP 之间的高性能数据传输 |

**类选择原则**：
- IP 连接到 ZYNQ PS 的哪个接口，以及 IP 自身具有什么接口，决定了使用哪个类。
- 具有 AXI Slave 接口的 IP -> 使用 `MMIO` 类
- 具有 AXI Master 接口的 IP -> 先用 `Xrt` 类分配内存，再使用
- 需要高性能数据传输 -> 使用 `DMA` 类
- 需要 GPIO 控制 -> 使用 `GPIO` 类

### 4.4 Overlay 类

`Overlay` 类用于通过 `fpga_manager` 驱动下载 bitstream 文件到 PL。通过指定 bitstream 文件名称来实例化 Overlay，实例化时会自动下载位流文件并解析 hwh 文件。

---

## 第五章 Overlay 之 GPIO 实验（EMIO）

### 5.1 核心概念和定义

**EMIO（Extended MIO）**：ZYNQ 器件具有从 PS 到 PL 的多达 64 个 GPIO，称为 EMIO。EMIO 是 PS 与 PL 进行交互的最简单直接的方式，PL 不需要 IP 即可使用。可用于：
- IP 的复位或中断控制信号
- 控制 PL 侧的 GPIO 外设（LED、按键、蜂鸣器等）

**Overlay 设计中涉及的两种 GPIO**：
1. **EMIO** -- 本章内容，通过 PS GPIO 控制器直接控制
2. **AXI GPIO** -- 下一章内容，通过 AXI4-Lite 接口控制

### 5.2 关键技术要点 -- GPIO 类

#### GPIO 类（`pynq.gpio` 模块）

- **模块文件**：`pynq/lib/gpio.py`
- **参考文档**：https://pynq.readthedocs.io/en/latest/pynq_package/pynq.gpio.html#pynq-gpio

#### Zynq GPIO 的 Linux 内核映射

Zynq 的 GPIO 使用 Linux 内核模块控制，操作系统运行时会为 GPIO 分配一个数字编号。在 PYNQ 中使用 GPIO 前，必须将 Linux 引脚号映射到 Python GPIO 实例。

#### GPIO 类 API

| API | 说明 |
|-----|------|
| `GPIO.get_gpio_pin(pin_number)` | 静态方法，将 Zynq GPIO 引脚号映射到 Linux gpio 引脚号 |
| `GPIO(pin, direction)` | 构造函数，`pin` 为 `get_gpio_pin()` 返回值，`direction` 为 `'in'` 或 `'out'` |
| `gpio.write(n)` | 写入方法，`n` 只能为 `0`（低电平）或 `1`（高电平），仅用于输出型 GPIO |
| `gpio.read()` | 读取方法，返回当前电平值（0 或 1），仅用于输入型 GPIO |

### 5.3 Overlay 设计步骤（Vivado 工程配置）

#### 5.3.1 Vivado 工程配置

1. **基础工程**：基于"Hello World 实验"的 Vivado 工程，另存为名为 `ps_gpio` 的工程
2. **ZYNQ IP 核配置**：将 EMIO 设置为 **7**（7 个 EMIO 用于连接 PL 端外设）
3. **验证设计**：按 F6 验证

#### 5.3.2 引脚约束

```tcl
# -------------------------EMIO-------------------
# PL_KEY 54 55
set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 } [get_ports { GPIO_tri_io[0] }]
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { GPIO_tri_io[1] }]
# TPAD 56
set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports { GPIO_tri_io[2] }]
# BEEP 57
set_property -dict { PACKAGE_PIN M14 IOSTANDARD LVCMOS33 } [get_ports { GPIO_tri_io[3] }]
# PL_LED 58-60
set_property -dict { PACKAGE_PIN J16 IOSTANDARD LVCMOS33 } [get_ports { GPIO_tri_io[4] }]
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports { GPIO_tri_io[5] }]
set_property -dict { PACKAGE_PIN L15 IOSTANDARD LVCMOS33 } [get_ports { GPIO_tri_io[6] }]
```

#### 5.3.3 EMIO 与 PL 外设的映射关系

| EMIO 引脚 | PL 外设 | 方向 |
|-----------|---------|------|
| GPIO 0 | PL_KEY0（按键0） | 输入 |
| GPIO 1 | PL_KEY1（按键1） | 输入 |
| GPIO 2 | TPAD（触摸按键） | 输入 |
| GPIO 3 | BEEP（蜂鸣器） | 输出 |
| GPIO 4 | PL_LED0 | 输出 |
| GPIO 5 | PL_LED1 | 输出 |
| GPIO 6 | PL_LED2 | 输出 |

#### 5.3.4 使用 Overlay 前的准备工作

1. 在 Vivado 工程目录下新建 `ready_to_test` 文件夹
2. **导出 bitstream 文件**：File -> Export -> 选择 `ready_to_test` 文件夹 -> 文件名输入 `/ps_gpio` -> Save
3. **获取 hwh 文件**：从 `ps_gpio.srcs\sources_1\bd\system\hw_handoff` 目录下复制 `system.hwh` 到 `ready_to_test` 文件夹
4. **重命名 hwh 文件**：将 `system.hwh` 重命名为 `ps_gpio.hwh`（必须与 bitstream 文件同名）

> **关键注意**：hwh 文件必须和 bitstream 文件同名！hwh 文件存有 Vivado 工程的硬件配置信息（如使用的 AXI IP 核及其配置），PYNQ 通过读取 hwh 文件获取硬件配置信息。

### 5.4 Overlay 应用 -- Python API 使用方法

#### 5.4.1 上传 Overlay 到 PYNQ 开发板

1. 连接网线启动 PYNQ，确保已连接网络
2. 获取 IP 地址：串口输入 `ip a s` 或 `ifconfig`
3. Windows 文件资源管理器地址栏输入 `\\pynq` 或 `\\<IP地址>`（如 `\\192.168.2.99`）
4. 输入密码 `xilinx`
5. 进入 `jupyter_notebooks` 目录（Jupyter Notebook/Lab 默认工作目录）
6. 新建 `app` 目录，将 `ready_to_test` 文件夹复制到 `app` 目录下

#### 5.4.2 加载 Overlay

```python
from pynq import Overlay
ps_gpio = Overlay("./ready_to_test/ps_gpio.bit")
```

- `Overlay` 类通过指定 bitstream 文件名称来实例化
- 实例化时会自动下载位流文件并解析 hwh 文件
- 下载过程中 Notebook 右上角 Kernel 状态为实心圆

#### 5.4.3 检查 Overlay 状态

```python
ps_gpio.is_loaded()  # 返回 True 表示 bitstream 已下载到 PL
help(ps_gpio)        # 查看 Overlay 帮助信息
```

### 5.5 代码示例

#### 示例 1：实例化输出型 GPIO（LED 和蜂鸣器）

```python
from pynq import GPIO

led0 = GPIO(GPIO.get_gpio_pin(4), 'out')
led1 = GPIO(GPIO.get_gpio_pin(5), 'out')
led2 = GPIO(GPIO.get_gpio_pin(6), 'out')
beep = GPIO(GPIO.get_gpio_pin(3), 'out')
```

#### 示例 2：LED 交替闪烁（10 次循环）

```python
from time import sleep

for i in range(10):
    led1.write(1)
    led2.write(0)
    sleep(0.5)
    led1.write(0)
    led2.write(1)
    sleep(0.5)
```

#### 示例 3：读取输入型 GPIO（按键和触摸按键）

```python
from pynq import GPIO

button0 = GPIO(GPIO.get_gpio_pin(0), 'in')
button1 = GPIO(GPIO.get_gpio_pin(1), 'in')
tpad = GPIO(GPIO.get_gpio_pin(2), 'in')

print(f"Button0: {button0.read()}")
print(f"Button1: {button1.read()}")
print(f"tpad: {tpad.read()}")
```

> **默认电平**：按键（button）默认为高电平（1），触摸 tpad 默认为低电平（0）。

#### 示例 4：触摸按键控制蜂鸣器

```python
while button0.read() == 1:
    beep.write(tpad.read())
    print(f"Button0: {button0.read()}")
```

- `button0` 默认为 1，循环默认一直有效
- `tpad` 默认为 0，蜂鸣器高电平有效，不触碰时无响应
- 触碰 tpad 时蜂鸣器鸣叫
- 按下 `button0`（PL_KEY0）退出 while 循环

### 5.6 注意事项和避坑要点

1. **hwh 文件必须与 bitstream 文件同名**，否则 PYNQ 无法正确解析硬件配置
2. **EMIO 引脚编号从 0 开始**，与 Vivado 中 `GPIO_tri_io[n]` 的索引一一对应
3. **GPIO 方向必须正确设置**：输出型用 `'out'`，输入型用 `'in'`
4. **`write(n)` 的 n 只能为 0 或 1**，不能写入其他值
5. **使用 `sleep()` 前需要先导入**：`from time import sleep`
6. **EMIO 总数最多 64 个**，本实验使用了 7 个
7. **早期 PYNQ 版本使用 tcl 文件**，当前版本推荐使用 hwh 文件

---

## 第六章 Overlay 之 AXI GPIO 实验

### 6.1 核心概念和定义

**AXI GPIO IP 核**：为 AXI 接口提供通用的输入/输出接口的软核（Soft IP）。与 PS 端的 GPIO（硬核 Hard IP）不同，AXI GPIO 是由用户通过配置 PL 端逻辑资源实现的功能模块。

**AXI GPIO 特性**：
- 可配置为**单通道**或**双通道**
- 每个通道的位宽可以单独设置
- 通过打开或关闭三态缓冲器，接口可动态配置为输入或输出
- 左侧实现 **AXI4-Lite Slave 接口**，用于主机访问内部各通道寄存器
- 可向主机产生中断信号（需在配置 IP 核时选择"使能中断"）

**PS 与 PL 交互方式对比**：
- EMIO（上一章）：最简单直接，不需要 IP
- AXI GPIO（本章）：通过 AXI4-Lite 接口通信，是 PS 与 PL **最主要**的交互方式

### 6.2 关键技术要点 -- AxiGPIO 类

#### AxiGPIO 类（`pynq.lib.axigpio` 模块）

- **模块文件**：`pynq/lib/axigpio.py`
- **参考文档**：https://pynq.readthedocs.io/en/latest/pynq_package/pynq.lib/pynq.lib.axigpio.html
- **导入方式**：`from pynq.lib import AxiGPIO`

#### AxiGPIO 类 API

| API / 属性 | 说明 |
|------------|------|
| `AxiGPIO(ip_dict_entry)` | 构造函数，参数为 `overlay.ip_dict[key]` 返回的 IP 字典条目 |
| `axigpio.channel1` | 访问通道 1 |
| `axigpio.channel2` | 访问通道 2（双通道模式） |
| `channel[n:m]` | 使用切片符号访问通道中的 GPIO，步幅（step）只能为 1 |
| `channel.read()` | 读取通道值（输入型 GPIO） |
| `channel[n:m].write(value)` | 写入值到通道（输出型 GPIO） |
| `channel[n:m].off()` | 关闭指定范围的 GPIO（全部置低） |

#### GPIO 方向与操作对照

| 接口配置 | 支持的操作 |
|----------|-----------|
| 输入（In） | `read()` 读取 |
| 输出（Out） | `write(value)` 写入、`off()` 关闭 |
| 双向（InOut） | 结合输入和输出功能，三态由上一次读取或写入决定 |

### 6.3 Overlay 设计步骤（Vivado 工程配置）

#### 6.3.1 Vivado 工程配置

1. **基础工程**：基于"AXI GPIO 按键控制 LED 实验"的 Vivado 工程，另存为名为 `axi_gpio` 的工程
2. **修改内容**：
   - 去除 ZYNQ IP 核的中断（本章不使用中断）
   - 添加两个 AXI GPIO IP（共三个 AXI GPIO IP）
   - 对 AXI GPIO IP 进行重命名

#### 6.3.2 三个 AXI GPIO IP 的配置

| IP 名称 | 通道配置 | GPIO 宽度 | 方向 | 连接外设 |
|---------|----------|-----------|------|----------|
| `leds` | 单通道 | 2 | 输出（Out） | 2 个 PL LED |
| `buttons` | 单通道 | 2 | 输入（In） | 2 个 PL 按键 |
| `tpad` | 单通道 | 1 | 输入（In） | 1 个触摸按键 |

#### 6.3.3 引脚约束

```tcl
# PL_KEY
set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 } [get_ports { btns_tri_io[0] }]
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { btns_tri_io[1] }]
# TPAD
set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [get_ports { tpad_tri_io }]
# PL_LED
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports { leds_tri_io[0] }]
set_property -dict { PACKAGE_PIN L15 IOSTANDARD LVCMOS33 } [get_ports { leds_tri_io[1] }]
```

#### 6.3.4 使用 Overlay 前的准备工作

与上一章相同：
1. 在工程目录下新建 `ready_to_test` 文件夹
2. 导出 bitstream 文件为 `axi_gpio.bit`
3. 复制并重命名 hwh 文件为 `axi_gpio.hwh`

### 6.4 Overlay 应用 -- Python API 使用方法

#### 6.4.1 加载 Overlay

```python
from pynq import Overlay
axi_gpio = Overlay("./ready_to_test/axi_gpio.bit")
```

#### 6.4.2 查看 Overlay 中的 AXI IP 信息

```python
axi_gpio?          # 查看 overlay 中使用的 AXI IP 列表（IP Blocks）
axi_gpio.ip_dict   # 查看 IP 字典（包含物理地址、地址范围、IP 类型、参数、寄存器空间等）
```

**IP 字典结构**：
- `ip_dict` 中的 key 对应 Vivado 中 AXI GPIO IP 的名称（如 `leds`、`buttons`、`tpad`）
- 每个 key 包含：
  - **IP 类型**：如 `xilinx.com:ip:axi_gpio:2.0`
  - **路径**：如 `tpad`
  - **物理地址（phys_addr）**：如 `0x41220000`（十进制 1092747264）
  - **地址范围（addr_range）**：如 `65536`（即 64KB）
  - **PYNQ 驱动文件**：如 `pynq/lib/axigpio.py`

#### 6.4.3 查看物理地址（十六进制）

```python
hex(axi_gpio.ip_dict["tpad"]["phys_addr"])  # 输出: '0x41220000'
```

### 6.5 代码示例

#### 示例 1：驱动 LED 交替闪烁

```python
from pynq.lib import AxiGPIO
from time import sleep

led_instance = axi_gpio.ip_dict['leds']
led = AxiGPIO(led_instance).channel1

for i in range(10):
    led[0:2].write(0x1)   # LED0 亮，LED1 灭
    sleep(0.5)
    led[0:2].write(0x2)   # LED0 灭，LED1 亮
    sleep(0.5)
```

**代码解析**：
- `axi_gpio.ip_dict['leds']` -- 从 IP 字典获取 leds IP 的配置信息
- `AxiGPIO(led_instance).channel1` -- 实例化 AxiGPIO 并获取通道 1
- `led[0:2]` -- 切片访问，`[0:2]` 是掩码，表示访问 channel1 的第 0~1 位
- `write(0x1)` -- 写入值，0x1 = 二进制 01，LED0 亮 LED1 灭
- `write(0x2)` -- 写入值，0x2 = 二进制 10，LED0 灭 LED1 亮

#### 示例 2：关闭所有 LED

```python
led[0:2].off()
```

#### 示例 3：读取按键和触摸按键

```python
buttons_instance = axi_gpio.ip_dict['buttons']
buttons = AxiGPIO(buttons_instance).channel1

tpad_instance = axi_gpio.ip_dict['tpad']
tpad = AxiGPIO(tpad_instance).channel1

print(f"buttons: {buttons.read()}")  # 默认输出 3 (0x11，两个按键都为高电平)
print(f"tpad: {tpad.read()}")        # 默认输出 0（低电平）
```

> **默认电平**：按键默认高电平（值为 3 即 0x11），触摸 tpad 默认低电平（值为 0）。

#### 示例 4：按键控制 LED（综合示例）

```python
while tpad.read() == 0:
    led[0:2].write(buttons.read())
print(f"tpad: {tpad.read()}")
```

- 不触碰 tpad 时，while 循环持续有效
- 按下按键时，相应 LED 熄灭（按键按下为低电平）
- 触碰 tpad 后退出循环，打印 tpad 值（输出 1）

### 6.6 注意事项和避坑要点

1. **AXI GPIO IP 名称必须与 `ip_dict` 的 key 对应**：Vivado 中对 AXI GPIO IP 的重命名（如 `leds`、`buttons`、`tpad`）会直接成为 `ip_dict` 的 key，Python 代码中通过该 key 访问 IP
2. **AxiGPIO 类与 GPIO 类不同**：EMIO 使用 `from pynq import GPIO`，AXI GPIO 使用 `from pynq.lib import AxiGPIO`
3. **切片步幅只能为 1**：`channel[n:m]` 的步幅固定为 1，不支持其他步幅
4. **`write()` 的值是位模式**：如 `write(0x1)` 控制的是所有指定引脚的位模式，不是单个引脚的值
5. **AXI GPIO 是软核**，占用 PL 资源；EMIO 是硬核，不占用 PL 资源
6. **中断功能需在 Vivado 中显式启用**：配置 AXI GPIO IP 时选择"使能中断"才会启用中断控制功能
7. **AXI GPIO 的地址范围固定为 65536（64KB）**，这是 AXI4-Lite 接口的标准地址空间
8. **IP 字典中的物理地址可在 Vivado 工程中验证**：打开 Vivado 工程查看对应 IP 的地址分配，应与 `ip_dict` 中的 `phys_addr` 一致

---

## 附录：EMIO GPIO vs AXI GPIO 对比总结

| 对比项 | EMIO GPIO | AXI GPIO |
|--------|-----------|----------|
| Python 类 | `pynq.GPIO` | `pynq.lib.AxiGPIO` |
| 导入语句 | `from pynq import GPIO` | `from pynq.lib import AxiGPIO` |
| IP 类型 | 硬核（Hard IP） | 软核（Soft IP） |
| 接口方式 | EMIO（PS GPIO 控制器） | AXI4-Lite Slave |
| 最大数量 | 64 个 | 取决于 PL 资源 |
| 通道 | 无通道概念 | 支持 channel1、channel2 |
| 位宽控制 | 每引脚独立 | 每通道可配置位宽 |
| 切片访问 | 不支持 | 支持 `channel[n:m]` |
| PL 资源占用 | 不占用 | 占用（LUT、FF 等） |
| 访问方式 | `get_gpio_pin()` 映射 | `ip_dict[key]` 获取 |
| 写入方法 | `write(0)` / `write(1)` | `write(value)` 支持多位值 |
| 关闭方法 | `write(0)` | `off()` |
| 适用场景 | 简单 GPIO 控制 | 需要更多 GPIO 或更复杂控制 |


---


# PYNQ 开发指南 -- 核心知识提取

> 面向 ZYNQ7020 + PYNQ 平台的 NV 色心实验系统项目
>
> 涵盖第七章（MMIO 类）、第八章（DMA 实验）、第九章（图像缩放 helloworld）

---

## 第七章 Overlay 之 MMIO 类实验（page_0078 ~ page_0087）

### 7.1 核心概念和定义

**MMIO（Memory Mapped I/O）**：内存映射 I/O。连接到 AXI Slave GP（General Purpose）接口的任何 IP 都将其寄存器或地址空间映射到系统内存映射中。MMIO 类允许 Python 对象访问映射到系统内存中的地址，特别是可以访问 PL 中外围设备的寄存器和地址空间。

**适用场景**：
- MMIO 读取或写入命令分别是将 **32 位数据**从内存位置取出或向内存位置写入
- MMIO **不支持突发（burst）指令**
- 最适合 IP 通过 AXI Slave GP 端口**读取和写入少量数据**
- 对于具有少量存储器访问权限或性能要求不高的简单外围设备，MMIO 已足够
- 如果性能至关重要，或需要在 PS 和 PL 之间传输大量数据，应使用 **AXI DMA IP + PYNQ DMA 类**（通过 Zynq HP 接口）

**对应接口**：AXI Slave GP 接口

**对应 PYNQ 库文件**：`mmio.py`

**参考文档**：https://pynq.readthedocs.io/en/latest/pynq_package/pynq.mmio.html#pynq-mmio

---

### 7.2 关键技术要点

#### 7.2.1 MMIO 类构造方法

```python
from pynq import MMIO
mmio = MMIO(IP_BASE_ADDRESS, ADDRESS_RANGE)
```

| 参数 | 说明 |
|------|------|
| `IP_BASE_ADDRESS` | IP 核的物理内存基地址 |
| `ADDRESS_RANGE` | 需要访问的内存地址范围长度（字节数） |

#### 7.2.2 MMIO 类核心方法

| 方法 | 说明 |
|------|------|
| `mmio.write(offset, data)` | 向指定偏移地址写入 32 位数据 |
| `mmio.read(offset)` | 从指定偏移地址读取 32 位数据 |
| `mmio.write(offset, data)` | 等同于 write，写入数据寄存器 |

#### 7.2.3 获取 IP 物理地址

通过 Overlay 的 `ip_dict` 属性获取 IP 核的物理内存地址：

```python
from pynq import Overlay
overlay = Overlay("./ready_to_test/axi_gpio.bit")

# 获取各 IP 核的物理地址
tpad_address = overlay.ip_dict['tpad']['phys_addr']
leds_address = overlay.ip_dict['leds']['phys_addr']
buttons_address = overlay.ip_dict['buttons']['phys_addr']
```

#### 7.2.4 通过 ip_dict 查看寄存器信息

```python
overlay.ip_dict  # 展开 IP 字典，查看各 IP 的 registers 信息
```

每个 IP 的 `registers` 字段包含：
- 寄存器名称（如 `GPIO_DATA`、`GPIO_TRI`）
- `address_offset`：寄存器偏移地址
- `size` / `bit_width`：位宽信息

#### 7.2.5 AXI GPIO IP 核寄存器（pg144-axi-gpio.pdf）

| 寄存器 | 偏移地址 | 说明 |
|--------|----------|------|
| `GPIO_DATA`（通道1数据寄存器） | `0x0000` | 存放当前 GPIO 的值，不同位宽代表不同数量的 GPIO 值（最大 32 位宽 = 32 个 GPIO） |
| `GPIO_TRI`（通道1三态寄存器） | `0x0004` | 动态配置 GPIO 方向：相应位为 **0** = 输出（Output），相应位为 **1** = 输入（Input） |

**ADDRESS_RANGE 计算方法**：

```
LENGTH = 需访问的偏移最远的寄存器地址 + 4
```

例如：需访问 GPIO_DATA（偏移 0x0）和 GPIO_TRI（偏移 0x4），则 `LENGTH = 0x4 + 4 = 8` Byte。

---

### 7.3 Overlay 设计步骤

本章复用上一章（GPIO 类实验）的 Vivado 工程，**无需单独设计 overlay**。系统框架包含：
- ZYNQ PS
- AXI GPIO IP 核（分别连接 LED、按键、触摸按键）
- AXI Interconnect

---

### 7.4 Python API 使用方法与代码示例

#### 7.4.1 加载 Overlay 并获取地址

```python
from pynq import Overlay
axi_gpio_design = Overlay("./ready_to_test/axi_gpio.bit")

tpad_address = axi_gpio_design.ip_dict['tpad']['phys_addr']
leds_address = axi_gpio_design.ip_dict['leds']['phys_addr']
buttons_address = axi_gpio_design.ip_dict['buttons']['phys_addr']

print("Physical address of tpad: 0x" + format(tpad_address, '02x'))
print("Physical address of leds: 0x" + format(leds_address, '02x'))
print("Physical address of buttons: 0x" + format(buttons_address, '02x'))
```

#### 7.4.2 MMIO 控制 LED（输出型 GPIO）

```python
from pynq import MMIO
from time import sleep

LENGTH = 8
leds = MMIO(leds_address, LENGTH)
leds.write(0x4, 0x0)  # 写入三态寄存器，配置为输出模式

for i in range(10):
    leds.write(0x0, 0x1)  # 点亮 LED0，熄灭 LED1
    sleep(0.5)
    leds.write(0x0, 0x2)  # 点亮 LED1，熄灭 LED0
    sleep(0.5)
```

**要点**：
- `leds.write(0x4, 0x0)` -- 向偏移 0x4（GPIO_TRI）写入 0x0，配置为输出
- `leds.write(0x0, 0x1)` -- 向偏移 0x0（GPIO_DATA）写入 0x1，点亮 LED0
- `leds.write(0x0, 0x2)` -- 向偏移 0x0（GPIO_DATA）写入 0x2，点亮 LED1

#### 7.4.3 MMIO 读取按键（输入型 GPIO）

```python
buttons = MMIO(buttons_address, LENGTH)
buttons.write(0x4, 0xffffffff)  # 配置为输入模式

tpad = MMIO(tpad_address, LENGTH)
tpad.write(0x4, 0xffffffff)     # 配置为输入模式

print(f"buttons: {buttons.read()}")
print(f"tpad: {tpad.read()}")
```

**要点**：
- 输入型 GPIO 需向 GPIO_TRI 写入 `0xffffffff`（全 1 = 全部配置为输入）
- 默认状态下：按键为**高电平**，触摸 tpad 为**低电平**

#### 7.4.4 综合示例：按键控制 LED

```python
while tpad.read(0x0) == 0:           # tpad 未触碰时循环
    leds.write(0x0, buttons.read(0x0))  # 将按键值写入 LED
print(f"tpad: {tpad.read()}")         # 触碰 tpad 后退出，输出 1
```

**逻辑**：按下按键时对应 LED 熄灭（按键按下为低电平），触碰 tpad 后退出循环。

---

### 7.5 注意事项和避坑要点

1. **MMIO 不支持突发传输**：仅适合少量数据读写，大数据量传输请使用 DMA
2. **ADDRESS_RANGE 计算要准确**：必须覆盖所有需要访问的寄存器偏移地址 + 4 字节
3. **三态寄存器必须正确配置**：输出型写 `0x0`，输入型写 `0xffffffff`
4. **GPIO_DATA 是最低有效位**：2 个 LED 只需关注最低 2 bit
5. **MMIO 读写单位为 32 位**：每次 read/write 操作的是 32 位（4 字节）数据
6. **可通过 overlay.ip_dict 查看寄存器信息**：不一定需要查阅 IP 手册

---

## 第八章 Overlay 之 DMA 实验（page_0088 ~ page_0094）

### 8.1 核心概念和定义

**AXI DMA IP**：用于 PS DRAM 和 PL 之间的高性能突发传输。PYNQ 通过 DMA 类支持 AXI DMA IP。

**DMA 接口组成**：
- **AXI Lite 控制接口**：用于配置和控制 DMA
- **读取通道（Read Channel / sendchannel）**：从 PS DRAM（通过 HP 或 ACP 端口）读取数据，写入 AXI4 Stream（发送给 PL IP）
- **写入通道（Write Channel / recvchannel）**：从 AXI4 Stream 读取数据，写回到 PS DRAM

**DMA 类仅支持简单模式（Simple Mode）**，不支持 Scatter Gather 模式。

**TLAST 信号**：当事务完成时，DMA 期望连接到 DMA 写通道的任何 stream IP 都将设置 **AXI TLAST 信号**。如果未设置，DMA 将永远不会完成事务。**使用 HLS 生成 IP 时，必须在 C 代码中设置 TLAST 信号。**

**默认最大事务大小**：实例化 DMA 时默认为 **14 位**（即 2^14 = **16KB**）。对于较大的 DMA 事务，需在 Vivado IPI 设计中增加该值。

**对应 PYNQ 库文件**：`dma.py`（pynq.lib.dma 模块）

---

### 8.2 关键技术要点

#### 8.2.1 DMA 类核心属性和方法

| 属性/方法 | 说明 |
|-----------|------|
| `overlay.axi_dma_xxx` | 通过 overlay 字典获取 DMA 对象 |
| `dma.sendchannel` | 读取通道：从 DDR 读取数据发送到 AXI Stream |
| `dma.recvchannel` | 写入通道：从 AXI Stream 读取数据写入 DDR |
| `dma.sendchannel.transfer(buffer)` | 启动发送通道传输 |
| `dma.recvchannel.transfer(buffer)` | 启动接收通道传输 |
| `dma.sendchannel.wait()` | 等待发送通道传输完成（不使用中断） |
| `dma.recvchannel.wait()` | 等待接收通道传输完成（不使用中断） |
| `dma.sendchannel.wait_async()` | 等待发送通道传输完成（使用中断，需启用并连接中断） |
| `dma.recvchannel.wait_async()` | 等待接收通道传输完成（使用中断，需启用并连接中断） |

#### 8.2.2 内存缓冲区分配

DMA 传输的 buffer 必须是通过 `pynq.allocate()` 函数分配的 **PynqBuffer 对象**：

```python
from pynq import allocate
import numpy as np

buffer = allocate(shape=(N,), dtype=np.uint32)
```

**使用完 buffer 后必须释放**：

```python
del input_buffer, output_buffer
```

#### 8.2.3 DMA 传输流程

```
1. 分配 input_buffer 和 output_buffer（pynq.allocate）
2. 将数据写入 input_buffer
3. dma.sendchannel.transfer(input_buffer)   # DDR -> Stream
4. dma.recvchannel.transfer(output_buffer)  # Stream -> DDR
5. dma.sendchannel.wait()                   # 等待发送完成
6. dma.recvchannel.wait()                   # 等待接收完成
7. 验证 output_buffer 中的数据
8. del input_buffer, output_buffer          # 释放内存
```

---

### 8.3 Overlay 设计步骤

#### 8.3.1 Vivado 工程配置

本章基于《领航者 ZYNQ 之嵌入式 Vitis 开发指南》"AXI DMA 环路测试"的 Vivado 工程，另存为 `dma_tutorial`。

**关键修改 -- 添加中断控制器**：

在 PYNQ 中，**所有 PL 中断都必须经中断控制器 AXI Interrupt Controller IP 连接到 ZYNQ IP**，否则运行时会报错。

修改步骤：
1. 在 Block Design 中添加 **AXI Interrupt Controller IP**
2. 将 **Concat IP** 的输出接到 AXI Interrupt Controller IP 的 `intr` 输入引脚
3. 将 AXI Interrupt Controller IP 的 `irq` 引脚连接到 **ZYNQ IP 的中断输入引脚 `IRQ_F2P`**
4. 其他引脚信号使用 Block Design 的自动连接
5. 按 **F6** 验证设计
6. 生成 bitstream 文件

#### 8.3.2 导出文件

在工程目录下新建 `ready_to_test` 文件夹，导出以下文件：
- `dma_tutorial.bit`（bitstream 文件）
- `dma_tutorial.hwh`（硬件描述文件）

将这两个文件复制到 Jupyter Notebook 工作目录的 `app/ready_to_test/` 目录下。

---

### 8.4 Python API 使用方法与代码示例

#### 8.4.1 加载 Overlay 并创建 DMA 对象

```python
from pynq import Overlay
dma_tutorial = Overlay("./ready_to_test/dma_tutorial.bit")

# 查看 overlay 中使用的 IP
dma_tutorial.ip_dict

# 创建 DMA 对象
import pynq.lib.dma
dma = dma_tutorial.axi_dma_0
```

#### 8.4.2 DMA 环回传输完整示例

```python
from pynq import allocate
import numpy as np

# 1. 分配缓冲区并写入测试数据
data_size = 100
input_buffer = allocate(shape=(data_size,), dtype=np.uint32)
for i in range(data_size):
    input_buffer[i] = i + 0xabcd0000

# 打印部分输入数据验证
for i in range(10):
    print(hex(input_buffer[i]))

# 2. 启动发送通道：DDR -> Stream (FIFO)
dma.sendchannel.transfer(input_buffer)
dma.sendchannel.wait()

# 3. 创建接收缓冲区
output_buffer = allocate(shape=(data_size,), dtype=np.uint32)

# 4. 启动接收通道：Stream (FIFO) -> DDR
dma.recvchannel.transfer(output_buffer)
dma.recvchannel.wait()

# 5. 验证接收数据
for i in range(10):
    print('0x' + format(output_buffer[i], '02x'))

# 6. 释放内存
del input_buffer, output_buffer
```

---

### 8.5 注意事项和避坑要点

1. **PL 中断必须经过 AXI Interrupt Controller**：PYNQ 要求所有 PL 中断经中断控制器连接到 ZYNQ IP 的 IRQ_F2P，直接连接会导致运行时报错
2. **TLAST 信号必须设置**：连接到 DMA 写通道的 stream IP 必须设置 AXI TLAST 信号，否则 DMA 永远不会完成事务；HLS IP 需在 C 代码中设置
3. **DMA 类仅支持简单模式**：不支持 Scatter Gather 模式
4. **默认最大事务大小为 16KB**（2^14），大事务需在 Vivado 中增大该配置值
5. **buffer 必须用 pynq.allocate() 分配**：不能用普通的 numpy 数组
6. **使用完 buffer 必须释放**：`del input_buffer, output_buffer`，避免内存泄漏
7. **sendchannel 和 recvchannel 的 wait()**：不使用中断时用 `wait()`，使用中断时用 `wait_async()`
8. **先 transfer 再 wait**：必须先调用 `transfer()` 启动传输，再调用 `wait()` 等待完成

---

## 第九章 PYNQ-helloworld 之图像缩放（page_0095 ~ page_0114）

### 9.1 核心概念和定义

**实验来源**：Xilinx PYNQ 演示例程 helloworld（Xilinx/PYNQ-HelloWorld on GitHub，PYNQ 镜像中已包含）。

**实验目的**：对比两种图像缩放方案的运算速度：
1. **PS 纯软件方案**：使用 Python Image Library (PIL) 通过软件算法实现图像缩放
2. **PL 硬件加速方案**：使用 Xilinx xfopencv library 在 FPGA 上实现硬件加速的图像缩放

**图像缩放（Image Scaling / Image Resizing）**：对数字图像的大小进行调整的过程。需要在处理效率与结果的平滑度（smoothness）和清晰度（sharpness）之间做权衡。

**本次实验采用双线性插值算法**。

#### 9.1.1 三种图像插值算法对比

| 算法 | 原理 | 优点 | 缺点 |
|------|------|------|------|
| **最近邻插值法**（Nearest Neighbor） | 待插值点取最近像素的灰度值 | 计算量最小，速度最快 | 放大时马赛克严重，缩小失真，灰度值不连续 |
| **双线性插值法**（Bilinear） | 两个方向分别进行一次线性插值，考虑周围 4 个邻点 | 计算量较小，图像连续性好，质量较高 | 放大时较模糊，细节损失，具有低通滤波器性质 |
| **双三次插值法**（Bicubic） | 用三次多项式近似 Sinc 函数，考虑周围 4x4=16 个像素点及灰度变化率 | 效果最佳，边缘最平滑，精度最高 | 计算量最大，算法最复杂 |

**双三次插值最优参数**：a = 0.5（大部分数字图像能量集中在低频部分）

---

### 9.2 关键技术要点

#### 9.2.1 PIL Image.resize() 方法

```python
Image.resize(size, resample=0, box=None)
```

| 参数 | 说明 |
|------|------|
| `size` | 缩放后大小（像素），2 元组 `(宽度, 高度)` |
| `resample` | 重采样滤波器：`PIL.Image.NEAREST`、`PIL.Image.BOX`、`PIL.Image.BILINEAR`、`PIL.Image.HAMMING`、`PIL.Image.BICUBIC`、`PIL.Image.LANCZOS`。省略或模式为 "1"/"P" 时默认 `NEAREST` |
| `box` | 可选 4 元组浮点数，指定源图像缩放区域，省略则缩放整图 |
| **返回值** | 缩放后的 `Image` 对象 |

#### 9.2.2 PL 硬件加速 -- Overlay 框图

**Overlay 文件**：`resizer.bit`（PYNQ 镜像中已包含，无需自行设计）

**数据通路**：
- **AXI_GP_0**：控制流通道，用于 Resize IP 和 DMA IP 的配置
- **AXI_HP_0**：数据流通道，DMA 通过 AXI_HP_0 将图像数据从 DRAM 传输给 Resize IP

**数据处理流程**：
1. 图像数据从 DRAM 经 DMA 通过 AXI_HP_0 传输
2. 传输过程中经过 **32bit 到 24bit 的转换**（Resize IP 处理 RGB888 格式，位宽 24bit）
3. Resize IP 使用双线性插值算法进行图像缩放
4. 处理完成后数据转换回 32bit，经 DMA 传输回 DRAM
5. PS 侧可查看处理后的图像

**Resize IP 规格**：
- 算法：双线性插值
- 下采样支持：缩小比例 >= 0.25
- 上采样支持：放大比例 <= 8

#### 9.2.3 Resize IP 寄存器

通过 overlay 的 IP 字典查看寄存器信息：

| 寄存器 | 地址偏移 | 说明 |
|--------|----------|------|
| 控制寄存器 | `0x00` | 写入 `0x81` 启动 IP |
| `src_rows` | `0x10` | 原始图像行数（高度） |
| `src_cols` | `0x18` | 原始图像列数（宽度） |
| `dst_rows` | `0x20` | 缩放后图像行数（高度） |
| `dst_cols` | `0x28` | 缩放后图像列数（宽度） |

通过 `register_map` 配置：

```python
resizer.register_map.src_rows = old_height
resizer.register_map.src_cols = old_width
resizer.register_map.dst_rows = new_height
resizer.register_map.dst_cols = new_width
```

#### 9.2.4 内存缓冲区分配（图像数据）

```python
from pynq import allocate
import numpy as np

in_buffer = allocate(shape=(old_height, old_width, 3), dtype=np.uint8, cacheable=1)
out_buffer = allocate(shape=(new_height, new_width, 3), dtype=np.uint8, cacheable=1)
```

**要点**：
- 图像数据为三维数组 `(height, width, 3)`，3 表示 RGB 三通道
- `dtype=np.uint8`：每通道 8 位
- `cacheable=1`：启用缓存，提升数据访问效率
- `in_buffer[:] = np.array(original_image)`：将图像数据从 Python 本地内存复制到共享物理内存（只有共享物理内存的数据才能传输到 PL）

---

### 9.3 Overlay 设计步骤

本章实验的 overlay 已包含在 PYNQ 镜像中（`resizer.bit`），**无需自行设计**。

Overlay 框架中包含：
- **DMA IP**（`axi_dma_0`）：通过 AXI_HP_0 进行数据传输
- **Resize IP**（`resize_accel_0`）：基于 xfopencv 的双线性插值图像缩放 IP
- 32bit <-> 24bit 数据位宽转换逻辑

---

### 9.4 Python API 使用方法与代码示例

#### 9.4.1 PS 纯软件图像缩放（resizer_ps.ipynb）

```python
# 导入库
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
%matplotlib inline

# 加载图片
image_path = "images/sahara.jpg"
original_image = Image.open(image_path)

# 显示原始图像
canvas = plt.gcf()
size = canvas.get_size_inches()
canvas.set_size_inches(size*2)
old_width, old_height = original_image.size
print("Image size: {}x{} pixels.".format(old_width, old_height))
_ = plt.imshow(original_image)

# 设置缩放因子并执行 resize
resize_factor = 2
new_width = int(old_width / resize_factor)
new_height = int(old_height / resize_factor)

resized_image = original_image.resize((new_width, new_height), Image.BILINEAR)

# 显示缩放后图像
print("Image size: {}x{} pixels.".format(new_width, new_height))
_ = plt.imshow(resized_image)

# 测试执行时间
%%timeit
resized_image = original_image.resize((new_width, new_height), Image.BILINEAR)
```

#### 9.4.2 PL 硬件加速图像缩放（resizer_pl.ipynb）

```python
# 导入库
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
%matplotlib inline
from pynq import allocate, Overlay

# 加载 Overlay
resize_design = Overlay("resizer.bit")

# 创建 DMA 和 Resize IP 对象
dma = resize_design.axi_dma_0
resizer = resize_design.resize_accel_0

# 加载图片
image_path = "images/sahara.jpg"
original_image = Image.open(image_path)
old_width, old_height = original_image.size

# 设置缩放因子
resize_factor = 2
new_width = int(old_width / resize_factor)
new_height = int(old_height / resize_factor)

# 分配内存缓冲区
in_buffer = allocate(shape=(old_height, old_width, 3), dtype=np.uint8, cacheable=1)
out_buffer = allocate(shape=(new_height, new_width, 3), dtype=np.uint8, cacheable=1)

# 将图像数据复制到共享物理内存
in_buffer[:] = np.array(original_image)

# 配置 Resize IP 寄存器
resizer.register_map.src_rows = old_height
resizer.register_map.src_cols = old_width
resizer.register_map.dst_rows = new_height
resizer.register_map.dst_cols = new_width

# 定义 run_kernel 函数
def run_kernel():
    dma.sendchannel.transfer(in_buffer)
    dma.recvchannel.transfer(out_buffer)
    resizer.write(0x00, 0x81)  # 启动 Resize IP
    dma.sendchannel.wait()
    dma.recvchannel.wait()

# 执行图像缩放
run_kernel()
resized_image = Image.fromarray(out_buffer)

# 显示结果
print("Image size: {}x{} pixels.".format(new_width, new_height))
plt.figure(figsize=(12, 10))
_ = plt.imshow(resized_image)

# 测试执行时间
%%timeit
run_kernel()
resized_image = Image.fromarray(out_buffer)

# 释放内存
del in_buffer
del out_buffer
```

---

### 9.5 性能对比数据

| 方案 | 测试图像 | 缩放操作 | 执行时间 | 性能提升 |
|------|----------|----------|----------|----------|
| **PS 纯软件**（PIL Image.resize + BILINEAR） | 3840x2160 -> 1920x1080 | 双线性插值 | **427ms**（约 994ms 含数据转换） | 基准 |
| **PL 硬件加速**（Resize IP + DMA） | 3840x2160 -> 1920x1080 | 双线性插值 | **60.6ms**（约 191ms 含数据转换） | **约 6 倍** |

> 性能提升计算公式：`(1/191 - 1/994) / (1/994) * 100%`，约等于 6 倍。
>
> 注：不同实验环境测量值略有不同。

---

### 9.6 注意事项和避坑要点

1. **TLAST 信号**：使用 HLS 生成 IP 时，必须在 C 代码中设置 TLAST 信号，否则 DMA 不会完成事务
2. **共享物理内存**：图像数据必须通过 `in_buffer[:] = np.array(original_image)` 复制到共享物理内存，只有共享物理内存的数据才能通过 DMA 传输到 PL
3. **cacheable=1**：分配图像缓冲区时建议启用缓存，提升数据访问效率
4. **Resize IP 启动命令**：`resizer.write(0x00, 0x81)` -- 向偏移 0x00 写入 0x81 启动 IP
5. **数据位宽转换**：DMA 传输 32bit 数据，Resize IP 处理 24bit（RGB888），overlay 中已包含 32bit <-> 24bit 转换逻辑
6. **释放内存缓冲区**：实验结束后必须 `del in_buffer, out_buffer` 释放内存
7. **Resize IP 缩放比例限制**：下采样 >= 0.25，上采样 <= 8
8. **PIL vs OpenCV**：本实验使用 PIL 库而非 OpenCV 库
9. **run_kernel 封装**：将 DMA 传输和 IP 启动封装为函数便于多次调用和性能测试
10. **%%timeit**：Jupyter Notebook 的 magic command，用于测量代码执行时间
