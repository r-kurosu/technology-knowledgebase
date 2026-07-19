# Claude API 実装パターン集

Anthropic Python SDK を使った主要パターンのリファレンス。  
SDK: `pip install anthropic`  
公式ドキュメント: https://docs.anthropic.com/en/docs/

---

## 1. messages API の基本

```python
import anthropic

client = anthropic.Anthropic(api_key="sk-ant-...")  # 省略時は環境変数 ANTHROPIC_API_KEY を使用

response = client.messages.create(
    model="claude-sonnet-4-6",          # 現行: claude-fable-5(最上位) / claude-opus-4-8(推奨既定) / claude-opus-4-7 / claude-sonnet-4-6 / claude-haiku-4-5
    max_tokens=1024,                     # 必須。出力の最大トークン数
    system="あなたは親切なアシスタントです。",  # オプション。システムプロンプト
    messages=[
        {"role": "user", "content": "Pythonで素数判定する関数を書いて"}
    ]
)

# レスポンス構造
print(response.content[0].text)          # テキスト出力
print(response.stop_reason)              # "end_turn" | "tool_use" | "max_tokens" | "stop_sequence"
print(response.usage.input_tokens)       # 消費入力トークン数
print(response.usage.output_tokens)      # 消費出力トークン数
```

### レスポンスオブジェクトの主要フィールド

| フィールド | 説明 |
|-----------|------|
| `content` | ContentBlock のリスト（TextBlock / ToolUseBlock） |
| `stop_reason` | 生成停止の理由 |
| `usage.input_tokens` | 入力トークン数（キャッシュ未ヒット分） |
| `usage.output_tokens` | 出力トークン数 |
| `model` | 実際に使用されたモデル ID |

---

## 2. マルチターン会話

```python
import anthropic

client = anthropic.Anthropic()
messages = []

def chat(user_input: str) -> str:
    messages.append({"role": "user", "content": user_input})
    
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        messages=messages
    )
    
    assistant_message = response.content[0].text
    # アシスタントの返答を履歴に追加（次のターンのコンテキストとして使用）
    messages.append({"role": "assistant", "content": assistant_message})
    return assistant_message

print(chat("Pythonの基礎を教えて"))
print(chat("変数宣言の例を見せて"))  # 前の会話コンテキストが維持される
```

**ポイント**: `messages` 配列は `user` と `assistant` が交互になる必要がある。  
最後は `user` ターンで終わること。

---

## 3. ツール使用（tool_use）

### 3-1. ツール定義とリクエスト

```python
import anthropic
import json

client = anthropic.Anthropic()

# ツール定義
tools = [
    {
        "name": "get_weather",
        "description": "指定した都市の現在の天気を取得する。都市名は日本語または英語で指定可能。",
        "input_schema": {
            "type": "object",
            "properties": {
                "city": {
                    "type": "string",
                    "description": "都市名（例: '東京', 'Tokyo'）"
                },
                "unit": {
                    "type": "string",
                    "enum": ["celsius", "fahrenheit"],
                    "description": "温度単位"
                }
            },
            "required": ["city"]
        }
    }
]

response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "東京の天気を教えて"}]
)

print(response.stop_reason)  # "tool_use" になる
```

### 3-2. エージェントループ（tool_use の処理）

```python
def run_tool(tool_name: str, tool_input: dict) -> str:
    """ツールの実際の実行（外部API等）"""
    if tool_name == "get_weather":
        # 実際のAPIコールや処理
        return json.dumps({"temperature": 22, "condition": "晴れ", "city": tool_input["city"]})
    raise ValueError(f"Unknown tool: {tool_name}")


def agent_loop(user_message: str) -> str:
    messages = [{"role": "user", "content": user_message}]
    
    while True:
        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1024,
            tools=tools,
            messages=messages
        )
        
        # 完了判定は必ず stop_reason で行う（content[0].type では不可）
        if response.stop_reason == "end_turn":
            # テキストブロックを抽出して返す
            for block in response.content:
                if block.type == "text":
                    return block.text
        
        if response.stop_reason == "tool_use":
            # アシスタントの返答（tool_use ブロック含む）を履歴に追加
            messages.append({"role": "assistant", "content": response.content})
            
            # 全ての tool_use ブロックを処理
            tool_results = []
            for block in response.content:
                if block.type == "tool_use":
                    result = run_tool(block.name, block.input)
                    tool_results.append({
                        "type": "tool_result",
                        "tool_use_id": block.id,   # tool_use の id と一致させる
                        "content": result
                    })
            
            # ツール結果をユーザーターンとして追加
            messages.append({"role": "user", "content": tool_results})
            # ループ継続 → Claudeがツール結果を元に回答を生成

result = agent_loop("東京の天気を教えて")
print(result)
```

**重要な落とし穴**:
- `content[0].type == "text"` でループ終了を判定してはいけない。Claudeはテキストと tool_use を同時に返すことがある
- `stop_reason == "tool_use"` でループ継続、`"end_turn"` で終了が正しいパターン（エージェントループの核心）

### 3-3. Tool Runner（自動ツールループ・beta）

3-2 の手動ループは SDK の **Tool Runner** で置き換えられる（Python SDK の beta 機能）。
`@beta_tool` デコレータで関数をツール化すると、スキーマは型ヒント＋docstring から自動生成され、
「API 呼び出し → ツール実行 → 結果返却 → ループ」を SDK が回してくれる。
**カスタムツールだけのエージェントなら、手動ループよりこちらが公式推奨**。

```python
import anthropic
from anthropic import beta_tool

client = anthropic.Anthropic()

@beta_tool
def get_weather(city: str) -> str:
    """指定した都市の現在の天気を取得する。

    Args:
        city: 都市名（例: 東京）
    """
    return '{"temperature": 22, "condition": "晴れ"}'  # 実際は外部API呼び出し

runner = client.beta.messages.tool_runner(
    model="claude-opus-4-8",
    max_tokens=16000,
    tools=[get_weather],
    messages=[{"role": "user", "content": "東京の天気を教えて"}],
)

# 1イテレーション = 1アシスタントターン。ツール呼び出しが尽きたら自動終了
for message in runner:
    print(message)
# ワンショットで最終メッセージだけ欲しいなら runner.until_done()
```

**手動ループとの使い分け**:

| | 手動ループ（3-2） | Tool Runner |
|---|---|---|
| ループ実装 | 自前（`while stop_reason == "tool_use"`） | SDK が管理 |
| 承認ゲート・介入 | ループ内に自由に書ける | イテレーション毎にメッセージが yield されるので介入可能（ツール関数内でゲート、`generate_tool_call_response()` で結果を検査・改変） |
| beta 依存 | なし | あり（beta 機能） |
| 選ぶ場面 | ループ全体を完全に自分で持ちたい・beta を避けたい | それ以外のカスタムツールエージェント全般 |

**注意点**:
- 非同期は `@beta_async_tool` + `AsyncAnthropic`
- `stream=True` でストリーミングにも対応、`max_iterations` でループ上限を設定できる
- **サーバーサイドツール（web_search 等）混在時の `pause_turn` は自動再開されない**——最後のメッセージの `stop_reason` を確認し、必要なら paused ターンを積んでランナーを再作成する
- MCP ツールを Tool Runner に渡す変換ヘルパーもある（`anthropic.lib.tools.mcp` の `mcp_tool` / `async_mcp_tool`、`pip install anthropic[mcp]`）

> **位置づけ**: Anthropic 公式の「エージェント構築 4 アプローチ」では、①手動ループ ②Tool Runner（どちらも本ノート）③Managed Agents ④Claude Agent SDK（③④は [07](07_Claude_Agent_SDK.md)）という整理。Tool Runner は「ループだけ SDK に任せ、ツールは全部自前」で、組み込みツール（Read/Bash 等）は持たない点が Agent SDK と違う。

---

## 4. ストリーミング

### 4-1. 基本的なストリーミング

```python
import anthropic

client = anthropic.Anthropic()

# context manager を使ったストリーミング
with client.messages.stream(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    messages=[{"role": "user", "content": "長い記事を書いて"}]
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)  # トークンごとに出力

# 完了後に最終メッセージを取得
final_message = stream.get_final_message()
print(f"\n\nトークン数: {final_message.usage}")
```

### 4-2. イベントベースのストリーミング

```python
with client.messages.stream(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    messages=[{"role": "user", "content": "こんにちは"}]
) as stream:
    for event in stream:
        # イベントタイプ: message_start, content_block_start,
        #               content_block_delta, content_block_stop, message_stop
        if hasattr(event, 'type'):
            if event.type == 'content_block_delta':
                if hasattr(event.delta, 'text'):
                    print(event.delta.text, end="", flush=True)
```

---

## 5. プロンプトキャッシング

大きなシステムプロンプトや長い文書を繰り返し送る場合に最大90%のコスト削減。

### 5-1. システムプロンプトのキャッシュ

```python
import anthropic

client = anthropic.Anthropic()

# 長いシステムプロンプト（例：数千トークンのマニュアル）
long_system_prompt = "..." * 500  # 実際には長いテキスト

response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": long_system_prompt,
            "cache_control": {"type": "ephemeral"}  # キャッシュ対象に指定
        }
    ],
    messages=[{"role": "user", "content": "このドキュメントを要約して"}]
)

# キャッシュ効果の確認
usage = response.usage
print(f"キャッシュ作成トークン: {usage.cache_creation_input_tokens}")  # 初回: キャッシュ書き込み
print(f"キャッシュ読み取りトークン: {usage.cache_read_input_tokens}")  # 2回目以降: ここに数字が入る
print(f"通常入力トークン: {usage.input_tokens}")
```

### 5-2. messages 内のコンテンツをキャッシュ

```python
# 長い文書を繰り返し参照するパターン
long_document = "..." * 1000

response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": f"以下のドキュメントを参照して質問に答えてください:\n\n{long_document}",
                    "cache_control": {"type": "ephemeral"}   # 文書部分をキャッシュ
                },
                {
                    "type": "text",
                    "text": "第3章の主要ポイントは？"   # 質問部分はキャッシュしない
                }
            ]
        }
    ]
)
```

### キャッシュの動作

| 条件 | 挙動 |
|------|------|
| 初回リクエスト | キャッシュ書き込み（`cache_creation_input_tokens` に計上） |
| 2回目以降（TTL内） | キャッシュヒット（`cache_read_input_tokens` に計上、コスト約90%削減） |
| TTL経過後 | 再度書き込み |
| キャッシュ可能な最小トークン数 | claude-sonnet-4-6 / claude-fable-5: 2,048トークン、claude-opus-4-8/4.7/4.6・Haiku 4.5: 4,096トークン |

**配置のルール**: `cache_control` はプロンプトの**先頭側**（変化しない部分）に置く。末尾の変動する部分にキャッシュを指定しても効果が低い。

---

## 6. エラーハンドリング

```python
import anthropic
from anthropic import APIError, RateLimitError, APIConnectionError

client = anthropic.Anthropic()

try:
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        messages=[{"role": "user", "content": "こんにちは"}]
    )
except RateLimitError:
    print("レート制限: リトライが必要")
except APIConnectionError:
    print("接続エラー: ネットワーク確認")
except APIError as e:
    print(f"APIエラー: {e.status_code} - {e.message}")
```

---

## 7. よく使うパターンまとめ

| パターン | 用途 | ポイント |
|---------|------|---------|
| 基本 messages | 単発の質問・生成 | `stop_reason` で完了確認 |
| マルチターン | チャットボット | messages 配列を累積 |
| tool_use ループ | エージェント | `stop_reason == "tool_use"` でループ継続 |
| Tool Runner | カスタムツールエージェント（推奨） | `client.beta.messages.tool_runner()` + `@beta_tool` |
| ストリーミング | UXの改善 | `client.messages.stream()` |
| プロンプトキャッシング | コスト削減 | 変化しない部分に `cache_control` |

---

## 参考リンク

- [Messages API リファレンス](https://docs.anthropic.com/en/api/messages)
- [Tool Use 実装ガイド](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/implement-tool-use)
- [ストリーミング](https://docs.anthropic.com/en/api/messages-streaming)
- [プロンプトキャッシング](https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching)
- [Anthropic Python SDK (GitHub)](https://github.com/anthropics/anthropic-sdk-python)
