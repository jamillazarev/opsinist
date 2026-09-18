#!/usr/bin/env bash
# §1 of the project guard, its register clause — **a project with dependencies and no register** — on a throwaway
# project in the state a live one was measured in: an auth service, a database service, a model key
# and a hosting provider all in use, and **no `_ops/TOOLING.md` at all**. So nothing recorded what
# any of them replaced, what licence or plan each was on, where its secret lived, or **what the
# service itself ships** — an MCP server, a CLI, an SDK, an agent skill. The owner found it from the
# other end, on the same project: the advisor chose a service and never asked what it offered.
#
# **One message per absent file, never two** — the generic *deferred on purpose* line and this one
# are the same warning at two levels of evidence, and two findings for one absence is the trap
# `facts.md` 261 measures. **Two code mutants**: the manifest scan removed (every project gets the
# specific text, including one with no dependencies at all) and the DECISIONS escape removed (a
# project that said so out loud, warned anyway). The check WARNS — a missing register is not a
# reason to refuse somebody's commit.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
said() { [ "$(printf '%s' "$OUT" | grep -cF -- "$1")" -gt 0 ]; }
run() { git add -A; OUT=$(bash _ops/scripts/preflight.sh 2>&1); RC=$?; }
commit() { git add -A; git commit -qm "$1" --no-verify; }

fixture() {
  rm -rf "$T/p"; mkdir -p "$T/p/_ops/tasks" "$T/p/_ops/scripts" "$T/p/src"
  cd "$T/p" || exit 1
  git init -q . && git config user.email t@f.t && git config user.name T
  for f in ROADMAP TEAM ARCHITECTURE; do printf '# %s\n' "$f" > "_ops/$f.md"; done
  printf '# Decisions\n\n' > _ops/DECISIONS.md
  printf '# Guide\n\n**Operated by** Opsinist **0.2.19**\n' > CLAUDE.md
  printf 'one\n' > src/app.js
  cp "${MUT:-$HERE/../templates/company-preflight.sh}" _ops/scripts/preflight.sh
  cp "$HERE/transition.py" "$HERE/new-id.py" _ops/scripts/ 2>/dev/null || true
  commit "chore: opsinist init"
}

# ── the measured case: dependencies declared, no register ──────────────────────────────────────
fixture
printf '{"dependencies":{"@some/auth":"^1.0.0"}}\n' > package.json
printf -- '- 2026-09-18 — @some/auth for sign-in; replaces the hand-rolled session code; rejected: writing our own\n' >> _ops/DECISIONS.md
run
[ "$RC" = 0 ] && said 'is missing and this project declares dependencies' \
  && said 'what the service itself ships' && ok \
  || bad "a project with a manifest and no register said nothing: $OUT"

# ── and the register silences it ───────────────────────────────────────────────────────────────
printf '# Tooling\n\n| Tool | What it'"'"'s for | Replaces |\n|---|---|---|\n' > _ops/TOOLING.md
run; [ "$RC" = 0 ] && ! said 'what the service itself ships' && ok \
  || bad "a project WITH a register was still warned: $OUT"

# ── a project that genuinely depends on nothing outside itself says so, once ────────────────────
fixture
printf '{"dependencies":{}}\n' > package.json
printf -- '- 2026-09-18 — no external services; nothing to register\n' >> _ops/DECISIONS.md
run; [ "$RC" = 0 ] && ! said 'what the service itself ships' && ok \
  || bad "a project that declared it depends on nothing was warned anyway: $OUT"

# ── no manifest at all is not a finding ────────────────────────────────────────────────────────
# A project of prose — a book, a research repository — declares no dependencies and owes no
# register. The check reads what the tree actually carries rather than assuming every project ships
# software, which is the same care `§4a-bis` takes about a map.
fixture
run; [ "$RC" = 0 ] && ! said 'what the service itself ships' && ok \
  || bad "a project with no dependency manifest was asked for a register: $OUT"

# ── a manifest inside _ops/ is the machinery's, not the product's ──────────────────────────────
fixture
mkdir -p _ops/scripts && printf '{"name":"ops-helper"}\n' > _ops/package.json
run; [ "$RC" = 0 ] && ! said 'what the service itself ships' && ok \
  || bad "a manifest under _ops/ was counted as the product's dependencies: $OUT"

# ── the mutants ────────────────────────────────────────────────────────────────────────────────
mutant() {   # $1 what it breaks · $2 from · $3 to
  cp "$HERE/../templates/company-preflight.sh" "$T/mut.sh"
  M_FROM="$2" M_TO="$3" python3 - "$T/mut.sh" <<'PY' || { bad "MUTATION DID NOT APPLY: $1"; return 1; }
import os, sys
p = sys.argv[1]; s = open(p).read(); a, b = os.environ["M_FROM"], os.environ["M_TO"]
assert s.count(a) == 1, "found %d times" % s.count(a)
open(p, "w").write(s.replace(a, b))
PY
  MUT="$T/mut.sh"
}
mutant "the manifest scan removed — every project warned" \
  'if [ "$f" = _ops/TOOLING.md ] && _deps_declared' \
  'if [ "$f" = _ops/TOOLING.md ] && true' \
  && { fixture; run
       said 'what the service itself ships' && ok \
         || bad "the suite did not catch the mutant: a project with no dependencies was warned"; }

mutant "the DECISIONS escape removed" \
  "&& ! grep -qi 'no external\\|TOOLING\\.md' _ops/DECISIONS.md 2>/dev/null; then" \
  "; then" \
  && { fixture
       printf '{"dependencies":{}}\n' > package.json
       printf -- '- 2026-09-18 — no external services; nothing to register\n' >> _ops/DECISIONS.md
       run; said 'what the service itself ships' && ok \
         || bad "the suite did not catch the mutant: the escape removed"; }
MUT=""

echo "register-exists: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
