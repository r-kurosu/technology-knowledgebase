# 運用とコスト

基盤を安定して安く動かし続ける章。コンピュートの管理、デプロイ（CI/CD）、監視・障害対応、コスト構造を理解する。it-fundamentals の 08_operations_observability、09_iac_devops、10_cost_optimization のDatabricks版にあたる。

## 学習する順番

1. [コンピュート管理](01_compute_management.md)
2. [CI/CDと環境管理](02_cicd_and_environments.md)
3. [監視と信頼性](03_monitoring_and_reliability.md)
4. [コストモデルと最適化](04_cost_model_and_optimization.md)

## 全体のつながり

1. クラスタ種別・サーバーレス・ポリシーで、用途に応じたコンピュートを整備する
2. notebookのコードをdev/stg/prodへ安全に出すデプロイフローを作る（Asset Bundles）
3. ジョブ失敗とデータ遅延を検知し、再実行・バックフィルで復旧する運用を設計する
4. DBU+AWSコストの構造を理解し、削減の打ち手を優先順位付けする

## 分類の境界

- 監視・IaC・コスト最適化の一般論は it-fundamentals の該当テーマで扱い、ここではDatabricks固有の運用を扱う
- ジョブの依存関係・リトライの設計は 05_transformation_and_orchestration で扱い、ここでは監視・復旧の運用を扱う
- データ品質の監視は 07_governance_and_unity_catalog で扱い、ここではジョブ・リソース・コストの監視を扱う

## 主な実装例

クラスタポリシー、インスタンスプール、サーバーレス、Databricks Asset Bundles、Terraform、system tables（billing/audit）、SQLアラート。AWS側ではEC2スポット、Graviton、CloudWatch、コスト配分タグ。

## 到達目標

- 開発用と本番ジョブ用でコンピュートをどう分けるかを説明できる
- データパイプラインのデプロイフロー（Git→dev/stg/prod）を設計できる
- 「朝データが更新されていない」ときの調査手順を説明できる
- Databricksのコストがどこで発生するかを分解して説明し、削減策を提案できる
