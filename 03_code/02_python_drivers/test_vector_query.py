# -*- coding: utf-8 -*-
"""
NV色心项目 - 向量知识库检索测试脚本

功能：
1. 连接到本地ChromaDB向量数据库
2. 执行语义检索查询
3. 显示检索结果及来源

使用方法：
    python test_vector_query.py

作者：@A AI使用工程师
日期：2026-05-18
"""

import chromadb
from chromadb.config import Settings
from sentence_transformers import SentenceTransformer
from pathlib import Path

# ========== 配置 ==========
VECTOR_DB_PATH = Path(r"c:\Users\YXCOA\Desktop\lxb\NCS_project-main\01_knowledge_base\vector_db")
EMBEDDING_MODEL = "paraphrase-multilingual-MiniLM-L12-v2"


def init_chroma_db():
    """初始化ChromaDB客户端"""
    client = chromadb.PersistentClient(
        path=str(VECTOR_DB_PATH),
        settings=Settings(anonymized_telemetry=False)
    )
    return client


def query_knowledge_base(client, model, query_text, n_results=3, agent_filter=None):
    """
    查询知识库
    
    参数:
        query_text: 查询文本
        n_results: 返回结果数量
        agent_filter: 指定智能体过滤（如"@H 硬件工程师"）
    
    返回:
        检索结果列表
    """
    # 生成查询向量
    query_embedding = model.encode(query_text).tolist()
    
    results = []
    
    # 获取所有集合
    collections = client.list_collections()
    
    for collection_info in collections:
        collection = client.get_collection(collection_info.name)
        
        # 如果指定了智能体过滤，检查集合元数据
        if agent_filter:
            meta = collection.metadata
            if meta.get("agent_display") != agent_filter:
                continue
        
        # 执行查询
        try:
            res = collection.query(
                query_embeddings=[query_embedding],
                n_results=n_results,
                include=["documents", "metadatas", "distances"]
            )
            
            # 解析结果
            if res["ids"] and res["ids"][0]:
                for i, doc_id in enumerate(res["ids"][0]):
                    results.append({
                        "id": doc_id,
                        "agent": res["metadatas"][0][i].get("agent", "未知"),
                        "source_file": res["metadatas"][0][i].get("source_file", "未知"),
                        "title": res["metadatas"][0][i].get("title", ""),
                        "content": res["documents"][0][i],
                        "distance": res["distances"][0][i],
                        "chunk_index": res["metadatas"][0][i].get("chunk_index", 0),
                        "total_chunks": res["metadatas"][0][i].get("total_chunks", 1)
                    })
        except Exception as e:
            print(f"  查询集合 {collection_info.name} 失败: {e}")
    
    # 按相似度排序（距离越小越相似）
    results.sort(key=lambda x: x["distance"])
    
    return results[:n_results]


def print_results(query, results):
    """打印检索结果"""
    print(f"\n{'='*60}")
    print(f"查询: {query}")
    print(f"{'='*60}")
    
    if not results:
        print("  ❌ 未找到匹配结果")
        return
    
    for i, res in enumerate(results, 1):
        print(f"\n--- 结果 {i} ---")
        print(f"  智能体: {res['agent']}")
        print(f"  来源: {res['source_file']}")
        print(f"  章节: {res['title']}")
        print(f"  相似度: {1 - res['distance']:.2%}")
        if res['total_chunks'] > 1:
            print(f"  分块: {res['chunk_index'] + 1}/{res['total_chunks']}")
        print(f"\n  内容:\n  {res['content'][:300]}...")


def main():
    print("=" * 60)
    print("NV色心项目 - 向量知识库检索测试")
    print("=" * 60)
    
    # 检查向量数据库是否存在
    if not VECTOR_DB_PATH.exists():
        print(f"\n❌ 向量数据库不存在: {VECTOR_DB_PATH}")
        print("   请先运行 vector_db_ingest.py 进行入库")
        return
    
    # 初始化
    print(f"\n连接到向量数据库: {VECTOR_DB_PATH}")
    client = init_chroma_db()
    
    print(f"加载嵌入模型: {EMBEDDING_MODEL}...")
    model = SentenceTransformer(EMBEDDING_MODEL)
    print("✅ 准备就绪\n")
    
    # 测试查询
    test_queries = [
        # 硬件相关
        "XC7Z020的LUT数量",
        "XDC约束怎么写",
        "引脚分配注意事项",
        
        # 架构相关
        "AXI总线协议",
        "IP核封装流程",
        "Vivado TCL脚本",
        
        # 软件相关
        "ARM裸机开发",
        "Linux设备树配置",
        
        # AI相关
        "PYNQ Overlay设计",
        "Jupyter Notebook使用",
        
        # 通用
        "RAG溯源规则",
        "防幻觉措施",
    ]
    
    print("\n" + "="*60)
    print("批量测试查询")
    print("="*60)
    
    for query in test_queries:
        results = query_knowledge_base(client, model, query, n_results=2)
        print_results(query, results)
    
    # 交互式查询
    print(f"\n{'='*60}")
    print("交互式查询（输入'quit'退出）")
    print(f"{'='*60}")
    
    while True:
        print("\n" + "-"*40)
        user_query = input("请输入查询内容: ").strip()
        
        if user_query.lower() in ['quit', 'exit', 'q', '退出']:
            print("再见！")
            break
        
        if not user_query:
            continue
        
        # 询问是否指定智能体
        agent_filter = input("指定智能体（直接回车搜索全部）: ").strip()
        if not agent_filter:
            agent_filter = None
        
        results = query_knowledge_base(client, model, user_query, n_results=3, agent_filter=agent_filter)
        print_results(user_query, results)


if __name__ == "__main__":
    main()
