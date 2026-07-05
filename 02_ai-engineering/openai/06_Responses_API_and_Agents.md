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

`openai-agents` ライブラリで宣言的にエージェントを構築できる。

```bash
pip install openai-agents
```

### 基本的なエージェント

```python
from agents import Agent, Runner

agent = Agent(
    name="リサーチエージェント",
    instructions="ウェブを検索して最新情報を提供する",
    model="gpt-5.4",
    tools=["web_search_preview"],
)

result = Runner.run_sync(agent, "Anthropic Claude 4.6の最新情報を教えて")
print(result.final_output)
```

### ハンドオフ（マルチエージェント）

タスクを別のエージェントに委譲するパターン。

```python
from agents import Agent, Runner

# 専門エージェントたち
data_analyst = Agent(
    name="データアナリスト",
    instructions="数値データの分析・集計が専門",
    tools=["code_interpreter"],
)

researcher = Agent(
    name="リサーチャー",
    instructions="ウェブ情報収集が専門",
    tools=["web_search_preview"],
)

# オーケストレーターがハンドオフを判断
orchestrator = Agent(
    name="オーケストレーター",
    instructions="タスクを適切な専門エージェントに振り分ける",
    handoffs=[data_analyst, researcher],
)

result = Runner.run_sync(orchestrator, "競合他社の最新動向を調べて売上データと比較して")
```

### ガードレール

入力・出力を検証するバリデーションレイヤー。

```python
from agents import Agent, Runner, input_guardrail, GuardrailFunctionOutput
from pydantic import BaseModel

class SafetyCheck(BaseModel):
    is_safe: bool
    reason: str

@input_guardrail
async def safety_guardrail(ctx, agent, input) -> GuardrailFunctionOutput:
    # 入力の安全性チェック
    result = await Runner.run(safety_agent, input)
    output = result.final_output_as(SafetyCheck)
    return GuardrailFunctionOutput(
        output_info=output,
        tripwire_triggered=not output.is_safe,
    )

agent = Agent(
    name="本番エージェント",
    input_guardrails=[safety_guardrail],
)
```

### カスタムツールの定義（`@function_tool`）

`@function_tool` デコレータで Python 関数をエージェントが呼べるツールに変換できる。  
型ヒントと docstring を書くだけで JSON スキーマが自動生成される。

```python
from agents import Agent, Runner, function_tool

@function_tool
def get_weather(city: str) -> str:
    """指定した都市の現在の天気を返す。"""
    # 実際は外部API呼び出しなど
    return f"{city}: 晴れ、25°C"

@function_tool
def send_email(to: str, subject: str, body: str) -> str:
    """メールを送信する。"""
    # 実際はメール送信ロジック
    return f"{to} にメール送信完了"

agent = Agent(
    name="アシスタント",
    instructions="ユーザーの依頼を処理する",
    tools=[get_weather, send_email],
)

result = Runner.run_sync(agent, "東京の天気を教えて")
print(result.final_output)
```

### コンテキスト変数（`RunContext`）

エージェントをまたぐ共有状態を TypedDict + `RunContextWrapper` で渡す。

```python
from dataclasses import dataclass
from agents import Agent, Runner, RunContextWrapper, function_tool

@dataclass
class AppContext:
    user_id: str
    plan: str  # "free" | "pro" | "enterprise"

@function_tool
def check_quota(ctx: RunContextWrapper[AppContext]) -> str:
    """ユーザーのクォータを確認する。"""
    if ctx.context.plan == "free":
        return "残り: 10リクエスト/日"
    return "無制限"

agent = Agent(
    name="サポートエージェント",
    tools=[check_quota],
)

ctx = AppContext(user_id="u123", plan="pro")
result = Runner.run_sync(agent, "今月の使用量は？", context=ctx)
```

### 非同期実行（`Runner.run`）

`Runner.run_sync` は内部で `asyncio.run()` を呼ぶ同期ラッパー。  
既存の async コードや FastAPI などと組み合わせるときは `Runner.run`（非同期）を使う。

```python
import asyncio
from agents import Agent, Runner

agent = Agent(name="アシスタント", instructions="役に立つアシスタント")

async def handle_request(user_input: str) -> str:
    result = await Runner.run(agent, user_input)
    return result.final_output

# FastAPI との組み合わせ例
from fastapi import FastAPI
app = FastAPI()

@app.post("/chat")
async def chat(message: str) -> dict:
    output = await handle_request(message)
    return {"response": output}
```

### ストリーミング（`Runner.run_streamed`）

```python
from agents import Runner

async def stream_response(agent, user_input: str):
    async with Runner.run_streamed(agent, user_input) as stream:
        async for event in stream.stream_events():
            if event.type == "raw_response_event":
                delta = event.data.delta
                if hasattr(delta, "text"):
                    print(delta.text, end="", flush=True)
```

### トレーシング

`openai-agents` はデフォルトで全実行トレースを OpenAI の Dashboard に記録する。  
無効化やカスタムエクスポートも可能。

```python
from agents import set_tracing_disabled

# トレース無効化（本番でコストを下げたい場合など）
set_tracing_disabled(True)
```

### Anthropic Agents SDK との比較

| 比較軸 | OpenAI Agents SDK (`openai-agents`) | Anthropic Managed Agents |
|---|---|---|
| **ホスティング** | 自分でホスト（SDK がループを管理） | Anthropic がコンテナをホスト |
| **ループ管理** | SDK（`Runner`）が自動管理 | Anthropic サーバーが管理 |
| **ツール定義** | `@function_tool` デコレータ | API スキーマ or `agent_toolset` |
| **ファイルシステム** | 自前で用意 | 自動プロビジョニング（session ごと） |
| **状態管理** | `RunContext` で引数渡し | Session で自動管理 |
| **マルチエージェント** | `handoffs` で宣言的に | Orchestrator パターン（手動） |
| **ガードレール** | `@input_guardrail`/`@output_guardrail` | プロンプトエンジニアリング主体 |
| **トレーシング** | 標準搭載（OpenAI Dashboard） | Claude.ai コンソール |
| **向いているケース** | 自前インフラ上で細かく制御したい | すばやく本番稼動させたい |

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
