# Gemini Thinking Mode（思考モード）

---

## 1. 概要

Gemini 3系では**内部推論（Thinking）**をAPIから制御できる。

| | Gemini 2.5 | Gemini 3 |
|---|---|---|
| 思考機能 | あり（一部モデルで `thinking` パラメータ） | **Dynamic Thinking（デフォルト有効）** |
| 制御パラメータ | `thinking_budget`（トークン数指定） | `thinking_level`（レベル指定） |
| デフォルト | off | **動的に自動調整** |

---

## 2. thinking_level パラメータ（Gemini 3）

```python
import google.generativeai as genai
from google.generativeai.types import GenerationConfig

model = genai.GenerativeModel("gemini-3-flash")

# 思考レベルの制御
response = model.generate_content(
    "複雑な数学の証明問題",
    generation_config=GenerationConfig(
        thinking_level="high"  # "minimal" / "low" / "medium" / "high"
    ),
)
```

| `thinking_level` | 内部推論の深さ | レイテンシ | コスト | 推奨用途 |
|---|---|---|---|---|
| `"minimal"` | ほぼなし | 最速 | 最小 | 単純な質問・翻訳・要約 |
| `"low"` | 浅い推論 | 速い | 小 | 標準的な質問回答 |
| `"medium"` | 中程度の推論 | 中 | 中 | コーディング・分析 |
| `"high"` | 深い推論 | 遅い | 大 | 複雑な推論・数学・戦略立案 |

> `"medium"` は Gemini 3.1 Pro で追加されたオプション。

---

## 3. Dynamic Thinking（Gemini 3 デフォルト）

Gemini 3はデフォルトでタスクの複雑さに応じて**自動的に思考レベルを調整**する。

```python
# 明示的な指定なし → モデルが自動で思考量を決定
response = model.generate_content("2+2は？")
# → minimal thinking（即答）

response = model.generate_content("RSA暗号の安全性を数学的に証明して")
# → high thinking（深い推論）
```

**メリット**: 単純なクエリでは速く・安く、複雑なクエリでは精度を上げる。  
**注意**: レイテンシ・コストが予測しにくい場合は明示的に `thinking_level` を指定。

---

## 4. Gemini 2.5 の Thinking Budget

2.5系では `thinking_budget`（トークン数）で思考量を制御。

```python
# Gemini 2.5系の思考制御
model = genai.GenerativeModel("gemini-2.5-pro")

response = model.generate_content(
    "この証明を検証して",
    generation_config=GenerationConfig(
        thinking_config={"thinking_budget": 8192}  # 最大思考トークン数
    ),
)
```

| `thinking_budget` | 目安 | 用途 |
|---|---|---|
| 0 | 思考なし | 単純なタスク |
| 1024〜4096 | 軽い思考 | 標準的なコーディング・分析 |
| 8192〜16384 | 中程度 | 複雑な問題 |
| 32768〜 | 深い思考 | 高難度の数学・研究 |

---

## 5. 思考内容の確認（Thought Summary）

```python
response = model.generate_content(
    "この数学の問題を解いて: ...",
    generation_config=GenerationConfig(thinking_level="high"),
)

# 思考過程のサマリーを取得（利用可能な場合）
for part in response.candidates[0].content.parts:
    if hasattr(part, 'thought') and part.thought:
        print("思考過程:", part.thought)
    else:
        print("最終回答:", part.text)
```

---

## 6. 他プロバイダーの推論モードとの比較

| | Gemini 3 | Claude（Extended Thinking） | OpenAI（o シリーズ） |
|---|---|---|---|
| 制御方法 | `thinking_level` (minimal/low/medium/high) | `budget_tokens` / `thinking.effort` | モデル選択（o3/o4-mini等） |
| デフォルト | **Dynamic（自動調整）** | 明示的に有効化が必要 | 推論モデルは常時on |
| 思考内容の参照 | 部分的に可 | ✅ `thinking` ブロックで確認可 | ❌ 内部非公開 |
| 通常モデルとの統合 | ✅ 同一モデルでon/off | ✅ 同一モデルでon/off | ❌ 別モデルが必要 |

**Geminiの強み**: 同一モデルで思考量をシームレスに調整できる。  
**Claudeの強み**: 思考内容（thinking blocks）を確認・デバッグできる。

---

## 7. 使い分けガイド

```
タスクの種類で考える:

単純 → thinking_level: "minimal"
  ・翻訳
  ・要約
  ・定型文生成

標準 → thinking_level: "low" or Dynamic
  ・質問回答
  ・データ抽出
  ・コード補完

複雑 → thinking_level: "medium" or "high"
  ・バグの原因調査
  ・アーキテクチャ設計
  ・論文・レポートの批評

非常に複雑 → thinking_level: "high"
  ・数学的証明
  ・複雑なデバッグ（大規模コードベース）
  ・多段階の戦略立案
```

---

## 参考リンク

- [Thinking Mode Guide](https://ai.google.dev/gemini-api/docs/thinking)
- [Gemini 3 Developer Guide](https://ai.google.dev/gemini-api/docs/gemini-3)
- [Gemini 3.1 Pro Preview](https://ai.google.dev/gemini-api/docs/models/gemini-3.1-pro-preview)
