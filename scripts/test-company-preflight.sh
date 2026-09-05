#!/usr/bin/env bash
# The bypass net (§14) exercised end to end: a hand-flipped stage in a staged commit is
# refused; the same move made through the door carries its transition line and passes.
set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d /tmp/opsinist-cpf-test.XXXXXX)
trap 'rm -rf "$T"' EXIT
cd "$T"
git init -q . && git config user.email t@f.t && git config user.name T
mkdir -p _ops/tasks _ops/scripts
cp "$HERE/../templates/company-preflight.sh" _ops/scripts/preflight.sh
printf '# Roadmap\n' > _ops/ROADMAP.md; printf '# Team\n' > _ops/TEAM.md
printf '# Tooling\n' > _ops/TOOLING.md; printf '# Decisions\n' > _ops/DECISIONS.md
cat > _ops/tasks/T-1.md <<'EOF'
# T-1 — the thing

**Status**: started
**Assignee**: worker-a

## History
EOF
# the doors: the furniture check refuses a wired project without them (N89's next form)
cp "$HERE/transition.py" "$HERE/new-id.py" _ops/scripts/ 2>/dev/null || true
git add -A && git commit -qm fixture

pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }

# a wired project without the doors is refused, naming the copy — and with them it passes
mv _ops/scripts/transition.py /tmp/.door.$$ 
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a guard without its doors passed" || ok
# `|| true` before the pipe, because this file sets pipefail: a refusing preflight piped into
# a MATCHING grep still returns preflight's 1, and the assertion reads a found phrase as absent.
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q "migrate-layout.py" && ok || bad "the doors refusal lost the command a reader can run"
# presence is not the door: an interrupted copy leaves a file of the right name and no command
: > _ops/scripts/transition.py
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "an empty file named transition.py passed as a door" || ok
printf 'print("hello")\n' > _ops/scripts/transition.py
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a .py that reads no arguments passed as a door" || ok
# The two false refusals that got the stricter form withdrawn on 2026-08-14. An inline `ast`
# heredoc caught one more stub shape and, in exchange, refused EVERY commit in a project with
# no python3 — blaming the doors for a missing interpreter — and refused a working door with a
# UTF-8 BOM. Both are real projects; the stub is not. These two hold the withdrawal.
mv /tmp/.door.$$ _ops/scripts/transition.py 2>/dev/null || true
mkdir -p /tmp/.nopy.$$ && printf '#!/bin/sh\nexit 127\n' > /tmp/.nopy.$$/python3 && chmod +x /tmp/.nopy.$$/python3
PATH="/tmp/.nopy.$$:$PATH" bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a project without python3 had every commit refused, blaming its doors"
rm -rf /tmp/.nopy.$$
python3 -c "
import pathlib
p=pathlib.Path('_ops/scripts/transition.py'); p.write_text('\ufeff'+p.read_text())"
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a working door carrying a UTF-8 BOM was refused as not reading arguments"
cp "$HERE/transition.py" _ops/scripts/transition.py
mv _ops/scripts/transition.py /tmp/.door.$$
mv /tmp/.door.$$ _ops/scripts/transition.py

# a hand flip, staged, no transition line → §14 refuses the commit
sed -i '' 's/\*\*Status\*\*: started/**Status**: done/' _ops/tasks/T-1.md
git add _ops/tasks/T-1.md
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "hand-flipped stage passed the net" || ok
git checkout -q _ops/tasks/T-1.md && git reset -q

# the same move through the door → transition line lands, the net passes it
mkdir -p _ops/process/types && printf 'started -> review -> done\n' > _ops/process/types/default.md
python3 "$HERE/transition.py" _ops/tasks/T-1.md review --by worker-a >/dev/null
python3 "$HERE/transition.py" _ops/tasks/T-1.md done --by owner >/dev/null 2>&1 || {
  printf -- '- reviewed by bob: checked\n' >> _ops/tasks/T-1.md
  python3 "$HERE/transition.py" _ops/tasks/T-1.md done --by owner >/dev/null
}
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "a door-made move was refused by the net"

# §15 · a generated asset with no recipe is refused. Every case here is one a lens measured
# passing the first version of this gate, so the suite is the record of what it used to miss:
# a current generator (the old check keyed on a vendor list — Ideogram, Nano Banana and
# gpt-image-1 all walked through), an empty value after a key, and a staged-broken file the
# author fixed only in the editor. Fixtures are written with printf, never `sed -i ''`, which
# is BSD-only and made this suite unrunnable on Linux while CI pinned macOS and never said so.
mkdir -p _ops/requests
assets() { printf '# Assets\n\n| Asset | Origin | Licence | Where |\n|---|---|---|---|\n| %s |\n' "$1" > _ops/assets.md; git add -A; }
relay()  { printf '# R-1 — an image for the launch post\n\n%s\n' "$1" > "${2:-_ops/requests/R-1.md}"; git add -A; }
gate()   { bash _ops/scripts/preflight.sh >/dev/null 2>&1; }

assets 'hero.png | origin: generated, Ideogram | owned | header'
gate && bad "a current generator with no recipe passed (the vendor-list hole)" || ok

assets 'hero.png | origin: generated, model: flux-1.1-pro, prompt: `a slate roof`, seed:'
gate && bad "an empty seed value passed" || ok

assets 'hero.png | origin: generated, model: flux-1.1-pro, prompt: `a slate roof`, seed: none'
gate || bad "a complete recipe with seed: none was refused"; gate && ok

assets 'logo.svg | origin: drawn | owned | everywhere'
gate || bad "a drawn asset was caught by the recipe check"; gate && ok

rm -f _ops/assets.md; git add -A

# §16 · a `relay` carries one operation, not the job. The load-bearing case is the cheapest
# cheat a lens found: the keys present as bare words inside an ordinary sentence, satisfying a
# substring test while the request says exactly what the gate exists to refuse.
relay '**Ask**: we need an image for the post. kind: relay payload: predicate: destination:'
gate && bad "keys with no values passed" || ok

relay '**Kind:** relay
**Payload**: `a slate roof at dusk, 3:2, no text`
**Predicate**: the roof fills the upper third and no text appears
**Destination**: `assets/posts/launch-hero.png`
**Return with it**: the model and the seed'
gate || bad "a complete relay in bold-colon spelling was refused"; gate && ok

relay '**kind**: relay
**payload**: `x`
**predicate**: y
**destination**: z' '_ops/requests/an image for the post.md'
gate || bad "a filename with spaces was skipped or broke the loop"; gate && ok
rm -f '_ops/requests/an image for the post.md'; git add -A

# the index is the truth, not the editor: stage the broken one, fix only the worktree
printf '# R-3\n\n**kind**: relay\n**payload**: `x`\n**destination**: z\n' > _ops/requests/R-3.md
git add -A
printf '# R-3\n\n**kind**: relay\n**payload**: `x`\n**predicate**: y\n**destination**: z\n' > _ops/requests/R-3.md
gate && bad "a staged-broken relay passed because the gate read the worktree" || ok
rm -f _ops/requests/R-3.md; git add -A

printf '# R-2 — merge?\n\n**kind**: approval\n\n**Ask**: merge the release branch?\n' > _ops/requests/R-2.md
git add -A
gate || bad "an approval request was caught by the relay check"; gate && ok

rm -rf _ops/requests; git add -A

# Every case below is one an adversarial lens measured PASSING a previous version of these
# gates. The suite used to test the gate against a row shape no document prescribes; these use
# the shapes people actually write, and each is named by the evasion it represents.

assets 'hero.png | origin: generated | model: prompt: seed: none | owned'
gate && bad "keys satisfying each other passed — a value that is the next key is not a value" || ok

assets 'hero.png | origin: generated | model: - prompt: - seed: - | owned'
gate && bad "a dash as every value passed" || ok

assets 'hero.png | Midjourney v7, no recipe kept | owned | header'
gate && bad "a bare vendor name passed — the origin field must SUPPLEMENT the vendor list, not replace it" || ok

assets 'hero.png | origin: generated, Ideogram | owned | see origin: build pipeline'
gate && bad "a mention of another origin excused a row that declares origin: generated" || ok

printf '# Assets\n\n| A | B | C | D |\n|---|---|---|---|\n   | hero.png | origin: generated | no recipe | x |\n' > _ops/assets.md; git add -A
gate && bad "a GFM-legal indented table row was never read" || ok

rm -f _ops/assets.md; git add -A

mkdir -p _ops/requests
# the shipped template must not pass itself with nothing filled in
sed -n '/^# RQ-{{id}}/,/^## review/p' "$HERE/../templates/REQUEST-template.md" > _ops/requests/R-9.md
printf '\n**kind**: relay\n**Payload**: {{ready to run, verbatim}}\n**Predicate**: {{checkable}}\n**Destination**: {{a path}}\n' >> _ops/requests/R-9.md
git add -A
gate && bad "untouched {{placeholders}} counted as values" || ok
rm -f _ops/requests/R-9.md; git add -A

# a relay written as a table has no colon after the key
printf '# R-8\n\n| field | value |\n|---|---|\n| kind | relay |\n| Payload |  |\n' > _ops/requests/R-8.md
git add -A
gate && bad "a table-form relay was never detected" || ok
rm -f _ops/requests/R-8.md; git add -A

# and a complete relay whose three fields appear ONLY inside a fenced example is not a relay
printf '# R-7\n\n**kind**: relay\n\n```markdown\n**Payload**: `x`\n**Predicate**: y\n**Destination**: z\n```\n' > _ops/requests/R-7.md
git add -A
gate && bad "fields present only inside a fenced example counted" || ok
rm -f _ops/requests/R-7.md; git add -A

# Absent is deferred; deleted is not. Measured 2026-08-14: with §1 warning, deleting the register
# in the same commit that claims an unevidenced entitlement turned a refusal into a green commit,
# because §2, §3 and §9 are each gated on the file existing.
git rm -q _ops/TOOLING.md
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "deleting a document deleted the checks gated on it" || ok
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q "this commit retires" \
  && ok || bad "the deletion refusal does not say what was retired"
# the remedy the message names has to work, or --no-verify is the only exit — measured
# refusing the very commit it asked for
printf -- '- 2026-08-14 retiring _ops/TOOLING.md: moved to the vendor portal\n' >> _ops/DECISIONS.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "a retirement recorded in DECISIONS.md was refused anyway"
# the escape is a record, not a password: a passing mention with no retirement verb does not open it
git checkout -q HEAD -- _ops/DECISIONS.md && git reset -q && git checkout -q _ops/DECISIONS.md
git rm -q _ops/TOOLING.md
printf -- '- 2026-08-14 _ops/TOOLING.md was mentioned in a meeting\n' >> _ops/DECISIONS.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a bare mention of the file opened the escape" || ok
# and each retired file needs its own line — one decision must not cover a second deletion
printf -- '- 2026-08-14 retiring _ops/TOOLING.md: moved to the vendor portal\n' >> _ops/DECISIONS.md
git rm -q _ops/TEAM.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "one file's decision covered a second file's deletion" || ok
git checkout -q HEAD -- _ops/TOOLING.md _ops/TEAM.md _ops/DECISIONS.md && git reset -q
git checkout -q _ops/TOOLING.md _ops/TEAM.md _ops/DECISIONS.md
git checkout -q HEAD -- _ops/TOOLING.md _ops/DECISIONS.md && git reset -q && git checkout -q _ops/TOOLING.md _ops/DECISIONS.md
# a rename is not listed by --diff-filter=D, and git detects renames by default — measured
# walking straight through, and better for the constrained party than the delete it replaced
mkdir -p _ops/registers && git mv _ops/TOOLING.md _ops/registers/TOOLING.md
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a rename retired the register and its checks" || ok
git mv _ops/registers/TOOLING.md _ops/TOOLING.md && rmdir _ops/registers && git reset -q
# and emptying it reaches the same end — which the first version of the message recommended
: > _ops/TOOLING.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "emptying the register retired its checks" || ok
git checkout -q HEAD -- _ops/TOOLING.md && git reset -q && git checkout -q _ops/TOOLING.md

# Three gates that could never fire, measured 2026-08-14 and each with its own reason: §3 counted
# `^-[^-]`, which excludes exactly the removed BULLET it guards; §3b was gated on a flat
# `config.md` the migration renames away AND had two mutually exclusive filters; §7/§8 were gated
# on a flat `roles/` while §8 looped over `_ops/roles/*.md`.
mkdir -p _ops/roles
printf '# Decisions\n\n- 2026-01-01 we chose X\n- 2026-02-02 we chose Y\n' > _ops/DECISIONS.md
printf '# Config\n\n## Migrations\n\n- — -> 0.2.6 · applied\n- 0.2.6 -> 0.2.7 · applied\n' > _ops/config.md
git add -A && git commit -qm "gate fixtures"

printf '# Decisions\n' > _ops/DECISIONS.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "removing every decision BULLET passed the append-only gate" || ok
git checkout -q HEAD -- _ops/DECISIONS.md; git reset -q; git checkout -q _ops/DECISIONS.md
# ...and on a run that CLOSES A TASK, because the two fixtures above never enter §10's loop and
# that is exactly where the second orphaned heredoc landed. It survived a day of green 93/93 runs:
# a `$( … )` in command position, so a markdown link in a task file became an argv word THIS HOOK
# EXECUTED, plus `LINKS: command not found` on stderr. `bash -n` passes on that shape, and the
# stderr assertions written for the FIRST occurrence did not reach the path. Measured 2026-08-15
# (pass eleven). A check whose fixture does not walk the code is coverage on paper.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
mkdir -p _ops/process/types runs
printf 'started -> done\n' > _ops/process/types/stderr-close.md
printf '#!/bin/sh\necho EXECUTED >&2\n' > runs/R-probe.md; chmod +x runs/R-probe.md
printf '# T-STDERR — thing\n\n**Status**: started\n**Assignee**: ui\n**Type**: stderr-close\n\n## Done when\n\n- [ ] a thing\n\n## History\n' > _ops/tasks/T-STDERR.md
git add -A && git commit -qm "stderr close fixture" >/dev/null 2>&1
printf -- '- 08-15 — built · run [R-X](runs/R-probe.md)\n- reviewed by qa\n' >> _ops/tasks/T-STDERR.md
python3 -c "
import pathlib
p = pathlib.Path('_ops/tasks/T-STDERR.md')
p.write_text(p.read_text().replace('- [ ] a thing', '- [x] a thing'))"
python3 "$HERE/transition.py" _ops/tasks/T-STDERR.md done --by qa >/dev/null 2>&1
git add -A
err=$(bash _ops/scripts/preflight.sh 2>&1 >/dev/null)
[ -z "$err" ] \
  && ok || bad "the guard writes to stderr while a task closes: $(printf '%s' "$err" | head -1)"
printf '%s' "$err" | grep -q EXECUTED \
  && bad "the guard EXECUTED a path named by a link inside a task file" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q
git rm -qf _ops/tasks/T-STDERR.md runs/R-probe.md _ops/process/types/stderr-close.md >/dev/null 2>&1
git commit -qm "stderr close fixture out" >/dev/null 2>&1
# and the inversion the first repair introduced: appending to a file whose last line carries no
# trailing newline shows that line as removed AND re-added, so a pure append was refused
printf -- '# Decisions\n\n- 2026-01-01 we chose X' > _ops/DECISIONS.md; git add -A; git commit -qm "no trailing newline"
printf -- '\n- 2026-02-02 we chose Y\n' >> _ops/DECISIONS.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "a pure append was refused by the append-only gate"
printf -- '# Decisions\n\n- 2026-01-01 we chose Z\n' > _ops/DECISIONS.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a rewritten entry passed the append-only gate" || ok
# a bullet whose own text begins with two dashes arrives as `--- …` in the diff and was read as
# the diff header, so deleting one — or all of them — passed in silence
printf -- '# Decisions\n\n-- a bullet starting with two dashes\n' > _ops/DECISIONS.md
git add -A && git commit -qm "two-dash bullet"
printf -- '# Decisions\n' > _ops/DECISIONS.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "deleting a two-dash bullet passed — the header was dropped by shape" || ok
# a decision line with trailing whitespace: `uniq -c | while read` handed on a stripped copy,
# so the line could not match itself and a pure append after it was refused
printf -- '# Decisions\n\n- 2026-01-01 an entry with trailing spaces   \n' > _ops/DECISIONS.md
git add -A && git commit -qm "trailing spaces"
printf -- '- 2026-02-02 the next one\n' >> _ops/DECISIONS.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "an append after a trailing-whitespace entry was refused"
git checkout -q HEAD -- _ops/DECISIONS.md; git reset -q; git checkout -q _ops/DECISIONS.md
# and membership is not multiplicity: three identical entries reduced to one lost two records
printf -- '# Decisions\n\n- A\n- A\n- A\n' > _ops/DECISIONS.md; git add -A; git commit -qm "three"
printf -- '# Decisions\n\n- A\n' > _ops/DECISIONS.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "three identical entries reduced to one passed" || ok
git checkout -q HEAD -- _ops/DECISIONS.md; git reset -q; git checkout -q _ops/DECISIONS.md
git checkout -q HEAD -- _ops/DECISIONS.md; git reset -q; git checkout -q _ops/DECISIONS.md

printf '# Config\n\n## Migrations\n\n- — -> 0.2.7 · applied\n' > _ops/config.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "rewriting the migration log passed — the gate was unreachable in this layout" || ok
git checkout -q HEAD -- _ops/config.md; git reset -q; git checkout -q _ops/config.md

printf 'type: advisor\n' > _ops/roles/a.md; printf 'type: advisor\n' > _ops/roles/b.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "two advisors in _ops/roles passed — §7 was watching the flat path" || ok
rm -rf _ops/roles _ops/config.md; git add -A; git commit -qm "gate fixtures out"

# One state, one home — enforced on what a commit ADDS. A project carrying the old shape cannot
# rewrite its history, and refusing it on every commit until every task is hand-edited is a
# release stranding its own projects; what is refused is creating a second home. The count is
# not anchored at `^` either: the shipped template writes `**Type**: build · **Status**: done`,
# so a start-anchored count scored that as zero and the motivating defect walked through.
printf '# T-legacy\n\n**Type**: build · **Status**: done\nstage: backlog\n\n## History\n' > _ops/tasks/T-legacy.md
git add -A && git commit -qm "a legacy two-home task"
printf -- '- an ordinary note\n' >> _ops/tasks/T-legacy.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "an ordinary commit to a legacy two-home task was refused — the project is stranded"
git checkout -q HEAD -- _ops/tasks/T-legacy.md; git reset -q; git checkout -q _ops/tasks/T-legacy.md

printf '# T-new\n\n**Type**: build · **Status**: done\nstage: backlog\n\n## History\n' > _ops/tasks/T-new.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a new task creating two state homes passed — mid-line Status is what the template writes" || ok
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q "keeps its state in 2 places (it kept 0)" \
  && ok || bad "the refusal does not say what it found, with both counts"
rm -f _ops/tasks/T-new.md; git add -A

# an example is not a field: a fenced or quoted `stage:` must not count toward the two
printf '# T-ex\n\n**Status**: done\n\n```yaml\nstage: draft\n```\n\n> stage: quoted\n' > _ops/tasks/T-ex.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "a fenced or quoted example counted as a second state home"
rm -f _ops/tasks/T-ex.md; git rm -qf _ops/tasks/T-legacy.md >/dev/null 2>&1; git add -A
git commit -qm "state fixtures out" >/dev/null 2>&1

# A by-the-book day one commits. Built in its own tree from `starting.md`'s table alone — guide,
# config with its migration log, guard and both doors, first task with its type — and NONE of the
# four documents that table defers. This refused with four ✗ until 2026-08-14; the case exists so
# the refusal cannot come back without someone reading why it was removed.
D=$(mktemp -d /tmp/opsinist-dayone.XXXXXX)
mkdir -p "$D/_ops/scripts" "$D/_ops/tasks" "$D/_ops/process/types"
cp "$HERE/../templates/company-preflight.sh" "$D/_ops/scripts/preflight.sh"
cp "$HERE/transition.py" "$HERE/new-id.py" "$D/_ops/scripts/"
printf '# Guide\n\n**Operated by:** Opsinist\n' > "$D/CLAUDE.md"
printf '# Config\n\nschema_version: 1\n\n- — → 0.2.7 · 2026-08-14 · applied · owner\n' > "$D/_ops/config.md"
printf 'started -> review -> done\n' > "$D/_ops/process/types/default.md"
printf '# T-1 — the first task\n\n**Status**: started\n**Assignee**: owner\n\n## History\n' > "$D/_ops/tasks/T-1.md"
git -C "$D" init -q . && git -C "$D" config user.email t@f.t && git -C "$D" config user.name T
git -C "$D" add -A
# ONE run, one capture: the earlier form ran the guard twice and the second run reported the
# tree as absent, which is a test lying rather than a guard failing — the shape this whole
# suite exists to catch.
dayone=$(cd "$D" && bash _ops/scripts/preflight.sh 2>&1); rc=$?
[ "$rc" -eq 0 ] && ok || bad "a day one built exactly as starting.md prescribes could not commit (exit $rc)"
printf '%s' "$dayone" | grep -q "Deferred on purpose" \
  && ok || bad "the deferred documents vanished from the guard's output entirely"
rm -rf "$D"

# Scale, by SIZE and not only by file count — the form that was missing. `grep -q` exits on its
# first match and SIGPIPEs its producer; past the 64 KiB pipe buffer the pipeline returns 141 and
# the condition reads it as "no match". Measured: a credential gate blind to an AWS key on line 1
# of a 200 000-line file, and §14 passing a hand-flipped stage once the task's own diff grew.
python3 -c "
import pathlib
pathlib.Path('.env').write_text('AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE' + chr(10) +
  chr(10).join('line %d padding padding padding' % i for i in range(200000)))"
git add -A
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -qi "credential" \
  && ok || bad "a key on line 1 of a 200k-line file was invisible to the credential gate"
rm -f .env; git add -A

# §14 reads a CHANGED status, so the task must already exist and then be hand-flipped
printf '# T-9\n\n**Status**: started\n**Assignee**: worker-a\n\n## History\n' > _ops/tasks/T-9.md
git add -A && git commit -qm "T-9 exists"
python3 -c "
import pathlib
pathlib.Path('_ops/tasks/T-9.md').write_text('# T-9' + chr(10)*2 + '**Status**: done' + chr(10) +
  '**Assignee**: worker-a' + chr(10)*2 + '## History' + chr(10) +
  chr(10).join('- log %d padding padding padding' % i for i in range(100000)))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a hand-flipped stage passed §14 once the task's diff exceeded the pipe buffer" || ok
git rm -qf _ops/tasks/T-9.md >/dev/null 2>&1; git commit -qm "T-9 out"

# Scale. Measured 2026-08-14: at ~3000 staged files the generated-asset gate stopped refusing
# entirely — `git diff --cached --name-only | grep -qx` SIGPIPEs its producer once grep exits
# early, `set -o pipefail` returns 141, and the condition reads it as "no match". Two gates
# failed OPEN this way on any real codebase, and one began refusing a parent that was fine.
assets 'hero.png | origin: generated, Ideogram | owned | header'
small=$(bash _ops/scripts/preflight.sh 2>&1 | grep -c "✗")
mkdir -p filler
python3 -c "
import pathlib
for i in range(3000): pathlib.Path('filler/f%d.txt' % i).write_text('x' + chr(10))"
git add -A
big=$(bash _ops/scripts/preflight.sh 2>&1 | grep -c "✗")
[ "$small" -gt 0 ] && [ "$big" -ge "$small" ] \
  && ok || bad "the asset gate refused $small time(s) at 6 files and $big at 3000 — it fails open at scale"
rm -rf filler; rm -f _ops/assets.md; git add -A

# The class this suite was blind to: every assertion above sends stderr to /dev/null, so the
# guard shipped for a day printing two shell errors on every commit in every project — an
# orphaned heredoc body left behind by a rewrite, word-split and glob-expanded into command
# position. The exit code never moved. Both paths are asserted now, clean and refusing.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
err=$(bash _ops/scripts/preflight.sh 2>&1 >/dev/null)
[ -z "$err" ] && ok || bad "the guard writes to stderr on a clean run: $(printf '%s' "$err" | head -1)"
printf '# Decisions\n' > _ops/DECISIONS.md; git add -A
err=$(bash _ops/scripts/preflight.sh 2>&1 >/dev/null)
[ -z "$err" ] && ok || bad "the guard writes to stderr while refusing: $(printf '%s' "$err" | head -1)"
git checkout -q HEAD -- _ops/DECISIONS.md; git reset -q; git checkout -q _ops/DECISIONS.md

# §10 — nobody edits the bar they are measured against. The suite had no case for this check
# at all, and the check could not see the edit: the bar is a list of bullets under `## Done
# when`, so rewriting it changes lines containing none of the words the regex looked for.
# Measured through the door — a task reaching `done` with its acceptance criterion relaxed in
# the same commit passed. It compares the section against HEAD now.
mkdir -p _ops/process/types && printf 'started -> done\n' > _ops/process/types/default.md
printf '# T-8 — a thing\n\n**Status**: started\n**Assignee**: bob\n\n## Done when\n\n- the strict bar\n\n## History\n' > _ops/tasks/T-8.md
git add -A && git commit -qm "T-8 exists"

python3 "$HERE/transition.py" _ops/tasks/T-8.md done --by alice >/dev/null 2>&1
python3 -c "
import pathlib
p=pathlib.Path('_ops/tasks/T-8.md'); p.write_text(p.read_text().replace('- the strict bar','- a much weaker bar'))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a task reached done with its own bar relaxed in the same commit" || ok
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q "own bar" \
  && ok || bad "the bar refusal does not name what it caught"

# the twin: an honest close, bar untouched, must pass
git checkout -q HEAD -- _ops/tasks/T-8.md; git reset -q; git checkout -q _ops/tasks/T-8.md
python3 "$HERE/transition.py" _ops/tasks/T-8.md done --by alice >/dev/null 2>&1
printf -- '- 2026-08-15 — reviewed by carol: checked against the bar\n' >> _ops/tasks/T-8.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "an honest close with the bar untouched was refused"

# and editing the bar while NOT terminal is ordinary work
git checkout -q HEAD -- _ops/tasks/T-8.md; git reset -q; git checkout -q _ops/tasks/T-8.md
python3 -c "
import pathlib
p=pathlib.Path('_ops/tasks/T-8.md'); p.write_text(p.read_text().replace('- the strict bar','- a sharper bar'))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "sharpening the bar mid-flight was refused"
git rm -qf _ops/tasks/T-8.md >/dev/null 2>&1; git commit -qm "T-8 out"

# §12 — the spend cap fired only on the pre-0.2.0 flat layout. Its trigger glob listed
# `runs?/` and `docs/BUDGET.md` and neither `_ops/runs/` nor `_ops/BUDGET.md`, so the two
# commits that most literally record spend were silent in the layout this skill migrates into.
cat > _ops/BUDGET.md <<'BUD'
# Budget

- **Amount**: 100
- **Pause spend at**: 80

| Date | Spent | Note |
|---|---|---|
| 2026-08-15 | 95 | the month so far |
BUD
mkdir -p _ops/runs && git add -A && git commit -qm "budget past the cap"
printf '# R-9\n\ninput: 100\n' > _ops/runs/R-9.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a run recorded past the cap passed — the glob watched the flat layout" || ok
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q "envelope" \
  && ok || bad "the cap refusal does not say what it read"
git rm -qf _ops/runs/R-9.md _ops/BUDGET.md >/dev/null 2>&1; git commit -qm "budget out"

# A ladder is checked at the commit that writes it — the person who can fix it is standing
# there. One character in `terminal:` disarms acceptance for the whole pipeline.
mkdir -p _ops/pipelines
printf '# bent\n\n```yaml\nname: bent\nstages: [draft, review, handoff]\nterminal: [handof]\n```\n' > _ops/pipelines/bent.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a malformed ladder was committed — acceptance is disarmed and nothing said so" || ok
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q "malformed ladder" \
  && ok || bad "the ladder refusal does not name the file"
printf '# bent\n\n```yaml\nname: bent\nstages: [draft, review, handoff]\nterminal: [handoff]\n```\n' > _ops/pipelines/bent.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "a sound ladder was refused"
git rm -qf _ops/pipelines/bent.md >/dev/null 2>&1; git commit -qm "ladder out"

# A run record carries its numbers or it is a sentence wearing the word. The guide calls it a
# door — "a dispatch lands as _ops/runs/R-<id>.md carrying its four token numbers" — and nothing
# read one. `attempt` is in the required set because "three attempts and it escalates" claimed
# enforced_by: validator with no field anywhere to count.
mkdir -p _ops/runs
printf '# R-5\n\nThe run went fine and cost about 200k tokens.\n' > _ops/runs/R-5.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a sentence passed as a run record" || ok
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q "four token numbers" \
  && ok || bad "the run-record refusal does not say what is missing"
cat > _ops/runs/R-5.md <<'RUN'
# R-5

| **Outcome** | completed |
| **Attempt** | 1 |
| **Model that answered** | claude-sonnet-5 |

| `input` | `output` | `cache_read` | `cache_write` |
|---|---|---|---|
| 12,400 | 3,110 | unknown | 6,200 |
RUN
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "a real record with an unknown was refused — unknown is an accepted value"
# and the third attempt is counted, which is what the rule needed all along
python3 -c "
import pathlib
p=pathlib.Path('_ops/runs/R-5.md'); p.write_text(p.read_text().replace('| **Attempt** | 1 |','| **Attempt** | 3 |'))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a third attempt with no escalation named passed" || ok
python3 -c "
import pathlib
p=pathlib.Path('_ops/runs/R-5.md')
p.write_text(p.read_text().replace('| **Attempt** | 3 |', '| **Attempt** | 3 |' + chr(10) + chr(10) + '**Escalated**: raised with the owner — the spec does not say which reading is meant.'))"
# the field on its own line, which is what the refusal prints. It used to be a table CELL, and a
# cell satisfied the old keyword hunt — the same looseness that let "not a spec problem" through.
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "a third attempt that names its escalation was refused"
git rm -qf _ops/runs/R-5.md >/dev/null 2>&1; git commit -qm "R-5 out" >/dev/null 2>&1

# ── the neighbour table is built ONCE, and the guard names the table it guards ───────────────
# **Correctness cannot see this.** A memo guarded on a variable nothing assigns rebuilds the table
# per changed record and every assertion stays green — measured 2026-08-29, four builds for four
# records, 16s against 150 kept ones, against a comment in the same file saying that exact cost
# was removed in 2026-08-16. So the assertion is structural: the variable in the `if [ -z ... ]`
# must be the one the body assigns.
_guardvar=$(sed -n 's/^[[:space:]]*if \[ -z "\${\([_a-z]*\):-}" \]; then/\1/p' \
  "$HERE/../templates/company-preflight.sh" | head -1)
# the assignment INSIDE that guard, not the first mktemp in the file — the first draft of this
# check read `tmp_l` from an unrelated section 300 lines earlier and failed on a correct guard.
_assignvar=$(awk '/^[[:space:]]*if \[ -z "\$\{[_a-z]*:-\}" \]; then/{f=1}
                  f && /^[[:space:]]*[_a-z]+=\$\(mktemp\)/{
                    sub(/^[[:space:]]*/,""); sub(/=.*/,""); print; exit }' \
  "$HERE/../templates/company-preflight.sh")
[ -n "$_guardvar" ] && [ -n "$_assignvar" ] \
  && ok || bad "neither the memo guard nor its assignment could be lifted out of the guard — this check is vacuous"
[ "$_guardvar" = "$_assignvar" ] \
  && ok || bad "the neighbour-table memo tests \`$_guardvar\` and assigns \`$_assignvar\` — the table is rebuilt once per changed record and no assertion can see it"

# ── §7 and §8 read the form the TEMPLATE writes, not only the YAML ──────────────────────────
# **Reported from a live migration, 2026-09-05, and reproduced here.** `templates/ROLE-template.md`
# writes `**Type**: advisor · **Grade**: senior` and a `## Skills attached` table; it contains no
# `type:` line and no `skills:` list. Both checks parsed YAML only, so a role written from the
# shipped template was invisible to them: two declared advisors, one found; nineteen skills, zero
# counted. **This pair had already been repaired once** — the directory was fixed in August while
# the format mismatch survived — which is why the assertions below are a must-fire/must-not-fire
# pair on BOTH forms rather than one happy path.
_role_tpl(){ { printf '# %s — the craft\n\n**Type**: %s · **Grade**: senior\n\n' "$1" "$2"
  printf '## Skills attached\n\n| Skill | Why this role needs it |\n|---|---|\n'
  i=1; while [ "$i" -le "${3:-0}" ]; do printf '| skill-%s | because |\n' "$i"; i=$((i+1)); done
  printf '\n## Trust\n'; } > "_ops/roles/$1.md"; }
_role_yml(){ { printf -- '---\ntype: %s\nskills:\n' "$2"
  i=1; while [ "$i" -le "${3:-0}" ]; do printf -- '  - skill-%s\n' "$i"; i=$((i+1)); done
  printf -- '---\n\n# %s\n' "$1"; } > "_ops/roles/$1.md"; }
_roleout(){ ( bash _ops/scripts/preflight.sh 2>&1 || true ); }
mkdir -p _ops/roles

# §7 · one advisor in the template's own form is fine; two are not.
_role_tpl Solo advisor 0; git add -A
_roleout | grep -q 'advisors — exactly one' \
  && bad "one advisor was refused as several" || ok
_role_tpl Second advisor 0; git add -A
_roleout | grep -q 'advisors — exactly one' \
  && ok || bad "two advisors written in the template's own form were invisible to §7 — the template writes no \`type:\` line at all"
# and the two forms are counted as one population, not two
rm -f _ops/roles/Second.md; _role_yml Legacy advisor 0; git add -A
_roleout | grep -q 'advisors — exactly one' \
  && ok || bad "a template-form advisor and a YAML-form advisor were not counted together"
# **An UNFILLED template is not an advisor.** Its placeholder lists every type, `advisor` among
# them, so a substring match would have counted the shipped template itself.
rm -f _ops/roles/Legacy.md
cp "$HERE/../templates/ROLE-template.md" _ops/roles/Unfilled.md; git add -A
_roleout | grep -q 'advisors — exactly one' \
  && bad "the unfilled ROLE-template placeholder counted as a second advisor" || ok
rm -f _ops/roles/Unfilled.md _ops/roles/Solo.md; git add -A

# §8 · the same count from either form, and the YAML off-by-one that proved nobody had measured it
_role_tpl Wide worker 19; git add -A
_roleout | grep -q 'Wide carries 19 skills' \
  && ok || bad "a template-form role with 19 skills in its table was counted as none by §8"
rm -f _ops/roles/Wide.md; _role_yml Old worker 19; git add -A
_roleout | grep -q 'Old carries 19 skills' \
  && ok || bad "the YAML counter is off — the frontmatter's closing --- was counted as a skill (it read 20 of 19)"
# and under the threshold nothing is said, in either form
# **An unfilled `{{name}}` row is not a skill**, and until this fixture nothing proved it: the
# only `{{…}}` role in the suite was the template itself, whose table has one placeholder row —
# 1 against 0, both under the bar, so deleting the skip changed no outcome. Seven real rows plus
# the template's own placeholder is the pair that separates them: 7 silent, 8 warns.
rm -f _ops/roles/Old.md; _role_tpl Ph worker 7
python3 -c "
import pathlib
p = pathlib.Path('_ops/roles/Ph.md')
p.write_text(p.read_text().replace('## Trust', '| {{name}} | {{the step it covers}} |' + chr(10) + chr(10) + '## Trust'))"
git add -A
_roleout | grep -q 'Ph carries' \
  && bad "an unfilled {{…}} row was counted as a skill — seven real rows plus the template's own placeholder crossed the bar" || ok
rm -f _ops/roles/Ph.md; _role_tpl Small worker 7; git add -A
_roleout | grep -q 'Small carries' \
  && bad "a role with 7 skills warned — the threshold is eight" || ok
rm -f _ops/roles/Small.md; git add -A

# ── §11 reads the word the TASK template writes, in the shape it writes it ──────────────────
# **The check that stops an agent approving its own work never fired on this project's own
# format.** It read the author as `^(assigned|author|worker)[: ]` — a bare word at line start —
# while `templates/TASK-template.md` writes `**Assignee**: …`: bold, and a different word. The
# author therefore came back empty on every task written the way this project tells people to
# write one, and the comparison could not be true. Measured 2026-09-05: **0 on the template's
# form, 1 on `assigned: ui`.** Third instance of the class in one sweep, after §7 and §8.
mkdir -p _ops/tasks
_selfsign(){ printf '# T-%s — a thing\n\n**Status**: in review\n%s\n\n## History\n' "$1" "$2" > "_ops/tasks/T-$1.md"
  git add -A; git commit -qm "task $1" >/dev/null 2>&1
  printf -- '- 2026-09-05 — **reviewed by %s** · checked\n' "$3" >> "_ops/tasks/T-$1.md"; git add -A; }
_selfsign SIGN01 '**Assignee**: ui' ui
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a task written from the template — \`**Assignee**\`, in bold — was signed off by its own author and §11 said nothing" || ok
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q 'signed off by' \
  && ok || bad "§11 refused for some other reason than the self-signoff"
# an honest review by someone else must still pass — a check that refuses everything proves nothing
git checkout -q HEAD -- _ops/tasks/T-SIGN01.md
printf -- '- 2026-09-05 — **reviewed by qa** · checked\n' >> _ops/tasks/T-SIGN01.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a review by someone who did NOT do the work was refused"
# and the legacy shape keeps working
git rm -qf _ops/tasks/T-SIGN01.md >/dev/null 2>&1; git commit -qm "sign01 out" >/dev/null 2>&1
_selfsign SIGN02 'assigned: ui' ui
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "the legacy \`assigned:\` shape stopped being read" || ok
git rm -qf _ops/tasks/T-SIGN02.md >/dev/null 2>&1; git commit -qm "sign02 out" >/dev/null 2>&1

# ── what the repair itself broke, and the half of §11 it left alone ─────────────────────────
# **An adversarial lens ran on the repair the day it was written and found three false refusals
# and one surviving evasion — all four in the lines that had just been edited.** Widening §7 to
# the template's prose form made a recursive search hit things that are not roles; teaching §8 to
# read a table made it miscount two ordinary tables; and §11's author half was taught bold and
# backticks while its reviewer half — the other side of the same comparison — was not.
_role_at(){ mkdir -p "$(dirname "_ops/roles/$1")"; printf '# %s\n\n**Type**: %s\n' "$(basename "$1" .md)" "$2" > "_ops/roles/$1"; }

# §7 · a README documenting the form, and an archive holding a retired role, are not advisors
_role_tpl OneAdv advisor 0
printf '# How to write a role\n\nExample: **Type**: advisor · **Grade**: senior\n' > _ops/roles/README.md
_role_at archive/old.md advisor
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a README documenting the form, or an archived role, was counted as a second advisor — §7 recursed where §8 has always iterated \`*.md\`"
rm -rf _ops/roles/README.md _ops/roles/archive _ops/roles/OneAdv.md; git add -A

# §8 · the header is the first row whatever it is called, and a table ends at any heading
{ printf '# Bold — c\n\n**Type**: worker\n\n## Skills attached\n\n| **Skill** | **Why** |\n|---|---|\n'
  i=1; while [ "$i" -le 7 ]; do printf '| s-%s | because |\n' "$i"; i=$((i+1)); done; } > _ops/roles/Bold.md
git add -A
_roleout | grep -q 'Bold carries' \
  && bad "a BOLDED header row was counted as a skill — seven real rows warned at a bar of eight" || ok
rm -f _ops/roles/Bold.md
{ printf '# Two — d\n\n**Type**: worker\n\n## Skills attached\n\n| Skill | Why |\n|---|---|\n| a | x |\n| b | x |\n| c | x |\n\n### Escalation\n\n| To | When |\n|---|---|\n'
  i=1; while [ "$i" -le 6 ]; do printf '| r-%s | when |\n' "$i"; i=$((i+1)); done; } > _ops/roles/Two.md
git add -A
_roleout | grep -q 'Two carries' \
  && bad "a second table under a \`###\` heading was counted into the skills — three skills warned as ten" || ok
rm -f _ops/roles/Two.md; git add -A

# §11 · the reviewer half, and a comparison that was case-sensitive on two -i greps
_selfsign SIGN03 '**Assignee**: ui' 'x'
python3 -c "
import pathlib
p = pathlib.Path('_ops/tasks/T-SIGN03.md')
p.write_text(p.read_text().replace('**reviewed by x**', '**Reviewed by**: ui'))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "\`**Reviewed by**: ui\` extracted no reviewer — the author half was taught bold and this half was not" || ok
git rm -qf _ops/tasks/T-SIGN03.md >/dev/null 2>&1; git commit -qm "sign03 out" >/dev/null 2>&1
_selfsign SIGN04 '**Assignee**: ui' 'UI'
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "\`UI\` reviewed \`ui\` and passed — both greps are -i and the comparison was not" || ok
git rm -qf _ops/tasks/T-SIGN04.md >/dev/null 2>&1; git commit -qm "sign04 out" >/dev/null 2>&1

# ── the contradiction stop: two runs, one question, opposite answers ─────────────────────────
# **Three attempts bound FAILURE; nothing bounded CONTRADICTION** — the worse state, because both
# runs end `completed` and each reports confidently. `escalating.md` has carried the rule as prose
# since 2026-08-21 and `LATER.md` named the missing half: a record could say how a run ENDED and
# not what it CONCLUDED. These fixtures are the twin/mutant pair that entry specified.
mkdir -p _ops/runs
_vrun(){ python3 - "$1" "$2" "$3" "$4" "${5:-T-VERDICT}" > "_ops/runs/$1.md" <<'VPY'
import sys
rid, outcome, verdict, extra, task = sys.argv[1:6]
print("# %s\n" % rid)
print("| | |")
print("|---|---|")
print("| **Task** | %s · does the migration hold |" % task)
print("| **Outcome** | %s |" % outcome)
print("| **Verdict** | %s — does the migration hold |" % verdict)
print("| **Attempt** | 1 |")
print("| **Model that answered** | claude-sonnet-5 |")
print("")
if extra and extra != "-":
    print(extra)
    print("")
print("| `input` | `output` | `cache_read` | `cache_write` |")
print("|---|---|---|---|")
print("| 100 | 20 | unknown | unknown |")
VPY
  git add -A; }

_vrun R-V1 completed pass -
git commit -qm "first verdict on T-VERDICT" >/dev/null 2>&1
# **A second run that AGREES is ordinary work and must pass.** A gate that fires on agreement
# would make every task with two runs unshippable, which is how a project learns --no-verify.
_vrun R-V2 completed pass -
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "two runs agreeing on one question were refused — only a clash is a finding"
# **The mutant: the same pair, flipped, with nothing recording that anyone noticed.**
_vrun R-V2 completed fail -
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a second run concluding the OPPOSITE of the first passed, with no escalation anywhere — this is the contradiction the ledger was blind to" || ok
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q 'the question is unstable' \
  && ok || bad "the refusal does not print the line to write — a gate that names no repair is one people satisfy by deleting the field"
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q 'which run was right' \
  && ok || bad "the refusal does not say what it is NOT: arbitration produces a winner rather than a resolution"
# **The twin: the same clash, with the escalation recorded.** A disagreement is not the failure;
# an unnoticed one is.
_vrun R-V2 completed fail '**Escalated**: the question is unstable — the two runs read different working trees.'
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a recorded disagreement that names its escalation was still refused"
# and the escalation on the OTHER record satisfies it too — whoever noticed, noticed
_vrun R-V2 completed fail -
python3 -c "
import pathlib
p = pathlib.Path('_ops/runs/R-V1.md')
p.write_text(p.read_text() + chr(10) + '**Escalated**: raised with the advisor — the two runs disagree.' + chr(10))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "the escalation was recorded on the FIRST record and the second was refused anyway"
# **`git checkout -- <f>` restores from the INDEX, and the index holds the escalation just
# added** — so R-V1 kept it, and the two assertions below then passed because a leftover
# escalation satisfied the gate, not because their own fixtures did. Caught 2026-08-28 by the
# one assertion that expected a REFUSAL; the two expecting a pass had been green and vacuous.
# This file already carries the same lesson about `git checkout -- .` sixty lines up.
git checkout -q HEAD -- _ops/runs/R-V1.md 2>/dev/null; git add -A
# **`none` conflicts with nothing.** Most runs check nothing, and taxing them would be the shape
# this corpus refuses — a field added for a gate's sake.
_vrun R-V2 completed none -
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a run that concluded nothing was treated as a clash"
# **An UNFILLED cell must not read as a verdict, and a HALF-filled one must.** The template ships
# `{{pass · fail · mixed · none}}`, so a record nobody touched has to yield nothing — while
# `pass — {{what it concluded}}`, where the verdict IS reached and only the sentence beside it is
# a placeholder, has to yield `pass`. Both directions are asserted so neither can drift.
_vrun R-V2 completed '{{pass · fail · mixed · none}}' -
python3 -c "
import pathlib
p = pathlib.Path('_ops/runs/R-V1.md')
p.write_text(p.read_text().replace('| **Verdict** | pass —', '| **Verdict** | fail —'))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "an unfilled {{…}} verdict cell was read as \`pass\` and clashed with a real \`fail\`"
# the other direction: verdict reached, explanation still a placeholder — this IS a verdict
_vrun R-V2 completed 'pass' -
python3 -c "
import pathlib
p = pathlib.Path('_ops/runs/R-V2.md')
p.write_text(p.read_text().replace('pass — does the migration hold', 'pass — {{what it concluded}}'))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a half-filled cell — verdict reached, sentence still a placeholder — was read as no verdict at all, so it did not clash with the opposite one" || ok
git checkout -q HEAD -- _ops/runs/R-V1.md 2>/dev/null; git add -A
# **Only two COMPLETED runs contradict.** A run that was interrupted did not conclude anything.
_vrun R-V2 interrupted fail -
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "an interrupted run was compared as a conclusion — it did not reach one"

# **The two conditions above test the NEW record; these test the SIBLING side of the filter.**
# A mutant that dropped `completed` and the pass/fail test from the awk comparison passed the
# whole suite on 2026-08-28, because every "must not clash" fixture put the excused value on the
# new record — where a separate entry condition already stopped it. An over-greedy gate was
# invisible. Here the new record is a legitimate `completed` + `fail`, and it is the OTHER one
# that concluded nothing or never finished.
_vrun R-W1 interrupted pass - T-VERDICT2
git add -A; git commit -qm "an interrupted sibling" >/dev/null 2>&1
_vrun R-W2 completed fail - T-VERDICT2
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a run clashed with an INTERRUPTED sibling — that run never reached a conclusion to disagree with"
git rm -qf _ops/runs/R-W1.md _ops/runs/R-W2.md >/dev/null 2>&1
_vrun R-W3 completed none - T-VERDICT2
git add -A; git commit -qm "a sibling that concluded nothing" >/dev/null 2>&1
# **A FRESH id, and this is not a detail.** The first draft reused R-W2, which the commit above
# had already taken — so §1f, which examines only ADDED records, never looked at it and the
# assertion passed on every mutant put to it. Caught 2026-08-28 by mutating the gate to treat
# `none` as an opposite and watching the suite stay green.
_vrun R-W4 completed fail - T-VERDICT2
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a run clashed with a sibling whose verdict was \`none\` — nothing is not the opposite of something"
# and the proof that the record above was examined at all: the same fixture, sibling flipped to
# the opposite verdict, must be refused. Without this pair the assertion cannot tell "did not
# clash" from "was never read".
python3 -c "
import pathlib
p = pathlib.Path('_ops/runs/R-W3.md')
p.write_text(p.read_text().replace('| **Verdict** | none —', '| **Verdict** | pass —'))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "the none-sibling assertion above is vacuous — §1f is not examining that record at all" || ok
git rm -qf _ops/runs/R-W4.md _ops/runs/R-W3.md >/dev/null 2>&1
git commit -qm "W3/W4 out" >/dev/null 2>&1
# **`mixed` is excused deliberately, and a deliberate excusal nothing tests is indistinguishable
# from an oversight.** A deletion lens found it shipped as a legal value with no code path and no
# fixture — behaviourally identical to `none`, to `unknown` and to a typo, which by this project's
# own capability bar is the toothless shape this release is about. It stays a value because a
# reviewer genuinely concludes it. **On the SIBLING side**, like the two above: the first version
# of this assertion put `mixed` on the new record, where a separate entry condition already stops
# it, and the mutant that treats `mixed` as an opposite sailed past.
_vrun R-W5 completed mixed - T-VERDICT3
git add -A; git commit -qm "a sibling that concluded mixed" >/dev/null 2>&1
_vrun R-W6 completed fail - T-VERDICT3
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a run clashed with a sibling whose verdict was \`mixed\` — partly-both is not the opposite of anything"
python3 -c "
import pathlib
p = pathlib.Path('_ops/runs/R-W5.md')
p.write_text(p.read_text().replace('| **Verdict** | mixed —', '| **Verdict** | pass —'))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "the mixed-sibling assertion above is vacuous — §1f is not examining that record at all" || ok
git rm -qf _ops/runs/R-W5.md _ops/runs/R-W6.md >/dev/null 2>&1
git commit -qm "W fixtures out" >/dev/null 2>&1
# **House style must not switch the gate off.** This corpus writes every enum value in backticks
# — `escalating.md`, `dispatching.md` and this template's own neighbouring cells all do — so a
# record following house style wrote `fail` and §1f went silent. Measured 2026-08-29 through
# the real guard: refused when bare, PASSED when either side was backticked or bolded, with every
# fixture in this suite writing the cell the one bare way that worked. A false refusal teaches
# --no-verify; a false silence teaches nothing at all.
# the backtick is built from its ordinal: written literally it sits inside `python3 -c "…"`,
# a DOUBLE-quoted shell string, and the shell substitutes it away before python sees it — the
# replacement then silently becomes empty and both assertions below fail for the wrong reason.
_vrun R-B1 completed fail - T-VERDICT4
python3 -c "
import pathlib
p = pathlib.Path('_ops/runs/R-B1.md')
b = chr(96)
p.write_text(p.read_text().replace('| **Verdict** | fail', '| **Verdict** | ' + b + 'fail' + b))"
git add -A; git commit -qm "a backticked sibling" >/dev/null 2>&1
_vrun R-B2 completed pass - T-VERDICT4
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a BACKTICKED sibling verdict was invisible to the gate — that is how this corpus writes every enum" || ok
_vrun R-B2 completed pass - T-VERDICT4
python3 -c "
import pathlib
p = pathlib.Path('_ops/runs/R-B2.md')
p.write_text(p.read_text().replace('| **Verdict** | pass', '| **Verdict** | **pass**'))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a BOLDED verdict on the new record was invisible to the gate" || ok
# and the unfilled cell must still read empty — `{` is not skipped
_vrun R-B2 completed '{{pass · fail · mixed · none}}' - T-VERDICT4
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "widening past backticks also let an unfilled {{…}} cell read as a verdict"
git rm -qf _ops/runs/R-B1.md _ops/runs/R-B2.md >/dev/null 2>&1
git commit -qm "B fixtures out" >/dev/null 2>&1
# **The line the refusal prints must not satisfy the refusal.** Pasting it whole, placeholder
# untouched, passed §1f — one non-space character after the colon was the whole test, so the gate
# handed the reader the shortest path to the thing its own attempt-gate comment condemns: *a gate
# satisfied by denying the thing it asks for is worse than an absent one*. Found by a cold-read
# lens 2026-08-29. Both directions are asserted, because a check that refuses the placeholder is
# worthless if it also refuses a real answer.
_pl=$(sed -n "s/^ESC_PLACEHOLDER='\(.*\)'$/\1/p" "$HERE/../templates/company-preflight.sh")
[ -n "$_pl" ] && ok || bad "ESC_PLACEHOLDER could not be lifted out of the guard — the two assertions below are vacuous"
_vrun R-P1 completed fail - T-VERDICT5
git add -A; git commit -qm "a verdict to contradict" >/dev/null 2>&1
_vrun R-P2 completed pass - T-VERDICT5
printf '\n**Escalated**: the question is unstable — %s\n' "$_pl" >> _ops/runs/R-P2.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "the refusal's own line, pasted with the placeholder untouched, satisfied the refusal" || ok
# **and the reader is told WHICH mistake they made.** Refusing a pasted placeholder with the
# message that asks for the line they just wrote is unfollowable in one direction — the exact
# failure this guard's attempt gate was rebuilt to stop. Measured 2026-08-29 on a reader who typed
# their answer AFTER the brackets instead of into them.
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q 'still carries the printed placeholder' \
  && ok || bad "a record whose escalation line is still the placeholder gets the message for a record that has no line at all"
_vrun R-P2 completed pass - T-VERDICT5
printf '\n**Escalated**: the question is unstable — %s and the shell differed\n' "$_pl" >> _ops/runs/R-P2.md
git add -A
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q 'still carries the printed placeholder' \
  && ok || bad "typing an answer AFTER the placeholder instead of into it gets the wrong diagnosis"
_vrun R-P2 completed pass - T-VERDICT5
printf '\n**Escalated**: the question is unstable — the two runs read different working trees\n' >> _ops/runs/R-P2.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a REAL escalation was refused — the placeholder check is refusing honest answers too"
git rm -qf _ops/runs/R-P1.md _ops/runs/R-P2.md >/dev/null 2>&1
git commit -qm "P fixtures out" >/dev/null 2>&1
# **A project whose records predate 0.2.14 keeps committing.** The entry promises this in so many
# words, so it is asserted rather than believed: two records on one task, both `completed`, with
# no `Verdict` cell at all — which is every record ever written before this release.
_vrun R-C1 completed pass - T-VERDICT6
python3 -c "
import pathlib, re
p = pathlib.Path('_ops/runs/R-C1.md')
p.write_text(re.sub(r'^.*Verdict.*$', '', p.read_text(), flags=re.M))"
git add -A; git commit -qm "a pre-0.2.14 record" >/dev/null 2>&1
_vrun R-C2 completed fail - T-VERDICT6
python3 -c "
import pathlib, re
p = pathlib.Path('_ops/runs/R-C2.md')
p.write_text(re.sub(r'^.*Verdict.*$', '', p.read_text(), flags=re.M))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "records written before the Verdict field existed are refused — the entry promises they are not"
git rm -qf _ops/runs/R-C1.md _ops/runs/R-C2.md >/dev/null 2>&1
git commit -qm "C fixtures out" >/dev/null 2>&1
# ── four evasions and one false refusal, adversarial 2026-08-29 ─────────────────────────────
# **A record written in the LINE form satisfied every other check in §1f and was invisible to
# this one.** Every other field test in that section is `hits -iF`; `record_task` was widened for
# exactly this on 2026-08-21 with the note that *the rigid reader in a loose section is the reader
# that silently counts zero*; `verdict_of` was written last week and was not widened.
_lrun(){ { printf '# %s\n\n**Task**: %s\n**Outcome**: %s\n**Verdict**: %s — q\n\n' "$1" "$4" "$2" "$3"
  printf '| **Attempt** | 1 |\n| **Model that answered** | m |\n\n'
  printf '| `input` | `output` | `cache_read` | `cache_write` |\n|---|---|---|---|\n| 1 | 1 | unknown | unknown |\n'
  } > "_ops/runs/$1.md"; git add -A; }
_vrun R-E1 completed fail - T-EVADE
git add -A; git commit -qm "a sibling to contradict" >/dev/null 2>&1
_lrun R-E2 completed pass T-EVADE
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a record declaring Task/Outcome/Verdict as LINES satisfied every other check and was invisible to this one" || ok
# **One verdict per record.** Two rows and only the first is read, so which one the record
# concluded is not decidable — measured, `none` above `pass` hid a real contradiction while the
# reverse order was refused, which is the direction that matters.
{ printf '# R-E3\n\n| | |\n|---|---|\n| **Task** | T-EVADE |\n| **Outcome** | completed |\n'
  printf '| **Verdict** | none — q |\n| **Verdict** | pass — q |\n| **Attempt** | 1 |\n'
  printf '| **Model that answered** | m |\n\n| `input` | `output` | `cache_read` | `cache_write` |\n|---|---|---|---|\n| 1 | 1 | unknown | unknown |\n'
} > _ops/runs/R-E3.md; rm -f _ops/runs/R-E2.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a record declaring Verdict twice passed — only the first is read, so the record does not say what it concluded" || ok
# **A word that is not one of the four is refused, not excused.** `failed` is a legal *Outcome*
# two rows above the Verdict cell, so the confusion is the record's own invitation.
rm -f _ops/runs/R-E3.md; _vrun R-E4 completed passed - T-EVADE
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "\`passed\` was read as no verdict and compared with nothing, silently" || ok
git rm -qf _ops/runs/R-E1.md >/dev/null 2>&1; rm -f _ops/runs/R-E4.md; git add -A
git commit -qm "E fixtures out" >/dev/null 2>&1
# **And the false refusal the same reader caused.** `record_task` matches `T-[0-9A-Za-z-]+`, so
# `T-A.1` and `T-A.2` both read `T-A`: two records on genuinely different tasks were refused as
# one contradiction, naming a task id present in neither file — this file's own condemned failure
# mode, *a number that appears nowhere*, arriving through the id reader.
_vrun R-F1 completed pass - T-A.1
git add -A; git commit -qm "a punctuated id" >/dev/null 2>&1
_vrun R-F2 completed fail - T-A.2
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "two records on DIFFERENT tasks whose ids share a prefix before punctuation were refused as a contradiction"
git rm -qf _ops/runs/R-F1.md _ops/runs/R-F2.md >/dev/null 2>&1
git commit -qm "F fixtures out" >/dev/null 2>&1
# **A quoted example is not a declaration.** A record showing this template for reference inside a
# fence was read as concluding whatever the example says — and once one-verdict-per-record landed,
# a record with a real row AND a quoted example was refused for declaring it twice. The check
# written to close an evasion opened a false refusal within the hour; in this file's accounting
# that is the more expensive direction, so both readers skip fences.
{ printf '# R-G1\n\n| | |\n|---|---|\n| **Task** | T-FENCE |\n| **Outcome** | completed |\n'
  printf '| **Verdict** | none — q |\n| **Attempt** | 1 |\n| **Model that answered** | m |\n\n'
  printf 'For reference the template shows:\n\n```\n| **Verdict** | pass — the question |\n```\n\n'
  printf '| `input` | `output` | `cache_read` | `cache_write` |\n|---|---|---|---|\n| 1 | 1 | unknown | unknown |\n'
} > _ops/runs/R-G1.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a record quoting this template inside a fence was read as declaring a second verdict"
git rm -qf _ops/runs/R-G1.md >/dev/null 2>&1 2>/dev/null; rm -f _ops/runs/R-G1.md; git add -A
git rm -qf _ops/runs/R-V1.md _ops/runs/R-V2.md >/dev/null 2>&1
git commit -qm "verdict fixtures out" >/dev/null 2>&1

# A child link that resolves to nothing is worse than a bare id — it reads as navigable. The
# template writes children as checkbox links precisely so the board can be walked; measured on a
# live project, twelve tasks with plainly dependent work and not one link between them.
printf '# T-6\n\n**Status**: started\n\n## Children\n\n- [ ] [T-99](T-99-ghost.md) — never written\n' > _ops/tasks/T-6.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a child link to a file that does not exist passed" || ok
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q "which is not" \
  && ok || bad "the link refusal does not name the target"
printf '# T-6\n\n**Status**: started\n\n## Children\n\n- [ ] [T-1](T-1.md) — the real one\n' > _ops/tasks/T-6.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "a child link that resolves was refused"
git rm -qf _ops/tasks/T-6.md >/dev/null 2>&1; git commit -qm "T-6 out" >/dev/null 2>&1

# The gates enforce what a commit CREATES, not what a project already holds — otherwise a
# release strands its own projects over history they cannot change. And a tick is evidence, not
# an edit: the shipped template puts deliverables in `- [ ]` boxes and tells the owner to tick
# them, so without normalising the mark the documented way to close a task was refused.
mkdir -p _ops/runs _ops/process/types && printf 'started -> review -> done\n' > _ops/process/types/default.md
cp "$HERE/../templates/TASK-template.md" _ops/tasks/T-tpl.md
printf '# R-old\n\n| **Outcome** | completed |\n' > _ops/runs/R-old.md
git add -A && git commit -qm "the template as a task, and a legacy record"
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "the shipped TASK-template cannot be committed through the shipped guard"
printf -- '\n- a later note\n' >> _ops/runs/R-old.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "touching a pre-0.2.7 run record was refused — the project is stranded"
printf '# R-new\n\nnothing at all\n' > _ops/runs/R-new.md; git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a NEW record with no numbers passed" || ok
git rm -qf --cached _ops/runs/R-new.md >/dev/null 2>&1; rm -f _ops/runs/R-new.md

printf '# T-close\n\n**Status**: started\n**Assignee**: bob\n\n## Done when\n\n- [ ] the deliverable\n\n## History\n' > _ops/tasks/T-close.md
git add -A && git commit -qm "a task to close"
python3 "$HERE/transition.py" _ops/tasks/T-close.md review --by bob >/dev/null 2>&1
python3 -c "
import pathlib
p=pathlib.Path('_ops/tasks/T-close.md'); p.write_text(p.read_text().replace('- [ ] the deliverable','- [x] the deliverable'))"
printf -- '- reviewed by carol\n' >> _ops/tasks/T-close.md
python3 "$HERE/transition.py" _ops/tasks/T-close.md done --by carol >/dev/null 2>&1
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "ticking a deliverable and closing was refused as editing the bar"
git checkout -q HEAD -- . ; git reset -q
python3 "$HERE/transition.py" _ops/tasks/T-close.md review --by bob >/dev/null 2>&1
python3 -c "
import pathlib
p=pathlib.Path('_ops/tasks/T-close.md'); p.write_text(p.read_text().replace('- [ ] the deliverable','- [ ] something much easier'))"
printf -- '- reviewed by carol\n' >> _ops/tasks/T-close.md
python3 "$HERE/transition.py" _ops/tasks/T-close.md done --by carol >/dev/null 2>&1
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "rewriting the criterion while closing passed" || ok
git checkout -q HEAD -- .; git reset -q
git rm -qf _ops/tasks/T-tpl.md _ops/tasks/T-close.md _ops/runs/R-old.md >/dev/null 2>&1
git commit -qm "fixtures out" >/dev/null 2>&1

# ── a task that closes must say what it cost ───────────────────────────────────────────────
# `cost.md` stores cost once, at the run, and derives every other number from it. Nothing checked
# the atom existed: measured 2026-08-15, a task taken started → review → done THROUGH the door with
# zero run records anywhere drew no refusal and no warning, so a feature's total, the budget burn
# and the trend the owner is told all rested on records nobody was asked for. Observed first on a
# live project whose board carried finished work and no cost at all. A WARNING, because a task done
# by a person legitimately has no run — so the pair is: warned without a record, silent with one.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
mkdir -p _ops/process/types _ops/runs
printf 'started -> review -> done\n' > _ops/process/types/default.md
printf '# T-COST — a real job\n\n**Status**: started\n**Assignee**: ui\n\n## Done when\n\n- [ ] the thing exists\n\n## History\n' > _ops/tasks/T-COST.md
git add -A && git commit -qm "cost fixture" >/dev/null 2>&1
close_it(){
  python3 "$HERE/transition.py" _ops/tasks/T-COST.md review --by ui >/dev/null 2>&1
  printf -- '- reviewed by qa\n' >> _ops/tasks/T-COST.md
  python3 -c "
import pathlib
p = pathlib.Path('_ops/tasks/T-COST.md')
p.write_text(p.read_text().replace('- [ ] the thing exists', '- [x] the thing exists'))"
  python3 "$HERE/transition.py" _ops/tasks/T-COST.md done --by qa >/dev/null 2>&1
  git add -A
}
close_it
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q "no run record names T-COST" \
  && ok || bad "a task closed with no run record anywhere and nothing said what it cost"
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '# R-C1 — the job\n\n| **Task** | T-COST · a real job |\n| **Attempt** | 1 |\n| **Model that answered** | sonnet |\n| **Outcome** | completed |\n\n| input | output | cache_read | cache_write |\n|---|---|---|---|\n| 12000 | 3100 | 188900 | 6200 |\n' > _ops/runs/R-C1.md
git add -A && git commit -qm "the record" >/dev/null 2>&1
close_it
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q "no run record names T-COST" \
  && bad "a task with a run record naming it was still warned about its cost" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q
git rm -qf _ops/tasks/T-COST.md _ops/runs/R-C1.md >/dev/null 2>&1
git commit -qm "cost fixture out" >/dev/null 2>&1

# ── a move added to the map names the job it is hired for ──────────────────────────────────
# New in 0.2.9. A move is a route someone takes; the job is what they were trying to get done when
# they took it. Without it the map answers how the product is walked and never why anyone walks
# it, and a roadmap reading that map proposes routes nobody asked for. Enforced on what the commit
# CREATES — a move already on the map is left alone, because retro-filling is a project's decision.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
mkdir -p _ops/map
printf '# Map\n\n## The moves\n' > _ops/MAP.md
git add -A && git commit -qm "map fixture" >/dev/null 2>&1
printf '\n### order to pickup\n\n\`\`\`mermaid\nflowchart LR\n  A[browse] --> B[pay]\n\`\`\`\n' >> _ops/MAP.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a move was added to the map with no job and nothing objected" || ok
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q 'job story' \
  && ok || bad "the refusal does not name the shape a job is written in"
# the twin: the same move, with its job
python3 -c "
import pathlib
p = pathlib.Path('_ops/MAP.md')
p.write_text(p.read_text().replace('### order to pickup', '### order to pickup' + chr(10) + chr(10) + '**Job**: when a parent is out of bread on a weekday morning, someone wants to reserve a loaf before work, so they can collect it without queueing.', 1))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a move carrying its job was refused"
git commit -qm "the move" >/dev/null 2>&1
# and a commit that touches the map WITHOUT adding a move is not asked
printf '\nA note about the map.\n' >> _ops/MAP.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a commit editing the map without adding a move was asked for a job"
git checkout -q HEAD -- . 2>/dev/null; git reset -q
git rm -qf _ops/MAP.md >/dev/null 2>&1
git commit -qm "map fixture out" >/dev/null 2>&1

# ── a new dependency says what it replaces ─────────────────────────────────────────────────
# New in 0.2.10, and taken from a third-party plugin's ladder rather than invented: does this need
# to exist · is it already here · standard library · native platform feature · an installed
# dependency · one line. Every rung above the last is a judgement no script can make; **whether
# the answer was written down is not**, and a new dependency is the moment it is cheapest to ask.
# Written as a form because the same ladder as prose is what this corpus measures at ~0.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '{\n  "name": "app",\n  "dependencies": {\n    "react": "^18.0.0"\n  }\n}\n' > package.json
printf '# Decisions\n\n- 2026-08-01 \xc2\xb7 we ship weekly \xc2\xb7 rhythm \xc2\xb7 owner\n' > _ops/DECISIONS.md
git add -A && git commit -qm "dep fixture" >/dev/null 2>&1
python3 -c "
import json, pathlib
p = pathlib.Path('package.json'); d = json.loads(p.read_text())
d['dependencies']['lodash'] = '^4.17.21'
p.write_text(json.dumps(d, indent=2) + chr(10))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a dependency was added with nothing said about why and nothing objected" || ok
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q 'what it replaces' \
  && ok || bad "the refusal does not say what the one line must contain"
printf -- '- 2026-08-22 retiring our own deep-clone helper: lodash does it; structuredClone rejected, it drops functions\n' >> _ops/DECISIONS.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a dependency arriving with its reason was refused"
git commit -qm "the dep" >/dev/null 2>&1
# and a commit touching the manifest WITHOUT adding a dependency is not asked
python3 -c "
import json, pathlib
p = pathlib.Path('package.json'); d = json.loads(p.read_text()); d['name'] = 'renamed'
p.write_text(json.dumps(d, indent=2) + chr(10))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "renaming the package was treated as adding a dependency"
git checkout -q HEAD -- . 2>/dev/null; git reset -q
git rm -qf package.json >/dev/null 2>&1; git commit -qm "dep fixture out" >/dev/null 2>&1

# ── the shapes §4e was blind to, and the name test's boundaries ────────────────────────────
# Its pathspec names seven manifest kinds and its extractor read two — blind to "latest", "*",
# npm:/git+ specifiers, requirements.txt bare names, go.mod require lines and Gemfile gems. Nine
# of sixteen realistic ways to add a dependency. And the name test was an unbounded substring, so
# a decision about anything containing the name as a fragment satisfied it. Measured 2026-08-23.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '{\n  "name": "app",\n  "dependencies": {}\n}\n' > package.json
printf '# Decisions\n' > _ops/DECISIONS.md
git add -A && git commit -qm "shapes fixture" >/dev/null 2>&1
_dep_case() { # <manifest-file> <line> → 1 when the gate refuses
  printf '%s' "$2" >> "$1"; git add -A
  local n; n=$( ( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -c 'says nothing about why' )
  # untracked probes are not removed by `git checkout -- .`, and a leftover go.mod fires the
  # very gate the NEXT case is measuring. Caught by the age check failing three blocks later.
  git checkout -q HEAD -- . 2>/dev/null; git reset -q
  rm -f requirements.txt go.mod Gemfile Cargo.toml pyproject.toml composer.json
  echo "$n"
}
[ "$(_dep_case package.json '{"dependencies":{"leftpad":"latest"}}')" -ge 1 ] \
  && ok || bad "a dependency pinned to \`latest\` was invisible to §4e"
[ "$(_dep_case requirements.txt 'requests>=2.31')" -ge 1 ] \
  && ok || bad "a requirements.txt dependency was invisible to §4e"
[ "$(_dep_case go.mod 'require github.com/pkg/errors v0.9.1')" -ge 1 ] \
  && ok || bad "a go.mod require line was invisible to §4e"
[ "$(_dep_case Gemfile 'gem "rails"')" -ge 1 ] \
  && ok || bad "a Gemfile gem was invisible to §4e"
# and the boundary: a decision naming `update` must NOT satisfy a dependency called `date`
printf '{\n  "name": "app",\n  "dependencies": {"date": "^1.0.0"}\n}\n' > package.json
printf -- '- 2026-08-23 we now update the invoice page weekly\n' >> _ops/DECISIONS.md
git add -A
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q 'says nothing about why' \
  && ok || bad "a decision saying \`update\` satisfied a dependency named \`date\` — an unbounded substring"
git checkout -q HEAD -- . 2>/dev/null; git reset -q
rm -f requirements.txt go.mod Gemfile
git rm -qf package.json >/dev/null 2>&1; git commit -qm "shapes fixture out" >/dev/null 2>&1

# ── the SHIPPED templates pass the SHIPPED gates ───────────────────────────────────────────
# The documented stand-up act — write _ops/MARKET.md and _ops/TOOLING.md from their templates —
# was refused by §4d, so every new project would have met a refusal on day one. Two causes: a
# figure and its source split across a hard wrap, and an example figure in running prose. Measured
# 2026-08-23. This asserts the act, not the parts: whatever the templates say, they must survive
# the guard that ships beside them.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
cp "$HERE/../templates/MARKET-template.md" _ops/MARKET.md
cp "$HERE/../templates/TOOLING-template.md" _ops/TOOLING.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "the shipped templates are refused by the shipped guard — the stand-up act refuses itself"
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/MARKET.md

# ── §4f reads a FIELD, not a vocabulary ────────────────────────────────────────────────────
# It was a keyword list, which is precisely the defect §4e was repaired away from in the same file
# on the same day: a gate satisfied by words teaches people to sprinkle them, and refuses an honest
# answer using different ones. Named by a lens, 2026-08-23. The register carries a **Replaces**
# column now; a register predating it falls back to the keyword list, and that fallback is named
# in the code rather than presented as a test.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '# Tooling\n\n| Tool | What for | **Replaces** | Checked |\n|---|---|---|---|\n' > _ops/TOOLING.md
git add -A && git commit -qm "replaces-column fixture" >/dev/null 2>&1
_col(){ printf '%s\n' "$1" >> _ops/TOOLING.md; git add -A
        local n; n=$( ( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -c 'what it replaces' )
        git reset -q; git checkout -q -- . 2>/dev/null; echo "$n"; }
[ "$(_col '| Otter | transcripts |  | 2026-08-23 |')" -ge 1 ] \
  && ok || bad "a blank Replaces cell passed — the column is the field this gate reads"
[ "$(_col '| Otter | transcripts | Bob did it on Fridays | 2026-08-23 |')" = 0 ] \
  && ok || bad "an honest answer using none of the old keywords was refused — that is the vocabulary defect"
[ "$(_col '| Otter | transcripts | we had none | 2026-08-23 |')" = 0 ] \
  && ok || bad "\`we had none\` was refused in the column form"
# **The gate must not be stricter than its own message.** With the column present it read the cell
# and nothing else, so a maintainer doing exactly what the refusal prescribed — writing the reason
# in `_ops/DECISIONS.md` — was refused again by the same message. That is §4e's defect one section
# down, found by a cold-read lens 2026-08-23 and reproduced before it was believed.
printf -- '- 2026-08-23 Otter replaces the intern typing them by hand\n' >> _ops/DECISIONS.md
[ "$(_col '| Otter | transcripts |  | 2026-08-23 |')" = 0 ] \
  && ok || bad "a blank cell with a decision naming the tool was refused — the message prescribes exactly that"
git checkout -q HEAD -- _ops/DECISIONS.md 2>/dev/null
printf -- '- 2026-08-23 we switched the invoice template\n' >> _ops/DECISIONS.md
[ "$(_col '| Otter | transcripts |  | 2026-08-23 |')" -ge 1 ] \
  && ok || bad "a decision about something else satisfied the rung — the name is the field"
git checkout -q HEAD -- _ops/DECISIONS.md 2>/dev/null
git checkout -q HEAD -- . 2>/dev/null; git reset -q

# The header is found by STRUCTURE — the line above the `|---|` — and not by the words in it.
# The filter used to drop any row matching `tool|name|what`, which is a vocabulary one level
# below the vocabulary §4e was cured of, in the same file. A register that names its columns
# anything else had its own header read as a data row: standing up `_ops/TOOLING.md` from a
# template, with no tools in it yet, was refused for containing no answer about what it replaced.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '# Tooling\n\n| Thing | Why we have it | Owner |\n|---|---|---|\n' > _ops/TOOLING.md
git add -A
[ "$( ( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -c 'what it replaces' )" = 0 ] \
  && ok || bad "a register standing up with headers and no rows was refused — the header was read as a row"
printf '| Otter | interview transcripts | me |\n' >> _ops/TOOLING.md; git add -A
[ "$( ( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -c 'what it replaces' )" -ge 1 ] \
  && ok || bad "a real row in an unfamiliarly-headed register was not seen at all"
git checkout -q HEAD -- . 2>/dev/null; git reset -q

# ── five ways this rung could be defeated or could refuse honest work (adversarial, 2026-08-23) ──
# The sharpest was a REGRESSION: the register was read from the worktree and the added lines from
# the index, so the moment the two disagreed the intersection was empty and the rung went silent.
# Staging a row and then aligning the table's pipes — the next thing a person does — passed a row
# the gate had just refused. Everything comes from the index now.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '# Tooling\n\n| Tool | What for | **Replaces** | Checked |\n|---|---|---|---|\n' > _ops/TOOLING.md
git add -A && git commit -qm "adversarial fixture" >/dev/null 2>&1
_fires(){ git add -A; ( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -c 'what it replaces'; }

printf '| Figma | design files |  | 2026-08-23 |\n' >> _ops/TOOLING.md
git add _ops/TOOLING.md
python3 - <<'MUT'
import pathlib
p = pathlib.Path("_ops/TOOLING.md"); t = p.read_text()
p.write_text(t.replace("| Figma | design files |  |", "| Figma  | design files  |  |"))
MUT
[ "$( ( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -c 'what it replaces' )" -ge 1 ] \
  && ok || bad "the rung fell open when the worktree and the index disagreed — whitespace is enough"
git reset -q; git checkout -q -- . 2>/dev/null

# A header past line 20 left the column index EMPTY, so awk read the whole row — never blank —
# and every row passed. Four lines of extra preamble was the entire margin.
{ printf '# Tooling\n'; for i in $(seq 1 25); do printf 'preamble line %s\n' "$i"; done
  printf '\n| Tool | What for | **Replaces** | Checked |\n|---|---|---|---|\n| Figma | design |  | 2026-08-23 |\n'; } > _ops/TOOLING.md
[ "$(_fires)" -ge 1 ] && ok || bad "a header below line 20 disarmed the column check entirely"
git reset -q; git checkout -q -- . 2>/dev/null

# Bold was required, so an honestly filled plain-header register went to the keyword fallback.
printf '# Tooling\n\n| Tool | What for | Replaces | Checked |\n|---|---|---|---|\n| Figma | design | the whiteboard photos | 2026-08-23 |\n' > _ops/TOOLING.md
[ "$(_fires)" = 0 ] && ok || bad "a plain \`Replaces\` header was not recognised as the column"
git reset -q; git checkout -q -- . 2>/dev/null

# A sentence in the preamble naming the column hijacked the index to field 1 — the empty string
# before the first pipe — so every row read blank and every row was refused.
printf '# Tooling\n\nEvery row fills *Replaces*; `we had none` is a complete answer.\n\n| Tool | What for | **Replaces** | Checked |\n|---|---|---|---|\n| Figma | design | the whiteboard photos | 2026-08-23 |\n' > _ops/TOOLING.md
[ "$(_fires)" = 0 ] && ok || bad "a preamble mention of the column hijacked its index"
git reset -q; git checkout -q -- . 2>/dev/null

# `|-|-|` is valid GFM; requiring two dashes read the separator itself as a data row.
printf '# Tooling\n\n| Tool | What for | Replaces | Checked |\n|-|-|-|-|\n' > _ops/TOOLING.md
[ "$(_fires)" = 0 ] && ok || bad "a one-dash GFM separator was read as a data row"

# ── the header must not be able to switch this gate off (adversarial, 2026-08-23) ───────────
# The header was handed back to awk as `HDR="$_hdr"`, a command-line assignment, which awk
# escape-processes: a header containing `c:\temp` arrived with a TAB in it and the equality test
# matched nothing, so §4f went silent for that file permanently. One character, and the gate is
# gone. Cells are also split on unescaped pipes outside code spans now — `\|` and a pipe inside
# backticks each shifted every field after them and the gate read the wrong cell.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
_reg(){ python3 - "$1" <<'RPY'
import pathlib, sys
pathlib.Path("_ops/TOOLING.md").write_text(sys.argv[1])
RPY
  git add -A
  local n; n=$( ( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -c 'what it replaces' )
  git reset -q; git checkout -q -- . 2>/dev/null; echo "$n"; }

[ "$(_reg '# T

| Tool | c:\temp | **Replaces** | Checked |
|---|---|---|---|
| Otter | x |  | d |
')" -ge 1 ] && ok || bad "a backslash in the header switched §4f off entirely"

# ── three more silencing shapes, adversarial 2026-08-28 ─────────────────────────────────────
# **(a) A register that documents its own parking idiom disarmed the gate.** A live row whose
# cell reads a comment opener in backticks has no closer on that line, so the strip broke, the
# multi-line path fired, and every live row down to the next closer went with it — including the
# blank-Replaces row this gate exists to catch. An opener inside a code span is text.
[ "$(_reg '# T

| Tool | Replaces |
|---|---|
| parkdoc | park a draft row by wrapping it in `<!--` |
| ripgrep |  |
<!-- | someday | x | -->
')" -ge 1 ] && ok || bad "a live row quoting a comment opener in backticks silenced every live row below it"

# **(b) A bare closer left standing is not a row**, and the walk read it as the end of one.
[ "$(_reg '# T

| Tool | Replaces |
|---|---|
| other | x |
  -->
| ripgrep |  |
')" -ge 1 ] && ok || bad "a stray -->  line was read as the end of the table, hiding every row after it"

# **(c) The stripped remnant of a comment-only line must not resurrect as a boundary either.**
[ "$(_reg '# T

| Tool | Replaces |
|---|---|
<!-- parked -->  -->
| ripgrep |  |
')" -ge 1 ] && ok || bad "a comment-only line leaving a stray closer silenced the rows below it"

# **The CR case was claimed "measured 2026-08-27" in four places and asserted in none** — found
# by a contradiction lens 2026-08-28, which is the same defect the commit that wrote those four
# comments accuses an earlier one of. `_reg` cannot carry a CR through, so this writes the file
# directly.
printf '# T\r\n\r\n| Tool | Replaces |\r\n|---|---|\r\n<!-- | draft | x | -->\r\n| ripgrep |  |\r\n' > _ops/TOOLING.md
git add -A
[ "$( ( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -c 'what it replaces' )" -ge 1 ] \
  && ok || bad "a CRLF register read a parked row as the end of the table and hid every live row below"
git reset -q; git checkout -q -- . 2>/dev/null

# ── a comment hides a LINE, and a fence needs a closer (adversarial, 2026-08-27) ────────────
# Three ways the register went silent, all measured: an inline `<!-- todo -->` in a live row made
# that row invisible while GFM still rendered it · a bare `<!--` with no closer anywhere made
# every row after it invisible permanently · a stray ``` at the top did the same. Openers are now
# believed only when a closer exists, and an inline comment is stripped from its line rather than
# swallowing it.
[ "$(_reg '# T

| Tool | What for | **Replaces** | Checked |
|---|---|---|---|
| Otter | notes | <!-- todo --> | d |
')" -ge 1 ] && ok || bad "an inline HTML comment in a cell made the row invisible"
[ "$(_reg '# T

| Tool | What for | **Replaces** | Checked |
|---|---|---|---|
| Beta | write <!-- here |  | d |
| Gamma | y |  | d |
')" -ge 1 ] && ok || bad "an unterminated comment swallowed every row after it"
[ "$(_reg '# T

```

| Tool | What for | **Replaces** | Checked |
|---|---|---|---|
| Otter | notes |  | d |
')" -ge 1 ] && ok || bad "a stray fence opener with no closer hid the whole register"
[ "$(_reg '# T

| Tool | What for | **Replaces** | Checked |
|---|---|---|---|

<!--
| Draft | not yet |  | d |
-->
')" = 0 ] && ok || bad "a genuinely commented-out row was treated as live"
# **A line that was ENTIRELY an inline comment is hidden, not empty.** Left visible-but-empty it
# read as the end of the table, so one parked draft row — the idiom the guard itself recommends —
# silenced the gate for every live row below. A regression of the comment rewrite, 2026-08-27.
[ "$(_reg '# T

| Tool | What for | **Replaces** | Checked |
|---|---|---|---|
<!-- | draft | parked |  | d | -->
| live | notes |  | d |
')" -ge 1 ] && ok || bad "a parked draft row silenced the gate for the live row below it"
[ "$(_reg '# T

| Tool | What for | **Replaces** | Checked |
|---|---|---|---|
<!-- sorted by date -->
| live | notes |  | d |
')" -ge 1 ] && ok || bad "a comment-only note between rows ended the table early"
# **The inline strip must survive a `>` and a CR.** `<!--[^>]*-->` could not cross a `>`, so a
# parked row containing `->`, `>=` or an HTML tag was neither stripped nor hidden — it stayed as
# non-pipe text and the row scan read it as the end of the table. `[ \t]` excluded `\r`, so a CRLF
# register did the same. Both measured 2026-08-27: surviving instances of the very defect the
# strip was written to close, because the repair generalised the finding and not the rule.
[ "$(_reg '# T

| Tool | What for | **Replaces** | Checked |
|---|---|---|---|
<!-- | draft | a -> b |  | d | -->
| live | notes |  | d |
')" -ge 1 ] && ok || bad "a parked row containing > silenced the gate for the live row below"
[ "$(_reg '# T

| Tool | What for | **Replaces** | Checked |
|---|---|---|---|
<!-- see issue #12 (>1 week) -->
| live | notes |  | d |
')" -ge 1 ] && ok || bad "a comment containing > ended the table early"
[ "$(_reg '# T

| Tool | a \| b | **Replaces** | Checked |
|---|---|---|---|
| Otter | x |  | d |
')" -ge 1 ] && ok || bad "an escaped pipe in the header shifted the column and the gate read the wrong cell"
[ "$(_reg '# T

| Tool | What for | **Replaces** | Checked |
|---|---|---|---|
| datadog | pipes `a|b` |  | d |
')" -ge 1 ] && ok || bad "a pipe inside backticks shifted the row and satisfied a blank cell"
[ "$(_reg '# T

| Tool | What for | Checked |
|---|---|---|
| Otter | transcripts | d |

## Retired

| Tool | Why | **Replaces** |
|---|---|---|
')" -ge 1 ] && ok || bad "a Replaces column on a LATER table captured the gate and the register went unasked"
[ "$(_reg '# T

## Retired

| Tool | Why | **Replaces** |
|---|---|---|

## Live

| Tool | What for | **Replaces** | Checked |
|---|---|---|---|
| Otter | x |  | d |
')" -ge 1 ] && ok || bad "a decoy table above the register captured the gate"
git checkout -q HEAD -- . 2>/dev/null; git reset -q

# **A row belongs to its own table.** A tooling file commonly carries a `## Retired` table
# recording that something went AWAY, and every row in it was being asked what it replaces — the
# opposite question. It passed or failed by accident, on whether the first table's column ordinal
# happened to land on a filled cell. Adversarial lens, 2026-08-23.
printf '# Tooling\n\n| Tool | What for | **Replaces** | Checked |\n|---|---|---|---|\n\n## Retired\n\n| Tool | Why it went |\n|---|---|\n| Trello | we stopped using it |\n' > _ops/TOOLING.md
[ "$(_fires)" = 0 ] && ok || bad "a row recording that a tool went away was asked what it replaces"
git reset -q; git checkout -q -- . 2>/dev/null
printf '# Tooling\n\n| Tool | What for | **Replaces** | Checked |\n|---|---|---|---|\n| Otter | transcripts |  | 2026-08-23 |\n\n## Retired\n\n| Tool | Why it went |\n|---|---|\n' > _ops/TOOLING.md
[ "$(_fires)" -ge 1 ] && ok || bad "a real register row went unchecked because a second table followed it"
git checkout -q HEAD -- . 2>/dev/null; git reset -q

# An example table inside a fence is an illustration, not the register — the same lesson the
# market gate paid for when the shipped template was refused by the shipped guard.
printf '# Tooling\n\n| Thing | Why | Owner |\n|---|---|---|\n\nExample:\n\n```\n| Foo | bar | me |\n```\n' > _ops/TOOLING.md
git add -A
[ "$( ( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -c 'what it replaces' )" = 0 ] \
  && ok || bad "a fenced example row was treated as a register row"
# A ~~~ fence and an HTML comment hide an example the same way ``` does, and only ``` was skipped
# — so four documentation-only edits were refused (adversarial, 2026-08-23).
printf '# Tooling\n\n| Thing | Why | Owner |\n|---|---|---|\n\n~~~\n| Foo | bar | me |\n~~~\n' > _ops/TOOLING.md
[ "$(_fires)" = 0 ] && ok || bad "a ~~~ fenced example row was treated as a register row"
git reset -q; git checkout -q -- . 2>/dev/null
printf '# Tooling\n\n| Thing | Why | Owner |\n|---|---|---|\n\n<!--\n| Draft | not yet | me |\n-->\n' > _ops/TOOLING.md
[ "$(_fires)" = 0 ] && ok || bad "a row parked in an HTML comment was treated as live"
git reset -q; git checkout -q -- . 2>/dev/null
# The live row sits under its own header, where a table row lives; the fenced example follows.
# The first version of this fixture put the row AFTER the fence with no header above it, which is
# not a table row in markdown at all — the assertion passed only because the old extractor swept
# every `|` line in the file. Corrected 2026-08-23 when the extractor started respecting table
# boundaries and the fixture, not the code, turned out to be wrong.
printf '# Tooling\n\n| Thing | Why | Owner |\n|---|---|---|\n| Otter | transcripts | me |\n\n~~~\n| Foo | bar | me |\n~~~\n' > _ops/TOOLING.md
[ "$(_fires)" -ge 1 ] && ok || bad "a live row under its own header was not seen when a fenced example followed"
git checkout -q HEAD -- . 2>/dev/null; git reset -q

# ── the guard notices its own age ──────────────────────────────────────────────────────────
# This file is a COPY, written into _ops/scripts/ at stand-up and never moving again by itself, so
# every release that adds a check leaves existing projects on the old one — silently, with a green
# tick. The upgrade's four layers did not include it; this is the fifth.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
_gv=$(sed -n 's/^# guard-version:[[:space:]]*\([0-9.]*\).*/\1/p' "$HERE/../templates/company-preflight.sh" | head -1)
printf '# P\n\n**Operated by:** Opsinist **%s** · format `schema_version` 1\n' "$_gv" > CLAUDE.md
git add -A
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q 'guard is version' \
  && bad "the guard complained about its age while matching the guide" || ok
printf '# P\n\n**Operated by:** Opsinist **0.0.1** · format `schema_version` 1\n' > CLAUDE.md
git add -A
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q 'guard is version' \
  && ok || bad "a guard older than the guide said nothing — the fifth upgrade layer is silent again"
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "the age check refused instead of warning"
git checkout -q HEAD -- . 2>/dev/null; git reset -q

# ── and the same rung where there is no code at all ────────────────────────────────────────
# A package manifest is one project's spelling of a new standing commitment; a bakery's is a
# supplier. `_ops/TOOLING.md` is the universal register, so a row added there is asked the same
# question — and it WARNS, because outside software `we had none` is very often the true answer.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '# Tooling\n\n| Tool | What for | Ceiling |\n|---|---|---|\n' > _ops/TOOLING.md
git add -A && git commit -qm "tooling fixture" >/dev/null 2>&1
printf '| Nordfeld flour | the sourdough base | 200kg/month |\n' >> _ops/TOOLING.md
git add -A
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q 'what it replaces' \
  && ok || bad "a tooling row arrived with nothing about what it replaces and nothing said so"
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '| Nordfeld flour | the sourdough base, instead of the mill we drove to weekly | 200kg |\n' >> _ops/TOOLING.md
git add -A
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q 'what it replaces' \
  && bad "a row saying what it replaces was still asked" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '| Nordfeld flour | the sourdough base; we had none, the recipe is new | |\n' >> _ops/TOOLING.md
git add -A
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q 'what it replaces' \
  && bad "\`we had none\` was not accepted — outside software it is usually the true answer" || ok
# and it REFUSES the silence — measured 2026-08-22: as a warning it scored 0 of 5, three runs
# adding the row and committing with nothing said. Accepting `we had none` is what makes refusing
# fair; the gate refuses silence, never the answer.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '| Otter | interview transcripts | me | service | 2026-08-22 |\n' >> _ops/TOOLING.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a row with nothing about what came before passed — a warning there measured 0 of 5" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q

# ── a market figure carries where it came from and when ────────────────────────────────────
# New in 0.2.9. _ops/MARKET.md is the most hallucination-prone file a project can own: a plausible
# number arrives free, reads as research, and is quoted for a year. The gate does not ask for a
# number — `unknown` passes — it asks that a number, once written, be traceable.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '# Market\n\n- **TAM**: $4.2B\n- **SAM**: 180,000 firms\n' > _ops/MARKET.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "market figures were added with no source and no date and nothing objected" || ok
printf '# Market\n\n- **TAM**: $4.2B \xc2\xb7 source: a report I read\n' > _ops/MARKET.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a figure with a source and no date passed — an undated number is a number about a year nobody named" || ok
printf '# Market\n\n- **TAM**: $4.2B \xc2\xb7 2026-08-21\n' > _ops/MARKET.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a figure with a date and no source passed — provenance is the half that cannot be guessed" || ok
# the twins: sourced and dated, honest unknowns, and prose that states no figure at all
printf '# Market\n\n- **TAM**: $4.2B \xc2\xb7 source: national register, SIC 10.71 \xc2\xb7 2026-07-14\n' > _ops/MARKET.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a figure carrying its source and date was refused"
printf '# Market\n\n- **TAM**: unknown \xe2\x80\x94 nobody has counted this\n' > _ops/MARKET.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "an honest unknown was refused — the gate asks for traceability, not for a number"
printf '# Market\n\nThe market is large and fragmented; nobody has sized it yet.\n' > _ops/MARKET.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "prose about a market with no figure in it was refused — this gate refuses claims, not sentences"
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/MARKET.md

# ── retiring _ops/DECISIONS.md itself must be POSSIBLE ─────────────────────────────────────
# The escape asks for an added line inside DECISIONS, and when DECISIONS is what is being retired
# the commit's whole content is that the file stops existing there — so every literal reading was
# refused and the printed remedy could not be followed. A gate with an impossible exit is the gate
# people pass with --no-verify. Measured 2026-08-21 (pass twelve). The pair: the honest retirement
# passes, and a retirement with no line anywhere is still refused.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '# Decisions\n\n- 2026-08-01 · we log decisions here · because · owner\n' > _ops/DECISIONS.md
printf '# Tooling\n\n| tool | why |\n|---|---|\n' > _ops/TOOLING.md
git add -A && git commit -qm "decisions fixture" >/dev/null 2>&1
# the honest move: rename it, and record the retirement where the decisions now live
git mv _ops/DECISIONS.md _ops/LOG.md >/dev/null 2>&1
printf -- '\n- 2026-08-21 retiring _ops/DECISIONS.md: the log lives at _ops/LOG.md now\n' >> _ops/LOG.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "retiring _ops/DECISIONS.md with the reason recorded in its successor was refused — the remedy is impossible"
# `git checkout -- .` restores DECISIONS but leaves the untracked LOG.md the rename created, so
# the second `git mv` failed and staged NOTHING — the assertion below then passed a preflight that
# had been handed an empty commit. Caught by the assertion disagreeing with a hand probe.
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/LOG.md
# and the twin that must still refuse: the same rename with nothing recorded anywhere
git mv _ops/DECISIONS.md _ops/LOG.md >/dev/null 2>&1
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "_ops/DECISIONS.md was retired with no line anywhere and nothing objected" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/LOG.md
git rm -qf _ops/DECISIONS.md _ops/TOOLING.md >/dev/null 2>&1
git commit -qm "decisions fixture out" >/dev/null 2>&1

# ── §10b reads the ID, not the id plus the slug — and asks the title when there is none ────
# The id was cut from the filename with a class holding `-` and `a-z`, so the shipped convention
# `T-XXXXXX-slug.md` — the one §1g's own comment cites — produced `T-CCC333-fix-login`, which no
# record ever names: the warning fired on EVERY close of a slug-named task, and was unanswerable,
# because writing the record it asked for could not silence it. And a filename carrying no id at
# all was skipped in silence rather than read from the title. Measured 2026-08-21 (pass twelve).
git checkout -q HEAD -- . 2>/dev/null; git reset -q
mkdir -p _ops/process/types _ops/runs
printf 'started -> review -> done\n' > _ops/process/types/default.md
_slugtask(){ printf '# %s — add a logout\n\n**Status**: started\n**Assignee**: ui\n\n## Done when\n\n- [ ] the thing exists\n\n## History\n' "$1" > "_ops/tasks/$2"; }
_close(){ python3 "$HERE/transition.py" "_ops/tasks/$1" review --by ui >/dev/null 2>&1
  printf -- '- reviewed by qa\n' >> "_ops/tasks/$1"
  python3 -c "
import pathlib,sys
p = pathlib.Path('_ops/tasks/' + sys.argv[1])
p.write_text(p.read_text().replace('- [ ] the thing exists', '- [x] the thing exists'))" "$1"
  python3 "$HERE/transition.py" "_ops/tasks/$1" done --by qa >/dev/null 2>&1
  git add -A; }

# a slug-named task WITH a record naming its id: the warning must stay silent
_slugtask T-CCC333 T-CCC333-fix-login.md
printf '# R-S1 — the job\n\n| **Task** | T-CCC333 · add a logout |\n| **Attempt** | 1 |\n| **Model that answered** | sonnet |\n| **Outcome** | completed |\n\n| input | output | cache_read | cache_write |\n|---|---|---|---|\n| 1 | 2 | 3 | 4 |\n' > _ops/runs/R-S1.md
git add -A && git commit -qm "slug fixture" >/dev/null 2>&1
_close T-CCC333-fix-login.md
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q "no run record names" \
  && bad "a slug-named task with a record naming its id was still warned — the id was cut with its slug" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q
git rm -qf _ops/tasks/T-CCC333-fix-login.md _ops/runs/R-S1.md >/dev/null 2>&1
git commit -qm "slug fixture out" >/dev/null 2>&1

# a task whose FILENAME carries no id: the title is asked, and the warning still fires when
# nothing names it. Skipping these silently is how a whole naming convention escapes the check.
mkdir -p _ops/runs
_slugtask T-DDD444 add-a-logout.md
git add -A && git commit -qm "slugless fixture" >/dev/null 2>&1
_close add-a-logout.md
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q "no run record names T-DDD444" \
  && ok || bad "a task whose filename carries no id closed unchecked — the title was never asked"
git checkout -q HEAD -- . 2>/dev/null; git reset -q
git rm -qf _ops/tasks/add-a-logout.md >/dev/null 2>&1
git commit -qm "slugless fixture out" >/dev/null 2>&1

# ── the escalation escape must be followable, and not satisfiable by denial ────────────────
# The keyword form was unfollowable in one direction and satisfiable in the other, both measured
# 2026-08-16 (pass eleven): a reader who did exactly what the message said — wrote in the record
# why a fourth was right — was refused again with identical text, while a record saying "not a spec
# problem" PASSED because it contains that substring. A gate satisfied by denying the thing it asks
# for is worse than no gate. Three cases, because the middle one is the whole point.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
mkdir -p _ops/runs
_erec(){ printf '# R-E%s — a run\n\ntask: T-ESC01\n\n| **Attempt** | %s |\n| **Model that answered** | sonnet |\n| **Outcome** | completed |\n%s\n\n| input | output | cache_read | cache_write |\n|---|---|---|---|\n| 1 | 2 | 3 | 4 |\n' "$1" "$2" "$3" > "_ops/runs/R-E$1.md"; }
_erec 1 1 ""; _erec 2 2 ""
git add -A && git commit -qm "escalation fixture" >/dev/null 2>&1
_erec 3 3 "
not a spec problem — the sandbox was flaky."
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a record DENYING that it is a spec problem satisfied the escalation gate" || ok
git rm -q --cached _ops/runs/R-E3.md >/dev/null 2>&1; rm -f _ops/runs/R-E3.md
_erec 3 3 "
**Escalated**: raised with the owner — the brief is ambiguous."
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "the line the refusal prints does not satisfy the gate that prints it"
git rm -q --cached _ops/runs/R-E3.md >/dev/null 2>&1; rm -f _ops/runs/R-E3.md
_erec 3 3 ""
git add -A
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q '\*\*Escalated\*\*:' \
  && ok || bad "the refusal does not print the line that satisfies it"
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/runs/R-E3.md
git rm -qf _ops/runs/R-E1.md _ops/runs/R-E2.md >/dev/null 2>&1
git commit -qm "escalation fixture out" >/dev/null 2>&1

# ── the neighbour count reads any declaration form, and only run records ───────────────────
# Every other check in §1f is format-agnostic (`hits -iF "$need"`); the id reader was the one rigid
# part, so a record naming its task on a `task:` line counted zero neighbours. And the walk globbed
# every `.md` under `_ops/runs/` while the gate applies to `R-*.md`, so an ordinary note living
# there was parsed as a record. Both measured 2026-08-16 (pass eleven).
git checkout -q HEAD -- . 2>/dev/null; git reset -q
mkdir -p _ops/runs
_frec(){ printf '# R-%s — a run\n\ntask: %s\n\n| **Attempt** | %s |\n| **Model that answered** | sonnet |\n| **Outcome** | completed |\n\n| input | output | cache_read | cache_write |\n|---|---|---|---|\n| 1 | 2 | 3 | 4 |\n' "$1" "$2" "$3" > "_ops/runs/R-$1.md"; }
_frec F1 T-FMT01 1; _frec F2 T-FMT01 2
printf '# Notes\n\nThis directory holds run records. T-FMT01 is mentioned here in prose.\n' > _ops/runs/README.md
git add -A && git commit -qm "format fixture" >/dev/null 2>&1
_frec F3 T-FMT01 1
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a third record declaring its task on a 'task:' line counted no neighbours" || ok
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q 'records attempt 3' \
  && ok || bad "the count is not 3 — the README in the same directory was parsed as a record"
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/runs/R-F3.md
git rm -qf _ops/runs/R-F1.md _ops/runs/R-F2.md _ops/runs/README.md >/dev/null 2>&1
git commit -qm "format fixture out" >/dev/null 2>&1

# ── and the two forms the CORPUS ITSELF prescribes ─────────────────────────────────────────
# The reader above was measured on a `task:` line, which no shipped template actually writes. The
# two that ARE written both read as EMPTY until 2026-08-21: `# T-ABC123 — title` is line 1 of
# templates/TASK-template.md, and `| **Task** | T-ABC123 · title |` is line 10 of
# templates/RUN-template.md. So §1f's neighbour count — the capability this range shipped — was
# void for every record written the way the corpus tells people to write them, while this suite
# stayed green on a form none of them use. Three lenses and the critic found it separately.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
mkdir -p _ops/runs
# the TABLE row, exactly as RUN-template.md prescribes it
_trec(){ printf '# R-%s — a run\n\n| **Task** | %s \xc2\xb7 a title |\n| **Attempt** | %s |\n| **Model that answered** | sonnet |\n| **Outcome** | completed |\n\n| input | output | cache_read | cache_write |\n|---|---|---|---|\n| 1 | 2 | 3 | 4 |\n' "$1" "$2" "$3" > "_ops/runs/R-$1.md"; }
_trec B1 T-TAB01 1; _trec B2 T-TAB01 2
git add -A && git commit -qm "table fixture" >/dev/null 2>&1
_trec B3 T-TAB01 1
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a third record declaring its task in the template's own **Task** row counted no neighbours" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/runs/R-B3.md
git rm -qf _ops/runs/R-B1.md _ops/runs/R-B2.md >/dev/null 2>&1
git commit -qm "table fixture out" >/dev/null 2>&1

# the ID-FIRST title, exactly as TASK-template.md line 1 prescribes it
mkdir -p _ops/runs
_hrec(){ printf '# %s \xe2\x80\x94 a run for it\n\n| **Attempt** | %s |\n| **Model that answered** | sonnet |\n| **Outcome** | completed |\n\n| input | output | cache_read | cache_write |\n|---|---|---|---|\n| 1 | 2 | 3 | 4 |\n' "$1" "$2" > "_ops/runs/R-$3.md"; }
_hrec T-HDR01 1 H1; _hrec T-HDR01 2 H2
git add -A && git commit -qm "header fixture" >/dev/null 2>&1
_hrec T-HDR01 1 H3
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a third record whose title LEADS with the id counted no neighbours — the shape TASK-template writes" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/runs/R-H3.md
git rm -qf _ops/runs/R-H1.md _ops/runs/R-H2.md >/dev/null 2>&1
git commit -qm "header fixture out" >/dev/null 2>&1

# and the twin the widened reader must NOT break: a MENTION is still not a declaration, or §1f
# would count every record that merely refers to a neighbouring task.
mkdir -p _ops/runs
_mrec(){ printf '# R-%s — a run\n\ntask: T-MEN01\n\n| **Attempt** | %s |\n| **Model that answered** | sonnet |\n| **Outcome** | completed |\n\n| notes | related to T-OTHER9 |\n|---|---|\n\n| input | output | cache_read | cache_write |\n|---|---|---|---|\n| 1 | 2 | 3 | 4 |\n' "$1" "$2" > "_ops/runs/R-$1.md"; }
_mrec M1 1; _mrec M2 2
git add -A && git commit -qm "mention fixture" >/dev/null 2>&1
printf '# R-M3 — a run\n\ntask: T-OTHER9\n\n| **Attempt** | 1 |\n| **Model that answered** | sonnet |\n| **Outcome** | completed |\n\n| input | output | cache_read | cache_write |\n|---|---|---|---|\n| 1 | 2 | 3 | 4 |\n' > _ops/runs/R-M3.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a record declaring T-OTHER9 was counted against two records that merely MENTION it"
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/runs/R-M3.md
git rm -qf _ops/runs/R-M1.md _ops/runs/R-M2.md >/dev/null 2>&1
git commit -qm "mention fixture out" >/dev/null 2>&1

# ── a RUN RECORD delivered as a rename must not escape §1f ─────────────────────────────────
# §1f was moved from `--diff-filter=A` to `AR` in this release because "a record delivered as a
# rename escaped this gate whole", and nothing asserted it: an adversarial lens reverted the
# filter and the suite stayed green. Measured 2026-08-15 (pass ten).
git checkout -q HEAD -- . 2>/dev/null; git reset -q
mkdir -p _ops/runs
printf '# R-OLD — probe\n\n| **Task** | T-RENREC |\n| **Attempt** | 1 |\n| **Model that answered** | sonnet |\n| **Outcome** | completed |\n\n| input | output | cache_read | cache_write |\n|---|---|---|---|\n| 1 | 2 | 3 | 4 |\n' > _ops/runs/R-OLD.md
git add -A && git commit -qm "record fixture" >/dev/null 2>&1
git mv _ops/runs/R-OLD.md _ops/runs/R-NEW.md
python3 -c "
import pathlib
p = pathlib.Path('_ops/runs/R-NEW.md')
p.write_text(p.read_text().replace('| **Attempt** | 1 |', '| **Attempt** | 4 |'))"
git add -A
( git diff --cached --name-status -M || true ) | grep -q '^R' \
  && ok || bad "the run-record fixture was not scored a rename — this pair proves nothing"
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a run record naming attempt 4 and no escalation escaped §1f by arriving as a rename" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q
git rm -qf _ops/runs/R-OLD.md >/dev/null 2>&1
git commit -qm "record fixture out" >/dev/null 2>&1

# ── ...and a rename must not STRAND a legacy task either ───────────────────────────────────
# Adding `R` to §1c's filter made it see renames without teaching it what one means: `was` was read
# from `HEAD:<new path>`, which does not exist, so a PURE `git mv` of a legacy two-home task —
# byte-identical, no edit — was refused quoting "(it kept 0)", a number the file contradicts.
# Measured 2026-08-15 (pass eleven). The pair: a pure rename passes, a rename that ADDS a home does
# not, because the easy way to stop stranding is to stop checking.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '# T-LEGR — legacy\n\n**Status**: doing\n**Stage**: build\n**Assignee**: ui\n\n## Notes\n\nprose\n' > _ops/tasks/T-LEGR.md
git add -A && git commit -qm "legacy rename fixture" >/dev/null 2>&1
git mv _ops/tasks/T-LEGR.md _ops/tasks/T-LEGA.md && git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a pure rename of a legacy two-home task was refused — legacy stranded by §1c"
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/tasks/T-LEGA.md; git checkout -q .
git mv _ops/tasks/T-LEGR.md _ops/tasks/T-LEGB.md
printf '\nstage: review\n' >> _ops/tasks/T-LEGB.md && git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a rename that ADDS a third state home passed §1c" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/tasks/T-LEGB.md; git checkout -q .
git rm -qf _ops/tasks/T-LEGR.md >/dev/null 2>&1
git commit -qm "legacy rename fixture out" >/dev/null 2>&1

# ── a rename must not be a bypass ──────────────────────────────────────────────────────────
# `git mv` plus the offending edit in ONE commit scored `R098` and drew ZERO refusals: `AM` does
# not select `R`, and restricting `git diff` to the new path alone defeats rename detection, so
# the diff showed a wholly-added file with no removed state line for §14 to find. Measured
# 2026-08-15 (pass ten). Both halves are needed — the file list must include renames AND the diff
# must be paired with its source — so this asserts the whole path, and the control beside it.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
{ printf '# T-REN — a long task\n\n**Status**: doing\n**Assignee**: ui\n\n## Notes\n\n'
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
    printf 'A line of ordinary prose number %s.\n' "$i"
  done; } > _ops/tasks/T-REN.md
git add -A && git commit -qm "rename fixture" >/dev/null 2>&1
git mv _ops/tasks/T-REN.md _ops/tasks/T-REN2.md
python3 -c "
import pathlib
p = pathlib.Path('_ops/tasks/T-REN2.md')
p.write_text(p.read_text().replace('**Status**: doing', '**Status**: done'))"
git add -A
# it really must be scored a rename, or this pair proves nothing
( git diff --cached --name-status -M || true ) | grep -q '^R' \
  && ok || bad "the fixture was not scored a rename — this assertion cannot demonstrate the bypass"
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a hand-flipped status delivered as a rename passed every gate" || ok
# ...and again with a TAB in the name, because git C-QUOTES such a path in line mode and the first
# version of `staged_diff` compared a quoted `$3` against a raw path: never equal, no source found,
# and the diff silently fell back to the rename-blind form. The bypass this helper closes, reopened
# by one tab. Measured 2026-08-15 (pass eleven) — rc=0 where the control above refuses.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
_told=$(printf '_ops/tasks/T-TAB\tx.md'); _tnew=$(printf '_ops/tasks/T-TAB2\tx.md')
{ printf '# T-TAB — a long task\n\n**Status**: doing\n**Assignee**: ui\n\n## Notes\n\n'
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
    printf 'Ordinary prose line %s.\n' "$i"
  done; } > "$_told"
git add -A && git commit -qm "tab rename fixture" >/dev/null 2>&1
git mv "$_told" "$_tnew"
python3 -c "
import pathlib, sys
p = pathlib.Path(sys.argv[1])
p.write_text(p.read_text().replace('**Status**: doing', '**Status**: done'))" "$_tnew"
git add -A
( git diff --cached --name-status -M || true ) | grep -q '^R' \
  && ok || bad "the tab fixture was not scored a rename — this assertion proves nothing"
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a rename whose path holds a tab passed every gate" || ok
_e=$(bash _ops/scripts/preflight.sh 2>&1 >/dev/null)
[ -z "$_e" ] \
  && ok || bad "the guard writes to stderr on a tab-named path: $(printf '%s' "$_e" | head -1)"
git checkout -q HEAD -- . 2>/dev/null; git reset -q
git rm -qf "$_told" >/dev/null 2>&1
git commit -qm "tab rename fixture out" >/dev/null 2>&1
git checkout -q HEAD -- . 2>/dev/null; git reset -q
git rm -qf _ops/tasks/T-REN.md >/dev/null 2>&1
git commit -qm "rename fixture out" >/dev/null 2>&1

# ── the third attempt is counted from the neighbours, not from the field ───────────────────
# The field is a claim; a worker who did not read the prior records writes a third one labelled
# `attempt: 1` and a gate keyed on the field alone lets it past. N93 measured 1/5 with four runs
# dispatching a further attempt having read neither prior record (2026-08-15). A guard cannot see
# a dispatch and this does not claim to repair that — it closes the case where the record IS
# written and its count is simply wrong. Four cases, because the false positives are the risk.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
mkdir -p _ops/runs
for a in 1 2; do
  printf '# R-N%s — T-93\n\n| **Attempt** | %s |\n| **Model that answered** | sonnet |\n| **Outcome** | completed |\n\n| input | output | cache_read | cache_write |\n|---|---|---|---|\n| 1 | 2 | 3 | 4 |\n' "$a" "$a" > "_ops/runs/R-N$a.md"
done
git add -A && git commit -qm "two runs on T-93" >/dev/null 2>&1
rec(){ printf '# R-N3 — T-93\n\n| **Attempt** | %s |\n| **Model that answered** | sonnet |\n| **Outcome** | completed |\n%s\n| input | output | cache_read | cache_write |\n|---|---|---|---|\n| 1 | 2 | 3 | 4 |\n' "$1" "$2" > _ops/runs/R-N3.md; }
rec 1 ""            && git add -A && bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a third record on the same task labelled 'attempt: 1' passed the escalation gate" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/runs/R-N3.md
rec 3 "Escalated: the spec does not say which of the two readings is meant." \
  && git add -A && bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a third record that DOES name its escalation was refused"
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/runs/R-N3.md
printf '# R-M1 — T-94\n\n| **Attempt** | 1 |\n| **Model that answered** | sonnet |\n| **Outcome** | completed |\n\n| input | output | cache_read | cache_write |\n|---|---|---|---|\n| 1 | 2 | 3 | 4 |\n' > _ops/runs/R-M1.md
git add -A && bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a first record on a task with no history was refused"
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/runs/R-M1.md
git rm -qf _ops/runs/R-N1.md _ops/runs/R-N2.md >/dev/null 2>&1
git commit -qm "T-93 runs out" >/dev/null 2>&1

# ...and the neighbours must be COUNTED BY DECLARATION, not by mention. `grep -rlF` over whole
# files counted any record that merely names the id — `blocked_by` is a field this same section
# greps for — so the first-ever record on a task with three dependents was refused as "attempt 4",
# quoting a number that appears nowhere in it. Measured 2026-08-15 (pass ten). A false refusal on
# an ordinary dependency graph is how a project learns to use --no-verify.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
# `mkdir -p` because the block above `git rm`s its records and git removes the empty directory
# with them — without this the fixtures are never written, the preflight sees no dependents, and
# the assertion below passes for the wrong reason while printing two errors to stderr.
mkdir -p _ops/runs
_rec(){ printf '# R-%s — probe\n\n| **Task** | %s |\n| **Attempt** | 1 |\n| **Model that answered** | sonnet |\n| **Outcome** | completed |\n%s\n| input | output | cache_read | cache_write |\n|---|---|---|---|\n| 1 | 2 | 3 | 4 |\n' "$1" "$2" "$3" > "_ops/runs/R-$1.md"; }
for n in D1 D2 D3; do _rec "$n" "T-7HJ3MN" "| **blocked_by** | T-4F2K9Q |"; done
git add -A && git commit -qm "dependents" >/dev/null 2>&1
_rec Z9 "T-4F2K9Q" ""
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "the first record on a task named in three others' blocked_by was refused as a third attempt"
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/runs/R-Z9.md
git rm -qf _ops/runs/R-D1.md _ops/runs/R-D2.md _ops/runs/R-D3.md >/dev/null 2>&1
git commit -qm "dependents out" >/dev/null 2>&1

# ── gutting a keyed file is retiring it ────────────────────────────────────────────────────
# `staged_size -eq 0` was the whole emptiness test, so `printf '.' > _ops/TOOLING.md` read as a
# living file while §2 and §9, both keyed on it having rows, went silent. Measured 2026-08-15.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
cp _ops/TOOLING.md "$T/.tooling.bak" 2>/dev/null || true
{ printf '# Tooling\n\n| Tool | What | Checked |\n|---|---|---|\n'
  for i in 1 2 3 4 5 6 7 8; do
    printf '| tool-%s | does a thing that is described here at some length | 2026-08-01 |\n' "$i"
  done; } > _ops/TOOLING.md
git add -A && git commit -qm "tooling with rows" >/dev/null 2>&1
printf '.\n' > _ops/TOOLING.md && git add _ops/TOOLING.md
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "gutting _ops/TOOLING.md to one character passed the retire gate" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q
[ -f "$T/.tooling.bak" ] && cp "$T/.tooling.bak" _ops/TOOLING.md
git add -A && git commit -qm "tooling back" >/dev/null 2>&1

# ── the bar is read at any heading depth and in any case ───────────────────────────────────
# `/^##[[:space:]]*(Done when|Acceptance)/` was case-sensitive and exactly two hashes, so under
# `### Done when` a task could close with its criterion rewritten to anything. Measured
# 2026-08-15 (pass nine). §13 one section down already reads headings with `grep -iE`.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '# T-H3 — deep heading\n\n**Status**: started\n**Assignee**: worker-a\n\n### Done when\n\n- [ ] the real criterion\n\n## History\n' > _ops/tasks/T-H3.md
git add -A && git commit -qm "h3 fixture" >/dev/null 2>&1
python3 "$HERE/transition.py" _ops/tasks/T-H3.md review --by bob >/dev/null 2>&1
python3 -c "
import pathlib
p = pathlib.Path('_ops/tasks/T-H3.md')
p.write_text(p.read_text().replace('- [ ] the real criterion', '- [ ] anything at all'))"
printf -- '- reviewed by carol\n' >> _ops/tasks/T-H3.md
python3 "$HERE/transition.py" _ops/tasks/T-H3.md done --by carol >/dev/null 2>&1
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "the criterion was rewritten under '### Done when' and the close passed" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q
git rm -qf _ops/tasks/T-H3.md >/dev/null 2>&1; git commit -qm "h3 out" >/dev/null 2>&1

# ── a link inside a fenced example is an example ───────────────────────────────────────────
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '# T-FL — fenced link\n\n**Status**: started\n**Assignee**: worker-a\n\n## Notes\n\n```\n- [ ] [T-4F2K9Q](T-4F2K9Q-nowhere.md)\n```\n\n## History\n' > _ops/tasks/T-FL.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "a link inside a fenced example was refused as a rotted link"
git checkout -q HEAD -- . 2>/dev/null; git reset -q; rm -f _ops/tasks/T-FL.md

# ── §1c must catch a second home whichever commit it arrives in, and strand no legacy task ──
# Counting only the ADDED lines refused two homes arriving together and nothing else, so the
# ordinary path was silent: create the task normally, commit, append `stage:` next commit. The
# block's own comment claimed it refused "CREATING a second home" and it did not. Measured
# 2026-08-15 (pass nine, cold read). Asserted as a TRIO — the legacy row is what makes the other
# two mean something, because the easy way to catch creation is to strand every old project.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '# T-ONE\n\n**Type**: build · **Status**: started\n**Assignee**: ui\n\n## History\n' > _ops/tasks/T-ONE.md
printf '# T-LEG\n\n**Status**: started\n**Assignee**: ui\nstage: review\n\n## History\n' > _ops/tasks/T-LEG.md
git add -A && git commit -qm "1c-head fixtures" >/dev/null 2>&1
printf '\n<!-- machine-readable -->\nstage: review\n' >> _ops/tasks/T-ONE.md
git add _ops/tasks/T-ONE.md
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "a second state home appended in a later commit passed" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf -- '- a note\n' >> _ops/tasks/T-LEG.md
git add _ops/tasks/T-LEG.md
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && ok || bad "editing a legacy task that already carried two homes was refused — stranding"
git checkout -q HEAD -- . 2>/dev/null; git reset -q
git rm -qf _ops/tasks/T-ONE.md _ops/tasks/T-LEG.md >/dev/null 2>&1
git commit -qm "1c-head fixtures out" >/dev/null 2>&1

# ── §1c's two blind spots, both measured 2026-08-15 (pass nine) ────────────────────────────
# (a) two homes on ONE line — the shape this section's own refusal recommends. `grep -co` counts
#     matching LINES on GNU grep, so the count was 1 and it passed.
# (b) a commit that CLOSES a fence opened earlier and then appends real fields. Fence state was
#     derived from the stream of `+` lines, so the lone marker turned the flag on and hid them.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '# T-1L\n\n**Assignee**: ui\n\n## History\n' > _ops/tasks/T-1L.md
printf '# T-FC\n\n**Assignee**: ui\n\n## Notes\n\n```\nan example\n' > _ops/tasks/T-FC.md
git add -A && git commit -qm "1c fixtures" >/dev/null 2>&1
printf '**Type**: build · **Status**: doing · **Stage**: review\n' >> _ops/tasks/T-1L.md
git add _ops/tasks/T-1L.md
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "two state homes on one line passed §1c" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q
printf '```\n\n**Status**: doing\nstage: review\n' >> _ops/tasks/T-FC.md
git add _ops/tasks/T-FC.md
bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
  && bad "two state homes hidden behind a closing fence passed §1c" || ok
git checkout -q HEAD -- . 2>/dev/null; git reset -q
git rm -qf _ops/tasks/T-1L.md _ops/tasks/T-FC.md >/dev/null 2>&1
git commit -qm "1c fixtures out" >/dev/null 2>&1

# ── a path with a space must not be a bypass ───────────────────────────────────────────────
# Every gate here read its file list out of an unquoted `for … in $(git diff --name-only)`, so
# one space in a filename split it into two names that match nothing and every section went
# silent — no refusal, no diagnostic, exit 0. Measured 2026-08-15 (pass nine): byte-identical
# hand-edits to a control and to `T-BYP001 hand edit.md` gave two refusals and zero. Asserted as
# a PAIR, because the control is what makes the zero mean something.
git checkout -q HEAD -- . 2>/dev/null; git reset -q
# A NEWLINE is the same class and the first repair missed it: BSD grep still treats \n as a line
# terminator for ^ and $ inside a -z record, so `grep -zE '^…$'` DROPPED the record and every gate
# went silent again. Measured 2026-08-15 (pass ten). git's own pathspec does the filtering now, so
# no path meets a line-oriented tool at all — and this asserts the newline case, not just the space.
nl_name=$(printf 'T-SP with\nnewline.md')
for nm in "T-SP-control.md" "T-SP with space.md" "$nl_name"; do
  printf '# %s\n\n**Status**: started\n**Assignee**: worker-a\n\n## Done when\n\n- [ ] a thing\n\n## History\n' "$nm" > "_ops/tasks/$nm"
done
git add -A && git commit -qm "space fixture" >/dev/null 2>&1
for nm in "T-SP-control.md" "T-SP with space.md" "$nl_name"; do
  # ONLY the status. The fixture used to edit the acceptance bar in the same breath, so it tripped
  # §10 as well as §14 — and a pair satisfied by two gates pins neither: an adversarial lens
  # reverted §14's file loop and this assertion stayed green. Measured 2026-08-15 (pass ten).
  python3 -c "
import pathlib, sys
p = pathlib.Path(sys.argv[1])
p.write_text(p.read_text().replace('**Status**: started', '**Status**: done'))" "_ops/tasks/$nm"
  git add "_ops/tasks/$nm"
  bash _ops/scripts/preflight.sh >/dev/null 2>&1 \
    && bad "a hand-flipped status in '$nm' passed — the gate is blind to this path" || ok
  git checkout -q HEAD -- . 2>/dev/null; git reset -q
done
git rm -qf "_ops/tasks/T-SP-control.md" "_ops/tasks/T-SP with space.md" "_ops/tasks/$nl_name" >/dev/null 2>&1
git commit -qm "space fixture out" >/dev/null 2>&1

echo "company-preflight: $pass passed, $fail failed"
exit "$fail"
