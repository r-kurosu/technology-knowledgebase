# ガバナンスとUnity Catalog

基盤全体を統制する章。データが増え利用者が増えても「誰が・何を・どう使えるか」を管理し続けるための仕組みを、Unity Catalogを軸に理解する。

## 学習する順番

1. [Unity Catalogの基本](01_unity_catalog_fundamentals.md)
2. [アクセス制御と監査](02_access_control_and_audit.md)
3. [リネージとデータ品質](03_lineage_quality_and_monitoring.md)
4. [データ共有](04_data_sharing.md)

## 全体のつながり

1. メタデータの一元管理（カタログ階層、テーブル種別、外部ロケーション）を理解する
2. その上で権限（GRANT、行/列レベル制御）と監査を設計する
3. データの来歴（リネージ）と品質を可視化・監視する
4. 統制を保ったまま社内外へデータを共有する（Delta Sharing）

## 分類の境界

- 認証・IAM・暗号化などセキュリティの一般論は it-fundamentals の 02_security と 07_security で扱う
- パイプライン内の品質チェック（expectations）の実装は 05_transformation_and_orchestration で扱い、ここでは品質の監視と統制を扱う
- BIツールへの提供経路は 06_sql_analytics_and_bi で扱い、ここでは提供時の統制を扱う

## 主な実装例

Unity Catalog、GRANT、Row Filter/Column Mask、リネージグラフ、Lakehouse Monitoring、system tables、Delta Sharing。AWS側ではGlue Data Catalog+Lake Formationが対応する。

## 到達目標

- Unity Catalogが何を一元化するのかを説明できる
- カタログ設計（環境・ドメインの分割）と権限設計を要件から組み立てられる
- データ品質問題に「どこで気づける設計にするか」を説明できる
- 社外へ安全にデータを渡す方式を比較・選択できる
