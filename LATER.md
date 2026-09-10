# Later — deferred, each with a moment that reopens it

**This project's own deferred list**, kept by the rule it gives everyone else: **a revisit trigger
that is a moment, not a date**. A deferral with no trigger is an abandonment wearing better
clothes, and this file exists so the ones here can be told apart from the ones nobody wrote down.

**What belongs here:** something real, understood, and consciously not done now. Not a wish, not
an idea — those go to the backlog or nowhere. **What does not belong here:** anything that stops
work now, which is a task with a blocker instead.

---

## ~~`diagrams.md` is at its budget~~ — answered 2026-09-06: beside the rule, not in a gallery

**Measured 2026-08-15**: the file stood at **499 of a 500-line chapter budget** while
`self-maintenance.md` §What-a-capability-owes requires a diagram for every new mechanic — two rules
meeting at the next one. The question was never where a diagram goes but **whether `diagrams.md` is
a chapter or an index.**

**Answered 2026-09-06, by use rather than argument.** Two releases running put their diagrams beside
the rules they draw — the contradiction stop's in `escalating.md`, the cost one in `cost.md` — and
twice in one session a repair owed none and said so instead of manufacturing one. **The gallery
reading was the collision course, not the budget**: a file holding every diagram meets 500 at each
new mechanic; one holding only what crosses several rules does not. `self-maintenance.md` §4 now
says so, and the file sits at 500 of 500 and stays there.

## ~~Measure what the day-one cut actually bought~~ — run 2026-08-01, partly falsified

**Closed by measurement, and the verdict is split.** The **ordering** claim confirmed: the first
task is now written second, before every document, where it used to arrive after the scaffolding.
The **volume** and **time** claims **falsified** against criteria written before the run and kept
in `evals/RUNS.md`: still ten to thirteen files, and turn two still at four hundred seconds against a stated
threshold of three hundred. `evals/RUNS.md` carries the table.

**What it taught, and the next thing to try:** the gate could see *order* and enforced it; it
cannot see *emptiness*, so once the task exists every document passes. **The corpus says day one
is four things and the hook enforces something narrower — the gap between them is the thirteen
files.** The predicate that would close it is *refuse a document whose body is a heading and a
template's braces*: checkable, a commission, and the shape that has worked twice. **Not
attempted**, because the criterion comes first — **and that half is open work under a struck
heading**, which the 2026-09-06 audit read past. Its form question is the *Nothing here measures
whether a DOCUMENT works* entry, which asks the same thing.

**The criteria that made the verdict possible** — written before the run, kept whole because
criteria written after a result are not criteria — are in `evals/RUNS.md` under *the day-one cut*.
They were held here until 2026-09-07; they are evidence, and the entry itself said *"It is not open
work."*

---

## A generated Opportunity-Solution-Tree view over the specs

**Deferred because** the data half landed on 2026-08-06 — the spec's `Opportunity` field names
the need and cites its insight, so every new spec feeds the tree — and only the generator
remains: mermaid between markers (`PATTERNS.md` §6, same shape as `touched by:`), a day of
work with no requester yet. A view nobody reads is furniture; the field is not, because a
solution with no opportunity above it now fails a read even without the picture.

**Revisit when** the first project running product discovery asks to *see* the tree, or a
review finds a solution shipped with no opportunity above it.

## A terminal UI over `_ops/` — deferred, with the boundary that would shape it

**Named 2026-09-07**, when the owner asked how hard a herdr-like terminal UI would be. **The deferred
thing is the build**; what follows is why not, and what is decided so it is not re-argued.

**Native-first, dated.** `herdr` (read 2026-09-07) **supervises CLI agents rather than being one**,
so this skill already runs inside it and there is nothing to port; its plugin surface carries
executables, not context.

**The boundary, stated without naming anyone.** A pane holding a live process belongs to whatever
supervises the session. **This system refuses that half on purpose** — nothing load-bearing lives in
a session — and owns the durable one: who exists, what they may do without asking, what is assigned,
what it costs, what waits on the owner. **Build the session half here and the result is a worse
supervisor bought with the founding premise.** The move the other way is cheap and holds for any
supervisor: it sees that an agent stopped and not why, while `_ops/` knows which task, which gate
and what the wait costs — **the reason can go on someone else's status row without this system
growing a session model.**

**Settled, each an existing rule applied:** **no model in memory**, every repaint re-reads · **no
silent subset**, a count line says what it could not read · **one writer** — it reads, the agent
writes, the owner edits · **no chat outside a thread** · the first view is **the bill for the
owner's attention**, which is `/status` repainting · **not columns**, because a wave is not a column.

**Why not now.** Nobody asked for the build, and the one screen with no substitute — *what changed
in `_ops/` while I was away* — has never been wanted aloud.

**The candidate form:** the parser refuses a malformed entity and the count line reports it. **The
mutant is a tree where one task's status line is bolded differently and the display shows the rest
without a word; the twin is that tree read whole.** `scripts/transition.py`'s `field()` already reads
the prose form tolerantly.

**Revisit when** an owner asks *what changed while I was away* and answering means reading
`git log -- _ops/` by hand.

## `starts: webhook` — an external trigger the automation can declare

**Reopened as a live candidate 2026-08-06 — the listener now exists somewhere real.** OpenClaw
was measured on this machine: a resident WebSocket gateway, `cron`, agent hooks — the first
runtime that could actually *hold* a declared trigger, where every earlier survey found only
serverless sessions. The shape stays settled: `webhook:<name>` beside `schedule:<cron>`,
executed by the host that has a listener, under the schedule's own law — *one that silently
did not run is worse than one that says it was late*.

**Revisit when** the first automation actually needs an external event — and the first step
then is verifying OpenClaw's trigger surface (its cron/gateway API), not building one.

## A tripwire for work bypassing the machinery wholesale

**The evidence:** a live project split into two eras at one commit — before it, six honest run
records and twelve tasks with done-definitions; after it, **0 of 33 commits touched `_ops`** while
the site shipped, decisions changed unrecorded (domain, language count, act format), and the
board froze at "created". The guard fired on every commit and had nothing to say, because no
check reads *work advancing while the record stands still*. The shape of the form: the project
preflight warns — never fails — when the last N commits carry zero `_ops/` paths in a repo whose
guide declares an operator. **Warn, not fail, and once**: site work is legitimate; the record
going dark is the smell. **Revisit when:** the next takeover audit or field report shows a second
project with a dark era — twice is the threshold everywhere here.

## A channel that reaches the owner who is away

**Requests age in files, and nothing tells an owner who is not at the terminal.** Evaluated
2026-08-14: Agent-Reach (71k★, MIT) — declined; despite the name it is **inbound only** (agents
reading platforms via cookie scrapers, ToS-gray, churn-prone), it contains no notification
surface at all. The honest candidates remain the harness's own push notifications and a
Telegram-bot shelf row (one token, owner-controlled, off-terminal). **Revisit when:** a request
ages past its threshold unseen in a real project — that is the moment the need names the row.

## A market-recon distillate template for `research/`

**The folder exists with no named shape** (`project-layout.md` — "studies and their
distillates"), and a live project's recon produced clean per-study documents with nowhere agreed
to converge. The substance worth keeping from the 2026-08-14 gap analysis: analogs land in the
competitor register (now with stage/outcome) · what-to-borrow and risks-and-failures as
distillate sections citing register rows · the delta is the positioning brief, homed in
`BRAND-template.md` §Positioning. **Revisit when:** the next real market-recon study is
commissioned — a template written before its second use is a guess.

## The advisor-side half of the doors: nothing forces wiring at stand-up

**Measured 2026-08-14, N89 at 0/3** (2 of its 5 runs voided): every graded day-one run stood the project up ad hoc — no
guard wired, no doors, no type file — so the guard's new doors check (the wired-project form,
landed the same day) never gets its chance. The prose instruction alone does not survive
contact, which is this corpus's oldest measurement. The candidate form: the plugin's own
SessionStart hook already delivers the migration fact in operated projects — the same mechanism
can say, once, *"this operated project has no wired guard and no doors"*.

**Revisit when:** a round re-measures N89 with the wired-project form in the field — if ad-hoc
stand-ups persist, the hook line is built, and a second round with no passes is the threshold. (This said
*"the next full round after 0.2.7"*; eight releases later N89 has been measured once, so the
version was never the condition — the second measurement is.)

## The council has a field but no gate, and a document has no seam to hold one

> [!NOTE]
> **This is a debt against the capability bar, not work consciously deferred** — the distinction
> this file's own contract draws. It stays because the missing half IS deferrable and its trigger
> is real; what belongs beside the bar, and not in a list of things not yet built, is the
> admission that the bar was not met.

**Named 2026-08-14, at the release that shipped it.** The capability bar has four clauses and
says *no exceptions for small ones*; the council shipped with the showcase trio and a declared
field (`angles · voices · provider`), and **without the other two — no form where it can fail,
no mutation test, and therefore no dated measurement of the field ever appearing**. This is
written here rather than implied met.

**Why no form today.** A council is a consultation: zero standing footprint, so its synthesis is
an answer in a conversation, and there is no artifact for a gate to read. Every enforceable rule
in this corpus keys on a file — a staged commit, a row, a request. The declaration is real
guidance and unenforced guidance, which is the class this corpus keeps measuring at ~0/5.

**Revisit when** either becomes true: a council's synthesis is written to a file (the owner asks
to keep it, or a research flow persists one) — that file is the seam, and the gate is a
missing-declaration refusal with its mutant · **or** the next full round measures whether a
council fires with its price and its declaration at all, which would give the claim its date. If
a round shows the field is simply not written, the honest repair is to delete the sentence rather
than repeat it louder.

## The repair exemption is judgement, and the test that would replace it has not paid its price

**Named 2026-09-07, the day it was written and taken back out.** `self-maintenance.md` §4 says a
repair owes only the fact, not the diagram and not the situation. **Nothing decides what a repair
is** — clauses 1–3 of the bar name artifacts a script can find; this one is answered by a sentence
in the changelog, written by the person who wants the answer, and it was claimed twice in one
session before anything checked it.

**The test that would close it:** *a change shipping a **new form** — a gate, a field, a refusal —
is a new mechanic and owes the trio; a change that only alters what an existing form reads is a
repair.* Read off the diff, not off the author's account.

**Why it did not ship the day it was written.** `self-maintenance.md`'s promotion ladder puts a rule
at rung 3 and charges **a week between the first dated line and the promotion, and it still
reproduces**; this was conceived and written into a standing chapter in one sitting, which is that
section's own dotted branch — *promoted the same day* → *a rule that was true once, on one machine,
about one version*. Its exception is a defect with a live blast radius, and a test telling authors
how to classify their own changes is a lesson.

**What a form would read**, when it has earned the rung: `preflight.sh` §1b-bis already resolves the
last tag and names `${last_tag}..HEAD` as the lens range, and §11 already reads the entry being
shipped. A check greps that range's diff for a **new section header in `templates/company-preflight.sh`**
— the shape that file writes is `# N · `, **never `§`**, whose occurrences there are all prose
cross-references — or a **new required field in a template**, which is what `+| **Verdict** |` was.

**The pair only works if the check refuses a form signal answered by an unbacked claim** — that is
the condition, and a trim once replaced it with the weaker *"the twin must pass"*, which states what
lets the honest case through and not what stops the dishonest one. **The mutant is a release whose
diff adds a section header and whose entry says *repair* with no trio; the twin is one whose diff
adds no form and says the same** (a first draft accepted *the word `repair`* as an answer, so the
mutant passed) — the twin must pass, or the check refuses everything.

**Revisit when** the exemption is claimed in a release at least a week after 2026-09-07 and still
reads right. **Do not count the citations inside the release that wrote it**: 0.2.16 applied the
idea three times in one commit, which is one occasion.

## The two capability bars have diverged, and neither repository says so

**Named 2026-09-07** by a lens asked to compare them. `self-maintenance.md`'s bar and the sibling's
`AGENTS.md` bar agree on clauses 1 and 2 — a form where the rule can fail, a mutation test — and
are disjoint on 3 and 4: this repository asks for **the claim dated with its measurement** and
**the showcase trio**, the sibling for **a scenario and the fixture it needs** and **a door**. Each
file says *four things* as though its own partition were the finding.

**It is mostly one set cut two ways, and that is the part worth fixing.** The sibling's *door* is
this repository's rule too — `AGENTS.md` carries *every capability has a door* outside the bar. The
sibling's *scenario and fixture* is enforced here in code and omitted from the stated bar:
`preflight.sh` warns when a version bumps and `evals/runsheet.tsv` is unchanged. The trio lives in
the sibling as a session-loop step with a narrower fact rule; the dated claim is folded into its
clause 1.

**Why not now.** Reconciling two bars is a change to both repositories' always-loaded contracts, and
the honest first step was the smaller one already taken: §4 no longer claims *both siblings' ledgers
carry the receipts* for clauses the sibling does not hold. Merging the partitions is a bigger move
than one release, and doing it while the divergence is one day old repeats the mistake the entry
above records.

**Revisit when** a third repository takes this bar, or when a capability ships in one repository and
is ported to the other — the first time the two lists have to agree on one object, which is when a
difference stops being a wording question.

## The promotion ladder's week has no form, only a citation a form could read

**Named 2026-08-21, at the release that shipped it.** `self-maintenance.md` now says a lesson
waits a week between its dated field-note line and its promotion to a rule — a filter against a
corpus that fills with laws written the afternoon something broke. **Two of its three parts are
already machine-readable** and one is not: field notes carry a `Date` column, and a promotion is
told to cite the line it came from, but **nothing reads the citation against the note's own date**,
and nothing notices a rule that cites nothing at all.

**Why no form today.** The seam exists — a promotion touches a rule file and a field-notes line in
the same commit — but the gate would have to tell a *promotion* from any other edit to a rule
file, and there is no field declaring one. Inventing a field for the gate's convenience is the
shape this corpus refuses: the form should read something the work already writes.

> [!NOTE]
> **The precondition landed 2026-08-27, and the gate deliberately did not.** Read the trigger
> below before concluding otherwise: the column existing is not the trigger, a closure written by
> real work is. The closure this entry waits on
> (`checking.md`) was prose with no cell to hold it; it is a column now. **Building the gate in the
> same hour would be the law written the afternoon something broke, which is the exact thing this
> ladder exists to filter.**

**Revisit when** a `Closed` cell is filled **by a sweep closing real work** in a project running
this skill, and that closure reaches here as a field report — not by the person who added the
column, and not by a note written to demonstrate it.

The template can hold the closure now; what the gate waits on is one
written for its own reasons, because a gate built on a shape nobody has used yet is a gate built
on a guess. The gate then reads: a rule added to an always-loaded file in the same commit as a
closure whose dated origin is under seven days old is refused, naming both dates. **The mutant is
a same-day promotion; the twin is one dated eight days back.** Until then the week is judgement,
and it is written here rather than believed.

## Depth was demoted before its tag, and owes the measurement it never had

**Named 2026-09-10, by the adversarial lens on the release that shipped it.** A three-rung depth
ladder for research — *orienting · deciding · standing* — went in as a **required field with a
guard**, and no measured defect stood behind it. The bar asks for **the claim dated with its
measurement**; the date belonged to a runtime check and nobody had been observed getting it wrong.
*A rule that cannot point back at its dated origin has not climbed — it was declared.*

**Demoted the same day to guidance that admits it.** Two defects went with the gate: its `standing`
cross-check guarded on `sources/SOURCES.md`, **a path no operated project has**, so the clause the
entry led with was dead everywhere it shipped; and its enum accepted the empty string, waving a
blank `Depth:` through while refusing an honest `Depth: TBD`.

**Revisit when** a research request is measured against a stated rung, or an owner objects to what
a search cost after it ran.

## The lens round has no form, and its range cannot see the repairs it prompts

**Named 2026-09-07**, by the adversarial lens reading the release that added the repair pass.
**Nothing counts rounds**, so a skipped lens and an empty one are the same artifact — `preflight.sh`
says so at every release, which is honest and is not a check.

**And the range has a hole the moment the tag is cut early.** `<last tag>..HEAD` contains a repair
until that repair's own tag exists, after which it is an ancestor and every later range excludes it.
Measured: `1727542`, the repair 0.2.16's re-run produced, is an ancestor of `v0.2.16` and absent from
`git log v0.2.16..5f76d30` — **the commit that motivated the rule is the one a deferral to "the next
round" would have missed.** `lenses.md` closes it by ordering, which is a rule and not a form:
nothing refuses a tag cut between rounds.

**The candidate form:** record the reviewed range in the entry, and have preflight refuse a tag when
that range does not reach `HEAD`. **The mutant is a release whose recorded range stops short of its
own repair commits; the twin is one whose range reaches them.**

**The sibling already ships two thirds of this.** Its `scripts/lens.sh <lens> <base-ref>` runs one
lens as an isolated headless session — own config home, no connectors, `Write` denied — beside a run
record that lists `not run` rather than omitting it. **And it has the state this project lacked**: a
lens that exhausts its budget is recorded as **not completed**. That half was ported 2026-09-10 after
nine agents died on usage limits across three rounds with nowhere to record it but prose.

**Why no form today.** A runner is a capability and owes the bar. **And the cost is undeclared** —
one round per release, with no number on a lens pass anywhere, which is the adversarial lens's own
fourth question unanswered by a rule it reviewed.

**Revisit when** a release ships a defect the previous release's repair introduced, or when any lens
round is measured for what it costs.

## Convergence between independent reviewers is not read as a signal

**Named 2026-08-28**, from `qa-swarm` — surveyed in the 0.2.14 entry, whose `catalogue.md` row
0.2.16 removed. The four lenses already run independently
and each reports even when empty, which is half of what that harness does. The half we do not do
is the cheap one: when two of them land on **the same file and the same line**, that agreement is
evidence, and this project currently treats it as a duplicate to be merged away. A finding two
blind readers reached separately is not the same object as a finding one reader reached twice.

**Why no form today.** Lens output is prose in a task notification, not a record with a file and a
line — so there is nothing to compare. The same objection `LATER.md` raised about the contradiction
stop applies, and the same answer resolves it: **wait for a flow that wants the finding written
structurally for its own reasons** rather than adding the shape for a counter's sake. The review
request is the candidate — a review that lands as findings with locations is useful to the
requester whether or not anything counts convergence.

**Revisit when** a review answer carries findings as rows. The gate then reads: a finding two
independent reviewers reached is promoted, and the promotion is recorded, so a later reader can
tell an agreed finding from a repeated one. **The mutant is two findings from ONE reviewer merged
and promoted; the twin is the same pair from two.**

## An install copy carries what the source gitignores, and the inventory reads it as ok

**Measured 2026-09-07**, during 0.2.16's re-sync. Both copy-route installs on this machine hold
**13 MB against a tracked source of 3.1** — `ledger/`, `brandkit/` and `.claude/worktrees/`, all
gitignored here and shipped by nothing (`git ls-files` over them returns zero). An earlier rsync ran
without excludes and every re-sync since preserved them.

**Why it is more than megabytes.** An install directory holding a lens worktree holds a second
checkout of this repository, at some other commit, inside a tree a runtime loads. Nothing reads it;
nothing says it is there either. `find-installs.sh` reads both copies as **ok** because it checks
the version stamp and not what else came along — the same shape as the mount-config entry, where
the inventory is silent about a state it never looks at.

**Half of it is closed**: the copies moved this time by `git archive <tag> | tar -x`, which emits
tracked files only and cannot carry an ignored path — the drift stops growing, and does not shrink.

**And one act is owed rather than deferred**: the 13 MB stayed because the comparison `CLAUDE.md`
requires — untracked artifacts checked against `origin/main` before removal — **was not run**. That
waits on somebody, not on a moment. Do it the next time a copy install is touched for any reason.

**Why no form today.** The obvious check — `git check-ignore` the copy's paths against the source —
needs the source present, which is the one thing a copy install does not guarantee.

**Revisit when** a copy install is moved by anything other than `git archive`, or a second machine
shows the same spread.

## The inventory is silent when a mount's CONFIG goes and its directory stays

**Named 2026-09-05, doing the ritual.** `find-installs.sh` gained a hermes row because a mount is
an install even though no file lands anywhere, and its comment covers one direction: *"it outlives
the directory it points at, which is how a cleanup elsewhere silently unplugs it."* The other
direction happened this release. `~/.hermes/` was removed between two runs; the row simply stopped
appearing, and `~/.agents/skills/opsinist/skills` still holds 21 files that hermes had been
mounting. The inventory's output is the canon by this project's own rule, so a canon that shrinks
without saying why is a canon that has to be re-derived by hand — which is what it exists to stop.

**Why no form today.** The honest check is not "did a row vanish" — rows vanish legitimately all
the time, and a diff against a remembered count is the shape this corpus refuses. What it wants is
a directory that *looks* mounted with no config naming it, and "looks mounted" has no test yet
beyond "a runtime we happen to know about used to point here". Guessing at that would be a check
that cries wolf, which is worse than this silence.

**Revisit when** a runtime's mount is recorded somewhere the inventory can read back — a stamp the
install itself carries, rather than a config only the runtime owns. The gate then reads: a
directory carrying our manifest, inside a runtime root, that no config mounts is reported as
orphaned. **The mutant is a live mount reported as orphaned; the twin is this exact case — config
gone, directory full — reported once and by name.**

## A "should this exist at all" ladder, and whether it changes anything

**Named 2026-08-22**, from a third-party plugin the owner asked about (`DietrichGebert/ponytail`,
**MIT, read 2026-08-22**). Its content is one ladder an agent walks **before writing code**: does this need to exist · is
it already in the codebase · standard library · a native platform feature · an installed dependency
· can it be one line · only then a minimum implementation.

**Why it is a real gap.** `choosing-tools.md` holds a ladder for *which vendor*. Nothing shipped
asks *should this code exist at all*; the nearest thing, **native-first**, lives in `AGENTS.md`,
which governs this repository and never reaches a project.

**Why it is not taken.** Its headline rates carry no denominator, no corpus and no date, and
*100% safe* is not falsifiable — the ladder can be taken, those numbers cannot be quoted. And **a
finding does not become a rule the day it is found**: two capabilities shipped in 0.2.9 whose prose
measures 1 in 10, so a third before the first two are measured is what `self-maintenance.md`
refuses.

**What the round bought, and it narrows rather than answers.** The prose arm measured **1 of 10**.
**N102 is N97 with *"then commit it"* in the turn, the only difference, and it converted 3 of 3** —
**the two rates do not share a denominator**: 1-of-10 is over every dispatch, 3-of-3 over the three
of five that reached the gate. So a ladder **shipped as prose** lands in the band this corpus
measures near zero; whether one shipped as a **form** changes anything is untouched. If it arrives,
it arrives as a form.

**Revisit when N97/N98 are re-run** against a decision this round left open — whether a scenario
meaning to reach a gate must say *commit it* in the turn, or whether not-committing is itself the
behaviour under test. The old trigger said *"when N97/N98 have measured the gates in the wild"*, and
they ran without measuring them: a `validator` reaches only a worker that commits, ten runs
committed nothing, and the round closes with **"0.2.9 has no gate measurement"**.

**Do not install that plugin alongside this skill** — two plugins instructing one agent about how to
write code is the shadowing trap `evals/RUNS.md` measured.

> [!NOTE]
> **Closed 2026-09-06 and reopened the same day by three lenses.** The closure called the round's
> prose arm *"a declared gate, in the field"* and cited a page whose closing line says the gates were
> never reached. **An audit that reads triggers against reality has to read the evidence file, not
> the trigger's summary of what would satisfy it.**

## Nothing here measures whether a DOCUMENT works, only whether a rule holds

**What it is.** Every scenario in `evals/` puts a run in a situation and counts whether the rule
survived. None of them asks the other question: given this document and a task, what comes back —
how many tries to a clean result, how many violations of what it teaches, how big the output, how
far each iteration moved, what the reading cost. A rule can hold inside a document nobody can use,
and a document can produce good work while the rule inside it is never reached. The corpus has
sixty-odd documents and no measurement of any of them as a document.

**Why not now.** It is a second harness, not a scenario: several runs against one task, an
artefact compared across them, and counts that are not pass/fail. The existing rig measures a
verdict; this measures a distribution. Building it while the scenario rig still owes RUNS — N97 and N98
have never measured the gates they were written for — would leave two half-harnesses instead of
one whole one. (An earlier draft of this line said those scenarios owed *fixtures*; all four named
are bound in `evals/runsheet.tsv`, and two of the ids were written without their `N`.)

**What reopens it.** A document is rewritten for readability and nobody can say whether it got
better — the argument that has already happened twice about the always-loaded core and once about
`diagrams.md`. That is the moment: the first time a rewrite is proposed and defended with taste
alone.

**Where the method came from.** Sanity Labs measured their own design system this way and
published the findings, the method and the runner (`catalogue.md`, *Does the design system survive an
agent?*). Their counts are the borrowable half; their tool is theirs.

---

## A lens reporting an absence never says how it looked — and twice in one day it had grepped

**Two false findings on 2026-09-10, both from the same round, both the same shape**: the lens
searched for a term, found nothing, and reported the mechanic missing.

- **"The 500-line chapter budget has no form."** `scripts/preflight.sh` reads `chapter_budget`
  from `SKILL.md` and had failed on it three times that day. The lens grepped the literal `500`.
- **"`use-cases.md` has no situation for the contradiction stop."** The row *"It passed, then it
  failed, then it passed"* carries the whole mechanic — the stop at the **second** disagreement,
  the count as flips, the escalation as *the question is unstable*. The lens grepped `contradict`,
  a word that file is built to avoid: **its rows are the owner's words by construction**, so the
  mechanic's own vocabulary is the one thing guaranteed not to be there.

**The shape is narrower than "a lens can be wrong": a search for a mechanic by its name fails
wherever the convention requires it to appear under another one** — a value against its variable, an
internal term against an owner's sentence. Both looked exactly like a true finding, because **an
absence is the one claim that needs no evidence to state.** The form it wants exists next door:
`Reads against` makes the writer choose between `none found` — a claim — and `not checked` — honest
ignorance, and an absence wants the same cut, **what was searched and where**, so a reader can see
that one grep of one word is not a search. `lenses.md`, *What the lenses do not cover*, is its home.

**Not promoted today, deliberately** — both occasions are one session, and rung 3 costs a week
(`self-maintenance.md`, *the ladder*). This is rung 2, and writing the rule now is the dotted branch
that ladder draws.

**Revisit when** a third false absence is reported, or the week has passed and these two still
reproduce. **The cost to weigh then is real**: every finding would carry the line, and most findings
are not absences.

---

## Closed — the outcome, kept so they can be told from the ones nobody wrote down

| What was deferred | How it ended |
|---|---|
| A wave's failure policy | carried in 2026-08-06, with its second occasion |
| A `pack` mode for the inventory script | deleted 2026-08-06, by the owner's call |
| A nested layout — the machinery under one root directory | carried in 0.2.0, by the owner's call |
| Project-local skills must survive an upgrade that ships a same-named stock skill | reopened 2026-08-05, taken into the release |
| The contradiction stop has no form | shipped in 0.2.14 |

**Bodies removed 2026-09-10.** Each of these ended in a decision that shipped and left no open
question, so the reasoning lives in the release that carried it and the row here says which. **Two
struck entries above are NOT in this table**: the diagrams one because `self-maintenance.md` cites
it by name, and the day-one cut because it still hides open work under a struck heading.
