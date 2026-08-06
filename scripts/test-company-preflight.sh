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

echo "company-preflight: $pass passed, $fail failed"
exit "$fail"
