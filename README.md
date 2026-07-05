# technology-knowledgebase

ITの基礎知識をMarkdownで体系化した学習ノート。

## ディレクトリ構成

```
01_it-fundamentals/          # IT基礎
  00_learning_system/        # 学習ルール・テンプレート
  01_core_topics/            # コアトピック（10分野）
    01_network/              # ネットワーク基礎・アドレッシング・ルーティング・CDN
    02_security/             # 認証・認可・暗号化・監査
    03_compute/              # プロセス・VM・コンテナ・サーバーレス・スケーリング
    04_storage/              # オブジェクト・ブロック・ファイル・ライフサイクル
    05_database/             # RDBMS・NoSQL・分析・キャッシュ・検索
    06_distributed_systems/  # スケーラビリティ・CAP定理・分散トランザクション
    07_reliability/          # SLO・障害設計・DR・カオスエンジニアリング
    08_operations_observability/ # メトリクス・ログ・トレース・アラート
    09_iac_devops/           # IaC・CI/CD・GitOps
    10_cost_optimization/    # コスト可視化・最適化戦略
  02_applied_topics/         # 応用トピック
    01_data_platform/        # データ基盤アーキテクチャ・取り込み・DWH・ガバナンス
    02_rag_agent_architecture/ # RAG基礎・検索・Agent・本番運用

02_ai-engineering/           # AIプロバイダー別のAPI・ベストプラクティス
  anthropic/                 # Claude API・Agentic設計・Claude Code・MCP
  openai/                    # GPT API・構造化出力・Fine-tuning・マルチモーダル
  google/                    # Gemini API・Long Context・Vertex AI

03_business-domains/         # 業務ドメイン概念（ERP・CRM・SCM・PLM）

04_sap/                      # SAPモジュール（FI-CO・MM・PP・SD・BDC）

05_fde-roadmap/              # Forward Deployed Engineer スキル・学習ロードマップ
```

## ブランチ

| ブランチ | 用途 |
|---------|------|
| `main` | 完成ノート。教科書として読む |
| `workbook-template` | 学習者向け雛形。セクション6・7（自分の言葉）が空 |

## 学習者向け：使い方

1. このリポをfork
2. `workbook-template` ブランチをチェックアウト
3. `01_it-fundamentals/` から始める
4. Claude Code と対話しながら各ノートを埋めていく

詳細は [`01_it-fundamentals/00_learning_system/`](01_it-fundamentals/00_learning_system/) を参照。
