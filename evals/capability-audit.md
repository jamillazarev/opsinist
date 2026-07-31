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

**Resolved `2026-07-31`, all three parts.** `cost.md` reads *"warn at a share, **refuse the next
dispatch** at the cap"*; the unperformable half is named in the `prose-only` list where it had
been missing while reading as a gate; **and the performable half is code** —
`templates/company-preflight.sh` §12 refuses a commit that records spend while `docs/BUDGET.md`
sits at or past its pause threshold.

**Verified by mutation, in both directions, because a gate that cannot fail is not a gate:**

| Planted | Expected | Result |
|---|---|---|
| ledger at 71% of a $300 envelope | pass | passed |
| ledger at 106%, commit touching a task | **refuse** | **refused, with the envelope and threshold quoted** |
| an unfilled `BUDGET-template.md` (braces, no numbers) | silent | silent |
| over the cap, commit touching only `README.md` | silent | silent |

The last two matter as much as the second: **a hook that cries wolf is a hook people bypass with
`--no-verify`**, and a template nobody filled in must never block a commit. **This is the first
row in this audit to move from a verdict to a mechanism** — from *"this is what we ask for"* to
*"this is refused"*, wherever a project has wired the script.

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

## The remaining fourteen, against two full rounds

Every mechanism below has at least one scenario. The two figures are **the first suite → the
repaired suite**, each `pass / valid runs` at N=5, `void` excluded. Read them as a pair: one round
is an anecdote, two rounds agreeing is a fact about the corpus.

| Mechanism | Scenarios, round 1 → round 2 | Verdict |
|---|---|---|
| **escalation ageing** — a request has an age and stops an unbounded exchange | `N3` 0/5 → 0/5 · `S10` 0/5 → 0/5 | **claimed, measured twice, never once demonstrated** |
| **the review gate: author and reviewer differ** | `N4` 0/5 → 0/5 · `N21` 1/5 → 0/5 | **never demonstrated.** The parent closed itself in every round |
| **routing to another craft** | `N25` 0/4 → 0/2 · `N2` 2/3 → all void | **thin and mostly failing**; `N2`'s round-2 runs are void, so it rests on three valid runs total |
| **link health** | `N57` 0/5 → 0/5 — **and `scripts/check-links.py` passes, today, in this repo** | **split, and the split is the finding**: as a *script* it is real and green; as a *behaviour* — an agent meeting a dead citation mid-task — it has never happened |
| **dependency watching, three tiers** | `N19` 1/2 → 0/3 · `N40` 0/5 → 0/5 | **never demonstrated**; the register goes uncorrected even after the run says out loud that it is wrong |
| **format migration with a codemod** | `N12` 1/1 → all void | **untested in practice** — one valid run across two rounds is not a measurement |
| **import mapping** | `N28` all void → all void · `N8` 0/2 → 0/5 | **untested and failing** — `N28` is void by my own dispatch-sheet defect, and `N8` never audits before touching |
| **personas and their grounding** | `N7` 1/4 → 2/5 · `S12` 1/5 → 1/4 | **works sometimes** — roughly a third, the best rate of anything in this table |
| **the product map** | `N29` 0/5 → 1/5 | **barely** — one run in ten refused to map an unshipped move |
| **parallel dispatch — the owner is not held** | `N24` 0/5 → 0/5 | **never demonstrated.** The audit runs inline every time and the conversation blocks |
| **the permission trust ladder** | `N21` 1/5 → 0/5 · `N20` 0/4 → 0/5 | **never demonstrated** |
| **deletion enumerates its destinations** | `N15` 0/4 → 0/2 | **never demonstrated**, on six valid runs |
| **handover and the guest boundary** | `N13` 0/5 → 0/5 · `N14` 0/3 → 0/4 | **never demonstrated** — and `N13` is one of the three whose rule was later moved into the core, which changed nothing |
| **recovery after a limit** | `N10` 3/5 → all void · `S4` 0/2 → 2/4 | **works sometimes**, on thin evidence — the round that would have confirmed it produced no valid runs |

### What the table says when you stand back from it

**Every mechanism a script performs works. Almost every mechanism an agent must perform does
not.** The scripts in this repository — links, structure, freshness — pass today, and
`templates/company-preflight.sh` guards four things in an owner's repo **where it is wired**: the
promised docs exist, a recorded fact past its recheck fails the commit, the decisions log stays
append-only, and the architecture and product maps still describe the repository. Those are the
green rows in this project, and they are green because **nothing depends on a model choosing to
do them.**

**`link health` is the clean experiment, because it is both at once.** The same subject, guarded
by a script and asked of an agent: the script is green today and the behaviour is 0 for 10.

**The two best rates in the table — personas at about a third, recovery at about a half — are the
two mechanisms where the fixture makes the work impossible to skip.** A persona file with a
grounded bias profile has to be read to be used; a task history saying *run 2 applied and did not
commit* is the work. Where the tree forces the step, it happens more often. That is the same
finding as the ladder, arriving from a different direction.

**None of this says the mechanisms are worthless.** A rule that fires a third of the time still
fires, and on a stronger tier these numbers would differ — the doctrine deliberately measures the
weakest realistic executor. What the table forbids is the sentence *"the system escalates on
age"* said without qualification: on the light tier, measured twice, **it does not**.

### Where each verdict lands

- **`no hook`** — the spend cap (rewritten), and *"a schedule survives the session"* on a
  per-session runtime (rewritten per runtime).
- **`hook unwired`** — the cap's preflight check, which is performable and not yet written.
- **`works, unmeasured`** — format migration, and the hermes and OpenClaw schedulers.
- **`prose that shapes`** — everything in the table scoring under half, which is most of it. **The
  honest form of each is *this is what we ask for*, not *this is what happens*.**

**Nothing in this audit was repaired while writing it.** The repairs go in the next round, against
this baseline, and the ladder now says where to start: not another sentence, and not a better
place for it — **a field, a template, a script, or a restriction on who may assert.**
