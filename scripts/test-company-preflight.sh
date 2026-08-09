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
git add -A && git commit -qm fixture

pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }

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

# §15 · a generated asset with no recipe is refused; the honest twin passes. Three cases,
# because the near-miss is the one that matters: a row that carries a prompt and no seed is
# the shape a hurried author actually produces, and `seed: none` must be a real door.
cat > _ops/assets.md <<'EOF'
# Assets

| Asset | Source | Licence | Where |
|---|---|---|---|
| hero.png | generated, fal.ai | owned | site header |
EOF
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a generated asset with no recipe passed" || ok

# the near miss: prompt written, seed forgotten
sed -i '' 's/| generated, fal.ai |/| generated, fal.ai, model: flux-1.1-pro, prompt: `a slate roof at dusk` |/' _ops/assets.md
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a generated asset with no seed passed" || ok

# the honest twin — and `seed: none` is a real answer, not a loophole to be denied
sed -i '' 's/`a slate roof at dusk` |/`a slate roof at dusk`, seed: none |/' _ops/assets.md
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "a recipe-carrying asset was refused"

# and a register with no generated rows at all never sees this check
printf '# Assets\n\n| Asset | Source | Licence | Where |\n|---|---|---|---|\n| logo.svg | drawn in-house | owned | everywhere |\n' > _ops/assets.md
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "a register with no generated rows was refused"

# §16 · a `hand` carries one operation, not the job. The case that matters is the plausible one:
# a request that reads like a sentence somebody would actually write and still hands over the
# whole task. And the check must stay blind to every other kind, or it fires on the four that
# were here first.
mkdir -p _ops/requests
hand() { printf '# R-1 — an image for the launch post\n\n**kind**: hand\n\n%s\n' "$1" > _ops/requests/R-1.md; git add -A; }

hand '**Ask**: we need an image for the post.'
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a hand with no payload, predicate or destination passed" || ok

# the plausible near miss: a real payload, and nothing that decides whether what comes back is right
hand '**Payload**: `a slate roof at dusk, 3:2, no text`
**Destination**: `assets/posts/launch-hero.png`'
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a hand with no predicate passed" || ok

# and the mirror of it — a predicate with nothing to run
hand '**Predicate**: the roof fills the upper third and no text appears
**Destination**: `assets/posts/launch-hero.png`'
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && bad "a hand with no payload passed" || ok

# the honest twin
hand '**Payload**: `a slate roof at dusk, 3:2, no text`
**Predicate**: the roof fills the upper third and no text appears
**Destination**: `assets/posts/launch-hero.png`
**Return with it**: the model and the seed'
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "a complete hand was refused"

# the four older kinds owe none of this — a check that fires on them is a check people switch off
printf '# R-2 — merge?\n\n**kind**: approval\n\n**Ask**: merge the release branch?\n' > _ops/requests/R-2.md
git add -A
bash _ops/scripts/preflight.sh >/dev/null 2>&1 && ok || bad "an approval request was caught by the hand check"

rm -rf _ops/requests && git add -A

echo "company-preflight: $pass passed, $fail failed"
exit "$fail"
