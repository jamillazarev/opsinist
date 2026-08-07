#!/usr/bin/env bash
# The 0.2.0 layout migrator exercised on a flat 0.1.x fixture: history-preserving
# moves, the hook and .gitignore following their files, the craft's docs/ left
# alone, a dirty tree refused, a second run finding nothing, a collision named.
set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d /tmp/opsinist-migrate-test.XXXXXX)
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/repo"; cd "$T/repo"
git init -q -b main . && git config user.email t@f.t && git config user.name T

mkdir -p docs/tooling tasks cohorts scripts src .index
printf 'adapter: claude\n' > config.md
printf '# Company\n' > docs/COMPANY.md
printf '# Decisions\n' > docs/DECISIONS.md
printf '# Ops guide\n' > docs/tooling/deploy.md
printf 'the craft own notes\n' > docs/handbook.md
printf '**Status**: started\n' > tasks/T-1.md
printf '# Beta readers\n' > cohorts/beta.md
printf 'echo net\n' > scripts/preflight.sh
printf 'code\n' > src/app.py
printf '.index/\n.opsinist-checkout\n' > .gitignore
printf 'w-1\n' > .opsinist-checkout
printf '{}\n' > .index/cache.json
printf '#!/bin/sh\nbash scripts/preflight.sh || exit 1\n' > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
git add -A && git commit -qm flat

pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }

# another system's tree is refused whole — the shared door read before any move
printf '# Guide\n\n**Operated by:** otherops 9.9.9\n' > CLAUDE.md
git add -A && git commit -qm operator
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1 && bad "sibling-operated tree was migrated" || ok
grep -q 'another system' "$T/out.txt" && [ -f tasks/T-1.md ] && ok || bad "refusal unnamed or something moved"
git rm -q CLAUDE.md && git commit -qm rm-operator

# a dirty tree is refused, and nothing moves
printf 'x\n' >> src/app.py
python3 "$HERE/migrate-layout.py" . >/dev/null 2>&1 && bad "dirty tree was not refused" || ok
[ -f tasks/T-1.md ] && ok || bad "refusal still moved something"
git checkout -q src/app.py

# the migration: git-mv moves, renames applied, followers rewritten
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1 || bad "migration exited nonzero: $(cat "$T/out.txt")"
[ -f _ops/config.md ] && [ -f _ops/ABOUT.md ] && [ -f _ops/tasks/T-1.md ] \
  && [ -f _ops/panels/beta.md ] && [ -f _ops/runbooks/deploy.md ] \
  && [ -f _ops/scripts/preflight.sh ] && [ -f _ops/.checkout ] \
  && ok || bad "a recognised path did not land under _ops/"
git diff --cached --name-status | grep -q '^R.*tasks/T-1.md' && ok || bad "moves are not history-preserving renames"
grep -q '_ops/scripts/preflight.sh' .git/hooks/pre-commit && ok || bad "the hook did not follow the preflight"
grep -q '_ops/.index/' .gitignore && ok || bad ".gitignore did not follow .index"
[ -f docs/handbook.md ] && grep -q 'handbook.md' "$T/out.txt" && ok || bad "the craft's docs/ was not left alone and named"

# a second run finds nothing
git commit -qm migrate
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1
grep -q 'nothing to migrate' "$T/out.txt" && ok || bad "second run was not a no-op"

# a collision is a named CONFLICT and a nonzero exit, never an overwrite
mkdir -p tasks && printf 'stray\n' > tasks/T-9.md
git add -A && git commit -qm stray
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1 && bad "collision exited zero" || ok
grep -q 'CONFLICT' "$T/out.txt" && [ -f tasks/T-9.md ] && ok || bad "collision was moved or unnamed"

echo "migrate-layout: $pass passed, $fail failed"
exit "$fail"
