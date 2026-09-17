#!/usr/bin/env bash
# §28 of the project guard — **a role the runtime cannot see is a document, not a worker** — on a
# throwaway project in the state a live one was measured in: three role files in `_ops/roles/` and
# **no `.claude/` directory at all**, so every instruction, skill and bar those roles carried was
# read by nobody and the advisor did the work instead. That failure does not error; it just looks
# like a project where one agent does everything.
#
# **Four code mutants**: the agent wiring unchecked · the skills half unchecked · the runtime's
# name spelling compared literally (`web_engineer.md` must answer to `web-engineer.md`) · the
# other-runtime escape removed, which would refuse every project not run in Claude Code.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
said() { [ "$(printf '%s' "$OUT" | grep -cF -- "$1")" -gt 0 ]; }
run() { git add -A; OUT=$(bash _ops/scripts/preflight.sh 2>&1); RC=$?; }
commit() { git add -A; git commit -qm "$1" --no-verify; }

role() {   # $1 file stem · $2.. skill rows
  local f="_ops/roles/$1.md"; shift
  { printf '# A role\n\n**Type**: worker · **Grade**: mid\n\n## Skills attached\n\n'
    printf '| Skill | Why this role needs it |\n|---|---|\n'
    for s in "$@"; do printf '| %s | because |\n' "$s"; done
  } > "$f"
}
agent() {   # $1 name — the runtime file a role owes
  mkdir -p .claude/agents
  printf -- '---\nname: %s\ndescription: does the thing\n---\n\nThe instructions.\n' "$1" \
    > ".claude/agents/$1.md"
}

fixture() {
  rm -rf "$T/p"; mkdir -p "$T/p/_ops/roles" "$T/p/_ops/tasks" "$T/p/_ops/scripts" "$T/p/src"
  cd "$T/p" || exit 1
  git init -q . && git config user.email t@f.t && git config user.name T
  for f in ROADMAP TEAM TOOLING DECISIONS ARCHITECTURE; do printf '# %s\n' "$f" > "_ops/$f.md"; done
  printf '# Guide\n\n**Operated by** Opsinist **0.2.19**\n' > CLAUDE.md
  printf '# Project configuration\n\nschema_version: 1\n' > _ops/config.md
  printf 'one\n' > src/app.js
  cp "${MUT:-$HERE/../templates/company-preflight.sh}" _ops/scripts/preflight.sh
  cp "$HERE/transition.py" "$HERE/new-id.py" _ops/scripts/ 2>/dev/null || true
  commit "chore: opsinist init"
}

# ── the measured case: a role with nothing in .claude/agents/ ──────────────────────────────────
fixture
role web_engineer
run
[ "$RC" = 1 ] && said 'the runtime cannot see' && said '.claude/agents/web-engineer.md' && ok \
  || bad "a role with no runtime wiring was accepted: $OUT"

# ── the wiring is one file, and the slug is compared, not the spelling ─────────────────────────
agent web-engineer
run; [ "$RC" = 0 ] && ok || bad "a role wired as `web-engineer.md` was still refused: $OUT"
commit "a wired role"

# ── an attached pool skill the runtime never loads ─────────────────────────────────────────────
fixture
mkdir -p _ops/skills/house-style && printf '# house-style\n' > _ops/skills/house-style/SKILL.md
agent writer
role writer '[house-style](../skills/house-style/SKILL.md)'
run
[ "$RC" = 1 ] && said 'sits in the project' && said '.claude/skills/house-style/' && ok \
  || bad "a pool skill missing from the runtime directory was accepted: $OUT"

mkdir -p .claude/skills/house-style && printf -- '---\nname: house-style\ndescription: the voice\n---\n' \
  > .claude/skills/house-style/SKILL.md
run; [ "$RC" = 0 ] && ok || bad "the wired skill was still refused: $OUT"

# ── a skill the runtime provides is not the pool's to wire ─────────────────────────────────────
fixture
agent web_eng
printf '# Tooling\n\n| Tool | Why | Replaces |\n|---|---|---|\n| frontend-design | a runtime skill | we had none |\n' \
  > _ops/TOOLING.md
role web_eng frontend-design
run; [ "$RC" = 0 ] && ok \
  || bad "a register-declared runtime skill was treated as one the project must wire: $OUT"

# ── a project run in another runtime says so, once, and this stands down ───────────────────────
fixture
printf '# Project configuration\n\nschema_version: 1\n\nAgent wiring lives in `.codex/agents/` here.\n' \
  > _ops/config.md
role web_engineer
run; [ "$RC" = 0 ] && ok || bad "a project naming another runtime's wiring path was still refused: $OUT"

# ── a README and an archived role are not workers ──────────────────────────────────────────────
# The same two false positives §7 was taught by an adversarial lens in 2026-08, inherited the
# moment this section read the same directory: a file explaining the form is not a role, and a
# parked one owes the runtime nothing precisely because nothing should be able to dispatch it.
fixture
printf '# How to write a role\n\nExample: **Type**: worker · **Grade**: mid\n' > _ops/roles/README.md
mkdir -p _ops/roles/archive
printf '# Old One\n\n**Type**: worker · **Grade**: mid\n' > _ops/roles/archive/old_one.md
run; [ "$RC" = 0 ] && ok \
  || bad "a README or an archived role was asked for runtime wiring: $OUT"

# ── history is not retro-wired ─────────────────────────────────────────────────────────────────
fixture
role old_role
commit "legacy role"                 # written before the guard was wired
printf 'two\n' > src/app.js
run; [ "$RC" = 0 ] && ok || bad "a role this commit did not touch was judged: $OUT"

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
mutant "the agent wiring unchecked" \
  '    if not elsewhere and norm(role) not in {norm(a) for a in agents}:' '    if False:' \
  && { fixture; role web_engineer; run
       [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: wiring unchecked"; }

mutant "the skills half unchecked" \
  '        if low in pool and low not in wired_skills and not elsewhere:' '        if False:' \
  && { fixture; mkdir -p _ops/skills/house-style
       printf '# house-style\n' > _ops/skills/house-style/SKILL.md
       agent writer; role writer '[house-style](../skills/house-style/SKILL.md)'; run
       [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: the skills half unchecked"; }

mutant "the runtime name compared literally" \
  'if not elsewhere and norm(role) not in {norm(a) for a in agents}:' \
  'if not elsewhere and role not in agents:' \
  && { fixture; role web_engineer; agent web-engineer; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: the slug compared literally"; }

mutant "the other-runtime escape removed" \
  'elsewhere = re.search(r"agent[s]?\s+(?:wiring|live|directory|path)|\.codex/|\.gemini/|agents_dir",
                      cfg, re.I) is not None' \
  'elsewhere = False' \
  && { fixture
       printf '# Project configuration\n\nschema_version: 1\n\nAgent wiring lives in `.codex/agents/` here.\n' \
         > _ops/config.md
       role web_engineer; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: the escape removed"; }
MUT=""

echo "role-wiring: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
