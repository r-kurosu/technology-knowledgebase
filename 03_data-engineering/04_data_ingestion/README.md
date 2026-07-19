# データ取り込み

データを基盤に入れる入口の章。ソースの種類と鮮度要件から取り込み方式を選び、失敗しても安全に再実行できる設計を理解する。

## 学習する順番

1. [データ取り込みのパターン](01_ingestion_patterns.md)
2. [ファイル取り込みとAuto Loader](02_auto_loader_and_file_ingestion.md)
3. [Structured Streaming](03_structured_streaming.md)
4. [CDCとマネージドコネクタ](04_cdc_and_managed_connectors.md)

## 全体のつながり

1. Batch/Streamingの軸とソースの種類で、取り込みパターンの全体地図を作る
2. 最頻出のファイル取り込みを、Auto Loaderの仕組みとともに理解する
3. イベントストリームの取り込みを、チェックポイントと整合性保証の仕組みから理解する
4. 業務DBの変更をCDCで反映する方式と、マネージドコネクタの位置づけを理解する

## 分類の境界

- 取り込んだ後の変換（Silver/Gold化）は 05_transformation_and_orchestration で扱う
- Structured Streamingの基盤であるSparkの実行モデルは 03_spark_and_distributed_processing で扱う
- メッセージング・キューの一般論は it-fundamentals の 06_distributed_systems で扱う

## 主な実装例

COPY INTO、Auto Loader、Structured Streaming、Lakeflow Connect、Change Data Feed。AWS側ではS3イベント通知+SQS、Kinesis、MSK（Kafka）、DMS。

## 到達目標

- ソースと鮮度要件から、取り込み方式（Batch/Streaming/CDC）を選択できる
- Auto Loaderが解決する問題と動作モードを説明できる
- チェックポイントによる障害復旧とexactly-onceの成立条件を説明できる
- 取り込みの冪等性（再実行しても壊れない設計）を説明できる
