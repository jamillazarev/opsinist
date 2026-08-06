# {{S-XXXXXX}} — {{what this describes, in the project's own words}}

**The stock shape of the `spec` rung** (`writing-work.md`) — the document a task points at and
closing updates. **The craft names it**: a PRD, a creative brief, an editorial policy, a recipe
card — the fields below are what good ones share, whatever the cover says. **Where a binding
exists, its format wins and this file is not used.**

**The id is minted, never invented** — `scripts/new-id.py`, prefix `S-`; the file lives at
`docs/specs/` unless the binding says otherwise. **Delete the optional sections the craft does
not need — a heading over an empty body is worse than no heading**, and the preflight refuses
templates shipped as content.

**Covers**: {{one line}} · **Touches**: {{map nodes this changes or creates → `docs/MAP.md`}}
**Opportunity**: {{the need this closes, named from the research chain, with the insight it
stands on cited to its place — a solution with no opportunity above it is the miss the tree
exists to show → `process-discovery.md`}}
**Sources**: {{each fact below is cited to its place — `file.md#Anchor (sha:…, checked …)`,
minted by `scripts/check-links.py --mint` — or written as "verify X"}}

## Why now

{{The business or craft context — the goal standing behind the work, one paragraph. What
happens if nothing is done belongs here too: **the cost of inaction is what prices the work**,
and a spec that cannot say it is a wish with sections. For product work, three questions
grade the problem before anything is scoped: **how often it bites · how hard · whether anyone
would pay to stop it** — a problem weak on all three is a curiosity, not a spec.}}

## The outcome

{{What must be true of the thing delivered, in one sentence — the same bar as the task's
outcome, held here because this document outlives the task.}}

## Out of scope

{{What this explicitly does not cover. **Enumerated near-misses stop work being declared done
sideways** — worth more than another success criterion, and read by the reviewer first.}}

## Success criteria and measures

{{The craft gates, objective where the craft allows. For product work, name the measures by
role rather than as a list:
- **primary** — the one number this succeeds by
- **secondary** — the leading indicators watched on the way
- **guardrail** — the counter-measure that must not degrade while the primary moves
- **proxy** — where the primary is too slow to read inside the work's window, the faster stand-in
  **with the stated reason it predicts the primary**, or it is a vanity number wearing a job
- **instrument** *(where the craft asks people)* — matched to the layer, never one-size: effort
  at a step · satisfaction at a touchpoint · the whole scenario · the software · the brand — the
  catalogue's measurement row carries the ladder and each one's trap}}

## Constraints

{{Compliance · technical · craft — the walls the solution must live inside, one line each,
sourced.}}

## Prior attempts

{{What was already tried against this, **with the outcome named** — worked, failed, or
**"effect never measured"**, which is its own finding. A decline nobody can explain returns
next quarter; so does an attempt nobody recorded.}}

## Open questions

{{What is not yet settled, each as "verify X" with who or what settles it. **An open question
listed here is honest; the same question discovered mid-build is a stall.** Each is an
assumption wearing a question mark — **the riskiest gets a test before the build**, named by
axis: does anyone want it · can we build it · does it hold up as a business.}}

## The plan per outcome *(optional — product and experiment work)*

{{Written **before** the work, the same law as the exemplar rung:
- **fails** — what is rolled back, how, and where the negative result is recorded
- **middling** — the number moved but missed the target: what gets one bounded iteration and
  what stops it
- **succeeds** — what scales it, and to whom}}

## Funnel stage *(optional — product work)*

{{Which stage of the project's growth frame this moves, in the frame the type's wave chose →
`catalogue.md`. One line, beside the north-star it serves.}}
