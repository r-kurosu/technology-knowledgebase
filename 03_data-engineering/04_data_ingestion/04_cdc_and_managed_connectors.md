# CDCとマネージドコネクタ

## 1. 概念理解

### 学ぶ範囲

CDCの方式（ログベース/クエリベース）、変更の適用（MERGE、APPLY CHANGES）、SCD Type1/2、マネージドコネクタの位置づけ。

## 2. 選択肢の比較

<!-- Lakeflow Connect/Fivetran/AWS DMS/自前CDCを、対応ソース、コスト、運用で比較する -->

## 3. Databricks/AWSでの実装例

Lakeflow Connect、AWS DMS、Change Data Feed、APPLY CHANGES INTO。

## 4. アーキテクチャ図

<!-- 業務DBからCDCでSilverテーブルが最新化される流れを表す -->

## 5. 設計トレードオフ

<!-- ソースDBへの負荷、遅延、ツールコストを考える -->

## 6. 自分の言葉で説明

<!-- 「CDCをいつ選ぶか」を説明する -->

## 7. 理解確認

### 到達目標

業務DBの変更を分析基盤へ反映する方式を設計できる。

### 現在の理解度

<!-- A：説明できる / B：見れば分かる / C：まだ怪しい -->
