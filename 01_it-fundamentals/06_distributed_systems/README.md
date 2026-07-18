# 分散システム・非同期処理

複数コンポーネントが通信するシステムで、部分障害、遅延、重複、順序の乱れを前提に設計する。

## 学習する順番

1. [スケーラビリティ・可用性・整合性](01_scalability_availability_and_consistency.md)
2. [キューとPub/Sub](02_queue_and_pubsub.md)
3. [イベント駆動とワークフロー](03_event_driven_and_workflow.md)
4. [リトライ・冪等性・DLQ](04_retry_idempotency_and_dlq.md)

## 全体の到達目標

- 同期と非同期、密結合と疎結合を比較できる
- キュー、Pub/Sub、イベントルーター、ワークフローを使い分けられる
- 失敗、再試行、重複実行を前提に設計できる
