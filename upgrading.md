# Upgrading — getting current

**Load when:** a new version of this system exists, a project is on an old format, or something
needs to move onto newer bytes.

**Two words, and they are not the same.** **Update** = new bytes arrive on the machine.
**Upgrade** = the project moves onto them. Confusing them is why people install something and
wonder why nothing changed.

---

## Four layers

| Layer | What moves |
|---|---|
| **this system's bytes** | the skill files on the machine — **by a route that differs per install**, below |
| **the project's format** | `schema_version` and the codemods that move a repo from one to the next |
| **attached skills** | third-party skills, re-screened |
| **tooling versions** | the things in the register, checked against their release feeds |

**Discovery precedes updating: run `bash scripts/find-installs.sh` and read the list it prints.**
It finds every install on the machine, names each one's version and its update route, and
separately flags the two states nothing else will ever report — a symlink resolving to a
directory that does not exist, and a copy sitting silently on an old version. Measured
`2026-07-31`: a machine remembered as holding three installs held **fourteen** — nine of them
symlinks into a directory that had never existed, so nine harnesses had the skill wired in and
loading nothing — and hours later the same machine held a config mount pointing at a copy a
cleanup had just removed, which the script caught and a person had not. **"Updated everywhere" is
a claim about a generated list, never about memory** — and the same list is re-run after the
updates, so every row is seen to have moved.

**The first layer has no single command, and assuming it does is how a runtime sits on an old
version while reporting itself current.** One route per harness was decided at install
(`INSTALL.md`); **the same choice decides how it updates**, and the table is here because a
sentence could not hold it. Measured end to end on `2026-07-31`:

| Installed as | What moves it | The trap |
|---|---|---|
| **a plugin, Claude Code** | `claude plugin marketplace update <name>` **then** `claude plugin update <plugin>@<marketplace>` | **the first step is the one people skip** — without it the second honestly reports nothing to update. Restart to apply |
| **a plugin, Codex** | `codex plugin marketplace upgrade` then `codex plugin add <plugin>@<marketplace>` | `add` without `@marketplace` refuses when two marketplaces are configured |
| **an extension, Gemini CLI** | **uninstall, then `gemini extensions install <url>`** — after the GitHub release is published; add `--consent` only when scripting | **`extensions update` is not the route.** Twice, differently: it answered *"already up to date"* on an old version — this route follows *releases*, and **a pushed tag is not one**, which hits every user — and it produced **no output for minutes** in a non-interactive shell, where the consent prompt had no one to answer it. Both look like a slow network and neither is. Uninstall-then-install took seconds and moved 0.1.1 → 0.1.2 |
| **a copied skills directory** | re-copy the source | the drift announces itself nowhere, so the announcement is a command: `scripts/find-installs.sh` after every update, and the copy's row shows the new version or the copy did not move |

An earlier version of that row said only *"nothing announces that the copy drifted"* — a
property, not an instruction — and within the hour the machine it described was caught holding
exactly such a copy. **A rule that names a property gets nodded at; a rule that names a command
gets run** — the same ladder as `self-maintenance.md`, applied to this table.

**Verify by reading the installed copy, never the command's output.** Each of the routes above
reported success at least once for a version it had not moved to — check the version in the
installed manifest, and that the core and the verb doors are all present.

**Preview first, always.** What would change, what it touches, and what it would require. Then
apply, then verify.

**The changelog is the migration map** — read the entries between the version the project is on
and the current one, and act on what they say rather than on the diff.

**Rollback is normal.** The previous commit is the restore point; there is nothing separate to
keep.

**Outside git there is no previous commit, and that is where a copy gets taken.** Uninstalling a
plugin, replacing an extension, moving a store: the safe move is to copy first — and **a copy
taken has exactly two endings, both of which include telling the owner.**

| Outcome | What happens to the copy |
|---|---|
| the step **succeeded** | **the copy is removed**, and the owner is told it existed and is gone |
| the step **failed or was abandoned** | **restore from it first**, verify the restore, **then** remove it — and say what failed, what was put back, and what state things are in now |

**A copy left behind is not caution, it is litter that looks like a backup.** Months later nobody
can tell a deliberate archive from an abandoned half-migration, and the one thing worse than no
backup is two states with no record of which is live. **Measured on this system's own release:**
a Gemini extension was copied before an uninstall, the reinstall succeeded, and the copy sat
there unmentioned until someone asked — the process had no ending written for the happy path,
only for the sad one.

**Finish by explaining it in plain language** — what changed, why it helps, what to do differently
now. That is onboarding a **person** into a release, and it is a different thing from onboarding
them into the system or into a project → `arriving.md`, `entering.md`.

---

## Format changes carry their own migration

This is the layer people skip, and it is the one that hurts.

**A change that alters the format does not ship without its codemod and a line about its risks.**
Not "here is what changed" — **here is what to run, what it will touch, and what could go wrong.**

**`schema_version` is what makes that possible.** A repo says which format it is on; an upgrade
knows which steps stand between that and now, and applies them in order.

**Moving a rule between files is a format change** for anyone who linked to it. That is not a
technicality: with the corpus split into companions, a reference that pointed at a section is a
reference that can break, and **only a link check across sections catches it** → `checking.md`.

**Anchors must be headings.** A reference to a bold line or a table row is invisible to tooling and
**dies silently the first time the table is reorganised**. If something is worth pointing at, it
gets a heading.

**An old-format project is a migration target, not a broken one** — and running an upgrade on one
is a scenario worth testing rather than assuming.

---

## Skills are re-screened, not assumed

**The version you vetted is not the version you are about to install.** Diff against the screened
one, scan it again, and **read the prose diff — a new paragraph is as much of a change as a new
script** → `security.md`.

Then record the newly-screened version, so the next upgrade has a baseline.

**Upgrading a skill that was never screened means screening it now, from scratch.**

---

## Tooling versions

For each entry in the register, check its release feed for a newer version **and for breaking
changes**.

**A tool that changed its interface breaks agents silently** — exactly like a stale pin, and with
the same symptom: work that used to succeed starts failing for reasons that look like the agent's
fault.

**Never upgrade unasked.** Summarise what changed and what it would touch — which roles carry it,
which rules mention it, which flows use it — and offer.

---

## When it applies

**At the next boundary, never mid-flight.** Work in progress finishes on the version it started
with; the next dispatch picks up the new one. **One version per unit of work.**

The advisor **reports which version it is now running**. A worker that proposed the new version
runs its *next* task on it — normal — but a single piece of work does not change under itself.

**Content applies on the next read.** Where a runtime registers commands or hooks at startup, those
need a restart; plain content does not.

**And where a team is running: wait for it to be idle.** Upgrading underneath live work is the
same failure as changing a setting mid-flight, with more moving parts.

---

## After a bad one

**Name what regressed** the way a recovery does → `recovering.md`.

**Restore the previous commit**, verify the regression is actually gone, and **write down what
broke, next to the entry**. The next attempt starts informed rather than repeating it.

**A rollback that nobody verified is a second change of unknown effect.**
