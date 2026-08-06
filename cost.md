# Cost — what things cost, and which bill

**Load when:** the owner asks what something cost, a budget is set or nearly spent, or a choice
turns on price.

**Measured at the atom, everything else derived.** Store once, at the run. **Never store
rollups** — they drift the moment anything is edited. Task, role, release, period and project are
all sums (`PATTERNS.md` §4).

---

## Ten slices, and only five of them are about spending

| Slice | Answers |
|---|---|
| **task** | what this piece cost — **own and including children, labelled** |
| **role** | who burns what, and whether the grade fits the work |
| **team · milestone · release** | free joins through the task |
| **period** | a generated report over a date range |
| **project** | periods against the envelope: burn, and where it ends |
| **outcome** | **what was spent on runs that produced nothing** |
| **attempt** | the price of not getting it right the first time |
| **model · effort · fast** | whether the expensive setting bought anything |
| **skill** | declared against used, per skill |
| **`stream`** | what maintaining the machinery costs |

The first five answer *how much was spent*. **The last five answer how much was wasted**, and
they come from the same group-by over the same records — which is the point: **a slice you did
not record a field for is impossible later, and a field recorded with no slice is never read.**

**Label own against including children, always.** *"This feature cost N"* is ambiguous the moment
the feature has children, and at depth the unlabelled number gets more wrong with every level. A
milestone has no ambiguity — it has no runs of its own.

**Report the trend, not the level.** *"$212 of $300, and the weekly rate doubled, so the envelope
ends around the 26th rather than the 30th."* A number without a direction is not a decision
input.

---

## Four token numbers, never one total

`input` · `output` · `cache_read` · `cache_write`. **The run is written from
`templates/RUN-template.md`, which gives the four their own cells** — the sentence-where-numbers-belong
failure below is what a form prevents and a paragraph does not.

**The dispatcher writes them, not the worker.** A worker does not reliably see its own usage —
the counts come back to whoever spawned it. A run recorded by the worker itself will carry a
sentence where four numbers belong, which is how a ledger quietly becomes prose. **Where the
numbers are genuinely unavailable, the line says `unknown` rather than describing the cost in
words** — an estimate dressed as a measurement is the failure the evidence rungs exist to stop.

Cache reads are the overwhelming majority of tokens on any project with a stable prefix, and read
tokens are far cheaper than fresh input. **A single total hides exactly that** — which means it
hides the one lever that actually moves the bill.

**Tokens are not the whole bill.** A run that drives a paid service — image or video
generation, a transcription API, a search index — spends **money inside the run**, on a different
key, in a different unit, and the harness's accounting never sees it. Four token numbers on a run
that generated two hundred images describe the thinking and miss the cost. So a run also records
**third-party spend: service · unit · quantity · amount · currency**, and where the amount is not
knowable at the time, the quantity still is — *"140 image generations"* is a number someone can
price later; silence is not.

**This is what breaks the waste slices**, and they are the half worth having. *Spent on work that
produced nothing* is answered from the ledger, so a failed run whose expense was entirely outside
the token count reads as nearly free — exactly the run that most deserved to be counted.

**And it is `spend`, so it is gated** — but not per call: a hundred generations is not a hundred
questions. The shape is the one already named: a **threshold** that asks before an action and a
**cap** that stops at a total, declared once for the service, so the owner is asked at the
boundary they chose rather than at every image.

---

## Context economy — what the four numbers are for

**In order of impact:**

**Keep the cached prefix stable.** The project guide and the role instructions *are* the prefix.
Every edit invalidates it: a cache **write** is paid, and cheap reads are lost until it warms
again. **Batch guide and instruction changes**; never dribble small edits mid-flight.

**Progressive disclosure.** Only the core is always loaded; chapters load on their trigger.
**Adding to a chapter is nearly free; adding to the core is paid on every run, by every role.**

**Model tiering.** Top tier for reasoning, mid for building, cheap for translation and bulk. And
route verification and search work **one tier down** — it does not need the top model.

**Terse by default, readable where a human reads** → `dispatching.md`.

**Do not re-derive.** Read the file rather than reconstructing it from memory, and commit
incrementally so a rerun resumes from the repository instead of redoing work.

**Not our layer:** model compression — quantization, distillation — applies to teams hosting
their own models. Consuming an API or a subscription, the lever is **context economy**.

**An estimate at dispatch, from the ledger's own history.** Enough runs of a type make the
next one predictable within a band: the dispatcher reads similar runs — same type, similar
size — and writes `~N tokens, from M similar runs` on the run **before it starts**,
judgement-rung, never a promise. Actual-vs-estimate accumulates in the same ledger, which is
what narrows the band honestly instead of a number invented per dispatch. **An estimate that
would change the owner's decision is said before the dispatch, not discovered in the ledger** —
said once, at the moment it matters (`PATTERNS.md` §21), and where it is that large, said as a
share of the budget's window rather than a bare token count.

---

## Two bills — name which one

**The work's spend** is the ledger: which task, which role, which release. It exists **whether or
not a budget is set**, so answer from the ledger rather than from a budget that may not exist.

**The advisory conversation is a separate bill** on the owner's own quota, and a long
conversation is dear even cached because cost climbs with context. So the advisor runs lean turns
— the point in the chat, the detail in a file — and **nudges**: a fresh conversation on a topic
switch, compaction on a long one. **Without making the owner mind the cache**: they should be
thinking about the project, not the session.

**A ballooning conversation is itself the signal to move heavy work into tasks**, where each run
starts with no carried context — the cheapest place for it.

**The honest boundary shifts with how you pay.** On a **subscription**, the harness's own usage
view is the authority on the bill and ours is **attribution**. On an **API key** it inverts: the
tokens are ours to count, and our ledger *is* the bill. Where the harness reports nothing for a
run, the field is **absent rather than guessed**.

**And that boundary is a slot in the answer, not a fact about the answer.** A cost question is
answered in four parts, and the fourth is the one that vanishes:

1. **own, or including children** — stated, never left to be inferred from the number's size.
2. **four token numbers, not one total** — cache reads dominate, and a single figure hides that.
3. **the trend, not only the level** — one figure argues about acceptability; a direction says
   whether the apparatus is earning its rent.
4. **which of us is the authority here** — *"the harness's usage view is the bill; this is
   attribution"*, or its inverse on an API key.

**Measured 2026-07-31, five of five:** runs produced the first three faithfully — the split, the
four numbers, the trend — and **not one said the fourth**, so a careful attribution read as a
statement of what the owner will be charged.

---

## The budget shapes advice, it does not only cap it

Declared once — an amount per day, month or project.

**It changes what gets recommended in the first place.** A project on $50 a month and one on
$5000 get different tools proposed from the start, not the same ones with a warning at the end.

**With no budget, assume no money — and say so.** Recommend what is free, and state the
assumption out loud rather than silently building half a stack on a guess. **Where nothing free
exists**, name the minimum it would cost and ask, rather than quietly proposing something paid.

**Credits and free months are runway, not income.** Recorded **with their expiry**, and the
advice **names the cliff**: *"free until March, then about $80 a month."* Otherwise March arrives
and the project is living on something that ended.

**Warn at a share, refuse the next dispatch at the cap, and always offer the cheaper path that
still works.**

**The verb is *refuse the next dispatch*, and it is deliberate.** *Stop at the cap* was written
here for months and **nothing could perform it**: no runtime exposes a spend gate, a run already
in flight cannot be halted from outside, and on a subscription the authoritative number is the
harness's, not ours. What **is** performable is the check between runs — the ledger's total
against the cap, before the next dispatch — and **that one is now a validator**: with the
preflight wired, a commit that records spend while `docs/BUDGET.md` reads at or past the pause
threshold is refused (§12). It stays quiet on an unfilled template and on a commit that touches
nothing spend-shaped, because a gate that cries wolf is a gate people bypass.

**Unwired, the line is still only a rule**, and it is listed by name in `permissions.md` —
believing an unenforced cap is a gate is the failure that list exists to prevent.

**A shrinking budget re-proposes the stack**, rather than only raising an alarm. An alarm says
something is wrong; a re-proposal says what to do.

**The cap is `locked`** — proposed to a human, never edited by whoever works under it.

---

## Where the numbers live

| File | What | Committed |
|---|---|---|
| the task's history | the measured atoms, **written by whoever dispatched the run** | **yes** — project history, and what makes a rerun resumable |
| the period report | the generated rollup a human reads | yes, **marked generated** |
| the index | the derived cache the rollups compute from — generated, never maintained (`PATTERNS.md` §7) | **no** — rebuildable |

**The cache is not a record**, which is why it may live outside markdown and outside git: nothing
is lost by deleting it. That is the boundary of *"if the system records it, a human can read it
in markdown"* — a record must be readable, a cache must be disposable.

**"Committed" above assumes telemetry lands in the repository, and often it should not** — in
someone else's tree it cannot, and on a small job nobody wants it there. The atoms are still
written, to wherever the record lands → `storing.md`. What changes is durability, and **that is
stated rather than discovered**: a local-only ledger answers *what did this cost* for exactly as
long as the machine survives.

**Publishing cost outward** — to a spreadsheet, a dashboard, a tracker — is an **outward
operation** and therefore gated. Two conditions: **markdown stays canon**, and the publish is
**one-way, never read back as truth**. If the outside system must also write, that is a checkout
relationship with its own `version_seen` and drift detection, declared once → `drift.md`.
