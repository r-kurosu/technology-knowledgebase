# 認可と最小権限

## 1. 概念理解

### 認可（Authorization）とは

「認証済みの主体が、何に、どの操作を、どの条件で行えるか」を決めること。認証（「お前は誰か」）で確定した相手を起点に、その**行動範囲を絞り込む**フェーズ。認証がゲートの入り口なら、認可は入った後に動ける範囲。

例：Cognito Identity Poolが `AssumeRoleWithWebIdentity` で発行したSTS一時認証情報が「実際に何をできるか」は、そこに紐づくIAM Policyが決める。ここが認可。

### 認可の基本モデル（4要素）

IAMは認可を4つの要素に分解する。

| 要素 | IAMでの呼び名 | 例 |
|---|---|---|
| 誰が | **Principal**（主体） | IAM Role / User / サービス |
| 何を | **Action**（操作） | `s3:GetObject`、`s3:PutObject` |
| どの対象に | **Resource**（対象） | `arn:aws:s3:::my-bucket/*` |
| どの条件で | **Condition**（条件） | 送信元IP、MFA有無、時間帯 |

この4要素を宣言的に記述したものが **Policy**（IAMではJSON）。1つの許可単位を **Statement** と呼ぶ。

```json
{
  "Effect": "Allow",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::my-bucket/*",
  "Condition": { "IpAddress": { "aws:SourceIp": "203.0.113.0/24" } }
}
```

→「この主体は / my-bucket内のオブジェクトを / 読み取れる / ただし送信元が指定IP範囲のときだけ」。`Effect` が `Allow` か `Deny` かで許可・拒否が決まる。

### 許可（Allow）と明示的拒否（Deny）の評価ロジック

複数のPolicyが絡んでも、判定は次の3ステップで決まる。

1. **暗黙的拒否（Implicit Deny）**＝デフォルト。どのPolicyにも書かれていなければ拒否
2. **明示的許可（Explicit Allow）**＝どれか1つのPolicyにAllowがあれば許可候補
3. **明示的拒否（Explicit Deny）**＝1つでもDenyがあれば、他に何があろうと最優先で拒否

優先順位：`明示Deny > 明示Allow > 暗黙Deny`

**なぜデフォルト拒否か（fail closed）**：Allowの書き忘れ → 暗黙的拒否で止まる（安全側に倒れる）。もし逆に「Denyの書き忘れ → 誤って許可」だったら、気づかないまま穴が開く。間違えたときに危険な方へ倒れないための設計。

### 設計の3原則

**① 最小権限（Least Privilege）**
業務に必要な操作・対象・条件だけを与え、それ以上は与えない。`s3:*` で全許可ではなく「`my-bucket/uploads/*` に `PutObject` だけ」まで絞る。理由は、権限が漏れた／悪用されたときの被害範囲（blast radius）が権限の広さに比例するから。実務では「広めに始めて使っていないものを削る」が現実的で、それを支援するのが Access Analyzer。

**② 職務分離（Separation of Duties, SoD）**
強い操作を一人／一つの主体に集中させない。「一人では危険な操作を完遂できない」状態を作る。
- 本番デプロイする人と承認する人を分ける
- 監査ログを「読む」権限と「消す」権限を別主体に分ける（消せる人が読めると証拠隠滅できる）
- お金を動かす申請者と承認者を分ける

**③ 権限境界（Permission Boundary）**
主体に「与えられる権限の上限（天井）」を課す仕組み。**それ自体は権限を付与しない**。実効権限 ＝ 通常Policy（Allow） ∩ 権限境界 の **AND**。用途は権限委譲——「開発者に自分でRoleを作らせたいが、管理者権限だけは付けさせない」等。開発者がどんなPolicyを書いても天井は超えられない。

```
実効権限 = 通常Policyで許可 ∩ 権限境界で許可（− どこかのDeny）
例）通常 s3:*+ec2:* ／ 境界 s3:* → 実効は s3:* のみ（ec2は天井で不可）
```

## 2. 選択肢の比較

<!-- Identity-based/Resource-based Policy、Allow/Deny、RBAC/ABACを比較する -->

## 3. AWSでの実装例

IAM Policy、Resource Policy、Permission Boundary、SCP、Access Analyzer。

## 4. アーキテクチャ図

<!-- Principal、Policy、Resourceの認可関係を表す -->

## 5. 設計トレードオフ

<!-- 管理しやすさ、柔軟性、過剰権限、組織単位の統制を考える -->

## 6. 自分の言葉で説明

<!-- 「RoleとPolicyの違い」「最小権限とは何か」を説明する -->

## 7. 理解確認

### 到達目標

主体、操作、対象、条件を分けて権限を読み、必要最小限のPolicyを考えられる。

### 現在の理解度

<!-- A：説明できる / B：見れば分かる / C：まだ怪しい -->
