#!/usr/bin/env bash
# Dispatch ONE scenario instance: build its fixture fresh, run the player through the turns
# the runsheet names, and leave a transcript beside a mechanical post-state.
#
#   bash scripts/eval-dispatch.sh <suite-root> <corpus-copy> <player-config-dir> <id> <n>
#
# The player is a tier below the team's floor, sees only what a user would say, and runs in
# an isolated config dir so the machine's own plugins, memory and servers cannot leak in —
# measured: with the shared config, the installed 0.1.1 plugin would shadow the corpus copy
# under test, and the suite would silently score last week's text.
#
# The whole suite is:  for each runsheet row, for n in 1..N, this script — then eval-judge.sh
# over the transcripts, eval-boundary.sh over the same, and eval-clean.sh over the roots.
set -uo pipefail
SUITE=${1:?suite root}; CORPUS=${2:?corpus copy}; PHOME=${3:?player config dir}
ID=${4:?scenario id}; N=${5:?instance number}
cd "$(dirname "$0")/.." || exit 1

row=$(grep -v '^#' evals/runsheet.tsv | awk -F'\t' -v id="$ID" '$1==id')
[ -n "$row" ] || { echo "$ID: not in runsheet"; exit 2; }
fixture=$(printf '%s' "$row" | cut -f2)
setup=$(printf '%s' "$row" | cut -f3)
turns=$(printf '%s' "$row" | cut -f4)

root="$SUITE/runs/$ID/$N"; logs="$SUITE/logs"; mkdir -p "$logs"
out="$logs/$ID-$N.output"
rm -rf "$root"; mkdir -p "$root"
bash evals/fixtures.sh "$root" "$fixture" >/dev/null 2>&1 || { echo "$ID/$N: fixture build failed"; exit 3; }
ws="$root/$fixture/workspace"

if [ "$setup" != "-" ]; then (cd "$ws" && bash -c "$setup") || { echo "$ID/$N: setup failed"; exit 3; }; fi

# The turn loop. stream-json keeps every tool call in the transcript — the boundary tripwire
# and the judge both read it. A resumed turn continues the same session, so a multi-turn
# scenario is one conversation, not three cold starts.
sid=""
i=0
printf '%s\n' "$turns" | sed 's/ ||| /\n/g' | while IFS= read -r turn; do
  i=$((i+1))
  args=( --model haiku -p "$turn" --plugin-dir "$CORPUS" --dangerously-skip-permissions
         --max-turns 40 --output-format stream-json --verbose )
  [ -n "$sid" ] && args+=( --resume "$sid" )
  ( cd "$ws" && CLAUDE_CONFIG_DIR="$PHOME" timeout 420 claude "${args[@]}" </dev/null ) >> "$out" 2>>"$logs/$ID-$N.err"
  rc=$?
  [ $rc -ne 0 ] && echo "turn $i exit $rc" >> "$logs/$ID-$N.err"
  sid=$(python3 -c "
import json,sys
sid=''
for l in open('$out'):
    l=l.strip()
    if not l: continue
    try: e=json.loads(l)
    except Exception: continue
    if e.get('session_id'): sid=e['session_id']
print(sid)")
  [ -n "$sid" ] || break
done

# A run the provider cut short measured nothing, and it must not reach the judge looking like a
# refusal. Detected by the banner the harness itself emits, marked in its own file, and the
# transcript deleted — a poisoned run is re-dispatched after the reset, never graded.
# Measured 2026-07-31: a session limit ate the last 77 runs of a 370-run suite, and every one of
# them would have scored as a failure of the corpus rather than of the account.
if grep -q "hit your session limit" "$out" 2>/dev/null; then
  reset=$(grep -o "resets [^\"]*" "$out" | head -1)
  echo "$ID $N limit ${reset:-unknown}" >> "$logs/POISONED"
  rm -f "$out"
  echo "$ID/$N LIMIT — requeue after ${reset:-the reset}"
  exit 4
fi

# The mechanical post-state: what the run changed is a fact, not a reading of the transcript.
{
  echo "== git status --porcelain"
  git -C "$ws" status --porcelain 2>/dev/null
  echo "== commits beyond the fixture's own"
  git -C "$ws" log --oneline 2>/dev/null | head -12
  echo "== files now present"
  (cd "$root" && find . -type f -not -path '*/.git/*' | sort)
  echo "== store"
  ls "$HOME/.opsinist/projects" 2>/dev/null || echo "(no store)"
} > "$logs/$ID-$N.post"
echo "$ID/$N done"
