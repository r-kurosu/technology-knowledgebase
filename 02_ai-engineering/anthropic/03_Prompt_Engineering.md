# Prompt Engineering & Structured Output

Claude のプロンプト設計・構造化出力・信頼性向上に関するノート。

---

## 1. このノートで扱うトピック

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

### 三層の信頼性モデル
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

### 重要ポイント
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

<!-- 一言説明、30秒説明、採用理由を自分で書く -->

## 7. プロンプトチェイニング (Prompt Chaining)

<!-- 判断問題への回答、疑問、理解度（A/B/C）を残す -->
