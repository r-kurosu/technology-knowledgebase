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

## 対象モデル（2026年7月時点）

### Gemini 3.5 系（最新世代）
| モデル | 特徴 |
|---|---|
| Gemini 3.5 Pro | プレミアム推論フラグシップ（順次展開中） |
| Gemini 3.5 Flash | Flash級の速度・コストでPro級に迫る知能、1M コンテキスト（GA） |

### Gemini 3.1 系
| モデル | 特徴 |
|---|---|
| Gemini 3.1 Pro | 推論重視。Adaptive Thinking・1M コンテキスト・グラウンディング |
| Gemini 3.1 Flash-Lite | コスト効率重視の大量処理向けワークホース |

### 画像生成
| モデル | 特徴 |
|---|---|
| Nano Banana Pro（Gemini 3 Pro Image） | 最高品質の画像生成 |
| Nano Banana 2（Gemini 3.1 Flash Image） | 高スループット・低価格 |

> 正確なモデルID・コンテキスト長・価格は流動的なため、利用前に公式ドキュメントで確認すること。

## 参考リンク

- [Google AI for Developers](https://ai.google.dev/)
- [Gemini API Docs](https://ai.google.dev/gemini-api/docs)
- [Google AI Studio](https://aistudio.google.com/)
- [Vertex AI Docs](https://cloud.google.com/vertex-ai/generative-ai/docs)
- [Gemini API Pricing](https://ai.google.dev/gemini-api/docs/pricing)
