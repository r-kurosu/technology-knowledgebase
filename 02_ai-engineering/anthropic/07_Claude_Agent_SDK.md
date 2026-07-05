# Claude Agent SDK（Managed Agents Python）

Anthropic の Managed Agents API を使って、サーバー管理のエージェントを Python から操作するガイド。  
`anthropic` パッケージに含まれる beta 機能として利用できる。

アーキテクチャ・設計の概念は [01_Agentic_Architecture.md](01_Agentic_Architecture.md) のSection 11 参照。

---

## インストール

```bash
pip install anthropic
```

## 基本的な流れ（3ステップ）

```
Agent（一度だけ作成・IDを保存）→ Environment（一度だけ作成）→ Session（実行のたびに）
```

---

## Agent の作成（セットアップ時に一度だけ）

```python
from anthropic import Anthropic

client = Anthropic()  # ANTHROPIC_API_KEY を環境変数から読む

# エージェント設定を保存（再利用・バージョン管理される）
agent = client.beta.agents.create(
    name="Research Assistant",
    model="claude-opus-4-8",
    system="You are a helpful research assistant.",
    tools=[{"type": "agent_toolset_20260401"}],  # bash/read/write/web_search 等を一括有効化
)
# agent.id と agent.version を環境変数や設定ファイルに保存する
print(f"Agent ID: {agent.id}, Version: {agent.version}")
```

## Environment の作成（セットアップ時に一度だけ）

```python
environment = client.beta.environments.create(
    name="my-env",
    config={
        "type": "cloud",
        "networking": {"type": "unrestricted"},  # または "limited" で制限付き
    },
)
print(f"Environment ID: {environment.id}")
```

---

## Session を作成してエージェントを実行

```python
import os

AGENT_ID = os.environ["AGENT_ID"]
ENV_ID   = os.environ["ENVIRONMENT_ID"]

# Session は実行ごとに作成する
session = client.beta.sessions.create(
    agent={"type": "agent", "id": AGENT_ID},  # 最新バージョンを使う場合はIDだけでOK
    environment_id=ENV_ID,
    title="Research task",
)

# ユーザーメッセージを送信
client.beta.sessions.events.send(
    session_id=session.id,
    events=[{
        "type": "user.message",
        "content": [{"type": "text", "text": "Anthropic の最新モデルについて調べてまとめてください"}],
    }],
)

# イベントをストリーミングで受け取る
# ポイント: ストリームを開いてからメッセージを送るのがベストプラクティス
with client.beta.sessions.events.stream(session_id=session.id) as stream:
    for event in stream:
        if event.type == "agent.message":
            for block in event.content:
                if block.type == "text":
                    print(block.text, end="", flush=True)
        elif event.type == "agent.tool_use":
            print(f"\n[ツール使用: {event.name}]")
        elif event.type == "session.status_idle":
            break  # エージェントの処理完了
        elif event.type == "session.status_terminated":
            break
```

---

## カスタムツール（クライアントサイド実行）

エージェントが独自ツールを呼び出し、クライアント側で実行して結果を返すパターン。

```python
agent = client.beta.agents.create(
    name="Data Agent",
    model="claude-opus-4-8",
    tools=[
        {"type": "agent_toolset_20260401"},
        {
            "type": "custom",
            "name": "get_stock_price",
            "description": "指定した銘柄の株価を取得する",
            "input_schema": {
                "type": "object",
                "properties": {
                    "symbol": {"type": "string", "description": "ティッカーシンボル（例: AAPL）"}
                },
                "required": ["symbol"],
            },
        },
    ],
)

# セッション実行時：カスタムツールのコールバックを処理
with client.beta.sessions.events.stream(session_id=session.id) as stream:
    for event in stream:
        if event.type == "agent.custom_tool_use":
            # ここでクライアント側の実装を実行
            result = fetch_stock_price(event.input["symbol"])  # 自前の関数
            # 結果を返す
            client.beta.sessions.events.send(
                session_id=session.id,
                events=[{
                    "type": "user.custom_tool_result",
                    "custom_tool_use_id": event.id,
                    "content": [{"type": "text", "text": str(result)}],
                }],
            )
        elif event.type == "agent.message":
            for block in event.content:
                if block.type == "text":
                    print(block.text)
        elif event.type == "session.status_idle":
            break
```

---

## Agent SDK vs 直接 Messages API の使い分け

| | Messages API（手動ループ） | Agent SDK（Managed Agents） |
|---|---|---|
| **ループ管理** | 自前で実装 | Anthropic が管理 |
| **サンドボックス** | 自前で用意 | 自動プロビジョニング |
| **ファイル/リポジトリ** | 自前でマウント | `resources` で宣言 |
| **スケーリング** | 自前 | マネージド |
| **適用場面** | カスタム要件・細かい制御が必要な場合 | すばやく本番運用したい場合 |

---

## 参考リンク

- [Building Agents with the Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk)
- [Agent SDK Overview](https://platform.claude.com/docs/en/agent-sdk/overview)
- [Scaling Managed Agents](https://www.anthropic.com/engineering/managed-agents)
- [New capabilities for building agents on the Anthropic API](https://www.anthropic.com/news/agent-capabilities-api)
