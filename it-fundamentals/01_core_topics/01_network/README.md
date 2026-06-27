# ネットワーク

ネットワークは、システム間の通信経路、公開範囲、セキュリティ境界を設計するための基礎である。AWSサービスの名前からではなく、通信がどこからどこへ、どのように届くかを理解する。

## 学習する順番

1. [IPアドレスとCIDR](01_ip_and_cidr.md)
2. [Public/Privateとルーティング](02_public_private_and_routing.md)
3. [DNS・HTTP・TLS](03_dns_http_tls.md)
4. [ロードバランシング](04_load_balancing.md)
5. [閉域接続](05_private_connectivity.md)

## 全体のつながり

1. IPアドレスとCIDRでネットワークの範囲を決める
2. SubnetとRoute Tableで配置と通信経路を決める
3. DNSで接続先を見つけ、HTTP/TLSで安全に通信する
4. Load Balancerで複数の処理先へ通信を分散する
5. VPN、Direct Connect、PrivateLinkでインターネットを介さない接続を作る

## AWSでの主な実装例

VPC、Subnet、Route Table、Internet Gateway、NAT Gateway、Security Group、NACL、Route 53、ALB/NLB、VPN、Direct Connect、PrivateLink。

## ネットワーク全体の到達目標

- 利用者からアプリケーション、データベースまでの通信経路を図で説明できる
- 公開するものと非公開にするものを、理由とともに判断できる
- 名前解決、暗号化、負荷分散、閉域接続の役割を説明できる
- セキュリティ、可用性、性能、コストを踏まえて構成を比較できる
