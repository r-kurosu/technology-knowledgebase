# MLと生成AI基盤

データ基盤の上に載るML・生成AIワークロードの章。モデル開発を「実験の再現・資産の管理・本番への提供」という基盤の問題として捉え、Lakehouse上でどう実現するかを理解する。

## 学習する順番

1. [MLflowとモデルライフサイクル](01_mlflow_and_model_lifecycle.md)
2. [Feature StoreとModel Serving](02_feature_store_and_model_serving.md)
3. [生成AI基盤](03_genai_platform.md)

## 全体のつながり

1. 実験→登録→デプロイというモデルのライフサイクル管理（MLflow）を理解する
2. 特徴量の一貫性（training-serving skew防止）と推論の提供方式を理解する
3. Vector SearchやFoundation Model APIなど、RAG・Agentをデータ基盤側で支える構成要素を理解する

## 分類の境界

- 生成AIのAPI利用・プロンプト設計・各プロバイダーの機能は 02_ai-engineering で扱い、ここではデータ基盤側の構成要素を扱う
- モデルが使うデータの品質・権限は 07_governance_and_unity_catalog の仕組みに乗る
- サービングのコスト・監視は 08_operations_and_cost の考え方を適用する

## 主な実装例

MLflow、Models in Unity Catalog、Feature Engineering in Unity Catalog、Model Serving、Mosaic AI Vector Search、Foundation Model API。AWS側ではSageMaker、Bedrock、OpenSearchが対応する。

## 到達目標

- モデルをコードと同様に管理する（実験管理・レジストリ）意義を説明できる
- バッチ推論とリアルタイム推論を要件から使い分けられる
- Lakehouse上でRAGを組む場合の構成要素と、その選択理由を説明できる
