# Gemini 構造化出力（Structured Output）

---

## 1. 概要

Geminiで構造化出力を得る方法は2つある。

| 方法 | 用途 | 確実性 |
|---|---|---|
| `response_mime_type: "application/json"` | 簡易JSON出力（スキーマ保証なし） | 低〜中 |
| `response_schema`（JSON Schema） | スキーマ強制（型・構造を保証） | **高** |

**本番では `response_schema` を使うべき**。スキーマを指定しないJSONはパース失敗リスクがある。

---

## 2. response_schema の基本

```python
import google.generativeai as genai
from google.generativeai.types import GenerationConfig

model = genai.GenerativeModel("gemini-2.5-flash")

# スキーマ定義
schema = {
    "type": "object",
    "properties": {
        "company": {"type": "string"},
        "founded_year": {"type": "integer"},
        "products": {
            "type": "array",
            "items": {"type": "string"}
        },
        "is_public": {"type": "boolean"}
    },
    "required": ["company", "founded_year", "products"]
}

response = model.generate_content(
    "Googleについての情報をまとめて",
    generation_config=GenerationConfig(
        response_mime_type="application/json",
        response_schema=schema,
    ),
)

import json
data = json.loads(response.text)
print(data["company"])  # "Google"
```

---

## 3. Pydanticモデルを使う（推奨）

```python
from pydantic import BaseModel
from typing import List, Optional

class Product(BaseModel):
    name: str
    category: str
    price_usd: float

class CompanyInfo(BaseModel):
    company: str
    founded_year: int
    products: List[Product]
    is_public: bool
    description: Optional[str] = None

response = model.generate_content(
    "Appleについての情報をまとめて",
    generation_config=GenerationConfig(
        response_mime_type="application/json",
        response_schema=CompanyInfo,  # Pydanticモデルを直接渡せる
    ),
)

company = CompanyInfo.model_validate_json(response.text)
print(company.company)        # "Apple"
print(company.founded_year)   # 1976
```

---

## 4. 列挙型（Enum）

```python
from enum import Enum

class Sentiment(str, Enum):
    POSITIVE = "positive"
    NEGATIVE = "negative"
    NEUTRAL = "neutral"

class ReviewAnalysis(BaseModel):
    sentiment: Sentiment
    confidence: float  # 0.0〜1.0
    key_points: List[str]

response = model.generate_content(
    "レビュー: 「配送は早かったですが、商品の品質は期待以下でした」を分析して",
    generation_config=GenerationConfig(
        response_mime_type="application/json",
        response_schema=ReviewAnalysis,
    ),
)

analysis = ReviewAnalysis.model_validate_json(response.text)
print(analysis.sentiment)  # Sentiment.NEGATIVE
```

---

## 5. ネストしたスキーマ

```python
class Address(BaseModel):
    street: str
    city: str
    country: str

class Person(BaseModel):
    name: str
    age: int
    address: Address
    hobbies: List[str]

# Pydanticのネストはそのまま使える
```

---

## 6. 配列レスポンス（リスト抽出）

```python
from typing import List

class MenuItem(BaseModel):
    name: str
    price_jpy: int
    category: str

# 複数アイテムのリスト抽出
response = model.generate_content(
    f"以下のメニュー表からすべてのアイテムを抽出して:\n\n{menu_text}",
    generation_config=GenerationConfig(
        response_mime_type="application/json",
        response_schema=List[MenuItem],  # リスト型を直接指定
    ),
)

items = json.loads(response.text)  # list of dicts
```

---

## 7. Function Calling との使い分け

| | Structured Output | Function Calling |
|---|---|---|
| 用途 | **最終回答**をスキーマ準拠で返す | **中間ステップ**で外部ツール/データを呼ぶ |
| 外部実行 | なし | あり |
| 典型例 | データ抽出・分類・フォーム入力 | 検索・DB照会・API呼び出し |

```
[Structured Output] テキスト → モデル → スキーマ準拠JSON
[Function Calling]  テキスト → モデル → 関数呼び出し → 実行 → モデル → テキスト
```

---

## 8. 他プロバイダーとの比較

| 項目 | Gemini | OpenAI | Anthropic |
|---|---|---|---|
| スキーマ強制 | `response_schema` | `response_format.json_schema` (`strict: true`) | `output_config.format` |
| JSON mode（スキーマなし） | `response_mime_type: "application/json"` | `response_format: {type: "json_object"}` | なし |
| Pydantic連携 | ✅ 直接渡せる | ✅ `.parse()` メソッド | ✅ Pydantic対応 |
| 列挙型のEnum | ✅ | ✅ | ✅ |

---

## 参考リンク

- [Structured Output Guide](https://ai.google.dev/gemini-api/docs/structured-output)
- [JSON Schema Reference](https://json-schema.org/)
