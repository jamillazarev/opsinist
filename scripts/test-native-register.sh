#!/usr/bin/env bash
# §20 and §21 of the project guard — the native files and the register held to each other —
# shown refusing each mutant and passing its honest twin, in a throwaway project.
#
# **The guard runs on whatever `python3` the machine has, so this suite runs it twice**: once on
# the one on PATH, and once with PATH pointed at the system interpreter (`/usr/bin/python3`, 3.9
# on a Mac with no Homebrew). §21 parses `mise.toml` by hand precisely so it never imports
# `tomllib`, which is 3.11+; the second pass is the only thing that can show that claim holds.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cd "$T"
git init -q . && git config user.email t@f.t && git config user.name T
mkdir -p _ops/tasks _ops/scripts
cp "$HERE/../templates/company-preflight.sh" _ops/scripts/preflight.sh
cp "$HERE/transition.py" "$HERE/new-id.py" _ops/scripts/ 2>/dev/null || true
printf '# Roadmap\n' > _ops/ROADMAP.md; printf '# Team\n' > _ops/TEAM.md
printf '# Decisions\n' > _ops/DECISIONS.md; printf '# Tooling\n' > _ops/TOOLING.md
printf '# T-1 — the thing\n\n**Status**: started\n**Assignee**: worker-a\n\n## History\n' > _ops/tasks/T-1.md
git add -A && git commit -qm fixture

pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }

# The register: one table whose *Wired how* column is found by its header, as the guard finds it.
reg() {
  { printf '# Tooling\n\n| Tool | What it'"'"'s for | Replaces | Licence | Access | Wired how | Checked |\n'
    printf '|---|---|---|---|---|---|---|\n'
    for r in "$@"; do printf '%s\n' "$r"; done; } > _ops/TOOLING.md
}
row() { printf '| %s | a reason | we had none | MIT · read 2026-09-11 | none | %s | 2026-09-11 |' "$1" "$2"; }

# run the guard on what is staged; OUT holds what it printed, RC its exit code
run() { git add -A; OUT=$(bash _ops/scripts/preflight.sh 2>&1); RC=$?; }
said() { [ "$(printf '%s' "$OUT" | grep -c -- "$1")" -gt 0 ]; }   # grep -c: no pipe can eat it

suite() {
  # ── §20 · .mcp.json ────────────────────────────────────────────────────────────────────────
  # the twin: a server reading its secret by NAME, with a row saying why
  printf '{ "mcpServers": { "sentry": { "command": "npx", "args": ["-y", "sentry-mcp"],
    "env": { "SENTRY_TOKEN": "${SENTRY_TOKEN}", "SENTRY_MODE": "readonly" } } } }\n' > .mcp.json
  reg "$(row sentry '`.mcp.json`')"
  run; [ "$RC" = 0 ] && ok || bad "[$1] the honest twin was refused: $OUT"

  # a secret-shaped key holding a literal token
  sed -i '' 's/"\${SENTRY_TOKEN}"/"sntrys_abcdefgh12345678"/' .mcp.json
  [ "$(grep -c sntrys_ .mcp.json)" -gt 0 ] || bad "[$1] MUTATION DID NOT APPLY (literal token)"
  run; [ "$RC" = 1 ] && said 'SENTRY_TOKEN' && ok || bad "[$1] a literal token in .mcp.json passed"

  # the measured case: a placeholder that authenticates as nothing, and only warns at launch
  sed -i '' 's/"sntrys_abcdefgh12345678"/"YOUR_API_KEY"/' .mcp.json
  run; [ "$RC" = 1 ] && said 'placeholder' && ok || bad "[$1] a YOUR_API_KEY placeholder passed"

  # a non-secret key may hold a literal — the rule is about secrets, not about every value
  sed -i '' 's/"YOUR_API_KEY"/"${SENTRY_TOKEN}"/' .mcp.json
  run; [ "$RC" = 0 ] && ok || bad "[$1] a literal in a non-secret key (SENTRY_MODE) was refused"

  # an HTTP server's Authorization header is a secret too
  printf '{ "mcpServers": { "sentry": { "type": "http", "url": "https://x.example/mcp",
    "headers": { "Authorization": "Bearer abc123" } } } }\n' > .mcp.json
  run; [ "$RC" = 1 ] && said 'Authorization' && ok || bad "[$1] a literal Authorization header passed"

  # the documentation's own header form — a scheme word and a reference — is what everyone copies
  printf '{ "mcpServers": { "sentry": { "type": "http", "url": "https://x.example/mcp",
    "headers": { "Authorization": "Bearer ${SENTRY_TOKEN}" } } } }\n' > .mcp.json
  run; [ "$RC" = 0 ] && ok || bad "[$1] the documented header form, Bearer and a reference, was refused: $OUT"
  # a default IS a value, written in the file
  printf '{ "mcpServers": { "sentry": { "command": "npx", "env": { "SENTRY_TOKEN": "${SENTRY_TOKEN:-sntrys_abcdefgh}" } } } }\n' > .mcp.json
  run; [ "$RC" = 1 ] && said 'SENTRY_TOKEN' && ok || bad "[$1] a secret written as a :-default passed"
  # an empty default holds nothing, and a name that merely contains `auth` names no secret
  printf '{ "mcpServers": { "sentry": { "command": "npx", "env": { "SENTRY_TOKEN": "${SENTRY_TOKEN:-}", "AUTHOR_NAME": "Jamil" } } } }\n' > .mcp.json
  run; [ "$RC" = 0 ] && ok || bad "[$1] an empty default, or a key merely containing auth, was refused: $OUT"

  # a server with no row, and a row with no server — both directions
  printf '{ "mcpServers": { "sentry": { "command": "npx" }, "linear": { "command": "npx" } } }\n' > .mcp.json
  run; [ "$RC" = 1 ] && said 'server `linear`' && ok || bad "[$1] a server with no register row passed"
  printf '{ "mcpServers": { "sentry": { "command": "npx" } } }\n' > .mcp.json
  reg "$(row sentry '`.mcp.json`')" "$(row github '`.mcp.json`')"
  run; [ "$RC" = 1 ] && said 'row `github`' && ok || bad "[$1] a register row naming a missing server passed"

  # a file the runtime cannot read
  printf '{ "mcpServers": { "sentry": ' > .mcp.json
  reg "$(row sentry '`.mcp.json`')"
  run; [ "$RC" = 1 ] && said 'does not parse' && ok || bad "[$1] a broken .mcp.json passed"
  git rm -q --cached .mcp.json; rm -f .mcp.json; reg; git add -A; git commit -qm clean-mcp >/dev/null 2>&1 || true

  # ── §21 · mise.toml ────────────────────────────────────────────────────────────────────────
  # the twin: a runtime, and one system package spelled per OS — all three lines meet ONE row
  printf '[tools]\npython = "3.12"\n"github:BeaconBay/ck" = "latest"\n\n[tools.node]\nversion = "22"\n\n'  > mise.toml
  printf '[bootstrap.packages]\n"brew:ffmpeg" = "latest"\n"apt:ffmpeg" = { os = "linux" }\n' >> mise.toml
  printf '"winget:Gyan.FFmpeg" = { os = "windows" }  # the Windows id is not the name\n' >> mise.toml
  reg "$(row python '`mise.toml`')" "$(row node '`mise.toml`')" "$(row ck '`mise.toml`')" "$(row ffmpeg '`mise.toml`')"
  run; [ "$RC" = 0 ] && ok || bad "[$1] the honest mise twin was refused: $OUT"

  # a tool with no row
  printf '"npm:@anthropic-ai/claude-code" = "latest"\n' >> mise.toml
  run; [ "$RC" = 1 ] && said 'claude-code' && ok || bad "[$1] a mise tool with no register row passed"

  # a row naming nothing mise installs
  sed -i '' '/claude-code/d' mise.toml
  reg "$(row python '`mise.toml`')" "$(row node '`mise.toml`')" "$(row ck '`mise.toml`')" \
      "$(row ffmpeg '`mise.toml`')" "$(row imagemagick '`mise.toml`')"
  run; [ "$RC" = 1 ] && said 'row `imagemagick`' && ok || bad "[$1] a register row naming nothing in mise.toml passed"

  # names match EXACTLY, never as a substring: `ck` must not vouch for `brew:package-stack`
  reg "$(row python '`mise.toml`')" "$(row node '`mise.toml`')" "$(row ck '`mise.toml`')" "$(row ffmpeg '`mise.toml`')"
  printf '"brew:package-stack" = "latest"\n' >> mise.toml
  run; [ "$RC" = 1 ] && said 'package-stack' && ok || bad "[$1] a row \`ck\` vouched for \`package-stack\` by substring"
  sed -i '' '/package-stack/d' mise.toml

  # a `#` comment and a subtable are not entries — the twin must still be clean after the edits
  run; [ "$RC" = 0 ] && ok || bad "[$1] the restored mise twin was refused: $OUT"

  # a key is a path: the same entries in dotted keys, and a quoted word in a comment is not an entry
  reg "$(row python '`mise.toml`')" "$(row ck '`mise.toml`')" "$(row ffmpeg '`mise.toml`')"
  printf 'tools.python = "3.12"\ntools."github:BeaconBay/ck" = "latest"   # "quoted" words in a comment\n' > mise.toml
  printf 'bootstrap.packages."brew:ffmpeg" = "latest"\n' >> mise.toml
  run; [ "$RC" = 0 ] && ok || bad "[$1] a mise.toml in dotted keys, each entry with its row, was refused: $OUT"
  printf 'tools.jq = "1.7"\n' >> mise.toml
  run; [ "$RC" = 1 ] && said '`jq`' && ok || bad "[$1] a tool declared as a dotted key, with no row, passed"
  git rm -q --cached mise.toml; rm -f mise.toml; reg; git add -A; git commit -qm clean-mise >/dev/null 2>&1 || true
}

suite "python3 on PATH"

# the same suite on the system interpreter, if this machine has one that is not the PATH one
SYS=/usr/bin/python3
if [ -x "$SYS" ] && [ "$("$SYS" -c 'import sys; print(sys.version_info >= (3, 11))')" = "False" ]; then
  mkdir -p "$T/.shim" && ln -sf "$SYS" "$T/.shim/python3"
  PATH="$T/.shim:$PATH" python3 -c 'import sys; assert sys.version_info < (3, 11)' \
    || bad "the shim did not put the system python first — the second pass would prove nothing"
  PATH="$T/.shim:$PATH" suite "system $("$SYS" --version 2>&1)"
fi

echo "native-register: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
