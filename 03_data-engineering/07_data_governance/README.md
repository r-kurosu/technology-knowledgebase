# データガバナンス

基盤全体を統制する章。データが増え利用者が増えても「誰が・何を・どう使えるか」を管理し続けるための仕組みを、カタログを軸に理解する。

## 学習する順番

1. [データカタログとメタデータ管理](01_catalog_and_metadata.md)
2. [アクセス制御と監査](02_access_control_and_audit.md)
3. [リネージ・データ品質・共有](03_lineage_quality_and_sharing.md)

## 全体のつながり

1. メタデータの一元管理（カタログ階層、名前空間設計、テーブル種別）を理解する
2. その上で権限（行/列レベル制御を含む）と監査を設計する
3. データの来歴（リネージ）と品質を可視化・監視し、統制を保ったまま社内外へ共有する

## 分類の境界

- 認証・IAM・暗号化などセキュリティの一般論は it-fundamentals の 02_security と 07_security で扱う
- パイプライン内の品質チェックの実装は 05_transformation_and_orchestration で扱い、ここでは品質の監視と統制を扱う
- BIツールへの提供経路は 06_analytics_and_bi で扱い、ここでは提供時の統制を扱う

## 主な実装例

DatabricksならUnity Catalog（3層名前空間、GRANT、Row Filter/Column Mask）、リネージグラフ、Lakehouse Monitoring、Delta Sharing、system tables。AWSならGlue Data Catalog+Lake Formation、CloudTrail。

## 到達目標

- データカタログが何を一元化するのかを説明できる
- 名前空間設計（環境・ドメインの分割）と権限設計を要件から組み立てられる
- データ品質問題に「どこで気づける設計にするか」を説明できる
- 社内外へ安全にデータを渡す方式を比較・選択できる
