# 分析クエリエンジンとDWH

## 1. 概念理解

### 学ぶ範囲

MPPアーキテクチャ、ストレージとコンピュートの分離、サーバーレスクエリ、同時実行とスケーリング。DWHの基礎概念は it-fundamentals の 05_database を参照。

## 2. 選択肢の比較

<!-- DWH型（Redshift/Snowflake/BigQuery）とLake上のクエリエンジン（Athena/Trino/Databricks SQL）を比較する -->

## 3. Databricks/AWSでの実装例

DatabricksならSQL Warehouse（Serverless/Pro/Classic）。AWSならRedshift、Athena。

## 4. アーキテクチャ図

<!-- BIツールからクエリエンジン経由でテーブルを読む経路を表す -->

## 5. 設計トレードオフ

<!-- 起動待ち、アイドルコスト、同時実行数を考える -->

## 6. 自分の言葉で説明

<!-- 「BI用途になぜ専用のクエリエンジンを使うか」を説明する -->

## 7. 理解確認

### 到達目標

分析用クエリエンジンの方式とサイズを要件から選択できる。

### 現在の理解度

<!-- A：説明できる / B：見れば分かる / C：まだ怪しい -->
