#!/usr/bin/env bash
# guard-status.py — is the project's guard installed, current, and wired — shown on throwaway
# repositories in every state it must tell apart: no guard · a guard under the template's own name ·
# a stale guard · doors missing · no hook · a hook that is somebody else's · a hook that is not
# executable · a hook under `core.hooksPath`, where looking in `.git/hooks` reports the wrong answer.
#
# **Two code mutants**: the hooks directory read as `.git/hooks` instead of asked for, and the guard
# found by one documented name instead of by its stamp — the shape a live project was measured in.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
S="$HERE/guard-status.py"
V=$(sed -n 's/^#[[:space:]]*guard-version:[[:space:]]*\([0-9.]*\).*/\1/p' "$HERE/../templates/company-preflight.sh" | head -1)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
has() { [ "$(printf '%s\n' "$OUT" | grep -cF -- "$1")" -gt 0 ]; }   # grep -c: no pipe can eat it
run() { OUT=$(python3 "${MUT:-$S}" "$1" 2>&1); RC=$?; }

# a project: the guard under a name of the caller's choosing, its doors, and a git repository
project() {   # $1 dir · $2 guard path relative to it (empty = no guard) · $3 version
  rm -rf "$1"; mkdir -p "$1"; git -C "$1" init -q .
  git -C "$1" config user.email t@f.t; git -C "$1" config user.name T
  if [ -n "$2" ]; then
    mkdir -p "$1/$(dirname "$2")"
    { printf '#!/usr/bin/env bash\n# guard-version: %s   <!-- stamped -->\necho guard\n' "$3"
    } > "$1/$2"
    printf '# door\n' > "$1/$(dirname "$2")/transition.py"
    printf '# door\n' > "$1/$(dirname "$2")/new-id.py"
  fi
}
wire() {   # $1 dir · $2 hooks dir relative to it
  mkdir -p "$1/$2"
  printf '#!/bin/sh\n# managed by opsinist company-preflight\nexec bash _ops/scripts/preflight.sh\n' > "$1/$2/pre-commit"
  chmod +x "$1/$2/pre-commit"
}

# ── the states it must tell apart ──────────────────────────────────────────────────────────────
run "$T/nothing-here"
[ "$RC" = 1 ] && has 'not a git repository' && ok || bad "a directory that is not a repository was not said to be one"

project "$T/bare" "" ""
run "$T/bare"
[ "$RC" = 1 ] && has 'no guard in this project' && ok || bad "a project with no guard passed as one with a guard"

project "$T/unwired" "_ops/scripts/preflight.sh" "$V"
run "$T/unwired"
[ "$RC" = 1 ] && has 'nothing is wired' && has 'the guard is here' && ok \
  || bad "a guard copied but not wired was not reported: $OUT"

wire "$T/unwired" ".git/hooks"; run "$T/unwired"
[ "$RC" = 0 ] && has "the hook is wired, and it is the guard's own" && ok || bad "a wired guard was not seen as wired: $OUT"

# the live project's own shape: the guard keeps the template's filename
project "$T/template-name" "_ops/scripts/company-preflight.sh" "$V"; wire "$T/template-name" ".git/hooks"
run "$T/template-name"
[ "$RC" = 0 ] && has 'the guard is here (_ops/scripts/company-preflight.sh' && ok \
  || bad "a guard under the template's own name was not found: $OUT"

# a stale guard does not complain; it does less
project "$T/stale" "_ops/scripts/preflight.sh" "0.0.1"; wire "$T/stale" ".git/hooks"
run "$T/stale"
[ "$RC" = 1 ] && has 'it does less' && ok || bad "a guard four versions behind passed as current: $OUT"

# §1 refuses a wired project whose doors are absent
project "$T/nodoors" "_ops/scripts/preflight.sh" "$V"; rm -f "$T/nodoors/_ops/scripts/transition.py"
wire "$T/nodoors" ".git/hooks"; run "$T/nodoors"
[ "$RC" = 1 ] && has 'the doors are not beside it: transition.py' && ok || bad "a missing door was not reported: $OUT"

# somebody else's hook, and a hook git skips because it is not executable
project "$T/alien" "_ops/scripts/preflight.sh" "$V"; mkdir -p "$T/alien/.git/hooks"
printf '#!/bin/sh\nexec npx lint-staged\n' > "$T/alien/.git/hooks/pre-commit"; chmod +x "$T/alien/.git/hooks/pre-commit"
run "$T/alien"
[ "$RC" = 1 ] && has "is not this guard's" && ok || bad "another tool's pre-commit passed as ours: $OUT"

project "$T/noexec" "_ops/scripts/preflight.sh" "$V"; wire "$T/noexec" ".git/hooks"
chmod -x "$T/noexec/.git/hooks/pre-commit"; run "$T/noexec"
[ "$RC" = 1 ] && has 'not executable, so git skips it silently' && ok || bad "a hook git would skip was called wired: $OUT"

# core.hooksPath moves the hooks directory — looking in .git/hooks answers about the wrong one
project "$T/hookspath" "_ops/scripts/preflight.sh" "$V"
git -C "$T/hookspath" config core.hooksPath .husky
wire "$T/hookspath" ".git/hooks"          # wired in the place git no longer reads
run "$T/hookspath"
[ "$RC" = 1 ] && has 'nothing is wired' && ok || bad "a hook in an unread directory passed as wired: $OUT"
wire "$T/hookspath" ".husky"; run "$T/hookspath"
[ "$RC" = 0 ] && ok || bad "a hook under core.hooksPath was not found: $OUT"

# ── the mutants ────────────────────────────────────────────────────────────────────────────────
mutant() {   # $1 what it breaks · $2 from · $3 to
  cp "$S" "$T/mut.py"
  M_FROM="$2" M_TO="$3" python3 - "$T/mut.py" <<'PY' || { bad "MUTATION DID NOT APPLY: $1"; return 1; }
import os, sys
p = sys.argv[1]; s = open(p).read(); a, b = os.environ["M_FROM"], os.environ["M_TO"]
assert s.count(a) == 1, "found %d times" % s.count(a)
open(p, "w").write(s.replace(a, b))
PY
  MUT="$T/mut.py"
}
# its own fixture: wired only where git no longer looks, so the honest script says "nothing is wired"
project "$T/hookspath-only" "_ops/scripts/preflight.sh" "$V"
git -C "$T/hookspath-only" config core.hooksPath .husky
wire "$T/hookspath-only" ".git/hooks"
run "$T/hookspath-only"
[ "$RC" = 1 ] && ok || bad "the mutant's fixture is not the state it needs — the honest script already passes it"
mutant "the hooks directory assumed, not asked for" 'hooks = git(root, "rev-parse", "--git-path", "hooks")' 'hooks = ".git/hooks"' \
  && { run "$T/hookspath-only"; [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: hooks directory assumed"; }
mutant "the guard found by one name" '"_ops/scripts/company-preflight.sh", "_ops/preflight.sh"' '"_ops/nowhere.sh"' \
  && { run "$T/template-name"; has 'no guard in this project' && ok || bad "the suite did not catch the mutant: guard found by name only"; }
MUT=""

echo "guard-status: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
