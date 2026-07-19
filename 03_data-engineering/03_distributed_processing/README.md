# 分散データ処理

データ基盤の処理エンジンを理解する章。デファクトであるSparkを題材に、書いたコードがクラスタ上でどう並列実行されるかを理解し、性能問題を自力で切り分けられる状態を目指す。

## 学習する順番

1. [分散処理エンジンとSpark](01_distributed_processing_and_spark.md)
2. [DataFrameとSQLによる処理](02_dataframe_and_sql.md)
3. [パフォーマンスとチューニング](03_performance_and_tuning.md)

## 全体のつながり

1. どこからが分散処理の出番かを見極め、Driver/Executor構造と遅延評価・DAGの実行モデルを理解する
2. DataFrame/SQLで書いたコードがオプティマイザを経て物理プランになる流れを理解する
3. 実行時のボトルネック（シャッフル、スキュー）を特定し、対処できるようになる

## 分類の境界

- 分散システムの一般論（レプリケーション、合意、耐障害性）は it-fundamentals の 06_distributed_systems で扱う
- ストリーム処理は 04_ingestion_and_streaming で扱う
- クラスタの種類・コストの選択は 08_operations_and_cost、BI向けクエリの最適化は 06_analytics_and_bi で扱う

## 主な実装例

DatabricksのマネージドSparkクラスタ、Spark UI、AQE、Photon。AWSならEMR、Glue（いずれもSparkベース）。単一マシン側の対照例としてpandas、DuckDB。

## 到達目標

- 1つのクエリがクラスタ上でどう並列実行されるかを説明できる
- シャッフルが何で、なぜ高コストかを説明できる
- 遅いジョブの原因をシャッフル、スキュー、リソースの観点で切り分けられる
