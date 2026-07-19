# technology-knowledgebase

ITの基礎知識をMarkdownで体系化した学習ノート。個人用途。

## 構成

- `01_it-fundamentals/` — IT基礎（ネットワーク・セキュリティ・コンピュート等、10分野）。`99_learning_system/` に学習ルール・テンプレート
- `02_ai-engineering/` — AIプロバイダー別のAPI・ベストプラクティスノート（anthropic / openai / google）
- `03_data-engineering/` — データエンジニアリング：Lakehouse・分散処理・ガバナンス等8テーマ（概念主題、実装例はDatabricks第一+AWS/OSS）
- `04_business-domains/` — 業務ドメインの概念（ERP / CRM / SCM / PLM）
- `05_sap/` — SAP（業務ドメインを実装する具体システム）
- `06_fde-roadmap/` — Forward Deployed Engineer ロールのスキル・学習ロードマップ
- `07_security/` — セキュリティ専門編（`01_it-fundamentals/02_security` は基礎編）

## 学習ノートの共通ルール

- ノートは `01_it-fundamentals/99_learning_system/output_template.md` の7セクション構成に従う（`03_data-engineering/` ではセクション3を「Databricks/AWSでの実装例」と読み替える）
- **保護セクション**: セクション6（自分の言葉で説明）・セクション7（理解確認）、および「自分で書く」「AIは勝手に埋めない」と記載された箇所は、明示的に依頼されない限りAIが追記・置換・要約しない
- レビューは本文を直接書き換えず、コメント・指摘形式で返す。修正案は参考として示し、最終版は本人が書く
- 詳細は `01_it-fundamentals/99_learning_system/ai_usage_rules.md` を参照

## 勉強セッションの進め方

「今日の勉強を始めましょう」等で開始したら、次の流れで進める。

1. 各テーマのREADMEと、ノートのセクション7「現在の理解度」欄から現在の学習位置を特定する
2. 今日のテーマを提示し、対話形式で概念説明・Q&Aを進める（一方的な長文説明にしない）
3. ノートは一気に埋めず、チャットで理解が固まった内容から都度該当ノートに反映する（保護セクションを除く）
4. 議論の結論・気づき・比較ポイントを話しっぱなしにせず、必ずノートに残す

## git

- 個人ノートのリポジトリなので、mainブランチに直接コミット・プッシュしてよい
- Claude Codeは終了時フックで自動コミットされる。フックのない環境（Codex等）では、セッション終了時に変更をcommit & pushすること

## 禁止

- 個人情報・プロジェクト固有情報をこのリポに含めない
- 出典未確認の内容を確定事項として書かない
- 実施していない検証・経験を実績として記載しない
