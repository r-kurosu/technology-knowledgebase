# OpenAI vs Anthropic 比較まとめ

実務でどちらを使うか判断するための比較ノート。

---

## 1. API構造の比較

| 項目 | OpenAI | Anthropic |
|---|---|---|
| **APIエンドポイント** | `/v1/chat/completions` | `/v1/messages` |
| **システムプロンプト** | `{"role": "system", ...}` | `system: "..."` (トップレベル) |
| **ロール** | system / user / assistant / tool | user / assistant (+ tool) |
| **マルチターン** | `messages` リストに追加 | 同じ |
| **ストリーミング** | `stream=True` | `stream=True` |
| **最大トークン** | `max_tokens` / `max_completion_tokens` | `max_tokens` |

---

## 2. プロンプト設計の共通点

**ほとんどの原則は共通**。以下はどちらにも当てはまる:

- 明確で具体的な指示を書く
- Few-shotで例を示す（3〜5個が最適）
- Confidence-basedな指示（「自信があるときだけ」）は機能しない
- 複雑なタスクはPrompt Chainingで分割する
- 構造化出力はスキーマ強制を使う（プロンプトだけに頼らない）
- リトライ時は具体的なエラー情報を含める
- プロンプトインジェクション対策は多層防御

---

## 3. プロンプト設計の相違点

| 項目 | OpenAI / GPT | Anthropic / Claude |
|---|---|---|
| **区切り文字の推奨** | `---`, `"""`, Markdownなど | **XMLタグが特に推奨**（ファインチューニングで強化） |
| **CoTプロンプト** | 通常モデルには有効 | 通常モデルには有効 |
| **推論モデルのCoT** | o1/o3には不要（内部でThinking） | Claudeの拡張思考(`budget_tokens`/`effort`)は別途オプション |
| **Few-shotの形式** | user/assistantのターンとして渡す | `<example>`タグで囲む方式が推奨 |
| **Prefill** | アシスタントメッセージの先頭を指定できない | 以前は可能だったが4.6以降は非推奨 |
| **Roleplay/人格設定** | system promptで定義 | system promptで定義（Claudeは「Character play」として詳細ガイドあり） |

---

## 4. 構造化出力の比較

| 項目 | OpenAI | Anthropic |
|---|---|---|
| **推奨方式** | Structured Outputs (`response_format` + `strict: true`) | `output_config.format` (json_schema) |
| **Python SDK** | `client.beta.chat.completions.parse()` + Pydantic | `client.messages.create()` + Pydantic |
| **JSON mode** | あり（スキーマ保証なし） | なし（json_schemaのみ） |
| **スキーマ保証** | `strict: true` で100%保証 | スキーマ強制で高信頼性 |
| **Nullable** | `["string", "null"]` | `Optional[str]` (Pydantic) |

---

## 5. Tool Use / Function Callingの比較

| 項目 | OpenAI | Anthropic |
|---|---|---|
| **呼称** | Function Calling / Tool Use | Tool Use |
| **ツール定義** | `tools[].function.parameters` (JSON Schema) | `tools[].input_schema` (JSON Schema) |
| **Strict mode** | `function.strict: true` | `strict: true`（ツール定義内） |
| **並列呼び出し** | `tool_calls`（リスト） | 複数の`tool_use` content block |
| **結果返却** | `{"role": "tool", "tool_call_id": ..., "content": ...}` | `{"role": "user", "content": [{"type": "tool_result", ...}]}` |
| **tool_choice** | `"auto"` / `"required"` / `"none"` / 特定指定 | `{type: "auto"}` / `{type: "any"}` / `{type: "none"}` / `{type: "tool", name: ...}` |

---

## 6. コスト・パフォーマンスの比較（2026年7月時点）

<!-- 一言説明、30秒説明、採用理由を自分で書く -->

## 7. SDKの書き方比較

<!-- 判断問題への回答、疑問、理解度（A/B/C）を残す -->
