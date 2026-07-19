# セキュリティ

セキュリティを専門分野として深掘りする。攻撃者の視点から始めて、レイヤーごとの防御、運用（検知・対応）、そして昨今話題のAIセキュリティまでを扱う。

前提となる基礎（認証/認可、暗号化、監査の入門）は [01_it-fundamentals/02_security](../01_it-fundamentals/02_security/README.md) で学習済みとする。ここではその先の、実務・専門レベルの内容を対象にする。

## 学習する順番

1. [脅威と攻撃手法](01_threats_and_attacks/README.md) — 攻撃者は何を、どう狙うのか
2. [アプリケーションセキュリティ](02_application_security/README.md) — 作る側の防御（セキュア開発）
3. [クラウド・コンテナセキュリティ](03_cloud_and_container_security/README.md) — AWS/ECS前提の防御
4. [アイデンティティとゼロトラスト](04_identity_and_zero_trust/README.md) — 境界防御からの転換
5. [セキュリティ運用](05_security_operations/README.md) — 検知・対応・インシデントレスポンス
6. [AIセキュリティ](06_ai_security/README.md) — LLM時代の新しい攻撃面
7. [オフェンシブセキュリティ入門](07_offensive_security_basics/README.md) — 手を動かして攻撃者視点を体得する

## 全体の到達目標

- 代表的な攻撃手法を、防御側の設計判断に接続して説明できる
- Webアプリ・API・CI/CDパイプラインの脆弱性を指摘し、対策を提案できる
- AWS（特にECS/コンテナ構成）のセキュリティ設計をレビューできる
- インシデント発生時の初動と、平時の検知の仕組みを説明できる
- LLMを組み込んだシステム特有のリスクを評価できる

## 将来の追加候補

- ガバナンス・コンプライアンス（ISMS/ISO 27001、SOC 2、個人情報保護法）— 基礎は [監査とガバナンス](../01_it-fundamentals/02_security/05_audit_and_governance.md) を参照
