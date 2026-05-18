# -*- coding: utf-8 -*-
"""
NV色心项目 - 知识库向量入库脚本

功能：
1. 读取各智能体知识库Markdown文件
2. 使用Sentence-Transformers生成向量嵌入
3. 存储到本地ChromaDB向量数据库
4. 支持语义检索

依赖安装：
    pip install chromadb sentence-transformers

使用方法：
    python vector_db_ingest.py

作者：@A AI使用工程师
日期：2026-05-18
"""

import os
import re
import chromadb
from chromadb.config import Settings
from sentence_transformers import SentenceTransformer
from pathlib import Path
import hashlib
import json

# ========== 配置 ==========
# 知识库根目录
KNOWLEDGE_BASE_DIR = Path(r"c:\Users\YXCOA\Desktop\lxb\NCS_project-main\01_knowledge_base\base_lib")

# 向量数据库保存路径
VECTOR_DB_PATH = Path(r"c:\Users\YXCOA\Desktop\lxb\NCS_project-main\01_knowledge_base\vector_db")

# 使用的嵌入模型（轻量级，支持中文）
# 可选："paraphrase-multilingual-MiniLM-L12-v2"（多语言，推荐）
#       "distiluse-base-multilingual-cased-v1"（更快，精度稍低）
EMBEDDING_MODEL = "paraphrase-multilingual-MiniLM-L12-v2"

# 文本分块大小（字符数）
CHUNK_SIZE = 500
CHUNK_OVERLAP = 100

# 需要处理的智能体知识库
AGENT_KNOWLEDGE_BASES = {
    "hw_engineer": "@H 硬件工程师",
    "architect": "@P 架构师",
    "sw_engineer": "@S 软件工程师",
    "ai_engineer": "@A AI使用工程师",
    "pm_base": "@M 项目经理",
    "boss_base": "@C 老板",
    "quantum_scientist": "@Q 量子科学家",
    "doc_engineer": "@D 文档工程师",
    "doc_preprocess": "@D 文档预处理工程师",
    "rule_manager": "@V 工程规则管理师",
    "hallucination_prevention": "防幻觉避坑手册",
}


def init_chroma_db():
    """初始化ChromaDB向量数据库"""
    # 确保目录存在
    VECTOR_DB_PATH.mkdir(parents=True, exist_ok=True)
    
    # 创建客户端
    client = chromadb.PersistentClient(
        path=str(VECTOR_DB_PATH),
        settings=Settings(
            anonymized_telemetry=False,
            allow_reset=True
        )
    )
    return client


def get_or_create_collection(client, agent_name, agent_display):
    """获取或创建智能体的向量集合"""
    collection_name = f"kb_{agent_name}"
    
    try:
        collection = client.get_collection(name=collection_name)
        print(f"  使用现有集合: {collection_name}")
    except:
        collection = client.create_collection(
            name=collection_name,
            metadata={
                "agent_name": agent_name,
                "agent_display": agent_display,
                "description": f"{agent_display}专属知识库"
            }
        )
        print(f"  创建新集合: {collection_name}")
    
    return collection


def chunk_text(text, chunk_size=CHUNK_SIZE, overlap=CHUNK_OVERLAP):
    """将长文本分块"""
    chunks = []
    start = 0
    
    while start < len(text):
        end = start + chunk_size
        chunk = text[start:end]
        
        # 尝试在句子边界处截断
        if end < len(text):
            # 查找最后一个句号、问号或换行
            for delim in ['。', '？', '！', '.', '?', '!', '\n\n']:
                last_delim = chunk.rfind(delim)
                if last_delim > chunk_size * 0.5:  # 至少保留一半内容
                    chunk = chunk[:last_delim + 1]
                    break
        
        chunks.append(chunk.strip())
        start = end - overlap
    
    return chunks


def extract_knowledge_items(md_content, file_path):
    """从Markdown内容中提取知识条目"""
    items = []
    
    # 按章节分割（## 标题）
    sections = re.split(r'\n## ', md_content)
    
    for section in sections:
        if not section.strip():
            continue
        
        # 提取标题
        lines = section.split('\n')
        title = lines[0].strip().lstrip('#').strip()
        content = '\n'.join(lines[1:]).strip()
        
        if not content:
            continue
        
        # 如果内容太长，分块
        if len(content) > CHUNK_SIZE:
            chunks = chunk_text(content)
            for i, chunk in enumerate(chunks):
                items.append({
                    "title": title,
                    "content": chunk,
                    "chunk_index": i,
                    "total_chunks": len(chunks),
                    "source_file": str(file_path)
                })
        else:
            items.append({
                "title": title,
                "content": content,
                "chunk_index": 0,
                "total_chunks": 1,
                "source_file": str(file_path)
            })
    
    return items


def generate_id(text, agent_name, index):
    """生成唯一ID"""
    hash_input = f"{agent_name}_{text[:100]}_{index}"
    return hashlib.md5(hash_input.encode()).hexdigest()


def ingest_agent_knowledge(client, agent_dir, agent_name, agent_display, model):
    """将智能体知识库入库"""
    print(f"\n{'='*60}")
    print(f"处理: {agent_display}")
    print(f"{'='*60}")
    
    if not agent_dir.exists():
        print(f"  ⚠️ 目录不存在: {agent_dir}")
        return 0
    
    # 获取或创建集合
    collection = get_or_create_collection(client, agent_name, agent_display)
    
    # 清空现有数据（重新入库）
    existing = collection.count()
    if existing > 0:
        print(f"  清空现有数据: {existing} 条")
        collection.delete(where={})
    
    # 读取所有Markdown文件
    md_files = list(agent_dir.glob("*.md"))
    if not md_files:
        print(f"  ⚠️ 未找到Markdown文件")
        return 0
    
    print(f"  找到 {len(md_files)} 个文件")
    
    total_items = 0
    
    for md_file in md_files:
        print(f"\n  处理文件: {md_file.name}")
        
        # 读取内容
        with open(md_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 提取知识条目
        items = extract_knowledge_items(content, md_file)
        print(f"    提取 {len(items)} 个知识块")
        
        if not items:
            continue
        
        # 准备入库数据
        ids = []
        documents = []
        metadatas = []
        embeddings = []
        
        for i, item in enumerate(items):
            # 生成ID
            doc_id = generate_id(item["content"], agent_name, i)
            ids.append(doc_id)
            
            # 文档内容
            doc_text = f"{item['title']}\n\n{item['content']}"
            documents.append(doc_text)
            
            # 元数据
            metadatas.append({
                "agent": agent_display,
                "source_file": item["source_file"],
                "title": item["title"],
                "chunk_index": item["chunk_index"],
                "total_chunks": item["total_chunks"]
            })
            
            # 生成向量
            embedding = model.encode(doc_text).tolist()
            embeddings.append(embedding)
        
        # 批量入库
        collection.add(
            ids=ids,
            documents=documents,
            metadatas=metadatas,
            embeddings=embeddings
        )
        
        total_items += len(items)
        print(f"    ✅ 入库 {len(items)} 条")
    
    print(f"\n  总计入库: {total_items} 条")
    return total_items


def test_query(client, model):
    """测试查询功能"""
    print(f"\n{'='*60}")
    print("测试语义检索")
    print(f"{'='*60}")
    
    test_queries = [
        "XC7Z020的LUT数量",
        "XDC约束怎么写",
        "PYNQ Overlay设计",
        "AXI总线协议",
    ]
    
    for query in test_queries:
        print(f"\n查询: {query}")
        
        # 生成查询向量
        query_embedding = model.encode(query).tolist()
        
        # 在所有集合中搜索
        results = []
        for collection in client.list_collections():
            col = client.get_collection(collection.name)
            try:
                res = col.query(
                    query_embeddings=[query_embedding],
                    n_results=2,
                    include=["documents", "metadatas", "distances"]
                )
                if res["ids"][0]:
                    for i, doc_id in enumerate(res["ids"][0]):
                        results.append({
                            "agent": res["metadatas"][0][i]["agent"],
                            "source": res["metadatas"][0][i]["source_file"],
                            "content": res["documents"][0][i][:200] + "...",
                            "distance": res["distances"][0][i]
                        })
            except:
                pass
        
        # 按距离排序
        results.sort(key=lambda x: x["distance"])
        
        if results:
            best = results[0]
            print(f"  最佳匹配: {best['agent']}")
            print(f"  来源: {best['source']}")
            print(f"  内容: {best['content']}")
        else:
            print("  未找到匹配结果")


def main():
    print("=" * 60)
    print("NV色心项目 - 知识库向量入库")
    print("=" * 60)
    print(f"\n向量数据库路径: {VECTOR_DB_PATH}")
    print(f"嵌入模型: {EMBEDDING_MODEL}")
    print(f"知识库目录: {KNOWLEDGE_BASE_DIR}")
    
    # 检查依赖
    try:
        import chromadb
        import sentence_transformers
    except ImportError:
        print("\n❌ 缺少依赖，请先安装:")
        print("   pip install chromadb sentence-transformers")
        return
    
    # 初始化向量数据库
    print("\n初始化ChromaDB...")
    client = init_chroma_db()
    
    # 加载嵌入模型
    print(f"加载嵌入模型: {EMBEDDING_MODEL}...")
    print("(首次加载会下载模型，请耐心等待)")
    model = SentenceTransformer(EMBEDDING_MODEL)
    print("✅ 模型加载完成")
    
    # 统计
    total_ingested = 0
    
    # 处理每个智能体的知识库
    for agent_key, agent_display in AGENT_KNOWLEDGE_BASES.items():
        agent_dir = KNOWLEDGE_BASE_DIR / agent_key
        count = ingest_agent_knowledge(client, agent_dir, agent_key, agent_display, model)
        total_ingested += count
    
    # 汇总
    print(f"\n{'='*60}")
    print("入库完成汇总")
    print(f"{'='*60}")
    print(f"总计入库: {total_ingested} 条知识")
    print(f"向量数据库路径: {VECTOR_DB_PATH}")
    
    # 保存元数据
    metadata = {
        "total_items": total_ingested,
        "embedding_model": EMBEDDING_MODEL,
        "agents": list(AGENT_KNOWLEDGE_BASES.values()),
        "db_path": str(VECTOR_DB_PATH)
    }
    
    metadata_path = VECTOR_DB_PATH / "metadata.json"
    with open(metadata_path, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, ensure_ascii=False, indent=2)
    print(f"元数据已保存: {metadata_path}")
    
    # 测试查询
    test_query(client, model)
    
    print(f"\n{'='*60}")
    print("✅ 向量入库完成！")
    print(f"{'='*60}")
    print(f"\n使用说明:")
    print(f"1. 向量数据库已保存到: {VECTOR_DB_PATH}")
    print(f"2. 各智能体现在可以通过语义检索查询知识库")
    print(f"3. 检索示例代码见: test_vector_query.py")


if __name__ == "__main__":
    main()
