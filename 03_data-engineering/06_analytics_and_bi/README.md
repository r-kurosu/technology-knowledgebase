# 分析クエリとBI

データの出口の章。作ったデータを分析者・ビジネスユーザーに使わせるためのクエリエンジンの選択、性能設計、提供方式を理解する。

## 学習する順番

1. [分析クエリエンジンとDWH](01_analytics_query_engines.md)
2. [BI提供とクエリ性能](02_bi_serving_and_performance.md)

## 全体のつながり

1. MPP、ストレージとコンピュートの分離、サーバーレスといった分析クエリエンジンの方式と使い分けを理解する
2. その上で、BIツールへの提供経路と、ダッシュボードを速く安く保つ設計（キャッシュ、マテリアライズドビュー、事前集計）を学ぶ

## 分類の境界

- DWH・分析クエリの基礎概念は it-fundamentals の 05_database で扱う
- バッチ処理（Sparkジョブ）のチューニングは 03_distributed_processing で扱い、ここではBI向けクエリの性能を扱う
- 誰がどのデータを見られるかは 07_data_governance で扱う

## 主な実装例

DatabricksならSQL Warehouse（Serverless/Pro/Classic）、AI/BIダッシュボード、Genie、マテリアライズドビュー。AWSならRedshift、Athena、QuickSight。ほかSnowflake、BigQuery、Trino、Tableau。

## 到達目標

- DWH型とLake上のクエリエンジンを比較し、要件から選択できる
- ダッシュボードが遅いときの対処順を説明できる
- 利用者像（アナリスト/ビジネスユーザー/外部システム）ごとに提供方式を選択できる
