#!/usr/bin/env bash
# The corpus-count claims shown firing on a chapter and staying silent on the changelog.
#
# `check-structure.py` chdirs to its own parent's parent, so a fixture is a tree with a COPY of
# the script inside it — the same shape `test-corpus-preflight.sh` uses. That also lets the last
# pair mutate **the rule itself** rather than the data: an exemption that silences a warning and
# an absence of anything to warn about return the identical silence (`facts.md` 254), so the only
# proof the exemption carries weight is that removing it brings the warning back.
#
# **Assert on what the script REPORTS, never on its exit code**: it prints `FAIL:`/`WARN:` lines
# for preflight to render and exits 0 on every path. The first draft of this suite tested the
# code and reported three failures that were its own, which is the check working on its author.
set -u

PY=${PY:-python3}
SRC=$(cd "$(dirname "$0")" && pwd)/check-structure.py
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }

# The honest twin: two diagrams on disk, a chapter that says so, and a changelog entry whose
# count is a DELTA — what that release added — which is not the corpus total and never was.
twin() {
  mkdir -p "$T/scripts"
  cp "$SRC" "$T/scripts/check-structure.py"
  printf '# D\n\n```mermaid\nflowchart TD\n  A-->B\n```\n\n```mermaid\nflowchart TD\n  C-->D\n```\n' > "$T/diagrams.md"
  printf '# Alpha\n\nThe corpus has two diagrams.\n' > "$T/alpha.md"
  printf '## 0.1.0 — 2026-01-01\n\nThis release added five diagrams.\n' > "$T/CHANGELOG.md"
}

run() { "$PY" "$T/scripts/check-structure.py" > "$T/out.txt" 2>&1; }
saw() { [ "$(grep -c "$1" "$T/out.txt")" -gt 0 ]; }   # grep -c drains, so no pipe can eat it

# ── the twin must pass, or every refusal below is meaningless ────────────────────────────────
twin; run
saw '^FAIL:' && bad "the honest twin was refused: $(cat "$T/out.txt")" || ok
saw 'diagrams' && bad "a correct chapter count was flagged: $(cat "$T/out.txt")" || ok

# ── mutant 1 · a chapter's count drifts — this is the whole reason the check exists ──────────
twin
printf '# Alpha\n\nThe corpus has five diagrams.\n' > "$T/alpha.md"
[ "$(grep -c 'five diagrams' "$T/alpha.md")" -gt 0 ] || bad "MUTATION DID NOT APPLY (chapter count)"
run
saw 'FAIL:alpha.md' && ok || bad "a chapter claiming five diagrams against two was accepted"
saw 'there are 2' && ok || bad "the refusal did not say what the real count is"

# ── the changelog is exempt — its counts are deltas, or totals true on their date ────────────
twin
[ "$(grep -c 'five diagrams' "$T/CHANGELOG.md")" -gt 0 ] || bad "FIXTURE LOST ITS CHANGELOG CLAIM"
run
saw 'diagrams' && bad "the changelog's delta was compared against the corpus total" || ok

# ── and the exemption is what does it: remove the rule, and the same line is refused ─────────
#    Without this pair the check above passes just as well on a fixture where nothing was read.
sed -i '' 's/^_NO_CORPUS_CLAIMS = .*/_NO_CORPUS_CLAIMS = set()/' "$T/scripts/check-structure.py"
[ "$(grep -c '_NO_CORPUS_CLAIMS = set()' "$T/scripts/check-structure.py")" -gt 0 ] \
  || bad "MUTATION DID NOT APPLY (the rule) — the pair below proves nothing"
run
saw 'FAIL:CHANGELOG.md' && ok \
  || bad "with the exemption removed the changelog count still passed — the rule is not what silences it"
saw 'diagrams' && ok || bad "the rule-mutant fired on something other than the diagram count"

# ── the exemption drops ONE comparison, not every check the changelog gets ───────────────────
#    A `continue` placed one loop higher would silence the changelog entirely and look identical.
twin
printf '## 0.1.0 — 2026-01-01\n\nAdded five diagrams.\n\n| A | B |\n|---|---|\n| one |\n' > "$T/CHANGELOG.md"
run
saw 'table row has 1 cells' && ok \
  || bad "a malformed table in the changelog went unreported — the exemption over-reached"
saw 'diagrams' && bad "the exempt comparison fired anyway" || ok

# ── a counted intro is charged with the items NESTED under it, never with shallower siblings ──
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
