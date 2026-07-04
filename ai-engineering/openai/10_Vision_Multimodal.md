# OpenAI Vision / マルチモーダル

テキストと画像を組み合わせた入力でモデルを活用するガイド。

---

## 1. 基本概念

GPT-5.4 以降の最新モデルは **テキスト + 画像（+ 音声）** の入力を標準サポート。  
画像はトークンに換算されて処理される。

**対応モデル（2026年時点）**:
- `gpt-5.4`（マルチモーダル最強、ドキュメント理解に最適）
- `gpt-5.4-mini`、`gpt-5.4-nano`（コスト重視）
- `gpt-5.4-pro`（高難度タスク向け）
- `gpt-4o`（音声入出力が必要な場合）

---

## 2. 画像入力の方法

### 2-1. URL で指定

```python
from openai import OpenAI

client = OpenAI()

response = client.chat.completions.create(
    model="gpt-5.4",
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "image_url",
                    "image_url": {
                        "url": "https://example.com/chart.png",
                        "detail": "high"   # low / high / auto（デフォルト: auto）
                    }
                },
                {
                    "type": "text",
                    "text": "このグラフの傾向を分析して"
                }
            ]
        }
    ]
)

print(response.choices[0].message.content)
```

### 2-2. Base64 エンコードで指定（ローカルファイル）

```python
import base64
from openai import OpenAI

client = OpenAI()

# 画像をBase64エンコード
with open("screenshot.png", "rb") as f:
    image_data = base64.standard_b64encode(f.read()).decode("utf-8")

response = client.chat.completions.create(
    model="gpt-5.4",
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "image_url",
                    "image_url": {
                        "url": f"data:image/png;base64,{image_data}",
                        "detail": "low"   # コスト削減したい場合は low
                    }
                },
                {
                    "type": "text",
                    "text": "このスクリーンショットに何が表示されていますか？"
                }
            ]
        }
    ]
)
```

---

## 3. `detail` パラメータとトークンコスト

### detail の選択肢

| 設定 | 動作 | コスト |
|------|------|-------|
| `"low"` | 画像を512×512に縮小して処理 | 固定 85トークン |
| `"high"` | 高解像度タイル処理（精度重視） | 画像サイズに依存 |
| `"auto"` | モデルが自動選択（デフォルト） | 状況依存 |

### high の場合のトークン計算

1. 画像を2048×2048の範囲に収まるようリサイズ
2. 最短辺が768pxになるようさらにリサイズ
3. 512×512のタイルに分割
4. コスト = **85トークン（ベース）+ 170トークン × タイル数**

```
例: 1024×1024の画像（high）
→ タイル数: 4（512×512 ×4）
→ 85 + 170×4 = 765 トークン
```

> **注意**: GPT-5では `detail: low` を指定しても無視され、`high` と同量のトークンが消費されるという報告がある（2026年時点）。コスト計算は実際の `usage` で確認を。

---

## 4. 主なユースケース

### 4-1. OCR・文字抽出

```python
response = client.chat.completions.create(
    model="gpt-5.4",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "image_url", "image_url": {"url": "data:image/png;base64,...", "detail": "high"}},
                {"type": "text", "text": "画像内のテキストをすべて抽出してください。フォーマットを維持してください。"}
            ]
        }
    ]
)
```

### 4-2. ドキュメント理解（GPT-5.4 推奨）

```python
# PDFのページを画像化して分析（マルチページ対応）
pages_content = []
for page_image in pdf_pages:
    pages_content.append({
        "type": "image_url",
        "image_url": {"url": f"data:image/png;base64,{page_image}", "detail": "high"}
    })

pages_content.append({"type": "text", "text": "このドキュメントの主要ポイントを日本語で要約してください"})

response = client.chat.completions.create(
    model="gpt-5.4",
    messages=[{"role": "user", "content": pages_content}]
)
```

### 4-3. UI検査・スクリーンショット分析

```python
response = client.chat.completions.create(
    model="gpt-5.4",
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "image_url",
                    "image_url": {"url": "...", "detail": "original"}  # クリック精度が必要な場合は original
                },
                {"type": "text", "text": "このUIのアクセシビリティ上の問題点を指摘してください"}
            ]
        }
    ]
)
```

### 4-4. マルチ画像比較

```python
# 複数画像を同時に渡して比較
response = client.chat.completions.create(
    model="gpt-5.4",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "image_url", "image_url": {"url": "https://example.com/before.png"}},
                {"type": "image_url", "image_url": {"url": "https://example.com/after.png"}},
                {"type": "text", "text": "2枚の画像の違いを教えてください"}
            ]
        }
    ]
)
```

---

## 5. 制限事項

| 制限 | 詳細 |
|------|------|
| 対応フォーマット | JPEG, PNG, GIF, WebP |
| 画像サイズ | 20MB未満（URL指定の場合） |
| 1回のリクエスト | 最大20画像（モデルにより異なる） |
| プライバシー | 人物の顔認識・個人特定はしない設計 |

---

## 6. Anthropicとの比較

| 観点 | OpenAI (gpt-5.4) | Anthropic (claude-sonnet-4-6) |
|------|-----------------|-------------------------------|
| 画像入力形式 | `image_url`（URL / Base64） | `image`（Base64 / URL） |
| detailパラメータ | `detail: low/high/auto/original` | `source.type` で指定 |
| ドキュメント理解 | GPT-5.4 が特に強力 | 同等の能力あり |
| コスト計算 | タイル数ベース | トークンベース |
| 対応フォーマット | JPEG/PNG/GIF/WebP | JPEG/PNG/GIF/WebP |

---

## 参考リンク

- [Images and vision ガイド](https://developers.openai.com/api/docs/guides/images-vision)
- [GPT-5.4 マルチモーダルドキュメント理解](https://developers.openai.com/cookbook/examples/multimodal/document_and_multimodal_understanding_tips)
- [GPT-5 モデル情報](https://platform.openai.com/docs/models/gpt-5)
