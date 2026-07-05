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

<!-- 一言説明、30秒説明、採用理由を自分で書く -->

## 7. よく使うパターンまとめ

<!-- 判断問題への回答、疑問、理解度（A/B/C）を残す -->
