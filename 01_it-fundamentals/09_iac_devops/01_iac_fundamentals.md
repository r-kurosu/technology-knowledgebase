# IaCの基礎

## 1. 概念理解

### 学ぶ範囲

宣言的/命令的、Desired State、Plan/Apply、State、Module、Configuration Drift、冪等性。

### 宣言的（Declarative）と命令的（Imperative）

- 命令的：「Aを作れ、次にBを作れ」と手順を書く（`aws cli`を順番に叩く、手作業も同じ）
- 宣言的：「最終的にこうあるべき」という状態を書く。Terraformの`.tf`はこちら

### Desired StateとState

`.tf`に書いたリソース定義が「あるべき姿（Desired State）」。Terraformの仕事は、実際のインフラ（Current State）をDesired Stateに近づけること。

AWS側のリソースには「Terraformが作った」という印は付いていないため、どのリソースをTerraformが管理しているかを記録する台帳が`tfstate`。**Stateは、実インフラとコード（プログラム論理）を一致させるための仕組み**。

### Plan/Apply（差分計算のサイクル）

1. `.tf`（Desired State）を読む
2. `tfstate`（前回の記録）を読む
3. AWS APIに問い合わせて実際の状態を確認する（**refresh**）
4. Desired StateとCurrent Stateの差分を計算し、`plan`として提示 → `apply`で反映

`tfstate`を紛失すると、Terraformは「まだ何も存在しない」と誤認し、既存リソースを再度`CREATE`しようとして名前衝突や重複作成が起きる。復旧には`terraform import`で1つずつ紐付け直しが必要。ローカルではなくS3などリモートバックエンドに置くのは、紛失・競合を避けるため。

## 2. 選択肢の比較

<!-- 手作業/IaC、宣言的/命令的、CloudFormation/CDK/Terraformを比較する -->

## 3. AWSでの実装例

CloudFormation、CDK、Terraform、CloudFormation StackSets。

## 4. アーキテクチャ図

<!-- コード、レビュー、適用、実環境、状態の関係を表す -->

## 5. 設計トレードオフ

<!-- 学習コスト、可搬性、状態管理、再利用性、変更影響を考える -->

## 6. 自分の言葉で説明

<!-- 「なぜIaCが必要か」を説明する -->

## 7. 理解確認

### 到達目標

IaCによる再現性、レビュー可能性、変更追跡の価値と注意点を説明できる。

### 現在の理解度

<!-- A：説明できる / B：見れば分かる / C：まだ怪しい -->
