# Automations — recurring and triggered work

**Load when:** something should happen on a schedule, on an event, or when a threshold is crossed.

**An automation is the thing that fires. A pipeline is the path work travels.** They were briefly
one word, which would have been expensive → `pipelines.md`.

---

## The file, and the contract

```yaml
trigger: cron: "0 9 * * 1-5"
         timezone: Europe/Warsaw
         missed_fire: run-once-late
template: weekly-digest
dry_run_first: true
stop_conditions: [budget-share-exceeded, three-consecutive-failures]
owner_of_failures: analyst
leaves_trace: true
```

**Every field is part of a contract, and none is decoration:**

**`dry_run_first`** — the first run shows what it would do. An automation nobody watched being
born is one nobody understands when it misbehaves.

**Idempotent steps.** It will run twice; assume it.

**`stop_conditions`** — explicit, and **required**. An automation with nothing to stop it is an
unbounded loop, which is the thing the whole gate apparatus exists to prevent.

**`owner_of_failures`** — a named role. **If nobody owns its failures, it should not exist**: this
is the cheapest filter in the file.

**`leaves_trace`** — does it appear on the board, or run quietly? **The default is to leave a
trace**, because a run that lands as visible work is reviewable, and one that does not is
invisible until it is wrong.

**`missed_fire`** — what to do when the time passed and nothing was running. Answering this is
what separates "late" from "silently skipped".

---

## Anything can be a trigger

A schedule · **a task reaching a stage** · a file changing · a pull request event · a webhook · a
threshold crossed.

The predecessor of this idea allowed only a clock and a webhook and **could not react to a stage
finishing at all**, which is the single most natural trigger in a working conveyor.

---

## Creates work; never moves anyone else's

An automation may **open a task, start a flow, raise a request**. It may **not** close anything,
advance a stage, or clear a blocker.

That is the same line as *nothing transitions itself*, and it is the reason automations are safe
to have: a board is only ever moved by a person or by whoever did the work. Otherwise
"automation" becomes the polite name for the thing that makes a board lie.

**Composable.** An automation **runs an existing flow** rather than carrying its own private
prompt, so improving the flow improves every automation using it. A prompt copied into an
automation is a fork nobody will remember to update.

---

## Failures are visible

**Silent failure was the worst property of the thing this replaces** — a scheduled run there could
fail and notify nobody, indefinitely.

Here a failed run is **an ordinary resident of the attention view**, like anything else that
needs a person → `requests.md`.

**A schedule that silently did not run is worse than one that says it was late.** Lateness is a
fact you can act on; silence is indistinguishable from success.

---

## Honest limits

**There is no server, and what survives depends on the runtime — checked, not assumed.**
Scheduling exists everywhere as *start on a timer*; **surviving the session that created it does
not**, and the difference decides whether an automation is real or decorative.

| Runtime | What a schedule survives | Verified |
|---|---|---|
| **Claude Code** | **the session and nothing more** — jobs are in-memory, nothing is written to disk, they vanish when the process exits, they fire only while it is idle, and recurring ones expire after 7 days | **2026-07-31 · measured** from the scheduling tool's own contract, live in this runtime |
| **hermes-agent** | **the machine — but only with a daemon the owner installs.** Jobs persist to disk rather than to a session, and `hermes cron status` reports plainly: *"Gateway is not running — cron jobs will NOT fire"*, pointing at `hermes gateway install` | **2026-07-31 · measured** — the cron CLI exists (`list · create · pause · runs · tick`), jobs are stored under `~/.hermes/`, and **on this machine the gateway is not installed, so nothing would fire**. Unattended execution is an install step, never a default |
| **OpenClaw** | a heartbeat, workspace-driven | **cited** `2026-07-30`; **no heartbeat setting is present in `openclaw.json` on this machine** and the interval was never exercised — treat the default as unknown |
| everything else | **unknown — treat as session-only** until a row says otherwise | — |

**So a promise like *"it will run tonight"* is false on a per-session runtime**, and the honest
form names the condition: *"it fires if this session is still open at that time."* What does not
exist anywhere is **anything happening while the machine is off**.

So a time trigger fires when a background session picks it up or a scheduled run starts, and
**inbound events queue and drain at the next pass**. State that plainly rather than implying a
cron guarantee, and set `missed_fire` accordingly.

**Use timezone names, never bare offsets** — offsets are wrong twice a year.

**A schedule can start late.** Fine for sweeps, wrong for a hard deadline.

---

## Webhooks are all four gated kinds at once

**A webhook's URL *is* the credential.** Holding it is enough to start runs — which **spends**,
consumes the **shared limit**, acts **under the project's identity**, and can be aimed at whatever
the automation does.

So: **creating one is owner-confirmed** · the URL is stored **as a secret**, never in a document, a
task or the repository · it is registered with **what is allowed to fire it** · and it is
**rotated when the people change**, not only when it leaks.

**Under any autonomy setting, an automation is an unattended actor** and deserves the same
scrutiny as any other.

---

## The ones worth having early

**A sweep that surfaces what got stuck** — interrupted runs, requests past their age, waits nobody
chased.

**A watch on dependencies** that publishes a feed → `tooling.md`.

**A wake after a limit resets.** A limit hit at 02:10 that resets at 07:00 currently waits for a
human to come back, and the reset time is a **known future moment** — which is a one-shot
schedule, not a poll.

**A regeneration pass** so generated surfaces are not stale, and — because the hash check runs
where regeneration runs — so that a hand edit is **reported before it is overwritten** rather than
after → `drift.md`.

---

## What not to automate

**A decision.** An automation can prepare one and put it in front of a person; it cannot make it.

**Anything gated.** Spend, outward, destructive, shape of team. A schedule is not consent, and
neither is urgency.

**A rule you have not yet been able to keep by hand.** Automating a process nobody has run
successfully once produces a reliable version of a bad process — and the reliability makes it
harder to notice.
