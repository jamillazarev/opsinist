#!/usr/bin/env bash
# §26 of the project guard — a skill attached to a role resolves to something — on a throwaway
# project in the state a live one was measured in: three roles naming five skills between them,
# `_ops/skills/` absent, `.claude/` empty, and every one of those skills installed in the owner's
# own runtime where the work happened to run fine.
#
# **Four code mutants**: the pool unread (a skill the project holds refused), the register unread
# (a declared runtime skill refused), the header row judged as a skill (`| Skill |` refused in
# every role), and the check widened past the rows this commit writes (a project's history refused
# for roles nobody touched).
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

fixture() {
  rm -rf "$T/p"; mkdir -p "$T/p/_ops/roles" "$T/p/_ops/tasks" "$T/p/_ops/scripts" "$T/p/src"
  cd "$T/p" || exit 1
  git init -q . && git config user.email t@f.t && git config user.name T
  for f in ROADMAP TEAM TOOLING DECISIONS ARCHITECTURE; do printf '# %s\n' "$f" > "_ops/$f.md"; done
  printf '# Guide\n\n**Operated by** Opsinist **0.2.19**\n' > CLAUDE.md
  printf 'one\n' > src/app.js
  cp "${MUT:-$HERE/../templates/company-preflight.sh}" _ops/scripts/preflight.sh
  cp "$HERE/transition.py" "$HERE/new-id.py" _ops/scripts/ 2>/dev/null || true
  commit "chore: opsinist init"
}

# ── the measured case: a name that is in no file of this project ───────────────────────────────
fixture
role web_engineer frontend-design
run
[ "$RC" = 1 ] && said 'frontend-design' && said 'loads nothing' && said '_ops/TOOLING.md' && ok \
  || bad "a skill attached from nowhere passed, or said nothing useful: $OUT"

# ── the project's own pool answers it ──────────────────────────────────────────────────────────
mkdir -p _ops/skills/frontend-design && printf '# frontend-design\n' > _ops/skills/frontend-design/SKILL.md
run; [ "$RC" = 0 ] && ok || bad "a skill sitting in the project's own pool was refused: $OUT"

# ── so does a register row saying the runtime provides it ──────────────────────────────────────
fixture
role web_engineer vercel-react-best-practices
printf '# Tooling\n\n| Tool | Why | Replaces | Ceiling |\n|---|---|---|---|\n| vercel-react-best-practices | a runtime skill, installed in Claude Code | we had none | — |\n' \
  > _ops/TOOLING.md
run; [ "$RC" = 0 ] && ok || bad "a skill declared in the register as the runtime's was refused: $OUT"

# ── a role with no skills at all, and a table that is only its header ──────────────────────────
fixture
role architect
run; [ "$RC" = 0 ] && ok || bad "a role attaching nothing was judged: $OUT"

# ── the template's own unfilled row is a hole, not a claim ─────────────────────────────────────
fixture
role designer '{{name}}'
run; [ "$RC" = 0 ] && ok || bad "an unfilled template placeholder was read as a skill name: $OUT"

# ── a linked name is the same name ─────────────────────────────────────────────────────────────
fixture
mkdir -p _ops/skills/house-style && printf '# house-style\n' > _ops/skills/house-style/SKILL.md
role writer '[house-style](../skills/house-style/SKILL.md)'
run; [ "$RC" = 0 ] && ok || bad "a skill named as a link was not resolved: $OUT"

# ── history is not retro-fixed ─────────────────────────────────────────────────────────────────
# **The commit has to write a role**, or the section's own bash gate never opens and this asserts
# nothing — the same trap §23's suite hit: a case that passes because no check ran is not a pass.
fixture
role old_role legacy-skill
commit "legacy"                      # written before the guard was wired
mkdir -p _ops/skills/house-style && printf '# house-style\n' > _ops/skills/house-style/SKILL.md
role new_role house-style
run; [ "$RC" = 0 ] && ok || bad "a role this commit did not touch was judged beside one it did: $OUT"

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
mutant "the project's own pool unread" \
  '    for p in ("_ops/skills/%s" % name, "_ops/skills/%s.md" % name, "_ops/skills/%s/SKILL.md" % name,' \
  '    for p in (' \
  && { fixture; mkdir -p _ops/skills/frontend-design
       printf '# frontend-design\n' > _ops/skills/frontend-design/SKILL.md
       role web_engineer frontend-design; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: the pool unread"; }

mutant "the register unread" 'for f in ("_ops/TOOLING.md", "_ops/config.md"):' 'for f in ():' \
  && { fixture; role web_engineer vercel-react-best-practices
       printf '# Tooling\n\n| Tool | Why | Replaces |\n|---|---|---|\n| vercel-react-best-practices | a runtime skill | we had none |\n' > _ops/TOOLING.md
       run; [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: the register unread"; }

mutant "the header row judged as a skill" \
  'if not cell or cell.lower() in ("skill", "name") or "{{" in cell:' \
  'if not cell:' \
  && { fixture; mkdir -p _ops/skills/house-style
       printf '# house-style\n' > _ops/skills/house-style/SKILL.md
       role writer house-style; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: the header row judged"; }

# the anchor spans two physical lines on purpose: `--diff-filter=AM` alone appears in §25 too,
# and a mutation that lands in the wrong section is a test of something else
mutant "every role judged, not the ones this commit writes" \
  'git("diff", "--cached", "--name-only", "--diff-filter=AM", "-z") or "").split("\0")
             if p.startswith("_ops/roles/")' \
  'git("ls-files", "-z", "_ops/roles") or "").split("\0")
             if p.startswith("_ops/roles/")' \
  && { fixture; role old_role legacy-skill; commit legacy
       mkdir -p _ops/skills/house-style && printf '# house-style\n' > _ops/skills/house-style/SKILL.md
       role new_role house-style; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: history retro-judged"; }
MUT=""

echo "skills-attached: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
