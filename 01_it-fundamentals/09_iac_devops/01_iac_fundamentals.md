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

### Module

Terraformコードを再利用可能にまとめた部品（関数のようなもの）。「ECSサービス一式」をモジュール化すれば、dev/staging/prodで同じ構成をパラメータだけ変えて使い回せる。コピペ運用は修正漏れ・環境間差異の温床になる。

### Configuration Drift

`tfstate`（Terraformの記憶）に対し、実際のAWSリソースがTerraform経由ではない変更（コンソールでの手動変更など）でずれてしまう状態。次の`plan`の`refresh`で「コードにない差分」として検出される。

**なぜapplyが壊れるか**
- 単純な値の手動変更（例：desired_count）→ 素直に「コードの値へ戻す」プランになり、大抵は通る
- immutable（変更不可）な属性を手動変更 → AWS的に削除→再作成が必要になるが、依存関係や一意制約で失敗しうる
- リソースを手動で削除・再作成 → AWS側のIDが変わり、`tfstate`は古いIDを指したまま。参照時に`ResourceNotFoundException`
- ECSのタスク定義リビジョンを手動更新 → コンソールは新リビジョン、`tfstate`は古いリビジョンを「正」として記憶したままズレる

**対処**
- `terraform apply -refresh-only`（またはplan）：コードは変えずtfstateだけ実際のAWSに合わせてから、改めてplanを取る
- 特定できない場合は`terraform state rm` → `terraform import`でtfstateを作り直す
- 根本対策：変更経路をTerraform（IaC）に一本化し、緊急時以外はコンソールから直接触らない運用ルール

### 冪等性（Idempotency）

同じ`apply`を何度実行しても結果が同じ状態に収束する性質。差分がなければ何もしない設計になっているため、CI/CDでリトライや再実行があっても安全。`aws cli`で単純に`create`コマンドを並べただけだと、2回実行時にエラーまたは重複作成が起きるのと対照的。

## 2. 選択肢の比較

### 手作業 vs IaC

| | 手作業 | IaC |
|---|---|---|
| 再現性 | 人によるブレ・手順忘れ | コード通りに同一の結果 |
| レビュー | 困難（手順が残らない） | Git上でPRレビュー可能 |
| 変更履歴 | コンソールログ頼み | Git履歴として残る |
| ロールバック | 手動で逆手順を実施 | 過去のコードに戻してapply |
| Drift検知 | 検知手段がない | plan/refreshで検知できる |

個人での小さな検証はコンソールでポチポチが分かりやすいこともあるが、チームで管理する前提ならIaCが一択になる。

### 宣言的 vs 命令的

| | 宣言的 | 命令的 |
|---|---|---|
| 書くもの | あるべき状態 | 実行手順 |
| 差分計算 | ツールが自動でやる | 自分で条件分岐を書く必要 |
| 冪等性 | ツールが保証 | 自分で担保する必要 |
| 代表 | Terraform, CloudFormation | シェルスクリプト、`aws cli`連打 |

### CloudFormation vs CDK vs Terraform

| | CloudFormation | CDK | Terraform |
|---|---|---|---|
| 対応範囲 | AWSのみ | AWSのみ（内部でCFnに変換） | マルチクラウド・SaaS含め広い（Provider次第） |
| 記述方法 | YAML/JSON宣言 | TypeScript/Python等の汎用言語 | HCL（宣言的専用言語） |
| State管理 | AWS側が管理（意識不要） | 内部的にCFn任せ | 自前で`tfstate`を管理する必要 |
| エコシステム | AWS公式 | AWS公式 | HashiCorp＋コミュニティ、対応Providerが多い |

Terraformを選ぶ理由は「対応範囲」「エコシステム」の広さ（汎用性）。引き換えに、State管理を自分で担う責任を負う。

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
