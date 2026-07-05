# OpenAI プロンプトエンジニアリング ベストプラクティス

---

## 1. メッセージ構造の基本

OpenAI Chat Completions APIは3種類のロールを持つ。

| ロール | 用途 |
|---|---|
| `system` | モデルの人格・制約・ゴールを定義 |
| `user` | ユーザーの入力 |
| `assistant` | モデルの応答（few-shotの例示にも使う） |

### システムプロンプトの推奨構造

```
You are [役割].
Your goal: [成功の定義].
Constraints:
- [制約1]
- [制約2]
Output format: [JSON / markdown / etc.]
If uncertain: [不確かな場合の振る舞い]
```

**Anthropicとほぼ同じ考え方。** どちらも「明確・具体的・制約明示」が基本。

---

## 2. プロンプト設計の6原則（OpenAI公式）

1. **明確な指示を書く** — モデルは心を読めない。詳しく書くほど良い
2. **参照テキストを提供する** — ハルシネーション削減のためコンテキストを与える
3. **複雑なタスクを分割する** — Prompt Chaining（後述）
4. **モデルに「考える時間」を与える** — Chain of Thoughtを促す
5. **外部ツールを活用する** — Function Callingで確実な処理を外出し
6. **体系的にテストする** — Evals（評価フレームワーク）を整備する

---

## 3. Chain of Thought（CoT）

モデルに段階的に推論させる手法。

### 基本的なやり方

```
# シンプルなCoT促進
"Think step by step before giving the final answer."

# より明示的
"First, analyze [X]. Then, consider [Y]. Finally, conclude [Z]."
```

### Zero-shot CoT
「Think step by step」と付けるだけで精度が上がる（特に数学・論理問題）。

### Few-shot CoT
例の中に推論プロセスを含める。

```python
messages = [
    {"role": "user", "content": "Q: 15 + 27 = ?"},
    {"role": "assistant", "content": "15 + 27: 10+20=30, 5+7=12, 合計42。Answer: 42"},
    {"role": "user", "content": "Q: 38 + 45 = ?"},
]
```

### o1 / o3 / o4-miniモデル（推論モデル）との違い
- **推論モデルはCoTプロンプトが不要**（内部で自動的に extended thinking を実行）
- むしろ「step by step」を書くと邪魔になるケースもある
- system promptはサポートされない場合あり（モデルによる）→ `developer` ロールを使う

---

## 4. Few-shot プロンプティング

### 基本パターン

```python
messages = [
    {"role": "system", "content": "感情分類器。positive/negative/neutralのみ返す。"},
    {"role": "user", "content": "最高の映画だった！"},
    {"role": "assistant", "content": "positive"},
    {"role": "user", "content": "普通だった"},
    {"role": "assistant", "content": "neutral"},
    {"role": "user", "content": "最悪だった"},  # ← 実際の入力
]
```

### ベストプラクティス
- 例は **3〜5個** が最適（多すぎるとコスト増・混乱）
- **エッジケース**を含める（曖昧な判定の例を入れると精度向上）
- 例の**順序**が影響することがある → 最も代表的な例を最後に置く

**Claudeとの違い**: Claudeは `<example>` タグで例を囲むことを推奨するが、  
GPTは通常の `user`/`assistant` ターンとして渡すほうが自然。

---

## 5. 明示的な指示の書き方

### NG → OK の変換

| NG（曖昧） | OK（明示的） |
|---|---|
| "Be concise" | "Answer in 2 sentences or fewer" |
| "Be careful" | "Do not include X unless Y" |
| "Be conservative" | "Only include items with confidence > 0.9" |
| "Summarize" | "Summarize in 3 bullet points, each ≤20 words" |

> **「confidence-basedな指示は機能しない」** ← Claudeと全く同じ原則。  
> モデルは「自信があるとき」を正確に判断できない。

---

## 6. コンテキスト管理

<!-- 一言説明、30秒説明、採用理由を自分で書く -->

## 7. Prompt Chaining（プロンプトチェイニング）

<!-- 判断問題への回答、疑問、理解度（A/B/C）を残す -->
