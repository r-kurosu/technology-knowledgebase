# Domain 3: Prompt Engineering & Structured Output (20%)

---

## 1. 学習目標（公式）

1. 明示的な基準（Explicit Criteria）を用いたプロンプト設計
2. Few-shot プロンプティングによる出力の一貫性確保
3. tool_use と JSON Schema を用いた構造化出力の強制
4. バリデーション・リトライ・フィードバックループの実装
5. マルチパスレビューアーキテクチャ
6. Message Batches API の活用

---

## 2. 構造化出力 (Structured Output)

### プロンプトベース vs スキーマ強制の違い（最重要）

| 方式 | 信頼性 | 説明 |
|---|---|---|
| プロンプトベース | 低（非推奨） | `"output as JSON"` とプロンプトに書くだけ。保証なし |
| **スキーマ強制**（推奨） | 高 | JSON Schemaを文法にコンパイルし、推論時にトークン生成を制約 |

### 2つの構造化出力モード

| モード | パラメータ | 用途 |
|---|---|---|
| **JSON outputs** | `output_config.format` (type: `json_schema`) | データ抽出、レポート生成 |
| **Strict tool use** | ツール定義に `strict: true` を追加 | ツールパラメータのスキーマ検証 |

### レガシー方式（tool_use を使った構造化出力）
- `tool_use` + `JSON Schema` + `tool_choice` で特定ツールを強制
- スキーマをツールの `input_schema` としてラップし、`tool_choice: { type: "tool", name: "..." }` で強制使用

### SDK サポート
- Python: **Pydantic** でスキーマ定義可能
- TypeScript: **Zod** でスキーマ定義可能

---

## 3. JSON Schema 設計のベストプラクティス

- **Nullable フィールド**: `Optional` 型でデータが存在しない場合に `null` を許容 → **ハルシネーション削減に効果的**
- **Literal 型**: 列挙値（enum）の制約に使用

### 三層の信頼性モデル（試験頻出）
1. **構造的信頼性** (Structural Reliability): JSON Schema による構造の強制
2. **意味的信頼性** (Semantic Reliability): プログラム的バリデーション（メール形式、日付範囲など）
3. **回復メカニズム** (Recovery): リトライループ

---

## 4. Few-shot / Multishot プロンプティング

### ベストプラクティス（公式推奨）
- **例の数**: 3〜5個が最適
- **例の品質基準**:
  - **Relevant（関連性）**: 実際のユースケースに近いもの
  - **Diverse（多様性）**: エッジケースをカバーし、意図しないパターン学習を防ぐ
  - **Structured（構造化）**: `<example>` タグで囲む（複数なら `<examples>` タグ内に配置）

### 試験での重要ポイント
- 曖昧なケースを含む2〜4個のfew-shotの例を使い、**判断理由も含めて**示す
- `<thinking>` タグをfew-shot内に入れることで、Claudeの推論パターンをガイドできる

---

## 5. 明示的基準 (Explicit Criteria) の設計

> **「自信があるときだけ抽出して」は機能しない。** Claudeには校正された信頼度シグナルがないため、confidence-basedの指示は失敗する。

### 正しいアプローチ
- 「何がマッチに該当するか」を定義する
- 「何がマッチに該当しないか」を定義する
- エッジケースを名前で指定する
- 2〜4個のfew-shot例で曖昧なケースと判断理由を示す

### 重要原則
- `"be conservative"` のような曖昧な指示は偽陽性を減らさない
- **プログラム的な強制 > プロンプトベースのガイダンス**

---

## 6. バリデーション・リトライループ

### リトライ時のベストプラクティス（試験頻出）

> **汎用的なリトライメッセージではなく、具体的なエラー詳細を添付してリトライする。**

```
# 悪い例（汎用リトライ）
"The output was invalid. Please try again."

# 良い例（具体的リトライ）
"Validation failed: 'email' field contains 'not-an-email' 
 which does not match email format. Expected: valid email address."
```

具体的に含めるべき情報:
- **どのフィールド**でエラーが発生したか
- **どんなエラー**か
- **期待値 vs 実際の値**

---

## 7. プロンプトチェイニング (Prompt Chaining)

### 定義
複雑なタスクを複数の個別のClaude API呼び出しに分解し、各呼び出しの出力を次の入力に接続するワークフローパターン。

### 一般的なパターン
- **コンテンツ作成**: Research → Outline → Draft → Edit → Format
- **自己修正（最も一般的）**: Draft生成 → 基準に照らしてレビュー → レビューに基づいて改善

### 設計原則
- サブタスクを識別し、明確な順序で分解する
- XMLタグで出力を次のプロンプトに引き渡す
- 各ステップは単一の明確な目標を持つ
- 各ポイントでログ記録、評価、分岐が可能

---

## 8. マルチパスレビューアーキテクチャ

単一パスで包括的な分析を行うのではなく、**複数の焦点を絞ったパスでコンテンツをレビュー**する手法。
- 各パスは異なる品質基準に焦点を当てる
- パス間でフィードバックを蓄積する
- 最終パスで統合的な判断を行う

---

## 9. XML タグによるプロンプト構造化

Claudeは**XMLタグに特別に注意を払うようファインチューニング**されている。

### 推奨構造
```xml
<instructions>指示内容</instructions>
<context>文脈情報</context>
<examples>
  <example>例1</example>
  <example>例2</example>
</examples>
<input>入力データ</input>
```

### 4ブロックパターン
1. INSTRUCTIONS（指示）
2. CONTEXT（文脈）
3. TASK（タスク）
4. OUTPUT FORMAT（出力形式）

---

## 10. システムプロンプトとロール設定

### 推奨構造
```
You are: [役割 - 1行]
Goal: [成功の定義]
Constraints: [制約のリスト]
If unsure: 明確に言い、1つの確認質問をする
Output format: [JSON schema / 見出し構造 / 箇条書き]
```

---

## 11. Prefill（プリフィル）テクニック

アシスタントメッセージに初期テキストを含めることで、出力形式を強制する手法。

> **Claude 4.6 モデル以降、最後のアシスタントターンでのプリフィルはサポートされていない。** 代替として構造化出力やシステムプロンプト指示を使用すること。

---

## 12. 拡張思考 (Extended Thinking)

- `budget_tokens` で思考予算を制御（最小1,024トークン）
- **Claude Opus 4.6 / Sonnet 4.6 以降、`budget_tokens` は非推奨** → 代わりに `effort` パラメータによる**Adaptive Thinking**を使用
- 推奨トークン予算: ほとんどのユースケースで5,000-10,000、難問で20,000+

### effort パラメータの値（Adaptive Thinking）

| 値 | 説明 |
|----|------|
| `low` | 簡単な問題に素早く応答 |
| `medium` | バランス型 |
| `high` | デフォルト。複雑な問題で拡張思考を自動活用 |
| `xhigh` | **Opus 4.7で追加**。`high`と`max`の間の新レベル。推論とレイテンシのトレードオフを細かく制御。**Claude CodeはデフォルトをxhighにUP** |
| `max` | 最大限の思考予算を使用 |

---

## 13. tool_choice パラメータ

| 値 | 動作 |
|----|------|
| `auto` | Claudeがツール使用を自動判断（デフォルト） |
| `any` | 必ずいずれかのツールを使用する |
| `tool` (name指定) | 特定のツールを強制使用する |
| `none` | ツール使用を禁止する |

**試験ポイント**: `any` または `tool` を指定すると、Claudeはツール使用前に自然言語の応答を生成**しない**。

---

## 14. Message Batches API

- 最大10,000クエリ/バッチ、24時間以内に処理
- **標準APIより50%コスト削減**
- プロンプトキャッシュと組み合わせると最大95%削減
- **レイテンシ許容型ジョブのみ**に適用

---

## 15. プロンプトインジェクション対策

- **Harmlessness Screening**: Claude Haikuなどの軽量モデルでユーザー入力を事前スクリーニング
- **分類器ベースの検出**: 隠しテキスト、操作された画像、欺瞞的UI要素の攻撃を検出
- **多層防御**: モデル層のガードレールだけでは不十分

---

## 試験攻略のヒント

1. **「明示的であれ」(Be Explicit)** — このドメインのほとんどの正答は「最も明示的な選択肢」
2. **「confidence-based指示は機能しない」ことを覚えておく** — 選択肢に出たら不正解
3. **リトライは具体的なエラー情報を含める** — 汎用リトライメッセージは不正解
4. **プロンプトベース vs スキーマ強制** — 正規表現でのJSONパースは「脆弱」として不正解
5. **nullableフィールドがハルシネーション削減に役立つ**ことを理解する

---

## 参考リンク

### Anthropic公式ドキュメント
- [Prompt engineering overview](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview)
- [Be clear, direct, and detailed](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/be-clear-and-direct)
- [Use XML tags](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/use-xml-tags)
- [Multishot prompting](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/multishot-prompting)
- [Chain complex prompts](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/chain-prompts)
- [Prefill Claude's response](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prefill-claudes-response)
- [System prompts](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/system-prompts)
- [Structured outputs](https://platform.claude.com/docs/en/build-with-claude/structured-outputs)
- [Batch processing](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
- [Extended thinking](https://platform.claude.com/docs/en/build-with-claude/extended-thinking)
- [Mitigate jailbreaks](https://platform.claude.com/docs/en/test-and-evaluate/strengthen-guardrails/mitigate-jailbreaks)

### Anthropic Academy（無料）
- [Anthropic Academy (Skilljar)](https://anthropic.skilljar.com) — 13コース、全て無料、修了証付き

### GitHub
- [Anthropic Courses](https://github.com/anthropics/courses) — Jupyter Notebook形式のハンズオン教材
- [Anthropic Cookbook - Extracting Structured JSON](https://github.com/anthropics/anthropic-cookbook/blob/main/tool_use/extracting_structured_json.ipynb)
