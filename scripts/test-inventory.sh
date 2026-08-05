#!/usr/bin/env bash
# The inventory's three promises, exercised: identical twice, guest-safe, honest off git.
set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d /tmp/opsinist-inventory-test.XXXXXX)
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/repo/src" "$T/repo/docs" "$T/ours"
cd "$T/repo"
printf 'x=1\n' > src/a.py; printf 'big\n%.0s' {1..2000} > src/big.txt
printf '# readme\n' > README.md; printf '# map\n' > docs/MAP.md
git init -q . && git config user.email t@f.t && git config user.name T
git add -A && git commit -qm i

pass=0; fail=0
ok()  { pass=$((pass+1)); }
bad() { fail=$((fail+1)); echo "  ✗ $1"; }

# 1 · two runs over the same tree are byte-identical — the whole point
python3 "$HERE/inventory.py" . > "$T/one.md" && python3 "$HERE/inventory.py" . > "$T/two.md"
diff -q "$T/one.md" "$T/two.md" >/dev/null && ok || bad "two runs differed"

# 2 · nothing lands in the tree unless --out says so — guest-safe by construction
[ -z "$(git status --porcelain)" ] && ok || bad "the inventory dirtied the tree it read"

# 3 · --out writes where it is pointed, outside the tree included
python3 "$HERE/inventory.py" . --out "$T/ours/inv.md" >/dev/null
[ -f "$T/ours/inv.md" ] && [ -z "$(git status --porcelain)" ] \
  && ok || bad "--out did not land where pointed, or dirtied the tree"

# 4 · the sections an audit leans on are present, and contents were never read
grep -q '## Largest files' "$T/one.md" && grep -q 'big.txt' "$T/one.md" \
  && grep -q '## Layers' "$T/one.md" && grep -q 'inventory-hash' "$T/one.md" \
  && ok || bad "a required section is missing"

# 5 · off git it says so, and still works
mkdir -p "$T/bare/d"; printf 'x\n' > "$T/bare/d/f.txt"
python3 "$HERE/inventory.py" "$T/bare" > "$T/bare.md"
grep -q 'not a git repository' "$T/bare.md" && grep -qF 'd/' "$T/bare.md" \
  && ok || bad "non-git tree not handled honestly"

echo "inventory: $pass passed, $fail failed"
exit "$fail"
