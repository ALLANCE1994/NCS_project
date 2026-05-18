import os
import fitz
import chromadb
from nomic import embed
from agent_config import config

def extract_text_from_pdf(pdf_path):
    doc = fitz.open(pdf_path)
    text = ""
    for page in doc:
        text += page.get_text()
    return text

def split_text_into_chunks(text, chunk_size=1000, chunk_overlap=200):
    chunks = []
    start = 0
    while start < len(text):
        end = start + chunk_size
        chunk = text[start:end]
        chunks.append(chunk)
        start = end - chunk_overlap
    return chunks

def process_pdf_and_add_to_kb(pdf_path, collection):
    print(f"正在处理: {pdf_path}")
    text = extract_text_from_pdf(pdf_path)
    chunks = split_text_into_chunks(text)

    embeddings = embed.text(chunks, model="nomic-embed-text-v1.5")["embeddings"]

    ids = [f"{os.path.basename(pdf_path)}_{i}" for i in range(len(chunks))]
    metadatas = [{"source": pdf_path, "chunk": i} for i in range(len(chunks))]

    collection.add(ids=ids, documents=chunks, embeddings=embeddings, metadatas=metadatas)
    print(f"成功添加 {len(chunks)} 个块")

def main():
    client = chromadb.PersistentClient(path=config["vector_db_path"])
    collection = client.get_or_create_collection(name="Hardware_Knowledge_Base")

    for root, dirs, files in os.walk(config["knowledge_base_path"]):
        for file in files:
            if file.endswith(".pdf"):
                pdf_path = os.path.join(root, file)
                process_pdf_and_add_to_kb(pdf_path, collection)

    print(f"知识库构建完成，总共有 {collection.count()} 个块")

if __name__ == "__main__":
    main()
