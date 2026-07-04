# Google Gemini ベストプラクティス ノート

Google AI（Gemini API / Vertex AI）を実務で使う際のベストプラクティスをまとめたフォルダ。  
Anthropic / OpenAI との共通点・相違点を意識した構成。

## ファイル一覧

| ファイル | 内容 |
|---|---|
| [01_Gemini_API_Basics.md](01_Gemini_API_Basics.md) | モデル一覧・SDK設定・基本的なAPI呼び出し |
| [02_Prompt_Engineering.md](02_Prompt_Engineering.md) | Gemini固有のプロンプト設計ベストプラクティス |
| [03_Multimodal.md](03_Multimodal.md) | 画像・動画・音声・PDF対応（Geminiの強み） |
| [04_Long_Context.md](04_Long_Context.md) | 1M+ tokenコンテキスト活用法とContext Caching |
| [05_Function_Calling.md](05_Function_Calling.md) | Function Calling / Tool Use（内蔵ツール含む） |
| [06_Structured_Output.md](06_Structured_Output.md) | `response_schema`による構造化出力 |
| [07_Thinking_Mode.md](07_Thinking_Mode.md) | `thinking_level`パラメータ（Gemini 3） |
| [08_Vertex_AI.md](08_Vertex_AI.md) | エンタープライズ利用（Google Cloud / Vertex AI） |
| [09_vs_OpenAI_Anthropic.md](09_vs_OpenAI_Anthropic.md) | 3プロバイダー比較まとめ |

## 対象モデル（2026年4月時点）

### Gemini 3 系（最新世代）
| モデルID | 特徴 |
|---|---|
| `gemini-3.1-pro-preview` | 最上位フラグシップ（Preview） |
| `gemini-3-flash` | 複雑なタスクに対応するFlash（低レイテンシ） |
| `gemini-3.1-flash-lite` | コスト重視・大量処理向け |

### Gemini 2.5 系（安定版）
| モデルID | Context | 特徴 |
|---|---|---|
| `gemini-2.5-pro` | **1M tokens** | 複雑な推論・コーディング・長文処理 |
| `gemini-2.5-flash` | **1M tokens** | 価格対性能バランス最良 |
| `gemini-2.5-flash-lite` | 128K tokens | 最安・最高スループット |

## 参考リンク

- [Google AI for Developers](https://ai.google.dev/)
- [Gemini API Docs](https://ai.google.dev/gemini-api/docs)
- [Google AI Studio](https://aistudio.google.com/)
- [Vertex AI Docs](https://cloud.google.com/vertex-ai/generative-ai/docs)
- [Gemini API Pricing](https://ai.google.dev/gemini-api/docs/pricing)
