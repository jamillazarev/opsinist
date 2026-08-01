<p align="center">
  <img src="assets/opsinist-docs.png" alt="Opsinist" width="240">
</p>

<h1 align="center">opsinist</h1>

<p align="center">
  An operations department for AI coding agents, in files.<br>
  Roles, work, cost, evidence and escalation — out of <b>one git repository</b>, and nothing else.
</p>

<p align="center">
  <a href="https://ai.jamillazarev.com/skills/opsinist"><img alt="docs" src="https://img.shields.io/badge/docs-ai.jamillazarev.com-black"></a>
  <a href="https://github.com/jamillazarev/opsinist/releases/latest"><img alt="release" src="https://img.shields.io/github/v/release/jamillazarev/opsinist?label=release&amp;color=black"></a>
  <a href="LICENSE"><img alt="license" src="https://img.shields.io/github/license/jamillazarev/opsinist?label=license&amp;color=black"></a>
</p>

---

Most tools for running agent teams ask you to trust a dashboard.

**This one is an entire operations department in forty-five markdown files — and every part of it
is something you can read, diff and delete, including the parts it admits it cannot enforce.**

Roles, work, pipelines, releases, threads, budgets, evidence, escalation, migrations, and a
supply chain for the agents' own skills. Not a task list with AI bolted on: the machinery a
company runs on, expressed as files, in a repository you already own.

---

## What it actually does differently

**Clone the repo and the whole project comes with it.** The team, the process, the history, the
budget. No platform, no database, no account. Delete every cache and it rebuilds. There is no
export feature because there is nothing to export *from* — `project = f(repo)` is the premise
everything else follows from.

**The gates tell you what actually enforces them.** Every rule that matters carries an honest
`enforced_by`: a request a human must answer, a validator that refuses, branch protection, the
runtime — **or `prose-only`, which means nothing enforces it**. There is a list, by name, of the
rules that are deliberately not gates. It is the one feature here written against its author's
interest, and it exists because *a gate believed in but not enforced is worse than a stated rule.*

**Cost per task, per role, per release — as four numbers, not one.** Cache reads are the
overwhelming majority of tokens, so a single total hides the only lever that moves the bill. And
five of the ten slices answer a question a receipt never does: **what was spent on work that
produced nothing** — failed runs, second attempts, an expensive setting that bought nothing, a
skill loaded into every brief and never used.

**A run that dies resumes instead of restarting.** It comes back with a state inventory —
committed, applied, remains — read from the repository rather than from a session that no longer
exists. **Applied work is never redone.** Hitting a limit stops being a lost afternoon.

**Nothing moves by itself.** A closed blocker does not start the work. Children finishing does not
close the parent. Everything surfaces as *ready* and waits. **The board cannot lie to you, because
nothing moves it except a person or whoever did the work.**

**Every claim carries how it is known** — measured, cited, recalled, or a judgement call — and the
rung travels with the claim, so one agent cannot promote another's guess into a fact by quoting
it. Ask for a percentage from synthetic users and you are told, *before* anything runs, that **a
hundred synthetic respondents are one bias repeated a hundred times**.

**It knows when the repository isn't yours.** Drop into someone else's library, fix one issue,
leave — and **not one of our files touches their tree**, not even an ignored one. Your record of
what you did, decided and spent is still complete; it just lives with you. You choose how much of
the machinery lands in a repository at all, as **one position on a ladder** rather than a page of
switches, and **a complete copy is always local — so you can decide after the work is done**, and
change your mind in either direction.

**Autonomy is earned per role, and it can go down.** A role with eleven runs and no rework and a
role hired yesterday are different risks, so trust moves on evidence the run records already carry
— second attempts, reviews returning the same objection, whether you edited what was proposed
before approving. **A role never loosens its own gate**: the proposal comes to you with the
evidence attached. And **no history buys the four gated kinds** — a role with a perfect year still
asks before it spends, because that risk was never about who was asking.

**Nobody waits while something runs, and nothing burns a top-tier model on a grep.** Work that
would take minutes leaves the turn — **an agent asked something long says it is going to look and
comes back with the answer**, rather than leaving a question sitting while a reply that looks like
typing is twenty minutes of reading. And a helper is chosen at the tier its own work needs:
search, extraction and verification go down a tier or further, because **"same as me" is the most
expensive default there is** and it hides in the bill as ordinary work. Every helper that ran is
named in the record with its tier, so an answer produced by three of them is never reported as one
agent's.

**You do not configure a team on day one.** A project starts with an advisor and nothing else, and
a role is created the moment a task needs a craft nobody has — with the reason recorded at that
moment. An unused role is not free: it sits in the roster, in search results, and in every "who
should do this" decision. **A team assembled before the work is a guess about the work.**

**It works outside software.** *Ship* is the go-live moment whatever you make — an episode
published, a production batch sent, a finding published, an issue mailed — and *urgent* means
something different in each, defined per medium. The vocabulary follows yours, because **a chip
maker has no data flows and a bakery has no deploys**.

**It maintains itself through its own machinery.** A change to the system goes through the same
tasks, gates and history as the work — **proposed, never self-merged**, because an author who
moves the bar they are measured against is the exact failure this warns projects about, and being
that system does not exempt it.

---

## What is actually in here

The list is long, so here it is grouped — **each line carries the decision that makes it not the
generic version**, because the names alone would tell you nothing.

**Work.** Tasks with an id that survives every rename, because links point at the id and never at
the name · **six status categories, and you name the stages inside them** — `blocked` is not one
of them, a blocked task is *started* with a blocker · pipelines as stage ladders with gates on the
transitions · **waves**, which are barriers between sibling children and a different thing from
stages · relations as typed pairs with one side stored and the other generated · priority that is
opt-in, where **dates beat priority and priority is not the order** · triage, where raw intake
lands with four dispositions and stays off the board until someone decides · decomposition where
**a parent spanning three crafts belongs to nobody** and is left unassigned.

**The team.** Roles as files that *are* the runtime's own worker definition, so the cascade
resolves into real fields rather than a private mechanism · five types — advisor, worker, expert,
persona, **human, who may hold an assignment they took rather than were given** · grade as a
routing fact that **never enters the instructions as an identity**, because a model told it is
junior will act junior · groups with routing rules, so you **address the group and the rule picks
the person** · a load budget stated as a share of the window, since windows differ.

**Conversation.** A thread per task, direct conversations with a role, and distillation at
rotation so what mattered is lifted before the rest goes · **everything that needs a decision is a
request with an age**, not a line in a report — a report is where findings go to die.

**Running.** A run record with four token numbers, the resolved settings, and **what the run spent
outside the model** · resume that reads committed state, where **applied work is never redone** ·
tasks that need the live checkout declare themselves exclusive and take a lock · a turn cap on the
role, which the runtime enforces and a budget cannot.

**Cost.** Ten slices, and **five of them measure waste rather than spend** · two bills, named,
because the advisory conversation is not the work's ledger · a budget that **changes what gets
recommended in the first place** rather than only stopping you at the end · credits recorded with
their expiry, and the advice names the cliff.

**Shipping.** Releases that carry a version and get measured, against milestones that may ship
nothing · a launch checklist **researched per medium rather than recalled** — store rules, channel
rules, labelling for a physical batch · four lenses read by someone who did not write the change ·
and a release that ships a stale price or a dead link **ships a small lie**, which is a check, not
a sentiment.

**Tools and knowledge.** A tooling register where every entry carries **where the free tier ends,
in the unit that will actually bite you** · resources where `why` is mandatory, which is the whole
difference between a resource and a bookmark · a sources register with archive links, licence
tiers and check-dates · skills created **only on the second occasion**, screened and trimmed
before they attach, because an imported skill's text becomes something an agent believes ·
automations that dry-run first and whose failures are visible.

**A supply chain for the agents' own skills.** A routine repeated twice becomes a skill — **once
is a task, twice is a pattern, and "we might need it" is neither** · an imported one is screened
as **untrusted code *and* untrusted instructions**, because its text becomes part of what an agent
believes, then trimmed of the scaffolding that fits somebody else's platform · fitting one to a
role means **dropping sections, never rewording them**, and compression keeps commands, paths,
numbers and security rules verbatim · **if fitting fails the role gets the original, never a
truncation** · and a skill that earned its keep **across two projects** can be extracted,
de-identified and released on its own.

**Escalation that terminates.** A chain with **fast lanes that go straight to the owner** when
waiting is the wrong move · **bounded rather than endless** — three attempts at the same error is
a signal, not a reason to try harder · every escalation is a request with an age, and there is a
named procedure for the hardest one to say out loud: **the deadline will slip**.

**Moving in, moving on, moving up.** A migration is an ordinary task in the ordinary cycle, whose
first stage is **an assessment with a real deliverable** rather than a promise · **round trips are
not symmetric**, and the file that says so exists because pretending otherwise loses work ·
version upgrades run in **four layers**, and **skills are re-screened rather than assumed** ·
after a bad upgrade there is a way back that is written down before you need it.

**Knowing what your audience actually said.** Personas that are documents first and agents only
when asked · **bias profiles, two to four, each with its source** · a staging ladder from proto to
validated to twin · **mixed rounds that keep hypothesis beside fact instead of averaging them
into a number** · and four things people get wrong about live participants, listed so you get them
right the first time.

**Automations that cannot quietly take over.** They **create work and never move anyone else's** ·
they dry-run before they run · **their failures are visible rather than swallowed** · and a
webhook is treated as **all four gated kinds at once**, because holding the URL is enough to spend
your money under your project's name.

**An attention view that is computed, not a stream.** What needs you, with ages. What happened
while you were gone. What changed that you did not change. **Settings that notice their own
friction** and say when a dial you set months ago has stopped being a signal.

**The system improving itself.** A change to the machinery goes through the same tasks, gates and
history as the work — **proposed, never self-merged** · behavioural scenarios with **fixtures as
code**, so a suite is re-run rather than reconstructed · validators that run in CI on every push
and refuse the things prose cannot.

---

## It is not only for building software

**A designer who wants one assistant, not a team.** Hire one role, give it the craft and the
tools it drives — it drafts in the design file, writes the documentation that goes with it, and
comes back through a review that is not its own. **You never assemble an org chart to get one
helper**: a project starts with the advisor and hires when a task needs a craft nobody has.

**A product manager who wants a second opinion, not a headcount.** Ask a question and nothing is
created — no project, no roster, no files. The answer can come from the advisor alone, or it can
**pull in an expert that cites its sources**, or a cohort of personas that reacts. And it is
built not to flatter you: **no praise by default, disagreement when the evidence disagrees, and
an alternative rather than a shrug**. Agents run their own checkpoints against anchoring and
confirmation — *is the search phrased to confirm rather than to find?* — and **an argument
without a source is an opinion**, including theirs.

**Anyone whose work ships somewhere that is not an app store.** *Ship* is the go-live moment
whatever you make: a channel publishes the episode, a snack brand sends the production batch, a
research group publishes the finding, a newsletter sends the issue. **Urgent** means something
different in each, and it is written down for each. And the words follow yours — a chip maker has
no data flows, a bakery has no deploys.

**Somebody who just wants one thing done.** Three questions, one or two agents, build and review.
**Deliberately none of the machinery**, with the list of what a small job does *not* get written
down rather than left to judgement — because over-serving someone who asked for very little is
the failure that happens most.

---

## Install

Two ways in, same corpus. **As a plugin** — the nineteen-verb palette, and always-on rules
where the runtime honours them (Claude Code shown; Antigravity, Codex / ChatGPT, Kimi, Gemini CLI,
Cursor, OpenCode, Copilot CLI, Factory Droid and Pi each have their route → **[INSTALL.md](INSTALL.md)**):

```sh
claude plugin marketplace add jamillazarev/opsinist
claude plugin install opsinist@opsinist
```

**Inside a session `/plugin` opens the same thing as a menu**, and there the two lines above are
*two separate steps*: paste **only the source** — `jamillazarev/opsinist` — into its *Add
Marketplace* field, then install `opsinist@opsinist` from the list. Pasting both lines into that
one field is the error it hands back, and it is the reason the shell form is written first here.

**Or as a bare Agent Skill**, anywhere the open standard is read:

```sh
npx skills add jamillazarev/opsinist
```

That installer detects the agents you already have and configures each of them — the packaging
here is the open Agent Skills standard, not a Claude Code format. **Which of them can then run a
team is a separate question**: it installs beyond Claude Code and has only been *run* there.
Loading and being followed are different claims, and the parts that lean on the runtime —
dispatching a team, a tool allowlist that actually refuses, worktree isolation — differ per tool
→ [runtimes.md](runtimes.md).

Then say what you need. You never need a command — plain language, in any language, reaches every
flow. Commands exist as shortcuts once you know the names.

**There is no server, and what a schedule survives differs per runtime.** In Claude Code a
scheduled job lives in the session and dies with it; in hermes jobs persist to disk **and fire
only when the gateway service is installed and running**. Nothing at all happens while your
machine is off. Worth knowing before you plan around an overnight run
→ [automations.md](automations.md).

### Updating

**One command per route, and then check the version rather than the command's reply** — three of
these routes have each reported success for a version they had not moved to:

| Installed as | Update it with |
|---|---|
| **Claude Code plugin** | `claude plugin marketplace update opsinist` **then** `claude plugin update opsinist@opsinist` — the first line is the one people skip, and without it the second honestly reports nothing to update. Restart to apply |
| **Codex plugin** | `codex plugin marketplace upgrade` then `codex plugin add opsinist@opsinist` |
| **Gemini CLI extension** | `gemini extensions uninstall opsinist` then `gemini extensions install https://github.com/jamillazarev/opsinist` — **not `extensions update`**, which has both reported "already up to date" on an old version and sat silently on its consent prompt |
| **a copied skills directory** (`npx skills add`, Antigravity, the shared `~/.agents/skills` path) | re-run the installer, or re-copy the source — **nothing announces that a copy has drifted** |

**And to see every install you have, with its version and its route:**

```sh
bash scripts/find-installs.sh
```

It flags the two states nothing else reports — a symlink resolving to a directory that does not
exist, and a copy silently on an old version — and exits non-zero when either is present. It was
written after a machine remembered as having three installs turned out to have fourteen, nine of
them wired in and resolving to nothing.

### Where it runs

The packaging is the open [Agent Skills](https://agentskills.my/specification/) standard, so it
installs anywhere that reads one. **What it can then do depends on the runtime** — and the row
that matters most is delegation, because without it you have an advisor and a record rather than
a team.

**Around thirty tools read the same `SKILL.md` standard** — Claude Code, Codex CLI, Gemini CLI, Copilot,
Cursor, VS Code, JetBrains Junie, AWS Kiro, Block Goose and more — since Anthropic released the
format as an open standard in December 2025. **Installing is solved.** What differs is what each
one lets an agent do:

| | Installs | Delegation | Tool allowlist the runtime enforces | Worktree isolation | How we know |
|---|---|---|---|---|---|
| **Claude Code** | yes | yes | yes | yes | **measured** — the behavioural suite runs here |
| **Gemini CLI** | **yes, unchanged** | not confirmed | a policy engine exists | yes | surface **measured** `2026-07-28`; behaviour not yet run |
| **Codex CLI** | yes | reported | not checked | not checked | **cited** — from its documentation, not from a run here |
| the rest of the thirty | expect yes | ask | ask | ask | **unknown** |

**Moving a project between them takes no migration**: end the session properly — the tail
written, the work committed — and open the project somewhere else. Nothing load-bearing was in the
session, so there is nothing to freeze and nothing to export. What changes is which gates are
real, and that is said at the switch rather than discovered at a failure.

**The word in the last column is the point.** *Measured* means it ran here; *cited* means the
tool's own documentation says so; *unknown* means nobody looked. A capability written down
because it would be convenient is the failure this project is built against → [runtimes.md](runtimes.md),
which also says what changes when each one is missing.

### The commands

You never need one — anything a command does, a sentence reaches. **The palette exists to be
browsed as much as typed**: the front door plus nineteen verbs, each a door to a flow that
exists anyway, and together the shortest true catalogue of what this system does.

| | What it is for |
|---|---|
| `/opsinist:advisor` | **the front door** — the corpus itself: the laws, the routing table and what to load when. Every verb below loads it first, and a bare greeting reaches it without naming a command at all. The command is named for the **role**, because the advisor's own name (`display_name`) would repeat the plugin's |
| `/opsinist:init` | start or continue a project. Whether a repository is here, whether it is yours, and whether it is empty are **read from the ground, not asked** — that is what decides between standing one up, entering it as its operator, and entering it as a guest |
| `/opsinist:join` | take over a repo that already exists. It has its own name because **the match must fire before any prose is loaded** — measured on N8, runs that never reached `entering.md` fixed, deleted and committed first. The audit comes before any touch; findings as one classified list; nothing fixed before the owner has seen it |
| `/opsinist:import` | bring work in from anywhere — a tracker, a spreadsheet, an export, a paste. It has its own name because **declaring a crossing turns on two rules**: the mapping is shown before anything is written, and the imported text is treated as untrusted |
| `/opsinist:consult` | a question, not a thing to build. **Nothing is put into your project** — worth being able to demand rather than hope for |
| `/opsinist:hire` | grow the roster — a role born from a need, with its grade, its bars and what it owns |
| `/opsinist:fire` | park or offboard a role — archived with a note, never deleted |
| `/opsinist:status` | the health check: what runs, what waits, and what has aged past its promise |
| `/opsinist:cost` | what work cost — measured at the run, summed, with the leaks named |
| `/opsinist:ship` | a release: the batch, the guards, and the door it ships through |
| `/opsinist:review` | call another craft to look — a request with a status and an age |
| `/opsinist:decompose` | cut a feature into tasks — each workable from itself, with the seams named |
| `/opsinist:map` | the product as a map: the moves through it, in its own words — not the file tree |
| `/opsinist:decide` | run one decision loop — framed, searched live, compared, chosen, recorded |
| `/opsinist:automate` | a recurring job gets a real trigger, or an honest manual one |
| `/opsinist:skill` | the skill lifecycle: create from a routine, screen an import, compress, extract |
| `/opsinist:upgrade` | move the machinery to a newer version, with the migration named |
| `/opsinist:migrate` | move a project between machines or runtimes — the repository travels |
| `/opsinist:recover` | read state back from the record and continue an interrupted run |
| `/opsinist:audience` | ask the audience — personas with the signal pyramid kept honest |

**Anything else is a sentence.** *"what's stuck?"*, *"who's idle?"*, *"$50 a month"* — in any
language. There were twenty-nine commands once; twenty-six of them were names for things you can
simply say. The bar that keeps the palette honest: **a verb is a door to its own flow, never a
synonym** — and a door may also exist so the capability can be found.

---

## First run

Say what you are making, or type nothing in particular. It reads what you have and takes the right
entrance:

| What you have | Where it goes |
|---|---|
| nothing yet | the interview, then your first task |
| a repository already | an audit, then a debt list you approve |
| a backlog somewhere else | a mapping shown before anything is written |
| one job, no team | three questions and none of the machinery |
| a question | an answer, and nothing is created |

**Two questions are never skipped** — how much you want to be in the loop, and who may direct
this. Everything else has a default good enough to leave alone. *An agent once ran an entire
project hands-off because the first one was never asked.*

---

## What is inside

| | |
|---|---|
| **[SKILL.md](skills/advisor/SKILL.md)** | the core: the laws, the front door, and what to load when |
| **[GLOSSARY.md](GLOSSARY.md)** | one word, one meaning — and the pairs that look alike and are not |
| **[PATTERNS.md](PATTERNS.md)** | the twenty-seven shapes this system reuses, named once |
| **[lenses.md](lenses.md)** | four readings before anything of consequence ships |
| **forty-three companions** | loaded by trigger, never all at once |
| **[storing.md](storing.md)** | which of the six layers land in the repository, and which stay with you |
| **[runtimes.md](runtimes.md)** | which gates are real in the runtime you are actually in |
| **[evals/](evals/)** | scenarios, scored by pass-rate, including nine that press on the rules |
| **[sources/](sources/)** | the evidence behind every slow-rotting claim, with archive links and dates |

The core is a router with a declared budget. **A line added to it is paid by every run of every
agent, forever** — which is why procedures, examples and reference tables live in companions.

---

## How you would know it is working

**Success here shows up as an absence.** Nothing was decided twice. Nothing was rebuilt that was
already built. No bill arrived that nobody saw coming. Nobody asked *"who chose this, and why?"*
and got silence. A system like this is invisible when it works and obvious when it fails — which
is exactly why it is tempting to measure something showier instead.

So these are the tests we would rather be judged on. **None of them has a number yet** — this is
early and it has not been lived in. They are written down now so they cannot be quietly swapped
later for whatever happens to look good.

**Can a stranger continue?** Hand the repository to someone who was not there, and give them a
task. If they can pick it up without asking anyone what was meant, `project = f(repo)` is true.
If they have to ask, it was a slogan.

**Did the dead run resume?** Of the runs that hit a limit or died: how many came back and
finished **without redoing work that was already applied.** That claim is on the box, and this is
the number that keeps it honest.

**Is the waste share falling?** Cost is sliced so that *spent on work that produced nothing* is a
visible number rather than a feeling. On one project, over time, it should go down. If it does
not, the machinery is not paying for the room it takes.

**How often do you go behind it?** Reading the diff because you do not believe *"done"*.
Recounting the cost. Re-checking the board. Each of those is a failure even when every gate is
green, because **a console you audit is not a console.**

And one number we deliberately do **not** treat as success: the eval pass-rate. It tells you
whether behaviour got worse than it was — a regression detector, not evidence that it was ever
good. It grades conformance to a rubric we wrote ourselves, and this project has already watched
a run score thirteen passes while quietly breaking one of its own laws.

---

Apache-2.0. The name **opsinist** and its mascot are reserved — see [TRADEMARKS.md](TRADEMARKS.md).
