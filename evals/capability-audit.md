# Capability audit — does the promised thing exist

**Not "is it worded correctly" but "does it happen".** Every mechanism this corpus promises gets
one row: what is promised, in its own words · who executes it · what enforces it · whether the
runtime has the hook, checked live where checking is possible · whether any run has ever
demonstrated it · and a verdict from four:

| Verdict | Meaning | What it costs to resolve |
|---|---|---|
| **no hook** | the runtime cannot do this and will not | delete the promise, or rewrite it as a verb something can perform |
| **hook unwired** | the runtime can, we never connected it | a known gap with a known price — honest, not false |
| **works, unmeasured** | plausibly real, never demonstrated | `cited`, and labelled so |
| **prose that shapes** | legitimately unenforced, and it changes decisions | must appear by name in the `prose-only` list (`permissions.md`) |

**Why the fourth matters as much as the first.** A rule that nothing enforces is acceptable and
sometimes correct; **a rule that nothing enforces and is not on the list is the one that buys
false confidence**, which is the failure the list exists to prevent.

Started `2026-07-31`, after two full suites. **This is the first batch, not the finished sweep** —
rows below carry evidence; the mechanisms not yet reached are listed at the end by name so the gap
is visible rather than implied.

---

## Scheduling and the wake after a limit — **hook exists, and the promise is wider than the hook**

**Promised** (`automations.md`): *"Scheduling and background execution do exist: work can run
outside the terminal, **survive it closing**, and start on a timer."* And, as a flagship example:
*"A wake after a limit resets. A limit hit at 02:10 that resets at 07:00 currently waits for a
human to come back, and the reset time is a known future moment — which is a one-shot schedule,
not a poll."*

**Checked live, 2026-07-31, Claude Code:** the hook is real — `CronCreate` / `CronList` exist and
answer. **And its own contract contradicts the promise:**

- *"Jobs live only in this Claude session — nothing is written to disk, and the job is gone when
  Claude exits."*
- the `durable` parameter: *"Has no effect — durable persistence is not available."*
- *"Jobs only fire while the REPL is idle (not mid-query)."*
- recurring jobs *"auto-expire after 7 days"*.

**So "survive it closing" is false in this runtime**, and it is the load-bearing half of the
sentence. The wake-after-a-limit example inherits the same defect: a limit hit at 02:10 and
resetting at 07:00 fires **only if the session is still open and idle at 07:00** — which is the
case the example was written to solve, since the reason nobody is there at 07:00 is that the
session was left overnight.

**Verdict: rewrite the promise to the hook.** A one-shot schedule inside a live session is real
and useful and should be claimed exactly that narrowly. `runtimes.md` already says the honest
thing for the general case — *"nothing happens while nobody is watching"* — so the two files
disagree, and the wrong one is the one a run reads when it is setting up an automation.

**Resolved `2026-07-31`.** `automations.md` now carries a per-runtime table instead of one
universal sentence: Claude Code **measured** as session-only from the tool's own contract; hermes
and OpenClaw **cited**, with their schedulers marked as never run here; everything else **unknown,
treated as session-only until a row says otherwise**. The promise *"it will run tonight"* is named
as false on a per-session runtime, with the honest form given. **The rows for hermes and OpenClaw
are the next live checks** — both are installed on this machine, so both are checkable.

**hermes, checked live the same day, and the answer is a third thing neither row anticipated.**
The cron subsystem is real and **persists jobs to disk rather than to a session** — so durability
across a closed session is genuine there, which Claude Code cannot offer. **And it fires only
when a gateway daemon is running**, which the tool states itself: *"Gateway is not running — cron
jobs will NOT fire."* On this machine it is not installed. So the honest row is neither *"hermes
has cron"* nor *"scheduling is unreliable"*: **unattended execution is an install step the owner
performs, and until they do, a schedule is stored and silent.** Recorded in `automations.md` with
the command that reveals the state.

**OpenClaw stays `cited` and got weaker, not stronger.** The heartbeat this project recorded as
*"on by default at 30 minutes"* has **no corresponding setting in `openclaw.json` here**, and the
interval has never been exercised. Absence from a config file is not proof it is off — defaults
can be implicit — so the row now says the default is **unknown**, which is the true state.

## Spend caps — **no hook, and not on the list**

**Promised** (`cost.md`): *"Warn at a share, **stop at the cap**, and always offer the cheaper
path that still works."*

- **Nothing enforces it.** No runtime exposes a spend gate; `runtimes.md` has **no row about spend
  at all** — not even one saying it was never checked.
- **It is absent from the `prose-only` list** in `permissions.md`, the list whose entire purpose
  is naming every rule nothing enforces. So it reads as a gate.
- **A cap is only evaluable between dispatches.** One run can exhaust the remainder, and nothing
  can halt it mid-flight — which is the same honesty `S10` demands and fails 5 of 5.
- **On a subscription the authoritative number is not ours.** `cost.md` says so itself: the
  harness's usage view is the bill and our ledger is attribution. `N11` failed 5 of 5 on exactly
  that sentence going unsaid.
- **Never tested.** No scenario in either file covers a budget or a cap.

**Verdict: no hook — rewrite the verb.** *"Refuse the next dispatch"* is performable and checkable
by a validator against the ledger; *"stop"* is not. Whatever remains prose goes on the list.

**Resolved `2026-07-31`, both halves.** `cost.md` now reads *"warn at a share, **refuse the next
dispatch** at the cap"*, with the reason written beside it — nothing halts a run in flight, and on
a subscription the authoritative figure is not ours. And the cap is **on the `prose-only` list by
name** in `permissions.md`, where it had been missing while reading as a gate. **Still open: the
preflight check itself** — the performable half is not yet code, so today the cap is an honest
rule rather than an enforced one, and it says so.

## What the suites already settle

| Mechanism | Scenario | Two rounds, N=5 each | Verdict |
|---|---|---|---|
| resume after a limit without redoing applied work | `N10` | 3/5 then all void | **works, thinly measured** — observed once, and the round that would have confirmed it produced no valid runs |
| a hand edit reported **before** it is overwritten | `N6` | 0/5, 0/5 | **claimed, measured, does not happen** — both rounds regenerated over the edit |
| trust that moves both ways on recorded evidence | `N21` | 1/5, 0/5 | **claimed, measured, does not happen** |
| a tool gap met twice becomes a `tooling` task | `N5` | 0/5, 0/5 (mostly void) | **claimed, never once demonstrated** |
| a routine that repeats becomes a skill | — | **no scenario exists** | **untested entirely** — the mechanism the owner named as a headline capability has never been put in front of a player |

**The last row is the one to notice.** *"A repeated primitive becomes a skill"* appears in
`skills.md`, `self-maintenance.md` and `checking.md`, and **no scenario anywhere asks a player to
do it.** A capability described in three files and tested in none is not a measured claim; it is a
sentence the corpus finds agreeable.

---

## Not yet reached, named so the gap is visible

drift detection of the environment fingerprint · escalation ageing on requests · the review gate
where author and reviewer must differ · routing to another craft · link health · dependency
watching across its three tiers · format migrations and their codemods · import mapping · personas
and their grounding · the product map · parallel dispatch · the permission trust ladder ·
deletion's enumeration of destinations · handover.

**Each gets a row with the same six columns, or it does not count as audited.**
