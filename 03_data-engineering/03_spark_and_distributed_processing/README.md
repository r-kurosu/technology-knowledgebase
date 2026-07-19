# Sparkと分散処理

Databricksの処理エンジンであるSparkを理解する章。書いたコードがクラスタ上でどう並列実行されるかを理解し、性能問題を自力で切り分けられる状態を目指す。

## 学習する順番

1. [Sparkのアーキテクチャ](01_spark_architecture.md)
2. [DataFrameとSpark SQL](02_dataframe_and_spark_sql.md)
3. [パフォーマンスとチューニング](03_performance_and_tuning.md)

## 全体のつながり

1. Driver/Executorの構造と、遅延評価・DAGによる実行モデルを理解する
2. DataFrame/SQLで書いたコードがオプティマイザを経て物理プランになる流れを理解する
3. 実行時のボトルネック（シャッフル、スキュー）を特定し、対処できるようになる

## 分類の境界

- 分散システムの一般論（レプリケーション、合意、耐障害性）は it-fundamentals の 06_distributed_systems で扱う
- ストリーム処理（Structured Streaming）は 04_data_ingestion で扱う
- クラスタのサイズ・種類の選択は 08_operations_and_cost で扱い、ここでは処理の中身に集中する
- BI向けSQLクエリの最適化は 06_sql_analytics_and_bi で扱う

## 主な実装例

Databricksクラスタ、PySpark、Spark SQL、EXPLAIN、Spark UI、AQE、Photon。AWS側ではEMR、Glue（Sparkベース）が対応する。

## 到達目標

- 1つのクエリがクラスタ上でどう並列実行されるかを説明できる
- シャッフルが何で、なぜ高コストかを説明できる
- 遅いジョブの原因をシャッフル、スキュー、リソースの観点で切り分けられる
