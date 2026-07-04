# Domain 5: Context Management & Reliability (15%)

---

## 1. コンテキストウィンドウ管理

### 各モデルのコンテキストウィンドウサイズ

| モデル | コンテキストウィンドウ | 最大出力トークン |
|---|---|---|
| Claude Opus 4.7 | **1Mトークン** | 128K（Extended Thinking時） |
| Claude Opus 4.6 | **1Mトークン** | 128K（Extended Thinking時） |
| Claude Sonnet 4.6 | **1Mトークン** | 64K（Extended Thinking時）/ Batch APIで300K |
| Claude Haiku 4.5 | 200Kトークン | 64K（Extended Thinking時） |
| Claude Sonnet 4.5 | 200Kトークン | - |

> **非推奨（Deprecated）**: Claude Sonnet 4 / Opus 4 は廃止済み。それぞれ Sonnet 4.6 / Opus 4.7 への移行を推奨。

### 「Lost in the Middle」効果（重要な試験トピック）
- LLMはコンテキストの**冒頭と末尾**の情報を正確に処理するが、**中間部分の情報を見落とす**傾向がある
- **対策**:
  - 重要なサマリーを集約入力の**先頭**に配置
  - 明示的なセクションヘッダーを使用
  - 長いドキュメント（20K+トークン）はプロンプトの**上部**に配置し、クエリ・指示・例はその下に配置
  - 冗長なツール出力はコンテキストに蓄積される前にトリミング

### コンテキストエンジニアリングの5つの操作（Anthropic公式）
1. **Select（選択）**: 必要な情報だけを選ぶ
2. **Compress（圧縮）**: 情報を凝縮する
3. **Order（順序付け）**: 情報の配置順を最適化する
4. **Isolate（分離）**: サブエージェントに情報を分離する
5. **Format（整形）**: 情報を適切な形式にする

---

## 2. プログレッシブサマリゼーション

### リスクと落とし穴（試験で出題される重要トピック）
- 数値、パーセンテージ、日付が**曖昧な要約に凝縮**されてしまうリスク
- 重要な識別子やファクトが失われる

### 正しいアプローチ
- プログレッシブサマリゼーションに頼るのではなく、**重要なファクトを不変の「ケースファクト」ブロック**としてコンテキストの先頭に抽出する
- 冗長なツール出力から**構造化されたファクトを抽出**する

> **試験頻出**: 「プログレッシブサマリゼーション vs ケースファクトブロック」 → **ケースファクトブロックが正解**

---

## 3. コンパクション（Compaction）

### サーバーサイドコンパクション
- コンテキストウィンドウの限界に定期的に近づく会話のための**推奨アプローチ**
- サーバーサイドの要約機能が自動的に会話の初期部分を凝縮
- Claude Opus 4.6 / Sonnet 4.6 で利用可能（ベータ版）

### コンパクション vs サマリゼーション
- **LLMサマリゼーション**: 古いメッセージを凝縮サマリーに置き換え
- **Verbatimコンパクション**: 圧縮率は低い（50-70%）が、ファイルパス・エラー文字列・設定値などの**正確性を保証**
- コーディングエージェントには正確なパスやエラー文字列が重要なため、Verbatimコンパクションが重要

---

## 4. セッション管理とスクラッチパッドファイル

### セッション管理パターン
- **--resume** コマンドによる名前付きセッション再開
- **fork_session**: 共有分析ベースラインから独立したブランチを作成
- 使い分け:
  - **セッション再開**: 以前のコンテキストが大部分有効な場合
  - **新規開始 + サマリー注入**: 以前のツール結果が古くなっている場合

### スクラッチパッドファイル
- 長時間セッションでのコンテキスト維持のために**外部ファイル**を活用
- エージェントがファイルに書き出し、必要な時に読み返すパターン
- コンテキストウィンドウの限界を超えた情報永続化の手段

### Ralph Loopパターン（Anthropic公式）
- **初期化エージェント**: 環境セットアップ
- **コーディングエージェント**: 各セッションでgitログと進捗ファイルを読んで方向付け

---

## 5. マルチエージェントのコンテキスト受け渡し（Handoff Patterns）

### 基本原則
- サブエージェントが必要とする情報は**全て明示的にプロンプトで渡す**
- 共有メモリは存在せず、自動的な履歴伝播もない
- 全ての調整は**オーケストレーターを通じて**フローする

### アーティファクトシステムパターン
- 専門エージェントが成果物を外部システムに保存（ツール呼び出し経由）
- **軽量な参照**をコーディネーターに返す
- 詳細な検索コンテキストはサブエージェント内に分離

### コンテキスト容量管理のためのサブエージェント委譲
- コンテキスト限界に近づいた場合、**クリーンなコンテキストを持つ新しいサブエージェント**を生成
- 情報が「伝言ゲーム」にならないよう注意（ハンドオフごとに忠実度が低下するリスク）

---

## 6. 信頼性パターンと出力品質

### ハルシネーション削減（Anthropic公式推奨）
1. **不確実性の許可**: Claudeに「わからない」と言う許可を明示的に与える
2. **直接引用による根拠付け**: 長文ドキュメントでは、タスク実行前にまず原文から引用を抽出させる
3. **引用付き検証**: 各主張に引用・出典を付けさせ、監査可能にする
4. **Best-of-N検証**: 同じプロンプトを複数回実行し、出力間の不整合を検出
5. **チェーン検証**: 前の出力を次のプロンプトに入力し、矛盾を検出・修正
6. **外部知識の制限**: 提供されたドキュメントのみを使用するよう指示

### 出力一貫性の向上
- **構造化出力**: JSONスキーマ保証によるゼロパースエラー
- **Strict tool use**: `strict: true` でパラメータがスキーマと完全一致
- **JSON出力モード**: `output_config.format` でデータ抽出タスクに使用

---

## 7. エスカレーションパターン

### 適切なエスカレーショントリガー（試験で問われる）
- **適切なトリガー**:
  - 人間への明示的なリクエスト
  - ポリシーのギャップ/例外
  - 進展が見られない場合
- **不適切なトリガー（信頼性の低いプロキシ）**:
  - 感情分析
  - モデルの信頼度自己評価

> **試験頻出**: 「感情分析 vs 明示的リクエスト」をエスカレーショントリガーとして → **明示的リクエストが正解**

---

## 8. プロンプトキャッシング

### 基本概念
- **cache_control**: `{"type": "ephemeral"}` で指定
- デフォルトTTL: **5分**
- 拡張キャッシュ: `{"type": "ephemeral", "ttl": "1h"}` で**1時間**

### キャッシュチェックポイントの最小トークン数
- Claude Opus 4.7 / 4.6 / Sonnet 4.6: **1,024トークン以上**が必要

### コスト構造
- **キャッシュ書き込みトークン**: ベース入力トークン価格の1.25倍（5分）、2倍（1時間）
- **キャッシュ読み取りトークン**: ベース入力トークン価格の**0.1倍**（90%割引）

---

## 9. トークンカウンティング

### Token Counting API
- エンドポイント: `POST /v1/messages/count_tokens`
- メッセージ送信前にトークン数を確認可能
- システムプロンプト、ツール、画像、PDFをサポート
- **無料**（リクエスト/分のレート制限あり）

### コンテキストアウェアネス
- Claude Sonnet 4.5 / Haiku 4.5 は**コンテキストアウェアネス機能**を搭載
- モデルが残りのコンテキストウィンドウ（「トークンバジェット」）を追跡可能

---

## 10. 長文コンテキストプロンプティングのベストプラクティス

1. 長文ドキュメントをプロンプトの**先頭**に配置
2. 複数ドキュメントは `<document>` タグで囲み、`<document_content>` と `<source>` サブタグを使用
3. 関連部分をまず**引用**させてからタスクを実行させる
4. ツールセットの肥大化を避ける
5. 多様で典型的な**Few-shot例**を用意する

---

## 試験対策の重要判断問題パターン

1. 「プログレッシブサマリゼーション vs ケースファクトブロック」 → **ケースファクトブロックが正解**
2. 「感情分析 vs 明示的リクエスト」のエスカレーション → **明示的リクエストが正解**
3. 「セッション再開 vs 新規開始」 → コンテキストの鮮度に応じて判断
4. 「全ツールを1エージェントに vs サブエージェント分離」 → **サブエージェント分離が正解**
5. 「プロンプトでJSON指示 vs 構造化出力スキーマ」 → **構造化出力スキーマが正解**

---

## 参考リンク

### Anthropic公式ドキュメント
- [Context windows](https://docs.anthropic.com/en/docs/build-with-claude/context-windows)
- [Long context prompting tips](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/long-context-tips)
- [Prompt caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching)
- [Token counting](https://platform.claude.com/docs/en/build-with-claude/token-counting)
- [Reduce hallucinations](https://docs.anthropic.com/en/docs/test-and-evaluate/strengthen-guardrails/reduce-hallucinations)
- [Increase output consistency](https://docs.anthropic.com/en/docs/test-and-evaluate/strengthen-guardrails/increase-consistency)

### Anthropicエンジニアリングブログ
- [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
- [Context engineering: memory, compaction, and tool clearing (Cookbook)](https://platform.claude.com/cookbook/tool-use-context-engineering-context-engineering-tools)
