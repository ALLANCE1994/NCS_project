# NV色心项目全套工程接续文案

> **文档编号**：NV-FPGA-MEMORY-001
> **版本**：V1.0
> **创建日期**：2026-05-16
> **维护人**：AI使用工程师
> **用途**：启动NV项目口令的标准输出内容，一键复原全部项目上下文

---

## ✅ NV色心项目已启动

---

## 一、项目概况

| 项目 | 内容 |
|------|------|
| **项目名称** | NV色心实验系统（FPGA+量子传感） |
| **核心平台** | ZYNQ7020 SoC（ARM PS + FPGA PL） |
| **开发框架** | PYNQ（Python + Jupyter） |
| **业务核心** | 金刚石NV色心量子精密测量 |
| **智能体团队** | 10大智能体 |
| **GitHub仓库** | https://github.com/ALLANCE1994/NCS_project.git |
| **当前阶段** | 基础框架搭建完成，等待专业PDF资料投喂 |

---

## 二、GitHub仓库绑定

| 属性 | 值 |
|------|-----|
| **仓库名称** | NCS_project |
| **仓库地址** | https://github.com/ALLANCE1994/NCS_project.git |
| **绑定状态** | ✅ 已绑定 |
| **绑定日期** | 2026-05-16 |
| **项目管家** | AI使用工程师 |

**仓库目录结构**：
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
│   │   └── sw_engineer_base/             #     软件工程师基础
│   ├── customer_docs/                    #   客户提供的原始文档（待投喂）
│   ├── engineering_rules/                #   工程规范与标准（待建设）
│   ├── experiment_docs/                  #   实验方案与数据文档（待建设）
│   ├── hallucination_records/            #   AI 幻觉错误汇总台账
│   ├── project_assets/                   #   项目公共资源文件（图片/模板等）
│   ├── project_management/               #   项目管理方法论沉淀（待建设）
│   ├── project_memory/                   #   项目记忆
│   │   ├── 01_full_project_context.md    #     全套工程接续文案
│   │   ├── 02_project_startup_skeleton.md#     极简启动骨架
│   │   ├── 03_agent_quick_reference.md   #     智能体快捷调用速查表
│   │   └── 04_mtc_mode_decision_manual.md#     MTC 模式决策手册
│   ├── scientific_principles/            #   科学原理与公式推导（待建设）
│   ├── technical_specs/                  #   技术规格说明书（待建设）
│   └── templates/                        #   模板（GitHub 同步/无幻觉提问句式）
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
│   └── 04_progress/                      #   进度记录
│
├── 05_rules/                             # 流程规范
│   ├── 01_token_efficiency_rules.md      #   Token 节流规则
│   ├── 02_rule_layer_management.md       #   核心常驻 + 非核心自动启停
│   ├── 03_document_refinement_workflow.md#   双层文档提炼流程
│   ├── 04_hallucination_prevention_rules.md # 防幻觉规则
│   └── 05_project_operation_standards.md #   项目运营标准
│
├── 06_experiment_data/                   # 实验数据（待建设）
├── 07_pynq_notebooks/                    # PYNQ Jupyter 笔记本（待建设）
└── 08_vivado_projects/                   # Vivado 工程文件（待建设）
```

**同步口令**：
- `同步到GitHub` — 整理文件清单，生成提交说明，输出同步预览
- `查看仓库状态` — 显示本地与仓库的文件差异对比

---

## 三、智能体团队阵容

| 序号 | 角色 | 配置文件 | 核心职责 |
|------|------|----------|----------|
| 1 | 老板 | `.trae/agents/boss.md` | 最高决策层，需求审计，项目DNA提取 |
| 2 | 项目经理 | `.trae/agents/project_manager.md` | 总执行负责人，任务拆解调度，VibeCoding三阶段管理 |
| 3 | 工程规则管理师 | `.trae/agents/engineering_rule_manager.md` | 全局防幻觉终审核验，质量合规审核，一票否决权 |
| 4 | 架构师 | `.trae/agents/architect.md` | 系统架构设计，MVP裁定，极简主义 |
| 5 | 量子科学家 | `.trae/agents/quantum_scientist.md` | NV色心物理原理，实验方案设计，参数计算 |
| 6 | 硬件工程师 | `.trae/agents/hardware_engineer.md` | PL端VHDL开发，IP核配置，Vivado工程 |
| 7 | 软件工程师 | `.trae/agents/software_engineer.md` | PS端PYNQ驱动，Jupyter界面，数据处理 |
| 8 | AI使用工程师 | `.trae/agents/ai_usage_engineer.md` | 指令优化，防幻觉预警，**永久项目记忆库** |
| 9 | 文档预处理工程师 | `.trae/agents/document_preprocessor.md` | 全格式文件解析，粗加工，领域分发 |
| 10 | 文档工程师 | `.trae/agents/document_engineer.md` | 技术文档撰写，实验报告，台账归档 |

---

## 三、核心运行规则

### 3.0 指令执行前置校验（第0条，V3.0新增，最高优先级）

> 任何指令执行前必须先完成规则校验，详见 `05_rules/02_rule_layer_management.md` V3.0

```
收到用户指令 → 【第0步】规则前置校验 → 匹配流程/规则 → 按规则执行
```

**校验输出格式**（每次执行前必须输出）：
```
【规则校验】
- 触发流程：[流程名称/无]
- 参与智能体：[@X/@Y/...]
- 执行顺序：[步骤1→步骤2→...]
- 输出格式：[格式说明]
```

### 3.1 AI项目方法论

| 方法论 | 适用角色 | 核心要点 |
|--------|----------|----------|
| **VibeCoding三阶段** | 项目经理 | 战略定型→工程定型→工程落地 |
| **Rules驱动开发** | 工程规则管理师 | 编码习惯+项目结构+安全红线+交付自检 |
| **TDD红绿重构** | 软件工程师 | 先写测试→最少代码通过→重构优化 |
| **MVP裁定四步法** | 架构师 | 价值交换→最短链路→最小动作→反向裁剪 |
| **小步快跑四控制** | 硬件工程师 | 改动边界+目标状态+验收方式+禁止顺手优化 |

### 3.2 三套极简固定口令

| 口令 | 功能 |
|------|------|
| **启动NV项目** | 一键复原全部项目上下文（智能体、流程、防幻觉、GitHub） |
| **记录本次进度** | 精简总结本次工作、进度、计划，含待同步文件提示 |
| **同步到GitHub** | 整理文件清单，生成提交说明，输出同步预览 |

### 3.3 RAG溯源防幻觉铁律

**全员强制遵守**：

1. 输出硬核技术内容前，**必须优先检索自身专属私有向量知识库**
2. 检索到匹配资料 → 严格依托原文输出，**必须标注知识来源**
3. 未检索到有效内容 → **立刻停止作答**，明确告知缺资料，绝不编造
4. 非技术类内容 → 无需强制溯源，正常输出
5. **严禁跨知识库挪用**无关领域知识强行套用

**知识来源标注格式**：
```
【知识来源】
- 文档名称：《XXX》
- 核心出处：第X章/第X节
- 关键内容：[原文核心描述]
```

### 3.4 双层防幻觉体系

```
用户下达指令
    │
    ▼
【第一层】AI使用工程师 → 指令精准化 + 幻觉预警
    │
    ▼
【第二层】专业智能体 → RAG溯源检索 + 依托原文输出
    │
    ▼
【第三层】工程规则管理师 → 终审核验 + 台账记录
    │
    ▼
通过 → 交付 / 驳回 → 修改
```

---

## 四、文档处理流程

### 4.1 双层文档提炼流程

```
客户上传任意格式文件
    │
    ▼
【第一层】文档预处理工程师（粗加工）
  - 全格式支持：PDF/TXT/MD/Word/Excel/PPT/图片/源码/压缩包
  - 提取内容 → 清洗格式 → 统一转为Markdown初稿
  - 识别领域 → 精准分发
    │
    ▼
【第二层】对应专业智能体（精加工）
  - 深度专业提炼 → 结合项目落地 → 输出干货文档
    │
    ▼
工程规则管理师审核
    │
    ▼
本地归档存储（默认不自动入库）
    │
    ▼
客户手动确认 → 批量投喂知识库
```

### 4.2 领域分发规则

| 文档类型 | 识别关键词 | 分发对象 |
|----------|-----------|----------|
| 量子物理 | NV、色心、ODMR、自旋、金刚石、微波 | @量子科学家 |
| 硬件设计 | FPGA、ZYNQ、Vivado、VHDL、时序 | @硬件工程师 |
| 软件开发 | PYNQ、Jupyter、Python、Overlay | @软件工程师 |
| 系统架构 | 架构、系统方案、模块划分 | @架构师 |
| 工程规范 | 规范、流程、质量、审核 | @工程规则管理师 |
| AI使用 | AI、MTC、智能体、指令 | @AI使用工程师 |

### 4.3 全格式支持

| 格式 | 扩展名 | 解析工具 |
|------|--------|----------|
| PDF | `.pdf` | pymupdf |
| Word | `.doc`/`.docx` | python-docx |
| Excel | `.xls`/`.xlsx` | openpyxl |
| PPT | `.ppt`/`.pptx` | python-pptx |
| 图片 | `.png`/`.jpg`/`.jpeg`/`.bmp`/`.tiff` | OCR |
| 源码 | `.vhd`/`.py`/`.c`/`.tcl`等 | 直接读取 |
| 压缩包 | `.zip`/`.tar`/`.tar.gz`/`.rar` | zipfile/tarfile |
| TXT | `.txt` | 直接读取 |
| MD | `.md` | 直接读取 |

---

## 五、知识库架构

### 5.1 目录结构

```
01_knowledge_base/
├── base_lib/                        # 通用基础知识库（已完成）
│   ├── doc_preprocess_base/         # 文档预处理工程师
│   ├── ai_engineer_base/            # AI使用工程师
│   ├── boss_base/                   # 老板
│   ├── pm_base/                     # 项目经理
│   ├── rule_manager_base/           # 工程规则管理师
│   ├── architect_base/              # 架构师
│   ├── quantum_scientist_base/      # 量子科学家
│   ├── hw_engineer_base/            # 硬件工程师
│   ├── sw_engineer_base/            # 软件工程师
│   ├── doc_engineer_base/           # 文档工程师
│   └── hallucination_prevention_base/    # 防幻觉避坑手册
│
├── professional_lib/                # 项目专业知识库（待投喂）
│   ├── nv_physics/                  # NV色心物理
│   ├── fpga_hardware/               # FPGA硬件
│   ├── pynq_software/               # PYNQ软件
│   └── ...
│
├── hallucination_records/           # 幻觉记录台账
├── templates/                       # 模板文档
│   └── 无幻觉提问句式模板.md
└── project_memory/                  # 项目记忆
    └── 01_full_project_context.md
```

### 5.2 知识库分层

| 层级 | 内容 | 权限 |
|------|------|------|
| 通用基础知识库 | 岗位工作思维、执行规范 | 全员可查阅，对应角色优先学习 |
| 项目专业知识库 | 唯一技术依据来源 | 仅对应专业智能体可检索 |
| 幻觉记录台账 | 幻觉案例、成因、修正 | 工程规则管理师维护，全员可查阅 |

---

## 六、防幻觉文档体系

| 文档 | 路径 | 用途 |
|------|------|------|
| 项目AI幻觉错误汇总台账 | `01_01_knowledge_base/hallucination_records/` | 记录幻觉案例 |
| 无幻觉提问句式模板 | `01_01_knowledge_base/templates/` | 指导正确提问 |
| AI幻觉避坑手册 | `01_01_knowledge_base/base_lib/hallucination_prevention_base/` | 全员学习参考 |

---

## 七、全局执行约束

1. **无实体硬件调试**：所有规则仅作用于方案设计、代码框架、文档整理、知识梳理层面
2. **静默生效**：防幻觉规则静默生效，不改变原有使用习惯
3. **默认本地存档**：所有资料默认仅本地存档，不自动向量入库，等待客户确认后再统一投喂
4. **即时拦截**：违反溯源规则的编造内容，由工程规则管理师第一时间拦截纠正
5. **无伤节流**：全员剔除客套话/重复话术/无效修饰，保留全部专业内容，一事一议，按需加载，详见 `01_01_knowledge_base/05_rules/01_token_efficiency_rules.md`

---

## 八、三套极简固定口令

| 口令 | 功能 | 说明 |
|------|------|------|
| **启动NV项目** | 一键复原全部项目上下文 | 输出本接续文案，含GitHub仓库信息 |
| **记录本次进度** | 精简总结本次工作 | 输出极简短句，含待同步文件提示 |
| **同步到GitHub** | 整理文件清单，生成提交说明 | 输出同步预览，客户一键确认后执行 |

---

## 九、当前项目状态

| 维度 | 状态 |
|------|------|
| 智能体团队 | ✅ 10大智能体全部配置完成 |
| 基础知识库 | ✅ 10个角色基础库已搭建（66个知识块） |
| 防幻觉体系 | ✅ 双层防幻觉框架已定型 |
| 全格式文档处理 | ✅ 9大类格式全部支持 |
| 双层提炼流程 | ✅ 流程规范v2.0已生效 |
| 项目专业知识库 | ⏳ 待上传专业PDF资料后生成 |

---

**系统已就绪，请下达任务。**
