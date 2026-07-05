# OpenAI Agents SDK（Python）

`openai-agents` ライブラリで宣言的にエージェントを構築できる。  
OpenAI が SDK 側でエージェントループを管理するため、手動ループ実装が不要。

Responses API との使い分けは [06_Responses_API_and_Agents.md](06_Responses_API_and_Agents.md) 参照。  
Anthropic Managed Agents との比較は [このファイルの末尾](#anthropic-managed-agents-との比較) 参照。

---

## インストール

```bash
pip install openai-agents
```

---

## 基本的なエージェント

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

---

## カスタムツールの定義（`@function_tool`）

`@function_tool` デコレータで Python 関数をエージェントが呼べるツールに変換できる。  
型ヒントと docstring を書くだけで JSON スキーマが自動生成される。

```python
from agents import Agent, Runner, function_tool

@function_tool
def get_weather(city: str) -> str:
    """指定した都市の現在の天気を返す。"""
    return f"{city}: 晴れ、25°C"

@function_tool
def send_email(to: str, subject: str, body: str) -> str:
    """メールを送信する。"""
    return f"{to} にメール送信完了"

agent = Agent(
    name="アシスタント",
    instructions="ユーザーの依頼を処理する",
    tools=[get_weather, send_email],
)

result = Runner.run_sync(agent, "東京の天気を教えて")
print(result.final_output)
```

---

## コンテキスト変数（`RunContext`）

エージェントをまたぐ共有状態を dataclass + `RunContextWrapper` で渡す。

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

---

## ハンドオフ（マルチエージェント）

タスクを別のエージェントに委譲するパターン。オーケストレーターが `handoffs` リストから適切なエージェントを選ぶ。

```python
from agents import Agent, Runner

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

orchestrator = Agent(
    name="オーケストレーター",
    instructions="タスクを適切な専門エージェントに振り分ける",
    handoffs=[data_analyst, researcher],
)

result = Runner.run_sync(orchestrator, "競合他社の最新動向を調べて売上データと比較して")
```

---

## ガードレール

入力・出力を検証するバリデーションレイヤー。

```python
from agents import Agent, Runner, input_guardrail, GuardrailFunctionOutput
from pydantic import BaseModel

class SafetyCheck(BaseModel):
    is_safe: bool
    reason: str

@input_guardrail
async def safety_guardrail(ctx, agent, input) -> GuardrailFunctionOutput:
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

---

## 実行パターン：同期・非同期・ストリーミング

| メソッド | 用途 |
|---|---|
| `Runner.run_sync()` | 同期的に実行（内部で `asyncio.run()`）。スクリプト・CLI 向け |
| `Runner.run()` | 非同期。FastAPI など既存 async コードと統合する場合 |
| `Runner.run_streamed()` | ストリーミング。UI へリアルタイム表示する場合 |

### 非同期実行（FastAPI との組み合わせ）

```python
from fastapi import FastAPI
from agents import Agent, Runner

agent = Agent(name="アシスタント", instructions="役に立つアシスタント")
app = FastAPI()

@app.post("/chat")
async def chat(message: str) -> dict:
    result = await Runner.run(agent, message)
    return {"response": result.final_output}
```

### ストリーミング

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

---

## トレーシング

`openai-agents` はデフォルトで全実行トレースを OpenAI の Dashboard に記録する。

```python
from agents import set_tracing_disabled

# トレース無効化（本番でコストを下げたい場合など）
set_tracing_disabled(True)
```

---

## Anthropic Managed Agents との比較

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

→ Anthropic 側の詳細: [../anthropic/07_Claude_Agent_SDK.md](../anthropic/07_Claude_Agent_SDK.md)

---

## 参考リンク

- [Agents SDK (Python)](https://openai.github.io/openai-agents-python/)
- [OpenAI Agents SDK GitHub](https://github.com/openai/openai-agents-python)
