# Anthropic / Claude 参考リンク集

Anthropic API・Claude Code・MCP に関する公式ドキュメントと学習リソースのリンク集。

---

## Anthropic 公式ドキュメント

### エージェント & ツール
- [Managed Agents Overview](https://docs.anthropic.com/en/docs/managed-agents/overview)
- [New capabilities for building agents on the Anthropic API](https://www.anthropic.com/news/agent-capabilities-api)
- [Tool Use Overview](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview)
- [Define Tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools)
- [Implement Tool Use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/implement-tool-use)
- [Strict Tool Use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/strict-tool-use)
- [Parallel Tool Use](https://platform.claude.com/docs/en/agents-and-tools/tool-use/parallel-tool-use)
- [Programmatic Tool Calling](https://platform.claude.com/docs/en/agents-and-tools/tool-use/programmatic-tool-calling)
- [Agent SDK Overview](https://platform.claude.com/docs/en/agent-sdk/overview)
- [Subagents in the SDK](https://platform.claude.com/docs/en/agent-sdk/subagents)
- [Agent SDK Python Reference](https://platform.claude.com/docs/en/agent-sdk/python)

### プロンプトエンジニアリング
- [Prompt Engineering Overview](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview)
- [Best Practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
- [Be Clear, Direct, and Detailed](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/be-clear-and-direct)
- [Use XML Tags](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/use-xml-tags)
- [Multishot Prompting](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/multishot-prompting)
- [Chain Complex Prompts](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/chain-prompts)
- [Prefill Claude's Response](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prefill-claudes-response)
- [System Prompts](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/system-prompts)
- [Long Context Prompting Tips](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/long-context-tips)

### ビルド
- [Rate Limits API](https://docs.anthropic.com/en/api/rate-limits)
- [Structured Outputs](https://platform.claude.com/docs/en/build-with-claude/structured-outputs)
- [Context Windows](https://docs.anthropic.com/en/docs/build-with-claude/context-windows)
- [Prompt Caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching)
- [Token Counting](https://platform.claude.com/docs/en/build-with-claude/token-counting)
- [Extended Thinking](https://platform.claude.com/docs/en/build-with-claude/extended-thinking)
- [Adaptive Thinking](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking)
- [Batch Processing](https://platform.claude.com/docs/en/build-with-claude/batch-processing)

### テスト & ガードレール
- [Reduce Hallucinations](https://docs.anthropic.com/en/docs/test-and-evaluate/strengthen-guardrails/reduce-hallucinations)
- [Increase Output Consistency](https://docs.anthropic.com/en/docs/test-and-evaluate/strengthen-guardrails/increase-consistency)
- [Mitigate Jailbreaks & Prompt Injections](https://platform.claude.com/docs/en/test-and-evaluate/strengthen-guardrails/mitigate-jailbreaks)

### MCP (Model Context Protocol)
- [MCP Overview](https://docs.anthropic.com/en/docs/mcp)
- [MCP Specification](https://modelcontextprotocol.io/specification/2025-11-25)
- [MCP Architecture](https://modelcontextprotocol.io/docs/learn/architecture)
- [MCP Transports](https://modelcontextprotocol.io/specification/2025-03-26/basic/transports)

---

## Claude Code ドキュメント

### コア設定
- [Claude Code Settings](https://code.claude.com/docs/en/settings)
- [How Claude Remembers Your Project (Memory)](https://code.claude.com/docs/en/memory)
- [Explore the .claude Directory](https://code.claude.com/docs/en/claude-directory)
- [Configure Server-Managed Settings](https://code.claude.com/docs/en/server-managed-settings)

### パーミッション & セキュリティ
- [Configure Permissions](https://code.claude.com/docs/en/permissions)
- [Choose a Permission Mode](https://code.claude.com/docs/en/permission-modes)
- [Sandboxing](https://code.claude.com/docs/en/sandboxing)
- [Security](https://code.claude.com/docs/en/security)

### フック & ワークフロー
- [Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Automate Workflows with Hooks](https://code.claude.com/docs/en/hooks-guide)

### スキル & コマンド
- [Extend Claude with Skills](https://code.claude.com/docs/en/skills)
- [Slash Commands](https://code.claude.com/docs/en/slash-commands)
- [Commands](https://code.claude.com/docs/en/commands)

### CI/CD 統合
- [Run Claude Code Programmatically](https://code.claude.com/docs/en/headless)
- [Claude Code GitHub Actions](https://code.claude.com/docs/en/github-actions)
- [Claude Code GitLab CI/CD](https://code.claude.com/docs/en/gitlab-ci-cd)
- [Code Review](https://code.claude.com/docs/en/code-review)

### その他
- [ant CLI](https://docs.anthropic.com/en/docs/ant-cli/overview)
- [Best Practices](https://code.claude.com/docs/en/best-practices)
- [Common Workflows](https://code.claude.com/docs/en/common-workflows)
- [Create Custom Subagents](https://code.claude.com/docs/en/sub-agents)
- [CLI Reference](https://code.claude.com/docs/en/cli-reference)
- [MCP](https://code.claude.com/docs/en/mcp)

---

## Anthropic エンジニアリングブログ（必読）

| 記事 | ドメイン |
|------|---------|
| [Building Effective Agents](https://www.anthropic.com/research/building-effective-agents) | D1 |
| [How We Built Our Multi-Agent Research System](https://www.anthropic.com/engineering/multi-agent-research-system) | D1, D5 |
| [Harness Design for Long-Running Apps](https://www.anthropic.com/engineering/harness-design-long-running-apps) | D1 |
| [Building Agents with the Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk) | D1 |
| [Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) | D5 |
| [Scaling Managed Agents: Decoupling the brain from the harness](https://www.anthropic.com/engineering/managed-agents) | D1 |
| [Writing Effective Tools for AI Agents](https://www.anthropic.com/engineering/writing-tools-for-agents) | D4 |
| [Advanced Tool Use](https://www.anthropic.com/engineering/advanced-tool-use) | D4 |
| [Code Execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp) | D4 |

---

## Anthropic Academy（無料コース）

- [Anthropic Academy Portal](https://anthropic.skilljar.com) — 13コース、全て無料、修了証付き
- [Introduction to Model Context Protocol](https://anthropic.skilljar.com/introduction-to-model-context-protocol)
- [MCP Advanced Topics](https://anthropic.skilljar.com/model-context-protocol-advanced-topics)

---

## GitHub リソース

### 公式
- [Anthropic Courses](https://github.com/anthropics/courses) — Jupyter Notebook形式のハンズオン教材
- [Anthropic Cookbook](https://github.com/anthropics/anthropic-cookbook) — 実践レシピ集
  - [Extracting Structured JSON](https://github.com/anthropics/anthropic-cookbook/blob/main/tool_use/extracting_structured_json.ipynb)
  - [Tool Choice](https://github.com/anthropics/anthropic-cookbook/blob/main/tool_use/tool_choice.ipynb)

### コミュニティ
- [ThibautMelen/agentic-workflow-patterns](https://github.com/ThibautMelen/agentic-workflow-patterns) — ワークフローパターン実装例
