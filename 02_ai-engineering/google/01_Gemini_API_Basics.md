# Gemini API 基礎

---

## 1. アクセス経路の選択

Google AIには2つの入口がある。

| | **Google AI Studio / Gemini API** | **Vertex AI** |
|---|---|---|
| 対象 | 個人・スタートアップ・プロトタイピング | エンタープライズ・GCP利用者 |
| 認証 | APIキー | Service Account / Workload Identity |
| 無料枠 | あり（レート制限付き） | なし（従量課金） |
| データ利用 | トレーニング利用される場合あり | トレーニング利用なし（契約次第） |
| SLA | なし | あり |
| 詳細 | [08_Vertex_AI.md](08_Vertex_AI.md) 参照 | 同左 |

**実務での判断基準**:
- 開発・検証フェーズ → Gemini API（APIキー）
- 本番運用・機密データ → Vertex AI

---

## 2. モデル一覧（2026年7月時点）

### Gemini 3.5 系（最新世代）

| モデル | 特徴 | Context |
|---|---|---|
| Gemini 3.5 Pro | プレミアム推論フラグシップ（順次展開中） | 1M tokens |
| Gemini 3.5 Flash | Flash級の速度・コストでPro級に迫る知能（GA） | 1M tokens |

### Gemini 3.1 系

| モデル | 特徴 | Context |
|---|---|---|
| Gemini 3.1 Pro | 推論重視。Adaptive Thinking・グラウンディング | 1M tokens |
| Gemini 3.1 Flash-Lite | コスト効率重視の大量処理向け | 1M tokens |

### 画像生成

| モデル | 特徴 |
|---|---|
| Nano Banana Pro（Gemini 3 Pro Image） | 最高品質の画像生成 |
| Nano Banana 2（Gemini 3.1 Flash Image） | 高スループット・低価格 |

> 正確なモデルID・スペックは流動的なため、利用前に公式ドキュメントで確認すること。  
> Preview モデルは最低2週間の廃止予告で変更される場合あり。

---

## 3. SDK セットアップ（Python）

```bash
pip install google-genai
```

```python
import google.generativeai as genai

# APIキー認証（Google AI Studio用）
genai.configure(api_key="YOUR_API_KEY")

# または環境変数
# export GOOGLE_API_KEY="YOUR_API_KEY"
```

---

## 4. 基本的なAPI呼び出し

```python
import google.generativeai as genai

model = genai.GenerativeModel("gemini-2.5-flash")

response = model.generate_content("Pythonでフィボナッチ数列を生成するコードを書いて")
print(response.text)
```

### チャット（マルチターン）

```python
model = genai.GenerativeModel("gemini-2.5-flash")
chat = model.start_chat()

response = chat.send_message("こんにちは")
print(response.text)

response = chat.send_message("続けて、もっと詳しく")
print(response.text)
```

> **Claudeとの違い**: Geminiは `role: "model"` を使う（OpenAI/Claudeの `"assistant"` に相当）。

---

## 5. Generation Config（パラメータ設定）

```python
from google.generativeai.types import GenerationConfig

model = genai.GenerativeModel(
    model_name="gemini-2.5-flash",
    generation_config=GenerationConfig(
        temperature=0.0,        # 0.0〜2.0（Geminiは2.0まで設定可）
        top_p=0.95,
        top_k=40,               # OpenAI/Claudeにはないパラメータ
        max_output_tokens=2048,
        response_mime_type="text/plain",  # or "application/json"
    ),
)
```

| パラメータ | 推奨値 | 用途 |
|---|---|---|
| `temperature` | 0.0〜0.3 | コード生成・データ抽出 |
| `temperature` | 0.7〜1.5 | 創作・ブレスト |
| `top_k` | 40（デフォルト） | Gemini固有。サンプリング候補数を制限 |
| `max_output_tokens` | 明示的に設定 | コスト管理 |

---

## 6. Safety Settings（安全フィルター）

<!-- 一言説明、30秒説明、採用理由を自分で書く -->

## 7. OpenAI互換エンドポイント

<!-- 判断問題への回答、疑問、理解度（A/B/C）を残す -->
