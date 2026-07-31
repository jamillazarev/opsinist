#!/usr/bin/env bash
# Re-run and re-judge exactly the runs a session limit ate, and nothing else.
#
#   bash scripts/eval-requeue.sh <suite> <corpus> <player-home> <judge-home>
#
# The limit is a fact about the account, not about the corpus. A poisoned run left in the table
# would be counted as behaviour that failed; deleted and silently forgotten, it would shrink N
# without saying so. So it is re-dispatched by id, and the record says how many there were.
set -uo pipefail
SUITE=${1:?}; CORPUS=${2:?}; PHOME=${3:?}; JHOME=${4:?}
cd "$(dirname "$0")/.." || exit 1
p="$SUITE/logs/POISONED"
[ -s "$p" ] || { echo "nothing was poisoned — no requeue needed"; exit 0; }

sort -u "$p" | awk '{print $1, $2}' > "$SUITE/requeue.jobs"
n=$(wc -l < "$SUITE/requeue.jobs" | tr -d ' ')
: > "$p"   # cleared now, so a second limit during the requeue collects its own list
echo "requeueing $n run(s)"
SHARDS=${SHARDS:-4}; POOL=${POOL:-4}
cp "$SUITE/jobs.txt" "$SUITE/jobs.full" 2>/dev/null
cp "$SUITE/requeue.jobs" "$SUITE/jobs.txt"
pids=()
for i in $(seq 0 $((SHARDS-1))); do
  bash scripts/eval-shard.sh "$SUITE" "$CORPUS" "$PHOME" "$i" "$SHARDS" "$POOL" \
    > "$SUITE/logs/requeue-shard-$i.log" 2>&1 &
  pids+=($!)
done
for pid in "${pids[@]}"; do wait "$pid"; done
mv "$SUITE/jobs.full" "$SUITE/jobs.txt" 2>/dev/null

echo "judging the requeued runs…"
xargs -P"${JPOOL:-10}" -n2 bash scripts/eval-judge.sh "$SUITE" "$JHOME" < "$SUITE/requeue.jobs"

if [ -s "$p" ]; then
  echo "still limited: $(wc -l < "$p" | tr -d ' ') run(s). Wait for the reset and run this again."
  exit 1
fi
echo "requeue complete — every run in the table is a run that finished"
