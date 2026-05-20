# 文档保存规范

P2 | 交付任务

## 核心要求（3条）
- 代码保存：VHDL→03_code/01_vhdl_modules/（@H）、Python→03_code/02_python_drivers/（@S）、Notebook→03_code/03_jupyter_notebooks/（@S）
- Git提交：每次工作结束前执行 git add . && git commit -m "[@X] 描述" && git push
- 工作记录：复杂任务→04_docs/02_reports/YYYYMMDD_内容.md、简单任务→Git提交信息即可

## 目录权限
- 目录创建→仅@P可执行
- 文件保存→各智能体在已有目录中
- 路径确认→@V验证

## 路径不确定处理
- 查阅规范目录→找到合适路径→保存
- 找不到→交给@A协调@P确定

## 对话修改文档输出
- 修改的文档最后简单列出（禁止表格）
- 格式：- 文件名 — 简要修改说明

## 产物复用
- 常用模板、代码片段、规则文件保存为项目模板，新建项目时直接复用
- 利用历史对话功能快速查找之前生成的内容，避免重复劳动

## 操作参考
- 目录结构和操作细节详见知识库 rules_operational_details.md 第七章
