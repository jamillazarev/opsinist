#!/usr/bin/env bash
# `board.py` — the derived board — on a throwaway project holding the two dialects a live one was
# measured in, plus the cases a board exists to make visible: a status on no rung of the ladder, a
# task whose assignment was written in a field the template never declared, and drift between the
# page on disk and what the tasks now say.
#
# **Three code mutants**: the field read only at the start of a line (the template writes
# `**Type**: x · **Status**: y`, so three of nine live tasks came out blank), the borrowed field
# taken silently (a board that blesses the dialect §23 refuses), and `--check` comparing nothing
# (a stale page reported current, which is the one failure that makes a generated page dangerous
# rather than merely old).
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
board() { OUT=$(python3 "${MUT:-$HERE/board.py}" --root "$T/p" "$@" 2>&1); RC=$?; }
said() { [ "$(printf '%s' "$OUT" | grep -cF -- "$1")" -gt 0 ]; }

fixture() {
  rm -rf "$T/p"; mkdir -p "$T/p/_ops/tasks" "$T/p/_ops/process/types"
  cd "$T/p" || exit 1
  git init -q . && git config user.email t@f.t && git config user.name T
  printf 'stages: [build, review, accept]\nterminal: [accept]\ngates:\n  review -> accept:\n    review_by: non-author\n' \
    > _ops/process/types/feature.md
  # the template's dialect: several fields to a line, and the id in the first line
  { printf '# T-AAAAAA — the web client\n\n**Type**: feature · **Status**: review\n'
    printf '**Assignee**: web-engineer\n**Release**: v0.1 · **Wave**: none\n\n## History\n\n- 2026-09-15 — started\n'
  } > _ops/tasks/T-AAAAAA-web-client.md
  # the dialect an agent invents when nothing refuses it — and a status on no rung of the ladder
  { printf '# T-BBBBBB: расширение\n\n- **Type:** feature\n- **Role:** Frontend Engineer\n'
    printf -- '- **Status:** todo\n\n## Лог\n'
  } > _ops/tasks/T-BBBBBB-extension.md
  git add -A && git commit -qm fixture
}

# ── every task appears, with the field that is not first on its line read ──────────────────────
fixture
board
[ "$RC" = 0 ] && said '**2 tasks**' && said 'review' && said 'web-engineer' && ok \
  || bad "the board did not read the template's own dialect: $OUT"
said '[T-AAAAAA](tasks/T-AAAAAA-web-client.md)' && ok \
  || bad "the board names a task without linking to it — a bare id is a string: $OUT"
said 'v0.1' && ok || bad "the release the task declares does not group it: $OUT"

# ── a status on no rung of that task's own ladder is marked, and said out loud ─────────────────
said 'todo ⚠' && said 'A status nothing declared' && ok \
  || bad "a status on no rung of the ladder passed unmarked: $OUT"

# ── a name read from a field the template does not declare is shown, and shown as borrowed ─────
said 'Frontend Engineer' && said 'read from a field the template does not declare' && ok \
  || bad "the invented `Role:` field was dropped, or blessed silently: $OUT"

# ── --write, then --check, which is the only honest way to keep a generated page ───────────────
board --write
[ "$RC" = 0 ] && [ -f _ops/BOARD.md ] && ok || bad "--write did not write _ops/BOARD.md: $OUT"
board --check
[ "$RC" = 0 ] && said 'is current' && ok || bad "--check called a page it had just written stale: $OUT"

printf '# T-CCCCCC — a third thing\n\n**Type**: feature · **Status**: build\n**Assignee**: qa\n\n## History\n' \
  > _ops/tasks/T-CCCCCC-third.md
board --check
[ "$RC" = 1 ] && said 'behind what the tasks say' && ok \
  || bad "--check passed a board that had drifted from the tasks: $OUT"

# ── a project this skill does not operate is refused, not half-answered ────────────────────────
rm -rf "$T/nope"; mkdir -p "$T/nope"
OUT=$(python3 "$HERE/board.py" --root "$T/nope" 2>&1); RC=$?
[ "$RC" = 2 ] && ok || bad "a directory with no _ops/tasks/ did not exit 2: $OUT"

# ── the mutants ────────────────────────────────────────────────────────────────────────────────
mutant() {   # $1 what it breaks · $2 from · $3 to
  cp "$HERE/board.py" "$T/mut.py"
  M_FROM="$2" M_TO="$3" python3 - "$T/mut.py" <<'PY' || { bad "MUTATION DID NOT APPLY: $1"; return 1; }
import os, sys
p = sys.argv[1]; s = open(p).read(); a, b = os.environ["M_FROM"], os.environ["M_TO"]
assert s.count(a) == 1, "found %d times" % s.count(a)
open(p, "w").write(s.replace(a, b))
PY
  MUT="$T/mut.py"
}
mutant "the field read only at the start of its line" \
  'r"^(?![ ]{4}|\t)[^\n]*?[*`_]*%s[*`_]*[ \t]*:[ \t]*[*`_]*([^·|\n]+)"' \
  'r"^[*`_]*%s[*`_]*[ \t]*:[ \t]*[*`_]*([^·|\n]+)"' \
  && { fixture; board; printf '%s' "$OUT" | grep -qF 'review' \
       && bad "the suite did not catch the mutant: a field after a · read as present" || ok; }

mutant "the borrowed field taken silently" 't["assignee"], t["borrowed"] = v, alt' 't["assignee"] = v' \
  && { fixture; board; said 'read from a field the template does not declare' \
       && bad "the suite did not catch the mutant: the dialect blessed silently" || ok; }

mutant "--check comparing nothing" 'if strip(have) == strip(text):' 'if True:' \
  && { fixture; board --write; printf '# T-CCCCCC — a third\n\n**Type**: feature · **Status**: build\n**Assignee**: qa\n\n## History\n' > _ops/tasks/T-CCCCCC-third.md
       board --check; [ "$RC" = 0 ] && ok \
       || bad "the suite did not catch the mutant: --check comparing nothing"; }
MUT=""

echo "board: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
