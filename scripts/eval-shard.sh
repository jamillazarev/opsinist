#!/usr/bin/env bash
# Run one shard of a suite's job list. The driver launches several of these at once; each is an
# independent process with its own pool, so the wall clock divides by the number of shards
# instead of by nothing.
#
#   bash scripts/eval-shard.sh <suite> <corpus> <player-home> <shard-index> <shard-count> <pool>
#
# Why shards rather than one bigger pool: a single `xargs -P30` is one process whose failure
# takes the whole round with it, and its output interleaves into one file nobody can attribute.
# Shards fail independently, and a shard that dies is re-runnable by index without re-running the
# ones that finished.
set -uo pipefail
SUITE=${1:?}; CORPUS=${2:?}; PHOME=${3:?}; IDX=${4:?}; COUNT=${5:?}; POOL=${6:-4}
cd "$(dirname "$0")/.." || exit 1

jobs="$SUITE/jobs.txt"
[ -s "$jobs" ] || { echo "no job list at $jobs"; exit 2; }
mine="$SUITE/shard-$IDX.jobs"
awk -v i="$IDX" -v n="$COUNT" 'NR % n == i' "$jobs" > "$mine"
total=$(wc -l < "$mine" | tr -d ' ')
echo "shard $IDX/$COUNT: $total runs, pool $POOL"
xargs -P"$POOL" -n2 bash scripts/eval-dispatch.sh "$SUITE" "$CORPUS" "$PHOME" < "$mine"
echo "shard $IDX complete"
