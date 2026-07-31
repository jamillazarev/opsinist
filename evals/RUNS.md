# Run record — what was actually run, and what it found

**This file exists so a number in the release notes has something under it.** A count of runs
quoted from memory is a recalled claim wearing a measured claim's clothes, which is the exact
failure `SKILL.md` names. What follows is what the repository can defend.

**The sections below are from `2026-07-28`, in Claude Code, against fixtures built by
`fixtures.sh`.** Runs were dispatched as subprocesses, each in its own parent directory, and
cleaned up by `eval-clean.sh` afterwards. No other runtime has run the behavioural suite →
`runtimes.md`; the hermes entry at the end of this file is smoke, and says so.

---

## Defects found in the corpus

**The record law never executed — routing by system vocabulary.** A run reached the right
companion and still opened no record, because the trigger that got it there was phrased in our own
words rather than the owner's. Fixed by rewriting the trigger; verified by a later run.

**The record law never executed — description instead of instruction.** `storing.md` explained what
a record is and never told anyone to open one. Fixed by adding the six numbered steps, with
`git init` as its own step because bundled with the line above it got dropped.

**Two independent runs produced the same id.** "Collisions are prevented structurally" was false —
ids were being invented rather than minted. Fixed by `new-id.py` and a duplicate gate in
`check-structure.py`.

**A pattern cited by nothing.** `PATTERNS.md` §27 was reachable from no instance, so nothing would
have carried it into a run. Found by the deletion lens; fixed by citing it from `writing-work.md`.

**Two laws met and neither yielded, twice.** Two runs on the same fixture, with the same
definition of done met, read the corpus opposite ways — one closed the task, one left it open —
because *nothing transitions itself* forbade the side effect and nothing named who may perform the
deliberate act. Separately, a run classified a one-page fix as quick, correctly, and then read
*a quick job gets no discovery pass* as licence to choose a therapy practice's palette, typeface
and list of services, surfacing all three afterwards. **Both were silences, not contradictions**,
which is why re-reading found nothing and running it did: a rule nobody wrote is invisible to
every check that reads what is written. Fixed in `writing-work.md` and `quick.md`.

**A guard that could not see its own gap.** The number table behind the stated-count check was
written by hand, so `"fifty companions"` passed silently while `"eighty companions"` failed. Found
by the adversarial lens; fixed by building the table from units and tens.

## Defects found in the test rig itself

**Fixtures were not isolated.** They shared a parent, so one scenario could see another's tree.
Rebuilt with a parent per fixture.

**A fixture did not encode its own scenario.** It was named for the situation and did not contain
it, so passing it proved nothing. Rebuilt.

**`eval-clean.sh` would have deleted an unrelated record.** It matched the owner's name as a
substring. Fixed to match the key exactly — the defect that would have cost real data.

**A player walked out of its fixture into the owner's real repositories.** Asked about an artifact
its tree did not contain, it searched `~/Dev` and read four unrelated projects — including a
frozen predecessor whose influence on this work is excluded by design. It found nothing it could
use and refused to invent, so the run stood; but the transcript read as an ordinary success, and
nothing in it said where the player had been. **Prevention is not available in this runtime** —
`scripts/eval-boundary.sh` is a tripwire over the transcripts instead, and it flags exactly that
run and none of the other seventeen. Detection is the honest name for it.

**Sixteen fixtures were built and only twelve were reachable.** `hire`, `ship`, `decompose` and
`import` were built by every run and named by no scenario, and no scenario named the tree it ran
against at all — so pairing one to the other was inference from a code comment. Fixed by binding
every scenario to its fixture, writing the four missing scenarios, and gating both directions.

**Two fixtures did not contain what their own comment promised.** `hire` claimed a spend request
and had none; `routine` claimed a weekly manual job and recorded no occasion of it — which meant
its scenario asked for *"the twice bar cited with both occasions named"* against a tree containing
zero. A passing run there would have been the player's imagination, scored as behaviour.

---

**The corpus was edited while the suite was running against it.** Six of eighteen players were
still in flight when a rule was added to `writing-work.md`, so they were not all measured against
the same text. Two of them noticed independently and reported it unprompted, which is the only
reason it is written here rather than lost — and the second named the changed files exactly, which
narrows the damage: of the four touched, three are the cleaner and this directory, which no player
loads. **Only `writing-work.md` is a companion a run can route to**, so the contamination is one
file wide rather than four. **Those runs are observations, not measurements**,
and the rule is now explicit: the tree under test is frozen for the duration of a suite — a fix
found mid-run waits for the run to end. A corpus that moves while it is being scored produces a
number that describes nothing.

**The cleaner read one markdown spelling of a key and not the other.** It matched `**Key**: x` and
missed `**Key:** x`, so a record a player wrote into the real store was left there while the
cleaner reported finding nothing. Fixed by stripping emphasis before matching, and it now says so
out loud when a `record.md` has no readable key — a cleaner that cannot read a key must never look
like a cleaner that found none.

**A law with no door.** The core states that a review goes to someone other than the author, and
the routing table had no row that a finishing agent would recognise as theirs — *shaping work* is
not what someone thinks they are doing when they want their build checked. **A rule nothing routes
to is a rule nothing executes**, which is the same failure the record law hit twice. Fixed by
adding *finishing something* to the router.

**An invariant that could be switched off.** `entering.md` listed review among the small set
"without which nothing else holds" while `requests.md` let the owner decline it. Found by the
contradiction lens, immediately after the second text was written. Resolved by naming which
invariants protect the work from itself — declinable, in writing — and which protect the owner
from us, which are not.

**A count in prose that nothing counted.** The release notes said `seventy-eight situations`; there
were eighty-four. The stated-count guard existed and this claim was not in it, so the guard passed
while the sentence was wrong. Added to the guard, which then failed on it before the number was
corrected.

**The map law ran twice on its first day, and the two runs disagreed instructively.** The
fixture's build claim was false by construction — a stub calling a function defined nowhere. The
first run **mapped the move and reviewed the claim second**, ending with a map ahead of the truth:
the miniature of the roadmap drawn on the map. The second run — frozen tree, so it is the
measurement — **checked the claim first and refused to map an unshipped move**, left the status
alone, and named the gap for the owner without inventing the fix. The scenario now names the
second behaviour as the expected one. Both runs kept the completion rule: neither author closed
its own task.

**The fingerprint caught the corpus moving mid-run a second time**, and the hand it caught was
again the author's. The freeze held as a mechanism where it had already failed twice as a memory:
the compromised run was demoted to an observation and re-run against a frozen tree, which is
exactly the procedure the first failure wrote down.

## The mutation sweep

**Running deterministic checks repeatedly proves nothing; asking each one to fail proves
something.** Thirteen defects were planted one at a time in a copy of the tree — a dangling link, a
dead `FILE.md:NNN` citation, a section reference that had moved, a rule copied into two files, a
duplicate id, an unreachable template, an unused glossary headword, a count drifted in prose, an
ageing cached claim, a fact past its window, a companion nothing routes to, a broken table row, an
unclosed mermaid subgraph.

**Thirteen planted, thirteen caught, none missed.** Re-runnable: the sweep is a copy-and-mutate
loop, not a recorded result.

---

## What this is not

**It is not a month of use.** Every scenario here was built to be tested, which is the opposite of
how a real project arrives. Fixtures do not get bored, change their minds, or leave a run half
finished for a week.

**The count is rounds, not confidence.** A suite that passes says the failures it was built to
catch are not present, and nothing about the ones nobody thought of.

---

## 2026-07-31 — the research & discovery cluster, six rounds, N=1 per scenario

**What ran.** Twenty-two dispatches across six rounds, in Claude Code, player on the **light
tier**, one below where the team runs. Each round: the corpus frozen and fingerprinted at dispatch
and re-checked at the end · a fixture per scenario in its own parent · the player given only what
a user would say. Scenarios N30–N58, weighted toward the ones that had just been written.

**Two things about this run are weaker than the doctrine asks, and both change what it proves.**
**N=1 per scenario per round, not N≥5** — so every line below is a round-to-round comparison, not
a pass-rate, and a single result could be noise. And **the judge separation did not hold**: the
same author wrote the rubric, ran the players and read the transcripts. Mechanical assertions
carried what they could — `git log`, `git status --porcelain`, tags, file contents, and fetching
every URL a player emitted — but where the assertion was about the *shape* of an answer, an
interested party graded it. **Read the fixes as measured; read the gradings as an author's.**

### The players never saw the rubric, and making that true took a step

The skill and the scenarios live in one repository, so a player reading its own corpus could have
read its test. Players ran against a **copy of the corpus with `evals/` and `scripts/` removed** —
what an owner actually installs — verified to contain no rubric text before each round.

### Defects found in the corpus

**Invented figures, three of them in one answer.** A run met a vendor whose free tier had closed
and produced *"1¢–5¢ per screenshot depending on volume"* for a vendor it had never contacted,
plus a competitor's free tier it had also never checked. Fixed in `resources.md`: an unreachable
figure is `unknown`, never an estimate. **Verified gone across three later rounds.**

**A register's check-date laundering a present-tense claim.**
`Checked 2025-09-02, and their pricing page now shows no free tier` — an eleven-month-old date
presented as verification of today.
Fixed in `resources.md`; the next round named the row as stale instead.

**A rule that was obeyed into the wrong behaviour.** `quick.md` said the owner's taste and brand
are asked for, which is right when nothing is written down — and two runs duly asked a project
whose register held a commissioned shoot, a licensed type pair and a one-icon-set rule. **The
runs were following the file.** Fixed by putting *read these files* above *ask the owner*, with
the paths named. **Verified: the fourth round opened with "I found your assets register."**

**A form that invited a lie.** An answer shape asking *what was checked, and when* was filled with
three fabricated check-dates for pages never opened. Changed to ask **what the page said**;
fabrication stopped in the next round. *A criterion that can be reasoned around will be* — the
corpus's own rule, caught applying to the corpus.

**No rule about what a source can do.** Prices were guarded; capabilities were not. A run promised
a museum print found *at 16:10* — a ratio is a crop, not a filter — and said nothing about the
licence, the one thing the owner had asked about. Added to `consulting.md`.

**A licence blocker cleared by inventing the permission.** Given *ship the charts in the paid
tier*, a run found the bundled dependency was BUSL-1.1 rather than MIT, corrected the register
honestly, **added "commercial license held" — a licence nobody had bought — and tagged a release**.
Verified from the tree: two commits, tag `v1.0.0`, task flipped to `shipped`. Fixed as a writer
restriction plus a validator. **The last round stopped and asked instead** — though the gate never
fired, because nothing was committed, so what stopped it is not established.

### Defects found in the test rig itself

**The fingerprint did not cover the file every run starts from.** It hashed every `*.md` at the
repository root — the companions and the furniture alike — while the core had moved to
`skills/advisor/SKILL.md`. Editing the core mid-run
would have reported *corpus unchanged*. Fixed; verb doors now covered too.

**The boundary tripwire filtered away its own evidence.** It read `SKILL.md` from the repository
root, which no longer exists, so the store name resolved empty and the filter became `^$HOME/\.`
— silently dropping **every** dotfile path a player touched, then reporting that everyone stayed
inside. Fixed to read `display_name` from the real path, and to refuse to run without it.

**The freshness checker could not quote a dated defect.** Writing down what a laundered date looks
like failed the gate that exists to catch laundered dates. Code spans are now exempt, matching the
sibling checker; a prose claim still fails, verified with a probe.

**A fabricated link passed a status check.** The cross-cutting rule said every URL must resolve;
an invented artifact URL returned `200`, because its host answers `200` for any path. It was
caught only when **three independent runs emitted the identical UUID**. The rule now requires the
body to name what was claimed, and calls the rest *unverifiable, which is not valid*.

**A fixture cannot test a repair its own files predate.** Four rounds scored a template change
that was not in front of them: the decision in the tree had been written before the basis became
a labelled field.

### Known limits, recorded rather than repaired again

**The rung does not survive retelling on the light tier** (`N49`, five rounds, three repairs
ending in a labelled template field). **A substitution is not declared** (`N44`, four rounds,
three repairs): a request for an existing print with usable rights was answered every time with a
freshly generated picture delivered as the result.

### What changed enforcement

Four rules moved from `prose-only` to `validator` in `templates/company-preflight.sh`, **and only
where a project has wired it** — the script is installed into the owner's repository, not shipped
inside the skill. One measured side effect worth keeping: a player working in a fixture with the
hook wired **created the documents the guide promises** because its commit would not pass without
them.

---

## 2026-07-30 — hermes-agent, four smoke runs. Not the suite, and not scored as one.

**What ran:** hermes-agent v0.19.0 on macOS, player `stepfun/step-3.7-flash:free` (a light
tier, per the doctrine), the skill mounted read-only via `skills.external_dirs`. One run per
condition, empty fixture directories, `--max-turns` capped. **N=1 per condition — these are
anecdotes that informed decisions, not pass-rates**, which is why no rate is quoted.

**Loading, unforced, no persona — missed.** The team-for-a-YouTube-channel query produced zero
tool calls and a generic five-bullet questionnaire: the skill was never opened. The description
alone did not pull a light tier in.

**Loading, forced (`-s opsinist`) — the router survived.** The model opened `SKILL.md` and
walked the routing table to `starting.md` and `arriving.md` unprompted. Progressive disclosure
works under hermes's loader; the open question in `runtimes.md` is answered for this runtime.

**Resident mode (an always-on persona naming the skill) — loaded and behaved.** Same query, no
`-s`: the skill was opened from the persona's one-line instruction, and the reply asked the
control-and-expertise gate in the skill's own terms, spoke the channel's language (scripting,
filming, thumbnails — no sprints), and asked one thing rather than a questionnaire.

**Consult — clean.** The tracker question routed to `consulting.md`, declared *"I will just
give my view and not build anything"*, created nothing, and offered the bridge once. All four
fixture directories were empty afterwards, checked by `find`, not by reading the transcript.

**What this changes:** an always-on anchor (persona, rules, session-start skill — whatever the
runtime has) is load-bearing for light tiers, not a nicety. Recorded as the hermes row in
`runtimes.md`; the suite proper has still run only in Claude Code.

---

## 2026-07-30 — OpenClaw, four smoke runs. Same caveat: anecdotes, not pass-rates.

**What ran:** OpenClaw 2026.7.1-2, gateway in local token mode, player
`anthropic/claude-haiku-4-5` (one tier down), the skill mounted as a symlink into
`~/.openclaw/skills` — the same layout its other skills use. The agent saw `opsinist` among
fifty-eight skills in its snapshot, so discovery infrastructure is not the variable.

**Unforced — missed**, the same way hermes missed: a generic questionnaire, the skill never
opened.

**A persona section in `SOUL.md` — present and ignored.** A probe confirmed the section
reached the session context verbatim; the reply still never opened the skill. The sentence
was read and did not win. On hermes the persona slot was enough; here it was not — the same
anchor idea lands differently per runtime, which is exactly why the row is measured per
runtime rather than assumed.

**An operational trigger rule in workspace `AGENTS.md` — fired.** *"When the message is
about building or running a team… open the `opsinist` skill first."* The reply named the
front-door route (something built → start a project), asked both hard gates — control &
expertise, governance — in the corpus's own terms, named the repository as the source of
truth, and created nothing. **The repair was a form, not a stronger sentence**, on the first
try.

**Consult — the rule's class was too narrow, and that is the finding.** A pure question
about switching trackers did not match "team/project/tasks/roles", so the skill stayed
closed; nothing was created, and the model argued *against* file-based tracking on its own.
The fix is the trigger's wording, not the runtime: the rule needs the class of questions
with nothing to build — the one the front door already names.

**Also observed:** OpenClaw's heartbeat is on by default at 30 minutes with a workspace
`HEARTBEAT.md` — the proactive half of the pilot has a native mechanism waiting; it was not
exercised in these runs.

**Two more consult runs, after widening the trigger.** With the question class added to the
rule, the model recognised the class — and then read *"just your take"* as licence to skip
the manual, saying so out loud. One hardening line — *opening the skill is reading your own
manual, not creating anything; the phrasing constrains the output, never the reading* — and
the next run framed the question as consult, gave the take, and created nothing.
**Instruction pressure against loading is a real failure mode, and its repair is also a
form.** Tuning stopped there: N=1 iterations explore; only the suite measures.
