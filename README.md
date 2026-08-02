# technology-knowledgebase

ITの基礎知識をMarkdownで体系化した学習ノート。

## 構成

| ディレクトリ | 内容 |
|------------|------|
| [`01_it-fundamentals/`](01_it-fundamentals/) | ネットワーク・セキュリティ・コンピュート・DB・分散システムなどIT基礎（10分野） |
| [`02_ai-engineering/`](02_ai-engineering/) | Anthropic・OpenAI・Google のAPI・ベストプラクティスノート |
| [`03_data-engineering/`](03_data-engineering/) | データ基盤アーキテクチャ・収集/処理・保存/DWH・ガバナンス/運用 |
| [`04_business-domains/`](04_business-domains/) | ERP・CRM・SCM・PLM などの業務ドメイン概念 |
| [`05_sap/`](05_sap/) | SAPモジュール（FI-CO・MM・PP・SD・BDC） |
| [`06_fde-roadmap/`](06_fde-roadmap/) | Forward Deployed Engineer スキル・学習ロードマップ |
| [`07_security/`](07_security/) | セキュリティ専門編（`01_it-fundamentals/02_security` が基礎編） |

## ブランチ

| ブランチ | 用途 |
|---------|------|
| `main` | 完成ノート。教科書として読む |
| `workbook-template` | 学習者向け雛形。セクション6・7（自分の言葉）が空 |

## 学習の進め方

各ノートは7セクション構成の[テンプレート](01_it-fundamentals/99_learning_system/output_template.md)に沿って書く。

| セクション | 書く人 |
|---|---|
| 1〜5（概念理解・選択肢の比較・AWSでの実装例・アーキテクチャ図・設計トレードオフ） | AIと対話しながら埋める |
| 6（自分の言葉で説明） | 自分で書く。AIは代筆しない |
| 7（理解確認） | 自分で書く。理解度をA/B/Cで記録 |

**1セッション＝1ノート、15分目安・最長30分。** Claude Code / Codex がまず確認質問で理解度（A/B/C）を判定し、そこから対話形式で進める。一方的に説明させず、理解が固まった内容から都度セクション1〜5に書き込む。セクションの途中で切り上げず、その日は次のテーマにも進まない。

- 比較する内容は文章ではなく表、構造や経路はMermaid図で書く
- 数値・上限・仕様は一次情報で裏取りし、出典URLを併記する
- AIの生成物を読んで満足しない。セクション6・7を自分で書いて初めて学習完了とする

## 学習者向け：使い方

1. このリポをfork
2. `workbook-template` ブランチをチェックアウト
3. `01_it-fundamentals/` から始める
4. Claude Code と対話しながら各ノートを埋めていく

詳細は [`01_it-fundamentals/99_learning_system/`](01_it-fundamentals/99_learning_system/) を参照。
