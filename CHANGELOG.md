# Changelog

Newest first. Each entry leads with what you can now do, not with which files moved.

## 0.1.2 — 2026-07-31

**This release is mostly about knowing what is true.** The behavioural suite ran in full for the
first time — every scenario, five times each, judged by a separate model that never saw the
rubric — and the number it produced is **22% on a light tier**. That figure is in
[evals/rates-2026-07-31.md](evals/rates-2026-07-31.md) with a row per scenario, and the method,
the confounds and the things it does not prove are in [evals/RUNS.md](evals/RUNS.md). **Nothing
here claims the number improved.** What changed is that it exists, that two ways of improving it
were tried and measured as ineffective, and that several promises this skill was making got
narrowed to what actually happens.

---

**Installs are discovered, not remembered.** `scripts/find-installs.sh` finds every install on a
machine, prints each one's version and its update route, and flags the two states nothing else
reports: **a symlink resolving to a directory that does not exist, and a copy sitting silently on
an old version**. It exits non-zero when either is present. Written after a machine remembered as
holding three installs turned out to hold fourteen — nine of them wired into harnesses and
resolving to nothing. `upgrading.md` now runs it as a step *before* updating and again after.

**Scheduling is stated per runtime, because it differs per runtime.** The old sentence promised
that scheduled work "survives the terminal closing". Checked live: in **Claude Code** jobs are
in-memory and die with the session; in **hermes** they persist to disk **and fire only when a
gateway daemon the owner installs is running** — the tool says so itself. Everything else is
**unknown and treated as session-only**. *"It will run tonight"* is now named as false on a
per-session runtime.

**A spend cap says what it can do.** *"Stop at the cap"* was unperformable — nothing halts a run
in flight, and on a subscription the authoritative figure belongs to the harness. It is now
**"refuse the next dispatch at the cap"**, which a wired preflight can hold, and the cap is
**named in the `prose-only` list** where it had been missing while reading as a gate.

**An instruction inside a tool's answer is refused more often than it was.** The boundary test
changed from *where did this come from* to **is this text addressed to me** — the first question
is unanswerable once a server's reply is cached inside the project, which is exactly where the
attack landed. Measured on the fixture: the planted command was executed by **3 of 5 runs before
and 1 of 5 after**, counted from the transcripts rather than graded.

**Transitions end in a named offer.** A quick job past its estimate, a note recorded twice, a
milestone across four crafts — each now ends in *this becomes that, carrying what exists — yes?*
rather than an open question handed back. Recognition already worked; taking the step did not.

**What did not work, and is written down as such.** Five well-formed repairs left the aggregate
flat. Three rules moved **verbatim** into the always-loaded core — location the only variable —
scored **1 of 15** against 0 of 10 before. So `self-maintenance.md` now records both as measured
dead ends: **a rule that only asks gets skipped, however well worded and wherever placed.** What
remains is structure that blocks — a field a liar cannot fill, a template with a hole, a script
that decides, a restriction on who may assert.

**The suite is a rig now, not a ritual.** Every scenario is bound to a fixture and to its exact
user turns in `evals/runsheet.tsv`; `eval-suite.sh` shards dispatch across processes (370 runs in
twenty-four minutes, down from two hours); a session limit is detected by its own banner on both
the player and the judge side, and those runs are **re-dispatched rather than scored**. Three
fixtures were added for scenarios that had none, and every fixture now stands on a seam between
flows.

**A capability audit started**, in [evals/capability-audit.md](evals/capability-audit.md): one row
per mechanism, asking not whether it is worded well but whether it happens — with a verdict of
*no hook · hook unwired · works but unmeasured · prose that shapes*. It is unfinished, and the
mechanisms not yet reached are listed by name.

---

## 0.1.1 — 2026-07-31

**Behaviour, measured.** Twenty-two runs on a light-tier player over six rounds, against a frozen
and fingerprinted corpus, found seven defects in this skill and five in the machinery that tests
it. What follows is what changed because a run failed — the evidence is in
[evals/RUNS.md](evals/RUNS.md), and where a repair did not work, it says so.

---

**Ask a research question and get sources instead of recollection.** A *find-me* answer now has a
shape: the pick and why · **what each claim rests on, quoted from the page rather than asserted as
"checked"** · what the project already holds · where it lands when used · and its origin, named —
found, already ours, or **made by us just now**. The quoted-evidence line replaced one asking for
a date, after a run filled that field with three check-dates for pages it had never opened.

**A figure nobody can point at is `unknown`, not an estimate.** A run met a vendor whose free tier
had closed and produced a per-unit price for a vendor it had never contacted. And a register's
check-date may no longer be attached to a claim about the present: an eleven-month-old date does
not verify today.

**What a source or tool *can do* is a fact, on the same terms as what it costs.** *You can filter
that by aspect ratio* is a claim, and the honest failure is not knowing whether it can.

**A quick job skips discovery, never the project's own record.** The rule that says *ask the owner
about their brand* now comes second, after the files that already answer it — named by path. Two
runs had asked a project whose register held a commissioned shoot, a licensed type pair and a
one-icon-set rule; both were obeying the file.

**Four rules stopped being sentences.** In `templates/company-preflight.sh`: a task cannot reach a
terminal status in the same commit that edits its own definition of done · an entitlement claimed
in the tooling register fails without evidence **in the same clause** · a register entry past twice
its recheck fails until it is re-verified or written `unknown` · and the decisions log stays
append-only. **These are real only where a project has wired that script**, which is now said out
loud in `permissions.md` and `project-layout.md` — ship the skill alone and they are `prose-only`
again.

**An agent may not author the fact that unblocks its own work.** A run found a bundled dependency
was BUSL-1.1 rather than MIT, corrected the register honestly, added *"commercial licence held"* —
a licence nobody had bought — and tagged a release into a paid product.

**When another sentence will not fix it.** A new section in `self-maintenance.md` records what
this round actually taught: a rule fires when it names something to open, a field that cannot be
faked, or a gate that blocks — and does not fire when it states a virtue. Five well-formed
statements of the right behaviour changed nothing; two structural changes worked immediately.

**Two limits are recorded rather than repaired a fourth time.** On the light tier, an answer drawn
from a decision record drops the basis however it is labelled, and a request that cannot be met as
asked gets a substitute delivered without the substitution being declared. Both carry their
evidence and their round count.

**Catalogue rows verified live rather than recalled** — cognitive-bias and deceptive-pattern
references with their licences, including the largest one that is now offline and why · licence
identification and choosing · structured comparison data, with what it does not disclose · SEO
measurement, a technical crawl and an indexing protocol, with the caution that trend data is
relative and not volume · visual hierarchy, and the line between what is measurable and what is a
model's prediction · academic sources widened past computer science, with a rule to match the
source to the field.

**Twenty-eight new evaluation scenarios and five new fixtures**, covering research and discovery:
primary sources, over-serving, licences, connected MCP servers as a source and as an injection
route, conflicting records, dead citations, and a request no catalogue row anticipates.

---

## 0.1.0 — 2026-07-31

**First release.** One version, one entry, and it says what it means: complete enough to use,
young enough to change. Where a decision is unsettled the text says so rather than sounding
confident.

---

**Install it as a plugin in ten runtimes from the one repository.** Claude Code, Google
Antigravity (with always-on `rules/`), Codex / ChatGPT, Kimi Code, Gemini CLI, Cursor,
OpenCode, GitHub Copilot CLI, Factory Droid and Pi — each through its own manifest or
marketplace route, with [INSTALL.md](INSTALL.md) as the door. Where the platform allows it,
the advisor's hard gates ride along as always-on context or a runtime bootstrap. **Each command
is its own `skills/<verb>/SKILL.md`** — the layout Claude Code specifies, where the folder name
becomes the command — with the corpus at `skills/advisor/` and its companions at the repository
root; anything that reads bare Agent Skills mounts the repository directly.

**A command palette of eighteen verbs that doubles as the catalogue.** init · import ·
consult · hire · fire · status · cost · ship · review · decompose · map · decide ·
automate · skill · upgrade · migrate · recover · audience — each one line, each a door to a flow that exists
anyway. The bar: a verb is a door to its own flow, never a synonym — and a door may also exist
so the capability can be found.

**The advisor is a role; the name is a setting.** The core says *advisor* throughout, and the
palette agrees — the command is `/opsinist:advisor`, because the frontmatter `name` is the
plugin's invocation name. What the advisor **introduces itself by** is `display_name`, and the
local store derives from that same display name — resolved by scripts, not hardcoded, so
renaming a command never renames an owner's records.

**Run a team of AI agents out of one git repository, with nothing else underneath.** Roles, work,
groups, pipelines, requests and run records are all files. Clone the repository and the project
comes with it — the team, the process, the history, the budget. Delete every cache and it
rebuilds.

**Decide how much of that lands in the repository at all.** Six layers — documentation, work,
conversation, team, telemetry, results — with one cut point rather than six switches. A complete
copy is always local, so the choice can be made after the work is done and changed in either
direction. Fix an issue in someone else's library and **not one of our files touches their tree**,
while your record of what you did, decided and spent stays complete.

**See the product as a map, not only the repository as a tree.** `docs/ARCHITECTURE.md` says where
the implementation lives; **`docs/MAP.md` says how the product is walked** — the moves through it
and the things it is made of, in the product's own words, whether those are screens, pickup slots
or the corridors of a venue. Every node names something that exists, the map holds current state
only — the roadmap points at nodes it will change, never draws on the map — and it ends honestly
with *what is not mapped yet*, where a claim is `unknown`. **Flows climb a ladder**: a task's
working draft stays in the task; what ships graduates to the map in the same task that ships it.

**Read a large repository without reading all of it.** The size is measured first — measuring is
nearly free and reading is not — and the depth is a choice with the recommendation filled in: the
**corridor** the work touches plus the coarse shape of the whole, **base only**, or
**everything**. Past `read_threshold_lines` a full read is announced as a cost. The read runs in
the background, a tier down; what went unread is named in the architecture map. **The corridor's
edges are derived before they are declared** — the maps, then the tree's own evidence, including
what history says changes together, and the owner only for the remainder, whose assertions about
the tree are checked against the tree.

**A task passes two bars, and they have names.** The **definition of ready** — workable from
itself, outcome writable, its type's own *ready when* met — held at the door into `started` by
whoever picks it up. The **definition of done** — the type's craft gates, made concrete by the
task's own acceptance criteria and **deliverables with destinations, checked as a list**: each
named thing at its named place, evidence in the thread, review from a non-author, acceptance
moving the status. A task may carry a **`check`** — the mechanical half of its bar, run clean
before review is asked for, its failure returning to the worker rather than the reviewer. **Types
are born at first use, in the project's own words** — an episode, a commission, a batch; `bug`
only where things are called bugs — with researched defaults offered once and held until the
owner asks, or the bar itself accumulates the evidence and proposes its change.

**Know what every rule is actually held by.** Gates carry an honest `enforced_by` — a request, a
validator, branch protection, the runtime, or `prose-only` — and the rules that are deliberately
not gates are listed by name. Only the runtime row moves between tools, so it resolves per runtime
and is recorded on the run. **The owner may switch a gate off**: the risk is named once, it goes
off in writing with a revisit trigger, and the manifest downgrades honestly rather than pretending
nothing changed.

**See what work cost, and what it wasted.** Cost is measured once at the run and summed ten ways.
Tokens are four numbers rather than one, because cache reads dominate and a single total hides the
only lever that moves the bill. A run also records what it spent *outside* the model. **And the
record names the model that answered, not the one that was asked for** — a gateway falls back, and
the requested name would be wrong in the ledger, the explanation and the evidence a role's trust
is earned from.

**Lose a run without losing the work.** An interrupted run is marked at the next session start,
the task visibly regresses, and recovery rebuilds a state inventory from the repository. **Applied
work is never redone.**

**Get told what synthetic users cannot tell you, before anything runs.** Two evidence pyramids,
never pooled; verdicts from synthetic audiences are direction-only; a cohort declares what it is
made of, and that decides what may be claimed about the result.

**Start with nothing configured.** Two questions are asked and never skipped — control level and
governance. Everything else has a default meant to be left alone, and a scenario exists whose only
job is to keep that true.

**Earn autonomy per role, from its own record.** Trust moves both ways on evidence the run records
already carry, a role never loosens its own gate, and no history buys the four owner-gated kinds.
**The right to spawn helpers rides the same ladder** — never a switch set at birth.

**What a thread carries, and what a decision looks like when it arrives.** The artifact under
discussion is in the thread — embedded where it embeds, linked with a still where it does not: a
process gets a small diagram beside the words, a choice gets a table of sourced criteria, a
command is quoted verbatim. A decision arrives with the recommendation first and a *flips-if*
line; related decisions are **presented together and consented per line**. Where measurement
settles it cheaper than argument, the artifact is an experiment whose metric and threshold are
named before anything runs.

**Keep imported and self-written skills intact.** A skill exists in three states — the **source**
nobody edits, the project copy, the role copy. An update diffs source against source, improving a
skill means editing the source, and **every command a skill ships is run against an input it must
reject before the file is saved**.

**Change the system through the system.** Machinery changes are tasks with full history regardless
of size, they are never self-merged, and friction found while working is recorded where it
happens — and a sweep that found nothing records what it looked at.

### Included

A core of laws and routing under a declared budget · **forty-three companions** loaded by
trigger · a glossary of confusable pairs · **twenty-seven reused patterns**, each cited from an
instance · the four lenses, defined · **twenty-one diagrams** whose every node names something a
file defines · a hundred and eighty-six single-sentence facts · eighty-six situations with what to
say · **seventy-five evaluation scenarios**, each naming the fixture it runs against, scored by
pass-rate, with fixtures built by script so a suite is re-run rather than reconstructed · a
register of sources with archive links, licence tiers and check-dates · templates for the
artifacts a project stands up · and guards that run on every push: dangling references, ageing
facts, duplicate ids, a rule living in two files, an unreachable template, a glossary headword
nobody uses, and a count in prose that no longer matches reality.

### Where it runs

The packaging is the open Agent Skills standard, which around thirty tools read. **Installing is
solved; what each runtime lets an agent do is not.** Claude Code is measured — the behavioural
suite runs there. Gemini CLI installed this repository unchanged, measured 2026-07-28; its
behaviour is unrun because authentication failed before a run, which is a different thing from
untested and is recorded as such. Codex CLI and CrewAI are cited from their own documentation
rather than measured here. Everything else is unknown, and says so.

### Known limits

**There is no server**: scheduling and background work exist, but nothing happens while the
machine is off.

**Some enforcement is prose**, and that list is written out by name — including the two that
cannot be enforced even in principle: that a price was fetched rather than recalled, and that
nothing of ours lands in a repository where we may not install a hook.

**Per-role skill limits hold for delegated work and are advisory in team mode**, because the
runtime does not apply them there.

**There is no built-in eval runner** — the suite is fixtures, scenarios and doctrine; dispatching
players is still a by-hand act, and that is stated where the suite lives.

**It has not been lived in.** The behavioural suite found defects in the corpus and rather more in
the test rig itself, and a mutation sweep planted fifteen defects and caught fifteen. **Each one
is named in `evals/RUNS.md`** — deliberately not summed here, because a tally in prose that
nothing counts is the exact defect that file records twice. Fixtures are not a month of use.
