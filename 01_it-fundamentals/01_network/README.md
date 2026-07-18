# ネットワーク

ネットワークは、システム間の通信経路、公開範囲、セキュリティ境界を設計するための基礎である。AWSサービスの名前からではなく、通信がどこからどこへ、どのように届くかを理解する。

## 学習する順番

0. [OSIモデルとTCP/IPモデル](00_osi_and_tcpip_model.md)
1. [通信の基礎とIPアドレス](01_network_fundamentals_and_addressing.md)
2. [ルーティングとインターネット接続](02_routing_and_internet_connectivity.md)
3. [エンドツーエンド通信](03_end_to_end_communication.md)
4. [トラフィックの分散と入口](04_traffic_distribution_and_edge.md)
5. [ネットワーク間接続](05_network_interconnection.md)

## 全体のつながり

1. TCP/IPの基本とIPアドレス、CIDRで通信とアドレス範囲を理解する
2. SubnetとRoute Tableで配置、インターネット接続、往復の通信経路を決める
3. TCP/UDPとポートでアプリケーションを識別し、DNS、HTTP、TLSで通信する
4. DNS、CDN、Load Balancerで入口を作り、複数の処理先へ通信を分散する
5. VPN、専用線、VPC間接続、サービス接続でネットワーク同士を接続する

## 分類の境界

- パブリックIPとプライベートIPは「アドレスの種類」として1章で扱い、Public/Private Subnetは「経路の性質」として2章で扱う
- DNSによる名前解決は3章、DNSルーティングによる分散とフェイルオーバーは4章で扱う
- Security Group、Network ACL、Firewallなどの通信制御はセキュリティ領域を主な置き場所とし、この領域では通信経路への影響を確認する
- セキュリティ、可用性、性能、コスト、トラブルシューティングは全章に共通する横断的な観点とする

## AWSでの主な実装例

VPC、Subnet、Route Table、Internet Gateway、NAT Gateway、Route 53、CloudFront、ALB/NLB、VPN、Direct Connect、VPC Peering、Transit Gateway、PrivateLink。

## ネットワーク全体の到達目標

- 利用者からアプリケーション、データベースまでの通信経路を図で説明できる
- 公開するものと非公開にするものを、理由とともに判断できる
- TCP/UDP、名前解決、暗号化、負荷分散、ネットワーク間接続の役割を説明できる
- セキュリティ、可用性、性能、コストを踏まえて構成を比較できる
- 疎通できないときに、アドレス、経路、ポート、名前解決、通信制御の順で切り分けられる
