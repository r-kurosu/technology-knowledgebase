# Data Lake・DWH・Lakehouse

## 1. 概念理解

### 学ぶ範囲

Data Lake、DWH、Lakehouseそれぞれの定義と成り立ち、Lake+DWHの2層構成の課題、Lakehouseが解決すること。SaaS型基盤でデータと処理がどこに置かれるか（コントロールプレーンとコンピュートプレーン）。

## 2. 選択肢の比較

<!-- Data Lake/DWH/Lakehouseを、扱えるデータの種類、スキーマ、性能、ガバナンス、コストで比較する -->

## 3. Databricks/AWSでの実装例

DatabricksはLakehouseの代表例で、コントロールプレーン（Databricks側）とコンピュートプレーン（自社AWSアカウント側）に分かれる。AWSならS3+Glue+Athena（Lake側）、Redshift（DWH側）。SnowflakeはDWH起点でLakehouse化した対照例。

## 4. アーキテクチャ図

<!-- Lake+DWHの2層構成とLakehouse構成の違いを表す -->

## 5. 設計トレードオフ

<!-- データ重複、整合性、移行コスト、ベンダーロックインを考える -->

## 6. 自分の言葉で説明

<!-- 「Lakehouseとは何か」を30秒で説明する -->

## 7. 理解確認

### 到達目標

要件に応じてData Lake、DWH、Lakehouseを比較・選択でき、データの置き場所を説明できる。

### 現在の理解度

<!-- A：説明できる / B：見れば分かる / C：まだ怪しい -->
