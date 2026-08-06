# Checking — health and audit

**Load when:** the owner asks whether anything is broken, before a release, or on returning after
a while.

**Two different sweeps, and blending them is why neither gets run.**

**Health checks the environment** — is the machinery intact and reachable. Fast, and mostly
mechanical.

**Audit checks the contents** — is what we are doing still sensible. Slower, and mostly judgement.

---

## Health — what fails silently

Everything on this list shares one property: **it breaks without producing an error**, and is
therefore discovered at the worst possible time.

| Check | The failure it prevents |
|---|---|
| **the environment fingerprint** | the same repo behaving differently on two machines → `drift.md` |
| **branch protection**, where a remote exists | a review gate that is a sentence rather than a gate |
| **the tooling register against reality** | a tool nobody checks, whose token nobody rotates |
| **versions and breaking changes** | **a tool that changed its interface breaks agents silently** |
| **free-tier headroom**, in the unit that actually bites | discovering the ceiling by hitting it |
| **credentials: expiry and last use** | an expired key found mid-run; a key nobody has used in a year |
| **link health** | a reference that quietly stopped existing → `resources.md` |
| **generated surfaces against their hashes** | a hand edit **reported before** it is overwritten |
| **the guards themselves** | *a guard that no longer matches reality passes silently* |

That last row is the one people forget. **A check that has stopped checking anything is worse than
no check**, because its green is read as evidence.

**An audit over a whole repository is dispatched, not performed in the turn.** It is minutes of
work, and a conversation that blocks for it has taken the owner hostage to a sweep they asked for
casually — **say what was sent, roughly how long, and how to see it**, then stay answerable while
it runs → `dispatching.md`. **Measured 2026-07-31, five of five:** *"audit the whole repo and
tell me what's rotten"* ran fifteen tool calls inline, and the owner's next question waited for
all of them.

**Report the whole ladder at once**, with what each fix costs, and let the owner say *"do it
all"*. Six sequential yes/no prompts is exactly the experience this replaces. And **installing or
updating software on someone's machine is their call** — the repair is offered, not performed.

**Offline is not broken.** Unreachable is **unchecked**, and a network failure warns rather than
failing the run.

---

## Audit — defects *and* opportunities

The half people skip is the second one.

**Defects:** work happening on a blocked task · dependency cycles · **gates where the author and
the reviewer coincide** · requests and waits past their age · **facts past their check-date** · a
missing or stale architecture map · edits to locked surfaces · roles over their load budget ·
un-archived temporary roles · unsourced scores, and **rankings that flip when a score moves by
one**.

**Opportunities:** stage and gate design that keeps bouncing the same work · tier savings ·
**skills worth creating** · automation candidates · roles idle or bottlenecked · **settings that
have stopped being signals**.

**The audit walks every declared destination, not the current directory.** Once layers can live
apart, a check that only reads what is underfoot reports health it has not looked at. It catches
**both asymmetries** — content sitting in a destination nobody declared, and a declaration with
nothing behind it — and **a destination it cannot reach is a finding, never a silent skip**
→ `storing.md`.

**Findings are evidence, not verdicts** (`PATTERNS.md` §15) — and each one names its place, the defect in one sentence,
and what would fix it. A finding without a location is an opinion.

**The field notes are swept here, and until this line existed nothing swept them.**
`docs/FIELD-NOTES.md` collects friction the moment it happens, and `self-maintenance.md` has
always said it is *"swept at natural checkpoints"* — **a status check is the checkpoint**, and
naming a sweeper is what turns that sentence into an act. Entries go to the backlog,
deduplicated so a re-sweep is idempotent; **an entry seen twice becomes a task with both
occasions named in it**; an entry that has shipped is closed with the version.

**An empty sweep still writes itself**, with its scope — the rule and its reasoning live in
`self-maintenance.md`; what belongs here is that this is where it happens.

---

## What the run records make measurable

Most of the audit's opportunity half comes free from data already recorded:

**Declared against used, per skill.** A skill attached to five roles that fired once in two months
is **evidence** — dead weight in every brief that carries it.

**Attempts clustering** on a type or an area — usually a brief problem, not a worker problem.

**Spend by outcome.** What was spent on runs that produced nothing is a number nobody has unless
someone asks for it. **Report its direction, not its level** — one figure says nothing, and the
level invites arguing about what is acceptable. On one project it should fall as the guide, the
briefs and the roles stop being guesses. **When it does not fall, that is the finding**: the
apparatus is charging rent it is not earning, and saying so is the point of measuring it at all.

**Runs that died, and whether they resumed.** Of the runs cut short by a limit or a crash: how
many came back and finished **without redoing applied work**. The failure this catches is silent
— a resumed run that quietly rebuilds what was already built looks like success from the outside
and costs twice.

**Time in stage**, from the task histories — which is what makes a bottleneck visible before it is
folklore. **And where it keeps pointing at the same edge, the audit proposes a better ladder** —
as a diff to the pipeline file with the numbers that argue for it, because the ladder is a
locked surface: proposed to the owner, never edited by whoever works under it (`pipelines.md`).

**An owner's edit to a worker's output is a signal, and it is offered a home** (`PATTERNS.md`
§21). The diff already says what the system got wrong; unrecorded, the same correction returns
next month. So the edit is offered — once, concretely — one of three homes: **an eval fixture**,
the regression that catches it next time · **a line in the project guide**, the rule the edit
implies · **a skill amendment**, where the miss lives in a skill. Proposed, never auto-written,
and declined is an answer.

**And the spoken rule is the same signal in words** — *"remember this"*, *"always do X"*,
*"never touch Y"*. It is routed to where workers actually read, never to the conversation's
memory: a behaviour → **a guide line** (taking effect at the next boundary, `PATTERNS.md`
§10) · a word or a fact of the domain → **`docs/COMPANY.md`** · a choice with reasons →
**`docs/DECISIONS.md`** · a place to look → **the resource register, with its why**. The
advisor names which home it heard and writes it there — a rule that lives only in a chat log
is the one promise `project = f(repo)` exists to refuse.

**A repeated primitive.** *"We keep doing this by hand"* is the trigger for making a skill or a
tool, and **the honest ranking is that recorded friction from real use finds it better and cheaper
than any analysis of the data** → `self-maintenance.md`. The machine signals are the backstop, not
the primary path — and if a direct signal is wanted, it costs one field: **a short line on each run
saying what was actually done**, which makes near-duplicates findable.

---

## Settings that watch their own friction

Adaptive means a **mechanic, not an intention**. The records already carry what is needed, so the
settings can propose their own change:

- *"You have overridden this default three times — change it?"*
- *"This threshold fires daily; it has stopped being a signal."*
- *"This gate has not fired in two months — still needed, or a ritual now?"*
- *"This role has been working above its grade for a month — promote it so the brief matches?"*

**Nothing drifts silently, and nothing changes silently either.** Each of these is a proposal with
its evidence attached, and the change that follows is **an event with a record**.

---

## A transition seen is an offer made

**"Where are we?" is where seams surface.** Work that has outgrown its container arrives dressed
as status — *still going*, *noted again*, *four crafts now* — and reporting it as progress is the
failure. Measured twice on `2026-07-31`: two runs named every seam unprompted, the recurrence bar
included, **and moved none of them**, closing with *"finish it as it stands, or step back?"* —
an answer that reads as competent while the hour quietly keeps becoming a roadmap.

**A seam named in a status answer ends in its offer**, and the offer has slots that cannot be
filled without opening the destination:

> *\<what outgrew\> becomes \<the named artifact\>, carrying \<what already exists\> — yes?*

| The shape seen | The offer it ends in |
|---|---|
| a quick job past its estimate | *becomes a task from `templates/TASK-template.md` — it gets an id and the work already done comes with it — yes?* → `quick.md` |
| the same note recorded twice | *becomes a `tooling` task in the system stream, with both dates in it — yes?* → `self-maintenance.md` |
| a milestone that outgrew its shape | *promoted to a release, every id under it kept — yes?* → `grouping.md`, `PATTERNS.md` §23 |

**An open question is not an offer.** *"Step back?"* hands the shape back to the owner to design;
the offer names the act and asks only for the yes. The owner still chooses — nothing is promoted
silently — but they choose **between named acts**, not between moods.

---

## Everything that needs a decision is a request

**The audit's output must not be a report.** A report lives until the end of the scroll, and the
findings that most need an owner — a link that cannot be repaired unambiguously, a skill worth
replacing, a deadline at risk, a debt that blocks — are exactly the ones that get scrolled past.

Findings land in **`triage`**, with the four dispositions, so each gets an age and a place in the
attention view → `requests.md`.

---

## When to run them

**Health:** on arriving, before a release, and when something feels wrong.

**Audit:** on a cadence the project chooses, before a release, and **after any restructure** —
because a line count proves a file got shorter and only behaviour proves it still works.

**Both, plus the eval pass, are the release gate** → `shipping.md`.
