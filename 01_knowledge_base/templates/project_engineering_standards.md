# 工程标准规范

P2 | 交付任务

## 核心原则
- 六层分离，层级清晰，命名统一，路径规范

## 六层目录结构

- 配置层 .trae/：agents/ rules/ skills/ 三个MTC默认识别目录
- 知识层 01_knowledge_base/：base_lib/ templates/ project_memory/ hallucination_records/ 专业子库
- 设计层 02_designs/：architecture/ interfaces/ physics/ pinout/ software/ timing/
- 代码层 03_code/：01_vhdl_modules/ 02_constraints/ 02_python_drivers/ 03_jupyter_notebooks/
- 文档层 04_docs/：01_specs/ 02_reports/ 03_manuals/ 04_progress/ 05_thesis_materials/
- 数据层 06_experiment_data/ 07_pynq_notebooks/ 08_vivado_projects/

## MTC自动加载目录（不可改名）

- .trae/agents/：智能体配置，TRAE自动扫描加载
- .trae/rules/：规则文件，TRAE自动扫描按文件名排序拼接
- .trae/skills/：技能文件，TRAE自动扫描挂载

## 命名规范

- 顶层目录：NN_英文名（01_knowledge_base 02_designs 03_code 04_docs）
- 规则文件：PX_YY_英文名_snake_case.md（P0_01_rule_layer_management.md）
- 智能体配置：角色英文名.md（boss.md project_manager.md）
- 技能文件：中文名.md（检查规则合规.md 保存工作进度.md）
- 知识库base_lib：角色英文名_base/ 子目录或 角色英文名_base.md 扁平文件
- 知识库project_memory：NN_英文名.md（01_full_project_context.md）
- 知识库templates：NN_英文名.md（01_github_sync_template.md）
- 设计文档：NN_英文名.md（01_system_architecture.md）
- 代码文件：英文名_snake_case.vhd/.py/.tcl（adc_interface.vhd）
- 约束文件：NN_英文名.xdc（01_pins.xdc）
- 报告文档：YYYYMMDD_中文描述.md（20260518_知识库审核报告.md）
- 归档报告：archive/YYYYMMDD_中文描述.md

## 路径书写规范

- 规则引用：.trae/rules/PX_YY_xxx.md
- 知识库引用：01_knowledge_base/子目录/文件名.md
- 代码引用：03_code/子目录/文件名
- 禁止：绝对路径、中文路径、空格路径、特殊字符
- 禁止：01_01_knowledge_base 等重复前缀

## 文件引用规则

- 规则间引用：仅用文件名（P0_01 P1_02）
- 跨层引用：使用从项目根目录起的相对路径
- 知识库引用知识库：01_knowledge_base/子目录/文件名.md
- 智能体引用规则：.trae/rules/PX_YY_xxx.md
- 智能体引用知识库：01_knowledge_base/base_lib/角色_base/文件名.md

## 禁止事项

- 禁止在.trae/rules/放置非规则文件（测试报告、变更清单等归档到04_docs）
- 禁止在.trae/agents/放置非智能体配置文件
- 禁止在.trae/skills/放置非技能文件
- 禁止中文文件名（技能文件除外，技能用中文便于语义检索）
- 禁止空格和特殊字符
- 禁止临时文件、草稿文件留在工程根目录
