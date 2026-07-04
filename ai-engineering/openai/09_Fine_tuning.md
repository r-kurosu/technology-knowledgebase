# OpenAI Fine-tuning

ベースモデルを独自データで追加学習し、特定タスクに特化させる手法。

---

## 1. いつFine-tuningを使うべきか

### Fine-tuningが有効なケース
- **一貫したフォーマット・スタイルが必要**: 社内用語、特定の文体、出力フォーマット
- **Few-shotでも再現できないパターン**: 数百〜数千の例が必要なほど複雑な挙動
- **推論コストの削減**: 長いシステムプロンプトをモデルに内包させることでトークン削減
- **レイテンシ改善**: 小型モデルを特化させて高速化

### Fine-tuningより先に試すべき手法

| 手法 | 適用条件 |
|------|---------|
| プロンプトエンジニアリング | まず最初に試す。コスト・時間ゼロ |
| Few-shot prompting | 例示で解決できるなら不要 |
| RAG | 知識の補完が目的なら Fine-tuning より効果的 |
| **Fine-tuning** | 上記では解決できない行動・スタイル変更 |

**原則**: Fine-tuningはプロンプトで解決できない問題に使う。プロンプト最適化が先。

---

## 2. データセットの準備

### フォーマット（JSONL）

各行が1つの学習例。`messages` 形式（Chat Completions と同じ構造）。

```jsonl
{"messages": [{"role": "system", "content": "あなたは丁寧な顧客サポートです。"}, {"role": "user", "content": "注文をキャンセルしたい"}, {"role": "assistant", "content": "ご注文のキャンセルについてお手伝いします。ご注文番号をお教えください。"}]}
{"messages": [{"role": "system", "content": "あなたは丁寧な顧客サポートです。"}, {"role": "user", "content": "返品はできますか？"}, {"role": "assistant", "content": "はい、商品到着後30日以内であれば返品可能です。返品手続きの詳細をご案内します。"}]}
```

### データ量の目安

| 用途 | 推奨例数 |
|------|---------|
| 最小（動作確認） | 10例 |
| 実用レベル | 50〜100例 |
| 高品質な専門特化 | 500〜1,000例+ |

**質 > 量**: 100例の高品質データ > 1,000例の粗雑なデータ。

---

## 3. Fine-tuning の実行

### 3-1. ファイルアップロード

```python
from openai import OpenAI

client = OpenAI()

# 学習データをアップロード
with open("training_data.jsonl", "rb") as f:
    training_file = client.files.create(
        file=f,
        purpose="fine-tune"   # fine-tune 用途を指定
    )

print(training_file.id)  # file-xxxxxxxx
```

### 3-2. Fine-tuning ジョブの作成

```python
job = client.fine_tuning.jobs.create(
    training_file=training_file.id,
    model="gpt-4o-mini",   # 現状: gpt-4o-mini, gpt-4.1-nano 等が対応
    hyperparameters={
        "n_epochs": 3,                      # 学習エポック数（デフォルト: auto）
        "batch_size": "auto",               # バッチサイズ（デフォルト: auto）
        "learning_rate_multiplier": "auto"  # 学習率の倍率（デフォルト: auto）
    },
    suffix="my-model-v1"   # カスタムモデル名のサフィックス（省略可）
)

print(job.id)       # ftjob-xxxxxxxx
print(job.status)   # validating_files → queued → running → succeeded
```

### 3-3. ジョブの監視

```python
# ステータス確認
job = client.fine_tuning.jobs.retrieve(job_id)
print(job.status)
print(job.fine_tuned_model)  # 完了後: ft:gpt-4o-mini:my-org:my-model-v1:xxxxxx

# イベントログの取得（進捗・エラー確認）
events = client.fine_tuning.jobs.list_events(fine_tuning_job_id=job_id)
for event in events.data:
    print(f"{event.created_at}: {event.message}")
```

---

## 4. Fine-tuned モデルの使用

```python
# 通常のChat Completions APIと全く同じ使い方
response = client.chat.completions.create(
    model="ft:gpt-4o-mini:my-org:my-model-v1:xxxxxx",   # Fine-tuned モデル ID を指定
    messages=[
        {"role": "system", "content": "あなたは丁寧な顧客サポートです。"},
        {"role": "user", "content": "返品したい"}
    ]
)

print(response.choices[0].message.content)
```

---

## 5. ハイパーパラメータの調整

| パラメータ | デフォルト | 調整のヒント |
|-----------|-----------|-------------|
| `n_epochs` | auto | 小データセットは増やす、大データセットは減らす |
| `batch_size` | auto | 大きいほど安定学習・低バリアンス |
| `learning_rate_multiplier` | auto | 過学習時は小さく（0.1〜0.5）、過少学習時は大きく |

**推奨**: 最初は全て `"auto"` で試し、評価後に調整。

---

## 6. 評価と品質管理

```python
# バリデーションデータを指定して客観的評価
job = client.fine_tuning.jobs.create(
    training_file="file-training-xxxx",
    validation_file="file-validation-xxxx",  # 学習に使わない評価用データ
    model="gpt-4o-mini"
)
# ジョブイベントで validation_loss を確認
```

### 評価の観点
1. **トレーニングロスの低下**: 収束しているか
2. **バリデーションロス**: 過学習していないか（training loss と乖離したら過学習）
3. **人間評価**: 実際のユースケースでの品質確認

---

## 7. コスト

Fine-tuning のコスト構造：

| フェーズ | 料金 |
|---------|------|
| 学習（Training） | モデル・トークン数に依存（例: gpt-4o-mini は $3/1M tokens） |
| 推論（Inference） | ベースモデルより高い場合が多い |

**コスト計算**: `(データセットのトークン数) × n_epochs × 学習料金`

---

## 8. Anthropicとの比較

| 観点 | OpenAI Fine-tuning | Anthropic |
|------|-------------------|-----------|
| 対応モデル | gpt-4o-mini, gpt-4.1-nano 等 | Fine-tuning API 非公開（2026年時点） |
| データ形式 | JSONL | - |
| 代替手段 | - | プロンプトエンジニアリング・RAGで対応 |

---

## 参考リンク

- [Fine-tuning ガイド](https://platform.openai.com/docs/guides/fine-tuning)
- [Fine-tuning API リファレンス](https://platform.openai.com/docs/api-reference/fine-tuning)
- [Supervised fine-tuning ガイド](https://platform.openai.com/docs/guides/supervised-fine-tuning)
