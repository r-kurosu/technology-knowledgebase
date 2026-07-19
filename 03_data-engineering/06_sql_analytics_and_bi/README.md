# SQL分析とBI

データの出口の章。作ったデータを分析者・ビジネスユーザーに使わせるためのコンピュート（SQL Warehouse）、性能設計、提供方式を理解する。

## 学習する順番

1. [SQLウェアハウス](01_sql_warehouse.md)
2. [クエリ性能と提供の最適化](02_query_performance_and_serving.md)
3. [BIツール連携とAI/BI](03_bi_tools_and_genie.md)

## 全体のつながり

1. BI・アドホック分析向けの専用コンピュートであるSQL Warehouseの種類と使い分けを理解する
2. ダッシュボードを速く安く保つための、キャッシュ・マテリアライズドビュー・事前集計を理解する
3. 外部BIツール、内蔵ダッシュボード、Genie（自然言語）といった利用者への提供経路を設計する

## 分類の境界

- DWH・分析クエリの基礎概念は it-fundamentals の 05_database で扱う
- Sparkジョブ（バッチ処理）のチューニングは 03_spark_and_distributed_processing で扱い、ここではBI向けクエリの性能を扱う
- 誰がどのデータを見られるかは 07_governance_and_unity_catalog で扱う

## 主な実装例

SQL Warehouse（Serverless/Pro/Classic）、クエリプロファイル、マテリアライズドビュー、AI/BIダッシュボード、Genie。AWS側ではRedshift、Athena、QuickSightが対応する。

## 到達目標

- BI用途に専用Warehouseを使う理由と、種類・サイズの選択基準を説明できる
- ダッシュボードが遅いときの対処順を説明できる
- 利用者像（アナリスト/ビジネスユーザー/外部システム）ごとに提供方式を選択できる
