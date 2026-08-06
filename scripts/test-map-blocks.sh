#!/usr/bin/env bash
# The touched-by executor exercised: blocks generated, only markers rewritten, and two live
# tasks on one node stated as a finding inside the block itself.
set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d /tmp/opsinist-mapb-test.XXXXXX)
trap 'rm -rf "$T"' EXIT
cd "$T"; mkdir -p tasks docs
printf '# Map\n\n## checkout\n\nThe checkout flow.\n' > docs/MAP.md
printf '**Status**: started\n**Touches**: checkout\n' > tasks/T-A1-copy.md
printf '**Status**: started\n**Touches**: checkout\n' > tasks/T-B2-redesign.md
printf '**Status**: backlog\n**Touches**: onboarding\n' > tasks/T-C3-later.md

pass=0; fail=0
ok(){ pass=$((pass+1)); }; bad(){ fail=$((fail+1)); echo "  ✗ $1"; }

python3 "$HERE/map-blocks.py" . >/dev/null
grep -q '<!-- touched-by:checkout -->' docs/MAP.md && ok || bad "no block generated"
grep -q 'both live on this node' docs/MAP.md && ok || bad "two live tasks not stated as a finding"
grep -q 'T-C3 (backlog)' docs/MAP.md && ok || bad "backlog row missing"

before=$(cat docs/MAP.md)
python3 "$HERE/map-blocks.py" . >/dev/null
[ "$before" = "$(cat docs/MAP.md)" ] && ok || bad "idempotent rerun rewrote the file"

printf '**Status**: done\n**Touches**: checkout\n' > tasks/T-B2-redesign.md
python3 "$HERE/map-blocks.py" . >/dev/null
grep -q 'both live on this node' docs/MAP.md && bad "stale finding survived" || ok
grep -q '## checkout' docs/MAP.md && ok || bad "prose outside markers was touched"

echo "map-blocks: $pass passed, $fail failed"
exit "$fail"
