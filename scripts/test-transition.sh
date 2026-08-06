#!/usr/bin/env bash
# The transition door, exercised end to end on a throwaway fixture — same habit as
# test-audit-gate.sh: the guard is code, so the guard gets a test, or the guard is a hope.
set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d /tmp/opsinist-transition-test.XXXXXX)
trap 'rm -rf "$T"' EXIT
cd "$T"
git init -q . && git config user.email t@fixture.test && git config user.name T

mkdir -p _ops/pipelines _ops/process/types _ops/tasks scripts
cat > _ops/pipelines/design.md <<'EOF'
```yaml
name: design
stages: [brief, draft, review, handoff]
terminal: [handoff]
gates:
  draft->review:
    check: "bash scripts/gate.sh"
  review->handoff:
    review_by: non-author
    fields: [evidence]
```
EOF
printf 'build -> review -> accept\n' > _ops/process/types/default.md
printf '#!/bin/sh\nexit "${GATE_RC:-0}"\n' > scripts/gate.sh
cat > _ops/tasks/T-1.md <<'EOF'
# T-1 — the screen

**Type**: design-task · **Status**: draft
**Assignee**: worker-a
**Pipeline**: design

## History
EOF
git add -A && git commit -qm fixture

pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
run() { python3 "$HERE/transition.py" "$@" >"$T/out" 2>&1; echo $?; }

# a skip is refused: stages are linear
[ "$(run _ops/tasks/T-1.md handoff --by owner)" = 1 ] && grep -q linear "$T/out" \
  && ok || bad "skip was not refused as linear"

# a failing check refuses, and the output travels with the refusal
[ "$(GATE_RC=3 run _ops/tasks/T-1.md review --by worker-a)" = 1 ] \
  && grep -q 'exited 3' "$T/out" && ok || bad "failing check did not refuse with its exit"

# a clean check passes, the field moves, the history line lands
[ "$(run _ops/tasks/T-1.md review --by worker-a)" = 0 ] \
  && grep -qF '**Status**: review' _ops/tasks/T-1.md \
  && grep -qF 'transition draft → review, by worker-a' _ops/tasks/T-1.md \
  && ok || bad "clean forward move did not record"

# no review from a non-author, no evidence field → both reasons, one refusal
[ "$(run _ops/tasks/T-1.md handoff --by owner)" = 1 ] \
  && grep -q 'not the worker' "$T/out" && grep -q 'evidence' "$T/out" \
  && ok || bad "missing review/field did not both surface"

printf -- '- reviewed by bob: states drawn\n' >> _ops/tasks/T-1.md
printf '\n**Evidence**: runs/R-1.md\n' >> _ops/tasks/T-1.md

# terminal without --by is refused: acceptance is a named, deliberate act
[ "$(run _ops/tasks/T-1.md handoff)" = 1 ] && grep -q 'needs --by' "$T/out" \
  && ok || bad "terminal without --by slipped through"

# the worker may not accept their own work
[ "$(run _ops/tasks/T-1.md handoff --by worker-a)" = 1 ] && grep -q 'is the worker' "$T/out" \
  && ok || bad "self-acceptance slipped through"

# a named non-worker may
[ "$(run _ops/tasks/T-1.md handoff --by owner)" = 0 ] \
  && grep -qF '**Status**: handoff' _ops/tasks/T-1.md && ok || bad "owner acceptance failed"

# a return to an earlier stage is always open, and still recorded
[ "$(run _ops/tasks/T-1.md draft --by owner)" = 0 ] \
  && grep -q 'transition handoff → draft' _ops/tasks/T-1.md && ok || bad "return move failed"

# --brief names the stage, the next legal move, and whose act the terminal is not
python3 "$HERE/transition.py" _ops/tasks/T-1.md --brief >"$T/out" 2>&1
grep -q 'stage: draft' "$T/out" && grep -q 'legal: → review' "$T/out" \
  && grep -q 'not yours' "$T/out" && ok || bad "--brief missing a required line"

# no pipeline field → the type default's inline ladder is picked up and said
cat > _ops/tasks/T-2.md <<'EOF'
# T-2 — a chore

**Status**: build
**Assignee**: worker-b
EOF
[ "$(run _ops/tasks/T-2.md review --by worker-b)" = 0 ] && grep -q 'via type default' "$T/out" \
  && ok || bad "inline type-default ladder was not resolved"

# a prose gate warns and does not block — honestly prose-only. Built in its own FLAT
# fixture on purpose: a not-yet-migrated project has no _ops/, and the transitional
# fallback must resolve its pipelines from the root.
F=$(mktemp -d /tmp/opsinist-transition-flat.XXXXXX)
( cd "$F" && git init -q . && git config user.email t@fixture.test && git config user.name T )
mkdir -p "$F/tasks" "$F/pipelines"
cat > "$F/pipelines/legacy.md" <<'EOF'
```yaml
name: legacy
stages: [build, review, done]
gates:
  review: "every state drawn"
```
EOF
cat > "$F/tasks/T-3.md" <<'EOF'
**Status**: build · **Assignee**: w
**Pipeline**: legacy
EOF
[ "$(run "$F/tasks/T-3.md" review --by w)" = 0 ] && grep -q 'prose-only' "$T/out" \
  && ok || bad "legacy prose gate did not warn-and-pass through the flat fallback"
rm -rf "$F"

# an edge written with the corpus's own glyph — `draft → review` — still gates
cat > _ops/pipelines/uni.md <<'EOF'
```yaml
name: uni
stages: [draft, review]
gates:
  draft → review:
    check: "bash scripts/gate.sh"
```
EOF
cat > _ops/tasks/T-4.md <<'EOF'
**Status**: draft · **Assignee**: w
**Pipeline**: uni
EOF
[ "$(GATE_RC=3 run _ops/tasks/T-4.md review --by w)" = 1 ] && grep -q 'exited 3' "$T/out" \
  && ok || bad "a unicode-arrow gate was silently dropped"

# a sign-off outside History is a requirement, not a review
cat > _ops/tasks/T-5.md <<'EOF'
**Status**: review · **Assignee**: worker-a
**Pipeline**: design
**Evidence**: runs/R-2.md

Body: this ships only when approved by legal.

## History
EOF
[ "$(run _ops/tasks/T-5.md handoff --by owner)" = 1 ] && grep -q 'not the worker' "$T/out" \
  && ok || bad "body text passed as a review"
printf -- '- reviewed by bob: checked\n' >> _ops/tasks/T-5.md
[ "$(run _ops/tasks/T-5.md handoff --by owner)" = 0 ] \
  && ok || bad "a real History review did not pass"

echo "transition: $pass passed, $fail failed"
exit "$fail"
