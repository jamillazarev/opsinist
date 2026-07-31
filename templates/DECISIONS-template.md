# Decisions — what we tried, what we rejected, and why

**Append-only.** Add entries; never rewrite or delete one. This file exists so a rejected
idea stays rejected instead of returning every quarter — the task threads hold the same
history, but re-reading them costs more than anyone will pay.

**What belongs here:** an approach that was proposed and turned down, a tool evaluated and
passed over, a design taken and later reversed, an experiment that failed. **What doesn't:**
current state (that's the spec, roadmap and guide) or a deferral with a revisit trigger
(that's `LATER.md`).

---

## {{YYYY-MM-DD}} — {{the decision, in one line}}

**Considered:** {{option A · option B · option C}}
**Chose:** {{what}} · **Rejected:** {{what}}
**Because:** {{the evidence — a measurement, a quote from the docs, a cost, a constraint.
"It felt cleaner" is not evidence.}}
**Basis is —** {{`measured` (we ran it) · `cited` (a primary source, named) · `reported`
(**someone else's account of a source** — an industry article, a vendor post, a summary) ·
`recalled` · `judgement`}} **· from:** {{the thing itself, named as what it is}}

> The tier is **its own field, and it travels when the entry is quoted.** Measured three times:
> a decision whose basis was an article *reporting* a study was read back as *"research shows"* —
> the qualifier sat inside a sentence, and summarising dropped it first because it was the least
> informative-sounding clause. A labelled field is dropped visibly; a clause is dropped silently.
> **A source `reports`; only the study `shows`.**
**Would revisit if:** {{the condition that would make this wrong — a price change, a
version, scale. Omit only if genuinely permanent.}}
**Decided by:** {{who}} · **Where:** {{task link}} · **Advising:** {{the session's model and
effort at the time — the advisor is not dispatched, so nothing else records what was running}}
