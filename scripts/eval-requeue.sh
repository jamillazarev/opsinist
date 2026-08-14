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

# A void is not a poisoned run. The limit list is written when a session limit eats a run, so a
# run that produced no transcript for any OTHER reason — never dispatched, fixture broken, shard
# died — is in no list this script reads, and the requeue below cannot reach it. Measured on the
# 2026-08-14 round: N72's five runs left no output, no stderr and no post, the judge honestly
# wrote `void: no transcript` over each, and this script still printed "every run in the table is
# a run that finished". The claim is now earned by a sweep of the whole table rather than by the
# poisoned list alone — the repair is a form, because the sentence was already emphatic.
#
# Scoped to the MISSING TRANSCRIPT, and only that. The first version also swept every `void`
# verdict — measured against this same round on 2026-08-14, that is **91 correctly graded runs**
# against 5 real ones: a content void is a judge reading a transcript and saying it measures
# nothing, which is a verdict, not a loss. Sweeping those would have told the operator to
# re-dispatch 91 finished runs and exited 1 on a healthy round. The rate table already counts
# them in its void column; this sweep is about runs that produced nothing to count.
sweep_voids() {
  # One interpreter for the whole table, not one per row: the per-row form cost 9.4s on a
  # healthy 515-row table, and the shell substitute that replaced it — "the verdict file ends
  # in a closing brace" — accepts a write truncated just after a brace inside the reason text,
  # which is exactly the shape it was meant to catch. One pass is both correct and ~1s.
  #
  # An unreadable table is not an empty one: without the first check the loop ran zero times,
  # `left` stayed 0, and the script printed its completion claim over a table it never opened.
  #
  # Scoped to runs that produced NOTHING — no transcript, or no readable verdict beside one.
  # A content void is a judge reading a real transcript and ruling it measures nothing; that is
  # a verdict, not a loss. Sweeping those was measured condemning 91 correctly graded runs
  # against 5 real ones on the round this was written for.
  if [ ! -s "$SUITE/jobs.txt" ]; then
    echo "no jobs table at $SUITE/jobs.txt — nothing was swept, and nothing can be claimed"
    return 1
  fi
  out=$(python3 - "$SUITE" <<'SWEEP'
import json, os, sys
suite = sys.argv[1]
logs = os.path.join(suite, "logs")
left = []
with open(os.path.join(suite, "jobs.txt"), encoding="utf-8", errors="replace") as fh:
    for line in fh:                      # a final unterminated row is read like any other
        parts = line.replace("\r", "").split()
        if len(parts) < 2:
            continue
        rid, n = parts[0], parts[1]
        out_p = os.path.join(logs, f"{rid}-{n}.output")
        ver_p = os.path.join(logs, f"{rid}-{n}.verdict.json")
        if not (os.path.exists(out_p) and os.path.getsize(out_p) > 0):
            left.append(f"{rid}/{n}"); continue
        try:
            with open(ver_p, encoding="utf-8") as vf:
                json.load(vf)
        except Exception:
            left.append(f"{rid}/{n}")
shown = left[:12]
if left:
    tail = f" … and {len(left) - len(shown)} more" if len(left) > len(shown) else ""
    print(f"{len(left)} run(s) are not finished runs — no transcript, or no readable verdict: "
          + " ".join(shown) + tail)
sys.exit(1 if left else 0)
SWEEP
  ) || {
    printf '%s\n' "$out"
    echo "none of these hit a session limit, so this script cannot requeue them. Re-dispatch by id"
    echo "with eval-shard.sh, or read logs/<id>-<n>.err — a whole scenario voiding means its fixture"
    echo "never built. Until then the table's N is smaller than it looks: read the void column."
    return 1
  }
  return 0
}

[ -s "$p" ] || { echo "nothing was poisoned — no requeue needed"; sweep_voids; exit $?; }

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
sweep_voids || exit 1
echo "requeue complete — every run in the table is a run that finished"
