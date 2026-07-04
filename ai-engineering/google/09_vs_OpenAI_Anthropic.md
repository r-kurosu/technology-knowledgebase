# Google vs OpenAI vs Anthropic 比較まとめ

3大プロバイダーの比較ノート。

---

## 1. モデルラインナップ（2026年4月時点）

| ティア | Google | OpenAI | Anthropic |
|---|---|---|---|
| 最上位フラグシップ | `gemini-3.1-pro-preview` | `gpt-5.4` | `claude-opus-4-6` |
| バランス型 | `gemini-2.5-flash` | `gpt-5.4-mini` | `claude-sonnet-4-6` |
| 軽量・高速 | `gemini-2.5-flash-lite` | `gpt-5.4-nano` | `claude-haiku-4-5` |
| 推論特化 | `gemini-3-flash`（Dynamic Thinking） | `gpt-5.4-pro` | Claude（Extended Thinking） |

---

## 2. API構造の比較

| 項目 | Google (Gemini) | OpenAI | Anthropic |
|---|---|---|---|
| エンドポイント | `generativelanguage.googleapis.com` | `api.openai.com/v1/chat/completions` | `api.anthropic.com/v1/messages` |
| AIロール名 | **`"model"`** | `"assistant"` | `"assistant"` |
| システム指示 | `system_instruction`（モデル初期化時） | `{"role": "system", ...}` | `system: "..."` (トップレベル) |
| max_tokens | `max_output_tokens` | `max_tokens` / `max_completion_tokens` | `max_tokens` |
| OpenAI互換 | ✅ あり | - | ❌ なし |

---

## 3. コンテキストウィンドウ

| モデル | Context | 出力上限 |
|---|---|---|
| `gemini-2.5-pro` | **1M tokens** | 65,536 tokens |
| `gemini-2.5-flash` | **1M tokens** | 65,536 tokens |
| `gpt-5.4` | **1M tokens** | 未公表 |
| `claude-opus-4-6` | 200K tokens | 32K tokens |
| `claude-sonnet-4-6` | 200K tokens | 32K tokens |

> 長文処理が必要なら Gemini か GPT-5.4 が有利。Claudeは200K止まり。

---

## 4. マルチモーダル対応

| モダリティ | Gemini | OpenAI | Anthropic |
|---|---|---|---|
| テキスト | ✅ | ✅ | ✅ |
| 画像 | ✅ | ✅ | ✅ |
| 動画 | ✅（YouTube URL対応） | 限定的 | ❌ |
| 音声 | ✅ | ✅（Whisper/TTS） | ❌ |
| PDF | ✅（最大1000ページ） | ❌（テキスト抽出必要） | ✅（制限あり） |
| 統一埋め込み | ✅（Gemini Embedding 2） | 限定的 | ❌ |

**Geminiのマルチモーダルは3社中最強**。特に動画・音声・大容量PDFの直接処理。

---

## 5. 推論・思考モード

| 項目 | Gemini 3 | Claude（Extended Thinking） | OpenAI（o系） |
|---|---|---|---|
| 制御パラメータ | `thinking_level` | `budget_tokens` / `effort` | モデル選択 |
| デフォルト | Dynamic（自動） | off（明示有効化） | 推論モデルは常時on |
| 思考内容確認 | 部分的 | ✅ thinking blocks | ❌ |
| 同一モデル | ✅ | ✅ | ❌（別モデルが必要） |

---

## 6. Function Calling / Tool Use

| 項目 | Gemini | OpenAI | Anthropic |
|---|---|---|---|
| ツール定義 | `FunctionDeclaration` + `Schema` | `tools[].function` | `tools[].input_schema` |
| 呼び出しモード | AUTO/ANY/NONE/VALIDATED | auto/required/none | auto/any/none |
| 並列呼び出し | ✅ | ✅ | ✅ |
| 内蔵ツール | **Google Search, Code Execution, Maps** | Web Search（別途） | Web Search（別途） |
| Strict mode | VALIDATED（Gemini 3） | `strict: true` | `strict: true` |

**Geminiの強み**: Google SearchグラウンディングとCode ExecutionがネイティブビルトインでHTTP呼び出し不要。

---

## 7. 構造化出力

| 項目 | Gemini | OpenAI | Anthropic |
|---|---|---|---|
| スキーマ強制 | `response_schema` | `response_format.json_schema` (`strict: true`) | `output_config.format` |
| JSON mode | `response_mime_type: "application/json"` | `{type: "json_object"}` | なし |
| Pydantic連携 | ✅ 直接渡せる | ✅ `.parse()` | ✅ |

---

## 8. コスト最適化

| 機能 | Gemini | OpenAI | Anthropic |
|---|---|---|---|
| Prompt Caching | ✅ Context Caching API（明示的） | ✅ 自動キャッシュ（OpenAI管理） | ✅ Prompt Caching（`cache_control`） |
| Batch API | ✅ | ✅ （50%割引） | ✅ （50%割引） |
| キャッシュ割引率 | 〜75%割引 | 〜50%割引 | 〜90%割引 |

---

## 9. エンタープライズ展開

| 項目 | Vertex AI（Google） | Azure OpenAI（Microsoft） | Claude on AWS/GCP（Anthropic） |
|---|---|---|---|
| クラウド基盤 | GCP | Azure | AWS Bedrock / Vertex AI |
| 認証 | Service Account | Azure AD | IAM Role |
| VPC | ✅ | ✅ | ✅ |
| Fine-tuning | ✅ | ✅ | 限定的 |

---

## 10. 実務での選択指針

```
長文ドキュメント処理（1M tokens）
  → Gemini 2.5 Pro / gpt-5.4

動画・音声・PDF処理
  → Gemini（ダントツ優位）

厳密な推論・数学・コード
  → Gemini 3 (thinking high) / Claude Extended Thinking / GPT o系

安全性・倫理的な回答品質
  → Anthropic Claude（コンスティテューショナルAI）

OpenAIからの移行コスト最小化
  → Gemini（OpenAI互換エンドポイントあり）

GCPエコシステム内で完結したい
  → Vertex AI (Gemini)

AzureエコシステムのエンタープライズAI
  → Azure OpenAI

マルチプロバイダー統一インターフェース
  → LiteLLM
```

---

## 参考リンク

- [Gemini API Docs](https://ai.google.dev/gemini-api/docs)
- [OpenAI Platform Docs](https://platform.openai.com/docs)
- [Anthropic Docs](https://docs.anthropic.com)
- [LiteLLM（マルチプロバイダー対応）](https://docs.litellm.ai)
