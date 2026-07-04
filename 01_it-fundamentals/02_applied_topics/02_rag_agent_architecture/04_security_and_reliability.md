# セキュリティと信頼性

## 1. 概念理解

### 学ぶ範囲

データ権限、Tenant分離、Prompt Injection、Tool権限、機密情報、Guardrail、Fallback、監査。

## 2. 選択肢の比較

<!-- 実行前/後検証、モデル/アプリ側Guardrail、Fail-open/Fail-closedを比較する -->

## 3. AWSでの実装例

IAM、KMS、Secrets Manager、Bedrock Guardrails、CloudTrail、WAF、PrivateLink。

## 4. アーキテクチャ図

<!-- 認証、検索権限、Guardrail、Tool実行、監査の境界を表す -->

## 5. 設計トレードオフ

<!-- 安全性、回答率、遅延、権限制御、誤検知、障害時動作を考える -->

## 6. 自分の言葉で説明

<!-- 「AIに入力・出力チェックだけでは足りない理由」を説明する -->

## 7. 理解確認

### 到達目標

利用者ごとのデータ・Tool権限を守り、危険な入力や失敗を閉じ込める構成を説明できる。

### 現在の理解度

<!-- A：説明できる / B：見れば分かる / C：まだ怪しい -->
