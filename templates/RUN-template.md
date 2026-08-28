# Run {{R-XXXXXX}} — {{what it was asked to do}}

**The dispatcher writes this, not the worker.** A worker does not reliably see its own usage; the
counts come back to whoever spawned it. This file exists because `cost.md` names the failure and
nothing prevented it: *a run recorded by the worker itself carries a sentence where four numbers
belong, which is how a ledger quietly becomes prose.*

| | |
|---|---|
| **Task** | {{T-XXXXXX}} · {{title}} |
| **Ran** | {{2026-07-31T09:14Z}} → {{09:41Z}} |
| **Outcome** | {{completed · interrupted · limit · failed · canceled}} |
| **Reason** | {{why, when the outcome is not `completed` — otherwise `—`}} |
| **Trigger** | {{a person · a schedule · an event · an automation}} |
| **Attempt** | {{1}} — {{the price of not getting it right the first time; three on one task is 
the escalation threshold, so this is the field that makes it countable}} |
| **Verdict** | {{pass · fail · mixed · none}} — {{the question this run answered, and what it concluded}} |
| **Commits · checkpoint** | {{sha, or `none`}} · {{where to resume from, or `—`}} |

## What answered

| | |
|---|---|
| **Model requested** | {{claude-sonnet-5}} |
| **Model that answered** | {{claude-sonnet-5}} — **fill this from the response, not the request** |
| **Effort · fast mode** | {{medium}} · {{off}} |
| **Strategy** | {{standard}} — {{explicit: task · cascade: role · auto: <selector rule>}} → `strategies/` |
| **Estimate** | {{~N tokens · from M similar runs of this type}} — **judgement-rung, from the ledger's own history; recorded so actual-vs-estimate teaches the next estimate** → `cost.md` |
| **Resolved from** | {{project → team → role → task}}, {{which rung won}} |

**A gateway falls back, and the requested name would then be wrong in the ledger, in the
explanation, and in the evidence a role's trust is earned from.** Where the response does not say,
this cell is `unknown` — never the requested name by default.

## Four numbers, never one total

| `input` | `output` | `cache_read` | `cache_write` |
|---|---|---|---|
| {{12,400}} | {{3,110}} | {{188,900 · or `unknown`}} | {{6,200 · or `unknown`}} |

> [!NOTE]
> **`Outcome` is how the run ended; `Verdict` is what it concluded, and they are not the same
> thing.** A run that answers *"the migration is safe"* and one that answers *"it is not"* both
> end `completed`, so a ledger holding only `Outcome` records that both finished and loses the
> fact that they disagreed — which is the state `escalating.md` calls worse than failure, because
> every run inside it reports confidently. **Most runs check nothing and write `none`**; the word
> is in the cell so nobody has to ask how to say it. Write the verdict where the run reached one:
> a review, a check, an audit, a question answered from the record. Two records on one task that
> conclude opposite things, with nothing recording that anyone noticed, are refused at the commit.

> [!CAUTION]
> **Write `unknown` in the cell.** Not a dash, not a blank, not a clarifying question back to
> the owner — the cell takes the word. Measured 2026-08-15: asked for a record whose cache
> numbers the harness does not report, **not one run of five wrote it**; one wrote `—`, the
> rest stalled asking how to format it and never committed. The affordance was explained in
> this file and not present in the thing being filled in.

**Unavailable is `unknown`, not a sentence.** An estimate dressed as a measurement is the failure
the evidence rungs exist to stop, and cache reads dominate on any project with a stable prefix —
a single total hides the only lever that moves the bill.

**Spend outside the model** — five cells, because a sentence cannot be summed (`cost.md`):

| Service | Unit | Quantity | Amount | Currency |
|---|---|---|---|---|
| {{the vendor}} | {{image · minute · request · seat}} | {{3}} | {{0.24}} | {{USD}} |

> [!NOTE]
> `none` in the Service cell is the whole row when nothing was spent. An amount that is not
> known yet is `unknown` with the unit and quantity still filled — the slice can then be
> completed later, which a free-text line never allows.

**Tool uses**: {{count, shape not content}} · **`skills_available[]`**: {{what was attached}}
· **`skills_used[]`**: {{what was actually reached for}} — declared against used is how dead
weight is found (`dispatching.md`).

## What it produced

- **Deliverables**: {{each named thing, at its named place}}
- **Result rung**: {{measured · cited · recalled · judgement · unknown}} — {{on what}}
- **Reviewed by**: {{someone who is not the worker}}
- **Wrote outside its tree**: {{paths, or `none`}}
