# データエンジニアリング

データ基盤の設計・構築・運用を体系的に学ぶ。[01_it-fundamentals](../01_it-fundamentals/README.md) の基礎（ストレージ、データベース、分散システム、運用）を前提とした応用編である。

## 学習方針

- 主題は一般的なデータエンジニアリングの概念。it-fundamentalsでのAWSと同じく、具体化は「例えばDatabricksなら〇〇、AWSなら〇〇」という実装例として扱う
- 実装例はDatabricksを第一に、AWS（Glue/Athena/Redshift等）やOSS（dbt/Airflow等）を対比として使う
- Lakehouseやメダリオンなど、Databricks発だが業界標準になった考え方は概念側でも取り入れる
- ノートは [output_template.md](../01_it-fundamentals/99_learning_system/output_template.md) に沿って書く。セクション3「AWSでの実装例」は本領域では「Databricks/AWSでの実装例」と読み替える

## 学習する順番

1. [データ基盤アーキテクチャ](01_data_platform_architecture/README.md)
2. [ストレージ層とテーブルフォーマット](02_storage_and_table_formats/README.md)
3. [分散データ処理](03_distributed_processing/README.md)
4. [データ取り込みとストリーミング](04_ingestion_and_streaming/README.md)
5. [変換とオーケストレーション](05_transformation_and_orchestration/README.md)
6. [分析クエリとBI](06_analytics_and_bi/README.md)
7. [データガバナンス](07_data_governance/README.md)
8. [運用とコスト](08_operations_and_cost/README.md)

## 全体のつながり

1. データ基盤という領域の全体像と、Lakehouseに至るアーキテクチャの変遷を掴む
2. 基盤の土台であるストレージ層（テーブルフォーマット）と処理エンジン（分散処理）を理解する
3. データを入れ（取り込み）、変換して流し（パイプライン）、使わせる（分析・BI）という流れを設計できるようにする
4. 全体を統制し（ガバナンス）、安定して安く動かし続ける（運用・コスト）

## 分類の境界

- DWH・分析クエリの基礎概念は it-fundamentals の [05_database](../01_it-fundamentals/05_database/README.md)、オブジェクトストレージの基礎は [04_storage](../01_it-fundamentals/04_storage/README.md)、分散システムの一般論は [06_distributed_systems](../01_it-fundamentals/06_distributed_systems/README.md) で扱い、ここではデータ基盤の文脈で深掘りする
- 生成AIのAPI利用・プロンプト設計は [02_ai-engineering](../02_ai-engineering/) で扱う。ML/生成AI基盤（MLOps、Vector Search、RAG基盤）は必要になった時点でテーマとして追加する
- セキュリティの一般論は [07_security](../07_security/) で扱い、ここではデータガバナンスを扱う

## 全体の到達目標

- データの発生から活用までの経路を説明し、Data Lake/DWH/Lakehouseを比較・選択できる
- 取り込み→変換→提供のパイプラインを、鮮度・コスト・運用の要件から設計できる
- カタログを軸に、権限・品質・リネージを含むガバナンスを設計できる
- コスト構造（プラットフォーム課金+クラウド課金）を分解して説明し、最適化を判断できる
- 遅い・壊れた・高いといった問題を、層（ストレージ/処理/提供）ごとに切り分けられる
