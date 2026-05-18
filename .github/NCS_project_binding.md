# GitHub仓库绑定配置

> **仓库地址**：`https://github.com/ALLANCE1994/NCS_project.git`
> **绑定日期**：2026-05-16
> **绑定状态**：✅ 已绑定

---

## 一、仓库信息

| 属性 | 值 |
|------|-----|
| **仓库名称** | NCS_project |
| **仓库地址** | https://github.com/ALLANCE1994/NCS_project.git |
| **所有者** | ALLANCE1994 |
| **项目代号** | NV色心实验系统 |
| **绑定智能体** | AI使用工程师（项目管家） |

---

## 二、仓库目录结构

```
NCS_project/
├── README.md                          # 项目总览说明
├── .gitignore                         # Git忽略规则
│
├── 01_knowledge_base/                 # 知识库文档
│   ├── 01_base_lib/                   # 通用基础知识库
│   │   ├── doc_preprocess_base/
│   │   ├── ai_engineer_base/
│   │   ├── boss_base/
│   │   ├── pm_base/
│   │   ├── rule_manager_base/
│   │   ├── architect_base/
│   │   ├── quantum_scientist_base/
│   │   ├── hw_engineer_base/
│   │   ├── sw_engineer_base/
│   │   ├── doc_engineer_base/
│   │   └── hallucination_prevention/
│   │
│   ├── 02_professional_lib/           # 项目专业知识库（待投喂）
│   │   ├── nv_physics/
│   │   ├── fpga_hardware/
│   │   └── pynq_software/
│   │
│   ├── 03_hallucination_records/      # 幻觉记录
│   └── 04_templates/                  # 模板文档
│
├── 02_agent_configs/                  # 智能体配置文件
│   ├── boss.md
│   ├── project_manager.md
│   ├── engineering_rule_manager.md
│   ├── architect.md
│   ├── quantum_scientist.md
│   ├── hardware_engineer.md
│   ├── software_engineer.md
│   ├── ai_usage_engineer.md
│   ├── document_preprocessor.md
│   └── document_engineer.md
│
├── 03_designs/                        # 设计方案
│   ├── 01_system_architecture/        # 系统架构设计
│   ├── 02_hardware_design/            # 硬件设计方案
│   ├── 03_software_design/            # 软件设计方案
│   └── 04_experiment_design/          # 实验设计方案
│
├── 04_code_frameworks/                # 代码框架
│   ├── 01_vhdl_modules/               # VHDL模块代码
│   ├── 02_python_drivers/             # Python驱动代码
│   └── 03_jupyter_notebooks/          # Jupyter实验脚本
│
├── 05_documents/                      # 技术文档
│   ├── 01_specs/                      # 规格说明书
│   ├── 02_reports/                    # 实验报告
│   ├── 03_manuals/                    # 用户手册
│   └── 04_progress/                   # 进度记录
│
├── 06_workflows/                      # 流程规范
│   ├── document_refinement_workflow.md
│   ├── hallucination_prevention_rules.md
│   └── project_operation_standards.md
│
└── 07_project_memory/                 # 项目记忆
    ├── project_continuation_guide.md
    └── progress_records/
```

---

## 三、产出物归类规则

### 3.1 自动归类映射表

| 产出物类型 | 本地路径 | 仓库目标路径 | 命名规范 |
|-----------|----------|-------------|----------|
| **基础知识库** | `knowledge_base/base_lib/` | `01_knowledge_base/01_base_lib/` | 保留原结构 |
| **专业知识库** | `knowledge_base/professional_lib/` | `01_knowledge_base/02_professional_lib/` | 保留原结构 |
| **幻觉记录** | `knowledge_base/hallucination_records/` | `01_knowledge_base/03_hallucination_records/` | 保留原结构 |
| **模板文档** | `knowledge_base/templates/` | `01_knowledge_base/04_templates/` | 保留原结构 |
| **智能体配置** | `.trae/agents/` | `02_agent_configs/` | 扁平化存储 |
| **系统架构设计** | `designs/architecture/` | `03_designs/01_system_architecture/` | `YYYYMMDD_架构名称.md` |
| **硬件设计** | `designs/hardware/` | `03_designs/02_hardware_design/` | `YYYYMMDD_模块名称.md` |
| **软件设计** | `designs/software/` | `03_designs/03_software_design/` | `YYYYMMDD_模块名称.md` |
| **实验设计** | `designs/experiment/` | `03_designs/04_experiment_design/` | `YYYYMMDD_实验名称.md` |
| **VHDL代码** | `code/vhdl/` | `04_code_frameworks/01_vhdl_modules/` | `模块名称.vhd` |
| **Python驱动** | `code/python/` | `04_code_frameworks/02_python_drivers/` | `驱动名称.py` |
| **Jupyter脚本** | `code/notebooks/` | `04_code_frameworks/03_jupyter_notebooks/` | `实验名称.ipynb` |
| **规格说明书** | `docs/specs/` | `05_documents/01_specs/` | `YYYYMMDD_文档名称.md` |
| **实验报告** | `docs/reports/` | `05_documents/02_reports/` | `YYYYMMDD_报告名称.md` |
| **用户手册** | `docs/manuals/` | `05_documents/03_manuals/` | `YYYYMMDD_手册名称.md` |
| **进度记录** | `docs/progress/` | `05_documents/04_progress/` | `YYYYMMDD_进度记录.md` |
| **流程规范** | `workflows/` | `06_workflows/` | 保留原文件名 |
| **项目记忆** | `knowledge_base/project_memory/` | `07_project_memory/` | 保留原结构 |

### 3.2 文件命名规范

| 类型 | 命名格式 | 示例 |
|------|----------|------|
| 设计文档 | `YYYYMMDD_描述.md` | `20260516_ZYNQ系统架构设计.md` |
| 代码文件 | `模块/功能名称.扩展名` | `pulse_generator.vhd` |
| 实验报告 | `YYYYMMDD_实验名称_报告.md` | `20260516_ODMR实验报告.md` |
| 进度记录 | `YYYYMMDD_进度记录.md` | `20260516_进度记录.md` |
| 技术文档 | `YYYYMMDD_文档名称.md` | `20260516_PYNQ驱动开发指南.md` |

---

## 四、同步规则

### 4.1 同步触发条件

- 客户下达指令：`同步到GitHub` / `同步到仓库` / `提交到GitHub`
- 阶段性工作完成（由客户确认后）

### 4.2 同步前准备（AI执行）

1. **扫描本地产出物**：遍历所有指定目录
2. **生成文件清单**：列出所有待同步文件
3. **检查命名规范**：确保符合命名规则
4. **生成分类映射**：确定每个文件的目标路径
5. **生成提交说明**：按规范生成commit message

### 4.3 同步确认流程

```
客户下达同步指令
    │
    ▼
AI整理文件清单 + 生成提交说明
    │
    ▼
输出同步预览（文件清单 + 提交说明）
    │
    ▼
客户一键确认
    │
    ▼
客户本地执行Git命令（或AI指导执行）
    │
    ▼
同步完成
```

### 4.4 不执行的操作

- ❌ 不执行 `git add`
- ❌ 不执行 `git commit`
- ❌ 不执行 `git push`
- ❌ 不修改 `.git/config`

所有Git操作由客户一键确认后自行执行，或AI提供指导命令。

---

## 五、与项目管家联动

### 5.1 启动口令联动

输入 `启动NV项目` 时，自动包含GitHub仓库信息：

```
✅ NV色心项目已启动

【GitHub仓库】
- 仓库地址：https://github.com/ALLANCE1994/NCS_project.git
- 绑定状态：已绑定
- 上次同步：YYYY-MM-DD HH:MM（如有）

[接续文案全文...]
```

### 5.2 进度记录联动

输入 `记录本次进度` 时，自动包含待同步文件提示：

```
📋 本次进度记录

[常规进度内容...]

【待同步文件】
- 新增：X个文件
- 修改：X个文件
- 提示：输入"同步到GitHub"可整理提交

记录时间：YYYY-MM-DD HH:MM
```

### 5.3 新增同步口令

| 口令 | 功能 |
|------|------|
| `同步到GitHub` | 整理文件清单，生成提交说明，输出同步预览 |
| `查看仓库状态` | 显示本地与仓库的文件差异对比 |

---

## 六、README模板

仓库根目录 `README.md` 自动生成/更新内容：

```markdown
# NV色心实验系统（NCS_project）

> **项目代号**：NCS（NV Center Sensing）
> **核心平台**：ZYNQ7020 + PYNQ
> **业务领域**：金刚石NV色心量子精密测量

---

## 项目概况

| 属性 | 说明 |
|------|------|
| 智能体团队 | 10大AI智能体 |
| 知识库 | 通用基础库 + 项目专业库 |
| 防幻觉体系 | 双层RAG溯源 + 人工终审 |
| 文档处理 | 全格式双层提炼 |

---

## 目录说明

| 目录 | 内容 |
|------|------|
| `01_knowledge_base/` | 知识库文档（基础+专业+记录+模板） |
| `02_agent_configs/` | 智能体配置文件 |
| `03_designs/` | 设计方案（架构/硬件/软件/实验） |
| `04_code_frameworks/` | 代码框架（VHDL/Python/Jupyter） |
| `05_documents/` | 技术文档（规格/报告/手册/进度） |
| `06_workflows/` | 流程规范 |
| `07_project_memory/` | 项目记忆 |

---

## 最近更新

- YYYY-MM-DD：[更新内容简述]

---

## 项目管家

本项目使用AI使用工程师作为永久项目记忆库：
- 启动口令：`启动NV项目`
- 记录口令：`记录本次进度`
- 同步口令：`同步到GitHub`
```

---

## 七、配置验证

- [x] 仓库地址已绑定
- [x] 目录结构已定义
- [x] 归类规则已建立
- [x] 命名规范已制定
- [x] 同步流程已设计
- [x] 项目管家联动已配置

---

**配置完成时间**：2026-05-16
**维护责任人**：AI使用工程师（项目管家）
