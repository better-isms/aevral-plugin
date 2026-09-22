#!/usr/bin/env bash
# Static copy locks for the public plugin. No network. Exit 1 on first miss.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail() { echo "lock-test FAIL: $*" >&2; exit 1; }

need() {
  local file="$1" pat="$2"
  rg -q -F -- "$pat" "$ROOT/$file" || fail "$file missing /$pat/"
}
forbid() {
  local file="$1" pat="$2"
  if rg -q -F -- "$pat" "$ROOT/$file"; then
    fail "$file contains forbidden /$pat/"
  fi
}

for f in README.md skills/review/SKILL.md skills/review/SETUP.md; do
  need "$f" "Catch security flaws before you merge"
  need "$f" "https://docs.aevral.com/agent-setup/prompt.md"
  need "$f" "https://github.com/apps/aevral"
  need "$f" "app.aevral.com/login?ref="
  need "$f" "MCP is not live"
  need "$f" "500"
  need "$f" "25"
  forbid "$f" $'\u2014'
  forbid "$f" "heyGRC"
  forbid "$f" "opt-in"
  forbid "$f" "every pull request"
  forbid "$f" "api.heygrc.com"
  forbid "$f" "/v1/config"
  forbid "$f" "auto_once"
  forbid "$f" "mention_only"
  forbid "$f" "mcpServers"
done

need "skills/review/SKILL.md" "next pull request can already be reviewed"
need "README.md" "aevral@aevral-plugins"
need "plugin.json" '"version": "0.1.0"'
need ".claude-plugin/marketplace.json" '"name": "aevral-plugins"'
need ".claude-plugin/marketplace.json" '"name": "aevral"'
need ".grok-plugin/marketplace.json" '"name": "aevral-plugins"'

# skills.sh collision note
need "README.md" "share that destination"

# Coexistence assertion: YAML name is still review (namespaced hosts)
rg -q -- '^name: review$' "$ROOT/skills/review/SKILL.md" || fail "skills/review/SKILL.md missing YAML name review"

echo "lock-test OK"
