# Tool Design & MCP Integration

ツール定義の設計・ツール境界・MCP（Model Context Protocol）連携に関するノート。

---

## 1. MCP (Model Context Protocol) の3つのコアプリミティブ

| プリミティブ | 制御主体 | 用途 |
|---|---|---|
| **Tools** | モデル制御 (Model-controlled) | Claudeが自律的に実行を判断する実行可能関数（DB操作、API呼出、ファイル書込など） |
| **Resources** | アプリケーション制御 (App-controlled) | 読み取り専用のデータソース（ファイル、スキーマ、ドキュメントなど） |
| **Prompts** | ユーザー制御 (User-controlled) | ユーザーアクション（ボタンクリック、スラッシュコマンド）で起動される定義済みワークフローテンプレート |

各プリミティブには `*/list`（発見）、`*/get`（取得）、`tools/call`（実行）のメソッドがある。MCPは **JSON-RPC 2.0** をRPCプロトコルとして使用。

---

## 2. ツール説明文（Tool Descriptions）の設計

> ツール説明文はClaudeがツールを選択する**主要なメカニズム**。ルーティングロジックでも分類器でもなく、descriptionが判断基準。

### 効果的なツール説明文に含めるべき要素
- **ツールの機能**: 何をするツールかの明確な説明
- **入力フォーマット**: 期待される入力形式と具体例
- **エッジケース**: 境界条件や例外的な入力への対処
- **類似ツールとの境界**: 似たツールとの明確な差別化
- **パラメータ記述**: 期待される型、範囲、制約

### ベストプラクティス
- **命名規約**: サービス名でプレフィックスを付ける（例: `github_list_prs`, `slack_send_message`）
- **高シグナル情報のみ返す**: 生の技術的IDではなく、意味のある安定した識別子を返す
- **トークン効率**: ページネーション、フィルタリング、切り詰めを実装
- Anthropicの知見: ツール説明文の小さな改善がSWE-bench Verifiedで最先端の性能を達成した実績あり

---

## 3. ツール境界と推論オーバーロード防止

### 1エージェントあたりのツール数
- **推奨: 4-5個/エージェント** が最適
- **14個以上のツールを1つのエージェントに与えると選択精度が著しく劣化**
- **ロールベースのスコーピング**が重要（合成エージェントにWeb検索ツールを与えない等）

### ツールスコーピングの原則
- 各サブエージェントには**特定のタスクに必要なツールのみ**を付与
- `allowedTools` パラメータでエージェントごとにアクセス可能なツールをフィルタリング
- ワイルドカードパターン対応（例: `mcp__claude-code-docs__*`）

---

## 4. 構造化エラーレスポンス

### isError フラグ
MCPツール結果の `isError` ブーリアンフィールド。**プロトコルレベルのエラー**と**アプリケーションレベルのエラー**を分離。

### エラー分類

| エラーカテゴリ | isRetryable | 対処 |
|---|---|---|
| **一時的 (Transient)**: タイムアウト、サービス不可用 | true | リトライ（バックオフ付き） |
| **バリデーション (Validation)**: 無効な入力 | false | 入力修正が必要 |
| **ビジネス (Business)**: ポリシー違反 | false | エスカレーション |
| **パーミッション (Permission)**: 認証失敗 | false | 権限確認/エスカレーション |
| **レートリミット**: API制限 | true（バックオフ後） | 遅延後にリトライ |

### 判断のポイント
**「ツール呼出が0件の結果を返した場合、それはリトライすべきアクセス障害か、それとも有効な空の結果か？」** → エラーレスポンスの構造（`isError`、`errorCategory`、`isRetryable`）によってコーディネーターが判断できるように設計する。

エラーの`content`にはスタックトレースではなく、**モデルが理解できる記述的なメッセージ**を含めるべき。

---

## 5. MCP サーバー設計とトランスポート

### トランスポートメカニズム

| トランスポート | 特徴 | 推奨度 |
|---|---|---|
| **stdio** | 同一マシン上のプロセス間通信。標準入出力を使用 | 最も推奨。最も互換性が高い |
| **Streamable HTTP** | 独立プロセスとして動作。複数クライアント接続対応 | モダンな標準 |
| **SSE (Server-Sent Events)** | 非推奨だが一部ツールでまだサポート | 非推奨 |

---

## 6. MCP設定（.mcp.json）

### 設定ファイルのスコープと優先順位

| スコープ | ファイルの場所 | 用途 |
|---|---|---|
| **プロジェクト（共有）** | `.mcp.json`（プロジェクトルート） | チーム共有、バージョン管理可能 |
| **プロジェクト（ローカル）** | `.claude/settings.local.json` | 個人用プロジェクト設定 |
| **ユーザー** | `~/.claude/settings.local.json` | 全プロジェクト共通の個人設定 |

**優先順位**: ローカル > プロジェクト > ユーザー

### 設定構造
```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-example"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

### 環境変数展開
- `.mcp.json` 内で `${VARIABLE_NAME}` 形式の環境変数参照が可能
- 未定義の変数は空文字列に解決される

---

## 7. ツールアノテーション（Tool Annotations）

| アノテーション | 意味 |
|---|---|
| `readOnlyHint` | 環境を変更しないか（trueなら自動承認の対象になりうる） |
| `destructiveHint` | 破壊的な変更を行うか（trueなら確認ダイアログ表示） |
| `idempotentHint` | 同じ引数で繰り返し呼出しても追加効果がないか |
| `openWorldHint` | 外部エンティティとやり取りするか |

---

## 8. Claude API ツール関連パラメータ

### tool_choice

| 値 | 動作 |
|---|---|
| `auto`（デフォルト） | Claudeがツール呼出の要否を自動判断 |
| `any` | 必ずいずれかのツールを使用 |
| `tool` | 特定のツールを強制使用 |
| `none` | ツール使用を禁止 |

### strict: true（厳格モード）
- JSON Schemaに基づく文法制約サンプリングでスキーマ準拠を保証
- 型の不一致（文字列"2"→整数2など）を防止
- `additionalProperties: false` と組み合わせ推奨
- 複雑度制限あり

### disable_parallel_tool_use
- `auto` + `disable_parallel_tool_use=true` → 最大1ツール使用
- `any`/`tool` + `disable_parallel_tool_use=true` → 正確に1ツール使用

### Extended Thinkingとの制約
- Extended Thinking使用時は `tool_choice: auto` と `none` のみ対応
- `any` や `tool` はエラーになる

---

## 理解確認チェックリスト

1. MCPの3プリミティブ（Tools/Resources/Prompts）の制御モデルの違いを即答できるか
2. 効果的なツール説明文の5要素を説明できるか
3. 1エージェント4-5ツールの原則と、その理由を理解しているか
4. isError、isRetryable、errorCategoryによる構造化エラーレスポンス設計ができるか
5. エラーの4分類とそれぞれの対処法を把握しているか
6. .mcp.jsonの3つのスコープと優先順位を暗記しているか
7. tool_choiceの4つのオプションの動作の違いを説明できるか
8. strict: trueの用途と制限を理解しているか
9. ツールアノテーションの各フラグの意味を知っているか
10. stdioとStreamable HTTPのトランスポートの違いと使い分けを理解しているか

---

## 参考リンク

### Anthropic公式ドキュメント
- [Tool Use Overview](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview)
- [Define Tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools)
- [Implement Tool Use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/implement-tool-use)
- [Strict Tool Use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/strict-tool-use)
- [Parallel Tool Use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/parallel-tool-use)
- [Claude Code MCP](https://code.claude.com/docs/en/mcp)
- [MCP Overview](https://docs.anthropic.com/en/docs/mcp)

### Anthropicエンジニアリングブログ（必読）
- [Writing Effective Tools for AI Agents](https://www.anthropic.com/engineering/writing-tools-for-agents)
- [Advanced Tool Use](https://www.anthropic.com/engineering/advanced-tool-use)
- [Code Execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp)

### Anthropic Academy
- [Introduction to Model Context Protocol](https://anthropic.skilljar.com/introduction-to-model-context-protocol)
- [MCP Advanced Topics](https://anthropic.skilljar.com/model-context-protocol-advanced-topics)

### MCP公式仕様
- [MCP Specification](https://modelcontextprotocol.io/specification/2025-11-25)
- [MCP Architecture](https://modelcontextprotocol.io/docs/learn/architecture)
- [MCP Transports](https://modelcontextprotocol.io/specification/2025-03-26/basic/transports)
