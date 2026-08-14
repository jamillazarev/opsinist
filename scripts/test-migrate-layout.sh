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
# `|| true` before the pipe: this file sets pipefail, so a failing left side returns through a
# MATCHING grep and the assertion reads a found phrase as absent. Benign here today — `git
# diff` without `--exit-code` returns 0 — but it is the shape that lied once already.
( git diff --cached --name-status || true ) | grep -q '^R.*tasks/T-1.md' && ok || bad "moves are not history-preserving renames"
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

# the doors ride the migration. Until 2026-08-14 this was prose in `project-layout.md` while
# the script copied only the guard — so an existing project taking 0.2.7's guard was refused on
# every commit by a message telling it to copy files "from the skill", a path a project cannot
# resolve. Both cases below are the ones that actually occur: a project already on `_ops/`
# (every upgrade), and a flat project whose guard only lands under `_ops/` mid-run.
[ -f _ops/scripts/transition.py ] && [ -f _ops/scripts/new-id.py ] \
  && ok || bad "the flat migration did not bring the doors with the guard"
grep -q 'sys.argv\|argparse' _ops/scripts/transition.py \
  && ok || bad "the door that landed is not the door — the guard tests that it reads arguments"

rm -f _ops/scripts/transition.py _ops/scripts/new-id.py
git add -A && git commit -qm "doors lost"
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1
[ -f _ops/scripts/transition.py ] && [ -f _ops/scripts/new-id.py ] \
  && ok || bad "an already-_ops project did not get its doors back"
grep -q 'doors re-copied' "$T/out.txt" && ok || bad "the re-copy happened silently"
( git diff --cached --name-only || true ) | grep -q '_ops/scripts/transition.py' \
  && ok || bad "the re-copied door was left unstaged, so the migration commit would not carry it"

# and a third run is a true no-op: identical bytes are not a re-copy
git commit -qm "doors back"
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1
grep -q 'doors re-copied' "$T/out.txt" && bad "re-copied identical doors and called it work" || ok

# Three shapes measured 2026-08-14: a customised door overwritten in silence against this file's
# own "never a silent overwrite"; `git add`'s result discarded, so an ignored path leaves the door
# in the worktree and out of the commit; and the already-_ops exit staging work it never mentioned,
# so the NEXT run hit the dirty-tree refusal against a docstring promising a no-op.
# the collision fixture above leaves tasks/T-9.md at the root, which keeps the migrator off its
# already-`_ops/` exit — clear it so this block exercises the path it is about
rm -rf tasks
printf 'custom door, do not clobber\n' > _ops/scripts/transition.py
git add -A && git commit -qm "customised door"
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1
grep -q 'differed from the shipped door and was replaced' "$T/out.txt" \
  && ok || bad "a customised door was replaced in silence"
ls _ops/scripts/transition.py.replaced-* >/dev/null 2>&1 && ok || bad "the replaced door was not kept"
# a second replacement must not clobber the first keep — the prescribed flow runs twice
printf 'a different custom door\n' > _ops/scripts/transition.py
git add -A && git commit -qm "customised again"
python3 "$HERE/migrate-layout.py" . >/dev/null 2>&1
[ "$(ls _ops/scripts/transition.py.replaced-* 2>/dev/null | wc -l | tr -d ' ')" -ge 2 ] \
  && ok || bad "the second replacement overwrote the first keep, losing the project's own edits"
grep -q 'Commit them before running this again' "$T/out.txt" \
  && ok || bad "work was staged and the operator was not told to commit it"
rm -f _ops/scripts/transition.py.replaced-*; git add -A; git commit -qm "doors restored"

# an ignore only bites an UNTRACKED path, so the door has to leave the index first — which is
# exactly the shape that produced the measured case: a project that never tracked its doors
git rm -q --cached _ops/scripts/new-id.py
printf '_ops/scripts/*.py\n' >> .gitignore
git add -A && git commit -qm "ignore the doors"
printf 'clobber me\n' > _ops/scripts/new-id.py
python3 "$HERE/migrate-layout.py" . > "$T/out.txt" 2>&1
grep -q 'written but NOT staged' "$T/out.txt" \
  && ok || bad "an ignored door was reported as re-copied while the commit would not carry it"
git checkout -q .gitignore 2>/dev/null || true

echo "migrate-layout: $pass passed, $fail failed"
exit "$fail"
