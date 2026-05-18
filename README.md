# NV色心实验系统（NCS_project）

> **项目代号**：NCS（NV Center Sensing）
> **核心平台**：ZYNQ7020 + PYNQ
> **业务领域**：金刚石NV色心量子精密测量
> **GitHub仓库**：https://github.com/ALLANCE1994/NCS_project.git

---

## 项目概况

基于 ZYNQ7020 SoC 平台的 NV 色心量子传感系统，采用 10 大 AI 智能体协同驱动，内置 RAG 溯源防幻觉体系，实现从硬件设计、软件开发到实验验证的全流程 AI 辅助工程。

| 属性 | 说明 |
|------|------|
| 硬件平台 | Xilinx ZYNQ7020（PL 端 FPGA + PS 端 ARM） |
| 软件框架 | PYNQ + Python + Jupyter Notebook |
| 智能体团队 | 10 大 AI 智能体（Trae Solo MTC） |
| 知识库体系 | 通用基础库 + 项目专业库（双层） |
| 防幻觉机制 | RAG 溯源 + 全局终审 + 幻觉台账 |
| 文档处理 | 全格式双层提炼（粗加工 + 精提炼） |

---

## 目录结构

```
NCS_project/
├── .github/                              # GitHub 仓库绑定配置
├── .trae/agents/                         # 10 大智能体配置文件
│
├── 01_knowledge_base/                    # 知识库
│   ├── base_lib/                         #   通用基础知识库（11 个角色目录）
│   │   ├── ai_engineer_base/             #     AI 使用工程师基础
│   │   ├── architect_base/               #     架构师基础
│   │   ├── boss_base/                    #     老板基础
│   │   ├── doc_engineer_base/            #     文档工程师基础
│   │   ├── doc_preprocess_base/          #     文档预处理基础
│   │   ├── hallucination_prevention_base/#     防幻觉避坑手册
│   │   ├── hw_engineer_base/             #     硬件工程师基础
│   │   ├── pm_base/                      #     项目经理基础
│   │   ├── quantum_scientist_base/       #     量子科学家基础
│   │   ├── rule_manager_base/            #     规则管理师基础
│   │   └── sw_engineer_base/             #     软件工程师基础（含 PYNQ 开发指南）
│   ├── customer_docs/                    #   客户提供的原始文档（待投喂）
│   ├── engineering_rules/                #   工程规范与标准（待建设）
│   ├── experiment_docs/                  #   实验方案与数据文档（待建设）
│   ├── hallucination_records/            #   AI 幻觉错误汇总台账
│   ├── project_assets/                   #   项目公共资源文件（图片/模板等）
│   ├── project_management/               #   项目管理方法论沉淀（待建设）
│   ├── project_memory/                   #   项目记忆（启动骨架/接续文案/速查表/模式手册）
│   ├── scientific_principles/            #   科学原理与公式推导（待建设）
│   ├── technical_specs/                  #   技术规格说明书（待建设）
│   └── templates/                        #   模板（GitHub 同步/无幻觉提问句式/Git Push 指南）
│
├── 02_designs/                           # 设计文档（待建设）
│
├── 03_code/                              # 代码框架
│   ├── 01_vhdl_modules/                  #   VHDL 硬件模块（待开发）
│   ├── 02_python_drivers/                #   Python/PYNQ 驱动
│   ├── 03_jupyter_notebooks/             #   Jupyter 实验脚本（待开发）
│   ├── README.md                         #   代码框架说明
│   └── agent_config.yaml                 #   智能体配置参数
│
├── 04_docs/                              # 技术文档
│   ├── 01_specs/                         #   规格说明书
│   ├── 02_reports/                       #   汇总报告
│   ├── 03_manuals/                       #   使用手册
│   ├── 04_progress/                      #   进度记录
│   └── 05_thesis_materials/              #   论文素材库（方法论/架构/实验/实证/综合）
│
├── 05_rules/                             # 流程规范
│   ├── 01_token_efficiency_rules.md      #   Token 节流规则
│   ├── 02_rule_layer_management.md       #   核心常驻 + 非核心自动启停
│   ├── 03_document_refinement_workflow.md#   双层文档提炼流程
│   ├── 04_hallucination_prevention_rules.md # 防幻觉规则
│   └── 05_project_operation_standards.md #   项目运营标准
│
├── 06_experiment_data/                   # 实验数据（待建设）
├── 07_pynq_notebooks/                    # PYNQ Jupyter 笔记本（实验级，完整实验流程/数据分析）

> **Note**：`03_code/03_jupyter_notebooks/` 存放驱动测试、模块验证等代码级 Notebook；`07_pynq_notebooks/` 存放完整实验流程、数据分析等实验级 Notebook。
└── 08_vivado_projects/                   # Vivado 工程文件（待建设）
```

---

## 命名规范

| 规则 | 说明 |
|------|------|
| 目录名 | 英文 snake_case，顶层目录带 `NN_` 编号前缀 |
| 文件名 | 英文 snake_case，带 `NN_` 编号前缀 |
| 文档日期 | `YYYYMMDD_` 格式前缀（04_docs/ 下） |
| 禁止事项 | 禁止中文文件名、禁止空格、禁止特殊字符 |

---

## 智能体团队

| 符号 | 智能体 | 职责 |
|:----:|--------|------|
| @C | 老板 | 最高决策，需求脱水，审批立项 |
| @M | 项目经理 | 任务拆解，进度管理，结果汇总 |
| @P | 架构师 | 系统架构设计，技术选型，MVP 裁定 |
| @H | 硬件工程师 | VHDL 编写，IP 核配置，Vivado 工程 |
| @S | 软件工程师 | PYNQ 驱动，Jupyter 界面，数据处理 |
| @Q | 量子科学家 | NV 色心原理，实验方案，参数计算 |
| @V | 工程规则管理师 | 合规审核，防幻觉终审，质量管控 |
| @D | 文档预处理工程师 | 全格式文件解析，粗加工，领域分发 |
| @E | 文档工程师 | 技术文档撰写，实验报告，归档管理 |
| @A | AI 使用工程师 | 全局调度枢纽 + 永久项目记忆库 |

> @G（GitHub 同步）由 @A 兼任。

---

## 核心规则

### 常驻规则（永久生效）

| 规则 | 说明 |
|------|------|
| **RAG 溯源** | 技术输出必须标注知识来源，无来源则停止作答 |
| **防幻觉** | 禁止编造参数、虚构引脚、杜撰原理，违者驳回 |
| **无伤节流** | 剔除客套冗余，保留专业干货，不压缩思考深度 |
| **调度本位** | @A 严禁越权实操技术工作，必须转派专职智能体 |

### 非核心规则（自动启停）

| 规则 | 默认状态 | 启用方式 |
|------|----------|----------|
| 文档处理流程 | 休眠 | 识别到文档类任务自动启用，完成后自动休眠 |
| GitHub 同步流程 | 休眠 | 识别到同步类任务自动启用，完成后自动休眠 |

---

## 快速上手

### 启动项目

在 Trae Solo MTC 中输入：

```
启动NV项目
```

系统将输出轻量化项目骨架（核心规则 + 快捷口令），进入工作状态。

### 下达任务

```bash
# 精准指派
@H 设计脉冲发生模块，频率 100kHz-10MHz，输出 AXI-Lite 接口
@Q 设计 ODMR 实验，微波扫频 2.8-3.0GHz，步进 1MHz

# 全局统筹（由 @A 自动分类转派）
帮我梳理一下系统整体架构
```

### 常用口令

| 口令 | 功能 |
|------|------|
| `启动NV项目` | 加载项目骨架，进入工作状态 |
| `记录本次进度` | 汇总本次工作内容 + 待同步文件提示 |
| `同步到GitHub` | 生成同步预览（文件清单 + 提交说明） |
| `查看规则状态` | 显示各规则层激活状态 |

---

## 防幻觉体系

```
智能体前端溯源（RAG 检索 → 有据输出 / 停止作答）
        │
        ▼
@V 工程规则管理师全局终审（来源真实性 + 参数准确性 + 逻辑一致性）
        │
        ▼
幻觉台账记录（错误分类 + 正确依据 + 修正建议）
```

---

## 更新日志

| 日期 | 内容 |
|------|------|
| 2026-05-16 | 项目初始化：10 智能体配置 + 知识库 + 规则体系 + 框架搭建 |
| 2026-05-16 | 框架优化：目录重组 + 文档归类 + 规则分层休眠 + 全员自测通过 |
| 2026-05-16 | 架构规范化：统一顶层编号 01-08 + 全英文命名 + 空目录占位 + README 同步 |
| 2026-05-17 | 知识库完善：PYNQ 开发指南入库 + 论文素材库建立 + Git Push 指南 + 文档同步闭环管理规则 |

---

**维护责任**：AI 使用工程师（@A）
**项目所有者**：[ALLANCE1994](https://github.com/ALLANCE1994)
