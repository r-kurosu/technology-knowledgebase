# Gemini マルチモーダル

Geminiは**テキスト・画像・動画・音声・PDF・コード**をネイティブに処理できる。  
これがGeminiの最大の差別化要因。

---

## 1. 対応モダリティ一覧

| モダリティ | 入力 | 出力 | 備考 |
|---|---|---|---|
| テキスト | ✅ | ✅ | |
| 画像 | ✅ | ✅（Imagen/Imagen 4） | JPG/PNG/GIF/BMP/WebP |
| 動画 | ✅ | - | MP4/MOV等。YouTube URL直接指定も可 |
| 音声 | ✅ | ✅（TTS/Live API） | MP3/WAV/FLAC等 |
| PDF | ✅ | - | 最大1000ページ |
| コード/ファイル | ✅ | - | テキスト形式ファイル全般 |

---

## 2. 画像理解

### インラインデータ（小さい画像）

```python
import google.generativeai as genai
from pathlib import Path

model = genai.GenerativeModel("gemini-2.5-flash")

# ローカルファイルから
image_data = Path("chart.png").read_bytes()

response = model.generate_content([
    {"mime_type": "image/png", "data": image_data},
    "このグラフから読み取れるトレンドを説明して"
])
print(response.text)
```

### File API（大きいファイル・再利用する場合）

```python
# ファイルをアップロード（48時間キャッシュ）
uploaded_file = genai.upload_file("large_image.png", mime_type="image/png")

response = model.generate_content([
    uploaded_file,
    "このダイアグラムのアーキテクチャを説明して"
])
```

### 複数画像の比較

```python
response = model.generate_content([
    "以下の2つのスクリーンショットの差分を説明して:",
    {"mime_type": "image/png", "data": before_image},
    "変更前",
    {"mime_type": "image/png", "data": after_image},
    "変更後",
])
```

---

## 3. 動画理解

Geminiは動画をフレーム単位ではなく**シーケンシャルに処理**できる。

### YouTube URL の直接指定

```python
response = model.generate_content([
    "https://www.youtube.com/watch?v=...",
    "この動画の主要なポイントを箇条書きでまとめて"
])
```

### ローカル動画ファイル

```python
# File API経由でアップロード（動画は処理に時間がかかる）
import time

video_file = genai.upload_file("demo.mp4", mime_type="video/mp4")

# アップロード処理が完了するまで待機
while video_file.state.name == "PROCESSING":
    time.sleep(5)
    video_file = genai.get_file(video_file.name)

response = model.generate_content([
    video_file,
    "この動画のタイムスタンプ付きサマリーを作成して"
])
```

### タイムスタンプ指定

```python
response = model.generate_content([
    video_file,
    "01:30から02:00の間に何が起きているか説明して"
])
```

---

## 4. 音声理解

```python
audio_file = genai.upload_file("meeting.mp3", mime_type="audio/mp3")

# 文字起こし
response = model.generate_content([
    audio_file,
    "この音声を文字起こしして、話者ごとに分けて整理して"
])

# 音声の内容分析
response = model.generate_content([
    audio_file,
    "この会議音声から次のアクションアイテムを抽出して"
])
```

---

## 5. PDF処理

Geminiは**最大1000ページのPDF**をネイティブ処理できる。  
OCRではなく、レイアウト・表・図も含めて構造的に理解する。

```python
pdf_file = genai.upload_file("annual_report.pdf", mime_type="application/pdf")

response = model.generate_content([
    pdf_file,
    "この年次報告書から財務ハイライトを抽出して、表形式でまとめて"
])
```

**OpenAI / Claudeとの違い**:
- OpenAI: PDFは直接対応なし（テキスト抽出が必要）
- Claude: PDFネイティブ対応（ただし最大ページ数は制限あり）
- Gemini: **最大1000ページ**のPDFをネイティブ処理、表・図も理解

---

## 6. 複合モダリティ（テキスト + 画像 + PDF 混合）

```python
response = model.generate_content([
    pdf_file,           # 仕様書PDF
    screenshot_image,   # UIスクリーンショット
    "仕様書の要件に対してこのUIが準拠しているか確認して、不足点をリストアップして"
])
```

---

## 7. media_resolution パラメータ（Gemini 3）

Gemini 3では画像解像度の制御が可能。

```python
from google.generativeai.types import GenerationConfig

model = genai.GenerativeModel(
    "gemini-3-flash",
    generation_config=GenerationConfig(
        media_resolution="high"  # "low" / "medium" / "high"
    )
)
```

| 設定 | 用途 | トークン消費 |
|---|---|---|
| `"low"` | 大まかな内容把握、コスト重視 | 少 |
| `"medium"` | バランス型（デフォルト） | 中 |
| `"high"` | 細かいテキスト・図表の読み取り | 多 |

---

## 8. マルチモーダル埋め込み

Gemini Embedding 2はテキスト・画像・動画・音声を**統一ベクトル空間**に変換。

```python
result = genai.embed_content(
    model="gemini-embedding-2",
    content={"mime_type": "image/png", "data": image_data},
)
# テキストと画像の類似度をコサイン類似度で比較できる
```

ユースケース:
- 画像+テキストの横断検索
- マルチモーダルRAG
- 視覚的な類似アイテム検索

---

## 参考リンク

- [Vision Understanding](https://ai.google.dev/gemini-api/docs/vision)
- [Video Understanding](https://ai.google.dev/gemini-api/docs/video-understanding)
- [Audio Understanding](https://ai.google.dev/gemini-api/docs/audio)
- [Document Understanding](https://ai.google.dev/gemini-api/docs/document-processing)
- [Files API](https://ai.google.dev/gemini-api/docs/files)
