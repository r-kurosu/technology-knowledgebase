# Claude Agent SDK / Managed Agents（Anthropic のエージェント構築 2 系統）

Anthropic でエージェントを組む方法は **2 系統**あり、名前が紛らわしいので最初に区別する。

| | **Claude Agent SDK**（`claude-agent-sdk`） | **Managed Agents**（`client.beta.agents`） |
|---|---|---|
| ループの実行場所 | **自分のプロセス / 自分のインフラ** | **Anthropic のサーバー** |
| インターフェース | Python / TypeScript ライブラリ（`query()`） | REST API（Agent→Session→Environment） |
| エンジン | **Claude Code と同じハーネス** | Anthropic ホストのオーケストレーション |
| エージェントの作業対象 | 自分のファイルシステム・サービス | セッションごとの managed サンドボックス |
| セッション状態 | ローカルの JSONL | Anthropic ホストのイベントログ |
| OpenAI Agents SDK の対応物 | **✅ 直接の対応物**（ローカルSDK、SDKがループを回す） | ✗ カテゴリが違う（サーバーホスト型） |

> **重要**: [OpenAI Agents SDK](../openai/11_OpenAI_Agents_SDK.md) の直接の対応物は **Claude Agent SDK** の方。どちらも「SDK がローカルでループを回す」ライブラリ。Managed Agents は「Anthropic がループもサンドボックスも持つ」別カテゴリ。

アーキテクチャ・設計の概念は [01_Agentic_Architecture.md](01_Agentic_Architecture.md) の Section 11 参照。

---
---

# Part A. Claude Agent SDK（ローカル / 自ホスト）

「Claude Code をライブラリとして使う」もの。Claude Code を支える**エージェントループ・組み込みツール・コンテキスト管理**をそのまま Python / TypeScript から呼べる。自分のプロセス内で動き、自分のファイルシステムを直接触る。

## インストール

```bash
pip install claude-agent-sdk        # Python 3.10+
# npm install @anthropic-ai/claude-agent-sdk   # TypeScript（Claude Code バイナリを同梱）
```

## 認証

```bash
export ANTHROPIC_API_KEY=sk-ant-...
```

サードパーティ経由も環境変数で切り替え可能（`claude.ai` ログインは不可、API キー方式のみ）:

- Amazon Bedrock: `CLAUDE_CODE_USE_BEDROCK=1`
- Claude Platform on AWS: `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` + `ANTHROPIC_AWS_WORKSPACE_ID`
- Google Vertex: `CLAUDE_CODE_USE_VERTEX=1`
- Microsoft Foundry: `CLAUDE_CODE_USE_FOUNDRY=1`

---

## 基本：`query()`（ワンショット）

`query()` は非同期イテレータを返す。デフォルトで新規セッションを作る。**手動ツールループは不要**——Claude が読み書き・実行を自律的に回す。

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    async for message in query(
        prompt="auth.py のバグを見つけて直して",
        options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
    ):
        # 最終結果は ResultMessage.result に入る
        if hasattr(message, "result"):
            print(message.result)

asyncio.run(main())
```

---

## マルチターン：`ClaudeSDKClient`

会話の継続（コンテキスト保持）が必要なときは `ClaudeSDKClient`。同一セッションで文脈が引き継がれる。

```python
from claude_agent_sdk import ClaudeSDKClient, AssistantMessage, TextBlock

async def main():
    async with ClaudeSDKClient() as client:
        await client.query("フランスの首都は？")
        async for message in client.receive_response():
            if isinstance(message, AssistantMessage):
                for block in message.content:
                    if isinstance(block, TextBlock):
                        print(block.text)

        # フォローアップ：前のやり取りを覚えている（"その都市" = パリ）
        await client.query("その都市の人口は？")
        async for message in client.receive_response():
            ...
```

主なメソッド: `query()` / `receive_response()` / `interrupt()`（実行中断）/ `set_permission_mode()` / `set_model()` / `disconnect()`。

---

## 設定：`ClaudeAgentOptions` 主要フィールド

| フィールド                                               | 用途                                                                                    |
| --------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `system_prompt`                                     | システムプロンプト。文字列 or プリセット `{"type": "preset", "preset": "claude_code", "append": "..."}` |
| `allowed_tools` / `disallowed_tools`                | 事前承認するツール / ブロックするツール（`"Bash(rm *)"` のようなパターン可）                                       |
| `tools`                                             | 使えるツールの集合。プリセット `{"type": "preset", "preset": "claude_code"}` も可                      |
| `permission_mode`                                   | `default` / `acceptEdits` / `plan` / `dontAsk` / `bypassPermissions`                  |
| `can_use_tool`                                      | ツール実行の可否をコールバックで判定（後述）                                                                |
| `mcp_servers`                                       | MCP サーバー定義（stdio / sse / in-process）                                                  |
| `agents`                                            | サブエージェント定義（`AgentDefinition`）                                                         |
| `hooks`                                             | ライフサイクルフック                                                                            |
| `skills`                                            | 有効化する Agent Skills（`"all"` / 名前リスト / `[]`）                                            |
| `setting_sources`                                   | `.claude/` 設定の読み込み元（`user` / `project` / `local`）                                     |
| `cwd` / `add_dirs`                                  | 作業ディレクトリ / 追加アクセス許可ディレクトリ                                                             |
| `model` / `fallback_model`                          | モデル（`"sonnet"` / `"opus"` 等のエイリアス、or `claude-opus-4-8`）                               |
| `thinking` / `effort`                               | 思考設定。`{"type": "adaptive"}` + `effort="high"`（`low`〜`max`, `xhigh`）を推奨                |
| `resume` / `fork_session` / `continue_conversation` | セッション再開 / 分岐 / 継続                                                                     |
| `max_turns` / `max_budget_usd`                      | ターン数上限 / コスト上限                                                                        |

> **思考設定の注意**: 現行モデル（Opus 4.6+ / Sonnet 4.6）は adaptive thinking + `effort` が推奨。固定 `budget_tokens` は旧モデル向けのレガシー。

---

## 組み込みツール

`allowed_tools` に名前を並べるだけで即使える（自前でツール実行を実装する必要なし）。

| ツール | 内容 |
|---|---|
| `Read` / `Write` / `Edit` | ファイル読み / 新規作成 / 精密編集 |
| `Bash` | シェルコマンド・スクリプト・git |
| `Glob` / `Grep` | パターンでファイル検索 / 正規表現で中身検索 |
| `WebSearch` / `WebFetch` | Web 検索 / ページ取得 |
| `AskUserQuestion` | 選択肢付きでユーザーに確認 |
| `Agent` | サブエージェント呼び出し（`agents` を使うなら `allowed_tools` に含める） |

---

## カスタムツール（`@tool` + in-process MCP）

Python 関数を `@tool` でツール化し、`create_sdk_mcp_server` で**プロセス内 MCP サーバー**として束ねる。OpenAI Agents SDK の `@function_tool` に相当。

```python
from claude_agent_sdk import tool, create_sdk_mcp_server, ClaudeAgentOptions

@tool("add", "2 数を加算", {"a": float, "b": float})
async def add(args):
    return {"content": [{"type": "text", "text": f"Sum: {args['a'] + args['b']}"}]}

calculator = create_sdk_mcp_server(name="calculator", version="1.0.0", tools=[add])

options = ClaudeAgentOptions(
    mcp_servers={"calc": calculator},
    allowed_tools=["mcp__calc__add"],  # 命名は mcp__<server>__<tool>
)
```

---

## パーミッション

3 段階で制御できる。

1. **`allowed_tools` / `disallowed_tools`**: 静的な許可/拒否リスト。
2. **`permission_mode`**: `acceptEdits`（編集自動承認）、`plan`（探索のみ・編集不可）、`dontAsk`（未承認は全拒否）、`bypassPermissions`（チェックを飛ばす）。
3. **`can_use_tool` コールバック**: 実行時に動的判定。入力の書き換えもできる。

```python
from claude_agent_sdk import PermissionResultAllow, PermissionResultDeny

async def guard(tool_name, input_data, context):
    if tool_name == "Write" and input_data.get("file_path", "").startswith("/etc/"):
        return PermissionResultDeny(message="system dir への書き込み禁止", interrupt=True)
    return PermissionResultAllow(updated_input=input_data)

options = ClaudeAgentOptions(can_use_tool=guard)
```

---

## サブエージェント

`AgentDefinition` で専門エージェントを定義し、メインが `Agent` ツール経由で委譲する。OpenAI Agents SDK の `handoffs` に相当（ただし委譲元が主導）。

```python
from claude_agent_sdk import query, ClaudeAgentOptions, AgentDefinition

options = ClaudeAgentOptions(
    allowed_tools=["Read", "Glob", "Grep", "Agent"],  # Agent を忘れず含める
    agents={
        "code-reviewer": AgentDefinition(
            description="コード品質・セキュリティのレビュー専門",
            prompt="コード品質を分析し改善案を出す。",
            tools=["Read", "Glob", "Grep"],
        )
    },
)
```

サブエージェント文脈のメッセージには `parent_tool_use_id` が付き、どの委譲に属すか追える。

---

## フック

エージェントのライフサイクル要所でコールバックを走らせる（検証・ログ・ブロック・変換）。

**種類**: `PreToolUse` / `PostToolUse` / `Stop` / `SessionStart` / `SessionEnd` / `UserPromptSubmit` ほか。

```python
from claude_agent_sdk import ClaudeAgentOptions, HookMatcher
from datetime import datetime

async def log_change(input_data, tool_use_id, context):
    fp = input_data.get("tool_input", {}).get("file_path", "unknown")
    with open("./audit.log", "a") as f:
        f.write(f"{datetime.now()}: modified {fp}\n")
    return {}

options = ClaudeAgentOptions(
    permission_mode="acceptEdits",
    hooks={"PostToolUse": [HookMatcher(matcher="Edit|Write", hooks=[log_change])]},
)
```

---

## MCP サーバー接続

外部システム（DB・ブラウザ・API 等）に MCP で接続。

```python
options = ClaudeAgentOptions(
    mcp_servers={
        "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]},  # stdio
        # "web": {"type": "sse", "url": "https://api.example.com/mcp"},         # sse
    }
)
# mcp_servers=".mcp.json" でファイルからロードも可
```

---

## セッション（再開 / 分岐）

読んだファイル・分析・会話履歴を保持し、後から `resume` で再開、`fork_session` で分岐できる。状態はローカルの JSONL。

```python
from claude_agent_sdk import query, ClaudeAgentOptions, SystemMessage, ResultMessage

session_id = None
async for message in query(prompt="認証モジュールを読んで",
                           options=ClaudeAgentOptions(allowed_tools=["Read", "Glob"])):
    if isinstance(message, SystemMessage) and message.subtype == "init":
        session_id = message.data["session_id"]

async for message in query(prompt="それを呼んでる箇所を全部探して",
                           options=ClaudeAgentOptions(resume=session_id)):
    if isinstance(message, ResultMessage):
        print(message.result)
```

---

## `.claude/` 設定と `setting_sources`（重要）

Claude Agent SDK は Claude Code の**ファイルシステムベース設定**をそのまま読める。読み込み元は `setting_sources` で制御する。

| 機能 | 内容 | 置き場所 |
|---|---|---|
| **Skills** | 自律起動 or `/name` 起動の専門能力 | `.claude/skills/*/SKILL.md` |
| **Commands** | カスタムスラッシュコマンド（レガシー形式） | `.claude/commands/*.md` |
| **Memory** | プロジェクト文脈・指示 | `CLAUDE.md` or `.claude/CLAUDE.md` |
| **Plugins** | Skills / agents / hooks / MCP をまとめて拡張 | `plugins` オプションで指定 |

`setting_sources` の値: `user`（`~/.claude/`）/ `project`（リポジトリの `.claude/`）/ `local`。

```python
options = ClaudeAgentOptions(setting_sources=["user", "project"])  # 明示指定
# setting_sources=[] にすると .claude/ 設定（Skills・CLAUDE.md・commands）は一切ロードされない
```

> **落とし穴**: `setting_sources` を**明示的に指定したのに `user`/`project` を含め忘れる**と、Skills も CLAUDE.md も commands もロードされない。Skills / CLAUDE.md を使うなら必ず `user` か `project` を入れる。

---

## Agent Skills（`.claude/skills/`）

Skills は `SKILL.md`（YAML frontmatter + Markdown）を含むフォルダ。`description` が「いつ Claude が発動するか」を決める。**SDK では Skills をプログラムから登録するAPIはなく、必ずファイルシステム上に置く**（サブエージェントとの違い）。

```
.claude/skills/processing-pdfs/
└── SKILL.md
```

有効化は `skills` オプション:

```python
options = ClaudeAgentOptions(
    cwd="/path/to/project",              # .claude/skills/ を含む or その親
    setting_sources=["user", "project"], # ← これが無いと Skills はロードされない
    skills="all",                        # or ["pdf", "docx"]、無効化は []
    allowed_tools=["Read", "Write", "Bash"],
)
```

- `skills` 省略時: 発見された Skills は有効、`Skill` ツールも自動で使える（CLI と同じ挙動）。
- `skills` を明示指定すると `Skill` ツールが自動で `allowed_tools` に追加される。ただし `tools` を明示リストで渡すなら `"Skill"` を自分で含める。
- プラグイン提供の Skill は `plugin:skill` 形式で指定。
- `skills` は**コンテキストフィルタであってサンドボックスではない**——リスト外の Skill はモデルから隠れるが、ファイル自体は Read/Bash から読める。
- SKILL.md の `allowed-tools` frontmatter は **CLI 専用**。SDK では効かないので `allowed_tools` オプションで制御する。

---

## Client SDK（生 Messages API）との違い

Client SDK = `anthropic` パッケージ（`client.messages.create` を直接叩く生 API）。実装パターンは [06_API_Implementation.md](06_API_Implementation.md) 参照。

| | Client SDK（`anthropic`） | Agent SDK（`claude-agent-sdk`） |
|---|---|---|
| ツールループ | **自分で実装**（`while stop_reason == "tool_use"`） | Claude が自律的に処理 |
| 組み込みツール | 無し（自前） | Read/Write/Bash/Grep 等が最初から |
| 用途 | 単発呼び出し・細かい制御 | ファイルを触るエージェント |

> **3 段の位置づけ**: 生 Messages API（[06](06_API_Implementation.md)、自分でループ）→ Claude Agent SDK（Part A、ローカルでループ自動）→ Managed Agents（Part B、サーバーでループ自動）。下ほど自前実装が減る。

---
---

# Part B. Managed Agents（サーバーホスト型）

Anthropic がエージェントループ**とサンドボックスの両方**をホストする REST API。`anthropic` パッケージの beta 機能（`client.beta.*`、beta header は SDK が自動付与）。自前でサンドボックス・セッション基盤を運用せずに本番エージェントを動かしたいとき、長時間・非同期セッションに向く。

## 基本の流れ（Agent は一度だけ、Session は毎回）

```
Agent（設定を一度だけ作成・IDを保存）→ Environment（一度だけ）→ Session（実行のたびに）
```

> **鉄則**: `model` / `system` / `tools` は **Agent 側**のフィールド。Session には載らない（Session は Agent を ID で参照するだけ）。`agents.create()` をリクエストの度に呼ばない——一度作って ID を保存し使い回す（設定変更は `agents.update()` で新バージョンを作る）。

## Agent の作成（セットアップ時に一度だけ）

```python
from anthropic import Anthropic
client = Anthropic()

agent = client.beta.agents.create(
    name="Research Assistant",
    model="claude-opus-4-8",
    system="You are a helpful research assistant.",
    tools=[{"type": "agent_toolset_20260401"}],  # bash/read/write/web_search 等を一括有効化
)
# agent.id と agent.version を保存して使い回す
```

## Environment の作成（セットアップ時に一度だけ）

```python
environment = client.beta.environments.create(
    name="my-env",
    config={"type": "cloud", "networking": {"type": "unrestricted"}},  # or "limited"
)
```

## Session を作って実行

```python
session = client.beta.sessions.create(
    agent=agent.id,                  # 最新バージョンなら ID 文字列だけでOK
    environment_id=environment.id,
)

# ストリームを先に開いてからメッセージを送るのがベストプラクティス
with client.beta.sessions.events.stream(session_id=session.id) as stream:
    client.beta.sessions.events.send(
        session_id=session.id,
        events=[{"type": "user.message",
                 "content": [{"type": "text", "text": "最新モデルを調べてまとめて"}]}],
    )
    for event in stream:
        if event.type == "agent.message":
            for block in event.content:
                if block.type == "text":
                    print(block.text, end="", flush=True)
        elif event.type == "session.status_idle":
            # requires_action 以外の stop_reason なら完了
            if event.stop_reason.type != "requires_action":
                break
        elif event.type == "session.status_terminated":
            break
```

## カスタムツール（クライアントサイド実行）

Agent が独自ツールを呼び、**こちら側で実行して結果を返す**パターン。認証情報をサンドボックスに置かずに外部 API を叩ける（Agent SDK の `@tool` と役割は近いが、実行はイベント往復になる）。

```python
agent = client.beta.agents.create(
    name="Data Agent", model="claude-opus-4-8",
    tools=[
        {"type": "agent_toolset_20260401"},
        {"type": "custom", "name": "get_stock_price",
         "description": "株価を取得",
         "input_schema": {"type": "object",
                          "properties": {"symbol": {"type": "string"}},
                          "required": ["symbol"]}},
    ],
)

# セッション実行中、custom tool 呼び出しを処理して結果を返す
for event in stream:
    if event.type == "agent.custom_tool_use":
        result = fetch_stock_price(event.input["symbol"])  # 自前関数
        client.beta.sessions.events.send(
            session_id=session.id,
            events=[{"type": "user.custom_tool_result",
                     "custom_tool_use_id": event.id,
                     "content": [{"type": "text", "text": str(result)}]}],
        )
```

## イベント/ステアリングのポイント

- **ストリームを先に開いてから送信**する（SSE はリプレイ無し。送信が先だと初期イベントを取りこぼす）。
- 切断時は `events.list()` で履歴を取り、event ID で重複排除してから live に追従。
- `session.status_idle` だけで break しない——`stop_reason.type == "requires_action"`（ツール確認待ち等）なら continue、それ以外（`end_turn` 等）で break。
- 認証は **Vault**（`vault_ids`）に置き、Agent の `mcp_servers` には URL のみ（auth なし）。GitHub リポは `resources` でマウント。

## 使い分け（vs 直接 Messages API）

| | Messages API（手動ループ） | Managed Agents |
|---|---|---|
| ループ管理 | 自前 | Anthropic が管理 |
| サンドボックス | 自前 | 自動プロビジョニング |
| ファイル/リポジトリ | 自前でマウント | `resources` で宣言 |
| 適用場面 | カスタム要件・細かい制御 | すばやく本番運用・長時間/非同期 |

---
---

## Claude Agent SDK vs Managed Agents（公式比較）

| | Agent SDK | Managed Agents |
|---|---|---|
| **実行場所** | 自分のプロセス・自分のインフラ | Anthropic 管理インフラ |
| **インターフェース** | Python / TypeScript ライブラリ | REST API |
| **作業対象** | 自分のインフラ上のファイル | セッションごとの managed サンドボックス |
| **セッション状態** | 自分のファイルシステム上の JSONL | Anthropic ホストのイベントログ |
| **カスタムツール** | プロセス内の Python/TS 関数 | Claude がトリガー→こちらで実行して返す |
| **向いているケース** | ローカル試作、自分のファイル/サービスを直接触る | サンドボックス/セッション基盤を運用せず本番、長時間・非同期 |

> よくある流れ: **Agent SDK でローカル試作 → 本番は Managed Agents** に移す。

## Claude Agent SDK vs OpenAI Agents SDK（本来の対応比較）

| 比較軸 | Claude Agent SDK (`claude-agent-sdk`) | OpenAI Agents SDK (`openai-agents`) |
|---|---|---|
| **ホスティング** | 自ホスト（SDK がループを管理） | 自ホスト（SDK がループを管理） |
| **ベース** | Claude Code と同じハーネス（組み込みツール込み） | 汎用エージェントフレームワーク |
| **ワンショット/継続** | `query()` / `ClaudeSDKClient` | `Runner.run_sync()` / `Runner.run()` |
| **組み込みツール** | Read/Write/Bash/Grep 等が最初から | 基本は自分で定義（一部 hosted tool） |
| **カスタムツール** | `@tool` + `create_sdk_mcp_server` | `@function_tool` デコレータ |
| **マルチエージェント** | `agents`（`AgentDefinition`）+ `Agent` ツール | `handoffs` で宣言的に |
| **ガードレール/権限** | `permission_mode` / `can_use_tool` / hooks | `@input_guardrail` / `@output_guardrail` |
| **ファイル系設定** | `.claude/`（Skills・CLAUDE.md・commands） | 無し（コードで完結） |
| **トレーシング** | hooks / セッション JSONL | 標準搭載（OpenAI Dashboard） |

→ OpenAI 側の詳細: [../openai/11_OpenAI_Agents_SDK.md](../openai/11_OpenAI_Agents_SDK.md)

---

## 参考リンク

**Claude Agent SDK**
- [Agent SDK Overview](https://code.claude.com/docs/en/agent-sdk/overview)
- [Python SDK Reference](https://code.claude.com/docs/en/agent-sdk/python) / [TypeScript SDK Reference](https://code.claude.com/docs/en/agent-sdk/typescript)
- [Agent Skills in the SDK](https://code.claude.com/docs/en/agent-sdk/skills)
- [Building Agents with the Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk)
- [claude-agent-sdk-demos（サンプル）](https://github.com/anthropics/claude-agent-sdk-demos)

**Managed Agents**
- [Managed Agents Overview](https://platform.claude.com/docs/en/managed-agents/overview)
- [New capabilities for building agents on the Anthropic API](https://www.anthropic.com/news/agent-capabilities-api)
