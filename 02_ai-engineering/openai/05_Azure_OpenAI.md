# Azure OpenAI API ベストプラクティス

Azure OpenAI（AOAI）を使う上でOpenAI APIと異なる点に絞ったノート。

---

## 1. OpenAI API との主な差異

| 項目 | OpenAI API | Azure OpenAI API |
|---|---|---|
| **エンドポイント** | `https://api.openai.com/v1/` | `https://{リソース名}.openai.azure.com/` |
| **モデル指定** | `model="gpt-5.4"` | `model="{デプロイ名}"` ← **モデル名ではない** |
| **api_version** | 不要 | **必須**（例: `"2025-01-01-preview"`） |
| **SDKクラス** | `OpenAI()` | `AzureOpenAI()` |
| **認証** | `Authorization: Bearer {key}` | API key または Entra ID（推奨） |
| **コンテンツフィルタ** | OpenAI側で管理 | Azure AI Content Safety が追加で動作 |

**重要**: `model` パラメータには **Azureポータルで作成したデプロイ名** を渡す。  
モデル名（`gpt-5.4` など）を直接渡しても動かない。

---

## 2. SDK セットアップ

### APIキー認証

```python
import os
from openai import AzureOpenAI

client = AzureOpenAI(
    api_key=os.environ["AZURE_OPENAI_API_KEY"],
    api_version="2025-01-01-preview",
    azure_endpoint=os.environ["AZURE_OPENAI_ENDPOINT"],  
    # 例: "https://my-resource.openai.azure.com/"
)

response = client.chat.completions.create(
    model="my-gpt5-deployment",  # ← デプロイ名
    messages=[{"role": "user", "content": "こんにちは"}],
)
print(response.choices[0].message.content)
```

### Entra ID 認証（エンタープライズ推奨）

APIキーを管理不要。ロールベースアクセス制御（RBAC）で権限管理できる。

```python
from azure.identity import DefaultAzureCredential, get_bearer_token_provider
from openai import AzureOpenAI

token_provider = get_bearer_token_provider(
    DefaultAzureCredential(),
    "https://cognitiveservices.azure.com/.default"
)

client = AzureOpenAI(
    azure_ad_token_provider=token_provider,
    api_version="2025-01-01-preview",
    azure_endpoint=os.environ["AZURE_OPENAI_ENDPOINT"],
)
```

`DefaultAzureCredential` は環境変数 → Managed Identity → Azure CLI の順で認証情報を探す。  
Azure VM / App Service / AKS上では Managed Identity が自動的に使われる。

---

## 3. デプロイタイプの選択

| デプロイタイプ | 特徴 | 向いているユースケース |
|---|---|---|
| **Global Standard** | マルチリージョン自動ルーティング、高スループット | 一般的な本番用途 |
| **Standard** | 単一リージョン | データ所在地要件がある場合 |
| **Global Provisioned Managed** | 予約スループット（PTU）、低レイテンシ保証 | レイテンシSLAが必要な場合 |
| **Data Zone Provisioned** | US/EUのみでデータ処理を保証 | GDPR等のコンプライアンス要件 |
| **Global Batch** | 非同期、50%コスト削減 | 大量一括処理（→ `07_Cost_Optimization.md`） |

---

## 4. api_version の管理

api_version は Azure OpenAI の API の安定性・機能セットを決める。  
**最新のGA版を使うことを推奨**。`preview` バージョンは新機能にアクセスできるが本番では要注意。

```python
# 安定版の例（時点によって変わる）
api_version = "2024-10-21"  # GA

# プレビュー版（新機能が使える）
api_version = "2025-01-01-preview"
```

バージョンは [Azure OpenAI API バージョン一覧](https://learn.microsoft.com/azure/ai-services/openai/reference) を参照。

---

## 5. コンテンツフィルタリング

Azure OpenAI には **Azure AI Content Safety** が内蔵されており、以下を自動検出する:
- Hate speech / Violence / Sexual / Self-harm

フィルタに引っかかると `finish_reason: "content_filter"` が返る。

```python
choice = response.choices[0]

if choice.finish_reason == "content_filter":
    # コンテンツフィルタで遮断された
    filter_result = choice.content_filter_results
    print(f"Filter triggered: {filter_result}")
else:
    print(choice.message.content)
```

### フィルタのカスタマイズ
Azureポータルの「Content filters」でカテゴリごとの閾値を調整できる。  
医療・法律など特定ドメインでは申請してフィルタを緩和可能。

---

## 6. 環境変数の標準化

<!-- 一言説明、30秒説明、採用理由を自分で書く -->

## 7. LiteLLM 経由でのAzure OpenAI利用

<!-- 判断問題への回答、疑問、理解度（A/B/C）を残す -->
