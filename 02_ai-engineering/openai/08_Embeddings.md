# OpenAI Embeddings

テキストを数値ベクトルに変換するAPI。意味的な類似度の計算・検索・分類に使用する。

---

## 1. 基本概念

**Embedding（埋め込み）**: テキストを高次元の浮動小数点数ベクトルに変換したもの。  
意味が近いテキストほど、ベクトル空間上で近い位置に配置される。

**Claudeとの比較**:
> Anthropicはembeddingモデルを提供していない。RAGやセマンティック検索が必要な場合は、OpenAI / Cohere / Azure AI などのembeddingモデルを組み合わせて使用する。

---

## 2. モデル比較

| モデル | 次元数（デフォルト） | 最大入力 | 料金（/1Kトークン） | 用途 |
|--------|---------------------|----------|---------------------|------|
| `text-embedding-3-small` | 1,536 | 8,191 tokens | $0.00002 | コスト重視、高速処理 |
| `text-embedding-3-large` | 3,072 | 8,191 tokens | $0.00013 | 精度重視、本番RAG |
| `text-embedding-ada-002` | 1,536 | 8,191 tokens | $0.00010 | レガシー（新規採用非推奨） |

**次元数の削減（Matryoshka表現学習）**:  
`text-embedding-3` シリーズは `dimensions` パラメータで次元を削減可能。

> text-embedding-3-large を 256次元に削減しても、text-embedding-ada-002（1,536次元）を上回る精度を維持する。

---

## 3. 基本的な実装

```python
from openai import OpenAI

client = OpenAI()

# 単一テキストのembedding
response = client.embeddings.create(
    model="text-embedding-3-small",
    input="OpenAIのembedding APIを使ってみる"
)

embedding = response.data[0].embedding      # 浮動小数点数のリスト
print(f"次元数: {len(embedding)}")           # 1536
print(f"使用トークン: {response.usage.total_tokens}")
```

### 次元数を削減する

```python
response = client.embeddings.create(
    model="text-embedding-3-large",
    input="高精度で低コストな埋め込みが必要",
    dimensions=256     # デフォルト3072 → 256に削減（コスト・速度改善）
)

print(len(response.data[0].embedding))  # 256
```

---

## 4. ユースケースと実装パターン

### 4-1. セマンティック検索（コサイン類似度）

```python
import numpy as np
from openai import OpenAI

client = OpenAI()

def get_embedding(text: str, model="text-embedding-3-small") -> list[float]:
    return client.embeddings.create(input=text, model=model).data[0].embedding

def cosine_similarity(a: list, b: list) -> float:
    a, b = np.array(a), np.array(b)
    return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))

# ドキュメントをembedding化（事前計算・DB保存が前提）
docs = [
    "Pythonでのウェブ開発入門",
    "機械学習の基礎と応用",
    "データベース設計のベストプラクティス"
]
doc_embeddings = [get_embedding(doc) for doc in docs]

# クエリに最も近いドキュメントを検索
query = "AIを使ったプログラミング"
query_embedding = get_embedding(query)

similarities = [cosine_similarity(query_embedding, de) for de in doc_embeddings]
best_match_idx = similarities.index(max(similarities))
print(f"最も関連するドキュメント: {docs[best_match_idx]}")
```

### 4-2. RAG（Retrieval-Augmented Generation）の基本構造

```python
# 1. ドキュメントをchunkに分割してembedding化（オフライン）
# 2. ベクトルDBに保存（Pinecone / Chroma / pgvector 等）
# 3. ユーザーのクエリをembedding化（オンライン）
# 4. ベクトルDB検索で関連chunkを取得
# 5. 取得したchunkをコンテキストとしてLLMに渡す

from openai import OpenAI

client = OpenAI()

def rag_answer(query: str, relevant_docs: list[str]) -> str:
    context = "\n\n".join(relevant_docs)
    response = client.chat.completions.create(
        model="gpt-5.4",
        messages=[
            {"role": "system", "content": f"以下のドキュメントを参照して質問に答えてください:\n\n{context}"},
            {"role": "user", "content": query}
        ]
    )
    return response.choices[0].message.content
```

### 4-3. バッチ処理（大量テキストの効率化）

```python
# 複数テキストを一度に処理（API呼び出し回数削減）
texts = ["テキスト1", "テキスト2", "テキスト3", ...]  # 最大2048件まで一度に送信可能

response = client.embeddings.create(
    model="text-embedding-3-small",
    input=texts    # リスト形式でバッチ送信
)

embeddings = [d.embedding for d in response.data]  # 順序保証あり
```

---

## 5. コスト・パフォーマンスの選択基準

| 要件 | 推奨モデル | 設定 |
|------|-----------|------|
| 精度優先（本番RAG） | text-embedding-3-large | dimensions=1536以上 |
| コスト優先（大量処理） | text-embedding-3-small | デフォルト |
| ストレージ節約 | text-embedding-3-large | dimensions=256 |
| レガシーシステム維持 | text-embedding-ada-002 | - |

---

## 6. 注意点

- **コンテキスト長**: 8,191トークンを超えるテキストは切り捨て（チャンク分割が必要）
- **言語**: 多言語対応だが、日本語は英語より若干精度が落ちる傾向
- **正規化**: APIのレスポンスはL2正規化済み（`np.linalg.norm(embedding) ≒ 1.0`）
- **embedding の変更**: モデルを変更したら全データのre-embedding が必要

---

## 参考リンク

- [Embeddings ガイド](https://platform.openai.com/docs/guides/embeddings)
- [Embeddings API リファレンス](https://platform.openai.com/docs/api-reference/embeddings)
- [新embedding モデル発表](https://openai.com/index/new-embedding-models-and-api-updates/)
