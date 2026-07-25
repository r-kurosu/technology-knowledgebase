# CI/CDパイプライン

## 1. 概念理解

### 学ぶ範囲

Continuous Integration、Delivery、Deployment、Build、Test、Artifact、Approval、Pipeline。

### Continuous Integration（CI）

変更を頻繁に主ブランチへ統合し、その都度自動でビルド・テストを走らせて検証する仕組み。名前の"Integration"が指すのは「ビルドが通ること」よりも、複数人の変更を頻繁に合流させること自体。

**なぜ必要か**

分岐期間が長いほど、マージコストは線形ではなく加速度的に増える（変更ファイルが増える、前提が食い違う、直した本人も理由を忘れる＝Integration Hell）。頻繁に小さく統合すれば、問題を小さく・早く・原因を特定しやすい状態で検出できる。

**どう壊れるか**

- CIツール（CodePipeline等）を導入していても、運用として各自が長期間ブランチを分けたままなら「頻繁な統合」という本質を満たしておらず、効果は薄い（ツールの導入とCIという実践は別物）
- テストが遅い・不安定（flaky）だと開発者が実行を省略し始め、形骸化する

## 2. 選択肢の比較

<!-- CI/CD、継続的Delivery/Deployment、Push/Pull型デプロイを比較する -->

## 3. AWSでの実装例

CodePipeline、CodeBuild、CodeDeploy、ECR、GitHub Actions。

## 4. アーキテクチャ図

<!-- CommitからBuild、Test、Artifact、Deployまでを表す -->

## 5. 設計トレードオフ

<!-- 速度、品質ゲート、承認、並列化、再現性、コストを考える -->

## 6. 自分の言葉で説明

<!-- 「本番へ安全に変更を届ける流れ」を説明する -->

## 7. 理解確認

### 到達目標

変更を自動テストし、同一Artifactを安全に各環境へ届けるPipelineを説明できる。

### 現在の理解度

<!-- A：説明できる / B：見れば分かる / C：まだ怪しい -->
