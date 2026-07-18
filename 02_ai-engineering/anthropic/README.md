# Anthropic / Claude ノート

Anthropic の Claude API・Agent SDK・Claude Code を実務で使う際のリファレンスとベストプラクティス。
エージェント設計・プロンプト・ツール/MCP・コンテキスト管理を扱う。

## ファイル一覧

| ファイル | 内容 |
|---|---|
| [01_Agentic_Architecture.md](01_Agentic_Architecture.md) | エージェンティックループ・マルチエージェント・ワークフローパターン・Agent SDK フック |
| [02_Claude_Code_Workflows.md](02_Claude_Code_Workflows.md) | CLAUDE.md 階層・スキル・権限・フック・CI/CD 連携 |
| [03_Prompt_Engineering.md](03_Prompt_Engineering.md) | プロンプト設計・構造化出力・Few-shot・信頼性向上 |
| [04_Tool_Design_MCP.md](04_Tool_Design_MCP.md) | ツール定義の設計・ツール境界・MCP (Model Context Protocol) 連携 |
| [05_Context_Management.md](05_Context_Management.md) | ロングコンテキスト・コンパクション・ハンドオフ・プロンプトキャッシング |
| [06_API_Implementation.md](06_API_Implementation.md) | Anthropic Python SDK 実装パターン集（messages / tool_use / streaming / caching） |
| [References.md](References.md) | 公式ドキュメント・エンジニアリングブログ・学習リソースのリンク集 |

## 対象モデル（2026年7月時点）

| モデルID | 位置づけ | コンテキスト | 入力/出力 $/1M |
|---|---|---|---|
| `claude-fable-5` | 最上位（最も高性能） | 1M | $10 / $50 |
| `claude-opus-4-8` | 推奨既定 | 1M | $5 / $25 |
| `claude-sonnet-4-6` | 速度と知能のバランス | 1M | $3 / $15 |
| `claude-haiku-4-5` | 高速・低コスト | 200K | $1 / $5 |

- 拡張思考は `thinking: {type: "adaptive"}`（Adaptive Thinking）を使用。`budget_tokens` は Opus 4.6/Sonnet 4.6 で非推奨、Fable 5/Opus 4.7/4.8 で削除済み。
- 構造化出力は `output_config.format`（旧 `output_format` は非推奨）。
