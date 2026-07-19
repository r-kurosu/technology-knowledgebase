# データ基盤アーキテクチャ

データ基盤全体の設計思想を掴む章。個別技術に入る前に、なぜ業務システムと分析基盤を分けるのか、なぜLakehouseという形に至ったのか、内部をどう層に分けるのかを理解する。

## 学習する順番

1. [データ基盤の全体像](01_data_platform_overview.md)
2. [Data Lake・DWH・Lakehouse](02_datalake_dwh_lakehouse.md)
3. [レイヤー設計とメダリオンアーキテクチャ](03_layered_architecture.md)

## 全体のつながり

1. 業務システムと分析基盤を分ける理由から出発し、収集→保存→変換→提供の流れを掴む
2. Data Lake→DWH→Lakehouseという進化を課題ドリブンで追い、SaaS型基盤でデータと処理がどこに置かれるかも確認する
3. 基盤内部のデータの流れを層（Bronze/Silver/Gold）で構造化する設計原則を理解する

## 分類の境界

- OLTP側のDB設計は it-fundamentals の 05_database で扱う
- テーブルフォーマットの仕組みは 02_storage_and_table_formats、各層の変換の実装は 05_transformation_and_orchestration で扱う

## 主な実装例

Databricks Lakehouse Platform（コントロールプレーン/コンピュートプレーン）、S3+Glue+Athena、Redshift、Snowflake（対照例）。

## 到達目標

- 「なぜ業務DBとは別に分析基盤を作るのか」「Lakehouseとは何か」を30秒で説明できる
- 要件に応じてData Lake/DWH/Lakehouseを比較・選択できる
- 層を分ける設計判断と各層の責務を説明できる
