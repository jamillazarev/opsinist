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
grep -q "no day-one row installing the doors" "$T/o2" \
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

# mutant 4 — the same evasion, carried in on CRLF. Measured 2026-08-14: `sed '/…/,/^$/p'` never
# terminated, because `^$` does not match a line ending in `\r`, so the range ran to EOF and the
# strings anywhere below the gutted block satisfied every path. One `core.autocrlf=true` checkout
# reached this, and the repo ships no `.gitattributes` to prevent it.
( cd "$T/c" && git checkout -q starting.md templates/GUIDE-template.md \
  && python3 -c "
import pathlib,re
p=pathlib.Path('templates/GUIDE-template.md'); t=p.read_text()
m=re.search(r'\*\*The doors — run these.*?\n\n', t, re.S)
t=t.replace(m.group(0), '_ops/scripts/transition.py _ops/runs/ _ops/pipelines/ _ops/scripts/new-id.py\n\n',1)
p.write_text(t.replace('\n','\r\n'))" \
  && CORPUS_PF_TEST=1 bash scripts/preflight.sh ) > "$T/o4" 2>&1 \
  && bad "a gutted block passed once the file arrived with CRLF line endings" || ok
grep -q "has no doors block" "$T/o4" && ok || bad "the CRLF refusal does not name the block"

# mutant 5 is a TWIN, not a mutant: a blank line inside the block is ordinary formatting, and the
# previous form answered it with four refusals naming paths that sat three lines up, unread. A
# gate that lies about why costs more than one that stays quiet — this asserts it stays quiet.
( cd "$T/c" && git checkout -q templates/GUIDE-template.md \
  && python3 -c "
import pathlib,re
p=pathlib.Path('templates/GUIDE-template.md'); t=p.read_text()
m=re.search(r'(\*\*The doors — run these[^\n]*\n- [^\n]*\n)', t)
p.write_text(t.replace(m.group(1), m.group(1)+'\n',1))" \
  && CORPUS_PF_TEST=1 bash scripts/preflight.sh ) > "$T/o5" 2>&1 \
  && ok || bad "a blank line inside the doors block was treated as the end of it"

# mutant 6 — the starting.md half, defeated by the very evasion the guide half was rewritten to
# escape: delete the day-one row, leave the paths in a comment. Measured passing on 2026-08-14.
( cd "$T/c" && git checkout -q templates/GUIDE-template.md \
  && python3 -c "
import pathlib
p=pathlib.Path('starting.md'); lines=p.read_text().split('\n')
out=[l for l in lines if not ('company-preflight.sh' in l and 'transition.py' in l)]
assert len(out) < len(lines), 'no day-one row to remove — this mutant tests nothing'
out.insert(0, '<!-- templates/company-preflight.sh scripts/transition.py scripts/new-id.py -->')
p.write_text('\n'.join(out))" \
  && CORPUS_PF_TEST=1 bash scripts/preflight.sh ) > "$T/o6" 2>&1 \
  && bad "the day-one row was deleted and a comment holding the paths passed for it" || ok
grep -q "no day-one row installing the doors" "$T/o6" \
  && ok || bad "the day-one refusal does not name what went missing"

# mutant 7 — a released entry edited after its tag. This is how the 0.1.0 section came to claim
# the current corpus's counts and a later release's vocabulary: each edit was small and none was
# wrong on its own. The twin below is the one change that IS allowed — a marked correction.
( cd "$T/c" && git checkout -q . \
  && python3 -c "
import pathlib,re
p=pathlib.Path('CHANGELOG.md'); t=p.read_text()
m=re.search(r'^## 0\\.1\\.0 .*?$', t, re.M); assert m, 'no 0.1.0 entry to mutate'
i=t.index('\\n', m.end())
p.write_text(t[:i] + '\\n\\nA sentence that was never in the 0.1.0 release.\\n' + t[i:])" \
  && CORPUS_PF_TEST=1 bash scripts/preflight.sh ) > "$T/o7" 2>&1 \
  && bad "a released entry was edited after its tag and passed" || ok
grep -q "no longer matches what v0.1.0 shipped" "$T/o7" \
  && ok || bad "the freeze refusal does not name the tag"

# twin: a blockquote correction under a released entry is the permitted change
( cd "$T/c" && git checkout -q . \
  && python3 -c "
import pathlib,re
p=pathlib.Path('CHANGELOG.md'); t=p.read_text()
m=re.search(r'^## 0\\.1\\.0 .*?$', t, re.M)
i=t.index('\\n', m.end())
p.write_text(t[:i] + '\\n\\n> *Corrected 2026-08-14.* The number below was wrong.\\n' + t[i:])" \
  && CORPUS_PF_TEST=1 bash scripts/preflight.sh ) >/dev/null 2>&1 \
  && ok || bad "a marked correction under a released entry was refused"

echo "corpus-preflight: $pass passed, $fail failed"
exit "$fail"
