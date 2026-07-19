# Delta Lakeとストレージ層

Lakehouseの土台であるストレージ層を理解する章。S3上のファイルにすぎないものが、なぜテーブルとして扱え、ACIDが効くのかを仕組みから理解する。

## 学習する順番

1. [列指向フォーマットとParquet](01_columnar_formats_and_parquet.md)
2. [Delta Lakeの基本](02_delta_lake_fundamentals.md)
3. [テーブル設計とメンテナンス](03_table_design_and_maintenance.md)
4. [オープンテーブルフォーマット](04_open_table_formats.md)

## 全体のつながり

1. まず分析に列指向（Parquet）が向く理由を、ファイル構造から理解する
2. Parquetの上にトランザクションログを載せたものがDelta Lakeであり、ACID・タイムトラベル・スキーマ進化が可能になる
3. テーブルを速く保つための物理設計（クラスタリング）とメンテナンス（OPTIMIZE/VACUUM）を学ぶ
4. Delta以外の選択肢（Iceberg/Hudi）と相互運用（UniForm）を知り、ロックインの議論に備える

## 分類の境界

- オブジェクトストレージ自体の基礎（S3、耐久性、ストレージクラス）は it-fundamentals の 04_storage で扱う
- テーブルをどう処理するか（Spark）は 03_spark_and_distributed_processing、誰がアクセスできるか（権限）は 07_governance_and_unity_catalog で扱う

## 主な実装例

Parquet、Deltaテーブル、DESCRIBE HISTORY、OPTIMIZE、VACUUM、Liquid Clustering、UniForm。AWS側ではS3、Glue Data Catalog、Athenaからの読み取り。

## 到達目標

- 「S3上のファイルなのにACIDが効く仕組み」を説明できる
- 小さいファイル問題の原因と対処を説明できる
- テーブルフォーマットの選択が何を左右するかを説明し、要件から選べる
