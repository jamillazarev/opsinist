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
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q "state fields" \
  && ok || bad "the refusal does not say what it found"
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
p.write_text(p.read_text().replace('| **Attempt** | 3 |','| **Attempt** | 3 |' + chr(10) + '| **Reason** | escalated: the spec is wrong, raised as a relay |'))"
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "a third attempt that names its escalation was refused"
git rm -qf _ops/runs/R-5.md >/dev/null 2>&1; git commit -qm "R-5 out" >/dev/null 2>&1

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

echo "company-preflight: $pass passed, $fail failed"
exit "$fail"
