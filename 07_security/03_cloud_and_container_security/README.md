# クラウド・コンテナセキュリティ

クラウド環境とコンテナワークロードの守り方を、特定ベンダーに依存しない概念として学ぶ。クラウドのインシデントの多くは「設定ミス」から起きる、という前提で考える。具体例はAWS（ECS/Fargate）を中心に、必要に応じてAzure/GCPを対比する。

## 扱う予定のトピック

- 責任共有モデルの実務的な解釈（IaaS/PaaS/SaaSでの境界の違い）
- クラウドIAMの深掘り（ポリシー評価ロジック、ロール設計、一時認証情報）
- コンテナ・Kubernetesのセキュリティ（イメージスキャン、実行時の最小権限、Pod/タスクの分離）
- クラウドネットワークの境界設計（VPC/VNet、セキュリティグループ、プライベート接続、WAF）
- 態勢管理の考え方と製品カテゴリ（CSPM、CWPP、CNAPP）
- 監査ログの集約と保全（CloudTrail等、マルチクラウドでの統合）

## 関連

- 基礎編: [認可と最小権限](../../01_it-fundamentals/02_security/02_authorization_and_least_privilege.md)
- [03_compute](../../01_it-fundamentals/03_compute/) — ECS/Fargate等のコンピュート基礎
