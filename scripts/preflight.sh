#!/usr/bin/env bash
# Preflight — the structural gate. Runs locally before a commit and in CI on every push.
#
# It checks shape and existence. It cannot check that a paragraph is still true — that is
# what the four lenses and the eval pass are for (AGENTS.md). Keep it small: a checker that
# cries wolf gets bypassed, and then none of it is enforced.
set -uo pipefail
cd "$(dirname "$0")/.."          # the repository root: skills/advisor/SKILL.md, its chapters and the
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

# 1a · the guide template names the doors. The 2026-08-10 field report measured the cost of
#      this hole: a high-tier run hand-edited stages, recorded a 223k-token dispatch as a History
#      sentence, and created no pipeline files — because the one file every worker loads named
#      none of them. The repair form is the corpus's own measured one (a list of paths placed
#      before the alternative), and this check keeps the list from silently eroding.
# Anchored to the BLOCK, not the substring: a lens defeated the first version by leaving the
# four paths in an HTML comment while deleting the block itself — the guide stopped telling
# workers the doors and the check stayed green. Comments are stripped first, then the paths
# must sit inside the block that starts at the doors heading.
doors_block=$(perl -0pe 's/<!--.*?-->//gs' "$ROOT/templates/GUIDE-template.md" \
  | sed -n '/\*\*The doors — run these/,/^$/p')
[ -n "$doors_block" ] || say_fail \
  "templates/GUIDE-template.md has no doors block — the measured repair for the \
operational-scripts hole (2026-08-10 report) is gone"
for door in "_ops/scripts/transition.py" "_ops/runs/" "_ops/pipelines/" "_ops/scripts/new-id.py"; do
  printf '%s' "$doors_block" | grep -qF "$door" || say_fail \
    "the doors block in templates/GUIDE-template.md no longer names $door — a guide that stops \
naming a door recreates the hole"
done
grep -qF 'scripts/transition.py' "$ROOT/starting.md" || say_fail \
  "starting.md no longer installs the doors on day one — the guard's §14 points at \
_ops/scripts/transition.py, and installing the refusal without the door strands the next commit"

# 1b · and everywhere a human wrote it. Two files agreeing proves nothing about the third: a
# release badge sat hardcoded at a version while the frontmatter moved, and the newest changelog
# heading is the other place a release quietly disagrees with itself.
cl=$(grep -m1 '^## [0-9]' "$ROOT/CHANGELOG.md" | sed 's/^## \([0-9.]*\).*/\1/')
[ "$cl" = "$sv" ] || say_fail "newest CHANGELOG heading is $cl, declared version is $sv"
for stray in $(grep -oE '\b[0-9]+\.[0-9]+\.[0-9]+\b' "$ROOT/README.md" | sort -u); do
  [ "$stray" = "$sv" ] || say_fail "README.md states version $stray — declared version is $sv"
done
# The runsheet too: N65's setup writes "you are on the current version" into a fixture guide, and
# a number a scenario depends on being *current* rots the moment a release moves without it. The
# other rows name older versions on purpose, so only the ones claiming to be current are checked.
for stray in $(grep -oE 'Operated by:\*\* Opsinist \*\*[0-9]+\.[0-9]+\.[0-9]+' "$ROOT/evals/runsheet.tsv" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sort -u); do
  [ "$stray" = "$sv" ] || say_fail "evals/runsheet.tsv sets a fixture to version $stray as though current — declared version is $sv"
done

# 2 · the core stays inside the budget it declares
budget=$(grep -m1 '^core_budget:' skills/advisor/SKILL.md | awk '{print $2}')
lines=$(wc -l < skills/advisor/SKILL.md | tr -d ' ')
if [ -z "$budget" ]; then
  say_fail "skills/advisor/SKILL.md declares no core_budget"
elif [ "$lines" -gt "$budget" ]; then
  say_fail "skills/advisor/SKILL.md is $lines lines, over its declared budget of $budget — move detail to a chapter"
else
  pct=$(( lines * 100 / budget ))
  say_ok "core $lines/$budget lines (${pct}%)"
  [ "$pct" -gt 90 ] && say_warn "core is at ${pct}% of its budget — moving beats squeezing"
fi

# 3 · the three files everything cites must exist
for f in GLOSSARY.md PATTERNS.md lenses.md; do
  [ -f "$f" ] || say_fail "$f is missing — the corpus cites it throughout"
done

# 4 · every chapter named in the routing table exists
python3 - <<'PY' || FAIL=1
import re, sys, pathlib
t = pathlib.Path("skills/advisor/SKILL.md").read_text(encoding="utf-8")
named = set(re.findall(r'`([a-z][a-z0-9-]*\.md)`', t))
# The core also names files that live in the *owner's* project, not in this repository, and
# they are lowercase like the chapters are. Uppercase project files (`LATER.md`,
# `docs/DECISIONS.md`) never collided; this one does. Kept as a short explicit list rather
# than a pattern, because every name added here is one the check stops guarding — if it grows
# past a couple of entries, the check is being weakened rather than corrected.
named -= {"config.md"}
missing = sorted(n for n in named if not pathlib.Path(n).exists())
if missing:
    for m in missing:
        print(f"  \033[31m✗\033[0m skills/advisor/SKILL.md routes to {m}, which does not exist")
    sys.exit(1)
print(f"  \033[32m✓\033[0m routing table: {len(named)} chapters, all present")
PY

# 5 · every command points at a chapter that exists, and declares a description
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

# 8b · no chapter outgrows the core. The core is capped because it is always loaded; a
# chapter pulled in by a trigger must not cost more than the thing that is always there, or the
# saving the cap exists for is spent on the first routing hop.
cbudget=$(grep -m1 '^chapter_budget:' skills/advisor/SKILL.md | awk '{print $2}')
if [ -z "$cbudget" ]; then
  say_fail "skills/advisor/SKILL.md declares no chapter_budget"
else
  over=0; big=""; top=0; topf=""
  for f in *.md; do
    case "$f" in README.md|CHANGELOG.md|AGENTS.md|TRADEMARKS.md|skills/advisor/SKILL.md) continue;; esac
    n=$(grep -c '' "$f")
    [ "$n" -gt "$top" ] && { top=$n; topf=$f; }
    [ "$n" -gt "$cbudget" ] && { over=$((over+1)); big="$big $f($n)"; }
  done
  if [ "$over" -gt 0 ]; then
    say_fail "$over chapter(s) over the $cbudget-line budget:$big"
  else
    say_ok "every chapter inside $cbudget lines (largest: $topf at $top)"
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

# 12 · every manifest this repo ships carries the same version — the sweep the ritual asks
#      for, held here rather than remembered (found by the lenses: a bump hit four of seven,
#      the four hid the three, and find-installs reads installs, not this tree).
ref=$(sed -n 's/^version: //p' skills/advisor/SKILL.md | head -1)
for mf in package.json gemini-extension.json .claude-plugin/plugin.json \
          .codex-plugin/plugin.json .cursor-plugin/plugin.json .kimi-plugin/plugin.json; do
  [ -f "$mf" ] || continue
  v=$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$mf" | head -1)
  [ "$v" = "$ref" ] || say_fail "$mf declares $v while SKILL.md declares $ref — one bump, seven manifests"
done

# 11 · the shipped guards are exercised, not hoped: a validator whose test only runs when
#      somebody remembers is a hope with a filename (found by the lenses — both tests were
#      green and nothing ran them).
# the hook wiring: hooks.json must parse, and every command file it names must exist —
# a renamed hook script fails silently at runtime, which is the blind spot class the
# sibling paid for ("a guard must not share its sweep's blind spot")
python3 - <<'PY' || FAIL=1
import json, os, re, sys
try:
    h = json.load(open("hooks/hooks.json"))
except Exception as e:
    print(f"  \033[31m✗\033[0m hooks/hooks.json does not parse: {e}"); sys.exit(1)
bad = []
for event, rules in (h.get("hooks") or {}).items():
    for rule in rules:
        for hook in rule.get("hooks", []):
            cmd = hook.get("command", "")
            m = re.search(r"\$\{CLAUDE_PLUGIN_ROOT\}/(\S+)", cmd)
            if m and not os.path.exists(m.group(1)):
                bad.append(f"{event}: {m.group(1)} does not exist")
for b in bad: print(f"  \033[31m✗\033[0m hooks.json → {b}")
if bad: sys.exit(1)
print(f"  \033[32m✓\033[0m hook wiring: hooks.json parses, every named file exists")
PY

# a raw "(" inside a markdown URL breaks every downstream link reader — percent-encode it
raw=$(grep -rEln '\]\([^) ]*\(' --include='*.md' . 2>/dev/null | grep -v '^\./\.git' || true)
if [ -n "$raw" ]; then say_fail "raw ( in a markdown URL — percent-encode: $raw"; else say_ok "no raw parens inside markdown URLs"; fi

# CORPUS_PF_TEST is set by test-corpus-preflight.sh when it runs THIS script inside a clone to
# exercise the doors check — the clone's preflight skips the suite battery, or the suite that
# calls preflight would call itself through every clone, forever.
if [ -z "${CORPUS_PF_TEST:-}" ]; then
for t in scripts/test-transition.sh scripts/test-inventory.sh scripts/test-company-preflight.sh scripts/test-map-blocks.sh scripts/test-migrate-layout.sh scripts/test-corpus-preflight.sh scripts/test-eval-requeue.sh; do
  [ -f "$t" ] || continue
  out=$(bash "$t" 2>&1 | tail -1)
  case "$out" in
    *" 0 failed") say_ok "${t##*/}: ${out}" ;;
    *) say_fail "${t##*/}: ${out:-did not run}" ;;
  esac
done
fi

echo
[ "$FAIL" = 0 ] && { printf '\033[32mpreflight passed\033[0m\n'; exit 0; }
printf '\033[31mpreflight failed\033[0m\n'; exit 1
