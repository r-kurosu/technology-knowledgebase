# Lakehouseとアーキテクチャ

データ基盤全体の設計思想を掴む章。個別機能に入る前に、なぜLakehouseという形に至ったのか、DatabricksがAWS上でどういう構造で動くのかを理解する。

## 学習する順番

1. [データ基盤の全体像](01_data_platform_overview.md)
2. [Data Lake・DWH・Lakehouse](02_datalake_dwh_lakehouse.md)
3. [メダリオンアーキテクチャ](03_medallion_architecture.md)
4. [DatabricksのアーキテクチャとAWS構成](04_databricks_architecture_on_aws.md)

## 全体のつながり

1. 業務システムと分析基盤を分ける理由から出発する
2. Data Lake→DWH→Lakehouseという進化を、課題ドリブンで追う
3. Lakehouse内部のデータの流れをメダリオン（Bronze/Silver/Gold）で構造化する
4. それがDatabricks+AWSの実際のリソース（コントロールプレーン/コンピュートプレーン、S3、IAM）にどう対応するかを確認する

## 分類の境界

- OLTP側のDB設計は it-fundamentals の 05_database で扱う
- Delta Lakeの仕組みの詳細は 02_delta_lake_and_storage、コンピュートの運用詳細は 08_operations_and_cost で扱う
- メダリオン各層の変換の実装は 05_transformation_and_orchestration で扱う

## 主な実装例

Databricksワークスペース、コントロールプレーン/コンピュートプレーン、サーバーレスコンピュート、S3、クロスアカウントIAM Role、customer-managed VPC。

## 到達目標

- 「Lakehouseとは何か」「なぜDWHだけでは足りないのか」を30秒で説明できる
- メダリオン各層の責務と利用者を説明できる
- Databricksの処理とデータがどのAWSアカウント・リソース上にあるかを図で説明できる
