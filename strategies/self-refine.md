# self-refine — produce, critique, revise once

```yaml
name: self-refine
mode: prefix
passes: 2
cost: ~2x
applies_to: any-tier
prompt_prefix: |
  Produce the deliverable, then critique it against the task's own acceptance criteria and
  what-does-not-count list, then revise once. The report carries what the critique changed —
  one line — not the discarded draft.
```

**Raises the floor before review; never replaces it.** The author's context is invisible to
the author (`lenses.md`) — a second pass by the same mind catches slips, not assumptions, so
**a self-refined deliverable still goes to a non-author for review**, and a run that cites
this strategy as its review has faked the review. Best on writing and analysis; pointless on
mechanical edits, where the critique has nothing to hold against.
