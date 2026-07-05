# Google vs OpenAI vs Anthropic 比較まとめ

3大プロバイダーの比較ノート。

---

## 1. モデルラインナップ（2026年7月時点）

| ティア | Google | OpenAI | Anthropic |
|---|---|---|---|
| 最上位フラグシップ | Gemini 3.5 Pro | GPT-5.5 | `claude-fable-5` |
| 主力（既定） | Gemini 3.5 Flash | `gpt-5.4` 系 | `claude-opus-4-8` |
| バランス型 | Gemini 3.1 Flash-Lite | `gpt-5.4-mini` | `claude-sonnet-4-6` |
| 軽量・高速 | Gemini 3.1 Flash-Lite | `gpt-5.4-nano` | `claude-haiku-4-5` |
| 推論特化 | Gemini（Dynamic Thinking） | `gpt-5.4` Thinking/Pro | Claude（Adaptive Thinking） |

> モデルの最新情報は流動的なため、選定時に各社の公式ドキュメントを確認すること。

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
| Gemini 3.5 Flash | **1M tokens** | 65,536 tokens |
| `gpt-5.4` 系 | **1M tokens** | 未公表 |
| `claude-fable-5` / `claude-opus-4-8` | **1M tokens** | 128K tokens |
| `claude-sonnet-4-6` | **1M tokens** | 64K tokens |
| `claude-haiku-4-5` | 200K tokens | 64K tokens |

> 主要3社ともフラグシップは 1M コンテキストに対応。長文処理でのコンテキスト長差は縮小している。

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

<!-- 一言説明、30秒説明、採用理由を自分で書く -->

## 7. 構造化出力

<!-- 判断問題への回答、疑問、理解度（A/B/C）を残す -->
