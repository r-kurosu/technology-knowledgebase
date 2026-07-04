# Domain 2: Claude Code Configuration & Workflows (20%)

---

## 1. CLAUDE.md 階層構造とメモリシステム

### CLAUDE.md の配置場所と読み込みタイミング

| 配置場所 | スコープ | 読み込みタイミング |
|---|---|---|
| `~/.claude/CLAUDE.md` | ユーザーグローバル（全プロジェクト共通、個人用） | セッション開始時に即座に読み込み |
| `.claude/CLAUDE.md`（プロジェクトルート） | プロジェクト全体（チーム共有、バージョン管理対象） | セッション開始時に即座に読み込み |
| `CLAUDE.local.md` | ローカル専用（個人用、git管理外） | セッション開始時に即座に読み込み |
| 作業ディレクトリ上位の `CLAUDE.md` | 上位ディレクトリのコンテキスト | 起動時にフルロード |
| サブディレクトリの `CLAUDE.md` | サブディレクトリ固有 | **オンデマンド**（Claudeがそのディレクトリのファイルを読む際に遅延読み込み） |

### Compaction（圧縮）時の動作（試験頻出）
- **プロジェクトルートの CLAUDE.md**: `/compact` 後にディスクから再読み込みされ、セッションに再注入される
- **サブディレクトリの CLAUDE.md**: 自動的には再注入されない。次にそのディレクトリのファイルをClaudeが読む際に再読み込み
- `/compact` にフォーカスを指定可能（例: `/compact focus on the API changes`）

### ベストプラクティス
- CLAUDE.md には**普遍的な標準**（コーディング規約、アーキテクチャ方針）を記載
- タスク固有の手順は CLAUDE.md に入れない（スキルに配置）
- 200行を超えるファイルはコンテキストを消費し遵守率が低下 → `@path` インポートで分割するか `.claude/rules/` に分散
- `/clear` で無関係なタスク間のコンテキストをリセット

---

## 2. .claude/rules/ ディレクトリとパス固有ルール

### 基本構造
- `.claude/rules/` ディレクトリにMarkdownファイルを配置
- 各ファイルは1つのトピック（例: `testing.md`, `api-design.md`）
- サブディレクトリでの再帰的発見をサポート
- シンボリックリンクをサポート（複数プロジェクトでルール共有可能）

### Glob パターンによるパス固有ルール（試験重要）

```yaml
---
paths:
  - "src/**/*.{ts,tsx}"
  - "lib/**/*.ts"
---
TypeScript のコーディング規約をここに記述...
```

- `paths` フィールドなし → 全ファイルに無条件適用
- `paths` フィールドあり → パターンにマッチするファイルをClaudeが読むときにのみトリガー

---

## 3. カスタムスラッシュコマンドとスキル

### レガシーコマンド vs スキル

| 項目 | レガシーコマンド | スキル（推奨） |
|---|---|---|
| 配置場所（プロジェクト） | `.claude/commands/` | `.claude/skills/<name>/SKILL.md` |
| 配置場所（個人） | `~/.claude/commands/` | `~/.claude/skills/<name>/SKILL.md` |
| 自律起動 | 不可 | 可能（frontmatterで設定） |
| サポートファイル | なし | ディレクトリ内に配置可能 |

### SKILL.md のフロントマター構成（試験頻出）

```yaml
---
name: review
description: コードレビューを実行する
disable-model-invocation: false
user-invocable: true
---
# レビュー手順
ここにスキルの指示を記述...
```

**重要なフロントマターオプション**:
- `name`: `/slash-command` の名前になる
- `description`: Claudeが自動的にスキルを選択する際の判断基準
- `disable-model-invocation: true`: ユーザーのみが起動可能（副作用のあるワークフロー向け: `/commit`, `/deploy` など）
- `user-invocable: false`: Claudeのみが起動可能（バックグラウンド知識用）

### `$ARGUMENTS` 文字列
コマンドファイル内で `$ARGUMENTS` を使用すると、スラッシュコマンドに渡された引数がその位置に展開される。

---

## 4. 設定ファイル（settings.json）の階層と優先順位

### 4つのスコープ（優先順位: 高→低）

| 優先順位 | スコープ | ファイルパス | 説明 |
|---|---|---|---|
| 1（最高） | Managed | managed-settings.json（サーバー配信/MDM/レジストリ） | 組織ポリシー。**上書き不可** |
| 2 | コマンドライン引数 | `--allowedTools` 等 | セッション一時的なオーバーライド |
| 3 | Local | `.claude/settings.local.json` | 個人のプロジェクト固有設定（git管理外） |
| 4 | Project | `.claude/settings.json` | チーム共有設定（ソース管理対象） |
| 5（最低） | User | `~/.claude/settings.json` | 個人のグローバル設定 |

### マージ動作（試験重要）
- **配列設定は結合（マージ）される**: `permissions.allow` や `sandbox.filesystem.allowWrite` など配列値の設定は、全スコープの値が**連結・重複排除**される（置換ではない）
- **deny ルールは常に優先**: いずれかのレベルで deny されたツールは、他のレベルで allow できない
- **Managed設定は上書き不可**（`--allowedTools` でも覆せない）

---

## 5. パーミッション（権限）設定

### ルール評価順序
**deny → ask → allow**（最初にマッチしたルールが適用）

ルール構文: `Tool` または `Tool(specifier)` （例: `Bash(npm run *)`, `Edit(src/**/*.ts)`）

### パーミッションモード（試験頻出）

| モード | 説明 |
|---|---|
| `default` | 標準のパーミッション動作 |
| `acceptEdits` | ファイル編集を自動承認 |
| `plan` | 読み取り専用ツールのみ。コード変更なし |
| `bypassPermissions` | 全パーミッションチェックをバイパス |
| `dontAsk` | プロンプトなし。事前承認されていなければ拒否 |
| `auto` | モデル分類器が各ツールコールを承認/拒否 |

**セッション中の切り替え**: `Shift+Tab` で `default → acceptEdits → plan` を循環

### サンドボックス
- Bash ツールとその子プロセスに対する OS レベルのファイルシステム・ネットワークアクセス制限
- **多層防御**: パーミッション deny ルール（Claudeの判断をブロック）+ サンドボックス制限（プロンプトインジェクション時も物理的にブロック）

---

## 6. Hooks（フック）システム

### フックイベント一覧

| イベント | タイミング | 制御可能性 |
|---|---|---|
| `PreToolUse` | ツール実行前 | ブロック可能、入力修正可能 |
| `PostToolUse` | ツール成功後 | ブロック可能（実行済みのため取り消し不可） |
| `PostToolUseFailure` | ツール失敗後 | 通知用 |
| `UserPromptSubmit` | ユーザープロンプト送信時 | ブロック可能 |
| `SessionStart` | セッション開始時 | - |
| `SessionEnd` | セッション終了時 | - |
| `Stop` | Claude応答完了時 | ブロック可能 |
| `SubagentStart` | サブエージェント生成時 | - |
| `SubagentStop` | サブエージェント終了時 | ブロック可能 |
| `Notification` | 通知送信時 | - |
| `PreCompact` | 圧縮前 | - |

### フックの終了コード（試験重要）
- `exit 0` → アクション続行
- `exit 2` → アクションブロック（stderrに理由を出力）
- その他の終了コード → アクション続行

---

## 7. CI/CD パイプライン統合（試験直接出題）

### ヘッドレスモード（-p フラグ）
`-p` (または `--print`) フラグはClaude Codeを**非対話モード**で実行する。これがないとCIジョブは入力待ちでハングする。

```bash
claude -p "コードをレビューして問題を報告してください"
```

### ベアモード（Bare Mode）
CI やスクリプトで**全マシンで同じ結果を得る**ために使用。`~/.claude` のフックやプロジェクトの `.mcp.json` の MCP サーバーは実行されない。

### 同期 API vs Batch API（試験重要な使い分け）

| 方式 | 用途 |
|---|---|
| 同期 API | ブロッキングワークフロー（マージ前チェック、開発者が待つ処理） |
| Batch API | レイテンシー許容型ワークフロー（夜間レポート、週次監査、テスト生成）|

### GitHub Actions / GitLab CI/CD
- `Claude Code Action v1` を使用
- `claude_args` パラメータでCLI引数を渡す
- `.gitlab-ci.yml` にジョブを追加
- `CLAUDE.md` または `REVIEW.md` でレビュー基準をカスタマイズ可能

---

## 8. Plan Mode（計画モード）

- 読み取り専用ツールのみ使用（ファイル編集なし）
- `Shift+Tab` を2回押して切り替え
- `Ctrl+G` で計画をテキストエディタで直接編集可能

### 使い分けの判断基準
- **Plan Mode**: 複雑なタスク、スコープが不明確な変更、アーキテクチャ的な決定
- **直接実行**: タイポ修正、ログ行の追加、変数のリネームなど

---

## 9. チェックポイント & /rewind（試験新出）

各コード変更の前に自動でコードステートを保存するチェックポイントシステム。

### 操作方法
- **Esc × 2** または `/rewind` コマンドで直前のチェックポイントに即座に巻き戻し
- 大規模なワイドスケールタスクを安心して実行可能にする安全網

### 重要な試験ポイント
- チェックポイントは**ツール実行前**に自動作成（ユーザー操作不要）
- チェックポイントとパーミッション機能は独立して機能する

---

## 10. /ultrareview

専用レビューセッションを起動するスラッシュコマンド。変更箇所を読み込み、バグと設計上の問題をフラグする。

```
/ultrareview
/ultrareview <PR番号>    # GitHubのPRを直接レビュー
```

- Proプランおよびそれ以上のユーザーが利用可能
- 内部的に複数の専門エージェントを並列で動かし、包括的なレビューを生成

---

## 11. Auto Mode（自律実行モード）

Claude Codeがより少ない中断でより長いタスクを自律的に実行するモード。

- Maxプランのユーザーに拡張
- 決定を代替してより長いタスクを継続実行

---

## 12. その他のUI・UX改善

| 機能 | 説明 |
|---|---|
| `Ctrl+r` | **プロンプト履歴の検索**。過去のプロンプトを再利用・編集可能 |
| `xhigh` effort | Claude Codeのデフォルト effortレベルを `xhigh` に引き上げ（Opus 4.7対応） |
| ターミナルUI刷新 | ステータス視認性の向上 |

---

## 参考リンク

### 公式ドキュメント
- [Claude Code settings](https://code.claude.com/docs/en/settings)
- [How Claude remembers your project (Memory)](https://code.claude.com/docs/en/memory)
- [Explore the .claude directory](https://code.claude.com/docs/en/claude-directory)
- [Configure permissions](https://code.claude.com/docs/en/permissions)
- [Choose a permission mode](https://code.claude.com/docs/en/permission-modes)
- [Sandboxing](https://code.claude.com/docs/en/sandboxing)
- [Hooks reference](https://code.claude.com/docs/en/hooks)
- [Automate workflows with hooks](https://code.claude.com/docs/en/hooks-guide)
- [Extend Claude with skills](https://code.claude.com/docs/en/skills)
- [Slash commands](https://code.claude.com/docs/en/slash-commands)
- [Run Claude Code programmatically](https://code.claude.com/docs/en/headless)
- [Claude Code GitHub Actions](https://code.claude.com/docs/en/github-actions)
- [Claude Code GitLab CI/CD](https://code.claude.com/docs/en/gitlab-ci-cd)
- [Code Review](https://code.claude.com/docs/en/code-review)
- [Create custom subagents](https://code.claude.com/docs/en/sub-agents)
- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices)

### 公式試験ガイドPDF
- [Exam Guide PDF](https://everpath-course-content.s3-accelerate.amazonaws.com/instructor/8lsy243ftffjjy1cx9lm3o2bw/public/1773274827/Claude+Certified+Architect+%E2%80%93+Foundations+Certification+Exam+Guide.pdf)
