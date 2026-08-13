#!/usr/bin/env bash
# The doors-regression check (preflight §1a) exercised on the mutant and the twin. The check
# exists because a field report measured the hole: the guide template silently stopped being
# the place workers learn the doors, and nothing noticed for a release. A check without its
# mutation test is a hope — this is the test.
#
# Recursion guard: this suite runs preflight inside a clone; CORPUS_PF_TEST makes the clone's
# preflight skip its suite battery, so the depth is exactly two.
[ -n "${CORPUS_PF_TEST:-}" ] && { echo "corpus-preflight: 0 passed, 0 failed"; exit 0; }
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
git clone -q --local . "$T/c"
pass=0; fail=0
ok(){ pass=$((pass+1)); }; bad(){ fail=$((fail+1)); echo "  ✗ $1"; }

# the twin: an untouched clone passes
( cd "$T/c" && CORPUS_PF_TEST=1 bash scripts/preflight.sh ) >/dev/null 2>&1 \
  && ok || bad "the untouched twin failed preflight"

# mutant 1: the guide template loses the transition door → refused, and the refusal names it
perl -pi -e 's{_ops/scripts/transition\.py}{}g' "$T/c/templates/GUIDE-template.md"
( cd "$T/c" && CORPUS_PF_TEST=1 bash scripts/preflight.sh ) > "$T/o1" 2>&1 \
  && bad "a guide template missing the transition door passed" || ok
grep -q "no longer names _ops/scripts/transition.py" "$T/o1" \
  && ok || bad "the refusal does not name the missing door"

# mutant 2: starting.md stops installing the doors → refused
( cd "$T/c" && git checkout -q templates/GUIDE-template.md \
  && perl -pi -e 's/transition\.py/xxx.py/g' starting.md \
  && CORPUS_PF_TEST=1 bash scripts/preflight.sh ) > "$T/o2" 2>&1 \
  && bad "a starting.md that stopped installing the doors passed" || ok
grep -q "no longer installs the doors" "$T/o2" \
  && ok || bad "the starting.md refusal does not say what went missing"

echo "corpus-preflight: $pass passed, $fail failed"
exit "$fail"
