# 運用とコスト

基盤を安定して安く動かし続ける章。コンピュートとコストの管理、デプロイ（CI/CD）、監視・障害対応を理解する。it-fundamentals の 08_operations_observability、09_iac_devops、10_cost_optimization のデータ基盤版にあたる。

## 学習する順番

1. [コンピュート管理とコスト](01_compute_and_cost.md)
2. [CI/CDと環境管理](02_cicd_and_environments.md)
3. [監視と信頼性](03_monitoring_and_reliability.md)

## 全体のつながり

1. コンピュート形態（常設/ジョブ単位/サーバーレス）の使い分けと、課金構造（プラットフォーム課金+クラウド課金）の分解を理解する
2. パイプラインのコードをdev/stg/prodへ安全に出すデプロイフローを作る
3. ジョブ失敗とデータ遅延を検知し、再実行・バックフィルで復旧する運用を設計する

## 分類の境界

- 監視・IaC・コスト最適化の一般論は it-fundamentals の該当テーマで扱い、ここではデータ基盤固有の運用を扱う
- ジョブの依存関係・リトライの設計は 05_transformation_and_orchestration で扱い、ここでは監視・復旧の運用を扱う
- データ品質の監視は 07_data_governance で扱い、ここではジョブ・リソース・コストの監視を扱う

## 主な実装例

DatabricksならAll-purpose/Jobクラスタ、サーバーレス、クラスタポリシー、DBU課金、Asset Bundles、system tables、SQLアラート。AWSならEC2スポット、Graviton、CloudWatch、コスト配分タグ。Terraform、GitHub Actions。

## 到達目標

- 用途ごとにコンピュート形態を選択し、コストの内訳を分解して説明できる
- データパイプラインのデプロイフロー（Git→dev/stg/prod）を設計できる
- 「朝データが更新されていない」ときの調査手順を説明できる
