# Gemini 長文コンテキスト（Long Context）

---

## 1. コンテキストウィンドウの比較

| モデル | Context Window | 備考 |
|---|---|---|
| `gemini-2.5-pro` | **1,048,576 tokens（1M）** | 長文処理の主力 |
| `gemini-2.5-flash` | **1,048,576 tokens（1M）** | コスパ型で同じ1M |
| `gemini-2.5-flash-lite` | 128K tokens | 大量スループット向け |
| `claude-sonnet-4-6` | 200K tokens | 比較参考 |
| `gpt-5.4` | 1M tokens | 比較参考 |

1Mトークンのスケール感:
- 約750万文字（日本語）
- 小説30〜40冊分
- コードリポジトリ丸ごと（中規模プロジェクト）
- 数時間分の動画

---

## 2. 長文コンテキストのベストプラクティス

### 情報の配置

```
[先頭] システム指示・タスク定義
  ↓
[中間] 参照ドキュメント・コンテキスト情報
  ↓
[末尾] 質問・タスクの具体的な指示 ← ここが最重要
```

> 研究によると、LLMは**先頭と末尾の情報**に最も注意を払う傾向がある（"Lost in the Middle"問題）。  
> タスクの指示は末尾に繰り返すことで精度向上。

### 不要なコンテキストの削除

```python
# NG: 関係ない情報を大量に詰め込む
prompt = f"{entire_codebase}\n\n{all_documentation}\n\n{question}"

# OK: 関連する部分だけを抽出して渡す
relevant_files = extract_relevant_files(question, codebase)
prompt = f"{relevant_files}\n\n{question}"
```

---

## 3. Context Caching（コンテキストキャッシュ）

同じ長文コンテキストを繰り返し使う場合、**キャッシュ化でコスト削減**できる。

### 仕組み

```
通常:  [長文ドキュメント 100K tokens] + [質問] → 毎回フル課金
キャッシュ: [長文ドキュメント 100K tokens をキャッシュ] + [質問] → キャッシュ分は割引
```

### 実装

```python
import google.generativeai as genai

# キャッシュの作成
cache = genai.caching.CachedContent.create(
    model="gemini-2.5-flash",
    contents=[large_document],  # キャッシュしたいコンテキスト
    ttl=datetime.timedelta(hours=1),  # キャッシュ有効期限（デフォルト1時間）
    display_name="quarterly_report_cache",
)

# キャッシュを使ったモデル初期化
model = genai.GenerativeModel.from_cached_content(cache)

# キャッシュを使ってリクエスト（長文部分はキャッシュから読む）
response = model.generate_content("第2四半期の売上トレンドを分析して")
response = model.generate_content("競合他社との比較を教えて")
response = model.generate_content("次期の戦略提案をまとめて")
```

### コスト構造

| | 通常 | キャッシュ利用 |
|---|---|---|
| 入力トークン | 通常単価 | **〜75%割引** |
| キャッシュ保存料 | - | 別途発生（時間単位） |
| 適用条件 | - | 最小32,768tokens以上 |

**使い所**:
- 同じ長文ドキュメントに繰り返し質問する場合
- マルチターン会話で共通の参照資料がある場合
- バッチ処理で同じコンテキストを使い回す場合

**Claudeとの違い**: Claudeも Prompt Caching あり（`cache_control` ヘッダー）。OpenAIも自動キャッシュあり。  
Geminiは明示的なキャッシュ管理APIが提供されている。

---

## 4. 長文処理のユースケース

### コードリポジトリ全体の分析

```python
import os

# リポジトリのファイルを収集
repo_content = []
for root, dirs, files in os.walk("./my_project"):
    dirs[:] = [d for d in dirs if d not in ['.git', 'node_modules', '__pycache__']]
    for file in files:
        if file.endswith(('.py', '.js', '.ts', '.md')):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                repo_content.append(f"### {filepath}\n{f.read()}")

full_context = "\n\n".join(repo_content)

response = model.generate_content([
    full_context,
    "このコードベースのアーキテクチャを説明して、改善できそうな点を指摘して"
])
```

### 長文PDF（報告書・マニュアル）

```python
pdf_file = genai.upload_file("500page_manual.pdf", mime_type="application/pdf")

questions = [
    "第3章の主要なポイントをまとめて",
    "セキュリティ要件はどこに記載されているか",
    "エラーコード一覧表を抽出して",
]

for q in questions:
    response = model.generate_content([pdf_file, q])
    print(f"Q: {q}\nA: {response.text}\n")
```

---

## 5. トークン数の確認

```python
# リクエスト前にトークン数を確認してコストを見積もる
response = model.count_tokens([large_document, "質問"])
print(f"入力トークン数: {response.total_tokens:,}")
```

---

## 参考リンク

- [Long Context Guide](https://ai.google.dev/gemini-api/docs/long-context)
- [Context Caching](https://ai.google.dev/gemini-api/docs/caching)
- [Pricing](https://ai.google.dev/gemini-api/docs/pricing)
