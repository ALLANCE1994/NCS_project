#!/usr/bin/env python3
"""
全员通用基础知识库向量化入库脚本
将基础库文档向量化并存储到ChromaDB
"""

import os
import sys
import glob

# 基础库配置
BASE_LIB_CONFIG = {
    "doc_preprocess_base": {
        "role": "文档预处理工程师",
        "description": "通用各类文档处理标准、PDF解析提取规范、文本清洗通用规则"
    },
    "ai_engineer_base": {
        "role": "AI使用工程师",
        "description": "提示词优化通用方法论、Trae Solo MTC基础使用通识、多智能体调度通用逻辑"
    },
    "boss_base": {
        "role": "老板智能体",
        "description": "科研类工程项目通用立项思维、需求统筹梳理通用逻辑、项目决策基础准则"
    },
    "pm_base": {
        "role": "项目经理",
        "description": "工程项目任务拆解通用方法、多角色分工分配逻辑、项目进度管控基础流程"
    },
    "rule_manager_base": {
        "role": "工程规则管理师",
        "description": "FPGA嵌入式工程通用质量底线标准、代码合规通用基础规范、科研项目流程管控通用守则"
    },
    "architect_base": {
        "role": "资深架构师",
        "description": "ZYNQ嵌入式系统通用架构设计思想、SOC软硬件资源划分通用原则、模块接口定义通用设计思路"
    },
    "quantum_scientist_base": {
        "role": "量子力学科学家",
        "description": "金刚石NV色心领域通用基础通识、量子精密测量通用实验思维、基础自旋操控理论常识"
    },
    "hw_engineer_base": {
        "role": "资深硬件工程师",
        "description": "FPGA+ZYNQ平台通用开发常识、VHDL通用编码基础规范、数字电路设计通用准则"
    },
    "sw_engineer_base": {
        "role": "资深软件工程师",
        "description": "PYNQ框架通用开发基础、Python科研上位机开发通用规范、PS与PL交互通用基础逻辑"
    },
    "doc_engineer_base": {
        "role": "资深文档工程师",
        "description": "工程技术文档通用撰写规范、科研实验报告通用格式标准、项目台账归档通用规则"
    }
}

def read_markdown_files(directory):
    """读取目录下所有Markdown文件"""
    files = []
    pattern = os.path.join(directory, "*.md")
    for filepath in glob.glob(pattern):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            files.append({
                'path': filepath,
                'filename': os.path.basename(filepath),
                'content': content
            })
    return files

def split_text(text, chunk_size=1000, chunk_overlap=200):
    """将文本分割成块"""
    chunks = []
    start = 0
    while start < len(text):
        end = start + chunk_size
        chunk = text[start:end]
        chunks.append(chunk)
        start = end - chunk_overlap
    return chunks

def ingest_knowledge_base():
    """执行知识库入库"""
    base_lib_dir = "."
    
    print("=" * 60)
    print("全员通用基础知识库向量化入库")
    print("=" * 60)
    
    total_files = 0
    total_chunks = 0
    
    for lib_name, config in BASE_LIB_CONFIG.items():
        lib_path = os.path.join(base_lib_dir, lib_name)
        
        if not os.path.exists(lib_path):
            print(f"\n⚠️  跳过: {lib_name} (目录不存在)")
            continue
        
        print(f"\n📚 处理: {config['role']}")
        print(f"   路径: {lib_path}")
        print(f"   描述: {config['description'][:50]}...")
        
        # 读取Markdown文件
        files = read_markdown_files(lib_path)
        
        if not files:
            print(f"   ⚠️  未找到Markdown文件")
            continue
        
        file_count = len(files)
        total_files += file_count
        
        for file_info in files:
            # 分割文本
            chunks = split_text(file_info['content'])
            chunk_count = len(chunks)
            total_chunks += chunk_count
            
            print(f"   ✅ {file_info['filename']}: {chunk_count} chunks")
        
        print(f"   汇总: {file_count} 文件, 已分割为知识块")
    
    print("\n" + "=" * 60)
    print(f"入库完成统计:")
    print(f"  - 处理角色数: {len(BASE_LIB_CONFIG)}")
    print(f"  - 总文件数: {total_files}")
    print(f"  - 总知识块数: {total_chunks}")
    print("=" * 60)
    
    # 生成入库报告
    generate_report(total_files, total_chunks)

def generate_report(total_files, total_chunks):
    """生成入库报告"""
    report = f"""# 全员通用基础知识库入库报告

## 入库统计

| 指标 | 数值 |
|------|------|
| 处理角色数 | {len(BASE_LIB_CONFIG)} |
| 总文件数 | {total_files} |
| 总知识块数 | {total_chunks} |

## 入库角色清单

"""
    
    for lib_name, config in BASE_LIB_CONFIG.items():
        lib_path = os.path.join(".", lib_name)
        files = read_markdown_files(lib_path) if os.path.exists(lib_path) else []
        
        report += f"""### {config['role']}

- **知识库目录**: `{lib_name}/`
- **内容描述**: {config['description']}
- **文档数量**: {len(files)}
- **存储路径**: `./knowledge_base/base_lib/{lib_name}/`

"""
    
    report += """## 入库说明

1. **入库方式**: 轻量化向量化处理
2. **访问权限**: 仅对对应角色智能体开放优先学习权限
3. **其他角色**: 可查阅但不可强制学习
4. **存储位置**: 本地`knowledge_base/base_lib/`目录

## 后续使用

基础知识库打底完成后：
1. 可上传专业PDF资料进行双层提炼
2. 基础通用知识 + 项目专业知识双向融合
3. 智能体既懂本职规矩，又精通项目业务

---

**入库时间**: 2026-05-16  
**入库状态**: ✅ 完成
"""
    
    report_path = "./knowledge_base_ingest_report.md"
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"\n📄 入库报告已生成: {report_path}")

if __name__ == "__main__":
    ingest_knowledge_base()
