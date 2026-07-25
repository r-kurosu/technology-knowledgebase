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

### Continuous Delivery / Continuous Deployment / Approval

土台はCIと同じ（自動でビルド・テストし、デプロイ可能な状態を作る）。違いは本番への最後の一押しを人が判断するか、自動でやるかだけ。

- Continuous Delivery：変更は自動で「いつでも本番に出せる状態」まで作られるが、実際に出すかは人（Approval）が判断する
- Continuous Deployment：承認なし。CIを通った変更はそのまま自動で本番まで到達する

**どう壊れるか**

- 承認（Approval）が中身を見ずに反射的にApproveするだけの作業になると、実質Deploymentと同じ速度で進みながら承認という手順だけが残る（Approval Theater）。遅延だけ生んでリスク低減の実効性は失われる

### Build / Artifact（Build once, deploy many）

- Build：ソースコードから実行可能な成果物（Dockerイメージ等）を作る工程
- Artifact：Buildで作られた成果物そのもの。CI/CDのベストプラクティスは「Build once, deploy many」＝一度ビルドした同じArtifactを、dev→本番へそのまま昇格させること。環境差はArtifactの中身ではなく外側（環境変数・タスク定義等）で吸収する

**どう壊れるか**

- ブランチごとに別パイプライン（別CodeBuild）を持ち、mainマージ後に再ビルドする構成だと、ソースは同じでも「ビルドという行為」をやり直すことになる
- 依存パッケージのバージョン固定が甘い、ベースイメージが`latest`参照など再現性が低いと、devで検証したものと本番で動くものが厳密には別物になり、「devで通ったのに本番で落ちる」の原因になる

### Test

Buildの後（または並行して）自動実行される検証。CIの文脈では「ビルドが通る」だけでなく、ロジックの破綻を検出する役割を持つ。テストが遅い・不安定（flaky）だとCI自体が形骸化するのは前述の通り。

### Pipeline

Commit → Build → Test → Artifact生成 → (Approval) → Deployを直列に繋いだ一連の自動化フロー全体。各ステージが独立して失敗しうるため、「どこで失敗したか」を切り分けられる設計になっているかが重要。

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
