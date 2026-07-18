# IT Fundamentals Learning

## このリポジトリの目的

汎用的なIT知識と設計力を体系的に学び、自分の言葉で説明・判断できる状態を目指す。AWSは学習の起点ではなく、概念を具体化するための実装例として使う。

## 学習方針
- 資格合格そのものではなく、実践的な場面で説明・判断できることを重視する
- AWSサービス名の暗記ではなく、概念と技術の使い分けを学ぶ
- 概念理解、選択肢の比較、AWSでの実装例、構成図、設計判断の順に理解を深める
- AI生成物を読むだけで終わらせず、自分のアウトプットを必ず残す
- 綺麗なノート作りより、説明可能性と実務への接続を優先する

## AIとの役割分担
AIは、概念説明のたたき台、AWSサービス対応表、Mermaid構成図、比較表、設計ミスの候補、理解確認用の質問、レビューを支援する。

一言説明、設計判断、30秒説明文、ユースケースへの接続文、弱点整理、理解確認への回答の最終版は自分で書く。詳細は [AI利用ルール](99_learning_system/ai_usage_rules.md) を参照する。

## ディレクトリ構成

```text
01_it-fundamentals/
├── 01_network/ ... 10_cost_optimization/   # 基礎となる10テーマ
└── 99_learning_system/                     # 学習原則・テンプレート（設定的な扱いのため末尾番号）
```

データ基盤・RAG/Agentなどの応用テーマは、リポジトリ直下の [`03_data-engineering/`](../03_data-engineering/) 以降で扱う。

## 学習する順番

1. [ネットワーク](01_network/README.md)
2. [セキュリティ](02_security/README.md)
3. [OS・コンピュート](03_compute/README.md)
4. [ストレージ](04_storage/README.md)
5. [データベース](05_database/README.md)
6. [分散システム・非同期処理](06_distributed_systems/README.md)
7. [可用性・バックアップ・DR](07_reliability/README.md)
8. [監視・ログ・運用](08_operations_observability/README.md)
9. [IaC・CI/CD](09_iac_devops/README.md)
10. [コスト最適化](10_cost_optimization/README.md)

最初は [`01_network/`](01_network/README.md) に取り組む。各テーマは最初から完成させず、[`output_template.md`](99_learning_system/output_template.md) の7項目に沿って少しずつ更新する。

大きなテーマはフォルダに分け、`README.md`を全体マップ、配下のファイルを学習単位とする。構成図、自分の説明、理解確認は対応する学習ファイル内に残す。

## このリポジトリで重視するアウトプット

- 自分の言葉による一言説明と30秒説明
- 要件と制約に基づく設計判断
- 構成図と、その構成を選んだ理由
- 理解確認用の判断問題への回答と弱点の更新
