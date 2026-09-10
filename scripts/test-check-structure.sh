#!/usr/bin/env bash
# The corpus-count claims shown firing where a claim is made and silent where a record is kept.
#
# `check-structure.py` chdirs to its own parent's parent, so a fixture is a tree with a COPY of
# the script inside it — the same shape `test-corpus-preflight.sh` uses. That also lets one pair
# mutate **the rule itself** rather than the data: a scoping rule that silences a warning and a
# fixture with nothing to warn about return the identical silence (`facts.md` 254), so the only
# proof the scoping carries weight is that removing it brings the warning back.
#
# **Assert on what the script REPORTS, never on its exit code**: it prints `FAIL:`/`WARN:` lines
# for preflight to render and **exits 0 on every path**, so a suite testing the code is green on
# every mutant (`CLAUDE.md` → machine notes).
set -u

PY=${PY:-python3}
SRC=$(cd "$(dirname "$0")" && pwd)/check-structure.py
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }

# The honest twin. Two diagrams on disk; a chapter that says so; a changelog whose CURRENT entry
# (0.1.0, matching the fixture's SKILL.md) is honest, whose OLDER entry carries a count that was
# true on its date, and whose Trio line states a delta in a total's words.
twin() {
  mkdir -p "$T/scripts" "$T/skills/advisor"
  cp "$SRC" "$T/scripts/check-structure.py"
  printf 'version: 0.1.0\n' > "$T/skills/advisor/SKILL.md"
  printf '# D\n\n```mermaid\nflowchart TD\n  A-->B\n```\n\n```mermaid\nflowchart TD\n  C-->D\n```\n' > "$T/diagrams.md"
  printf '# Alpha\n\nThe corpus has two diagrams.\n' > "$T/alpha.md"
  printf '# Changelog\n\n## 0.1.0 — unreleased\n\nA release that added things.\n\n**Trio:** five diagrams, one situation.\n\n## 0.0.9 — 2026-01-01\n\nBack then there were nine diagrams.\n' > "$T/CHANGELOG.md"
}

run() { "$PY" "$T/scripts/check-structure.py" > "$T/out.txt" 2>&1; }
saw() { [ "$(grep -c "$1" "$T/out.txt")" -gt 0 ]; }   # grep -c drains, so no pipe can eat it

# ── the twin must pass, or every refusal below is meaningless ────────────────────────────────
twin; run
saw '^FAIL:' && bad "the honest twin was refused: $(cat "$T/out.txt")" || ok

# ── mutant 1 · a chapter's count drifts — this is the whole reason the check exists ──────────
twin
printf '# Alpha\n\nThe corpus has five diagrams.\n' > "$T/alpha.md"
# No apply-guard here: the write is one line up and unconditional, so a guard could only fire if
# printf itself failed. The guards below DO earn theirs — one patches a file with `sed`, which
# silently matches nothing, and one reads a string written inside `twin()`.
run
saw 'FAIL:alpha.md' && ok || bad "a chapter claiming five diagrams against two was accepted"
saw 'there are 2' && ok || bad "the refusal did not say what the real count is"

# ── the entry being WRITTEN is still compared. This is the assertion the first design failed:
#    exempting the whole file silenced the one entry that describes today's corpus. ───────────
twin
printf '# Changelog\n\n## 0.1.0 — unreleased\n\nThe corpus now has nine diagrams.\n\n## 0.0.9 — 2026-01-01\n\nOld.\n' > "$T/CHANGELOG.md"
[ "$(grep -c 'nine diagrams' "$T/CHANGELOG.md")" -gt 0 ] || bad "FIXTURE LOST ITS CURRENT-ENTRY CLAIM"
run
saw 'FAIL:CHANGELOG.md.*nine diagrams' && ok \
  || bad "a drifted count in the entry being written was not compared — the scope is too wide"
# …and it must name the line it is on IN THE FILE. A filtered body renumbers everything under
# it, and a checker naming the wrong line sends its reader to innocent text.
saw 'CHANGELOG.md:5' && ok || bad "the line number was reported relative to the entry, not the file"

# ── an OLDER entry is a dated record: its count was true when written, and is not compared ───
twin
[ "$(grep -c 'nine diagrams' "$T/CHANGELOG.md")" -gt 0 ] || bad "FIXTURE LOST ITS OLD-ENTRY CLAIM"
run
saw 'nine diagrams' && bad "a superseded entry's count was compared against today's corpus" || ok

# ── the Trio line states a DELTA in a total's words, and no corpus count can judge it ────────
twin
[ "$(grep -c 'Trio:\*\* five diagrams' "$T/CHANGELOG.md")" -gt 0 ] || bad "FIXTURE LOST ITS TRIO LINE"
run
saw 'five diagrams' && bad "the Trio line's delta was read as a claim about the corpus" || ok

# ── and the scoping is what does it: remove it, and both silenced lines are refused again ────
#    Without this pair the two checks above pass just as well on a fixture nothing ever read.
twin
# The mutation forces the documented fallback: with no version to find, the whole file is read.
sed -i '' 's/^    _v = re\.search/    _v = None; _unused = re.search/' "$T/scripts/check-structure.py"
[ "$(grep -c '_v = None; _unused' "$T/scripts/check-structure.py")" -gt 0 ] \
  || bad "MUTATION DID NOT APPLY (the scoping) — the pair below proves nothing"
run
saw 'nine diagrams' && ok \
  || bad "with the scoping removed the old entry still passed — the scope is not what silences it"

#    …and the Trio exemption isolated from the scoping. The mutation above kills BOTH, because the
#    Trio filter lives inside the same branch — so on its own it cannot tell which one silenced the
#    line. This one neuters only the filter, with the scoping intact.
twin
sed -i '' 's/if l\.lstrip()\.startswith("\*\*Trio:\*\*"):/if False:/' "$T/scripts/check-structure.py"
[ "$(grep -c 'if False:' "$T/scripts/check-structure.py")" -gt 0 ] \
  || bad "MUTATION DID NOT APPLY (the Trio filter) — the assertion below proves nothing"
run
saw 'five diagrams' && ok \
  || bad "with only the Trio filter removed the line still passed — the filter is not what silences it"

# ── the exempt lines are BLANKED, never dropped. A filter that drops them renumbers everything
#    below, and a checker naming the wrong line sends its reader to innocent text. Only a fixture
#    with a Trio line ABOVE a compared claim can tell the two apart — without one, a dropping
#    mutant passes the whole suite. ─────────────────────────────────────────────────────────────
twin
printf '# Changelog\n\n## 0.1.0 — unreleased\n\n**Trio:** five diagrams.\n\nThe corpus now has nine diagrams.\n' > "$T/CHANGELOG.md"
run
saw 'CHANGELOG.md:7' && ok \
  || bad "a claim under a Trio line was numbered as if the Trio line were gone: $(cat "$T/out.txt")"

# ── the scoping drops ONE comparison, not every check the changelog gets ─────────────────────
#    A `continue` one loop higher would silence the changelog entirely and look identical.
twin
printf '# Changelog\n\n## 0.1.0 — unreleased\n\nFine.\n\n| A | B |\n|---|---|\n| one |\n' > "$T/CHANGELOG.md"
run
saw 'table row has 1 cells' && ok \
  || bad "a malformed table in the changelog went unreported — the scoping over-reached"

# ── `mermaid` is an adjective more often than a counted noun: it must name what it counts ────
twin
printf '# Alpha\n\nTwo of them, one mermaid edge and one sentence.\n' > "$T/alpha.md"
run
saw 'mermaid' && bad "'one mermaid edge' was read as a claim about the diagram count" || ok
twin
printf '# Alpha\n\nThe corpus has five mermaid blocks.\n' > "$T/alpha.md"
run
saw 'FAIL:alpha.md' && ok || bad "a real count spelled 'five mermaid blocks' went unchecked"

# ── a counted intro is charged with the items NESTED under it, never with shallower siblings ─
twin
printf '# A\n\nThere are two rules:\n\n- one\n- two\n- three\n' > "$T/alpha.md"
run
saw 'two rules but 3 follow' && ok \
  || bad "a top-level intro miscounting its own list was accepted — the indent rule removed the teeth"

#    Both shapes the measured case can take: the colon on a bullet's continuation line, and on
#    the bullet's own line. In each the following bullets are PEERS, and were never its count.
twin
printf '# A\n\n- **A bullet** that runs long\n  and its sentence ends in two rules:\n  more of the same bullet.\n- sibling one\n- sibling two\n- sibling three\n' > "$T/alpha.md"
run
saw 'rules but' && bad "an intro on a bullet's continuation line was charged with the outer list" || ok

twin
printf '# A\n\n- **A bullet** whose sentence ends in two rules:\n  more of the same bullet.\n- sibling one\n- sibling two\n- sibling three\n' > "$T/alpha.md"
run
saw 'rules but' && bad "an intro that IS a bullet was charged with its own siblings" || ok

#    …and an intro that really does introduce a nested list is still counted, wrongly or rightly.
twin
printf '# A\n\n- **A bullet** whose sentence ends in two rules:\n  - nested one\n  - nested two\n  - nested three\n' > "$T/alpha.md"
run
saw 'two rules but 3 follow' && ok \
  || bad "a nested list under its own intro was not counted — the indent rule removed the teeth"

echo "check-structure: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
