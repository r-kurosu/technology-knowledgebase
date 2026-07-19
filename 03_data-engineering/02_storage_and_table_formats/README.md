# ストレージ層とテーブルフォーマット

データ基盤の土台であるストレージ層を理解する章。オブジェクトストレージ上のファイルにすぎないものが、なぜテーブルとして扱え、ACIDが効くのかを仕組みから理解する。

## 学習する順番

1. [列指向フォーマット](01_columnar_formats.md)
2. [オープンテーブルフォーマット](02_open_table_formats.md)
3. [テーブル設計とメンテナンス](03_table_design_and_maintenance.md)

## 全体のつながり

1. 分析に列指向（Parquet）が向く理由を、ファイル構造から理解する
2. その上にトランザクションログ/メタデータ層を載せたものがテーブルフォーマット（Delta Lake/Iceberg/Hudi）であり、ACID・タイムトラベル・スキーマ進化が可能になる
3. テーブルを速く保つための物理設計（パーティショニング/クラスタリング）とメンテナンス（コンパクション等）を学ぶ

## 分類の境界

- オブジェクトストレージ自体の基礎（S3、耐久性、ストレージクラス）は it-fundamentals の 04_storage で扱う
- テーブルをどう処理するかは 03_distributed_processing、誰がアクセスできるかは 07_data_governance で扱う

## 主な実装例

Parquet。Delta Lake（Databricksの標準、OPTIMIZE/VACUUM/Liquid Clustering）、UniForm。AWS側はGlue Data Catalog/Athena/EMRのIceberg対応。

## 到達目標

- 「S3上のファイルなのにACIDが効く仕組み」を説明できる
- 小さいファイル問題の原因と対処を説明できる
- テーブルフォーマットの選択が何を左右するかを説明し、要件から選べる
