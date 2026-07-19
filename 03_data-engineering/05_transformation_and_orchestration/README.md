# 変換とオーケストレーション

取り込んだデータを使える形に変換し、パイプラインとして安定的に流す章。変換の設計（何をどの層でやるか）と、実行の設計（依存・リトライ・再実行）を分けて理解する。

## 学習する順番

1. [ETL/ELTとデータモデリング](01_etl_elt_and_data_modeling.md)
2. [宣言的な変換パイプライン](02_declarative_pipelines.md)
3. [オーケストレーション](03_orchestration.md)

## 全体のつながり

1. ETL/ELTの違いと、層ごとの変換責務、分析用テーブルのモデリング（スタースキーマ、SCD）を理解する
2. その変換を宣言的に記述する考え方（dbtに代表される）と、品質チェックの組み込みを理解する
3. パイプライン全体の実行を、依存関係・トリガー・リトライ・バックフィルを含めて設計する

## 分類の境界

- 取り込み（Bronzeまで）は 04_ingestion_and_streaming で扱い、ここではそれ以降の変換を扱う
- パイプラインに埋め込む品質チェックの考え方はここ、品質の監視・リネージは 07_data_governance で扱う
- ジョブが使うコンピュートの管理・コストは 08_operations_and_cost で扱う

## 主な実装例

dbt（宣言的変換の代表）、Airflow（汎用オーケストレータ）。DatabricksならSQL/PySparkのELT、Lakeflow Declarative Pipelines（旧Delta Live Tables）、Lakeflow Jobs（旧Workflows）。AWSならGlue、MWAA、Step Functions。

## 到達目標

- 「なぜ今はELTが主流なのか」を説明できる
- スタースキーマとSCDを使った分析用テーブルのモデリングを設計できる
- 命令的な実装と宣言的パイプラインを使い分けられる
- 失敗時の再実行範囲とバックフィルを考慮したジョブ設計ができる
