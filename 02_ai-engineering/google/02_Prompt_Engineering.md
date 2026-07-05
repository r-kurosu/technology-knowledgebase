# Gemini プロンプトエンジニアリング ベストプラクティス

---

## 1. メッセージ構造の基本

Gemini APIのロール構造はOpenAIと微妙に異なる。

| ロール | Gemini | OpenAI | Anthropic |
|---|---|---|---|
| システム指示 | `system_instruction`（モデル初期化時） | `{"role": "system", ...}` | `system: "..."` |
| ユーザー | `{"role": "user", ...}` | 同じ | 同じ |
| AIの応答 | `{"role": "model", ...}` | `{"role": "assistant", ...}` | `{"role": "assistant", ...}` |

> **重要**: Geminiのassistantロールは `"model"` 。`"assistant"` では動かない。

### System Instruction の書き方

```python
model = genai.GenerativeModel(
    model_name="gemini-2.5-flash",
    system_instruction="""
あなたは社内技術ドキュメントの要約アシスタントです。
目標: 技術文書を非エンジニアにもわかる言葉で要約する。
制約:
- 200字以内で要約する
- 専門用語は括弧内に説明を付ける
- 日本語で回答する
""",
)
```

---

## 2. Few-shot プロンプティング

```python
response = model.generate_content([
    # Few-shot の例
    {"role": "user", "parts": ["「最高の体験でした」のセンチメント分類"]},
    {"role": "model", "parts": ["positive"]},
    {"role": "user", "parts": ["「普通でした」のセンチメント分類"]},
    {"role": "model", "parts": ["neutral"]},
    # 実際の入力
    {"role": "user", "parts": ["「二度と使いたくない」のセンチメント分類"]},
])
```

**他プロバイダーとの違い**:
- Claude: `<example>` タグで囲む方式が推奨
- OpenAI: `user`/`assistant` ターン（GeminiとほぼOK同じ構造だが `"model"` に注意）
- Gemini: `user`/`model` ターン

---

## 3. 区切り文字（Delimiter）の活用

GeminiはMarkdown・XML・カスタム区切りいずれも動作する。

```python
prompt = f"""
以下のレビューテキストを分析してください。

---
{review_text}
---

上記のテキストについて：
1. 全体的なセンチメント（positive/negative/neutral）
2. 言及されている具体的な問題点（あれば）
3. 改善提案（あれば）

を抽出してください。
"""
```

**Claudeとの違い**: ClaudeはXMLタグが特に推奨されるが、GeminiはMarkdownベースが自然。どちらも使える。

---

## 4. Chain of Thought（CoT）

```python
# Zero-shot CoT
prompt = "以下の問題をステップバイステップで解いてください:\n\n{problem}"

# 明示的なCoT誘導
prompt = """
問題: {problem}

解答手順:
1. まず問題の要件を整理する
2. 解法のアプローチを検討する
3. 各ステップを順番に実行する
4. 最終的な答えを確認する
"""
```

> Gemini 3 系は `thinking_level` パラメータで内部推論を制御できる。  
> 推論モデルにはCoTプロンプトは基本不要（→ [07_Thinking_Mode.md](07_Thinking_Mode.md)）。

---

## 5. Grounding（根拠付き生成）

Gemini固有の機能。Google検索と連動してハルシネーションを削減。

```python
from google.generativeai.types import Tool

model = genai.GenerativeModel(
    model_name="gemini-2.5-flash",
    tools=[Tool(google_search={})]  # Google Search Grounding
)

response = model.generate_content("2026年4月時点の最新のGeminiモデルは？")
print(response.text)

# 根拠URL（検索ソース）の確認
for chunk in response.candidates[0].grounding_metadata.grounding_chunks:
    print(chunk.web.uri)
```

> OpenAI / Anthropicにはネイティブ検索グラウンディングがない（OpenAIはWebSearchツール、AnthropicはSearch toolが別途提供）。

---

## 6. プロンプト設計の原則（Gemini公式）

<!-- 一言説明、30秒説明、採用理由を自分で書く -->

## 7. System Instruction vs プロンプト内指示

<!-- 判断問題への回答、疑問、理解度（A/B/C）を残す -->
