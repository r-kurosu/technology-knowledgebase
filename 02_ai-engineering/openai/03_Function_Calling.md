# OpenAI Function Calling / Tool Use

---

## 1. 基本概念

モデルが「関数を呼び出す」のではなく、**「どの関数をどの引数で呼ぶべきか」を出力**する。  
実際の実行はアプリ側で行う。

**Claudeとの用語対応**:

| OpenAI | Anthropic/Claude |
|---|---|
| Function Calling | Tool Use |
| `tools` | `tools` |
| `tool_choice` | `tool_choice` |
| `tool_calls` | `tool_use` (content block) |
| `tool` role | `tool` role |

---

## 2. 基本的な実装パターン

```python
from openai import OpenAI
import json

client = OpenAI()

# 1. ツール定義
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "指定した都市の現在の天気を取得する",
            "parameters": {
                "type": "object",
                "properties": {
                    "city": {
                        "type": "string",
                        "description": "都市名（例: Tokyo）",
                    },
                    "unit": {
                        "type": "string",
                        "enum": ["celsius", "fahrenheit"],
                        "description": "温度単位",
                    },
                },
                "required": ["city"],
                "additionalProperties": False,
            },
            "strict": True,
        },
    }
]

# 2. 初回リクエスト
messages = [{"role": "user", "content": "東京の天気を教えて"}]

response = client.chat.completions.create(
    model="gpt-5.4",
    messages=messages,
    tools=tools,
)

# 3. ツール呼び出しの処理
message = response.choices[0].message

if message.tool_calls:
    tool_call = message.tool_calls[0]
    args = json.loads(tool_call.function.arguments)
    
    # 実際の関数を実行
    result = get_weather(**args)  # 自前の関数
    
    # 4. 結果をメッセージに追加して再リクエスト
    messages.append(message)  # assistantのtool_callsを含むメッセージ
    messages.append({
        "role": "tool",
        "tool_call_id": tool_call.id,
        "content": json.dumps(result),
    })
    
    final_response = client.chat.completions.create(
        model="gpt-5.4",
        messages=messages,
        tools=tools,
    )
    print(final_response.choices[0].message.content)
```

---

## 3. tool_choice パラメータ

| 値 | 動作 |
|---|---|
| `"auto"` | モデルが判断（デフォルト） |
| `"required"` | 必ずいずれかのツールを使う |
| `"none"` | ツール使用禁止 |
| `{"type": "function", "function": {"name": "..."}}` | 特定の関数を強制 |

**Claudeとの対応**:
- `"auto"` → `tool_choice: {type: "auto"}`
- `"required"` → `tool_choice: {type: "any"}`
- `"none"` → `tool_choice: {type: "none"}`
- 特定指定 → `tool_choice: {type: "tool", name: "..."}`

---

## 4. 並列ツール呼び出し（Parallel Tool Calls）

GPT-4oは複数のツールを**同時に呼び出す**ことができる。

```python
# 応答に複数のtool_callsが含まれる場合
if message.tool_calls:
    tool_results = []
    
    for tool_call in message.tool_calls:  # 複数処理
        args = json.loads(tool_call.function.arguments)
        result = dispatch_tool(tool_call.function.name, args)
        
        tool_results.append({
            "role": "tool",
            "tool_call_id": tool_call.id,
            "content": json.dumps(result),
        })
    
    messages.append(message)
    messages.extend(tool_results)
```

**Claudeとの違い**: Claudeも並列ツール呼び出しをサポートするが、  
ループ設計は同様。OpenAI SDKは`tool_calls`が**リスト**になる。

---

## 5. Strict Mode

`strict: true` を設定するとJSON Schemaに完全準拠した引数が保証される。

```python
"function": {
    "name": "create_task",
    "strict": True,  # ← これを追加
    "parameters": {
        "type": "object",
        "properties": {...},
        "required": [...],
        "additionalProperties": False,  # strict時は必須
    },
}
```

**制約**:
- `additionalProperties: false` 必須
- 全プロパティを `required` に含める必要あり
- 一部のJSON Schema機能は非対応

---

## 6. ツール設計のベストプラクティス

<!-- 一言説明、30秒説明、採用理由を自分で書く -->

## 7. エラーハンドリング

<!-- 判断問題への回答、疑問、理解度（A/B/C）を残す -->
