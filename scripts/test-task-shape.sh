#!/usr/bin/env bash
# §23 of the project guard — a task the commit CREATES has the shape the template gives it — and
# `scripts/new-task.py`, the door that writes that shape. Shown on a throwaway project in the two
# states a live one was measured in: the door's own file, and the dialect an agent invents when
# nothing refuses it (`# T-…: title`, fields as a list, its own section names).
#
# **The project's own translated template is obeyed**: a project working in Russian keeps
# `_ops/templates/TASK.md` with its headings, and the guard asks for those, not for English.
#
# **Three code mutants**: the project's template ignored, a placeholder accepted as a value, and
# the check widened from added files to every task, which would refuse a project's whole history.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }
said() { [ "$(printf '%s' "$OUT" | grep -cF -- "$1")" -gt 0 ]; }   # -F: `**` is not a repetition here
run() { git add -A; OUT=$(bash _ops/scripts/preflight.sh 2>&1); RC=$?; }

fixture() {
  rm -rf "$T/p"; mkdir -p "$T/p/_ops/tasks" "$T/p/_ops/scripts" "$T/p/_ops/process/types"
  cd "$T/p"
  git init -q . && git config user.email t@f.t && git config user.name T
  cp "${MUT:-$HERE/../templates/company-preflight.sh}" _ops/scripts/preflight.sh
  cp "$HERE/transition.py" "$HERE/new-id.py" _ops/scripts/ 2>/dev/null || true
  for f in ROADMAP TEAM TOOLING DECISIONS; do printf '# %s\n' "$f" > "_ops/$f.md"; done
  printf '# feature\n\n```yaml\nstages: [build, review, accept]\nterminal: accept\n```\n' > _ops/process/types/feature.md
  git add -A && git commit -qm fixture
}

# ── the door writes what the guard asks for ────────────────────────────────────────────────────
fixture
python3 "$HERE/new-task.py" --root . --title "the first thing" --type feature --assignee web-engineer >/dev/null
run; [ "$RC" = 0 ] && ok || bad "a task the door wrote was refused: $OUT"

# a hole the writer has not filled is not a value
python3 "$HERE/new-task.py" --root . --title "the second thing" --type feature >/dev/null
run; [ "$RC" = 1 ] && said 'carries a value' && ok || bad "a task with its Assignee still a placeholder passed: $OUT"

# ── the dialect an agent invents when nothing refuses it ───────────────────────────────────────
fixture
cat > _ops/tasks/T-8B94NJ-backend.md <<'EOF'
# T-8B94NJ: Бэкенд-агент

- **Type:** feature
- **Role:** Backend Engineer
- **Status:** review
- **Owner:** agent

## Что нужно сделать

Поднять сервис.

## Definition of Done

- [ ] Работает

## Лог

- 2026-09-01 — начали
EOF
run
[ "$RC" = 1 ] && said 'its first line reads' && said '## Ready when' && said '## History' && ok \
  || bad "the invented dialect passed, or the refusal did not name what was missing: $OUT"
said '`**Assignee**:` carries a value' && ok || bad "the refusal did not notice that Role replaced Assignee"

# ── a project translates the template, and the guard asks for what it says ─────────────────────
fixture
mkdir -p _ops/templates
cat > _ops/templates/TASK.md <<'EOF'
# {{T-XXXXXX}} — {{заголовок}}

**Type**: {{тип}} · **Status**: {{стадия}}
**Assignee**: {{роль}}

## Что нужно сделать

{{…}}

## Дети <!-- optional -->

{{…}}

## Готово когда

{{…}}

## Лог

{{…}}
EOF
git add -A && git commit -qm template
cat > _ops/tasks/T-RU1234-pervaya.md <<'EOF'
# T-RU1234 — Первая задача

**Type**: feature · **Status**: build
**Assignee**: web-engineer

## Что нужно сделать

Сделать.

## Готово когда

- [ ] Сделано

## Лог

- 2026-09-16 — создана
EOF
run; [ "$RC" = 0 ] && ok || bad "a task written to the project's own translated template was refused: $OUT"

cat > _ops/tasks/T-RU5678-vtoraya.md <<'EOF'
# T-RU5678 — Вторая задача

**Type**: feature · **Status**: build
**Assignee**: web-engineer

## Ready when

Written to the skill's headings, not this project's.

## Done when

- [ ] done

## History

- 2026-09-16 — made
EOF
run; [ "$RC" = 1 ] && said '## Что нужно сделать' && ok \
  || bad "a task using the skill's headings in a project that translated them passed: $OUT"

# ── history is not retro-fixed: an existing task, edited or renamed, is not judged ─────────────
fixture
cat > _ops/tasks/T-OLD111-legacy.md <<'EOF'
# T-OLD111: legacy

- **Type:** feature
- **Status:** review
EOF
git add -A && git commit -qm legacy
printf '\nOne more line.\n' >> _ops/tasks/T-OLD111-legacy.md
run; [ "$RC" = 0 ] && ok || bad "an existing task, merely edited, was judged by the new shape: $OUT"
git mv _ops/tasks/T-OLD111-legacy.md _ops/tasks/T-OLD111-renamed.md
run; [ "$RC" = 0 ] && ok || bad "a renamed existing task was judged as a new one: $OUT"

# ── the mutants ────────────────────────────────────────────────────────────────────────────────
mutant() {   # $1 what it breaks · $2 from · $3 to
  cp "$HERE/../templates/company-preflight.sh" "$T/mut.sh"
  M_FROM="$2" M_TO="$3" python3 - "$T/mut.sh" <<'PY' || { bad "MUTATION DID NOT APPLY: $1"; return 1; }
import os, sys
p = sys.argv[1]; s = open(p).read(); a, b = os.environ["M_FROM"], os.environ["M_TO"]
assert s.count(a) == 1, "found %d times" % s.count(a)
open(p, "w").write(s.replace(a, b))
PY
  MUT="$T/mut.sh"
}
mutant "the project's own template ignored" '        SECTIONS = kept' '        pass' && {
  fixture; mkdir -p _ops/templates
  printf '# {{T-XXXXXX}} — {{t}}\n\n**Type**: {{a}} · **Status**: {{b}}\n**Assignee**: {{c}}\n\n## Что нужно сделать\n\n## Готово когда\n\n## Лог\n' > _ops/templates/TASK.md
  git add -A && git commit -qm tpl
  printf '# T-RU1234 — Первая\n\n**Type**: feature · **Status**: build\n**Assignee**: web\n\n## Что нужно сделать\n\nx\n\n## Готово когда\n\nx\n\n## Лог\n\nx\n' > _ops/tasks/T-RU1234-pervaya.md
  run; [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: the project's template ignored"; }
mutant "a placeholder accepted as a value" '        if not m or not val or val.startswith("{{"):' '        if not m or not val:' && {
  fixture; python3 "$HERE/new-task.py" --root . --title "third" --type feature >/dev/null
  run; [ "$RC" = 0 ] && ok || bad "the suite did not catch the mutant: a placeholder as a value"; }
# the added file opens the section's own gate; what the mutant changes is which files it then judges
# the anchor carries §23's own path filter: `--diff-filter=A` alone now appears in three sections
mutant "every task judged, not only the added ones" \
  '"--diff-filter=A", "-z") or "").split("\0")
             if p.startswith("_ops/tasks/") and p.endswith(".md")' \
  '"--diff-filter=AM", "-z") or "").split("\0")
             if p.startswith("_ops/tasks/") and p.endswith(".md")' && {
  fixture
  printf '# T-OLD111: legacy\n\n- **Type:** feature\n' > _ops/tasks/T-OLD111-legacy.md
  git add -A && git commit -qm legacy
  printf '\nmore\n' >> _ops/tasks/T-OLD111-legacy.md
  python3 "$HERE/new-task.py" --root . --title "a new one" --type feature --assignee web >/dev/null
  run; [ "$RC" = 1 ] && ok || bad "the suite did not catch the mutant: a project's history refused"; }
MUT=""

echo "task-shape: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
