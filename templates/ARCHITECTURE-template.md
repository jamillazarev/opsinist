# Architecture — what lives where

**Why this file exists:** every task starts in a **fresh worktree with no memory of the
last one**, so anything not written here is re-derived by every agent on every run. Keeping
it current is cheaper than paying that rediscovery repeatedly — and it falls under
docs-follow-decisions like any other doc: **a change that moves the map updates the map in
the same task.** A stale map is worse than none.

## The shape

{{One paragraph: what this codebase is and the one idea someone must hold to navigate it.}}

| Path | What it is | Owner |
|---|---|---|
| `{{apps/…}}` | {{}} | {{role}} |
| `{{site/…}}` | {{}} | {{role}} |

## Entry points

- **Runs from:** {{the command, the file}}
- **Build:** {{command}} · **Test:** {{command}} · **Deploy:** {{how}}

## Paths a change usually touches

{{"Adding a screen touches X, Y, Z." The routes people actually take — this is the part
that saves the most time.}}

## Boundaries and rules

{{What must not depend on what; where generated code lives; what is vendored; anything a
newcomer would break by accident.}}

## What is not mapped yet

**A map that does not say where it ends is read as if it ended nowhere.** This section is
what stops an agent reasoning confidently about ground nobody opened — a claim about
anything listed here is `unknown`, not inference from the parts that were read.

- {{path or area}} — {{not read: why. "outside the corridor for T-12", "chose base-only at
  takeover", "generated"}}

**Reading depth chosen:** {{corridor | base only | everything}}, {{date}}. Threshold in
`config.md` as `read_threshold_lines`.

**Delete an entry when it gets read**, in the same task that reads it. An area that quietly
stays listed after someone worked in it makes this section a lie in the other direction.
