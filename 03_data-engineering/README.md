# データエンジニアリング

Databricksを主題に、データ基盤の設計・構築・運用を体系的に学ぶ。[01_it-fundamentals](../01_it-fundamentals/README.md) の基礎（ストレージ、データベース、分散システム、運用）を前提とした応用編である。

## 学習方針

- Databricksを主題としつつ、製品機能の暗記ではなく「概念 → Databricksでの実装 → AWSでの対応・比較」の順で理解する
- 基盤はDatabricks on AWSを想定し、AWSサービスは対応関係・比較対象として登場させる
- ノートは [output_template.md](../01_it-fundamentals/99_learning_system/output_template.md) に沿って書く。セクション3「AWSでの実装例」は本領域では「Databricks/AWSでの実装例」と読み替える

## 学習する順番

1. [Lakehouseとアーキテクチャ](01_lakehouse_architecture/README.md)
2. [Delta Lakeとストレージ層](02_delta_lake_and_storage/README.md)
3. [Sparkと分散処理](03_spark_and_distributed_processing/README.md)
4. [データ取り込み](04_data_ingestion/README.md)
5. [変換とオーケストレーション](05_transformation_and_orchestration/README.md)
6. [SQL分析とBI](06_sql_analytics_and_bi/README.md)
7. [ガバナンスとUnity Catalog](07_governance_and_unity_catalog/README.md)
8. [運用とコスト](08_operations_and_cost/README.md)
9. [MLと生成AI基盤](09_ml_and_genai/README.md)

## 全体のつながり

1. Lakehouseという設計思想と、DatabricksがAWS上でどう動くかの全体像を掴む
2. データの実体であるDelta Lakeと、それを処理するSparkを理解する（基盤の2本柱）
3. データを入れ（取り込み）、変換して流し（パイプライン）、使わせる（SQL/BI）
4. 全体を統制し（ガバナンス）、安定運用してコストを管理する
5. その上のML・生成AIワークロードへ広げる

## 分類の境界

- DWH・分析DBの基礎概念は it-fundamentals の [05_database](../01_it-fundamentals/05_database/README.md)、オブジェクトストレージの基礎は [04_storage](../01_it-fundamentals/04_storage/README.md) で扱い、ここではLakehouse文脈で深掘りする
- 分散処理の一般論は [06_distributed_systems](../01_it-fundamentals/06_distributed_systems/README.md)、ここではSparkに特化する
- 生成AIのAPI利用・プロンプト設計は [02_ai-engineering](../02_ai-engineering/)、ここではデータ基盤側の構成要素（Vector Search等）を扱う
- セキュリティの一般論は [07_security](../07_security/)、ここではデータガバナンス（Unity Catalog）を扱う

## 全体の到達目標

- Lakehouseアーキテクチャを構成要素から説明し、DWH型アーキテクチャと比較できる
- 取り込み→変換→提供のパイプラインを、鮮度・コスト・運用の要件からDatabricks上で設計できる
- Unity Catalogを軸に、権限・品質・リネージを含むガバナンスを設計できる
- DBU課金とAWS側コストを踏まえた構成・運用の判断ができる
- 遅い・壊れた・高いといった問題を、層（ストレージ/処理/提供）ごとに切り分けられる
