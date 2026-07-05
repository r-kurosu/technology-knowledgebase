# Gemini Function Calling / Tool Use

---

## 1. 基本的なワークフロー

```
① ユーザー入力 + ツール定義 → モデルへ送信
② モデルが関数呼び出しを決定 → FunctionCall レスポンスを返す
③ アプリが実際の関数を実行
④ 実行結果を FunctionResponse としてモデルへ送信
⑤ モデルが最終回答を生成
```

---

## 2. ツール定義

```python
import google.generativeai as genai

# ツール定義（JSON Schema形式）
get_weather = genai.protos.FunctionDeclaration(
    name="get_weather",
    description="指定した都市の現在の天気情報を取得する",
    parameters=genai.protos.Schema(
        type=genai.protos.Type.OBJECT,
        properties={
            "city": genai.protos.Schema(
                type=genai.protos.Type.STRING,
                description="都市名（例: Tokyo, Osaka）",
            ),
            "unit": genai.protos.Schema(
                type=genai.protos.Type.STRING,
                enum=["celsius", "fahrenheit"],
                description="温度の単位",
            ),
        },
        required=["city"],
    ),
)

model = genai.GenerativeModel(
    model_name="gemini-2.5-flash",
    tools=[genai.protos.Tool(function_declarations=[get_weather])],
)
```

---

## 3. 実装例（フルサイクル）

```python
chat = model.start_chat()

# ① ユーザー入力
response = chat.send_message("東京の天気を教えて")

# ② モデルが関数呼び出しを返す
if response.candidates[0].content.parts[0].function_call:
    fc = response.candidates[0].content.parts[0].function_call
    print(f"関数名: {fc.name}")
    print(f"引数: {dict(fc.args)}")
    # → {"city": "Tokyo", "unit": "celsius"}

    # ③ 実際の関数を実行（アプリ側の処理）
    result = get_weather_api(fc.args["city"], fc.args.get("unit", "celsius"))
    # → {"temperature": 22, "condition": "晴れ", "humidity": 65}

    # ④ 結果をモデルへ送信
    response = chat.send_message(
        genai.protos.Content(
            parts=[genai.protos.Part(
                function_response=genai.protos.FunctionResponse(
                    name=fc.name,
                    response={"result": result},
                )
            )]
        )
    )

# ⑤ 最終回答
print(response.text)
# → "東京は現在22℃で晴れています。湿度は65%です。"
```

---

## 4. Tool Config（呼び出しモード）

```python
from google.generativeai.types import Tool, ToolConfig

model = genai.GenerativeModel(
    model_name="gemini-2.5-flash",
    tools=[tool],
    tool_config=ToolConfig(
        function_calling_config=ToolConfig.FunctionCallingConfig(
            mode=ToolConfig.FunctionCallingConfig.Mode.AUTO,  # デフォルト
            # allowed_function_names=["get_weather"],  # 特定ツールのみ許可
        )
    ),
)
```

| モード | 挙動 |
|---|---|
| `AUTO` | モデルが自動判断（デフォルト） |
| `ANY` | 必ずツールを呼び出す（`tool_choice: "required"` 相当） |
| `NONE` | ツールを呼び出さない（テキストのみ回答） |
| `VALIDATED`（Gemini 3） | スキーマ準拠を強制。不正な関数呼び出し削減 |

> **VALIDATED モード（Gemini 3系）**: AUTO より精度が高く、スキーマを外れた呼び出しを自動修正。本番推奨。

---

## 5. 並列ツール呼び出し

Geminiは1回のレスポンスで複数のツールを同時に呼び出せる。

```python
# モデルが「get_weather(Tokyo)」と「get_weather(Osaka)」を同時に返す場合
for part in response.candidates[0].content.parts:
    if part.function_call:
        # 各呼び出しを並列処理
        results.append(execute_function(part.function_call))
```

---

## 6. 内蔵ツール（Built-in Tools）

<!-- 一言説明、30秒説明、採用理由を自分で書く -->

## 7. 他プロバイダーとの比較

<!-- 判断問題への回答、疑問、理解度（A/B/C）を残す -->
