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

## 2. モデル一覧（2026年4月時点）

### Gemini 3 系（最新世代）

| モデルID | 特徴 | Context |
|---|---|---|
| `gemini-3.1-pro-preview` | 最上位フラグシップ、高度な推論・エージェント | 1M tokens |
| `gemini-3-flash` | Pro並みの推論力 + Flash の低レイテンシ | 1M tokens |
| `gemini-3.1-flash-lite` | コスト重視・大量処理向け | 1M tokens |

### Gemini 2.5 系（安定版 ← 本番推奨）

| モデルID | 特徴 | Context |
|---|---|---|
| `gemini-2.5-pro` | 複雑な推論・コード・数学・長文処理 | 1M tokens |
| `gemini-2.5-flash` | 価格対性能バランス最良 | 1M tokens |
| `gemini-2.5-flash-lite` | 最安・最高スループット | 128K tokens |

> Gemini 3 は `preview` 扱いが多い。本番は 2.5 系が安定。  
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

Geminiには組み込みの安全フィルターがあり、デフォルトで有効。

```python
from google.generativeai.types import HarmCategory, HarmBlockThreshold

model = genai.GenerativeModel(
    model_name="gemini-2.5-flash",
    safety_settings={
        HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_ONLY_HIGH,
        HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_ONLY_HIGH,
        HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_ONLY_HIGH,
    },
)
```

> OpenAI / Anthropicにはモデルレベルの安全設定パラメータがない（プロンプトで制御）。  
> Geminiは明示的に閾値を設定できる。

---

## 7. OpenAI互換エンドポイント

GeminiはOpenAI互換APIを提供しており、SDKの切り替えが容易。

```python
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_GEMINI_API_KEY",
    base_url="https://generativelanguage.googleapis.com/v1beta/openai/"
)

response = client.chat.completions.create(
    model="gemini-2.5-flash",
    messages=[{"role": "user", "content": "こんにちは"}],
)
print(response.choices[0].message.content)
```

> AnthropicはOpenAI互換エンドポイントを提供していない（LiteLLMで対応）。  
> Geminiはネイティブ互換を提供しているため移行コストが低い。

---

## 参考リンク

- [Gemini API Quickstart](https://ai.google.dev/gemini-api/docs/quickstart)
- [Models](https://ai.google.dev/gemini-api/docs/models)
- [Python SDK Reference](https://ai.google.dev/api/python/google/generativeai)
