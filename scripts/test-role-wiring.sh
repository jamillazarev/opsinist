#!/usr/bin/env bash
# §28 of the project guard — **a role the runtime cannot see is a document, not a worker** — on a
# throwaway project in the state a live one was measured in: three role files in `_ops/roles/` and
# **no `.claude/` directory at all**, so every instruction, skill and bar those roles carried was
# read by nobody and the advisor did the work instead. That failure does not error; it just looks
# like a project where one agent does everything.
#
# **Four code mutants**: the agent wiring unchecked · the runtime's name spelling compared
# literally (`web_engineer.md` must answer to `web-engineer.md`) · the other-runtime escape removed,
# which would refuse every project not run in Claude Code · and the escape taken from a MENTION
# rather than a declaration, which is the hole an adversarial lens found in its second shape.
# **The skills half is §26's**, tested in `test-skills-attached.sh` — one reader per table, one
# suite per reader; the escape itself is one reader (`_wiring_elsewhere`) that both stand down on.
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

# ── the skills half moved to §26, which owns the table ────────────────────────────────────────
# A deletion lens found §26 and §28 reading one table in one file, and §26 already had the row
# open — so the pool-skill-not-wired case lives in `test-skills-attached.sh` now.

# ── a project run in another runtime DECLARES it, once, and this stands down ───────────────────
fixture
printf '# Project configuration\n\n| Setting | Value | Notes |\n|---|---|---|\n| `runtime_wiring` | `.codex/agents/` | Codex here |\n' \
  > _ops/config.md
role web_engineer
run; [ "$RC" = 0 ] && ok || bad "a project declaring another runtime's wiring path was still refused: $OUT"

# ── and a MENTION is not a declaration ─────────────────────────────────────────────────────────
# An adversarial lens found the escape firing on any prose naming a non-`.claude` agents path — so
# a sentence about a *rejected* alternative silenced both wiring checks on a correctly wired
# project (2026-09-18). An escape any footnote can trip is not an escape, and this is the second
# time this one was widened too far: the answer was to make it a declared setting.
fixture
printf '# Project configuration\n\nschema_version: 1\n\nWe evaluated `.gemini/agents/` and stayed on `.claude/agents/`.\n' \
  > _ops/config.md
role web_engineer
run; [ "$RC" = 1 ] && said 'the runtime cannot see' && ok \
  || bad "prose mentioning another runtime's path silenced the check: $OUT"

# ── an unfilled placeholder is not a declaration either ────────────────────────────────────────
# `CONFIG-template.md` ships the row with `{{absent}}` in its value cell, and a project that has
# not filled it in must be judged, not excused. The notes column names `.claude/` on purpose.
fixture
printf '# Project configuration\n\n| Setting | Value | Notes |\n|---|---|---|\n| `runtime_wiring` | {{absent}} | absent means `.claude/`, e.g. `_ops/agents/` would not |\n' \
  > _ops/config.md
role web_engineer
run; [ "$RC" = 1 ] && said 'the runtime cannot see' && ok \
  || bad "an unfilled runtime_wiring row stood the check down: $OUT"

# ── wiring that is present but ignored by git ──────────────────────────────────────────────────
# An adversarial lens found `--exclude-standard` dropping an ignored `.claude/`, so a correctly
# wired role read as unwired and the refusal named a file sitting right there. Present-and-ignored
# is a different finding from absent, and it is a warning: the role loads here and arrives with no
# clone.
fixture
printf '.claude/\n' > .gitignore
agent web_engineer
role web_engineer
run
[ "$RC" = 0 ] && said 'on disk and NOT in git' && ok \
  || bad "an ignored-but-present wiring file was refused instead of warned about: $OUT"

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
  '    elif not wiring_elsewhere and norm(role) not in {norm(a) for a in agents}:' '    elif False:' \
  && { fixture; role web_engineer; run
       [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: wiring unchecked"; }

mutant "the runtime name compared literally" \
  'elif not wiring_elsewhere and norm(role) not in {norm(a) for a in agents}:' \
  'elif not wiring_elsewhere and role not in agents:' \
  && { fixture; role web_engineer; agent web-engineer; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: the slug compared literally"; }

# The escape is one reader now — `_wiring_elsewhere` — so both mutants land in it, and both
# sections stand or fall with it. That is the point of the shared helper: the alternative was two
# copies of a regex, which is how this escape came to have two different holes in two days.
mutant "the other-runtime escape removed" \
  '        print("1")' '        pass' \
  && { fixture
       printf '# Project configuration\n\n| Setting | Value | Notes |\n|---|---|---|\n| `runtime_wiring` | `.codex/agents/` | Codex here |\n' \
         > _ops/config.md
       role web_engineer; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: the escape removed"; }

# the hole the lens found, as a mutant: stop requiring the declared key and any line's first path
# becomes the answer — which is what a prose mention silencing the check IS
mutant "the escape taken from a mention rather than a declaration" \
  '    k = line.find(KEY)' '    k = 0' \
  && { fixture
       printf '# Project configuration\n\nschema_version: 1\n\nWe evaluated `.gemini/agents/` and stayed on `.claude/agents/`.\n' \
         > _ops/config.md
       role web_engineer; run
       [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: a mention read as a declaration"; }
MUT=""

echo "role-wiring: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
