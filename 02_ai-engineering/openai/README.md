# OpenAI / GPT ベストプラクティス ノート

実務でGPTを使う際のベストプラクティスをまとめたフォルダ。  
Anthropic/Claudeとの共通点・相違点を意識した構成。

## ファイル一覧

| ファイル | 内容 |
|---|---|
| [01_Prompt_Engineering.md](01_Prompt_Engineering.md) | プロンプト設計のベストプラクティス |
| [02_Structured_Output.md](02_Structured_Output.md) | 構造化出力（JSON mode / response_format） |
| [03_Function_Calling.md](03_Function_Calling.md) | Function calling / Tool use |
| [04_vs_Anthropic.md](04_vs_Anthropic.md) | AnthropicとOpenAIの比較まとめ |
| [05_Azure_OpenAI.md](05_Azure_OpenAI.md) | Azure OpenAI API固有の知識（認証・デプロイ・フィルタ） |
| [06_Responses_API_and_Agents.md](06_Responses_API_and_Agents.md) | Responses API + Agents SDK + 組み込みツール |
| [07_Cost_Optimization.md](07_Cost_Optimization.md) | Prompt Caching と Batch API によるコスト削減 |
| [08_Embeddings.md](08_Embeddings.md) | text-embedding-3 モデル・セマンティック検索・RAG |
| [09_Fine_tuning.md](09_Fine_tuning.md) | Fine-tuning の判断基準・データセット準備・実行手順 |
| [10_Vision_Multimodal.md](10_Vision_Multimodal.md) | 画像入力・Vision API・ドキュメント理解 |

## 対象モデル（2026年7月時点）

- **GPT-5.5 / GPT-5.5 Pro** — 最新フラグシップ（GPT-5.4 より高性能かつトークン効率が良い）
- **GPT-5.4 Thinking / Pro** — 推論・高難度タスク向け
- **GPT-5.4 mini / nano** — コスト・速度重視（nano は API 限定）
- **GPT-5.3 Instant** — 各ティアの既定モデル
- GPT-5.6 系（Sol / Terra / Luna）は限定プレビュー
- gpt-4o / gpt-4o mini（音声入出力が必要な場合のみ）

> モデルの詳細スペック（コンテキスト長・価格）は流動的なため、利用前に公式ドキュメントで確認すること。

## 参考リンク

- [OpenAI Platform Docs](https://platform.openai.com/docs)
- [OpenAI Cookbook](https://cookbook.openai.com)
- [Prompt Engineering Guide (OpenAI)](https://platform.openai.com/docs/guides/prompt-engineering)
