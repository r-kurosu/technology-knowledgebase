# Vertex AI（エンタープライズ利用）

Gemini APIのエンタープライズ版。Google Cloudのエコシステムに統合されている。  
Azure OpenAI に相当するポジション。

---

## 1. Gemini API vs Vertex AI

| 比較軸 | Gemini API（Google AI Studio） | Vertex AI |
|---|---|---|
| 認証 | APIキー | Service Account / Workload Identity |
| SLA | なし | あり（エンタープライズ契約） |
| データプライバシー | トレーニング利用される場合あり | トレーニング利用なし（デフォルト） |
| VPC対応 | なし | ✅ VPC Service Controls |
| リージョン指定 | 限定的 | ✅ グローバルなリージョン選択 |
| コンプライアンス | 基本的なもの | HIPAA / ISO / SOC 2 等 |
| 料金 | 従量課金（無料枠あり） | 従量課金（無料枠なし） |
| Fine-tuning | 限定的 | ✅ Supervised Fine-tuning |
| Model Garden | なし | ✅ サードパーティモデルも利用可 |

**判断基準**:
- 本番・機密データ・エンタープライズ → Vertex AI
- 個人・開発・検証フェーズ → Gemini API

---

## 2. セットアップ

```bash
# Google Cloud SDK インストール後
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID

pip install google-cloud-aiplatform
```

```python
import vertexai
from vertexai.generative_models import GenerativeModel

# プロジェクトとリージョンの設定
vertexai.init(project="my-project-id", location="us-central1")

model = GenerativeModel("gemini-2.5-flash")
response = model.generate_content("こんにちは")
print(response.text)
```

---

## 3. 認証方式

### Service Account（推奨）

```bash
# サービスアカウントキーファイルを使う場合
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
```

```python
from google.oauth2 import service_account
import google.auth

credentials = service_account.Credentials.from_service_account_file(
    "service-account.json",
    scopes=["https://www.googleapis.com/auth/cloud-platform"],
)

vertexai.init(
    project="my-project-id",
    location="us-central1",
    credentials=credentials,
)
```

### Workload Identity（GKE/Cloud Run 推奨）

```yaml
# Cloud Run サービスにサービスアカウントを紐付け
serviceAccountName: gemini-sa@my-project.iam.gserviceaccount.com
```

→ アプリ内で認証コードが不要。`vertexai.init(project=..., location=...)` だけでOK。

---

## 4. Vertex AI SDK の書き方（Gemini APIとの差分）

```python
# Gemini API（google.generativeai）
import google.generativeai as genai
model = genai.GenerativeModel("gemini-2.5-flash")

# Vertex AI（vertexai）
import vertexai
from vertexai.generative_models import GenerativeModel
vertexai.init(project="my-project", location="us-central1")
model = GenerativeModel("gemini-2.5-flash")
```

**ほぼ同じインターフェース**。`import` と `init()` が違うだけで、`generate_content()` 等の使い方は同じ。

---

## 5. モデルのエンドポイント形式

```python
# Vertex AIでのモデル指定（プレフィックスなし）
model = GenerativeModel("gemini-2.5-flash")

# または明示的にバージョン指定
model = GenerativeModel("gemini-2.5-flash@latest")
```

---

## 6. Vertex AI固有の機能

### Fine-tuning（Supervised Fine-tuning）

```python
from google.cloud import aiplatform

# チューニングジョブの作成
job = aiplatform.CustomTrainingJob(
    display_name="gemini-finetuning",
    script_path="training_script.py",
)
```

### Model Garden

Vertex AIコンソールから以下にアクセス可能:
- Gemini全モデル
- Llama, Mistral, Code Llama等のOSSモデル
- Anthropic Claude（Vertex AI経由でも利用可能）

### Batch Prediction

```python
from vertexai.generative_models import GenerativeModel

# バッチ処理（大量リクエスト向け、低コスト）
# BigQueryまたはCloud Storageに入力・出力を指定
```

---

## 7. リージョン選択

```python
# 推奨リージョン（東京最寄り）
vertexai.init(project="my-project", location="asia-northeast1")  # 東京

# 他の主要リージョン
# "us-central1"      # アイオワ（デフォルト・最新機能が先行）
# "europe-west4"     # オランダ
# "asia-southeast1"  # シンガポール
```

> 最新モデル・機能は `us-central1` で先行公開されることが多い。

---

## 8. Azure OpenAI との対比

| 比較軸 | Vertex AI (Gemini) | Azure OpenAI (GPT) |
|---|---|---|
| 基盤クラウド | Google Cloud (GCP) | Microsoft Azure |
| モデル | Gemini 2.5/3 系 | GPT-5.4 系 |
| 認証 | Service Account / Workload Identity | Azure AD / Managed Identity |
| VPC | ✅ VPC Service Controls | ✅ Private Endpoint |
| コンプライアンス | HIPAA, ISO 27001 等 | HIPAA, SOC 2, ISO 等 |
| Fine-tuning | ✅ SFT | ✅ SFT |
| リージョン | グローバル | Azure リージョン（日本東/西） |

---

## 参考リンク

- [Vertex AI Generative AI Docs](https://cloud.google.com/vertex-ai/generative-ai/docs)
- [Vertex AI SDK for Python](https://cloud.google.com/vertex-ai/docs/python-sdk/use-vertex-ai-python-sdk)
- [Authentication Guide](https://cloud.google.com/docs/authentication)
- [Vertex AI Pricing](https://cloud.google.com/vertex-ai/generative-ai/pricing)
- [Model Garden](https://cloud.google.com/vertex-ai/generative-ai/docs/model-garden/explore-models)
