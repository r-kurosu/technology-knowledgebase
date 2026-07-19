# クラウド・コンテナセキュリティ

AWS前提で、クラウド環境とコンテナワークロード（ECS/Fargate中心）の守り方を学ぶ。クラウドのインシデントの多くは「設定ミス」から起きる、という前提で考える。

## 扱う予定のトピック

- 責任共有モデルの実務的な解釈
- IAMの深掘り（ポリシー評価ロジック、ロール設計、一時認証情報）
- ECS/Fargate・コンテナのセキュリティ（イメージスキャン、タスクロール、実行時の最小権限）
- ネットワーク境界の設計（VPC、セキュリティグループ、PrivateLink、WAF）
- 設定ミスの検知（Security Hub、Config、GuardDuty、CSPMの考え方）
- ログの集約と保全（CloudTrail、VPC Flow Logs）

## 関連

- 基礎編: [認可と最小権限](../../01_it-fundamentals/02_security/02_authorization_and_least_privilege.md)
- [03_compute](../../01_it-fundamentals/03_compute/) — ECS/Fargate等のコンピュート基礎
