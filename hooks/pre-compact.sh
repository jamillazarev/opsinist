#!/usr/bin/env bash
# Fires before the runtime compacts the conversation. Plain stdout from PreCompact is NOT
# added to the compaction's context (docs, cited 2026-08-06: only UserPromptSubmit,
# UserPromptExpansion and SessionStart stdout reach Claude) — so the order travels as the
# documented JSON contract instead: hookSpecificOutput.additionalContext. The post-compaction
# half lives in post-compact.sh under SessionStart(matcher: compact), where stdout does reach.
cat <<'EOF'
{"hookSpecificOutput": {"hookEventName": "PreCompact", "additionalContext": "Before this summary replaces the transcript: anything load-bearing that lives only in the conversation must be written to the repository first — the tail of any thread in flight, any decision reached in talk (docs/DECISIONS.md), any applied-but-uncommitted work named. What is already in the tree needs nothing: the repository is the canon and the summary may drop it freely. Preserve in the summary only: open questions awaiting the owner, and pointers (ids, paths) to where everything else was written."}}
EOF
exit 0
