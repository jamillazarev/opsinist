# Entering — meeting a repository that already exists

**Load when:** taking over a repo, coming back to one after time away, or switching between
projects.

**Audit before touching.** Whatever is here was built by someone for reasons that are not written
down, and the fastest way to lose their trust — and the project's history — is to tidy it.

---

## Guest, or successor? Decide this before anything else

**Two different arrivals wear the same clothes**, and taking the wrong one is expensive in a way
that is hard to undo.

| | Successor | Guest |
|---|---|---|
| what you become | the project's operator | a contributor passing through |
| the deliverable | a project that runs | one bounded piece, through their process |
| their conventions | respected by choice | **binding** |
| the debt list | produced, for them | **not produced for them** |
| our files in their tree | yes | **none** |

**Read it from the ground:** whose remote it is, whether `CODEOWNERS`, a PR template or a
contributor guide exist, whether `docs/` carries recent commits from many hands. **Ambiguity is
guest** — a guest who turns out to be the successor loses nothing but a copy.

### Being a guest

**Do not gap-check the invariants.** You cannot turn on branch protection in someone else's
repository, and their missing definition of done is not your problem to name. The invariant check
below is for a project you are taking responsibility for.

**Do not hand them a debt list they did not ask for.** An unsolicited audit of a stranger's
repository is the opposite of what a contributor does. Audit for yourself, silently, only as far
as the piece of work needs.

**Their conventions are not a preference to weigh** — labels, ladder, naming, commit style, review
etiquette. Read `CONTRIBUTING` before writing, and match what the tree already does.

**Nothing of ours lands in their tree.** Not a dotfile, not an ignored file — a stray untracked
file in a contributor's checkout is how it ends up in a review.

**But the record still gets made — elsewhere, and you say where.** This is the half that gets
dropped, because the restraint above is the memorable part: guest work is where the record is
*most* useful, since the checkout may be deleted the moment the work lands and then nothing else
remembers what you changed, why, or what it cost. **Open the record before the first change and
tell the owner where it is** → `storing.md`. This is the arrival where that stops being a
preference and becomes the only correct answer.

**Their tree is a ship target.** The work leaves through their process — a patch, a review, their
checks — and that is `outward`, gated like any other departure → `shipping.md`.

---

## Taking a project over

**Inventory, then gaps, then the interview delta, then apply in batches they approve.**

**Inventory** — what is here: the repository shape, existing conventions, tools already wired,
whatever process files exist, and **the environment fingerprint**, because the same repo behaves
differently on a different machine → `drift.md`.

### How much of it to read is a decision, not a reflex

**Measure the repository before reading it, because measuring is nearly free and reading is not.**
File count, total lines, languages present, the shape of the top two directory levels, how many
commits and how many hands. That is a handful of shell commands and no judgement — **and it is what
turns "read the project" from an open-ended act into a priced one.**

**Past the size the project declares, reading everything is announced rather than performed.** The
number lives in `config.md` as `read_threshold_lines`, so it is a decision someone made rather than
a constant someone hard-coded. Under it, the full read is cheap and is the recommended answer.

**The default is ten thousand readable lines** — source and docs, excluding lockfiles, vendored
dependencies, generated output and binaries, because nobody reads those and counting them makes the
threshold lie. Roughly a hundred thousand tokens: minutes and real money spent before the work
starts, which is where a survey stops being free and starts being a decision. **That number is a
judgement, not a measurement** — it has not been calibrated against a spread of real repositories,
and a project that finds it wrong should move it and say why.

**Three depths, offered with the recommended one already filled in** — the same shape as every
other choice here (`PATTERNS.md` §26):

| Depth | What gets read | When it is the recommendation |
|---|---|---|
| **corridor** | the area this work touches, **plus the coarse shape of the whole** — entry points, how it builds, where tests live, the architecture note if there is one | **past the threshold.** A route between two points is not the whole map, and the map is what costs |
| **base only** | the coarse shape and nothing deep; each task opens what it needs | when the work is a series of small unrelated jobs, or the owner wants to start now |
| **everything** | the full read, with its cost stated before it starts | **under the threshold**, or when the work is a migration, an audit, or anything whose answer depends on the whole |

**The offer stands under the threshold too.** A small repository can still be read task by task, and
an owner who wants to start now rather than wait through a survey is making a reasonable choice —
**it is offered, not assumed**, and *everything* is what the recommendation says.

**Whatever is chosen, what went unread is written down.** This is the half that makes the mechanism
honest instead of merely fast: an agent that later reasons about an area it never opened produces
confident prose with nothing under it, and **nothing in the output marks the difference**. A claim
about unread ground is `unknown` — not judgement, not inference from the parts that were read.

**Two records, and they are not the same kind of thing.** The **choice** is a decision and lives in
`config.md` beside the other settings. The **coverage** is state that grows with every task, and it
belongs in `docs/ARCHITECTURE.md` — the map already exists to stop every worker re-deriving the
codebase, and a map that does not say where it ends is the version of that failure nobody notices.
**Unmapped ground is named there, not left as silence.**

**The reading itself is dispatched, not done in the turn.** Three parts, and only the middle one
waits: **measuring is inline** — it is shell commands and seconds. **The depth is a question**, so
it blocks, as questions do. **The read is background work** — minutes, and the next sentence of the
conversation does not depend on it → `dispatching.md`. An owner watching a survey scroll for four
minutes is being made to wait for something that had no reason to hold the session.

**And it runs a tier down.** Reading a tree and extracting a map is extraction, not reasoning the
parent could not do itself — the most expensive way to survey a repository is at the advisor's own
tier, and it hides in the bill as ordinary work.

**How the corridor's edges are found — read, derived, then asked, in that order.** First the maps,
where they exist: the product map's nodes and the architecture note's *paths a change usually
touches* answer most of it without a question. Then **the tree's own evidence**: what calls and
imports the thing being changed, and **what history says changes together with it** — `git log`
over the touched files is a measured answer to "what else moves when this moves", and it is
sitting in every repository unread. **The owner fills only the remainder** — the interview-delta
law applied to impact — **and what they assert about the tree is checked against the tree**, the
same way a "it's built" claim is: named ground the callers contradict is a finding, not a fact.

**What the read learned about how the product is walked lands in `docs/MAP.md`** — the corridor's
product half is the map's first version, written down instead of evaporating with the session →
`mapping.md`.

**The corridor widens on demand, and widening is announced.** A task reaching past what has been
read says so and reads further; it does not quietly expand into a survey. **What has been covered
so far belongs in the record**, so the next session starts from the map that already exists rather
than rebuilding it → `storing.md`.

**A guest reads less, not more.** Someone else's repository is where a full survey is least
justified and most expensive: read the corridor the issue actually touches, and stop.

---

**Gap-check against the invariants only.** Not against taste. The invariants are the small set
without which nothing else holds: a guide, a way of writing work down, the four gated kinds, and a
review that goes to someone other than the author.

**"Invariant" names what we stand up and check for, not what the owner may not touch.** Three of
the four **protect the work from itself**, and an owner who says they do not want one has said it
— the risk is named once and it goes off in writing, with the manifest telling the truth
afterwards (`requests.md`). **The four gated kinds are the exception**, because they protect the
owner *from us*: spending, leaving the project, destroying, and changing the shape of the team.
A set nobody may decline would not be a small set of invariants, it would be a licence agreement.

**Interview delta** — ask only what the existing setup does not already answer. Walking someone
through twenty questions they have already answered in their own files is how a takeover starts
badly.

**Respect incumbent conventions.** Their labels, their ladder, their naming. A convention that
works and differs from the default is not a defect, and replacing it costs more than it returns.

**An old format makes this a migration target, not a broken project** → `upgrading.md`.

---

## The debt list — and this is the part that is usually missing

Finding gaps is easy. **Classifying them is what makes the list usable**, and a list without the
classification is just criticism.

**Every finding is either blocking or deferrable, and it says which, with the consequence named.**

**Blocking** — the work cannot honestly proceed:

- **no branch protection where a remote exists** → the review gate is a sentence, not a gate
- **no definition of done** → "done" means nothing, so nothing can be accepted or rejected
- **no architecture map** → every worker re-derives the codebase on every run, forever
- **credentials in the repository** → rotate first, discuss after
- **the guide promises documents that do not exist** → agents told to read a missing file
  improvise, and improvisation is how conventions drift

**Deferrable** — real, and survivable for now. Goes to the deferred list **with a revisit trigger
that is a moment, not a date**: *"before anything public ships"*, *"at the first paying customer"*.

**Present the whole list at once**, with what each fix costs, and let them say *"do it all"* or
pick. **Not one finding per message** — the same rule as the environment ladder, and for the same
reason: a sequence of individually reasonable prompts is an unreasonable experience.

**Nothing is fixed before they have seen the list.** A takeover that starts by changing things is
a takeover nobody asked for.

**And this one sentence is performed rather than promised**, because it is the sentence a run
under pressure drops first — measured on `N8`, twice, at zero: runs edited source, deleted files
and committed, all before any list existed. `hooks/audit-gate.py` ships with the plugin and
**refuses a mutating call in a repository being taken over while no debt list is there** — a
write or an edit to a *tracked* file, or a mutating shell command. It disarms the moment
`LATER.md` (or `docs/DEBTS.md`) exists at the root. **Reading is never blocked, and neither is
creating something new** — the list, a guide, `docs/` — because the gate is about the order of
the evidence, not about holding the work still.

**And it holds the other end too, at the moment the run tries to finish**: a takeover that
presented deferrable findings and wrote no `LATER.md` is stopped once and asked to write them
down. Measured — with only the first half in place, four runs in five said the deferrable half
and left nothing behind, which is the same failure as fixing before the list, arriving from the
other side. **A deferral nobody wrote down is a deferral nobody revisits.**

**A guest trips neither half**, because a guest owes no debt list at all: `CODEOWNERS`, a
contributor guide, a PR template or a history in many hands stand both gates down, and
*ambiguity is guest* means they stand down on doubt rather than press. Where the runtime does
not honour hooks this is prose again (`runtimes.md`), and **the gates check the order, never the
honesty**: a list written to get past one is exactly the forgery a gate cannot see and a reader
can.

---

## Coming back to your own project

A different question, and it is the one nobody built for: **what happened while I was gone.**

Four parts, and blending them hides the ones after the first:

| Question | Source |
|---|---|
| **what needs me** | open requests, with their ages → `requests.md` |
| **what happened** | the notification feed — events, bounded, ageing out |
| **what changed that we did not change** | the environment fingerprint → `drift.md` |
| **what is still undecided** | records kept outside the repository, with their age → `storing.md` |

**Computed from the task histories, never stored**: closed since the last session, requests open
and how long, spend since then, **anything that regressed** — an interrupted run marked at session
start is exactly the thing a returning owner should see first.

### Ending one, starting the next — what the owner actually does

**Nothing here is a command, and there is deliberately no "log out".** A session ends when the
owner closes it; the advisor cannot end its own. What it can do is **make the ending clean before
that happens**, and the words that start it are ordinary: *"I'm done for now"*, *"wrapping up"*,
*"let's continue tomorrow"*, *"I want to carry on in another tool"*.

**And it is offered rather than remembered.** When the signals are there — applied work sitting
uncommitted, a long session, a piece just finished — **the wrap-up is proposed**: *"before you go:
two files applied and not committed, and the thread on T-4K2 has no closing note. Land both?"* An
owner who has to know the ritual to get a warm start next time does not have a console,
they have a checklist.

**The wrap-up is three things, and all three are writes:** the tail of anything in flight written
to its thread, applied work committed, and any decision reached in conversation recorded where
decisions live. **Then the session can be closed from anywhere** — a terminal, a tab, a laptop
lid — because nothing is left in it.

**Starting the next one is the same act wherever it happens.** Open the project — same directory,
different tool, different machine — and **the arrival summary is the first thing said**: what
needs you, what happened, what changed that you did not change, what is still undecided. That is
where the previous state comes from. **Nothing is carried in the session, so nothing has to be.**

**Clearing a terminal costs nothing and loses nothing**, which is worth saying plainly because it
looks destructive. The transcript is a source, never a dependency: what mattered was written down
as it happened.

**If the session ended badly — a crash, a closed lid, a limit — the next start says so.** The
interrupted run is marked, the task visibly regresses, and recovery separates committed from
applied from remaining → `recovering.md`. **A bad ending costs a summary line, not the work.**

---

**Leaving should be as deliberate as arriving.** A conversation with a role ends with a wrap-up —
tail written to its thread, distilled if it crossed the threshold, control returned. **A session
that ends without one is an interrupted run**, and the next start notices. **The same is owed when
leaving a project**, and it is the piece most often skipped, which is why returning feels like
arriving cold.

---

## Switching between projects

**A session is bound to a working directory**, so switching projects is **opening a session
somewhere else** — not changing a setting inside one. That is a fact about the runtime, and
pretending otherwise produces a command that cannot do what its name says.

So switching is two things: **knowing which project you are acting on**, and **arriving there
properly** — the summary above, not a blank prompt.

**Which projects exist, and which you were last in, is personal** and lives outside any of them,
along with language preferences, editor choices and bookmarks. **Project canon travels with the
project; preferences do not** — and a project must never become unopenable because someone else's
preferences are missing.

**Say which project you are acting on before acting**, whenever more than one is in play. Doing
the right thing in the wrong repository is a failure with no error message.
