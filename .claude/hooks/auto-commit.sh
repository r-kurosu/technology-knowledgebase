#!/usr/bin/env bash
# Auto-commit & push for this notes repo.
# Fires from the Stop hook after each Claude turn. Personal markdown repo, so
# commit granularity is intentionally coarse: one commit per turn that leaves
# changes. No-op when the working tree is clean.
set -uo pipefail

# Resolve the repo root from this script's own location (.claude/hooks/ -> root).
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO" || exit 0

# Bail unless we're inside a git work tree with something to commit.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
[ -n "$(git status --porcelain)" ] || exit 0

git add -A

changed="$(git diff --cached --name-only)"
count="$(printf '%s\n' "$changed" | grep -c .)"
first="$(printf '%s\n' "$changed" | head -1)"
ts="$(date '+%Y-%m-%d %H:%M')"

if [ "$count" -eq 1 ]; then
  subject="Auto-commit: ${first} (${ts})"
else
  subject="Auto-commit: ${count} files (${ts})"
fi

git commit -q -m "$subject" -m "$changed" \
  -m "Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>" >/dev/null 2>&1 || exit 0

if git push -q origin HEAD 2>/dev/null; then
  printf '{"systemMessage": "auto-commit ✓ pushed: %s"}\n' "$subject"
else
  printf '{"systemMessage": "auto-commit ✓ committed locally; push failed (offline?)"}\n'
fi
exit 0
