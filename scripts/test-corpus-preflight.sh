#!/usr/bin/env bash
# The doors-regression check (preflight §1a) exercised on the mutant and the twin. The check
# exists because a field report measured the hole: the guide template silently stopped being
# the place workers learn the doors, and nothing noticed for a release. A check without its
# mutation test is a hope — this is the test.
#
# These cases run against a LOCAL CLONE of HEAD, not the working tree — an uncommitted edit
# to a checked file or to preflight itself is exercised one commit late, on purpose: the
# suite tests what ships.
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

# mutant 3 — the lens's own evasion: the block deleted, the four paths left in an HTML
# comment. A guide that stops TELLING workers the doors while the strings survive is the
# exact hole the check was built for.
( cd "$T/c" && git checkout -q starting.md templates/GUIDE-template.md \
  && python3 -c "
import pathlib,re
p=pathlib.Path('templates/GUIDE-template.md'); t=p.read_text()
m=re.search(r'\*\*The doors — run these.*?\n\n', t, re.S)
t=t.replace(m.group(0), '<!-- _ops/scripts/transition.py _ops/runs/ _ops/pipelines/ _ops/scripts/new-id.py -->\n\n',1)
p.write_text(t)" \
  && CORPUS_PF_TEST=1 bash scripts/preflight.sh ) > "$T/o3" 2>&1 \
  && bad "paths hidden in a comment passed while the doors block was gone" || ok
grep -q "has no doors block" "$T/o3" && ok || bad "the comment-evasion refusal does not name the block"

echo "corpus-preflight: $pass passed, $fail failed"
exit "$fail"
