# ルーティングとインターネット接続

## 1. 概念理解

### 学ぶ範囲

ルーター、Route Table、最長プレフィックス一致、デフォルトルート、Public/Private Subnet、Internet Gateway、NAT、インバウンド/アウトバウンド経路、戻り経路。

## 2. 選択肢の比較

<!-- Public/Private配置、Internet Gateway/NAT、NAT Gateway/NAT Instanceを比較する -->

## 3. AWSでの実装例

VPC、Subnet、Route Table、Internet Gateway、NAT Gateway、Egress-only Internet Gateway。

## 4. アーキテクチャ図

<!-- インターネットからALB、アプリ、DBまでの往復経路をMermaidで表す -->

## 5. 設計トレードオフ

<!-- 公開範囲、外向き通信、戻り経路、可用性、NATコストを考える。通信制御はSecurity Group/NACLとの境界も確認する -->

## 6. 自分の言葉で説明

<!-- 「なぜPrivate Subnetに置くのか」「NAT Gatewayは何のためか」を説明する -->

## 7. 理解確認

### 到達目標

往路と復路のRoute Tableをたどって到達可能性を判断し、各リソースをPublic/Privateのどちらに置くか説明できる。

### 現在の理解度

<!-- A：説明できる / B：見れば分かる / C：まだ怪しい -->
