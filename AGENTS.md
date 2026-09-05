# Working on this repository

You have landed in the skill's own repository. **Start at [SKILL.md](skills/advisor/SKILL.md)** — this file is
about changing *this*, not about using it.

**This repository is a project like any other, and its machinery is this skill.** So everything in
`self-maintenance.md` applies here unchanged: a change to the machinery is a task, it carries full
history however small, and **it is never self-merged**.

---

## Before changing anything

**Read [GLOSSARY.md](GLOSSARY.md) and [PATTERNS.md](PATTERNS.md).** Most defects this repository
has shipped were a word used in a second meaning, or a pattern paraphrased instead of cited.

**A rule has one home.** If you find yourself writing something that already exists elsewhere,
link instead. **A rule in two files goes stale in one of them**, and you will not be the one who
notices.

**Cite a pattern rather than restating its reasoning.** That is the whole reason the catalogue
exists.

**An anchor must be a heading.** A reference to a bold line or a table row is invisible to tooling
and dies silently the first time the section is reorganised — the link checker cannot see it, and
neither will you.

---

## What the automation checks — and what it cannot

**The scripts verify shape and existence.** They are blind to whether a paragraph is still
*correct*, and **every expensive defect this repository has shipped was of exactly that kind: a
statement that parsed perfectly, linked correctly, and was false.**

So before you commit, read for these six, as a human or as an agent asked to review — but never
assume a green check covered them:

**1 · Does this contradict another file?** Rules live in several places on purpose and drift apart
silently. **If you change a rule, grep for it everywhere and fix every copy in the same commit.**

**2 · Is the framing still current?** Text ages by being outrun, not by breaking. **When you add a
capability, ask which page now describes an older product.** The introduction is the usual victim.

**3 · Does a claim about the outside world still hold?** The checkers verify that a link resolves.
They cannot verify that a tool still *means* what we say it means. **If a sentence explains what a
tool does, run the tool.**

**4 · Are the numbers still measured?** Any figure about ourselves rots. **If you quote a size, a
count or a share, re-measure it.**

**5 · Does the example still match the rule?** Change the standard and the demonstration quietly
becomes the counter-example.

**6 · Is it reachable?** **A capability that no entrance, use case or index points at does not
exist for whoever needs it.** The door ships in the same commit, or the commit says why not.

---

## Before building anything: does the runtime already do it?

**Native-first: ask whether the runtime already has it before designing anything, and record
the answer with the date** → [tooling.md](tooling.md). A minute of asking costs nothing; missing
it costs a home-grown mechanism that drifts from the runtime and confuses anyone reading both.

**This repository has been in danger of exactly that**, having been rebuilt onto a runtime that
turned out to already provide isolation, tool restriction, turn caps, inter-agent messaging and
scheduling. Several designs were deleted rather than shipped because of that check.

**And when the platform genuinely does not do it, say so explicitly and note the version checked**,
so a later reader knows the wheel was deliberate.

---

## When a flow deserves a command

Add one when **all three** hold: it is invoked as an action in its own right · it has a name in the
owner's own language · **plain language alone reaches it unreliably** — **or** when the palette
would otherwise hide the capability: a verb may exist so the possibility can be found, because
**the palette doubles as the catalogue**.

Either way, only an owner's action qualifies. The corpus has four natures, and one of them takes
a command:

| Nature | Takes a command? |
|---|---|
| an owner's action — *"do X"* | **yes** — this is the palette |
| a law, or the advisor's internal procedure | no — it fires inside other flows; nobody "runs drift" |
| reference — read, not executed | no |
| a flow reachable through a larger door | no — a synonym is a worse door than the sentence |

Not for a one-off step, an internal stage, or a synonym — synonyms live in recognition, not in
files that must then be kept in sync.

**A command is a door to a flow, never the flow itself.**

---

## The checks

```sh
python3 scripts/check-links.py       # file → section, not just file exists
python3 scripts/check-freshness.py   # check-dates, and rows that have none
python3 scripts/check-structure.py   # shape and budget
bash scripts/test-audit-gate.sh      # the shipped hooks, by mutation
```

**`hooks/` is machinery, not prose, and it is tested like machinery.** The plugin ships two
gates that hold a takeover to its order — refusing a mutating call before the debt list exists,
and stopping a run that presented deferrable findings and wrote no `LATER.md`. **Every rule in
them is shown refusing the mutant and passing its honest twin**; a rule added without both halves
is a rule nobody has seen work. They fail open by construction: a broken gate must never brick a
session.

**`check-links` FAILs are not advisory.** They mean a reference points at something that is not
there, which is how a rule silently stops being reachable.

**`check-freshness` warns on age and fails past the threshold.** A fact past its recheck is
**unknown, not fine**.

**A checker that cries wolf gets bypassed**, and then none of it is enforced. If one produces noise,
fix the checker rather than learning to ignore it.

---

## The release ritual

**The tag is cut on the developer's word, never on momentum.** Prepare everything — the
entry, the sweep, the checks — then stop: the tag, the Release, the site and the install
re-sync follow an explicit yes for **this** version. `shipping.md`'s outward law, applied
to this repository itself.

**Before the tag: the manifest sweep.** Seven files carry the version and one bump has already
missed three of them — `scripts/preflight.sh` now compares them against the SKILL.md line and
fails on a straggler, and the ritual's own step is simply: run it, read it, then tag. The
notes of the release are the changelog entry whole (`shipping.md`) — **with the entry's own
heading collapsed to the bare date**, because the release title already carries the version
and the name, and a heading repeated under itself is the first thing every reader scrolls
past.

**Green checks are evidence about the corpus, and evidence of nothing about behaviour.** In the
first full behavioural pass, **every defect found had already passed** preflight, check-links,
check-freshness and check-structure: a law written perfectly and executed never, a rule stated in
five files with a procedure in none, and a guarantee of unique ids with no generator behind it.
Read that line before treating a green run as a reason to skip what follows.

**Does this change need a scenario?** One test, and it is answerable: **would any existing
scenario fail if this change were reverted?** If nothing would notice, the change has no
regression test and needs one. Wording that alters no behaviour needs none — say so rather than
adding a scenario per commit.

**Run them, and record the pass-rate.** Scored as a rate, not pass-or-fail: **the regression in the
rate is the signal**, and a suite that goes red for no reason is a suite nobody trusts. The shape
of a run — fixture, player, assertion, judge — is a form in
[evals/README.md](evals/README.md), because *"run the evals"* is the instruction that gets
performed as reading them.

**Run the four lenses** — deletion, adversarial, contradiction, cold-read — **by someone who did
not write the change**, and **state each one even when it found nothing**. A silent lens is
indistinguishable from a skipped one → [lenses.md](lenses.md).

**Keep the guards current** → [shipping.md](shipping.md).

**Every capability has a door**, and **the published pages are one of the doors.** A release
that changes what a page says and does not regenerate the site ships a documentation set that
describes the previous version — silently, because nothing about the repository looks wrong.
Regenerate, rebuild, and check the pages that carry generated shapes: the diagrams still match
their files, the glossary still resolves, the help a command gives still names something that
exists.

**A correction to a frozen entry re-publishes its release.** Release notes are a snapshot taken
once, so a marked correction reaches the changelog and the site and never the page most people
read: the file admits an error the release goes on repeating. `scripts/check-releases.sh` compares
every published release against its entry and prints the one command each gap needs. It is a
report, not a gate — it needs the network and `gh`, and preflight runs offline.

**The checks are green**, and the check-dates are not past their threshold.

**The showcase trio answers for every new mechanic — by name, before the tag.** A capability
that landed in the corpus asks three questions nothing automates: does **a diagram** show it
where its prose lives (`diagrams.md`, or beside the prose when the budget is full) · does **a
situation** say what an owner would say to reach it (`use-cases.md`) · does **a fact** state it
in one true sentence (`facts.md`)? The counters are guarded — `check-structure` fails a showcase
number that drifts — but **whether the trio exists at all is judgement, so it is a named step,
not a hope**. Wording-only changes owe nothing; say so.

**The developer machine is re-synced after the release, every install by its own route.**
`scripts/find-installs.sh` names each installation and its update route — run it, follow the
routes, run it again and read every row at the new version. The 0.1.12 night is why this is a
step: four bumped manifests hid three missed ones until a runtime reinstalled the old version
from its own file.

**The changelog leads with the capability, not the archaeology** — what someone can now do and why
it helps — **and says what kind of change it is, because it is the migration map**.

**A change that alters the format ships with its migration and a line about its risks.** Not
"here is what changed" but *here is what to run, what it touches, and what could go wrong*.

**Batch, don't drip** → [shipping.md](shipping.md).

---

## The one thing to remember

**Form beats prose, and that was measured rather than argued.** Prose the mid tier ignored started
working once it was re-formed into structure.

So when a rule does not hold, **the repair is a form** — a list, a required field, a gate — and not
a stronger sentence.
