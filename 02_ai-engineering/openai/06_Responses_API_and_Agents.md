# Responses API と Agents SDK

2025年3月にOpenAIが発表した新API群のまとめ。

---

## 1. Responses API とは

**Chat Completions APIの後継**として設計された新しいAPIプリミティブ。  
エージェント的なユースケース（複数ターン・ツール使用・状態管理）を第一級に扱う。

| 比較軸 | Chat Completions API | Responses API |
|---|---|---|
| **入力形式** | `messages: [...]` | `input: "..."` または `input: [...]` |
| **出力形式** | `choices[0].message.content` | `output[0].content[0].text` |
| **会話状態** | 自前でhistoryを管理 | `previous_response_id` でチェーン |
| **組み込みツール** | なし（自前実装） | web_search / file_search / code_interpreter |
| **Structured Output** | `response_format` パラメータ | `text.format` パラメータ |

**Chat Completions は引き続きサポートされる。** 既存システムは無理に移行しなくてよい。

---

## 2. Responses API の基本

```python
from openai import OpenAI

client = OpenAI()

# 単発リクエスト
response = client.responses.create(
    model="gpt-5.4",
    input="東京の最新の天気は？",
    tools=[{"type": "web_search_preview"}],
)

print(response.output_text)  # 出力テキスト
print(response.id)           # 後続リクエストで使うID
```

### 会話の継続（状態管理）

```python
# 1ターン目
r1 = client.responses.create(
    model="gpt-5.4",
    input="Pythonでリストをソートする方法を教えて",
)

# 2ターン目（前の応答を参照）
r2 = client.responses.create(
    model="gpt-5.4",
    input="逆順にするには？",
    previous_response_id=r1.id,  # ← 自前でhistoryを渡す必要がない
)
```

### Azure OpenAI での Responses API

```python
from openai import AzureOpenAI

client = AzureOpenAI(
    api_key=...,
    api_version="2025-01-01-preview",  # preview版が必要
    azure_endpoint=...,
)

response = client.responses.create(
    model="my-gpt5-deployment",
    input="query here",
)
```

---

## 3. 組み込みツール

### web_search_preview

リアルタイムのウェブ検索。ハルシネーション削減に有効。

```python
response = client.responses.create(
    model="gpt-5.4",
    input="2026年のAIトレンドを教えて",
    tools=[{"type": "web_search_preview"}],
)
```

### file_search

OpenAI Vector Store に保存したドキュメントからRAG検索。

```python
# 事前にVector Storeを作成しておく
vector_store_id = "vs_xxxx"

response = client.responses.create(
    model="gpt-5.4",
    input="製品仕様書のページ数は？",
    tools=[{
        "type": "file_search",
        "vector_store_ids": [vector_store_id],
    }],
)
```

### code_interpreter

サンドボックス内でPythonを実行。データ分析・可視化に使う。

```python
response = client.responses.create(
    model="gpt-5.4",
    input="このCSVデータを集計して平均を出して",
    tools=[{"type": "code_interpreter", "container": {"type": "auto"}}],
)
```

---

## 4. Agents SDK（Python）

詳細は専用ノートを参照: [11_OpenAI_Agents_SDK.md](11_OpenAI_Agents_SDK.md)

**主なトピック**: `@function_tool`、`RunContext`、ハンドオフ（マルチエージェント）、ガードレール、  
`Runner.run_sync` / `Runner.run`（非同期）/ `Runner.run_streamed`、トレーシング、Anthropic との比較

---

## 5. Responses API vs Chat Completions: 使い分け

| ユースケース | 推奨API |
|---|---|
| 新規エージェント開発 | **Responses API** |
| Web検索・コード実行が必要 | **Responses API** |
| 複数ターン会話（状態管理簡略化） | **Responses API** |
| 既存の Chat Completions ベースのシステム | Chat Completions のまま |
| カスタムツール実装が主体 | Chat Completions でも可 |
| シンプルな単発リクエスト | どちらでも可 |

---

## 参考リンク

- [Responses API](https://platform.openai.com/docs/guides/responses-vs-chat-completions)
- [Agents SDK (Python)](https://openai.github.io/openai-agents-python/)
- [Built-in tools](https://platform.openai.com/docs/guides/tools)
