#!/usr/bin/env bash
# §24 of the project guard — the product moved and the record did not — shown warning on the first
# such commit and refusing the second in a row, on a throwaway project.
#
# The measured shape it answers (a live project, 2026-09-16): 4 of 15 commits changed files outside
# `_ops/` while touching neither a task nor a run record, one of them thirteen files of feature work.
# The legitimate one-line fix is the reason this warns before it refuses. **The fourth of those four
# is `chore: opsinist init`** — the commit that wires the project — which is why the record is the
# whole `_ops/` tree and not only tasks and runs: see the case below, and `shape()`'s own note.
#
# **Four code mutants**: the refusal removed (a warning is what the rule already was), the previous
# commit not read (every lone fix refused), the record narrowed to tasks alone (the quick path, whose
# whole shape is a run record and no task, caught), and narrowed to tasks-and-runs (the wiring commit
# becomes a precedent, so the guard's first act on a fresh project is a false refusal).
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
said() { [ "$(printf '%s' "$OUT" | grep -cF -- "$1")" -gt 0 ]; }   # -F: `**` is not a repetition here
run() { git add -A; OUT=$(bash _ops/scripts/preflight.sh 2>&1); RC=$?; }
commit() { git add -A; git commit -qm "$1" --no-verify; }

task() {   # a task of the shape §23 asks for, so this suite measures §24 and nothing else
  printf '# %s — a thing\n\n**Type**: build · **Status**: started\n**Assignee**: owner\n\n' "$1" \
    > "_ops/tasks/$1-thing.md"
  printf '## Ready when\n\nThe thing is not there.\n\n## Done when\n\n- [ ] it is\n\n## History\n\n- 2026-09-16 — started\n' \
    >> "_ops/tasks/$1-thing.md"
}
run_record() {   # the four token numbers and the three sliceable fields §1f asks a record for
  printf '# %s\n\n| | |\n|---|---|\n| **Task** | none — a job small enough to need none |\n' "$1" \
    > "_ops/runs/$1.md"
  printf '| **Outcome** | completed |\n| **Attempt** | 1 |\n| **Model that answered** | claude-sonnet-5 |\n\n' \
    >> "_ops/runs/$1.md"
  printf '| `input` | `output` | `cache_read` | `cache_write` |\n|---|---|---|---|\n| 1200 | 300 | 0 | 0 |\n' \
    >> "_ops/runs/$1.md"
}

fixture() {   # $1 = "operated" or "foreign" — the second is a repository this skill does not run
  rm -rf "$T/p"; mkdir -p "$T/p/_ops/tasks" "$T/p/_ops/runs" "$T/p/_ops/scripts" "$T/p/src"
  cd "$T/p" || exit 1
  git init -q . && git config user.email t@f.t && git config user.name T
  for f in ROADMAP TEAM TOOLING DECISIONS ARCHITECTURE; do printf '# %s\n' "$f" > "_ops/$f.md"; done
  if [ "$1" = operated ]; then printf '# Guide\n\n**Operated by** Opsinist **0.2.19**\n' > CLAUDE.md
  else printf '# Guide\n\nSomebody else keeps this.\n' > CLAUDE.md; fi
  printf 'one\n' > src/app.js
  # the wiring commit: `_ops/` arrives, and there is no task in it because the door arrives with it
  cp "${MUT:-$HERE/../templates/company-preflight.sh}" _ops/scripts/preflight.sh
  cp "$HERE/transition.py" "$HERE/new-id.py" _ops/scripts/ 2>/dev/null || true
  commit "chore: opsinist init"
}

# ── the commit that wires the project is not a precedent: the fix after it warns, not refuses ──
fixture operated
printf 'two\n' > src/app.js; run
[ "$RC" = 0 ] && said 'moves the product and not the record' && ok \
  || bad "the first product-only commit after the wiring commit was refused instead of warned: $OUT"

# ── the second in a row is refused, and names the commit before it ─────────────────────────────
commit "first fix"
printf 'three\n' > src/app.js; run
[ "$RC" = 1 ] && said 'and so did the one before it' && said 'new-task.py' && ok \
  || bad "two product-only commits in a row were not refused: $OUT"

# ── moving a task satisfies it, however far the product moved ──────────────────────────────────
task T-AAAAAA
run; [ "$RC" = 0 ] && ok || bad "a commit that moves a task with the product was refused: $OUT"
commit "with a task"

# ── the quick path — a run record and no task — is not caught ──────────────────────────────────
printf 'four\n' > src/app.js; run_record R-AAAAAA
run; [ "$RC" = 0 ] && ! said 'moves the product and not the record' && ok \
  || bad "the quick path — a run record and no task — was caught: $OUT"
commit "quick job"

# ── after a commit that carried the record, the next lone fix warns again rather than refusing ──
printf 'five\n' > src/app.js; run
[ "$RC" = 0 ] && said 'moves the product and not the record' && ok \
  || bad "a lone fix after a recorded commit was refused: $OUT"

# ── a repository this skill does not operate is none of its business ───────────────────────────
fixture foreign
printf 'two\n' > src/app.js; commit "first fix"
printf 'three\n' > src/app.js; run
[ "$RC" = 0 ] && ! said 'moves the product and not the record' && ok \
  || bad "a repository with no operator line was judged: $OUT"

# ── a commit that moves only the record says nothing ───────────────────────────────────────────
fixture operated
printf '# Roadmap\n\nlater\n' > _ops/ROADMAP.md; run
[ "$RC" = 0 ] && ! said 'moves the product' && ok || bad "a record-only commit was warned about: $OUT"

# ── the mutants ────────────────────────────────────────────────────────────────────────────────
RECORD_LINE='    record = [p for p in paths if p.startswith("_ops/")]'
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
two_in_a_row() {
  fixture operated
  printf 'two\n' > src/app.js; commit "first fix"
  printf 'three\n' > src/app.js; run
}
mutant "the refusal removed — the rule back to the note it already was" \
  'print("FAIL:this commit moves the product' 'print("WARN:this commit moves the product' \
  && { two_in_a_row; [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: refusal removed"; }

mutant "the commit before it never read — every lone fix refused" \
  'if product_before and not record_before:' 'if True:' \
  && { fixture operated; printf 'two\n' > src/app.js; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: a lone fix refused"; }

mutant "the record narrowed to tasks — the quick path caught" \
  "$RECORD_LINE" '    record = [p for p in paths if p.startswith("_ops/tasks/")]' \
  && { fixture operated; printf 'two\n' > src/app.js; commit "first fix"
       printf 'three\n' > src/app.js; run_record R-AAAAAA; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: the quick path caught"; }

mutant "the record narrowed to tasks and runs — the wiring commit becomes a precedent" \
  "$RECORD_LINE" '    record = [p for p in paths if p.startswith("_ops/tasks/") or p.startswith("_ops/runs/")]' \
  && { fixture operated; printf 'two\n' > src/app.js; run
       [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: a fresh project's first fix refused"; }
MUT=""

echo "record-moves: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
