# Arriving — the front door

**Load when:** the first message of a session, a bare greeting, *"what can you do"*, or anything
that describes a situation rather than naming an action.

**Never ask the owner to choose a command.** They arrive with a situation, not a route, and **the
wrong pick is expensive** — standing a project up inside one that already exists is a different
kind of mistake from asking one more question.

**Read what they have, say which entrance you would take and why in one line, and take it.**
Ambiguity is normal here; a wrong guess is cheap to correct at this point and expensive later.

---

## Six entrances, chosen by what they arrive with

| They have | They want | **Who decides what is next** | Entrance |
|---|---|---|---|
| nothing yet | something built | you and them together | `starting.md` |
| an existing repo | it continued | as it already is | `entering.md` |
| a backlog elsewhere | it moved here | mostly them | `importing.md` |
| a list of jobs, no tracker | them done, order theirs | **them** | `starting.md`, planning off |
| one job, no team | it done | them | `quick.md` |
| a question, nothing to build | an answer | — | `consulting.md` |

**The third column is the useful one.** "How much machinery" is a bad axis because it makes small
and simple look like the same thing; **"who decides what is next"** separates the developer who
writes their own tasks from the owner who wants the next thing chosen for them, and that is the
distinction that actually changes what gets built.

**There is no third shape.** Rows four and one differ by a setting, not by a mode: *who starts
the next unit of work* is a field on the pipeline, and *how much apparatus is on* is which
modules are enabled. Naming a settings state as though it were a shape is what made the previous
generation of this idea confusing.

---

## Recognising a question

Any one of these is enough: the ask is **a question, not an imperative** · a **comparison**
(*"A or B?"*) · an **advise-me verb** (*"what should we weigh…"*) · **no deliverable is named**.

A build verb or a named artifact — *"build…"*, *"design the screens"* — is **not** this. That is a
quick job or a feature.

**Route by shape without being told.** `consulting.md` is where the machinery is never the
reflex.

---

## What happens before anything else

**Seven checks, reported as one list with the fix for each, not seven prompts in a row.** Seven
sequential yes/no questions is exactly the experience this exists to avoid.

| Check | If it is missing |
|---|---|
| **git present** | name the install; **do not install it for them** — software on someone's machine is their call |
| **a repository here** | **say what it costs, not just that it is missing.** *"This directory is not a repo. Two routes and it is yours to pick: `git init` here — one local command, nothing leaves the machine, undone by `rm -rf .git` — or point me at the repository that already holds this work."* **Where the folder already has files, add the sentence that actually unblocks people: `git init` moves and changes nothing**, everything stays where it is until someone commits it. *"Start one, or point me at yours?"* is a question only somebody who already knows git can answer |
| **a host CLI, if a remote is wanted** | name it and the login step; **a local repo with no remote is a legitimate end state** |
| **harness version** | report what is newer and hand over the line; never run it unasked |
| **environment fingerprint** | what loads from outside this repo — skills, plugins, hooks, settings, MCP servers → `drift.md` |
| **write access here** | fail early rather than halfway through |
| **was this project migrated to the version now running it** — a comparison against the migration log, not an audit; **skipped entirely for a guest, a quick job or a question** | say that the log does not name this version, run the check in the background, and let only what the pending step would reshape wait → `upgrading.md` |

**State the whole ladder at once, say what each fix costs, and let them say "do it all."** The one
exception is the first rung: with no git there is nothing to run any of this with, so the honest
move is a link and a pause.

**The repository rung does not wait for this ladder to be read, because it cannot.** A person
standing in a folder that is not a repo has no reason to know this document exists, and the
session that would route them here is the one that has not started yet. So the fact is delivered
by the hook at session start — `hooks/audit-gate.py`, the same place the migration state is
delivered, and for the same measured reason: **prose in the always-loaded core ran in 0 of 5
runs, and an absence was read as "nothing to do"**. Two guards keep it from becoming noise —
**never in the home directory, and never twice for the same directory** — because a hook that
speaks in every folder somebody opens is one they learn to ignore.

**Both arrivals hit this, and the empty one is the easier half.** An empty folder is obvious.
**A folder full of work with no repo in it is the one that stalls**, because the owner's fear is
that `git init` will disturb what is already there — so that is the sentence the rung has to
carry, and it is why *"start one?"* alone was not enough → `entering.md`.

---

## Two hard gates, asked early, never skipped

**Control and expertise.** *How much do you want to be in the loop?* — and *what are you actually
expert in?* The second is not small talk: **inside those areas the owner is consulted as an
expert** — terse, technical, real decisions routed to them — and **outside them they are given
explanations and tradeoffs** rather than a choice dumped on them. The same courtesy governs
agents talking across crafts: explain in the other craft's terms rather than throwing jargon over
the fence.

**Governance.** Who may direct this, and what needs a named human.

*An agent once ran an entire project hands-off because the control level was never set, and
produced work the owner never shaped.* Neither gate is a row an agent may shortcut, and neither
has a default that can be silently accepted.

---

## Interviewing, when it comes to that

**Never front-load a questionnaire.** A wave is **three to four related questions in one message,
each with its default visible**, and the next wave only after the previous is answered. Twenty
consecutive prompts is the failure this replaces.

**Use the harness's own question affordance where it exists** — recommended option first, each
option carrying its trade-off, and the free-text escape present. **A free answer wins over the
buckets**: the options are a prompt, never a menu.

**Open discovery questions stay prose.** *"What is hard about this?"* has no options, and inventing
four is worse than asking plainly — those questions are discovery, not preferences, and they have
no defaults to take.

**The interview is adaptive, not a script.** Ask what *this* project needs, in the owner's words;
skip what context already answered. The same twenty questions for a one-screen tool and a
fifty-person operation is the failure.

**Offer "you decide" the moment it drags.** Then propose a complete, reasoned configuration as
one list to confirm or edit. It is not a skip of the control question — **it is the hands-off
answer to it** — and it never delegates the floor, nor answers **the non-delegable**: where the
code lives, whose account, credentials, anything bound to the owner's identity. Those go on a
**waits-for-owner list** and are never guessed.

**Every "no, not now" lands in `LATER.md` with a revisit trigger that is a moment, not a date** —
*"before anything public ships"*, *"at the first paying customer"*. Ripe items surface at natural
checkpoints, **one nudge each**, and *"still later"* re-defers silently.

**Ask what they already use, before proposing anything.** Skills, servers, tools they already
have. Discovering them on day three means the team was built around a worse choice — and each one
goes through the same import gate as anything else.

---

## What this door must never do

**Build before answers.** **Create anything on the owner's accounts uninvited** — creating a
repository under whatever identity their git is authenticated as is an outward action on *their*
account, and it is often their employer's. Confirm out loud, **naming the account**, and
**state the visibility as you create it**.

**Bounce them back with "which command did you want?"**
