# OpenAI 構造化出力 (Structured Output)

---

## 1. 3つの方式

| 方式 | パラメータ | 信頼性 | 推奨度 |
|---|---|---|---|
| **Structured Outputs** | `response_format: { type: "json_schema", json_schema: {...}, strict: true }` | 最高（100%保証） | ★★★ |
| **JSON mode** | `response_format: { type: "json_object" }` | 高（JSON保証、スキーマ非保証） | ★★☆ |
| プロンプトベース | "output as JSON" | 低 | ★☆☆ |

---

## 2. Structured Outputs（推奨）

2024年8月に追加。JSON Schemaに**完全準拠した出力を保証**する。

```python
from openai import OpenAI
import json

client = OpenAI()

response = client.chat.completions.create(
    model="gpt-5.4",  # Structured Outputs対応モデル
    messages=[
        {"role": "system", "content": "ユーザー情報を抽出する"},
        {"role": "user", "content": "田中太郎、30歳、東京在住"},
    ],
    response_format={
        "type": "json_schema",
        "json_schema": {
            "name": "UserInfo",
            "strict": True,
            "schema": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "age": {"type": "integer"},
                    "city": {"type": ["string", "null"]},  # nullable
                },
                "required": ["name", "age", "city"],
                "additionalProperties": False,  # 必須
            },
        },
    },
)

data = json.loads(response.choices[0].message.content)
```

### `strict: true` の制約（重要）
- `additionalProperties: false` を全オブジェクトに明示する必要あり
- `required` に全プロパティを含める必要あり
- サポートされないJSON Schema機能あり（`anyOf`, `$ref` は限定的にサポート）

### PydanticでのSchemaパース（SDK対応）

```python
from pydantic import BaseModel
from openai import OpenAI

class UserInfo(BaseModel):
    name: str
    age: int
    city: str | None

client = OpenAI()
response = client.beta.chat.completions.parse(
    model="gpt-5.4",
    messages=[...],
    response_format=UserInfo,
)
user = response.choices[0].message.parsed  # UserInfoのインスタンス
```

**Claudeとの対応**: AnthropicはPydantic + `output_config.format`。  
どちらもPydanticを使えるが、APIの呼び出し方が異なる。

---

## 3. JSON mode

スキーマを指定せずにJSON形式の出力を保証する方法。

```python
response = client.chat.completions.create(
    model="gpt-5.4",
    messages=[
        {"role": "system", "content": "必ずJSON形式で返答してください"},
        {"role": "user", "content": "東京の天気を教えて"},
    ],
    response_format={"type": "json_object"},
)
```

**注意点**:
- システムプロンプトかユーザーメッセージで「JSONで返す」と明示しないと警告が出る
- スキーマは保証されない（フィールド名や型が変わりうる）
- Structured Outputsが使えるなら非推奨

---

## 4. Refusals（拒否応答）の扱い

Structured Outputs使用時にモデルが拒否した場合の対処。

```python
message = response.choices[0].message

if message.refusal:
    # モデルが応答を拒否した
    print(f"Refused: {message.refusal}")
else:
    data = message.parsed
```

---

## 5. Function Callingでの構造化出力

Function Callingも構造化出力の一形態。スキーマをtoolの`parameters`として定義。

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "extract_user",
            "description": "テキストからユーザー情報を抽出",
            "strict": True,  # Strict modeを有効化
            "parameters": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "age": {"type": "integer"},
                },
                "required": ["name", "age"],
                "additionalProperties": False,
            },
        },
    }
]
```

---

## 6. バリデーション・リトライパターン

```python
import json
from pydantic import BaseModel, ValidationError

def extract_with_retry(text: str, max_retries: int = 3):
    messages = [
        {"role": "system", "content": "ユーザー情報をJSONで抽出"},
        {"role": "user", "content": text},
    ]
    
    for attempt in range(max_retries):
        response = client.chat.completions.create(
            model="gpt-5.4",
            messages=messages,
            response_format=UserInfo,  # Pydanticモデル使用
        )
        
        try:
            return response.choices[0].message.parsed
        except ValidationError as e:
            # 具体的なエラー情報を添付してリトライ
            error_detail = str(e)
            messages.append({
                "role": "assistant",
                "content": response.choices[0].message.content
            })
            messages.append({
                "role": "user",
                "content": f"Validation failed: {error_detail}\nPlease fix and retry."
            })
    
    raise ValueError("Max retries exceeded")
```

**Claudeと共通**: リトライ時は**具体的なエラー詳細**を含めること。汎用メッセージはNG。

---

## 参考リンク

- [Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs)
- [JSON mode](https://platform.openai.com/docs/guides/text-generation#json-mode)
