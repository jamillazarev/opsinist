# The four lenses — read before this ships

**Load when:** a change of consequence is about to land — a release, a merge into the guide, a
new capability, a rewritten rule. Also on request: *"run the lenses over this."*

Four readings, **one question each**, **in this order**, **by someone who is not the author**.
They are the **compensating control for every `prose-only` gate** — the reason it is honest to
write `enforced_by: prose-only` at all is that these run.

**Why four separate readings instead of one careful one.** A reader holding four questions holds
none of them. Each lens is cheap because it ignores everything except its own question, and the
order matters: deleting first means the later lenses read less.

**Why not the author.** Not distrust — **the author's context is invisible to the author**. They
cannot see what they assumed, because assuming it is what made the text feel complete.

---

## 1 · Deletion — what can go?

*Fights: additive drift.*

- What breaks if this is simply removed?
- Does it restate a rule that already lives somewhere? (If so, one of the two is the home and
  the other points.)
- Is a new entity doing work an existing one could do with **one more value**?
- Is this a pattern already named in [`PATTERNS.md`](PATTERNS.md), being paraphrased instead of cited?

The bar is not "is this good" but "would we notice it gone". A change that survives deletion is
the smallest version of itself, and that is the only version worth reviewing further.

## 2 · Adversarial — how does this fail?

*Fights: authors test what they intended.*

- The unhappy path. Misuse by someone in a hurry.
- **Does a failure fail loudly or quietly?** A gate that fails open is worse than no gate,
  because it is believed.
- What does a half-finished write leave behind?
- What is the **cheapest way to comply with the letter and violate the rule**?
- Who pays for it — in tokens, in attention, in a wait nobody sees?

## 3 · Contradiction — does this fight anything?

*Fights: local correctness.*

Against the corpus, not against taste. **Name both sides**, with locations.

- Does it promise something nothing delivers — a referenced file that does not exist, a check
  described but not implemented, a capability no door reaches?
- Does it use a glossary term in a second meaning?
- **A reversal is legitimate; an unstated one is not.** If this overturns an earlier decision,
  say so and say why, and the earlier decision gets its revisit note.

## 4 · Cold-read — understandable by someone who was not here?

*Fights: the author's context is invisible to the author.*

- Does it explain **why**, not only what?
- Does it depend on context that exists only in a conversation?
- Would a newcomer act correctly from this text alone — or **correctly by accident**?
- Is the example still an example of the rule, or did the rule move?

---

## Running them

**Each lens is stated, including when it found nothing.** *"Deletion: nothing found"* is a
result; silence is indistinguishable from a skipped lens. **And a lens that ran out of budget is
recorded as `not completed`, never as empty** — those two are identical in the report and opposite
in fact, so *"deletion: nothing found"* written over a lens killed at its third tool call is a
false clean. Measured 2026-09-10: **three rounds in one session lost twelve lens agents to usage
limits**, with nowhere to record it but prose. **A round carrying a `not completed` has not reported
clean**, which is the condition the tag waits on.

**A finding names its place and its fix:** path, line, the defect in one sentence, and what
would resolve it. A finding without a location is an opinion. **And an objection quotes the line it
is about** — the text as written, not a paraphrase of it. A paraphrase is where a lens's own reading
hides: the author answers the paraphrase, both walk away satisfied, and the line is untouched.

**A finding cites a verbatim excerpt, and its line is derived from that.** Not *"line 214"* — the
text as it stands, quoted, and the location computed by finding that text. **A quote that matches
nowhere is a finding about a file that has moved on, and a quote that matches twice is a finding
that has not said which one** — both leave it *unlocated* rather than placed, which is the honest
outcome and the one a line number silently fakes. This is what makes a mislocated finding
impossible instead of merely rare: every line number in a review is a claim about a file as it was
at some moment, and the moment is never stated. (Read off `alibaba/open-code-review`, 2026-09-17,
where the model is not permitted to emit a line number at all and the address is resolved
deterministically from the excerpt — zero hits and multiple hits both decline.)

**A verdict is a shape, not an adjective, and demoting one takes its fields away.** A confirmed
finding owes the things only a confirmed finding can have — what was observed, what would fix it,
how to reproduce it. **When the same claim is demoted, those fields are removed rather than
softened**, because a rejected finding still carrying a severity and a remediation reads, three
weeks later, exactly like a real one somebody forgot to act on. Softening the wording is how a
hedge survives; deleting the field is how it cannot ([`PATTERNS.md`](PATTERNS.md) §15 — evidence, not verdicts).

**Verification is structural, not attitudinal.** The cheapest honest version has four properties
and drops none of them: **one fresh reader who did not write the claim** · given the claim **and its
cited evidence**, not the author's reasoning and not another reviewer's conclusion · asked **to
refute it**, not to assess it · returning **one of a fixed set of verdicts**. Two more where the
stakes justify them: **a promotion goes to a third reader** who did neither earlier pass — the
direction that adds authority is the one that needs the independent look — and **where independence
cannot be had, the record is withdrawn and the round says `not completed`**, which is the same rule
this file already applies to a lens that ran out of budget. **Agreement from a model that was shown
the argument is not verification; it is a restatement.** (The four-and-two shape read off
`cloudflare/security-audit-skill`, 2026-09-17, whose verifier prompt opens *"You did not write this
candidate"* and whose third pass is triggered by any promotion.)

**The reader gets the artefact, not the author's case for it.** No plan, no reasoning, no summary of
what the change was trying to achieve — those are exactly the things that make a reader agree.
**Self-review confirms assumptions; it does not test them**, and a reader handed the author's
assumptions is doing self-review with an extra step. So the input is the diff and the files it
touches ([`dispatching.md`](dispatching.md) for what a subagent gets), and the round is run by someone who did not write
the text — which is the same rule from the other side. *(Named by Boris Cherny as the thing people
most often get wrong about verification, 2026-08; it agrees with this corpus's own measurement that
a model reads its own output generously, and sharpens it: the danger is not only the author
reviewing, it is the author's framing travelling with the work.)*

**A review names the pattern and quotes the line; it never returns a score.** *"This reads 7/10
machine-written"* is a guess dressed as a measurement, and a guess about **who or what wrote a
text** is not a finding at all — it is unfalsifiable and it insults the author when it is wrong.
**Name the pattern, quote the instance, and the reader can check both.** (Read off
`petergyang/no-ai-slop`, 2026-09-17, whose detect mode refuses to grade on exactly this ground:
detectors guess, named patterns are evidence somebody can check.)

**Findings are not votes.** The lenses report; the owner of the change decides, and a rejected
finding is answered, not ignored — one line saying why.

**The re-round reads the repair; the range is context, not the reading.** A round finds something,
the repair lands, and the rule is that the round runs again over it — which has been read as *read
the whole range again*, and that is what killed it. **Measured across 0.2.17 and 0.2.18: nine round
attempts, five lost whole to the session limit** — and in 0.2.18 the sharpest finding of each
re-round sat **in the latest repair commit**, while the one re-round that read only that commit (231
lines against 688) completed on the first try. So the re-round's input is the repair's own diff,
with the range available to open when a finding needs it. **The risk is named rather than
hand-waved**: a defect a repair causes *outside* the lines it touched is what this trades away, and
it is the reason the range stays reachable and the round still ends on a clean report over the
repair rather than over a sample of it.

**They run on this skill and on the user's project alike.** The corpus is not more fragile than
the work; the same four questions catch the same four failures in a spec, a role's instructions
or a pipeline change.

**A finding of the shape "X is not there" is checked in the main repository before it is
reported.** Measured 2026-08-09: a lens running in an isolated worktree read a tree three commits
behind and filed a defect against work that was present and verified three ways. Isolation buys a
reader who did not write the text; it does not guarantee a reader who sees the current one. **Two
of four lenses that day noticed the staleness themselves and diffed against the newest ref** —
which is the habit, not the exception: check `git rev-parse HEAD` first, and if a finding is an
absence, confirm it where the work actually lives.

**The repair a lens causes is unread until the round runs again over it.** The first round reads
text drafted *before* the findings existed; the repair is drafted *after* them, at speed, by the
person those findings have just persuaded — the condition every lens exists for. **Re-run the round
once the repair is committed and before the tag is cut**: the range is still `<last tag>..HEAD`, so
it already contains the repair, and no new mechanism is needed — the same four questions, a range
that grew. **It ends when a round reports clean**, and in practice the rounds shrink; a third still
finding structure is the release telling you something.

**Three occasions, and none of them was a fifth reader**: 2026-08-23, four lenses read a range
before its tag and *the worst thing they found was a regression in the repair itself*; 2026-09-05,
three of four adversarial findings were false refusals the repair had introduced; 2026-09-07, a
re-run over the repair found a stopping condition that pointed at a range excluding what it
deferred, a half-question unanswerable from the input its own text called sufficient, and a wrong
occasion cited for the ladder that promoted it.

**Give the second round the findings the first one raised** where they survive, because *did the
repair do what the finding asked* cannot be read off a diff. **Nothing retains them** — a lens
reports into a notification, not into a record anything reads back — so when they are gone the round
answers the half that can be read and says which half it could not.

**Do not tag between the rounds.** Cutting the tag first is what puts a repair outside the next
range: it becomes an ancestor of the tag, and `<last tag>..HEAD` excludes it by construction.
Measured 2026-09-07 on this repository's own history.

**What it costs is one more round per release, and nothing here has measured that.** The adversarial
lens's own fourth question is *who pays for it — in tokens, in attention, in a wait nobody sees* —
and this rule does not answer it. **No form holds it**: nothing counts rounds, so a skipped one and
a stated-empty one are the same artifact. `LATER.md` carries the candidate.

**Temporary readers.** When they run as agents, they are created for the release and archived
after — they read, they do not own. Archiving them is part of finishing the release
([`PATTERNS.md`](PATTERNS.md) → *promote what outgrew itself* does not apply here: a lens never grows into a
role).

---

## What the lenses do not cover

They read **text**. They do not run the code, walk the links, or measure a number — those are
[`checking.md`](checking.md) and the eval suite. Four green lenses over a claim that was never true is exactly
the failure mode the corpus names: *a statement that parsed perfectly, linked correctly, and was
false*. The six reading rules in `AGENTS.md` are the chapter habit for that, and the eval
pass-rate is the measurement.
