# Skills — the toolkit's lifecycle

**Load when:** a routine keeps repeating, someone found a skill worth using, a brief has grown
heavy, or something proved itself and should leave home.

**A toolkit is an asset that rots without an owner.** Four operations, each with a gate.

**The pool is separate from attachment.** `_ops/skills/` holds everything the project has; **a skill
may sit unattached — available, searchable, ready — and that is a normal state, not an untidy
one.** Skills created during work land in the pool first and are attached when a role actually
needs them. **Attachment lives on the role, never on the skill**: one skill serves many roles, and
a role's list is part of its identity.

### Three copies, and only one of them is edited by nobody

**A skill exists in three states, and calling them all "the skill" is how an update goes blind.**

| | Who edits it | What it is for |
|---|---|---|
| **the source** | **nobody** — it is fetched, or it is authored | the basis every later diff is taken against |
| **the project copy** | trimmed of what this project cannot use | what sits in the pool and serves many roles |
| **the role copy** | fitted to one role's work | what actually loads on a run |

**The source of an imported skill is what came down, unedited.** **The source of one we wrote is
the thing we wrote.** Same slot, two origins, and the rule is identical: it is never the copy that
gets trimmed, fitted, or repaired in place.

**An update diffs source against source.** Comparing the new upstream against a copy we already
trimmed shows *our own* cuts as changes, and the one real change hides among them → [`security.md`](security.md).
After the diff lands, trimming and fitting run again from scratch — cheap, because both are
selection rather than writing.

**Improving a skill means editing the source.** A worker that fixes the copy it was handed loses
the fix at the next fitting, silently, and the loss looks like the fix never worked. **This is the
path the machinery uses on itself**, which is why it is stated rather than assumed.

---

## Create — a routine repeated twice

**Evidence first: name the two occasions** ([`PATTERNS.md`](PATTERNS.md) §22). *"We might
need it"* is neither. Same bar that governs adding a guard and raising a tooling need to a task —
one threshold, three uses.

**Born modular.** A budgeted core that is mostly a router, plus chapters loaded on their
trigger. **Modularity is cheap at birth and expensive at five hundred lines.**

- **Set the line budget at creation and write it in the frontmatter.** Roughly 100 lines for a
  tool skill, 200 for a role skill, 500 only for a full methodology. **The budget is a cost
  decision**: the core is paid by every run of every role that carries it.
- The core holds **when to act**, the **rules that govern every use**, and a **routing table**.
  Procedures, examples and reference tables live in chapters, never in the core.
- **Chapters are named for their trigger** — *"when X happens, read Y"* — not for their topic.
- **A rule has one home; the other file points.**
- **Full at birth is a design smell.** If the first draft hits the budget, it wants splitting.

**Test before you trust it.** Hand it to a fresh worker that has never seen the routine and check
it reaches the outcome. **A skill nobody tested is a hypothesis** — and the hypothesis is recorded
rather than believed: `SKILL-SCAFFOLD.md` → *Tested against* is a required section carrying the
input, the refusal it printed, and the date. **This sentence alone measured 0 of 5** (`N61`,
counted from transcripts, three rounds), with one run declaring itself tested by reading a manual,
which is why there is now a field instead of a firmer sentence.

**Every command it contains is run before the file is saved — against an input it must reject.**
**The form behind this is narrower than the sentence**, and the gap is stated rather than hidden:
§18 fires on a line that *looks like* a command — indented or prompted, a runner or a path — so a
command named mid-paragraph is the author's to test and nobody's to catch.
Not a passing case: **a checker that reads nothing and a checker that finds nothing wrong return
the identical silence**, so a clean run against good input proves only that nothing crashed. Give
it the defect and watch it refuse; that is the smallest test that can distinguish working from
inert.

```mermaid
flowchart TD
  S["a skill with commands"] --> Q{"was a command run<br/>against an input it<br/>must REJECT?"}
  Q -->|"yes"| F["**Tested against**<br/>input · what it printed · date"]
  Q -->|"read the manual"| M(("not a test —<br/>you cannot paste<br/>output you never<br/>produced"))
  Q -->|"a passing case"| P(("proves nothing —<br/>read-nothing and<br/>found-nothing are<br/>the same silence"))
  S -.->|"runs nothing"| N["`none:` — the whole<br/>answer for a door"]
  F --> G["§18 lets the commit through"]
  M --> G2["§18 refuses"]
  P --> G2
  N --> G
```

**Reading a command does not find what running it finds.** Measured here twice, both on commands
read carefully and never once executed: a pattern that matched one ordinary markdown spelling of a
key and not its equally ordinary twin — it reported finding nothing while a fabricated project sat
in the store — and a hand-written number table that let a wrong count through in words it happened
not to contain. **Both looked correct on the page.** Both were caught the first time something was
handed to them that they were supposed to stop.

**When the budget is hit later: move, don't squeeze.** The newest rarely-needed block becomes a
chapter and the core keeps one pointer line. Compression is the second resort, deletion the
third, and **raising the budget is a decision with a stated cost, never a reflex**.

---

## Import — untrusted code *and* untrusted instructions

Screening, the prose diff, and who decides what a finding means: → [`security.md`](security.md). Three things
specific to skills:

**Trim after screening — and trim the copy, never the source.** Imported skills carry generic
scaffolding, alternative platforms and examples for tools this project does not have. What is
irrelevant here is dropped before it is attached, and **what came down stays untouched** so the
next upstream release can be diffed against it.

**The gain is precision before it is economy.** The prefix is cached, so the tokens saved are
cheap ones — but every paragraph describing a platform we do not use is **an instruction competing
with the ones that apply**, and the rule an agent actually needed is the one that drowned.

**Attach with provenance** — source, version or commit, date screened, who approved.

**A skill's own description says when to reach for it AND when not to.** *Use when… · Do not use
for…* — both halves, in the description a runtime reads to decide whether to load it, because the
half everybody writes is the first and the half that prevents a wrong load is the second. A skill
that only says what it is for gets pulled into every adjacent question and then argues badly from
the wrong file. **And every reference file a skill ships is linked from its own body**: an unlinked
`references/` folder is weight the skill carries and nothing reaches. (Both are admission rules in
`tech-leads-club/agent-skills`'s validator, read 2026-09-17 — which also refuses a `README.md`
inside a skill, on the grounds that skills are for agents and a human-facing file in there is a
second description that will disagree with the first.)

**A skill whose profile still carries an unfilled placeholder stops, rather than producing
something generic.** An imported skill usually expects a project profile — the house style, the
jurisdiction, the brand, the stack — and the failure is silent: with `{{…}}` still in it, the skill
does not error, it produces the average of its training and everyone reads the output as *ours*.
**Refusing is the cheaper failure**, and it is the same law a task file lives under: an unfilled
field is a hole somebody can see, and the guard's §23 refuses one rather than guessing. (Measured in
`anthropics/claude-for-legal` 2026-09-17, where every practice skill hard-stops while its profile
contains `[PLACEHOLDER]`.)

**Check the pool first.** Before searching outside, look at what the project already has: a pool
skill is **already screened, already carries provenance, and is already paid for**. An outside one
costs the full gate again. The order is about gates, not convenience.

---

## Where a skill comes from, and what the project records

**Three origins, and the project records all three the same way — by resolving.** A skill named on
a role and present in no file is not attached to anything.

| Origin | Where it lives | What the role's row points at |
|---|---|---|
| **authored here** | `_ops/skills/<name>/SKILL.md` — the pool | a **link** to that file |
| **imported** | the same pool, with the untouched source beside it and its provenance | a **link** to that file |
| **provided by the runtime** — a marketplace or plugin skill installed on the machine | nothing in this repository | a row in `_ops/TOOLING.md`: which runtime provides it, and why this project needs it |

**The third is the one that goes wrong, because it works.** Measured on a live project 2026-09-16:
three roles named five skills between them — `frontend-design`, `modern-web-guidance`,
`vercel-react-best-practices` and two more — while `_ops/skills/` did not exist and `.claude/` was
empty. Every one of them was installed in the *owner's* runtime, so the work ran fine on that
machine and the repository recorded nothing about it. **A skill that is absent does not fail — it
loads nothing**, silently, so the same clone elsewhere produces worse work with no error anywhere.
That is the same failure [`tooling.md`](tooling.md) names for an MCP server or a system package, and it takes the
same answer: **what the project needs from the machine is declared.** The guard's §26 refuses a role
whose commit attaches a name that resolves to neither the pool nor a register row.

**The pool is the source; the runtime directory is the copy that gets read.** `_ops/skills/<name>/`
is where a skill lives as this project's own — screened, trimmed, provenance attached — and
`.claude/skills/<name>/SKILL.md` is where the runtime looks for it. **Both are committed**, so a
clone gets the skill and the wiring together, and the guard's §26 refuses a role that attaches a
pool skill the runtime directory does not carry: a role told it has a skill nothing loads is a role
doing the work without it, silently and slightly worse. A project whose runtime is not Claude Code
declares its own directory once — the `runtime_wiring` setting in `_ops/config.md` — and this and
the roles half of the rule ([`hiring.md`](hiring.md)) stand down together.

**Linking is what puts the edge in the graph.** A role's `Skills attached` row naming
`` `house-style` `` in backticks is an edge only a reader infers; written as
`[house-style](../skills/house-style/SKILL.md)` it is an edge Obsidian draws, the link checker
validates, and `/team` can follow — so a role, its skills and the tasks citing them sit in one
connected neighbourhood instead of three islands of identical strings → [`facts.md`](facts.md) 265. A runtime
skill has no file to point at, so its row points at the register, which is a file: the edge still
exists, and it lands where the *why* is written.

---

## Optimize — selection, never rewriting

**Fitting a skill to a role means dropping sections that do not apply. It never means rewording.**

Dropping is safe and reversible. **Rewording is not: a reworded rule stops being followed** — and
that is measured on this corpus's own regression gate rather than assumed. The same measurement
found the deeper law: **prose the mid tier ignored started working once it was re-formed into
structure**, which is why the repair for a rule that does not hold is a **form**, not a stronger
sentence.

**Compression preserves commands, paths, numbers and security rules verbatim**, and is reviewed by
someone other than whoever compressed it.

**Fail open — and say so.** If fitting fails, the role gets **the original**, never a truncation.
But a silent fallback is its own failure: **it must announce that it fell back**, or nobody learns
the fitting is broken.

**"Cannot compress this safely" is a valid answer.**

**Repairing over-compression: restore, don't rewrite.** You cannot recover prose from its own
compressed output, and asking a model to expand it back **invents plausible text that was never
there**. **Restore from the source** — the copy nobody edits — and run the pass again under the
readability rules. There is no separate backup and none is needed, precisely because compression
is selection and the source was never the thing being compressed.

---

## Release — a skill that proved itself leaves home

**Evidence, not enthusiasm:** it earned its keep across **at least two projects**, and **someone
outside its origin used it successfully**.

**Extract and de-identify** — project names, internal paths, ticket keys, conventions that only
make sense here, and above all **anything secret**. *This is where leaks happen*: a human reads the
diff before anything goes anywhere.

**Its own repository, the owner's, private by default.** Publishing is outward — owner-confirmed,
always, and named account stated as it is created.

**A project-local skill shadows a stock skill of the same name, and an upgrade never overwrites
it.** Local wins — it was screened, adapted and paid for by this project — and the collision
surfaces at upgrade rather than resolving silently: the upgrade names the shadowed skill, says
what the stock version would have added, and the owner chooses keep, merge or rename. **Checked
2026-08-05: nothing held this** — an upgrade shipping a same-named stock skill would have
clobbered the local copy unremarked, because [`upgrading.md`](upgrading.md) protects the owner's conventions
and nothing protected their files.

**Re-import it as an external skill so there is exactly one source of truth.** The in-project copy
is **deleted, not left to drift**. From then on it upgrades like any third-party skill, and other
projects import the same URL.

**The same path exists for tooling** — a script or a helper that proved itself across projects
leaves the same way, with one addition: **the licence question**, which a text skill does not
have.

---

## Versions are a release act, not an edit act

**A skill living inside a project carries no version number** — it carries a date and a line in
the decisions log saying what changed and why.

**Numbers appear only when a skill leaves for its own repository**, because that is the only
moment a version answers a real question: **which of the copies out there is this one?**

Without this rule, agents bump a patch on every wording tweak, producing a changelog that records
typing rather than change, and an upgrade that fires for nothing.

Once released: **patch** for a fix that alters no instruction · **minor** for a new capability ·
**major** when existing projects must do something differently — and **the changelog entry says
which, because it is the migration map**.

---

## What the pool costs

Every attached skill loads on **every run that role makes**. The budget, the share of the window,
and why crossing the line is a hiring signal rather than a pruning task: → [`hiring.md`](hiring.md).

**Declared against used is measured, not guessed.** Every run records both, so *"this skill has
been attached to five roles for two months and fired once"* is **evidence**. What it is evidence
*for* is a proposal, not a verdict: a skill can be rarely used and still right.

**Replacing one is a behaviour change, so it is verified like one.** Find the candidate — pool,
then curated sources, then a broader search. Change **one variable at a time**, or the result
cannot be attributed. Compare **before and after on the same kind of work, by pass-rate**, since
running the same task twice cleanly is not available. And **the proposal reaches the owner as a
request**, not a line in a report — a report lives until the end of the scroll.

*Note the tension with batching: guide and instruction edits are batched to protect the cached
prefix, but a trial swap is one variable at a time. Different concerns, both true.*
