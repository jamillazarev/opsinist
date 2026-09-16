#!/usr/bin/env bash
# `cost-report.py` — the rollup — on a throwaway project holding the cases the page exists for:
# a record in the template's own four-column shape, one with `unknown` where a runtime reported
# nothing, a failed attempt, third-party money spent on another key, and a run whose task names a
# release.
#
# **Three code mutants**: `unknown` summed as zero with nothing said (a floor read as a
# measurement), the four numbers read only from `key: value` lines (the template's own table
# missed, so every project reports unknown), and the waste slice emptied (spend on work that
# produced nothing is the slice the ledger exists for).
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
cost() { OUT=$(python3 "${MUT:-$HERE/cost-report.py}" --root "$T/p" "$@" 2>&1); RC=$?; }
said() { [ "$(printf '%s' "$OUT" | grep -cF -- "$1")" -gt 0 ]; }

fixture() {
  rm -rf "$T/p"; mkdir -p "$T/p/_ops/runs" "$T/p/_ops/tasks"
  cd "$T/p" || exit 1
  git init -q .
  { printf '# R-AAAAAA — the web client\n\n| | |\n|---|---|\n'
    printf '| **Task** | [T-AAAAAA](../tasks/T-AAAAAA-web.md) · init the web client |\n'
    printf '| **Ran** | 2026-09-15T09:14Z → 09:41Z |\n| **Outcome** | completed |\n'
    printf '| **Attempt** | 1 |\n| **Model that answered** | claude-sonnet-5 |\n'
    printf '| **Third-party spend** | none |\n\n'
    printf '| `input` | `output` | `cache_read` | `cache_write` |\n|---|---|---|---|\n'
    printf '| 12400 | 3100 | 480000 | 21000 |\n'
  } > _ops/runs/R-AAAAAA.md
  { printf '# R-BBBBBB — a failed try\n\n| | |\n|---|---|\n'
    printf '| **Task** | [T-AAAAAA](../tasks/T-AAAAAA-web.md) · init the web client |\n'
    printf '| **Ran** | 2026-09-15T11:00Z → 11:12Z |\n| **Outcome** | failed |\n'
    printf '| **Attempt** | 2 |\n| **Model that answered** | claude-opus-5 |\n'
    printf '| **Third-party spend** | 140 image generations · 4.20 USD |\n\n'
    printf '| `input` | `output` | `cache_read` | `cache_write` |\n|---|---|---|---|\n'
    printf '| 5000 | unknown | 90000 | 0 |\n'
  } > _ops/runs/R-BBBBBB.md
  printf '# T-AAAAAA — init the web client\n\n**Type**: feature · **Status**: review\n**Assignee**: web-engineer\n**Release**: v0.1\n\n## History\n' \
    > _ops/tasks/T-AAAAAA-web.md
}

# ── the four numbers stay four, and the release groups them ────────────────────────────────────
fixture
cost
[ "$RC" = 0 ] && said '17 400' && said '570 000' && ok \
  || bad "the four numbers were not read from the template's own row: $OUT"
said '| v0.1 |' && ok || bad "the release the task declares did not group its runs: $OUT"
said 'cache read' && said 'cache write' && ! said 'total tokens' && ok \
  || bad "the page collapsed the four numbers into one: $OUT"

# ── `unknown` is a value, and a floor is called a floor ────────────────────────────────────────
said '1 of 2 runs carry `unknown`' && said 'a floor, not a measurement' && ok \
  || bad "a run reporting nothing was summed silently as zero: $OUT"

# ── money spent on another key is not in any token count ───────────────────────────────────────
said 'USD 4.20' && ok || bad "third-party spend was dropped: $OUT"

# ── the slice the ledger exists for ────────────────────────────────────────────────────────────
said 'Spent on work that produced nothing' && said '95 000' && ok \
  || bad "the failed run was not counted as spend that produced nothing: $OUT"
said 'Second and later attempts**: 1' && ok || bad "a second attempt went uncounted: $OUT"

# ── a project with no run records says that, and not that it was free ──────────────────────────
rm -f _ops/runs/*.md
cost; [ "$RC" = 0 ] && said 'Nothing has been measured' && said 'not *this project was free*' && ok \
  || bad "a project with no records did not say so: $OUT"

# ── --write, and --by task ─────────────────────────────────────────────────────────────────────
fixture
cost --write; [ "$RC" = 0 ] && [ -f _ops/COST.md ] && ok || bad "--write wrote nothing: $OUT"
cost --by task; said '| T-AAAAAA |' && ok || bad "--by task did not group by task: $OUT"
cost --by model; said 'claude-opus-5' && said 'claude-sonnet-5' && ok \
  || bad "--by model did not separate the models: $OUT"
cost --since 2026-09-16; said 'Nothing has been measured' && ok \
  || bad "--since did not drop runs dated before it: $OUT"

# ── the mutants ────────────────────────────────────────────────────────────────────────────────
mutant() {   # $1 what it breaks · $2 from · $3 to
  cp "$HERE/cost-report.py" "$T/mut.py"
  M_FROM="$2" M_TO="$3" python3 - "$T/mut.py" <<'PY' || { bad "MUTATION DID NOT APPLY: $1"; return 1; }
import os, sys
p = sys.argv[1]; s = open(p).read(); a, b = os.environ["M_FROM"], os.environ["M_TO"]
assert s.count(a) == 1, "found %d times" % s.count(a)
open(p, "w").write(s.replace(a, b))
PY
  MUT="$T/mut.py"
}
mutant "unknown summed as zero with nothing said" '    if unknown_total:' '    if False:' \
  && { fixture; cost; said 'a floor, not a measurement' \
       && bad "the suite did not catch the mutant: unknown hidden" || ok; }

mutant "the four numbers read only from key: value lines" '    if head:' '    if False:' \
  && { fixture; cost; said '17 400' \
       && bad "the suite did not catch the mutant: the template's own row unread" || ok; }

mutant "the waste slice emptied" 'r["outcome"] in ("failed", "interrupted", "limit", "canceled",' \
                                 'r["outcome"] in ("no-such-outcome", "interrupted", "limit", "canceled",' \
  && { fixture; cost; said 'Spent on work that produced nothing' \
       && bad "the suite did not catch the mutant: failed runs dropped from the waste slice" || ok; }
MUT=""

echo "cost-report: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
