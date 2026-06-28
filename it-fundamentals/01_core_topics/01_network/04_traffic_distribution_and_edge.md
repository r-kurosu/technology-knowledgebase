# トラフィックの分散と入口

## 1. 概念理解

### 学ぶ範囲

負荷分散、L4/L7、リバースプロキシ、リスナー、ターゲット、ヘルスチェック、スティッキーセッション、DNSルーティング、CDN、冗長化。

## 2. 選択肢の比較

<!-- ALB/NLB、内部向け/外部向け、DNS/Load Balancerによる分散、CDN利用の有無を比較する -->

## 3. AWSでの実装例

Application Load Balancer、Network Load Balancer、Target Group、Route 53、CloudFront、Global Accelerator、Auto Scaling。

## 4. アーキテクチャ図

<!-- DNSやCDNからLoad Balancerを経由し、複数AZの処理先へ分散する構成をMermaidで表す -->

## 5. 設計トレードオフ

<!-- プロトコル、レイテンシ、ルーティング機能、固定IP、障害検知、コストを考える -->

## 6. 自分の言葉で説明

<!-- 「なぜLoad Balancerが必要か」「ALBとNLBの違い」を説明する -->

## 7. 理解確認

### 到達目標

要件からDNS、CDN、L4/L7 Load Balancerの役割を選択し、ヘルスチェックを含む負荷分散と冗長化を説明できる。

### 現在の理解度

<!-- A：説明できる / B：見れば分かる / C：まだ怪しい -->
