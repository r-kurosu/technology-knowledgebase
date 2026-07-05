# Claude Code Configuration & Workflows

Claude Code の設定（CLAUDE.md・スキル・権限・フック）と CI/CD 連携に関するノート。

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

### Compaction（圧縮）時の動作- **プロジェクトルートの CLAUDE.md**: `/compact` 後にディスクから再読み込みされ、セッションに再注入される
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

### Glob パターンによるパス固有ルール
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

### SKILL.md のフロントマター構成
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

### マージ動作- **配列設定は結合（マージ）される**: `permissions.allow` や `sandbox.filesystem.allowWrite` など配列値の設定は、全スコープの値が**連結・重複排除**される（置換ではない）
- **deny ルールは常に優先**: いずれかのレベルで deny されたツールは、他のレベルで allow できない
- **Managed設定は上書き不可**（`--allowedTools` でも覆せない）

---

## 5. パーミッション（権限）設定

### ルール評価順序
**deny → ask → allow**（最初にマッチしたルールが適用）

ルール構文: `Tool` または `Tool(specifier)` （例: `Bash(npm run *)`, `Edit(src/**/*.ts)`）

### パーミッションモード
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

<!-- 一言説明、30秒説明、採用理由を自分で書く -->

## 7. CI/CD パイプライン統合

<!-- 判断問題への回答、疑問、理解度（A/B/C）を残す -->
