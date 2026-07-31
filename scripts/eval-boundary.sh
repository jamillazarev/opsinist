#!/usr/bin/env bash
# Did a player stay inside its fixture?
#
#   bash scripts/eval-boundary.sh <fixture-root> <transcript-dir>
#
# A player is told to work in one tree. Nothing in this runtime stops it reading another: a run
# whose fixture lacked the artifact its query named went looking, walked out into the owner's real
# projects, and read an unrelated repository. That one found nothing and refused to invent, so the
# result stood — but a player that *finds* something real produces a pass grounded in a project the
# scenario knows nothing about, and the transcript reads as an ordinary success.
#
# Prevention is not available here, so this is detection, and the honest name for it is a tripwire.
# It reads the transcripts a run leaves and reports absolute paths outside the two places a player
# is allowed: its fixture, and the skill it operates under.
set -uo pipefail
root=${1:?usage: eval-boundary.sh <fixture-root> <transcript-dir>}
logs=${2:?usage: eval-boundary.sh <fixture-root> <transcript-dir>}
skill=$(cd "$(dirname "$0")/.." && pwd)
# The store is named from **display_name**, and the file moved to skills/advisor/ in the
# restructure — eval-clean.sh explains why both matter. Getting either wrong here does not
# fail loudly: an empty name turns the store filter into `^$HOME/\.`, which silently drops
# every dotfile path a player touched, and a tripwire that filters away its own evidence
# reports "everyone stayed inside" for a run that walked out. So it is read the same way and
# refuses to run without it.
core="$skill/skills/advisor/SKILL.md"
skill_name=$(sed -n 's/^display_name:[[:space:]]*//p' "$core" | head -1 | tr '[:upper:]' '[:lower:]')
[ -n "$skill_name" ] || { echo "no display_name in $core — cannot tell the store from a stray"; exit 1; }

[ -d "$logs" ] || { echo "no transcript directory: $logs"; exit 1; }

total=0
for f in "$logs"/*.output; do
  [ -f "$f" ] || continue
  # Home-anchored absolute paths the player named, minus the two it is entitled to, minus the
  # store (a correct player writes its record there by design — eval-clean.sh owns that one).
  stray=$(grep -oE "$HOME/[A-Za-z0-9._/-]+" "$f" 2>/dev/null \
          | grep -v "^$skill" \
          | grep -v "^$HOME/\.$skill_name" \
          | grep -v "^$root" \
          | sed 's#\(\(/[^/]*\)\{4\}\).*#\1#' \
          | sort -u)
  if [ -n "$stray" ]; then
    n=$(printf '%s\n' "$stray" | wc -l | tr -d ' ')
    echo "  $(basename "$f" .output): $n path(s) outside the fixture"
    printf '%s\n' "$stray" | head -5 | sed 's/^/      /'
    total=$((total + n))
  fi
done

echo
if [ "$total" -gt 0 ]; then
  echo "BOUNDARY CROSSED: $total path(s). Those runs read outside their fixture —"
  echo "check what they read before trusting their result."
  exit 1
fi
echo "every player stayed inside its fixture"
