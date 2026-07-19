# データ取り込みとストリーミング

データを基盤に入れる入口の章。ソースの種類と鮮度要件から取り込み方式を選び、失敗しても安全に再実行できる設計を理解する。

## 学習する順番

1. [データ取り込みのパターン](01_ingestion_patterns.md)
2. [ストリーム処理](02_stream_processing.md)
3. [CDC（変更データキャプチャ）](03_cdc.md)

## 全体のつながり

1. Batch/Streamingの軸とソースの種類で取り込みパターンの全体地図を作り、冪等性・スキーマ変化・新着ファイル検知といった共通課題を押さえる
2. ストリーム処理を、チェックポイント・ウォーターマーク・exactly-onceといった整合性の仕組みから理解する
3. 業務DBの変更をCDCで反映する方式と、マネージドコネクタの位置づけを理解する

## 分類の境界

- 取り込んだ後の変換は 05_transformation_and_orchestration で扱う
- ストリーム処理の土台となる分散処理エンジンは 03_distributed_processing で扱う
- メッセージング・キューの一般論は it-fundamentals の 06_distributed_systems で扱う

## 主な実装例

DatabricksならCOPY INTO、Auto Loader、Structured Streaming、Lakeflow Connect。AWSならKinesis、MSK（Kafka）、DMS、Managed Service for Apache Flink。OSSならKafka、Debezium。

## 到達目標

- ソースと鮮度要件から、取り込み方式（Batch/Streaming/CDC）を選択できる
- 再実行しても壊れない（冪等な）取り込みの設計を説明できる
- チェックポイントによる障害復旧とexactly-onceの成立条件を説明できる
