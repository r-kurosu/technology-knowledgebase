# コスト最適化：Prompt Caching と Batch API

---

## 1. Prompt Caching（プロンプトキャッシュ）

### 仕組み

リクエストの**プレフィックス（先頭部分）が前回と一致**していればキャッシュヒットし、  
Input tokenのコストが大幅に削減される（最大約75〜90%割引）。

- **自動適用**: 設定不要。OpenAI / Azure OpenAI 両方で自動的に動作
- **最小サイズ**: 1,024 tokens 以上のプレフィックスが必要
- **キャッシュTTL**: 通常5〜10分（アイドル時間が続くと消える）

### コスト削減のための設計原則

**静的なコンテンツ → 先頭に置く / 動的なコンテンツ → 末尾に置く**

```python
# ✅ キャッシュヒットしやすい構造
messages = [
    {
        "role": "system",
        "content": """
        あなたは企業の法務アシスタントです。
        [ここに大量の静的コンテキスト: 規約・ガイドライン・例など 1,024+ tokens]
        """,
    },
    {
        "role": "user",
        "content": user_query,  # ← リクエストごとに変わる部分は末尾
    }
]

# ❌ キャッシュヒットしない（動的内容が先頭）
messages = [
    {"role": "user", "content": f"日付: {datetime.now()}\n{static_system_content}"},
]
```

### キャッシュの確認方法

```python
response = client.chat.completions.create(
    model="gpt-5.4",
    messages=messages,
)

usage = response.usage
details = usage.prompt_tokens_details

print(f"キャッシュヒット: {details.cached_tokens} tokens")
print(f"新規読み込み: {usage.prompt_tokens - details.cached_tokens} tokens")

# キャッシュヒット率
hit_rate = details.cached_tokens / usage.prompt_tokens if usage.prompt_tokens > 0 else 0
print(f"ヒット率: {hit_rate:.1%}")
```

### 実務での活用パターン

```python
# RAG + マルチユーザーの例
SYSTEM_PROMPT = """
あなたは社内ナレッジベースのアシスタントです。
{ここに製品ドキュメント・FAQなど大量の静的テキスト}
"""

def ask(user_question: str) -> str:
    response = client.chat.completions.create(
        model=DEPLOYMENT_NAME,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},  # 静的 → キャッシュされる
            {"role": "user", "content": user_question},    # 動的
        ],
    )
    return response.choices[0].message.content
```

複数ユーザーが同じSYSTEM_PROMPTを使うと、2人目以降のリクエストで  
SYSTEM_PROMPT部分のトークンコストがほぼかからない。

### Azure OpenAI での注意点

Azure OpenAI でも自動的にキャッシュが動作する。追加設定は不要。  
`prompt_tokens_details.cached_tokens` で確認できる（API version 2024-10-21以降）。

---

## 2. Batch API（バッチ処理）

### 概要

非同期でリクエストをまとめて処理することで **50%のコスト削減**。

| 項目 | 通常API | Batch API |
|---|---|---|
| **コスト** | 定価 | **50%割引** |
| **レイテンシ** | 即時（秒〜分） | 最大24時間（実際は1〜数時間が多い） |
| **Rate Limit** | 通常の枠を消費 | **別枠**（通常の枠を圧迫しない） |
| **用途** | リアルタイム用途 | バッチ処理・夜間ジョブ等 |

### 基本的な使い方

**Step 1: JSONL ファイルを作成**

```python
import json

requests = [
    {
        "custom_id": f"task-{i}",       # 後で結果と紐付けるID
        "method": "POST",
        "url": "/v1/chat/completions",
        "body": {
            "model": "gpt-5.4",          # Azure の場合はデプロイ名
            "messages": [
                {"role": "user", "content": text}
            ],
            "max_tokens": 500,
        }
    }
    for i, text in enumerate(texts_to_process)
]

with open("batch_input.jsonl", "w") as f:
    for req in requests:
        f.write(json.dumps(req, ensure_ascii=False) + "\n")
```

**Step 2: バッチを送信**

```python
from openai import OpenAI

client = OpenAI()

# ファイルをアップロード
with open("batch_input.jsonl", "rb") as f:
    file = client.files.create(file=f, purpose="batch")

# バッチを作成
batch = client.batches.create(
    input_file_id=file.id,
    endpoint="/v1/chat/completions",
    completion_window="24h",
)

print(f"Batch ID: {batch.id}")
print(f"Status: {batch.status}")
```

**Step 3: 結果を取得**

```python
import time

# ポーリングで完了を待つ
while True:
    batch = client.batches.retrieve(batch.id)
    
    if batch.status == "completed":
        break
    elif batch.status in ("failed", "cancelled", "expired"):
        raise RuntimeError(f"Batch failed: {batch.status}")
    
    print(f"Status: {batch.status} ({batch.request_counts})")
    time.sleep(60)  # 1分おきに確認

# 結果を取得
result_content = client.files.content(batch.output_file_id).text

results = {}
for line in result_content.strip().split("\n"):
    item = json.loads(line)
    results[item["custom_id"]] = item["response"]["body"]["choices"][0]["message"]["content"]
```

### Azure OpenAI での Batch API

Azure OpenAI では **Global Batch デプロイタイプ** を使う。

```python
from openai import AzureOpenAI

client = AzureOpenAI(
    api_key=...,
    api_version="2024-10-21",
    azure_endpoint=...,
)

# 以降は同じ使い方（model にはデプロイ名を指定）
```

Global Batch デプロイはAzureポータルで作成時に「Global Batch」を選択する。  
通常のデプロイに対して Batch API を呼ぶことはできないので注意。

### 向いているユースケース

- 大量ドキュメントの要約・分類・翻訳
- データセットのラベリング・Evals
- 夜間バッチ処理（翌日の業務開始前に完了）
- コスト重視の定期レポート生成

### 向いていないユースケース

- リアルタイムのユーザー向けアプリ
- 結果を即時に必要とする処理
- 会話履歴が必要なインタラクティブ用途

---

## 3. コスト最適化の全体戦略

| 手法 | 削減効果 | 実装コスト |
|---|---|---|
| Prompt Caching | Input tokenを最大75〜90%削減 | 低（設計を変えるだけ） |
| Batch API | 全体50%削減 | 中（非同期設計が必要） |
| 軽量モデルへの切り替え | 大幅削減（モデル依存） | 低〜中 |
| max_tokens の適切な設定 | Output token削減 | 低 |
| 不要なコンテキストの削除 | Input token削減 | 低 |

```python
# コスト試算の考え方
# ・リアルタイムかつ大きなsystem prompt → Prompt Caching を最大活用
# ・リアルタイム不要の大量処理 → Batch API
# ・両方組み合わせることも可能（Batch内でもキャッシュは動作する）
```

---

## 参考リンク

- [Prompt Caching](https://platform.openai.com/docs/guides/prompt-caching)
- [Batch API](https://platform.openai.com/docs/guides/batch)
- [Azure OpenAI Batch](https://learn.microsoft.com/azure/ai-services/openai/how-to/batch)
- [Cost optimization guide](https://platform.openai.com/docs/guides/cost-optimization)
