# Domain 1: Agentic Architecture & Orchestration (27%)

**試験全体の27%を占める最重要ドメイン**

---

## 1. タスクステートメント一覧（公式試験ガイド）

| タスク | 内容 |
|--------|------|
| **1.1** | エージェンティックループの設計と実装（自律的タスク実行） |
| **1.2** | コーディネーター・サブエージェントパターンによるマルチエージェントシステムのオーケストレーション |
| **1.3** | サブエージェントの呼び出し、コンテキスト受け渡し、スポーンの設定 |
| **1.4** | エンフォースメントとハンドオフパターンによるマルチステップワークフローの実装 |
| **1.5** | Agent SDKフックによるツールコールのインターセプトとデータ正規化 |
| **1.6** | 複雑なワークフローのためのタスク分解戦略の設計 |
| **1.7** | セッション状態と再開の管理（コンテキストウィンドウ管理、段階的要約、重要データ用イミュータブルファクトブロック） |

---

## 2. エージェンティックループ（Agentic Loops）

### 基本概念
エージェンティックループは、Claudeベースの全てのエージェントを駆動するコア実行サイクル。決定論的な制御フローパターン。

### ループの4ステップ
1. Messages APIにリクエストを送信（会話履歴、システムプロンプト、ツール定義を含む）
2. Claudeが応答を返す
3. `stop_reason`を確認する
4. `stop_reason`に基づいて次のアクションを決定

### stop_reason（最重要シグナル）
- **`tool_use`**: Claudeがツールを呼び出したい → **ループ継続**
- **`end_turn`**: Claudeが作業を完了 → **ループ終了**
- 正しいパターン: `stop_reason === "end_turn"` を唯一のループ終了シグナルとして使用

### 試験で問われるアンチパターン
- **イテレーションキャップ**: 最大ループ回数を設定する（脆弱 — 実タスクは必要ステップ数が変動する）
- **自然言語パース**: Claudeの応答に「DONE」「COMPLETE」が含まれるかチェック（非信頼性）
- **固定ステップ数での終了**: タスクの性質を無視した硬直的な終了条件

---

## 3. ワークフロー vs エージェント

### Anthropicの定義（Building Effective Agents より）
- **ワークフロー**: LLMとツールが**事前定義されたコードパス**で統制されるシステム
- **エージェント**: LLMが自身のプロセスとツール使用を**動的に制御**するシステム

> 核心: エージェントとは「フィードバックループを持つワークフロー」である。

### 拡張LLM (Augmented LLM) — 基本構成要素
エージェンティックシステムの基本構成要素は、以下で拡張されたLLM:
- **検索（Retrieval）**: 自身で検索クエリを生成
- **ツール（Tools）**: 適切なツールを選択
- **メモリ（Memory）**: 保持すべき情報を決定

### 使い分けの原則
- **常にシンプルな解決策を最初に探す**（エージェンティックシステムを構築しない選択も含む）
- ワークフロー: 明確に定義されたタスクに対する予測性と一貫性
- エージェント: 柔軟性とモデル主導の意思決定が必要な場合
- エージェンティックシステムはレイテンシとコストを犠牲にしてタスク性能を向上させる

---

## 4. 5つのワークフローパターン（必須暗記）

### 4.1 プロンプトチェーニング（Prompt Chaining）
- タスクを一連のステップに分解し、各LLMコールが前の出力を処理
- **適用場面**: タスクが固定サブタスクに明確に分解可能な場合
- **トレードオフ**: レイテンシ増加と引き換えに精度向上

### 4.2 ルーティング（Routing）
- 入力を分類し、専門化されたフォローアップタスクに振り分け
- **利点**: 関心の分離、より専門化されたプロンプトの構築が可能

### 4.3 パラレル化（Parallelization）
- LLMが同時にタスクに取り組み、出力をプログラム的に集約
- **2つの変種**: 投票（Voting）とセクショニング（Sectioning）
- 独立したサブタスクを並列実行、または同じタスクを複数回実行して多様な出力を取得

### 4.4 オーケストレーター・ワーカー（Orchestrator-Workers）
- 中央のLLMがタスクを動的に分解、ワーカーLLMに委譲、結果を統合
- **パラレル化との違い**: サブタスクが事前定義されず、オーケストレーターが入力に基づき決定
- **適用場面**: 必要なサブタスクを事前に予測できない複雑なタスク

### 4.5 評価者・最適化者（Evaluator-Optimizer）
- 1つのLLMが応答を生成、別のLLMが評価とフィードバックをループで提供
- **適用場面**: 明確な評価基準があり、反復的改善が有効な場合

---

## 5. ハブ・アンド・スポーク（Hub-and-Spoke）アーキテクチャ

### 構造
- **ハブ（中央コーディネーター）**: 全サブエージェント間の通信を管理
- **スポーク（専門サブエージェント）**: 各自が独自のコンテキストを持ち、直接状態を共有しない

### 利点
- 一貫した観測性（Observability）
- 制御された情報フロー
- 複雑なマルチステップAIワークフロー全体の管理

### コンテキスト受け渡しの重要ルール
- **サブエージェントは親の会話履歴を継承しない** — コーディネーターが明示的にプロンプトで渡したものだけ
- **暗黙的コンテキスト仮定はアンチパターン** — サブエージェントが必要な情報は全て明示的に注入する

---

## 6. マルチエージェントリサーチシステム（Anthropic実装事例）

### アーキテクチャ
- **リードエージェント**: クエリを分析、戦略を策定、サブエージェントをスポーン
- **サブエージェント**: 異なる側面を同時に探索する「インテリジェントフィルター」

### サブエージェントに必要な4要素
1. 目的（Objective）
2. 出力形式（Output format）
3. 使用するツールとソースに関するガイダンス
4. 明確なタスク境界

### 並列化の2レベル
- リードエージェントが3-5のサブエージェントを同時スポーン
- 各サブエージェントが複数のツールコールを並列実行

### トークン効率
- サブエージェントは独自のコンテキストウィンドウで並列動作し、最も重要なトークンだけをリードエージェントに圧縮して返す

### モデル構成の例
- リード: Claude Opus 4.7（高い推論能力）
- サブエージェント: Claude Sonnet 4.6（コスト効率）
- 結果: 単一エージェントよりも高い性能

---

## 7. Agent SDKのフック（Hooks）システム

### 主要フックイベント一覧
| フック | タイミング |
|--------|-----------|
| **PreToolUse** | ツール実行前 |
| **PostToolUse** | ツール実行後 |
| **PostToolUseFailure** | ツール実行失敗後 |
| **Stop** | エージェント停止時 |
| **SubagentStart** | サブエージェント開始時 |
| **SubagentStop** | サブエージェント停止時 |
| **SessionStart** | セッション開始時 |
| **SessionEnd** | セッション終了時 |
| **UserPromptSubmit** | ユーザープロンプト送信時 |
| **PreCompact** | コンテキスト圧縮前 |
| **Notification** | 通知時 |
| **PermissionRequest** | 権限リクエスト時 |
| **Setup** | セットアップ時 |

### 権限処理の順序（重要）
```
PreToolUse Hook → Deny Rules → Allow Rules → Ask Rules → Permission Mode Check → canUseTool Callback → PostToolUse Hook
```

### PreToolUseフックの権限判定オプション
- **"allow"**: ツール実行を許可
- **"deny"**: ツール実行を拒否
- **"ask"**: ユーザーに確認を求める

### フックの実行タイプ（4種類）
1. シェルコマンド
2. シングルショットLLMプロンプト
3. マルチターンエージェント会話
4. HTTPウェブフック

---

## 8. サブエージェントの設計と管理

### Task ツールによるサブエージェントスポーン
- `allowedTools`に`Task`を含める必要がある
- 各サブエージェントは独自のコンテキストウィンドウとツールアクセスを持つ

### context: fork
- スキルを分離されたサブエージェントで実行
- メインセッションのコンテキスト汚染を防止

### AgentDefinition（SDK）の設定項目
- description, prompt, tools, model, skills, memory type, MCP servers

### allowedTools制限
- デフォルトでは全ツール使用可能
- `allowedTools`でスキル実行中に利用可能なツールを制限
- 例: EditとWriteを除外すればコードベースを変更不可にできる

---

## 9. エージェントハーネス設計（本番運用）

### Anthropicの3層分離アーキテクチャ
1. **Session**: エージェントインタラクションの完全履歴を含む追記のみのイベントログ
2. **Harness**: Claudeを呼び出しツールコールを実行環境にルーティングするステートレスな制御ループ
3. **Sandbox**: Claudeがコードを実行しファイルを操作する分離された実行環境

### エラー回復戦略
- ツールハンドラ内で障害をキャッチし、エラー結果として返してループを継続
- gitへのコミットと進捗ファイルの記録で回復ポイントを作成
- 不正なコード変更はgit revertで作業状態に復帰

### 長期実行エージェント — Ralph Loopパターン
- **初期化エージェント**: 環境セットアップ（initスクリプト、進捗ファイル、機能リスト、初期gitコミット）
- **コーディングエージェント**: 各セッションでgitログと進捗ファイルを読み、優先度最高の未完了機能を選択、作業、コミット、要約記録

### ガードレールとHuman-in-the-Loop
- 権限エンフォースメントとモデル推論をアーキテクチャ的に分離
- モデルは何を試みるか決定、ツールシステムは何が許可されるか決定
- 高リスク操作（データ削除、外部通信、インフラ変更）には承認ゲートが必要

---

## 10. 重要用語集

| 用語 | 定義 |
|------|------|
| **Agentic Loop** | LLMがツールを使用し結果を受け取る反復的な実行サイクル |
| **stop_reason** | APIレスポンスでループ継続/終了を判断するシグナル |
| **Hub-and-Spoke** | 中央コーディネーターが専門サブエージェントを管理するアーキテクチャ |
| **Orchestrator-Workers** | タスクを動的に分解しワーカーに委譲するパターン |
| **PreToolUse Hook** | ツール実行前に介入するコールバック（許可/拒否/確認） |
| **Context Fork** | サブエージェントを分離コンテキストで実行する仕組み |
| **Task Tool** | サブエージェントをスポーンするためのツール |
| **allowedTools** | サブエージェントが使用可能なツールを制限するパラメータ |
| **Agent Harness** | エージェントを本番運用するための包括的インフラ |
| **Ralph Loop** | 長期実行タスク用の2フェーズパターン（初期化+反復コーディング） |
| **Augmented LLM** | 検索・ツール・メモリで拡張されたLLM（エージェントの基本単位） |
| **Evaluator-Optimizer** | 生成と評価をループで反復する改善パターン |
| **Prompt Chaining** | 出力を次の入力として逐次処理するパターン |

---

## 11. Claude Managed Agents（パブリックベータ）

Anthropicが提供するフルマネージドエージェントハーネス。自前でハーネスを実装せずにClaudeをエージェントとして運用できる。

### 主な特徴
- **セキュアサンドボックス**: OS レベルで隔離された実行環境を自動プロビジョニング
- **組み込みツール**: ファイルシステム・コード実行などのツールが標準搭載
- **SSEストリーミング**: サーバー送信イベントによるリアルタイムな進捗通知
- **Memory（ベータ）**: セッション間でコンテキストを保持する永続メモリ
- **マルチエージェントセッション**: コーディネーター + サブエージェントの構成を API で管理
- **Webhooks**: セッション・Vaultのライフサイクルイベントを外部システムに通知

### API利用方法
- ベータヘッダー: `managed-agents-2026-04-01`
- エージェントの作成 → コンテナ設定 → セッション実行 の3ステップ

### 従来のAgent SDKとの違い
| | Agent SDK | Managed Agents |
|---|---|---|
| ハーネス実装 | 自前 | Anthropicが管理 |
| サンドボックス | 自前 | 自動プロビジョニング |
| スケーリング | 自前 | マネージド |
| 適合場面 | カスタム要件が多い場合 | 素早くエージェントを本番運用したい場合 |

---

## 参考リンク

### Anthropic公式
- [Building Effective Agents](https://www.anthropic.com/research/building-effective-agents)
- [How We Built Our Multi-Agent Research System](https://www.anthropic.com/engineering/multi-agent-research-system)
- [Harness Design for Long-Running Apps](https://www.anthropic.com/engineering/harness-design-long-running-apps)
- [Building Agents with the Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk)
- [Tool Use Documentation](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview)
- [Agent SDK Overview](https://platform.claude.com/docs/en/agent-sdk/overview)
- [Subagents in the SDK](https://platform.claude.com/docs/en/agent-sdk/subagents)
- [Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Scaling Managed Agents: Decoupling the brain from the harness](https://www.anthropic.com/engineering/managed-agents)
- [New capabilities for building agents on the Anthropic API](https://www.anthropic.com/news/agent-capabilities-api)

### 学習サイト
- [Tutorials Dojo CCA-F Study Guide](https://tutorialsdojo.com/cca-f-claude-certified-architect-foundations-study-guide/)
- [Claude Certifications - Domain 1](https://claudecertifications.com/claude-certified-architect/domains/agentic-architecture)
- [Claude Certification Guide - Agentic Architecture](https://claudecertificationguide.com/learn/1-agentic-architecture)
- [FlashGenius - Mastering Agentic Architecture](https://flashgenius.net/blog-article/mastering-agentic-architecture-the-core-pillar-of-the-claude-certified-architect-exam)

### GitHub
- [timothywarner-org/claude-architect](https://github.com/timothywarner-org/claude-architect)
- [carolinacherry/claude-certified-architect](https://github.com/carolinacherry/claude-certified-architect)
- [ThibautMelen/agentic-workflow-patterns](https://github.com/ThibautMelen/agentic-workflow-patterns)
