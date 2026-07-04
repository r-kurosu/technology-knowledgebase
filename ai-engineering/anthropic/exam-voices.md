# CCA-F 受験者の声まとめ

> ソース：Medium、dev.to、CertLand、Towards AI、BigTechCareers Newsletter、Reddit等のコミュニティ投稿（2026年4月時点）  
> note/Qiitaの日本語記事は現時点で未確認のため、英語圏コミュニティが主体

---

## 試験の基本情報（受験者視点）

| 項目 | 詳細 |
|------|------|
| 問題数 | 60問（4択） |
| 試験時間 | 120分 |
| 合格ライン | 720/1000 |
| 受験料 | $99/回 |
| 監視方式 | ProctorFree によるライブ監視 |
| 持ち込み | 一切不可（Claude、ドキュメント、外部ツール全て禁止） |
| 開始日 | 2026年3月12日（ローンチ） |

**難易度感（コミュニティの声）:**
- 「AIの認定試験の中で現時点で最も難しい」
- 「コンセプト理解だけでは通らない。実際に本番環境でビルドした経験が必要」
- 合格者スコード例：985/1000（Reddit投稿）

---

## 頻出ドメインと重点トピック

### Domain 1: Agentic Architecture & Orchestration（27%）← 最重要

コミュニティで最も「ここが出た」と言われるドメイン。

**押さえるべきポイント:**
- サブエージェントはコーディネーターの会話履歴・メモリを**引き継がない**
- サブエージェント同士が**直接通信することはない**（コーディネーター経由のみ）
- コンテキストは明示的にパスする必要がある
- タスク分解の戦略、フォールバックパターン設計

### Domain 3: Claude Code Configuration & Workflows（20%）

**押さえるべきポイント:**
- `CLAUDE.md` の階層（user-level vs project-level）の違いと使い分け
- `-p` フラグ：CI/CDでの非インタラクティブ実行に必須（ないとジョブがハング）
- カスタムスラッシュコマンドの設計
- 新メンバーが設定を引き継げない原因の多くは階層の誤り

### Domain 2: Prompt Engineering & Structured Output（20%）

**押さえるべきポイント:**
- JSONスキーマ検証による幻覚防止
- few-shot examples の適切な使い方と誤用
- Batch API vs リアルタイム：コストとレイテンシのトレードオフ
- 構造化データ抽出パターン

### Domain 4: Tool Design & MCP Integration（18%）

- ツールの説明文（description）がルーティングの主要メカニズム
- 構造化エラーハンドリング
- MCP のスコーピングルール

### Domain 5: Context Management & Reliability（15%）

- "lost in the middle" 効果（長コンテキストでの注意散漫）
- エスカレーションパターンの設計
- マルチエージェントシステムのメモリ管理

---

## よく出る「アンチパターン」問題

試験の約半分は「やりがちな誤った選択肢」を見抜けるかを問う。

| アンチパターン | 正しいアプローチ |
|--------------|----------------|
| few-shotでツール実行順を強制する | programmatic prerequisite（コード側で強制）を使う |
| LLMの自己申告信頼度でエスカレーション判断 | 構造化された条件（外部シグナル）でルーティング |
| コスト削減だけの理由でBatch APIにルーティング | latency要件を先に確認してからBatch/リアルタイムを選択 |
| コンテキスト拡張で注意散漫問題を解決 | "lost in the middle"は拡張では解決しない。チャンキングや再構成で対応 |
| コンテンツタイプでレスポンス完了を判定 | Claudeは text + tool_use を同時に返すため、この判定は誤り |

---

## 5つのメンタルモデル（合格者が共通して言及）

1. **Programmatic enforcement vs prompt-based guidance** — コンプライアンスが重要な処理はコードで強制する
2. **Tool description = ルーティングの主役** — system promptではなくdescriptionが分岐を決める
3. **サブエージェントへのコンテキスト明示パス** — 自動継承はない
4. **"Lost in the middle"効果** — 長文脈では重要情報が中央に埋もれると見落とされやすい
5. **Batch APIの判断軸はlatency** — コストではなく応答速度要件で決める

---

## 合格者の学習法

**学習期間の目安:**
- API実務経験あり：2〜4週間（20〜30時間）
- Claude初学者：2〜4ヶ月

**推奨ステップ（コミュニティ共通の声）:**
1. Anthropic Academy の公式コースを全受講（13コース、旗艦コースは8.1時間）
2. 公式の練習問題60問を解き、900+/1000 を目標に
3. **誤答の解説を重点的に読む**（正答より重要との声多数）
4. 「8つの繰り返しディストラクターパターン」を認識できるようにする
5. 試験当日：急がず120分フルに使う（速く解き終えても得点は変わらない）

**スコアの目安:**
- 900+ → 自信を持って受験できる水準
- 820〜880 → 合格圏だが余裕は少ない
- 800未満 → 追加学習を推奨（再受験は$99）

---

## 試験形式の特徴（受験者の感想から）

- 選択肢4つはどれも「それっぽい」。正解1つ、残り3つは本番でやりがちなアンチパターン
- シナリオは6種類あり、そのうち4つがランダム出題
- 問題文は「本番の状況」設定で書かれており、ドキュメントを読んだだけでは判断しにくい
- 用語の精度が問われる（`stop_reason` の正確な値、CLAUDE.mdの階層仕様など）

---

## 主要ソース

- https://certland.net/blog/cca-f-exam-day-experience-what-to-expect/
- https://pub.towardsai.net/claude-certified-architect-the-complete-guide-to-passing-the-cca-foundations-exam-9665ce7342a8
- https://dev.to/mcrolly/inside-anthropics-claude-certified-architect-program-what-it-tests-and-who-should-pursue-it-1dk6
- https://dynamicbalaji.medium.com/claude-certified-architect-foundations-certification-preparation-guide-c70546b51f51
- https://newsletter.bigtechcareers.com/p/step-by-step-guide-to-achieve-claude-certification
- https://tutorialsdojo.com/cca-f-claude-certified-architect-foundations-study-guide/
- https://github.com/paullarionov/claude-certified-architect/blob/main/guide_en.MD
