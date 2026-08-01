#!/usr/bin/env bash
# Preflight — the structural gate. Runs locally before a commit and in CI on every push.
#
# It checks shape and existence. It cannot check that a paragraph is still true — that is
# what the four lenses and the eval pass are for (AGENTS.md). Keep it small: a checker that
# cries wolf gets bypassed, and then none of it is enforced.
set -uo pipefail
cd "$(dirname "$0")/.."          # the repository root: skills/advisor/SKILL.md, its companions and the
ROOT="$(pwd)"                    # manifests all live here, so corpus and root are one place

FAIL=0
say_fail() { printf '  \033[31m✗\033[0m %s\n' "$1"; FAIL=1; }
say_warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }
say_ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }

echo "preflight"

# 1 · version agreement
sv=$(grep -m1 '^version:' skills/advisor/SKILL.md | awk '{print $2}')
pv=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["version"])' "$ROOT/.claude-plugin/plugin.json")
[ "$sv" = "$pv" ] && say_ok "version $sv" \
  || say_fail "version mismatch: skills/advisor/SKILL.md=$sv plugin.json=$pv"

# 1b · and everywhere a human wrote it. Two files agreeing proves nothing about the third: a
# release badge sat hardcoded at a version while the frontmatter moved, and the newest changelog
# heading is the other place a release quietly disagrees with itself.
cl=$(grep -m1 '^## [0-9]' "$ROOT/CHANGELOG.md" | sed 's/^## \([0-9.]*\).*/\1/')
[ "$cl" = "$sv" ] || say_fail "newest CHANGELOG heading is $cl, declared version is $sv"
for stray in $(grep -oE '\b[0-9]+\.[0-9]+\.[0-9]+\b' "$ROOT/README.md" | sort -u); do
  [ "$stray" = "$sv" ] || say_fail "README.md states version $stray — declared version is $sv"
done

# 2 · the core stays inside the budget it declares
budget=$(grep -m1 '^core_budget:' skills/advisor/SKILL.md | awk '{print $2}')
lines=$(wc -l < skills/advisor/SKILL.md | tr -d ' ')
if [ -z "$budget" ]; then
  say_fail "skills/advisor/SKILL.md declares no core_budget"
elif [ "$lines" -gt "$budget" ]; then
  say_fail "skills/advisor/SKILL.md is $lines lines, over its declared budget of $budget — move detail to a companion"
else
  pct=$(( lines * 100 / budget ))
  say_ok "core $lines/$budget lines (${pct}%)"
  [ "$pct" -gt 90 ] && say_warn "core is at ${pct}% of its budget — moving beats squeezing"
fi

# 3 · the three files everything cites must exist
for f in GLOSSARY.md PATTERNS.md lenses.md; do
  [ -f "$f" ] || say_fail "$f is missing — the corpus cites it throughout"
done

# 4 · every companion named in the routing table exists
python3 - <<'PY' || FAIL=1
import re, sys, pathlib
t = pathlib.Path("skills/advisor/SKILL.md").read_text(encoding="utf-8")
named = set(re.findall(r'`([a-z][a-z0-9-]*\.md)`', t))
missing = sorted(n for n in named if not pathlib.Path(n).exists())
if missing:
    for m in missing:
        print(f"  \033[31m✗\033[0m skills/advisor/SKILL.md routes to {m}, which does not exist")
    sys.exit(1)
print(f"  \033[32m✓\033[0m routing table: {len(named)} companions, all present")
PY

# 5 · every command points at a companion that exists, and declares a description
python3 - <<'PY' || FAIL=1
import re, sys, pathlib
bad = []
# The doors moved to skills/<verb>/SKILL.md in the plugin restructure and this kept globbing
# `commands/`, a directory that no longer exists — so it printed "0 commands, each a door to a
# file that exists" and passed, vacuously, for every release since. A check that cannot fail
# is the failure this file exists to catch; the count is now asserted so an empty glob is red.
cmds = sorted(p for p in pathlib.Path("skills").glob("*/SKILL.md") if p.parent.name != "advisor")
if not cmds:
    print("  \033[31m✗\033[0m no command doors found under skills/ — the glob is looking in the wrong place")
    sys.exit(1)
for p in cmds:
    t = p.read_text(encoding="utf-8")
    if not re.match(r'^---\ndescription: \S', t):
        bad.append(f"{p}: no description in frontmatter")
    for target in re.findall(r'\[`([a-z][a-z0-9-]*\.md)`\]', t):
        if not pathlib.Path(target).exists():
            bad.append(f"{p}: points at {target}, which does not exist")
for b in bad:
    print(f"  \033[31m✗\033[0m {b}")
if bad: sys.exit(1)
print(f"  \033[32m✓\033[0m {len(cmds)} commands, each a door to a file that exists")
PY

# 6 · nothing from the platform this grew out of
# Built from parts so this file does not itself contain the strings it forbids.
pat="mul""tica\\|\\bm""ops\\b"
hits=$(grep -ril "$pat" --include='*.md' --include='*.py' --include='*.sh' \
        --include='*.json' --include='*.yml' "$ROOT" 2>/dev/null | grep -v '\.git/' | grep -v CHANGELOG.md)
[ -z "$hits" ] && say_ok "no predecessor references" \
  || { echo "$hits" | while read -r f; do say_fail "$f still names the predecessor"; done; FAIL=1; }

# 7 · cross-references resolve, file *and* section
if python3 scripts/check-links.py >/tmp/pf-links 2>&1; then
  say_ok "$(tail -1 /tmp/pf-links)"
else
  grep 'FAIL:' /tmp/pf-links | while read -r l; do say_fail "$l"; done; FAIL=1
fi

# 8 · recorded facts are not past their recheck
python3 scripts/check-freshness.py >/tmp/pf-fresh 2>&1
if grep -q '^0 FAIL' /tmp/pf-fresh; then
  say_ok "$(tail -1 /tmp/pf-fresh)"
else
  grep 'FAIL:' /tmp/pf-fresh | while read -r l; do say_fail "$l"; done; FAIL=1
fi
warns=$(grep -c 'WARN:' /tmp/pf-fresh || true)
[ "${warns:-0}" -gt 0 ] && say_warn "$warns rows carry no check-date or are ageing — see check-freshness"

# 8b · no companion outgrows the core. The core is capped because it is always loaded; a
# companion pulled in by a trigger must not cost more than the thing that is always there, or the
# saving the cap exists for is spent on the first routing hop.
cbudget=$(grep -m1 '^companion_budget:' skills/advisor/SKILL.md | awk '{print $2}')
if [ -z "$cbudget" ]; then
  say_fail "skills/advisor/SKILL.md declares no companion_budget"
else
  over=0; big=""; top=0; topf=""
  for f in *.md; do
    case "$f" in README.md|CHANGELOG.md|AGENTS.md|TRADEMARKS.md|skills/advisor/SKILL.md) continue;; esac
    n=$(grep -c '' "$f")
    [ "$n" -gt "$top" ] && { top=$n; topf=$f; }
    [ "$n" -gt "$cbudget" ] && { over=$((over+1)); big="$big $f($n)"; }
  done
  if [ "$over" -gt 0 ]; then
    say_fail "$over companion(s) over the $cbudget-line budget:$big"
  else
    say_ok "every companion inside $cbudget lines (largest: $topf at $top)"
  fi
fi

# 9 · nothing built is tracked. A `git add -A` during a squash once swept a site build into
# this tree and shipped 928K of fonts and bundles inside a package that is markdown. The commit
# looked fine; only a file inventory showed it.
built=$(git -C "$ROOT" ls-files 2>/dev/null | grep -cE '(^|/)(dist|node_modules)/|\.(woff2?|ttf|eot|map)$|\.min\.(js|css)$' || true)
if [ "${built:-0}" -gt 0 ]; then
  say_fail "$built built files are tracked — a package of markdown ships no bundles"
  git -C "$ROOT" ls-files | grep -E '(^|/)(dist|node_modules)/|\.(woff2?|ttf|eot|map)$|\.min\.(js|css)$' | head -5 | sed 's/^/      /'
else
  say_ok "nothing built is tracked"
fi

# 10 · heuristic structure guards (never fatal)
if [ -f scripts/check-structure.py ]; then
  python3 scripts/check-structure.py 2>/dev/null | while read -r line; do
    case "$line" in FAIL:*) say_warn "structure: ${line#FAIL:}" ;; WARN:*) say_warn "structure: ${line#WARN:}" ;; esac
  done
fi

echo
[ "$FAIL" = 0 ] && { printf '\033[32mpreflight passed\033[0m\n'; exit 0; }
printf '\033[31mpreflight failed\033[0m\n'; exit 1
