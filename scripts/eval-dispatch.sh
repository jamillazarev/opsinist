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
# Column five, optional: the tier this scenario is meaningful at. Most rows leave it empty and
# take the light default — the deliberate floor, because behaviour that holds there holds
# everywhere. **But a scenario measured where nobody would run it measures nothing**, and some
# flows are the advisor's own work: the advisor is the session, its model is the one setting the
# cascade cannot reach, and no owner migrates a project on the cheapest model available. Those
# rows name their tier, and the rate they produce is a claim about that tier.
row_model=$(printf '%s' "$row" | cut -f5)
[ -n "$row_model" ] && PLAYER_MODEL="$row_model"

root="$SUITE/runs/$ID/$N"; logs="$SUITE/logs"; mkdir -p "$logs"
out="$logs/$ID-$N.output"
rm -rf "$root"; mkdir -p "$root"
bash evals/fixtures.sh "$root" "$fixture" >/dev/null 2>&1 || { echo "$ID/$N: fixture build failed"; exit 3; }
ws="$root/$fixture/workspace"

# `wired;` at the head of a setup installs the guard, its doors and the four documents into
# this run's workspace. It is declared HERE, in the row, and not by an environment variable the
# operator has to remember: measured 2026-08-15, a whole round of seven refusal scenarios ran
# against fixtures nobody had wired, because `WIRE_PREFLIGHT=1` was set when the fixtures were
# built by hand and not when the suite rebuilt them per run. Every precondition was absent and
# the round measured an ungated project — 35 dispatches that answered a question nobody asked.
case "$setup" in
  wired\;*)
    mkdir -p "$ws/_ops/scripts"
    cp templates/company-preflight.sh "$ws/_ops/scripts/preflight.sh"
    cp scripts/transition.py scripts/new-id.py "$ws/_ops/scripts/"
    printf '#!/bin/sh\nbash _ops/scripts/preflight.sh || exit 1\n' > "$ws/.git/hooks/pre-commit"
    chmod +x "$ws/.git/hooks/pre-commit" "$ws/_ops/scripts/preflight.sh"
    for d in ROADMAP TEAM TOOLING DECISIONS; do
      [ -f "$ws/_ops/$d.md" ] || printf '# %s\n' "$d" > "$ws/_ops/$d.md"
    done
    # And the guide, because `project-layout.md` says a project gets `CLAUDE.md` on day one and
    # every real one has it. Without this the fixture was enforcement without instruction — a hook
    # that refuses and no file stating any rule it enforces — which is a project shape that does
    # not exist. Measured 2026-08-15: in the first refusal round the only two scenarios that
    # scored (N91 5/5, N94 4/5) were the two whose refusal message carried the whole instruction
    # itself; every scenario that needed a rule to be written down somewhere met a project where
    # it was not. Placeholders are left unfilled — the doors section, which is what these
    # scenarios turn on, is literal text.
    [ -f "$ws/CLAUDE.md" ] || cp templates/GUIDE-template.md "$ws/CLAUDE.md"
    git -C "$ws" add -A >/dev/null 2>&1
    git -C "$ws" -c user.email=o@fixture.test -c user.name=Owner commit -qm "wired" >/dev/null 2>&1
    setup=${setup#wired;}
    ;;
esac
if [ -n "$setup" ] && [ "$setup" != "-" ]; then (cd "$ws" && bash -c "$setup") || { echo "$ID/$N: setup failed"; exit 3; }; fi

# The baseline the post-state's commit section is a delta against — taken after setup, so a
# scenario whose setup commits is not blamed for it either.
base=$(git -C "$ws" rev-parse HEAD 2>/dev/null || true)

# The turn loop. stream-json keeps every tool call in the transcript — the boundary tripwire
# and the judge both read it. A resumed turn continues the same session, so a multi-turn
# scenario is one conversation, not three cold starts.
# `timeout` is not part of macOS — it arrives with Homebrew's coreutils. Measured 2026-08-20 in
# the sibling tree: a suite that wrapped its calls in `timeout` was green on this machine and
# failed every assertion with 127 on a runner without it. Here the timeout does real work — it is
# what stops a hung run from holding a round forever — so it is not silently skipped. It is used
# when present, and its absence is SAID once, because an unbounded run that looks bounded is the
# worse of the two failures. Resolved at TOP LEVEL: the first version of this sat inside the turn
# loop, where it would have re-resolved and re-warned once per turn, up to 55 times a run.
_TMO=$(command -v timeout || command -v gtimeout || true)
[ -n "$_TMO" ] || echo "  ! no \`timeout\` on this machine (it is Homebrew's, not macOS's) — runs are UNBOUNDED" >&2

sid=""
i=0
printf '%s\n' "$turns" | sed 's/ ||| /\n/g' | while IFS= read -r turn; do
  i=$((i+1))
  # The player's tier is a variable, defaulting to the light one every published rate was
  # measured on. It became a variable the day someone asked "will this work?" and the honest
  # answer was that the suite has only ever answered for one tier — a rate is a claim about a
  # corpus AND a model, and quoting it without the second half is half a measurement.
  args=( --model "${PLAYER_MODEL:-haiku}" -p "$turn" --plugin-dir "$CORPUS" --dangerously-skip-permissions
         --max-turns 55 --output-format stream-json --verbose )
  [ -n "$sid" ] && args+=( --resume "$sid" )
  ( cd "$ws" && CLAUDE_CONFIG_DIR="$PHOME" ${_TMO:+$_TMO 420} claude "${args[@]}" </dev/null ) >> "$out" 2>>"$logs/$ID-$N.err"
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
  # A delta, because the header promises one. Printing the whole log put the fixture's own build
  # commit under a heading that says the run made it — measured 2026-08-01: a judge read `wip`,
  # built by `fixtures.sh`, as evidence of unaudited changes and failed the run partly for it.
  # Silence here means the run committed nothing, which is the common and correct case.
  if [ -n "$base" ]; then
    git -C "$ws" log --oneline "$base"..HEAD 2>/dev/null | head -12
  else
    git -C "$ws" log --oneline 2>/dev/null | head -12   # no baseline: the fixture had no commit
  fi
  echo "== files now present"
  (cd "$root" && find . -type f -not -path '*/.git/*' | sort)
  echo "== store"
  ls "$HOME/.opsinist/projects" 2>/dev/null || echo "(no store)"
} > "$logs/$ID-$N.post"
echo "$ID/$N done"
