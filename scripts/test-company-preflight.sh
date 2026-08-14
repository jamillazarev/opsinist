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
( bash _ops/scripts/preflight.sh 2>&1 || true ) | grep -q "Ask your advisor to run the upgrade step" && ok || bad "the doors refusal lost its executable route"
# presence is not the door: an interrupted copy leaves a file of the right name and no command
: > _ops/scripts/transition.py
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "an empty file named transition.py passed as a door" || ok
printf 'print("hello")\n' > _ops/scripts/transition.py
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a .py that reads no arguments passed as a door" || ok
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
printf '%s' "$dayone" | grep -q "✗" \
  && bad "a by-the-book day one still draws a hard refusal" || ok
rm -rf "$D"

echo "company-preflight: $pass passed, $fail failed"
exit "$fail"
