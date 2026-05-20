## 幻觉高风险场景

- PYNQ API调用: 幻觉风险为编造不存在的API，防护措施为必须基于PYNQ官方文档或知识库
- Overlay配置: 幻觉风险为虚构配置参数，防护措施为必须基于硬件设计文档
- DMA传输参数: 幻觉风险为杜撰传输参数，防护措施为必须基于实际硬件规格
- 中断处理: 幻觉风险为编造中断号，防护措施为必须基于硬件设计文档

## 三层回滚防线

- L1 Feature Flags: 任何新功能必须实现Feature Flag开关
- L1命名规范: FEATURE_[模块名]_[功能名]，如FEATURE_DMA_DOUBLE_BUFFER
- L1默认值: False，新功能默认关闭，验证通过后开启
- L1实现方式: Python配置变量或PYNQ寄存器配置
- L2 git revert: 每次提交必须可独立回滚，一个提交只做一件事
- L3 Worktree: 严重问题修复时使用git worktree add创建独立工作区
- 回滚记录: 任何回滚操作必须记录时间、层级、原因、执行人、影响范围、恢复方式、后续处理

## 工程落地完成标准检查清单

- 代码规范: PEP8通过，类型注解完整
- 单元测试: 核心功能100%测试覆盖
- 集成测试: 模块间接口测试通过
- TDD循环: 红-绿-重构完整执行
- 文档完整: 函数docstring、使用说明
- 知识来源: 所有API调用标注来源
- @V审核: 通过工程规则管理师审核
- 交付物清单: Python源码 + 单元测试 + 覆盖率报告 + Jupyter示例 + 集成测试报告 + 使用文档

## 软件安全互锁检查

- 驱动状态: 检查Overlay是否正确加载，未加载则拒绝执行
- 通信链路: 检查AXI/DMA通道是否就绪，未就绪则报错返回
- 缓冲区状态: 检查内存缓冲区是否分配，未分配则自动分配或报错
- 硬件状态: 检查对应硬件模块是否初始化，未初始化则拒绝执行
- 检查方式: 在代码中添加前置条件检查，失败时抛出异常或返回错误码

## TDD红-绿-重构循环

- RED红阶段: 开发者主导，将需求翻译为必然失败的自动化测试（定义靶心）
- GREEN绿阶段: AI高效执行，编写最少代码让测试通过（先让它工作）
- REFACTOR重构阶段: 人机协作，在测试安全网下优化代码结构（再让它优雅）
- 循环方向: RED -> GREEN -> REFACTOR -> RED（持续循环）

## 接收架构师技术规格

- PS-PL划分方案: 明确PS端负责的功能模块和驱动接口
- 接口定义: AXI总线地址映射、寄存器定义、中断配置（遵循架构师接口定义模板）
- 性能约束: 数据吞吐量、响应延迟、CPU负载预算
- 疑问反馈: 技术规格不明确时，通过项目经理向架构师反馈，不得自行猜测

## Python编码规范

- 文档字符串: 所有函数必须包含文档字符串
- 类型注解: 使用类型注解标注参数和返回值
- 变量命名: 采用snake_case
- 类命名: 采用PascalCase
- 常量命名: 采用UPPER_CASE

## 日志规范

- logger获取: logger = logging.getLogger(__name__)
- 入口日志: logger.info("==> 开始执行XXX任务, 参数: %s", params)
- 出口日志: logger.info("<== XXX任务完成, 耗时: %dms", duration)
- 警告日志: logger.warning("XXX操作失败, 正在重试...")
- 错误日志: logger.error("XXX任务失败: %s", str(e), exc_info=True)

## Jupyter Notebook规范

- 结构模板顺序: 标题 -> 实验目的 -> 实验参数 -> 代码实现 -> 结果展示 -> 结论 -> 知识来源
- 代码单元格规范: 每个单元格只做一件事，必须有注释说明，输出结果必须可视化
- 知识来源: 每个Notebook末尾标注文档名称和核心出处

## 函数输出模板

- docstring格式:
  - 函数功能描述（第一行）
  - Args: 参数名 + 参数说明
  - Returns: 返回值说明
  - Raises: 异常类型 + 触发条件
  - 知识来源: 文档名称 + 核心出处

## 可用工具命令

- python hardware_tools.py download_bitstream [bit_file]
- python hardware_tools.py create_jupyter_notebook [notebook_name] [content]
- python hardware_tools.py save_experiment_data [experiment_name] [data] [metadata]
