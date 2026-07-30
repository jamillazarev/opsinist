#!/usr/bin/env bash
# Remove what a behavioural run leaves behind — the fixtures, and the writes outside them.
#
#   bash scripts/eval-clean.sh <fixture-root>          # show what would go
#   bash scripts/eval-clean.sh <fixture-root> --yes    # remove it
#
# A player following this skill correctly writes outside its fixture: the record lands in
# ~/.opsinist/projects/<slug>/, keyed by the fixture's invented remote. Left there, it is
# indistinguishable from a real project — the store is listed by scanning, so a repository
# that never existed shows up in "every project you have touched" months later.
set -uo pipefail
root=${1:?usage: eval-clean.sh <fixture-root> [--yes]}
confirm=${2:-}
[ -d "$root" ] || { echo "no such fixture root: $root"; exit 1; }

echo "fixtures under $root:"
find "$root" -mindepth 1 -maxdepth 1 -type d | sed 's/^/  /'

# Which stores belong to the fixtures. Match the record's own key against the remotes the
# fixtures actually declare — exactly, never on a fragment. A first cut matched the owner
# segment as a substring of the fixture tree and proposed deleting an unrelated record whose
# owner happened to be a common word. A tool that removes things may not guess.
# The store root takes its name from the skill's **display name** — the product's identity —
# resolved here rather than hardcoded (storing.md). It deliberately does not use `name`:
# that field is the plugin's invocation name (`/opsinist:advisor`), and the two answer
# different questions. Tying the store to it would rename every owner's records the day a
# command is renamed.
core="$(cd "$(dirname "$0")/.." && pwd)/skills/advisor/SKILL.md"
skill_name=$(sed -n 's/^display_name:[[:space:]]*//p' "$core" | head -1 | tr '[:upper:]' '[:lower:]')
store="$HOME/.${skill_name:?SKILL.md declares no display_name}/projects"
remotes=$(cd "$root" 2>/dev/null && find . -name config -path '*/.git/*' -exec \
          sed -n 's#^[[:space:]]*url = ##p' {} + 2>/dev/null \
          | sed -e 's#^https\{0,1\}://##' -e 's#^git@##' -e 's#:#/#' -e 's#\.git$##' | sort -u)
orphans=()
if [ -d "$store" ] && [ -n "$remotes" ]; then
  for rec in "$store"/*/; do
    [ -d "$rec" ] || continue
    # Strip emphasis and backticks *before* matching. The first version required the asterisks
    # ahead of the colon, so it read `**Key**: x` and silently missed `**Key:** x` — both are
    # ordinary markdown, and a cleaner that misses one leaves a fabricated project in the store
    # while reporting that it found nothing. Failing to read a key must never look like no key.
    key=$(tr -d '`*' < "$rec"record.md 2>/dev/null \
          | sed -n 's/^[[:space:]]*-\{0,1\}[[:space:]]*[Kk]ey[s()]*[[:space:]]*:[[:space:]]*//p' \
          | sed -e 's#^https\{0,1\}://##' -e 's#^git@##' -e 's#\.git$##' \
          -e 's/[[:space:]].*//' | head -1)
    if [ -z "$key" ] && [ -f "$rec"record.md ]; then
      echo "  ! $rec has a record.md with no readable key — check it by hand" >&2
    fi
    [ -n "$key" ] || continue
    while IFS= read -r r; do
      [ "$r" = "$key" ] && { orphans+=("$rec"); break; }
    done <<< "$remotes"
  done
fi
if [ ${#orphans[@]} -gt 0 ]; then
  echo "records written outside the fixtures, keyed to a fixture remote:"
  printf '  %s\n' "${orphans[@]}"
else
  echo "records written outside the fixtures: none keyed to these fixtures"
fi

if [ "$confirm" != "--yes" ]; then
  echo
  echo "nothing removed. Re-run with --yes to remove the above."
  exit 0
fi
rm -rf "$root"
for o in ${orphans+"${orphans[@]}"}; do rm -rf "$o"; done
rmdir "$store" 2>/dev/null; rmdir "$HOME/.opsinist" 2>/dev/null
echo "removed."
