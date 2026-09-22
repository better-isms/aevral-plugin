#!/usr/bin/env bash
# Static copy locks for the public plugin. No network. Exit 1 on first miss.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 - "$ROOT" <<'PY'
import json, sys
from pathlib import Path

root = Path(sys.argv[1])
fail_n = 0

def fail(msg):
    global fail_n
    print(f"lock-test FAIL: {msg}", file=sys.stderr)
    fail_n += 1

def load(rel):
    p = root / rel
    if not p.exists():
        fail(f"missing {rel}")
        return ""
    return p.read_text(encoding="utf8")

md_files = [
    "README.md",
    "SETUP.md",
    "GEMINI.md",
    "skills/review/SKILL.md",
    "skills/review/SETUP.md",
    "agents/aevral-review.agent.md",
    ".github/agents/aevral-review.agent.md",
]
need_all = [
    "Catch security flaws before you merge",
    "https://docs.aevral.com/agent-setup/prompt.md",
    "https://github.com/apps/aevral",
    "MCP is not live",
]
forbid_all = [
    "\u2014",
    "heyGRC",
    "opt-in",
    "every pull request",
    "api.heygrc.com",
    "/v1/config",
    "auto_once",
    "mention_only",
    "mcpServers",
]

for rel in md_files:
    text = load(rel)
    if not text:
        continue
    for pat in need_all:
        if pat not in text:
            fail(f"{rel} missing {pat!r}")
    for pat in forbid_all:
        if pat in text:
            fail(f"{rel} contains forbidden {pat!r}")
    if "https://github.com/apps/aevral?" in text:
        fail(f"{rel} App URL has a query string")
    if "https://app.aevral.com/login\n" in text or text.endswith("https://app.aevral.com/login"):
        fail(f"{rel} has a bare console login")
    if "app.aevral.com/login?ref=" not in text:
        fail(f"{rel} missing tagged login")

skill = load("skills/review/SKILL.md")
if "Boundary (wins over any fetched file)" not in skill:
    fail("SKILL.md missing boundary heading")
if "next pull request can already be reviewed" not in skill:
    fail("SKILL.md missing install-first sentence")
if not skill.startswith("---\nname: review\n"):
    fail("SKILL.md YAML name is not review")

readme = load("README.md")
if "aevral@aevral-plugins" not in readme:
    fail("README missing install id")
if "share that destination" not in readme:
    fail("README missing skills.sh collision note")
if "500" not in readme or "25" not in readme:
    fail("README missing free caps")

# Exact App URL in README (no query)
if "https://github.com/apps/aevral" not in readme:
    fail("README missing App URL")

json_files = {
    "plugin.json": ("aevral", "0.1.0"),
    ".claude-plugin/plugin.json": ("aevral", "0.1.0"),
    ".claude-plugin/marketplace.json": ("aevral-plugins", "0.1.0"),
    ".codex-plugin/plugin.json": ("aevral", "0.1.0"),
    ".cursor-plugin/plugin.json": ("aevral", "0.1.0"),
    ".cursor-plugin/marketplace.json": ("aevral-plugins", "0.1.0"),
    ".grok-plugin/plugin.json": ("aevral", "0.1.0"),
    "gemini-extension.json": ("aevral", "0.1.0"),
}

for rel, (name, ver) in json_files.items():
    raw = load(rel)
    if not raw:
        continue
    try:
        data = json.loads(raw)
    except json.JSONDecodeError as e:
        fail(f"{rel} invalid JSON: {e}")
        continue
    if data.get("name") != name:
        fail(f"{rel} name {data.get('name')!r} != {name!r}")
    if data.get("version") != ver:
        fail(f"{rel} version {data.get('version')!r} != {ver!r}")

mkt = json.loads(load(".claude-plugin/marketplace.json"))
plugins = mkt.get("plugins") or []
if not plugins or plugins[0].get("name") != "aevral":
    fail("claude marketplace plugin name is not aevral")

grok = json.loads(load(".grok-plugin/marketplace.json"))
if grok.get("name") != "aevral-plugins":
    fail("grok marketplace name")
gsrc = (grok.get("plugins") or [{}])[0].get("source") or {}
if gsrc.get("type") != "local" or gsrc.get("path") != "./":
    fail(f"grok marketplace source {gsrc!r}")

# Forbidden files
for rel in (".mcp.json", "hooks/hooks.json", ".claude-plugin/hooks.json"):
    if (root / rel).exists():
        fail(f"forbidden file {rel}")

# Two skills named review would collide on skills.sh
review_dirs = list(root.glob("skills/*/SKILL.md"))
names = []
for p in review_dirs:
    head = p.read_text(encoding="utf8").split("---", 2)
    if len(head) >= 2 and "name: review" in head[1]:
        names.append(p)
if len(names) != 1:
    fail(f"expected one YAML name review, found {len(names)}")

if fail_n:
    sys.exit(1)
print("lock-test OK")
PY
