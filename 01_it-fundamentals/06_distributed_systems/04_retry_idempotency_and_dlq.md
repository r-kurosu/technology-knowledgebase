# リトライ・冪等性・DLQ

## 1. 概念理解

### 学ぶ範囲

一時障害、Retry、Backoff、Jitter、Timeout、冪等性、重複実行、Dead Letter Queue。

## 2. 選択肢の比較

<!-- 即時/指数Backoff、At-most-once/At-least-once、再試行/DLQを比較する -->

## 3. AWSでの実装例

SQS DLQ、Lambda Retry、Step Functions Retry/Catch、DynamoDB Conditional Write。

## 4. アーキテクチャ図

<!-- 失敗、再試行、DLQ、再処理の流れを表す -->

## 5. 設計トレードオフ

<!-- 復旧率、重複、副作用、遅延、負荷増幅、運用を考える -->

## 6. 自分の言葉で説明

<!-- 「なぜRetryだけでは不十分か」を説明する -->

## 7. 理解確認

### 到達目標

再試行してよい失敗を判断し、冪等性とDLQを含む再処理方式を設計できる。

### 現在の理解度

<!-- A：説明できる / B：見れば分かる / C：まだ怪しい -->
