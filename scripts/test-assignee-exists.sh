#!/usr/bin/env bash
# §25 of the project guard — a task is assigned to somebody this project has — on a throwaway
# project in the state a live one was measured in: two tasks addressed to **Frontend Engineer**,
# a role in neither `_ops/roles/` nor `_ops/TEAM.md`, sitting at `review` with nobody on them.
#
# The rule underneath is `hiring.md`'s: an uncovered craft is a hire, not the nearest-sounding
# name — and a name that resolves to nothing is the only mechanical trace that it was skipped.
#
# **Five code mutants**: `_ops/roles/` unread (the roster reduced to the team file), the name
# compared literally (`web_engineer.md` no longer answers to `Web Engineer`), every staged task
# judged rather than the assignment this commit writes (a project's history refused for a field
# nobody touched), the alphabet narrowed to ASCII (a roster written in the project's own language
# normalises to nothing, and then every name matches every other), and an empty roster read as a
# roster naming nobody — which refuses day one, when the task is written before anyone is hired.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
said() { [ "$(printf '%s' "$OUT" | grep -cF -- "$1")" -gt 0 ]; }   # -F: `**` is not a repetition here
run() { git add -A; OUT=$(bash _ops/scripts/preflight.sh 2>&1); RC=$?; }
commit() { git add -A; git commit -qm "$1" --no-verify; }

task() {   # $1 id · $2 assignee — the shape §23 asks for, so this suite measures §25 and nothing else
  { printf '# %s — a thing\n\n**Type**: build · **Status**: started\n**Assignee**: %s\n\n' "$1" "$2"
    printf '## Ready when\n\nThe thing is not there.\n\n## Done when\n\n- [ ] it is\n\n## History\n\n- 2026-09-17 — started\n'
  } > "_ops/tasks/$1-thing.md"
}

fixture() {   # no argument: a staffed project · `bare`: day one, before anyone is hired
  rm -rf "$T/p"; mkdir -p "$T/p/_ops/tasks" "$T/p/_ops/runs" "$T/p/_ops/roles" "$T/p/_ops/scripts" "$T/p/src"
  cd "$T/p" || exit 1
  git init -q . && git config user.email t@f.t && git config user.name T
  for f in ROADMAP TOOLING DECISIONS ARCHITECTURE; do printf '# %s\n' "$f" > "_ops/$f.md"; done
  printf '# Guide\n\n**Operated by** Opsinist **0.2.19**\n' > CLAUDE.md
  if [ "${1:-}" = bare ]; then
    printf '# Team — who owns what\n\nNobody yet.\n' > _ops/TEAM.md
    printf 'one\n' > src/app.js
    cp "${MUT:-$HERE/../templates/company-preflight.sh}" _ops/scripts/preflight.sh
    cp "$HERE/transition.py" "$HERE/new-id.py" _ops/scripts/ 2>/dev/null || true
    commit "chore: opsinist init"
    return
  fi
  { printf '# Team — who owns what\n\n## People\n\n'
    printf '| Person | Role | Expert in | Owns |\n|---|---|---|---|\n'
    printf '| Владелец | owner | design, frontend | the product |\n\n'
    printf '## Agents\n\n| Agent | Craft | Team | Grade | Model tier | Owns |\n|---|---|---|---|---|---|\n'
    printf '| Opsinist | advisory | — | senior | top | routing |\n'
    printf '| Web Engineer | engineering | Frontend | mid | top | the web client |\n'
  } > _ops/TEAM.md
  printf '# Web Engineer\n\n**Type**: worker · **Grade**: mid\n' > _ops/roles/web_engineer.md
  printf '# Architect\n\n**Type**: expert · **Grade**: senior\n' > _ops/roles/architect.md
  printf 'one\n' > src/app.js
  cp "${MUT:-$HERE/../templates/company-preflight.sh}" _ops/scripts/preflight.sh
  cp "$HERE/transition.py" "$HERE/new-id.py" _ops/scripts/ 2>/dev/null || true
  commit "chore: opsinist init"
}

# ── a role file answers to the name the roster writes, however it is spelled ───────────────────
fixture
task T-AAAAAA "[Web Engineer](../roles/web_engineer.md)"   # the file is `web_engineer.md`
run; [ "$RC" = 0 ] && ok || bad "a task assigned to an existing role was refused: $OUT"

task T-AAAAAB "[architect](../roles/architect.md)"          # a role file TEAM.md never mentions
run; [ "$RC" = 0 ] && ok || bad "a task assigned to a role file absent from TEAM.md was refused: $OUT"

task T-AAAAAC "Владелец"              # a person on the roster with no file of their own
run; [ "$RC" = 0 ] && ok || bad "a task assigned to a person on the roster was refused: $OUT"

task T-AAAAAD "unassigned"            # nobody yet, said out loud — §23 is what asks for a value
run; [ "$RC" = 0 ] && ok || bad "a task that says nobody is decided yet was refused: $OUT"
commit "four tasks"

# ── the measured case: a plausible name that exists nowhere ────────────────────────────────────
task T-AAAAAE "Frontend Engineer"
run
[ "$RC" = 1 ] && said 'has no such role, person or team' && said 'hire it' && said '`Web Engineer`' && ok \
  || bad "a task assigned to a role that exists nowhere passed, or said nothing useful: $OUT"
rm -f _ops/tasks/T-AAAAAE-thing.md

# ── hiring in the same commit is how it is meant to be fixed ───────────────────────────────────
task T-AAAAAF "[Designer](../roles/designer.md)"
printf '# Designer\n\n**Type**: worker · **Grade**: mid\n' > _ops/roles/designer.md
# hiring writes two files: the role, and the wiring the runtime reads (§28)
mkdir -p .claude/agents
printf -- '---\nname: designer\ndescription: draws the screens\n---\n' > .claude/agents/designer.md
run; [ "$RC" = 0 ] && ok || bad "a task assigned to a role hired in the same commit was refused: $OUT"
commit "hire a designer"

# ── history is not retro-fixed, and a reassignment is ──────────────────────────────────────────
fixture
task T-OLD111 "Frontend Engineer"     # written before the guard was wired
commit "legacy"
printf '\nOne more line.\n' >> _ops/tasks/T-OLD111-thing.md
run; [ "$RC" = 0 ] && ok || bad "a task whose assignment this commit did not touch was judged: $OUT"

python3 - <<'PY'
import re
p = "_ops/tasks/T-OLD111-thing.md"
s = open(p, encoding="utf-8").read()
open(p, "w", encoding="utf-8").write(s.replace("Frontend Engineer", "Mobile Engineer"))
PY
run; [ "$RC" = 1 ] && said 'Mobile Engineer' && ok \
  || bad "a reassignment to a role that exists nowhere was not judged: $OUT"

# the roster is read in the project's own alphabet, so a name in it is compared, not erased
fixture
task T-AAAAAG "Дизайнер"              # the roster has Владелец, and no designer
run; [ "$RC" = 1 ] && said 'Дизайнер' && ok \
  || bad "an unknown name in the project's own alphabet was not judged: $OUT"

# ── a project with no roster at all has no answer to compare against ───────────────────────────
fixture bare
task T-AAAAAH "Web Engineer"
run; [ "$RC" = 0 ] && ok || bad "day one — a task written before anyone is hired — was refused: $OUT"

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
mutant "the roster reduced to the team file" \
  'git("ls-files", "-z", "_ops/roles", "_ops/teams", "_ops/panels")' \
  'git("ls-files", "-z", "_ops/teams")' \
  && { fixture; task T-AAAAAB "architect"; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: _ops/roles/ unread"; }

mutant "the name compared literally" 'if norm(val) in known:' 'if val.strip() in known:' \
  && { fixture; task T-AAAAAA "[Web Engineer](../roles/web_engineer.md)"; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: no normalisation"; }

mutant "every staged task judged, not the assignment this commit writes" \
  '    if not re.search(r"^\+.*(?:\*\*)?Assignee(?:\*\*)?\s*:", diff, re.M | re.I):' \
  '    if False:' \
  && { fixture; task T-OLD111 "Frontend Engineer"; commit legacy
       printf '\nmore\n' >> _ops/tasks/T-OLD111-thing.md; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: history retro-judged"; }

mutant "the alphabet narrowed to ASCII" \
  '"".join(c if c.isalnum() else " " for c in s.lower())' \
  '"".join(c if (c.isascii() and c.isalnum()) else " " for c in s.lower())' \
  && { fixture; task T-AAAAAG "Дизайнер"; run          # its twin, four cases up, is refused
       [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: a non-ASCII roster erased"; }

mutant "an empty roster read as a roster naming nobody" 'if known else []' 'if True else []' \
  && { fixture bare; task T-AAAAAH "Web Engineer"; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: day one refused"; }
MUT=""

echo "assignee-exists: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
