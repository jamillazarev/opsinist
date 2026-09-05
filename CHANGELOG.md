# Changelog

Newest first. Each entry leads with what you can now do, not with which files moved.

## 0.2.15 — unreleased

**Migration — and this one affects every project whose roles and tasks are written from the
shipped templates, which is the shape this system tells people to use.** Three checks that were
silent on that shape now speak, and two of them **refuse a commit**: §7 where a project has two
advisors, §11 where a task's assignee is also the name that reviewed it. §8 warns where a role
carries eight or more skills. Measured on a fixture written exactly as `ROLE-template.md` and
`TASK-template.md` instruct: **silent under 0.2.14, refusing under 0.2.15.** Nothing was wrong with
those projects yesterday and nothing is wrong with them today — the checks simply could not see
them, so a rule the corpus states in three files was enforced by nothing.

**What to do:** re-copy `templates/company-preflight.sh` over `_ops/scripts/preflight.sh` — the
guard is a copy and the fix does not arrive on its own. Then expect, once: a second advisor named
where there should be one, a self-signoff that had been passing, and skill counts on roles that had
been counting zero. None of the three is a defect in your project; they are three years of green
that meant nothing.

**A field report from a live migration, and the sharpest finding in it is that a guard had been
repaired once already and stayed blind.**

- **§7 and §8 of the company guard could not see a role written from this repo's own template.**
  Both parsed YAML frontmatter — `type: advisor`, a `skills:` list — while
  `templates/ROLE-template.md` writes `**Type**: advisor · **Grade**: senior` and a
  `## Skills attached` table, and contains **no `type:` line at all**. Measured 2026-09-05 on a
  live migration: two declared advisors, **one found**; nineteen skills in a table, **zero
  counted**. The threshold §8 exists to enforce could never be reached by a role written the way
  this project tells people to write one.

  **This pair had already been repaired.** The comment above §7 records fixing it in August — for
  the *directory* it looked in — and the format mismatch survived that repair untouched, so both
  checks went on reporting green about files they never read. **A guard that is green because it
  looked at nothing is worse than an absent one: it issues a report on a check that did not
  happen.** Both forms are read now; the YAML stays as the legacy branch. The unfilled template,
  whose placeholder lists every type including `advisor`, is correctly not counted.

  **And the YAML path had never been measured either** — it counted **20 of 19**, because the
  frontmatter's closing `---` matched its own list-item pattern. An off-by-one is harmless; what it
  tells you is that nobody had run the numbers on either branch. Both forms are covered now as
  must-fire/must-not-fire pairs — the table and the YAML list, a filled role and an unfilled
  template, above the bar and below it — and restoring either old reader fails them. **The count
  of assertions is deliberately not quoted**: this entry said "eight", was corrected to "seven"
  when they were counted, and was eight again an hour later when one more landed. A number that
  moves whenever unrelated work touches the file is a claim that rots by construction, which this
  corpus learned one release ago and repeated here anyway.

- **The sweep the report asked for found a third one, and it is the most expensive.** Its closing
  caveat was that the question — *does this section read the shape its own template writes?* —
  belongs to every check that greps a templated file, not only the two it measured. Put to all 29
  sections: **§11 read the author of a task as `^(assigned|author|worker)[: ]`, a bare word at
  line start, while `TASK-template.md` writes `**Assignee**:` — bold, and a different word.** The
  author came back empty on every task written the way this project tells people to write one, so
  the comparison could never be true and **the check that stops an agent approving its own work
  never fired on this project's own format.** Measured: 0 on the template's form, 1 on
  `assigned: ui`. Both shapes and both spellings are read now, the legacy form still works, and an
  honest review by someone else still passes — that last assertion exists because a check that
  refuses everything proves nothing.

  The other sections held. §1c, §2, §3, §4d and §16 each spoke on a violation written from the
  template and stayed silent on the honest twin. The sweep's own probe was wrong five times before
  it was right, in five different ways, none of which ship: **a probe auditing guards needs exactly
  the scrutiny it is applying**, or it manufactures the same green it went looking for.

- **An adversarial lens read the repair the day it was written and found four defects in it —
  three of them false refusals the repair itself introduced.** That is the costlier direction by
  this file's own accounting, and all four were in lines that had just been edited.

  **§7 refused three honest repositories that committed the day before.** Widening it to the
  template's prose form left it a `grep -r` over the whole directory, so a `README.md` documenting
  the form and an `archive/` holding a retired role both counted as advisors. §8 has iterated
  `"$roles_dir"/*.md` all along; §7 now matches it, and a top-level README is excluded by name,
  because a document about roles is not one.

  **§8's new counter warned falsely at seven skills and at three.** It recognised the header row
  by its spelling, so a bolded `| **Skill** |` or a column called `Name` counted as a skill; and it
  closed the table only on `## `, so a six-row `### Escalation` table below pushed a three-skill
  role to ten. **Shape, not spelling**: the header is the first row whatever it is called, and the
  table ends at the next heading of any depth or the first line that is not a row.

  **And §11's reviewer half kept the exact defect its author half had just been repaired for.**
  `**Reviewed by**: ui` — the shape a bolded label naturally takes — extracted no reviewer at all,
  so the check passed on the very form the repair was about. Both greps are `-i` and the comparison
  between them was not, so `UI` could review `ui`. Both closed, both asserted, five mutants each
  failing the assertion written for it.

- **`migrate-layout.py` claimed `skills/` at a project root unconditionally.** In the reported
  migration that directory held a single README pointing at an unrelated repository — someone
  else's entity, moved silently into `_ops/` and put back by hand. The comment above `ENTITY_DIRS`
  already spells out this exact care for its neighbour — *`scripts/` is absent on purpose: at a
  project root it is usually the craft's own* — and `docs/` takes only the names it knows and
  prints what it left. **`skills/` was the one of the three the caution had not reached.** It is
  claimed now only when something under it carries a `SKILL.md`, and otherwise left where it is
  with a line saying so.

- **Three more the same lens found, in code this release wrote.** `looks_like_skill_pool` was
  fooled by a **symlinked** subdirectory — `is_dir()` follows links, so someone else's entity one
  symlink away made the whole directory look like ours, which is the exact failure the check exists
  to stop. The new `left alone:` line **could not print when it was the only thing to say**: it
  lived after an early `return 0`, so a repository whose sole ambiguity was a foreign `skills/`
  heard nothing about it, and the shipped test passed only because its fixture also had something
  to move. And `scripts/check-releases.sh` **reported green on nothing**: `gh release list`'s exit
  status was discarded, so no authentication, the wrong repository or no network read as *"0
  releases checked, every one matches its entry"* — `facts.md` 254's own shape, shipped in the
  three commits that quote it. It also printed "3 of 0" when a release had no entry, and took
  `--emit` only as the first argument, so the natural `check-releases.sh owner/name --emit <dir>`
  silently did nothing.

- **`--dry-run` printed one file as both moved and left behind.** `leftovers` read the directory
  from disk, which is right after a real move and wrong before a previewed one, so every file the
  preview had just promised to move appeared again as staying put. The behaviour was correct
  throughout; **only the preview lied, in the one place a preview exists for.** Fixed in both
  methodologies, since the line was identical in each.

- **The `All-in-one client DB` row is gone from the shelf: InstantDB is sunsetting.** Read at
  source 2026-09-05 — *"Instant is sunsetting. Services will continue until August 31st, 2027"*,
  the team having joined OpenAI. **The service outlives the recommendation by a year**, which is
  the reason to take the row out rather than date it: a shelf exists to be started from, and
  starting on something with a published end date is the one thing it must not suggest. Recorded
  here rather than struck through in place, so the shelf stays a list of what to reach for and the
  reason a name left it stays findable.

Eval state: **not run.** No scenario writes a role from the template and asks the guard about it;
the guards are covered by their suites, which print their own totals.

**Trio:** a fact (`facts.md` 254 — *a guard that reads a format its own template does not produce
is green because it read nothing*). **No diagram and no situation**, and that is deliberate: these
are repairs to mechanics the corpus already draws and already narrates, not new mechanics. Saying
so is the rule, not an omission.

## 0.2.14 — 2026-08-29

**A rule this corpus had written in file after file and enforced in none is now a form.** `escalating.md`
stops work at the *second* disagreement between two runs on one question — the bound on
**contradiction**, where the three-attempt rule bounds only **failure**. Contradiction is the worse
state and the reason is structural: both runs finish, so both report confidently, and a ledger that
records *how a run ended* has no place to notice that they concluded opposite things.

- **A run record carries a `Verdict` — what it concluded — beside `Outcome`, which is how it
  ended.** `LATER.md` named this gap on 2026-08-21 and deliberately refused to fill it: *"adding the
  field for the gate's sake alone would be the shape this corpus refuses — so it waits for a flow
  that wants the verdict written for its own reasons."* **That flow is review**, and the closed
  entry carries the argument. Most runs check nothing and write `none`; the word sits in the cell
  rather than beside it, which is the lesson `templates/RUN-template.md` already paid for on its
  cache cells — not one run of five wrote the accepted word when the cell did not carry it.

- **§1f of the company guard reads it.** A new record concluding `pass` where a completed sibling on
  the same task concluded `fail`, with neither naming an escalation, is refused at the commit — and
  the refusal prints the literal line to write, which is the shape that measured 5/5 on this corpus
  where a keyword hunt measured worse than nothing. **Recording the disagreement satisfies the
  gate**; what is refused is the second opposite verdict landing with nothing saying anyone noticed.
  It escalates as *"the question is unstable, and here is what differed between the two askings"* —
  never as *"which run was right"*, because that framing produces a winner rather than a resolution.
  **Only `pass` against `fail` clashes — every other value, and every run that did not complete, is
  excused**, because this file's
  own history says a false refusal on ordinary work costs more than the miss it closes, since it is
  how a project learns to reach for `--no-verify`.

  *Measured 2026-08-28, dated in `escalating.md` where the claim is made:* four mutants of the
  guard each fail assertions the honest twin passes, on a suite that is **189 green**.

- **Three of those assertions were vacuous when first written, and each was caught by a mutant
  rather than by reading.** One restored a fixture with `git checkout -- <file>`, which restores
  from the **index** — and the index held an escalation added two assertions earlier, so two checks
  passed because of a leftover rather than because of what they tested. One reused a record id the
  preceding commit had already taken, and §1f examines only *added* records, so nothing was
  examined at all. And one guarded against an unfilled `{{…}}` cell that the regex already refused
  — dead code, and worse than dead: on a **half**-filled cell it blanked a verdict genuinely
  reached because the sentence beside it was still a placeholder. All three now carry a paired
  assertion that fails if the fixture stops being examined.

- **The capability bar took two of the three in, plus the one that follows from them**
  (`self-maintenance.md` §2), together with the one that follows from them: **a mutation asserts
  that it changed the file**, because a wrong anchor makes the edit a no-op and the green that
  follows reads as *the mutant survived* — a conclusion about the assertion when the truth is
  about the patch.

- **The deletion lens read it before the tag and found the guard paying twice for one walk.** The
  neighbour table shipped as two tables built side by side from the same buffer, with `record_task`
  forked twice over identical bytes — while the comment between them congratulated the loop for not
  walking the files twice. One table now, one fork, and the escalation pattern that had been copied
  into three call sites has one home. **Consolidating three correct call sites produced one wrong
  helper**: the merged version lost `-i`, every record writes `**Escalated**:` with a capital E,
  and five assertions went red until it came back. It also found `mixed` shipped as a legal value
  with no code path and no fixture, and the excused set spelled out four times across three
  files — two of them one mermaid edge and one sentence in the same file — no two alike and none
  complete. One clause now, in one sentence, everywhere it appears.

- **Two more lenses read it before the tag, and both found the release contradicting itself.** The
  memo guarding the neighbour table still named the variable the deletion round had removed, so the
  table was rebuilt once per changed record — **four builds for four records, 16s against 150 kept
  ones** — reintroducing, in the commit titled *one walk paid for twice*, the exact cost a comment
  in the same file says was removed in 2026-08-16. **No assertion could see it**; the check is
  structural now, requiring the guard's variable to be the one its body assigns. Re-measured after
  the repair: **one build, 5s at 150 kept records and 4 new ones.** The older three-attempt gate,
  which now reads the same table, was re-probed and still refuses at three and passes at two.

  **House style switched the gate off.** This corpus writes every enum in backticks, including in
  the sentences defining this one — and a record following that style wrote a backticked verdict
  that §1f read as nothing. Bold did the same. Every fixture in the suite wrote the cell the one
  bare way that worked, so nothing caught it. **A false refusal teaches `--no-verify`; a false
  silence teaches nothing at all.**

  **The repair for that then refused the reader who complied.** Someone who pastes the printed
  line and types their answer *after* the angle brackets is still carrying the placeholder, and
  got back the message asking for the line they had just written — *unfollowable in one
  direction*, which is the failure the attempt gate beside it was rebuilt to stop, reproduced by
  its own fix within the hour. The two mistakes have two messages now, and the second one names
  the bracketed text and says to replace it rather than type around it.

  **And the refusal was satisfied by pasting the refusal.** The line it prints ends in a
  placeholder, and pasting the whole thing unedited passed — the shape §1f's own attempt gate
  condemns eleven lines below, with the gate handing over the shortest path to it. The placeholder
  has one home now, printed and excluded from the same string.

  **The numbers in the entry did not survive checking.** *"Three mutants each fail 5 assertions"*
  was four mutants failing 8 · 3 · 2 · 5 a day later. **Per-mutant counts shift whenever an
  unrelated assertion lands, so quoting them is a claim that rots by construction** — the release
  states which mutants and what the twin totals, and nothing finer.

- **The adversarial lens found the one rigid reader in a section that is loose everywhere else.**
  Every other field check in §1f is a substring test; `record_task` was widened on 2026-08-21 with
  the note that *the rigid reader in a loose section is the reader that silently counts zero*; and
  `verdict_of`, written last week, read a table row and nothing else. **A record declaring
  `**Verdict**: pass` as a line satisfied every other check in the section, was refused by
  nothing, and was invisible to the gate** — for `Outcome` as well. Both shapes are read now, and
  fenced blocks are skipped by both, because a record quoting this template for reference was
  otherwise read as concluding whatever the example says.

  **Three more, all silent.** A record declaring `Verdict` twice was read by its FIRST row, so
  `none` above `pass` hid a real contradiction while the reverse order was caught — one verdict
  per record now, and a second is a defect in the record. A value that is not one of the four —
  `passed`, or `failed`, which is a legal *Outcome* two rows above the same cell — took the
  silent-excuse path; it is refused with the four values named. And an empty `ESC_PLACEHOLDER`
  would have made every line match the exclusion, refusing honest work with a message about a
  placeholder it does not carry.

  **And a false refusal, which is the costlier direction.** `T-A.1` and `T-A.2` both read as
  `T-A`, so two records on genuinely different tasks were refused as one contradiction — **naming
  a task id present in neither file**, which is this section's own condemned failure mode arriving
  through the id reader rather than the matcher. An id that does not end where the guard stops
  reading it is now skipped with a warning rather than compared against the wrong task. Measured
  at 300 kept records: one table build, 7.6s per commit.

- **Four external review harnesses read, one mechanic kept as a candidate, one declined outright**
  → `catalogue.md`. `qa-swarm`'s convergence — two independent reviewers landing on the same file
  and line is evidence, not a duplicate — is named in `LATER.md` with its own bar, because lens
  output is prose today and there is nothing structural to compare. `review-triage`'s *a human in
  the thread ends the bots' authority over it* is the PR-thread spelling of a bound §1d already
  holds harder. `no-mistakes` is declined: prescriptive prose, no measurement, and its pipeline is
  this project's preflight plus its outward gate.

**Nothing breaks, and there is one thing to do.** A run record written before this version has no
`Verdict` cell at all; measured — such records are invisible to the check and every commit that
touches them passes, so no migration is owed and none is offered. **To get the gate, re-copy
`templates/company-preflight.sh` over `_ops/scripts/preflight.sh`**; until you do, the guard you
have will say so itself at your next commit, because it compares its own stamp against the guide.
Records written from here on carry `Verdict`, and `none` is the answer for most of them.

Eval state: **not run.** No scenario dispatches two runs at one question; the guard is covered by
its suite, which prints its own total.

## 0.2.13 — 2026-08-28

**Eight rounds of lenses read the tagged 0.2.12. Five remedies for the same defect were written
across three days; two of them shipped and destroyed data, and three more were caught before they
could.** Every one was written to prevent exactly what it then did. The pattern is the entry: a
repair that generalises its finding instead of its rule leaves the class standing, and the class
is what comes back.

- **`find-installs.sh` told you an install was at risk because of an edit somewhere else, and the
  remedy it printed deleted that edit.** It read `git status` across the whole repository, so an
  install living inside a larger one — a dotfiles clone carrying `.claude/plugins/<skill>` — was
  flagged for a change in an unrelated folder, and the `git reset --hard` it prescribed is
  repo-wide too.

  > **If you ran it, here is how to tell what it took.** `git reflog` in that repository shows the
  > reset and when — look for `reset: moving to`. What it discarded is every uncommitted tracked
  > change in the whole repository at that moment, and the two halves recover differently:
  > **anything that had been `git add`-ed is still in the object store** — `git fsck --lost-found`
  > writes the dangling blobs into `.git/lost-found/` where you can read them. **Anything never
  > staged is gone**, and no tool will bring it back; we would rather say that than let you spend
  > an evening looking.

  > **The second remedy took a different file, and it is recoverable by the same route.** Its
  > victim is *by definition* one you had `git add`-ed — that is the only kind
  > `restore --source=HEAD` deletes — so the blob is in the object store and
  > `git fsck --lost-found` writes it out, exactly as above. Verified 2026-08-27 against real git:
  > the staged file's contents came back byte-for-byte from `.git/lost-found/other/`.

  **Detection stays repo-wide, because the route it predicts is** — `git pull --ff-only` aborts on
  a modified tracked file anywhere in the enclosing repository, so an install inside a dotfiles
  clone really is at risk when a sibling folder is dirty. **What changed is which files it counts,
  and that is what makes a discard safe to print.** Four remedies were written here in three days.
  Two shipped and destroyed work: `reset --hard`, repo-wide, which took an unrelated file; then a
  scoped `restore --staged --worktree --source=HEAD`, which **deletes a staged new file outright**,
  because a path absent from HEAD is restored to not existing. The third refused to name any
  discard at all — safe, and unhelpful to someone whose route is stuck. **The fourth was one
  command from shipping the same defect a third time:** counting with `--diff-filter=MDRT` looks
  like it yields paths that exist in HEAD, and its `R` rows name a rename's *destination*, which
  does not. Measured, with the file deleted. The count is `--no-renames --diff-filter=MDT` now, for
  which the property is true and demonstrable: rename detection off decomposes that `R` into a `D`
  at the **old** path — present in HEAD, and the path an incoming commit can actually collide with,
  so detection gets sharper rather than weaker. The suite lifts the listing command out of the
  printed message and checks that property against a tree containing a rename; a mutant restoring
  `MDRT` fails it. The discard is printed in full — `restore --staged --worktree --source=HEAD` —
  because dropping `--staged` leaves the index differing, which stops the pull while this flag
  reads clean.

  **A fifth remedy was in the same message the whole time, and it could take a stranger's work.**
  `stash push` exits **0 having saved nothing** when the only difference is a submodule gitlink;
  the `stash pop` that follows then pops whatever was already on the stack. Measured 2026-08-28,
  with a week-old unrelated stash dumped into the tree and the stack left empty. The sequence is
  printed guarded now — `refs/stash` compared across the push, `pop` only if it moved — and the
  suite runs the printed line verbatim against exactly that repository and requires the unrelated
  entry to survive; the unguarded form, run on the same fixture, consumes it.

  **And the count has two blind spots, now stated wherever it is described.** `git pull --ff-only`
  also aborts on a **staged new file** and on an **untracked file** when the incoming commit adds
  that same path — both measured 2026-08-28 with the count at 0. Neither is countable without
  knowing what is incoming, and counting every untracked file recreates the false positive that
  started all of this. So the flag says outright that the count is a warning and the pull is the
  only exact test, and it leads with the pull because running it costs nothing. **A shipped comment
  said flatly that an untracked file never blocks a pull** — the stray-file measurement generalised
  into a rule it does not support, in the function whose own entry accuses an earlier repair of
  exactly that.

- **`--doors-only` overwrote a file outside the repository through a HARD link.** 0.2.12 closed
  the symlink route by resolving the destination; a hard link has no target to resolve, so
  containment passed and the door was written through — measured, a file outside replaced by 19 KB,
  reported as success at exit 0.

  > **If you ran `--doors-only` on a repository where `_ops/scripts/transition.py` or
  > `_ops/scripts/new-id.py` was a symlink or a hard link, your file is probably still there.**
  > The command wrote a copy of what it was about to overwrite, next to the door:
  > `_ops/scripts/<door>.replaced-<hash>`. That copy is an ordinary new file — it does not share
  > the link — so it holds the original bytes even though the door itself was rewritten. Look
  > there first. To find the other name: for a **symlink**, `readlink _ops/scripts/<door>` prints
  > it outright; for a **hard link**, `ls -li _ops/scripts/<door>` gives the inode and
  > `find ~ -inum <n>` finds the rest. The inode hunt does nothing for a symlink — it returns the
  > link itself — so read which kind you have first.

  A door whose link count is above one is refused now, before anything is written.

- **Eight ways `_ops/TOOLING.md` could be made invisible to §4f**, all closed, and they need
  four cures. An inline `<!-- … -->` in a live row hid that row while the page still rendered it ·
  a `<!--` with no closer hid every row after it, permanently · a stray fence marker at the top did
  the same — *an opener is believed only when a closer exists.* **A line that was ENTIRELY an
  inline comment read as the end of the table** and silenced every live row below it, which is the
  parked-draft idiom the guard's own message recommends — *a line left empty by the strip is hidden
  rather than read as a boundary.* The strip that fixed that **could not cross a `>`**, so a parked
  row containing `->` or an HTML tag brought the silence straight back, and a CR at the end did too
  — *the strip survives the text it walks.* And two more, found adversarially after all of that was
  written: **a live row quoting the opener in backticks** — `` `<!--` `` — had no closer on its
  line, so the multi-line path fired and swallowed every live row down to the next parked row,
  meaning a register that documents its own parking idiom disarmed the gate; and **a bare `-->`
  left standing** was read as the end of the table. *An opener inside a code span is text, and a
  stray closer is not a boundary.* **This bullet said "three ways · one cure" through three of
  these discoveries and "five" through two more**; the count moves with the next one.

  The strip also **rebuilt the whole line every pass**, rescanning everything already walked:
  **27.8s** on a 390 KB row against 0.06s for the single `gsub` it replaced — measured 2026-08-28,
  a fresh regression from the repair above. A guard that slow is one people run with
  `--no-verify`, which the file's own header names as its failure mode. The walked prefix is
  consumed and never scanned again: same output, **0.7s**.

- **A tab inside a tool name dropped its row, and a CRLF register read a blank answer as filled.**
  Both were introduced by 0.2.12's own rewrite of that block.

**Doctrine.** Five entries joined `facts.md`, and one of them had to be scoped before it shipped:
*an interactive multi-step flow is a form that does not hold* is true of a flow a run walks
**unattended**, and the progressive interview is the opposite case — a person answers at every
turn, and that is what forces the next step. Written unqualified, it condemned this system's own
front door. The other four carry their source in the line, because `facts.md` is what other
writing quotes and a rate without its origin becomes this project's number by morning.

**`_ops/FIELD-NOTES.md` gained a `Closed` column** — the version that shipped the fix. **Nothing
validates the table's shape, so an existing five-column file keeps working**; add the column when
you next close something. The one edit the append-only rule permits is this cell moving from empty
to a version, and a `Closed` that already holds one is never changed.

- **`--doors-only` wrote through a symlink whose target was inside the repository.** The
  containment test only asks whether the target leaves the tree, so an in-repo target was
  overwritten — a tracked file replaced by 19 KB of door. A second name is a second name wherever
  it lives, and both kinds are refused before any write.

  > **This one is the mildest of the three, and you have two ways back.** The target was tracked
  > and its path is in `HEAD`, so `git restore -- <path>` returns it. And the
  > `.replaced-<hash>` copy written beside the door **holds that file's original bytes** — the
  > copy is made by reading the door path, which follows the symlink to the target, and written to
  > a fresh path that shares no link with it. Either route is whole; the earlier entry's warning
  > about a backup landing on the wrong side belongs to the *outside*-the-repository case, not
  > this one.

  **The same bullet's claim did not cover a symlinked DIRECTORY, and an adversarial lens walked
  straight through it.** With `_ops/scripts -> scripts_real` the door is an ordinary file with one
  name, so the second-name test saw nothing, and the containment test asks only whether the target
  leaves the tree — which it does not. Measured 2026-08-28: a tracked 45-byte file replaced by 19 KB
  of door at exit 0, **while the printed diagnosis said the link led *out* of the repository and
  told the reader to move it *in*, where it already was.** Any symlink between the root and the
  door is refused now, in either direction, and the reason is the one thing both directions share:
  git cannot stage a path behind a symlink — *pathspec … is beyond a symbolic link* — so no commit
  here could carry the door whichever way the link points. Your bytes are recoverable the same two
  ways as above.
- **Four notices in this project's own hooks were giving orders to the runs that read them, and
  a fifth is in the sibling.** The one that started it fired after twelve read-only calls:
  *"Stop digging: say what you know, start the wave (a task, a dispatch), or ask the one question
  that is actually blocking."* For a review, an audit, or a question answered from the record,
  twelve read-only calls are the contract, so for that reading the order was simply wrong. It
  reports the count now, names both readings, and says it cannot tell which.

  **Removing that instance left the class**, which an adversarial lens then found three more times
  in the same file, on the same non-blocking channel: *"Before acting on it, say so, run the
  migration audit"*, *"**bump the version line in the guide**"*, *"Reconcile the version line
  before acting on the project"*. All three state what was found and what procedure this project
  publishes now, and command nothing. The sibling's `dispatch-nudge.py` carried the twin defect
  untouched — *"Assign it to an agent"*, *"take the next real step"* — and its suite **asserted
  that it did**, requiring the note to say to dispatch. Both are repaired; that assertion is now
  its opposite.

  **The guard against all of this was a spelling check, and the lens proved it.** Three assertions
  grepped for the literal words *"Stop digging"*; a mutant that put the order back as *"Stop
  investigating and start the wave now. Do not read another file."* passed all three. The check is
  a shape check now, run over **every** notice the file emits and keyed to `security.md`'s own
  published test — text that "tells the reader to run, install, send, fetch, grant, ignore, or
  contact" is an instruction found in data. It denies the synonym mutant, and it caught one more
  place in the shipped tree where an option read as an order.

  **The rule was also cited wrongly here.** This entry said the position is that *text arriving
  through a tool* is data — a provenance test, and `security.md` exists to replace exactly that
  one: *the test is who the text addresses, never where it came from.* The conclusion holds under
  the real test; the reason given for it did not.

  **And the note did not arrive once.** Read, increment, write and the already-spoke test are four
  unsynchronised filesystem operations, so a batch of parallel read-only calls put several past the
  threshold together and each one spoke — **twice in 6 of 12 trials, measured** — which is the run
  it was written not to harass, harassed twice. An `O_CREAT|O_EXCL` create settles it atomically:
  0 of 12 after, 5 of 12 for the unfixed form on the same probe, and four trials of it run in the
  suite. The count in the text is the real count now, too; it was hard-coded to twelve while `n`
  could arrive higher.

Eval state: **not run.** No scenario measures any of this; the guards are covered by their suites,
which print their own totals.

## 0.2.12 — 2026-08-23

**Four lenses read 0.2.11 after it was tagged. Everything here is what they found in it.**

- **§4f asked the rung of retirements.** A tooling file commonly carries a second table —
  `## Retired`, recording that something went **away** — and every row in it was checked for what
  it replaces, which is the opposite question. It passed or failed by accident, on whether the
  first table's column ordinal happened to land on a filled cell in the second. **Rows belong to
  their own table now**, found by the header that actually carries the `Replaces` column. A
  register with no such column anywhere keeps the old behaviour, where every table row is a
  candidate — so a `## Retired` table in *that* shape is still asked, and that is the honest
  limit of this fix.

- **`--doors-only` ended its refusal with *"read the reason above and pick accordingly"*** —
  pointing at a parenthetical in its own sentence, and, when git printed nothing, at an unresolved
  either/or. It picks one remedy from git's own reason now. And it **stopped printing *"doors
  re-copied beside the guard"* over doors it had just failed to stage** — the shape `git pull`
  uses to hide its own failures, printed directly beneath two refusals.

- **`find-installs.sh` called healthy installs broken.** It fired on **untracked** files, which do
  not stop `git pull --ff-only`, and offered a `reset` — destructive advice for a false positive.
  **If it told you an install was broken over a stray file, the install was fine.** It reads
  tracked modifications only, says **AT RISK** rather than BROKEN (a modified file stops a
  fast-forward only when an incoming commit touches it), and its remedies are commands you can
  paste. **It had no test at all**, under a commit titled *a route nobody verifies is a route
  nobody has*; it has twelve, and they are what forced BROKEN down to AT RISK.

- **`--doors-only` overwrote a file outside the repository.** If `_ops/scripts/transition.py`
  — or `_ops/scripts` itself — was a symlink leading out of the tree, the door was written
  **through** it: a measured case replaced a 35-byte personal file with 19 KB of door, and the
  only notice was *"the previous file is at …"*, naming a backup written inside the repo whose
  original was not. **If you ran `--doors-only` in a repository where either path is a link, check
  what is at the far end of it.** The destination is resolved now and a write that lands outside
  the repository is refused, which costs nothing that was going to work: no commit there could
  have carried the door either.

- **Three words meant one thing in the glossary and another in the code** — `door`, `rung`, and
  **`the reach gate`**, which was 0.2.10's headline capability and appeared in no README and no
  glossary, only inside its own implementation.

> [!NOTE]
> **An earlier draft of this entry claimed three fixes that shipped in 0.2.11** — §4f reading from
> the index, the four column-finding defeats, and `--doors-only` staging a door missing from the
> index. All three are in the `v0.2.11` tag; two lenses caught it independently by checking the
> claims against `git show v0.2.11:`. **This is the third release running where a draft entry
> promised an upgrader a fix they already had**, and 0.2.11's own entry carries a parenthetical
> apologising for the second. A changelog claim is checkable against the tag in one command, and
> checking it is not optional.

Eval state: **not run.** Nothing here changes what a run is asked to do.

> [!IMPORTANT]
> **Correction, 2026-08-27 — this entry omitted the most important thing in its own range.**
> `91c6425` closed a **single-character bypass of §4f**: the register's header was handed back to
> awk as a command-line assignment, which awk escape-processes, so a header containing a backslash
> arrived mangled, the comparison matched nothing, and **the rung went silent for that file
> permanently**. Anyone who wanted the gate gone edited one header cell. Three further evasions
> closed with it — a `Replaces` column on a later table capturing the gate, a decoy table above the
> register, and `-F"|"` shifting fields on an escaped or backticked pipe. **If you are on 0.2.11 or
> earlier, this is the reason to move.**
>
> The entry also opened *"Everything here is what they found in it"*, which was false of the tag:
> the range also carried five `facts.md` entries, a `runtimes.md` row, two `catalogue.md` rows, a
> `LATER.md` entry and a rule change in `templates/TOOLING-template.md`. Found by two lenses reading
> the tagged range four days later. The heading is frozen, so this is a marked correction rather
> than a rewrite.

## 0.2.11 — 2026-08-23

**Three gates were refusing honest work, and two of them were refusing the remedy they had just
printed.** All three shipped in 0.2.10 and are repaired here. (An earlier draft of this entry also
claimed the tool-choosing diagram and its missing fact — those shipped *in* 0.2.10, not after it,
and listing them here would have promised an upgrader a fix they already had.)

- **`--doors-only` told you your door was not staged when it was.** It asked
  `git diff --cached --name-only`, which lists paths whose index entry differs from HEAD — so a
  door deleted and restored to identical bytes is staged correctly and appears nowhere in that
  list. **If you saw *"written but NOT staged"* while following the guard's own instruction, your
  tree was fine**, and the advice about gitignored paths and symlinked directories did not apply
  to you. It asks the index directly now.
- **§4f read your register's header as a row** unless your first column happened to be called
  Tool, Name or What. **If you named your columns anything else — `| Thing | Why | Owner |` — then
  standing up `_ops/TOOLING.md` at all, headers written and no tools in it yet, was refused for
  saying nothing about what it replaced.** (The shipped template opens `| Tool |`, so a register
  begun from it was not affected — which is exactly why this went unnoticed.) The header is now
  found where it structurally is, above the separator, in any language and any GFM dialect. A
  fenced example table is not a row, and neither is a separator written `|-|-|`.
- **§4f was stricter than its own refusal message.** With a **Replaces** column in the register
  the gate read that cell and nothing else — so writing the reason in `_ops/DECISIONS.md`, which
  is what the message tells you to do, left you refused by the same message with no hint that a
  column existed. **Both homes now count**: the cell, or a decision line that names the tool.

**Four lenses then read the range before it was tagged, and the worst thing they found was a
regression in the repair itself.** §4f had been reading the register from the working tree and the
added lines from the index: the moment those disagreed the intersection was empty and the rung
went **silent** — so staging a row and then aligning the table's pipes, which is the next thing a
person does, passed a row the gate had just refused. That is weaker than what it replaced.
Everything is read from the index now, which is what a commit is made of. Four more ways the same
block could be defeated or could refuse honest work, all measured and all fixed: a header below
line 20 disarmed the column check entirely · a sentence in the preamble naming *Replaces* hijacked
the column index so every row was refused · a plain, unbolded `Replaces` header sent an honestly
filled register to the keyword fallback · `|-|-|`, which is valid GFM, read the separator itself as
a row. **And a `~~~` fence or an HTML comment no longer hides an example from being seen as one.**

**Also repaired here, from the same reading:** `--doors-only` reported *"already in place and
current"* for a door sitting on disk with the right bytes and **missing from the index** — the one
case its own refusal names as measured, and the one the remedy could not reach. It stages it now
and says so.

**The pattern in all of it: the condition a gate fires on was repaired and the sentence it prints
was not.** Assertions were added for each; the suites print their own totals, which is the only
count with a guard on it.

**Migration — and this one affects you if you upgraded to 0.2.10.** The guard copied into your
repository at `_ops/scripts/preflight.sh` stamps its own version on line 2, and warns when that stamp
disagrees with the version your guide says you run. **The stamp was not bumped for 0.2.10,
so the warning fired on every commit — and re-copying the guard, which is exactly what the warning
tells you to do, brought the same stale stamp and did not clear it.** It is stamped 0.2.11 now,
and a check in this repository's own preflight refuses a release whose stamp lags the version, so
it cannot be forgotten again. **What to do:** re-copy the guard once more from this release, along
with the two scripts beside it, and the warning goes quiet. Nothing else about your repository has
to change.

Eval state: **not run.** Nothing here changes what a run is asked to do; it changes what the
guards accept, and every change is covered by an assertion in the suite that owns it —
`test-company-preflight.sh`, `test-migrate-layout.sh`, `test-audit-gate.sh`.

## 0.2.10 — 2026-08-23

**The reach, not the gate.** 0.2.9's round measured what its gates could not: across ten runs the
player edited the machinery 8 times and committed **0** times, so every rule this project holds —
all `enforced_by: validator`, all enforced *at the commit* — went unreached. The gates were not
weak; the work never arrived at them, and the paired arm proved it: with *"then commit it"* in the
turn, the same gate was reached, refused, answered and satisfied **3 of 3**.

**So the ending is refused while `_ops/` sits uncommitted** — a Stop hook, and it **forbids**
rather than asks. That is the design, and it is measured too: this system's own rounds found a
fact delivered at session start bought 0 of 5, a demand at the ending bought 1 of 5, and the one
rule that only ever *forbids* held 5 of 5 in all three. A reminder to commit is precisely the
shape that does not work.

It speaks **once** — a gate that repeats is one the next run learns to sit through, and leaving
work deliberately is a real answer, said in a line. It watches `_ops/` only: the product's own
files are the craft's business, and a run may rightly leave them for review.
`OPSINIST_UNCOMMITTED_GATE=off` is the deliberate door.

The four clauses: the form is the hook · six assertions, and the mutant that removes the gate is
denied (108 → 107/1) · measured 2026-08-22 · the rule in `recovering.md`, fact 245, a situation.

**And the rung above every tool choice: does this need to exist at all.** Taken from a
third-party ladder the owner brought — YAGNI · already here · standard library · native platform ·
installed dependency · one line · only then the smallest thing that works — and **taken as a form,
because the same ladder as prose is what this corpus measures at zero.** A commit that adds a
dependency names it in `_ops/DECISIONS.md`, with what it replaces and what was rejected: the
dependency's own **name**, not a keyword, because a gate satisfied by vocabulary teaches people to
sprinkle words. A version bump is not a new dependency and is not asked. Four assertions, mutant
denied. Its extractor took three iterations and reformatting was the adversary every time —
re-indented neighbours, then collapsed-and-expanded braces — each caught by its own suite within
the hour, and each named in the comment rather than smoothed over.

**Pass thirteen read this range before it shipped: 91 findings, 8 critical, and every critical is
repaired here.** The four worst were mine, made the same day the capabilities were:

- **The reach gate fired outside its own project.** It sat above the arming check, so with the
  plugin merely installed it refused the ending of any session in any git repository holding an
  uncommitted manifest — including sessions that never opened this skill. Four lenses, independently.
  It is armed now, and it also asks whether **this** session wrote anything: a run that only
  answered a question is not blamed for the tree it inherited.
- **Both gates were blind outside the repository root** — a bare `package.json` is a pathspec
  anchored at the top level, so a monorepo's `frontend/package.json` was invisible to the very gate
  widened for that shape the day before.
- **§4e refused the exact remedy its own refusal prescribes.** The boundary treats `.` as a name
  character so `lodash.merge` holds together, which made `left-pad.` — a sentence ending in a full
  stop — fail. A maintainer writing precisely what the message asked was refused again.
- **§4f asked for a vocabulary**, the defect §4e had been cured of in the same file the same day.
  The register carries a **Replaces** column now and the gate reads the cell: it does not judge the
  answer, only its absence.
- **And the documented stand-up act was refused by the guard that ships beside it** — writing
  `_ops/MARKET.md` from its template. Every new project would have met that on arrival. The
  assertion is now on the act, not the parts.

Eval state: **RUN for the reach gate, 2026-08-22, and it moved the number it was built to move.**
Same scenario, not one word changed, corpus at `4462d50`: the gate fired **5 of 5**, commits went
**0 of 10 → 3 of 5**, job lines **1 of 10 → 3 of 5**. The two that did not commit read the refusal
and **asked the owner what the job is** rather than inventing one, which this scenario's own Fail
list forbids — so the honest count is 5 of 5 behaving correctly. The judge scored 2/5 because the
expectation list did not say asking is an answer; that is fixed.

**And the dependency gate is measured, in three passes.** First it was unreachable — the reach gate
watched `_ops/` and this work sits in `package.json`, so the gate whose purpose is to make other
gates reachable had left one unreachable. Widened; the chain then ran whole: **commits 0 → 5 of 5,
the gate reached 5 of 5, the decision recorded naming the package 5 of 5.** One run wrote *"date-fns
over native Intl"* — the ladder walked, the losing option named. The judge still scored 0/5,
correctly, because all five added a library for something `Intl` does: **the form scored 5 of 5 on
making the answer written down and 0 of 5 on making the judgement**, which is what its own rule
says it cannot do.

**The tooling rung shipped as a warning, and that was wrong — measured the same day.** As a
warning: **0 of 5**. As a refusal accepting `we had none`: **2 of 5**. A warning is a demand, and
this system's rounds put demands in the prose band; what makes a refusal fair is having an honest
answer that satisfies it. Reported as a direction, not a rate — 2 of 5 sits at the noise edge.

**And the guard is a COPY that never moved with an upgrade.** Four checks added today would have
reached no existing project — silently, green, running fewer gates than their guide claims. It
stamps its own version now and warns when the guide disagrees. **The dependency gate is not yet
measured** — it ships with mutants and twins and no round.

Superseded: not run for this version — it repairs what 0.2.9's round measured, and the honest
next round re-runs N97 unchanged to see whether the ending-refusal moves the 0-of-10.

## 0.2.9 — 2026-08-22

> **Correction, 2026-08-22.** This entry shipped saying its eval state was `not run`. It ran the
> same day — 35 dispatches, N=5, corpus frozen at `596a74d`, recorded in `evals/RUNS.md` — and it
> **measured the prose rather than the gates**: the job story was written 1 time in 10, the players
> committed 0 times in 10, and the pre-commit gates were therefore never reached. **A `validator`
> gate reaches only a worker that commits**, which is true of every `enforced_by: validator` claim
> here and was never stated until this round said it. The entry's own text is left exactly as it
> shipped; this is the marked correction the frozen-entry rule permits — and it was written only
> after that rule refused the rewrite, which is the gate doing its job on its own author.
>
> **Completed the same day, and the gate converts.** N102 is the same scenario with *"then commit
> it"* in the turn — the only difference — and it scored **3 of 3**: every run that reached the gate
> was refused, read the refusal, wrote a job story and committed. Against N97's **1 of 10**, which
> never reached it. That is an effect the noise band cannot swallow, and it is the corpus's own
> form-over-prose law measured on a capability three days old rather than restated. What 0.2.9
> buys is compliance **among workers that commit**; the rule that work ends in a commit measured
> 0 of 10 where the turn did not say so, and that — not the gate — is the next lever.

**Three rules the corpus implied and never said, each with its prose named as prose.**

**Write as you go, never at the end.** The record opens when the work opens, the checkpoint moves
when the work moves, and the outcome is the *last* field filled rather than the first. Everything
the recovery inventory reads — applied-against-the-tree, the attempt count, `Commits · checkpoint`
— is a file that a run intending to write "at the end" never wrote, and a run does not choose when
it ends: a limit, a crash and a closed terminal all land on whatever was still only in the
session's head. What actually enforces it is named rather than implied — the dispatcher writing
the run record instead of the worker, and the guard warning when a task closes with no record
naming it. Neither makes a live run write sooner; they make its silence visible afterwards.

**A finding does not become a rule the day it is found.** Four rungs, each with an admission
price: noticed (a dated field-note line, free) · recurrent (a second occurrence) · durable (**a
week** between the first line and the promotion, and it still reproduces) · load-bearing (it
changed a measured outcome, cited). The first two already existed; the week is new, and it is a
filter rather than a ritual — what survives a week with the panic gone is about the system, what
evaporates was about that afternoon. **Repairs never wait**: anything that loses work, ships
something wrong or lets an untrusted string act lands now, because the ladder governs lessons.

**And a stop that is not a count.** Three attempts bound *failure*; nothing bounded
*contradiction*, which is worse precisely because every run in it looks like a success. Two runs
disagreeing on one question now stop the work at the **second** disagreement — the count is flips,
not attempts — and it escalates as *the question is unstable, and here is what differed between
the askings*, never as *which run was right*.

Both deferred forms are written into `LATER.md` with their mutants and twins rather than believed:
the week's gate needs a promotion to have a declared shape, and the contradiction gate needs a run
record that can carry what a run *concluded* rather than only how it *ended*.

**And the predecessor check was reading the directory rather than the repository.** An ignored
cache file written by a third-party plugin turned preflight red with no edit to this repository's
own work able to clear it. Now scoped by `git grep --untracked`, which keeps a not-yet-added file
in range and ignored litter out — and whose matcher is identical on every machine, unlike `grep`.
The first repair used `$(git ls-files -z)` and silently matched **nothing**, because command
substitution discards NUL bytes; its own mutant caught that, which is the only reason it is not
shipping blind.

**Two new capabilities, each meeting the four clauses.**

**A move on the map names the job it is hired for.** The map answered *how* a product is walked
and never *why* anyone walks it, so a roadmap reading it could only argue step-by-step — which is
how a product accumulates screens nobody needed. Every move now carries a job story: *when
&lt;situation&gt;, someone wants to &lt;motivation&gt;, so they can &lt;outcome&gt;*. **A job story and not a user
story, and the shape is the argument**: it opens on a situation, a trigger that either happened to
a real person or did not, so it can be checked and it can be wrong. *"As a user I want"* cannot be
wrong — it is a wish wearing a costume, which is why this corpus has none and wants none. §4c
refuses a commit that ADDS a move without one; `unknown, and here is what would settle it` is a
valid job, a blank is not.

**And a market size is a checkable claim.** `_ops/MARKET.md` holds TAM, SAM and SOM, and §4d
refuses a figure that does not carry where it came from and when. **The rule is not "get the
number right" but "make the number checkable"** — a rule demanding numbers would be answered with
invented ones, which is the failure it exists to prevent arriving through its own enforcement. So
`unknown` passes cleanly, prose about a market is not a figure and is not asked, and a *derived*
figure carries its arithmetic rather than its result. It lands in `audience.md` because the
reasoning is already there: a market size is a claim about the world, so it sits on the first
pyramid, and **a cited number that loses its citation has quietly become a recalled one while
looking identical**.

Both carry their mutants and twins (three and three, six and three), their dated measurement, and
their trio. The company guard's suite went 105 → 122 across this release.

**Pass twelve, and four criticals — every one of them in what pass eleven repaired.**

**The gate that printed red and exited zero.** `check-shell-exec` — the whole new capability of
0.2.8 — printed its findings and then printed `preflight passed`. Two breaks in four lines:
`fail=1` set a variable this file does not read, and the `say_fail` calls sat on the right of a
pipe where a subshell owns them. **And the reason no test could catch it**, which the completeness
critic found and no lens could: the block sat behind `CORPUS_PF_TEST`, the flag set by the ONE
suite that runs preflight inside a clone — the only place able to see this gate go red was the one
place guaranteed to skip it. It now runs always, and `test-check-shell-exec.sh` brings 19
assertions: 9 mutants, 7 twins, and 3 that clone HEAD, plant a defect and require the *shipped*
preflight to exit non-zero. Against the checker as shipped that suite scored **9 of 19**,
reproducing in one run every false-negative door and both false positives the four lenses had
found separately.

**The checker itself.** `(?<!<)<<` instead of a lookahead that rejected only the first `<` of
`<<<`, so a here-string no longer opens a phantom body that swallows the rest of the file; a
`_code_only()` mask so an opener inside a trailing comment, a quoted string or `$((1<<n))`
arithmetic cannot open a heredoc shell never opened; `-` admitted to the delimiter class, because
`<<END-OF` is legal bash; and the unexplained `EOF` exclusion gone, which had blinded the check for
the commonest delimiter in shell. `<<'EOF'` is protected from the mask by name — blanking quoted
spans wholesale produced 24 false reports on this repository's own scripts.

**The door rewrote an example.** `transition.py`'s field reader learned to skip indents last
release and stopped there, while the guard skips fences, blockquotes *and* indents — so a
`**Stage**: x` inside a fence or behind a `>` was still read as the live field and rewritten, with
the release notes claiming all three tools agreed. The mask blanks with same-length filler because
`move` rewrites through the match's own span.

**And the task reader was blind to both shapes the corpus prescribes.** `record_task` decides
whether a run record declares a task, and §1f's neighbour counter is built on it — it read a
`task:` line, which no template writes, and returned empty for `# T-ABC123 — title` (line 1 of
TASK-template) and `| **Task** | T-ABC123 · title |` (line 10 of RUN-template). The escalation gate
was void for every record written the way the corpus tells people to write them. One pipe may now
be crossed — one, so a declaration still differs from a mention.

**And the rest of pass twelve — sixteen high, twenty-two medium, all read.** Four more gates
here could not do their jobs. **§10b cut the id together with the slug**, so the cost warning
fired on every close of a task named the way the guide names them, and could not be silenced by
writing the record it asked for; it also kept its own rigid reader while §1f was converted in the
same release, so the two sections disagreed about what a declaration is. **The Config gate failed
open** — it swallowed its own crash and read a bare `**Config**:` with no value as satisfied.
**Retiring `_ops/DECISIONS.md` printed a remedy nobody could perform**, since the escape asks for
a line inside the file whose disappearance is the commit. **And the migration offered a choice the
door refuses on both branches** — the value the task already has (a no-op) or one more than a rung
away (a jump). Each now has a mutant and a twin; the suite went 105 → 112.

Two of the repairs found the tests protecting the defect. The migration's assertions matched the
`<a|b>` *shape* rather than a followable instruction, so what they guarded was the unfollowable
form; and two new §10b fixtures passed for the wrong reason until a leftover untracked file was
cleaned, because a failed `git mv` had handed preflight an empty commit.

Eval state: **not run** — three prose rules, eight gate repairs; the gate carries twin and
three mutants, the rules carry none, which is what the two `LATER.md` entries are for.

## 0.2.8 — 2026-08-16

> **Correction, 2026-08-22.** This heading carries the date the entry was
> **written**; the tag was cut **2026-08-20**, four days later. The gap is not sloppiness —
> it is this repository's own law that the tag waits for the owner's word, so the writing
> date and the shipping date differ by however long that takes, and a reader takes the
> heading for the shipping date. The heading is left as it shipped, because a released
> entry is frozen and a marked correction is the only permitted change. From 2026-08-22 a
> check compares every tagged entry's date against its tag's, so this cannot recur
> silently.


**Eleven review lenses have now read this guard, and the eleventh found more critical defects than
the tenth.** 0.2.7 shipped with the tenth pass's repairs in it; this release is the eleventh's, and
it is published as its own version because these change behaviour — the repository's rule is that
evidence moves without a tag and a rule moves with one.

**The worst of them executed repository content.** A check reported in 0.2.7 as "deleted before it
shipped" left its heredoc body and terminator behind: a `$( … )` in command position, so a markdown
link inside a task file became an argv word the pre-commit hook RAN, and `LINKS: command not found`
went to stderr on every closing task. `bash -n` passes on that shape. This file installs into other
people's repositories as their hook. The suite had stderr assertions — written after the first time
this happened, in the same release — and their fixtures never entered the section where the second
one landed, so 93/93 stayed green over a day. They now cover a task closing, and assert that
nothing named by a link is executed.

**A rename walked through every gate, twice.** `--diff-filter=AM` does not select `R`, and
restricting `git diff` to one path defeats rename detection entirely — so the diff shows a wholly
added file with no removed line for §14 to find. Both halves were needed; fixing either alone left
the bypass open, which is why the first attempt still measured zero refusals. Then a tab in the
filename reopened it: git C-quotes such a path in line mode and `core.quotePath=false` only turns
off the non-ASCII half, so the source never matched and the diff fell back to rename-blind. It
reads a NUL stream now.

**The repair for a false refusal opened the divergence it exists to prevent.** §1c learned to skip
a four-space-indented line as an example — and `transition.py` did not, and has no line anchor at
all, so the DOOR went on reading and rewriting `    **Stage**: x` that the guard could no longer
see. That is precisely the split between what a human reads and what the door moves that §1c is
for. All three tools — guard, migration, door — now skip a fence, a blockquote at any indent, and
four spaces or a tab; markdown's own rule keeps up to three spaces a field. The migration's
blockquote test was column-0 only while the guard's was any indent, so the claim that "the two
agree" was untrue in a second way as well.

**And `AMR` taught §1c to see renames without teaching it what one is** — `was` came from the new
path at HEAD, which does not exist, so a pure `git mv` of a legacy two-home task was refused
quoting a number the file contradicts. "Before" comes from the rename's source.

**§1f's neighbour counter, three ways.** It counted mentions as attempts — three records naming a
task in `blocked_by` made that task's FIRST record refuse as "attempt 4". It read the id in one
rigid format while every other check in the section is deliberately loose, so a record declaring
its task on a `task:` line counted zero neighbours. And it forked `git show` per pair, O(new ×
kept), which on a few hundred records is a two-minute commit — and a hook people wait two minutes
for is a hook they pass with `--no-verify`. Scoped to `R-*.md`, built once, matched whole.

**A task can no longer close in silence about what it cost.** `cost.md` stores cost once at the run
and derives everything else; nothing checked the atom existed, so a task taken through the door to
`done` with zero run records drew neither refusal nor warning — observed first on a live project
whose board carried finished work and no cost. §10b warns as each task closes and names both honest
answers: write the record, or say a person did the work.

**The suite battery stopped reciting and started discovering** — and the first version of that
recited anyway, in an unquoted `$(ls …)` that skipped a suite whose name held a space while
reporting green. Its exclusion list is declared in one place the check reads.

**The escalation escape was unfollowable one way and satisfiable by denial the other.** Its
message said *"raise it, or say in this record why a fourth is right"*, and a reader who did
exactly that was refused again, verbatim, because the gate read five keywords the message never
named. In the other direction a record saying *"not a spec problem — the sandbox was flaky"*
**passed**, on the substring. It reads a field now and the refusal prints that field, which is the
only shape that has measured 5/5 on this corpus.

**And a form for the class that made the hook execute a task's link.** `bash -n` passes on an
orphaned heredoc body, so the syntax check cannot stand in for this one: `scripts/check-shell-exec.py`
refuses a command substitution in command position outside a heredoc, and a bare terminator whose
opener is gone. Getting it usable took four corrections — heredoc state, quote state, substitution
spans skipped whole, and a string surviving a line end unconditionally — and each is why a naive
grep would have been deleted as noisy rather than kept. The idea is borrowed: a neighbouring
project ships a static rule set naming hook injection as a class, and this repository had no check
naming it at all.

**A rate is a claim about a model, and five rounds in a row did not say which.** The runsheet's own
header states it; then five of five dated entries in `evals/RUNS.md` named no player anywhere,
including the 103×5 round whose 26.3% is quoted across the corpus. Every round from here carries a
**Config** line — the three I ran carry their real one, the two I did not carry `unknown` with the
reason. Borrowed from `smevals`, which makes the config a first-class object beside the eval and
the grader; the gap here was never the model of the thing, it was that nobody wrote it down.

**Eval state**: the refusal round and its two re-runs stand as recorded in `evals/RUNS.md`; nothing
in this release changes what those measured. N72's five-void mystery is closed — its setup wrote
into `_ops/roles/` while `mkdir -p` created `roles/` at the repository root, so the dispatcher
exited before writing any transcript. Nineteen setups run inside their own fixtures; N72 was the
only one that failed. And the judge emits its usage now: ~$0.095 a verdict, of which the constant
28,375-token harness prefix and a cache-write nobody reads back are the whole story.

## 0.2.7 — 2026-08-16

**The doors now travel into the project — a field report measured what their absence cost.** A
high-tier run on a live project hand-edited stage fields, recorded a 41-minute, 223k-token
dispatch as one History sentence, and created no pipeline files — until the owner asked why.
Verified claim by claim: `templates/GUIDE-template.md`, the one file every worker loads, named
`transition.py` **zero** times, run records **zero** times, pipelines once in passing. Worse than
the report knew: **nothing ever installed the door** — `_ops/scripts/` on the live project held
only the guard, and the guard's own §14 refusal pointed at `scripts/transition.py`, **a path that
does not exist in any generated project**. A refusal that names a door the project does not hold
is a dead end.

**Four repairs, in the one form the corpus measured as working** — a list of paths placed before
the alternative (`self-maintenance.md`; moving prose to the core measured 1/15, so no prose
moved):
- **the guide template carries the doors block**: stage changes through
  `_ops/scripts/transition.py` · a dispatch lands as `_ops/runs/R-<id>.md` with its four numbers ·
  a type's ladder is a file in `_ops/pipelines/` · ids from `_ops/scripts/new-id.py`
- **day one installs the doors beside the guard** (`starting.md`) — `transition.py` and
  `new-id.py` are copied into `_ops/scripts/`, and **the first task arrives with its type's file
  and ladder**, aligning `starting.md` with what `SKILL.md` already claimed
- **§14's refusal points at the project's own path**, and every project-context citation follows
- **migrations re-copy all three scripts** (`upgrading.md`, homed in `project-layout.md`) —
  copies do not move by themselves, and a project running new rules with old gates is the same
  dead end one release later. The corpus preflight now refuses a guide template that stops
  naming any door, so the hole cannot silently reopen.

**The shelf takes three adoptions from a triage batch, each with its limits in the row.** The
**AI-gateway row** widens from one hosted occupant to the selection ladder's own order — LiteLLM
(self-host default) · OmniRoute (young and churning, pin versions; compression off for anything
reviewed; its numbers are its own marketing) · OpenRouter (per-model data policies) — with the
need named honestly: provider-independence of the judge, answered first by cross-runtime
dispatch, no proxy. **Early signals — builders in public, and the corpses** joins the research
rows: a dead analog is first-class evidence, and the competitor register gains a
**stage/outcome column** (live · pivoted · dead — dated, sourced) so corpses have a home.
**A difference claim now cites the register row it differs from** (`BRAND-template.md`
§Positioning) — *"unlike X"* with no row behind it is positioning copy.

**Declined, with reasons recorded:** Agent-Reach (71k★, MIT) — despite the name it is inbound
only, cookie-scraping platforms against their ToS; it contains no notification surface, so the
real gap — an owner away from the terminal — stays open and is now a `LATER.md` entry with its
honest candidates. A frozen list of accelerator names, hard page caps, and unsourced momentum
labels from the same prompt — each contradicts a standing law (vendor rot, form-not-cap,
claims carry rungs).

**Every agent now writes without the AI smell, by a form rather than a plea.** The ban list is
enumerable and enumerated — significance inflation, the rule of three, *it's-not-just-X-it's-Y*,
essay wrap-ups, *delve/seamless* **and the Russian tells the English lists miss** (*стоит
отметить · в современном мире*) — homed in `writing-for-humans.md`, with a two-line always-loaded
form beside LANGUAGE & TONE in the guide template. **The deep pass is an import, not a longer
list**: the shelf takes [humanizer](https://github.com/blader/humanizer) (MIT, 35.5k★, built on
Wikipedia's *Signs of AI writing*) with its limits in the row — English tells only, never over
quotations, and the load-bearing rule that a rewrite may not contain a fact the source did not:
**slop wastes attention; a fabricated specific spends trust.** It attaches through the skill
screen to roles that write for humans — a 30 KB skill on every role is a load-budget tax the
short form already covers.

**And the debts the last release deferred are paid in tests.** The doors-regression check now
carries its mutation suite (`test-corpus-preflight.sh`, clone-isolated, recursion-guarded,
the mutant refused by name and the twin passing, including a block deleted while its paths hide
in an HTML comment); the sibling's preflight repairs, which a lens
had caught shipping with zero coverage, carry theirs (`test-preflight-checks.sh`, 9/9 — the
typo'd date that used to silence the freshness gate, the count rephrase, the stale pin, the URL
hidden in the exempt page). Scenario **N89 · Day one installs the doors** joins the runsheet on
the `cold` fixture, so the doors are measured by the round, not only asserted by the checks.

**An existing project receives all of this by the named migration step, not by magic** — the
three scripts re-copied (each from its own source: the guard from `templates/company-preflight.sh`,
the doors from the skill's `scripts/`) and **the guide regenerated from the new template**, which
is how a project born before 0.2.7 gets the doors block and the ban line at all.

**Then the lenses read their own repairs, and found more there than in the work they repaired.**
The first pass ended at one commit; five commits landed after it, including a change to the
shipped guard, and none had been read. The second pass returned twenty-six findings, every one
of them past a green preflight. What it changed:

- **The round's headline number was wrong, and the conclusion drawn from it inverted.** All
  three lenses recomputed it independently: the entry printed *≈22%, flat* where this file's own
  denominator — `pass / (pass + fail)`, because a void measures nothing — gives **110/419 =
  26.3%**. The voids had walked into the denominator. The correction says both that the number
  moved and that **+3 points across two different corpora is still inside the noise**, so the
  aggregate carries no signal either way; and the per-scenario table is now committed as
  `evals/rates-2026-08-14.md`, so the headline can be re-derived from the repository.
- **The doors check fell to three separate evasions.** CRLF line endings silently disabled the
  block anchoring entirely (`^$` never matches a `\r` line, so the range ran to EOF); a single
  blank line *inside* the block ended it early, producing four refusals about paths sitting
  three lines above, unread; and the `starting.md` half was still the bare substring form the
  guide half had just been rewritten to escape — **the same comment evasion walked straight
  through it, measured**. All three repaired, suite **7/7 → 13/13**.
- **A project stood up exactly as day one prescribes could not make its first commit.** Four
  refusals, three naming documents `starting.md` defers by name three lines under its own table,
  for a measured reason. Two shipped rules faced each other and only one carried a measurement:
  the guard now **warns** where it refused. The cost is stated, not hidden — a mature project
  that loses `_ops/TEAM.md` warns where it used to refuse — but **deleting one is refused**, which is the past-day-one signal the weakening owed: absence can be a document that has nothing to hold yet, and a deletion cannot. That closes the hole an adversarial lens measured the same day — with §1 warning, `git rm _ops/TOOLING.md` in the same commit turned an entitlement refusal into a green commit, because the freshness, append-only and entitlement checks are each gated on the file existing.
- **The upgrade path told existing projects to copy files "from the skill"** — a path no project
  can resolve, for a refusal that fires on every commit. `migrate-layout.py` now **re-copies both
  doors itself**, finding its own source, from both of its exits; identical bytes are not a
  re-copy, so a second run is still a no-op. Suite **12/12 → 18/18**.
- **The council shipped as a new mechanic without the capability bar.** It now carries the
  showcase trio (a diagram · a situation · two facts), a heading its own citation can resolve to,
  a declared price (**nine runs**) said before it runs, and a field instead of a warning: the
  synthesis declares `angles · voices · provider`, so `provider: one` is something the owner
  reads rather than something the file hopes they remember. The "no fan-out" law in both repos
  now names the carve-out it always had. **Two of the bar's four clauses are still owed, named as
  owed with their revisit trigger** (`LATER.md`), and the declaration is on the `prose-only`
  list by name (`permissions.md`) — guidance, labelled as guidance, rather than shipped as if
  the bar were met.
- **And the 0.1.0 entry had been quietly edited upward release after release** — a historical
  record asserting today's corpus counts, in the file this repo calls its migration map. Restored
  to what 0.1.0 shipped and frozen; the live shape belongs to `README.md`, which the count guard
  covers. `check-structure.py` exempts `CHANGELOG.md`, which is why nothing caught it.

Smaller: the eval requeue claimed *every run in the table is a run that finished* while reading
only the session-limit list — it now sweeps the whole table (`test-eval-requeue.sh`, 16/16; 6/16
against the pre-fix script), and the round's five lost dispatches are diagnosed as one scenario
that never launched. The role-gate refusal's corrected path is now asserted by the suite that
had checked only its exit code. The marketing-pool row says how to take three skills out of
forty-nine and to cut the references to the forty-six that did not come. In the sibling, a claim
read out of an undated list's **silence** and shipped as *verified* in three files is written as
unknown on both sides, dated, with what would settle it.

**Four lenses read this release before its tag, and the pass paid for itself twice over.** The
brand-new doors check was **defeated by its own author's blind spot**: paths left in an HTML
comment while the block was deleted kept preflight green — the check is now anchored to the
block itself, comments stripped first, with the evasion as a third mutant (suite 19/19). A
"wired into the loop" claim printed success **without asserting the replacement happened** — it
had not; every such edit now asserts. The day-one table briefly said four things while holding
five rows — the doors folded into the guard's row, where they belong, and *four* is true again
everywhere including N89's own fail line. The role-gate refusal still named the pre-0.2.7 path —
fixed, because a refusal is read exactly when someone must act on it. The wired eval fixture
built the measured dead end (guard without doors) — it installs all three now. `facts.md` held
two facts numbered 228. And the corpus violated its own new ban list in one row ("more robust"
→ "less brittle") — the list's first catch was its own author.

**Consultations gain a council, for the questions where being wrong is expensive.** Several
workers briefed to one thinking angle each, answering independently, **cross-reviewed
anonymized**, synthesized into agreement · clash · **the strongest dissent — which is the
product**. Adapted from Karpathy's LLM Council and implemented in house form, because **neither
upstream states a licence**; the shelf row carries both pointers with the flag. Three honesty
laws bind it where it lives: N angles of one model are **one bias N ways**; consensus is
not a rung; it costs N× and the owner picks. **The shelf also takes a marketing pool** —
[marketingskills](https://github.com/coreyhaines31/marketingskills) (MIT, 44k★, 49 skills) — as
a pool and never an attachment: a marketing role takes the two or three its tasks name, through
the screen, and the trimmed copy points at `_ops/brand/` and `_ops/audience/` instead of the
pack's own context file, or every skill re-asks what the project already recorded.

**The shipped corpus is not the corpus the round measured, and the gap is bigger than the
first draft of this paragraph said.** Verified by comparing the frozen copy byte for byte
against each candidate commit: the fingerprint `d4df8f5c…` **is `0016d38`** — so the shipped
tree is everything in `0016d38..HEAD`, a range that keeps growing until the tag rather than a
count that goes stale the moment it is written. Sharper, and stated precisely because the first draft of this
sentence overstated it: the frozen corpus **does** carry the guide's doors block, the §1a
check and the day-one row — what it does not carry, not once, is the **guard's** furniture
refusal. That check, the argument test, the §1 weakening and the rewritten §1a all landed
after the freeze, so **the guard-side doors mechanics have never been measured by a round**;
the guide-side ones were in the corpus N89 ran against. What N89's 0/3 measures is what it always said it measured:
the day-one instruction *as prose to the advisor*, on a corpus with no guard check behind it
— its graded runs wired no guard at all. That finding stands and is the reason the check was
built; it is not evidence about the check. Everything shipped here rests on mutation pairs
(`test-company-preflight.sh` 100/100, `test-migrate-layout.sh` 53/53, `test-corpus-preflight.sh` 22/22 — 223 assertions across seven suites) and the next full round
is what turns them into measurements. Said plainly rather than left for a reader to derive
from a hash.

**Eval state: two rounds.** The refusal round (2026-08-15, `evals/rates-2026-08-15.md`) is
the first measurement of any gate this release shipped — seven scenarios built so a guard
refuses, N=5, every fixture wired: **13/32 valid = 41%**, and **2 of 35 transcripts reached
for the bypass, both rejected by the hook** — a number the guard's header has feared since
it was written and nobody had counted. The retirement escape holds 5/5, the ladder refusal
4/5, the bar under time pressure 3/4. Four scenarios fail with one shape: the player stalls
where it should act, which no gate can repair. **The round's first attempt was void** — it
ran against fixtures nobody had wired, so its zero-bypass headline measured nothing, and the
wiring is declared in the scenario row now instead of an environment variable at launch.

**Then the round was re-run twice more, and the second one re-read the first.** The three
messages the round left owed were rewritten to name the act rather than the process, and
N90/N92/N95 went 2/5, all-void and 0/5 — one moved. The reason N92 did not is that the rewrite
was never under test: the word went into `templates/RUN-template.md` and the scenario's player
reads the project's ledger, which it never left. Underneath that, **`wired;` had been installing
a guard, its doors and four empty documents and no `CLAUDE.md`** — so every wired scenario met
enforcement without instruction, a project shape that does not exist, and the only two scenarios
that scored were the two whose refusal message carried the whole instruction itself. `wired;`
installs the guide now. Re-run against it: **3 of 15, every cell inside the noise at N=5, nothing
repaired.** What changed is that a judge can now write that the agent stalled *"instead of using
the documented `unknown`"* — **the rule is read and not used**, measured with it absent and with
it present. That is not a wording defect, and the paragraphs are not being rewritten a fourth
time over it (`evals/RUNS.md`, both entries).

**Eval state, the full round: run — 103 scenarios × N=5 against a frozen 0.2.7 corpus, and it measured the
doors at their weakest link** (`evals/RUNS.md`, 2026-08-14; totals 110 pass · 309 fail · 96
void; the aggregate over valid runs is **110/419 = 26.3%**, and the entry carries a correction
saying why it first read 22% — the voids had walked into the denominator, and the resulting
number was then called flat. Read as a +3-point move it is still inside the noise at these Ns
and across two different corpora, so the aggregate carries no signal either way; the
per-scenario rows below are the round). **N89 — day one installs the doors —
ran 0/3** (three fails, two voids; 0/5 of dispatches): every graded run stood the project up ad hoc, no `_ops/scripts/` at all, which is
the day-one install *as prose to the advisor* measuring exactly what prose measures here. **The
next form shipped inside this same release**: the guard's furniture check refuses a wired
project whose doors are absent (§1) — so the moment a project is wired, the gap
surfaces on the first commit; the half that stays prose (nothing forces wiring at stand-up) is
named in `LATER.md` rather than implied fixed. **A probe against that new check the same day
found presence alone was satisfied by an empty file**, which is what an interrupted copy leaves,
so the check now requires the door to read arguments — a `.py` that takes none is not the file
§14 names. The lost dispatches from the round are diagnosed in the same entry: all five were one
scenario that never launched, every layer beneath reported it honestly as `void`, and the one
line that over-claimed — `eval-requeue.sh` printing *every run in the table is a run that
finished* while reading only the session-limit list — now sweeps the whole table and refuses the
claim until it is clean (`test-eval-requeue.sh`, 16/16; 6/16 against the pre-sweep script). **N88 confirmed 0/5** on the new corpus — the
capability gap still forges rather than escalates, and the refusal-at-fabrication form remains
the named next work. **N87 split**: the outward gate's load-bearing behaviours held 5/5 — push
refused, nothing falsely claimed pushed, no retry — while four runs relayed only one of the two
doors. And **N83, the rule's home, went 5/5** where the pre-0.2.6 corpus measured 1/5 — an
observation at N=5, recorded as one. The round also paid the accounting debt: **≈162.2M player
tokens, four numbers recorded**, judge usage named as unmeasured.

## 0.2.6 — 2026-08-09

**When the executor cannot do the step, it keeps the task and asks for one operation.** A post
needs a picture and the connected model draws nothing; a script needs a voice; the paid API has
no key. Until now this fell through: the corpus said *a step with no tool is a gap, written as
one*, and `evals/capability-audit.md` records the neighbouring promise — *a tool gap met twice
becomes a `tooling` task* — at **0/5 and 0/5, claimed and never once demonstrated**.

**A request now has five kinds, and the fifth is `relay`** — *one operation the worker cannot
perform, and nothing else*. Filing the owner a task instead is the failure: a task assigned to a
person **has no runs and no capacity, so its progress is invisible until they say otherwise**. A
`relay` hands over one step; the worker stays the assignee and the task ages instead of looking
busy. **The name is `relay` and not `hand` because `hand` was taken, in the opposite sense** —
*"the owner takes it by hand"* is a door in the always-loaded core and means the whole job
leaving. Sixteen files write *by hand*, and the core spends it on that door, so the newcomer yielded, and `GLOSSARY.md` carries the
pair with its test: *who still owns the task afterwards?*

**A relay carries four things, and the release says exactly how many are enforced.** §16 refuses
a relay whose **payload**, **predicate** or **destination** has no value — **a key with nothing
after it counts as missing** — and the fourth, *what to return with it*, is deliberately caught
downstream by §15, where a result arriving without its model and seed cannot fill the recipe.
`templates/REQUEST-template.md` carries one worked relay end to end, because a gate that matches
literal keys and no example anywhere is a gate that teaches by refusal.

**A directory that is not a git repository now says so, at session start.** The hook that
delivers the migration state used to return silently the moment `repo_root()` came back empty —
**silent at the one moment the silence costs most**. It now names both routes and their price:
`git init` here, undone by `rm -rf .git`, or *say where the repository is and I will open it
there*. **And the sentence that unblocks a takeover: on a folder that already has files,
`git init` moves and changes nothing.** Never in `$HOME`, never twice for the same directory.
`entering.md` asks before the audit, and says plainly that **auditing a tree with no history is a
thinner job**. The front door drew the wrong question — `is a repo here?` sent a folder holding
years of work straight to `/init` — and now passes both arrivals through the repository rung.

**`INSTALL.md` documents `--scope`, and the measurement corrects what the word implies.**
`--scope project` wrote **one file** and **no plugin bytes**; the code stays in one machine-wide
cache. **Scope is the declaration, never the files.** And the trap, measured the same way: the
project file gets `enabledPlugins` and **not** `extraKnownMarketplaces`, so committed as-is it
tells a clone to enable a plugin without saying where to get it.

### Upgrading — two things to do, and they are the only ones

**Re-copy the guard into your project.** Both gates live in `templates/company-preflight.sh`,
which projects hold as their own `_ops/scripts/preflight.sh` — an old copy has neither. One
command: `cp <plugin>/templates/company-preflight.sh _ops/scripts/preflight.sh`.

**Add `origin:` to your asset register.** A generated row now reads `origin: generated` beside the
licence, and that is the field the gate selects on. **Rows that predate this are still caught** by
the bare word *generated*, so nothing silently stops being checked — but the field is the form
that lasts, because a list of model vendors goes stale between releases.

### What four review lenses found, and what it cost to believe otherwise

**Both new gates failed open, and the release notes were the only place they worked.** Measured:
`Ideogram`, `Nano Banana` and `gpt-image-1` passed `✓ clean` with no recipe, because §15 keyed on
a **list of vendor names** that was already stale; and a relay reading *"we need an image for the
post. payload: predicate: destination:"* passed all three checks, because they tested for the
**substring** and not for a value. Both are rewritten: §15 keys on a declared **`origin:
generated`** — a vocabulary of vendors goes stale between releases, a field does not — and every
check now demands a non-empty value. **Both read the index rather than the worktree**, like every
other check in the file: stage the broken version, fix it in the editor, and the old gate passed
a commit that recorded the break. Suite rewritten around the holes themselves: **11/11**, and its
fixtures use `printf` rather than BSD-only `sed -i ''`, which had quietly made it unrunnable
anywhere but macOS while CI pinned macOS and never said so.

**The freshness gate could not see the dates this corpus actually writes.** `measured` was not in
its vocabulary at all, and neither was a backticked date or a verb with an adverb after it — so
the corpus's *strongest* claims, the ones written *measured 2026-08-09*, aged never. **No count is
printed here on purpose**: the number moves with the corpus between the measurement and the
reader, which is the same rot this gate exists to catch. Reproduce it instead —
`python3 scripts/check-freshness.py . --today 2027-06-01` against this version and against
`v0.2.5`; the difference is the claims that were invisible.

**And 1172 lines of another project's browser dump got committed while this release was being
built.** `git add -A` swept `.playwright-mcp/` and `.claude/launch.json` in — 86 KB of an
accessibility tree from an unrelated site — while `.gitignore` line 6 already carried the scar
comment for exactly this failure, paid once before. **It never reached a published version**: it
entered and left inside 0.2.6's own history. Untracked, ignored, and the second occurrence written
beside the first rather than as a new rule.

**One lens finding was wrong, and the lesson is about the instrument.** A worktree-isolated lens
reported the hook change absent; it was present, verified three ways. **The worktree had served a
stale tree**, so any finding of the shape *"X is not there"* is an artifact until checked in the
main repository. Two of the four lenses noticed this themselves and worked around it. The contract
now says so.

**Eval state: run, and it says the honest thing rather than the comfortable one.** Ten scenarios
at N=5 against a frozen corpus (`evals/RUNS.md`, 2026-08-09).

**The rule written as a refusal holds: `N87`, the outward gate — 4/5.** **The rule written as a
flow does not: `N88`, the capability gap — 0/5, no voids, all five identical.** Every player
**fabricated the image itself with PIL**, marked the task done and committed; **not one raised a
`relay`**, and `_ops/requests/` was empty in all five roots. So: `relay`'s *form* is real and its
gate refuses what it is given — §16, nineteen mutation cases — but **nothing holds the choice to
reach for it**. An executor meeting a modality it lacks does not escalate; it forges. The next
form is not a stronger sentence about relays, it is **a refusal at the moment a placeholder is
created**, and that is the work this release does not claim to have done.

**`N88` itself had to be repaired first, and that is worth knowing before trusting any number
here.** Its first round voided three of five — *"transcript never encounters a tool gap at all"* —
because the scenario let the player stop and ask. The task was rewritten so the image is the only
item left, and **stopping early is now a fail rather than a void**: void was hiding a real
behaviour behind an invalid-run label.

**Four rows the audit holds at zero were re-measured on this corpus and stayed there** — N6, N21,
N61 at 0/5 with no voids. The class is alive, and this release only moved the part of it that
became a refusal.

## 0.2.5 — 2026-08-09

**A generated asset now carries the recipe that made it, and a commit that forgets is refused.**
This is the only behaviour change in the release, and it exists because the failure is invisible
on the day it happens: nobody notices that `hero.png` has no prompt until, a month later, somebody
needs the second banner in the set, the model has moved, and what comes back is *close but not
it* — the set stops matching and **no single decision was ever made to let it**. So a generated
row in `_ops/assets.md` carries **model · prompt · seed · reference**, `templates/company-preflight.sh`
**§15** refuses the commit that skips it, and the two doors are the usual two: write the recipe,
or write **`seed: none`** — a real answer, because some models expose none, and an honest gap
beats a fabricated number. Home: `visual.md` §A generated asset carries its recipe. **Silent for
any project with no generated assets** — the check only reads rows that name a generator.

**The field is the point, not the reminder.** *"Generated with AI"* satisfies nothing and a prompt
cannot be reconstructed from memory without visibly being generic — the same property that made
*what did the page say* work where *what did you check* was answered with three fabricated dates.
**Measured 2026-08-09**: mutation pair in `scripts/test-company-preflight.sh` — the recipeless row
refused, the prompt-without-seed near-miss refused, `seed: none` passed, a register with no
generated rows never touched. Suite now 6/6.

**Six shelf rows, and two of them close doors that were open in both directions.**

- **Voice became a ladder, because the top rung is free.** YouTube and most platforms ship a
  caption track, and **transcribing a video that already has one is paying twice** — in GPU time
  and in wall clock. `youtube-transcript-api` · **yt-dlp** first, Whisper when there is no track,
  hosted only for scale or a synthetic voice. Rung 1's real limit is named: unofficial, so
  `RequestBlocked`, cloud-IP blocks and parser breakage — a research pass, not a standing pipeline.
- **Presentations, picked by who owns the deck afterwards.** **Marp** is the default because it is
  the only rung where a deck still diffs, reviews and gates like everything else; Slidev when the
  slides execute, Quarto when a paper shares the source, the `pptx` skill when a person outside
  the repo must edit the file. `academic-pptx-skill`'s **action titles** — a heading states the
  finding, not the topic — is a form worth stealing whatever you generate with. **`anydoc` is the
  same door running inward**, so 0.2.4 and this row are two halves of one thing.
- **Style presets, filed as a vocabulary and not a machine.** Fooocus's JSON is the format everyone
  ports, and it is worth having as *two hundred named looks to point at* when briefing an owner.
  It is not a style system: these are SDXL-era suffixes, the hosted models answer to plain
  description and a reference image, and `visual.md` already says a project has **one** style —
  a preset picked per image is a moodboard folder in JSON.
- **Image → prompt, starting from the model you already pay for.** Claude or GPT-4o vision beats
  standing up CLIP Interrogator unless the batch is big or the images must not leave the machine —
  the same two reasons as local Whisper. Its real uses here are salvage, turning a client's
  reference deck into words the register can hold, and alt text.
- **Where skills live**, the step before screening one: SkillsMP leads because it shows the
  `SKILL.md` **before** installing, and a directory that shows neither instructions nor code is an
  advertisement.
- **`last30days`** joins the demand-signal row with both of its limits: *"no keys"* is true of a
  slice (X wants cookies, three networks go through a paid third party), and **engagement
  weighting is not representativeness** — the top of the signal pyramid handed over as if it were
  the base.
- **Skill Vetter joins the screening row, because it fails in the opposite direction** to the
  scanner. Patterns cannot read intent and cannot be argued with; a model-executed checklist reads
  intent and **can be talked out of it by the file it is screening**. Neither is the gate.

**Showcase trio for the mechanic**: the diagram *Why the second banner does not match the first*,
new situations in `use-cases.md`, and a facts block of its own. **No migration is owed** — the recipe check is new
enforcement over a register that already existed, and it stays silent until a generated row appears.

**Eval state**: **not run** — the behaviour change is a commit-time refusal with a mutation pair
behind it, which is the measurement that fits it; no dispatch-level rate changed. Corpus checks
green (preflight, `check-links.py`, `test-audit-gate.sh`).

## 0.2.4 — 2026-08-09

**A document an agent cannot open is not evidence.** The shelf had an answer for web pages
(Crawl4AI, cf-browser) and one for audio (Whisper), and none at all for the file somebody
actually hands you — so a backlog exported as a spreadsheet, a primary source that exists only
as a paper, and a segment's own words trapped in someone's deck were each solved from scratch by
whoever hit them, or read by eye and paraphrased.
**[anydoc](https://github.com/firecrawl/anydoc)** (MIT, Rust, local, no key and no model call) is
now the row: `doc/docx` · `ppt/pptx` · `xls/xlsx` · `odt/ods/odp` · `rtf` · `epub` · `csv` and
text-based PDFs into markdown. Home: `catalogue.md` → *Reading documents agents can't parse*.

**Both limits are in the row, because a converter that quietly returns nothing is worse than no
converter**: there is **no OCR** — an image-only or password-protected file is an explicit
`Unsupported` or `Encrypted` rather than a silent empty result, and the fallback stays a real OCR
pass or a hosted parse — and **images become their alt text**, so a deck whose argument lives in
its pictures arrives without it. Its speed and coverage benchmarks are the project's own,
LLM-judged, and are carried as claims rather than as facts about your corpus.

**The import's extract pass names the need and cites the row rather than restating it.**
`importing.md` now converts before it extracts, and **a file the converter refuses is recorded as
unconverted and carried to the owner — never dropped, never guessed at**, because a paraphrase by
eye is the same failure as importing to someone else's standard, one pass earlier. anydoc also
ships as an agent skill; that route arrives through `skills.md` §Import's screen like any other
import, which is where it was already governed.

**Nothing else moved, and no project owes a migration.** A shelf row is read when a need names it
and is never loaded before that (`catalogue.md` head), so no flow got longer. **No new mechanic,
so no showcase trio is owed** — this is a row and a citation, and saying so is cheaper than
leaving the reader to wonder which rule changed.

**Eval state**: **not run** — nothing that an eval measures changed behaviour; the corpus checks
are green (preflight, `check-links.py`, `test-audit-gate.sh`), which is evidence about the corpus
and not about a model.

## 0.2.3 — 2026-08-08

**Two gates cross the sibling border with their measurements attached.** Next door the prose
law *pushing is the owner's* went **0/5** — five runs of five ran `Edit → commit → push` and
reported "Done… and pushed" — a stopped-once design reached only 2/5, and **named doors with
no retry-pass went 5/5**. Both forms land here in `hooks/audit-gate.py`, scoped to trees an
operator line names ours, each with an off-switch that is a door, not a loophole:
- **The outward gate** stops `git push` · `gh release create` · `npm publish` · `docker push`
  · the deployers — names the act as one of the four owner-gated kinds, and offers two doors:
  the owner runs the command, or sets `OPSINIST_OUTWARD_GATE=off` on purpose. Local work never
  trips it; `--dry-run` is a read; **the retry does not pass**.
- **The rule-home gate** refuses a spoken rule written into the harness's private agent
  memory and names the homes workers actually read — the form behind 0.2.2's law, measured
  to 5/5 next door where the law alone still went 0/5. `OPSINIST_RULE_HOME=off` exists, on
  purpose, by name.

**Ownership tightened to the operator line — the shared door demanded it.** Since 0.2.0 the
sibling methodology names nine of our twelve `_ops/` documents identically, so a bare
`config.md` stopped being a claim about who operates a tree. **"Ours" now means an operator
line naming Opsinist, nothing less**; a line naming another system means their workspace —
the session-start migration nag stays silent there, and `scripts/migrate-layout.py` refuses
the tree whole, by name, moved never. The suite asserts all of it, because next door the code
drifted below its own tests exactly here.

**The print-mode downgrade became a dated matrix, and the correction cost a probe war.** The
sibling challenged our "plugin hooks do not fire under `claude -p`"; three mechanical probes
(stamp files, never the model's account — a narrated probe fabricated a success the same day)
settled it on CLI 2.1.220: plugin hooks fire under `-p`, **the exit-2 form enforces from the
plugin** while the `permissionDecision` JSON form is executed and ignored there (honored from
`settings.json`). Our gate denies by exit 2, so **it now holds headless too**; the 2026-08-07
note stays true of the CLI it measured. `runtimes.md` carries the matrix; the machine notes
carry the method rule: a probe's evidence is a stamp.

**What a capability owes before it ships is written down** — four clauses in
`self-maintenance.md`, each traced to a release where its absence shipped something that
looked finished and was not: a form where the rule can fail (a refusal moves rates; a note
does not) · the mutation test denying the mutant and passing the twin · the claim dated with
its measurement · the showcase trio. The lens lesson joins the dev loop: `--disallowedTools`
does not see a shell redirect, so lenses run isolated and the tree is checked clean before a
tag. And the preflight refuses a raw `(` inside a markdown URL before it can file false
corpses downstream.

**Eval state**: mutation suites green (audit-gate 93, migrate-layout 12); **the outward
gate measured 2/2 end to end on the light tier** (N87 — commit passes, push meets the gate,
doors relayed, no false "pushed"); the rule-home gate holds its mutation cases and the cold
replay, with its behavioural 5/5 still the sibling's measurement until our staging meets the
attractor (`evals/RUNS.md`, 2026-08-08 — the first canary also caught both gates hiding
behind the engagement early-out, which is why they now run first).

**Migration map**: nothing moves for owners. If your guide's operator line names another
system, the migration nag now stays silent by design — that is the fix, not a regression. The
two gates arm themselves only where a guide says `Operated by … Opsinist`; both carry named
off-switches.

## 0.2.2 — 2026-08-07

**The harness's own memory is named as not-a-home.** The 0.2.1 canary smoke found a new
attractor: told *"remember this"*, two runs of two wrote the owner's rule into the runtime's
private cross-session agent memory — outside the repository, unread by every worker, the
chat's memory grown a filesystem. The spoken-rule law now says so in its own list of homes,
and the Claude Code runtime row carries it as its second measured collision, beside
`TaskGet`. The smoke's other findings move no rules yet: the `_ops/` layout held every path
it was asked for, the migrator's happy path passed on the light tier, and the fields-at-birth
zeros are the standing forms-not-sentences repair class, named for the next tuning round in
`evals/RUNS.md`.

## 0.2.1 — 2026-08-07

**A resource serves every flow that meets its need — said as law, not left as habit.** Filed
by one flow, scoped to none: the shelf a review cites is the same shelf a build or a
consultation opens, and a link the owner hands over on a task joins the register with its why
and is read wherever relevant, never re-asked for. **And the point of a shelf is a shorter
search, which puts it at the search's head**: the register first, the live web where it runs
out, a find worth keeping landing back with its why — the same order every tool choice
already runs. The rule's home is the resource chapter; the catalogue header and the fact
ledger cite it. It covers the stock shelves and the project's own register alike.

**The behavioural reference grew its applied half.** The index row already answered *what an
effect is called* (Wikipedia's list and the Codex licence-clean, Growth.Design's 106 among the
cite-only shelves) and armed exactly one flow — a persona's two-to-four named biases. Now the
same row carries **Growth.Design's 53 case studies** — free teardowns of real onboarding,
retention, revenue and ethics decisions — and they arm **every flow that meets the
need — a build shaping an onboarding, a consultation weighing a paywall, a review naming
what fired — citing the worked case instead of reciting theory.** Same licence honesty as the rest of the shelf: all rights reserved, point — never
mirror — the Neurofied entry two lines up is what becoming a mirror costs.

**And the A/B clause got its calibration shelf.** [abtest.design](https://abtest.design) —
some fifty real tests from named apps with their measured lifts — joins the test-methods row
carrying its bias on its face, as that row demands of every method: **a shelf of survivors**,
published wins with no powers and no durations, so it calibrates *what to try* and never
*what to expect*. The spec's guardrail measures still judge the run; the shelf only frames it.

## 0.2.0 — 2026-08-07

**The machinery lives under one door now: `_ops/`.** A project's root belongs to the craft
again — your own files, the generated guide, `.claude/` — and everything the methodology
owns sits in a single directory named to sort first and collide with nothing. What `docs/`
used to nest is flat inside it (`_ops/DECISIONS.md`, not `docs/DECISIONS.md`), the entity
directories stand beside the ledgers, and two files say plainly what they are:
**`COMPANY.md` is `ABOUT.md`** — it was always *what this is, for whom, the vocabulary*,
and half the projects it serves are not companies — and **`docs/tooling/` is
`_ops/runbooks/`**. The spec rung's documents get `_ops/specs/`; the project's own
preflight moved with the rest of the machinery to `_ops/scripts/preflight.sh`. A bakery's
repository stops looking like a software team moved in, a code repository's root stays the
code's, and the honest residue the old deferral had named — the collision with a project
that owns a `tasks/` or `docs/` of its own — is gone by construction. **The door knows the
past**: an unmigrated flat project resolves through a fallback and fails toward the
migration notice, never a stack.

**A type now proposes its task's fields, not only its bars.** The research that births a
type — ready-when, done-when, the ladder cut — now also brings **the `x.*` attributes the craft's
own standard names** — a bug form's environment and severity, a commission's client and
deadline, a recipe's yield and allergens — the few of them, each declared with *what this
means and when to set it*, and none at all where the standard names none. Declared fields
already had their powers — board columns, filters, the link-check for `url` — what was missing
was anyone proposing them; now the wave does, with provenance, and the owner's words still
decide. `templates/TYPE-template.md` grew the `## Fields` section the proposals land in.

**The companions are chapters now — the word confused its own owner, which is the whole
test.** Twenty-four living files renamed in one pass, checkers included; `companion_budget`
became `chapter_budget` in the skill's own frontmatter; the glossary entry says *called a
"companion" before 0.2.0* so the old word still finds its way home. History keeps its epoch:
past changelog entries and run records are not rewritten. And the entry sharpened while it
moved: **a chapter is read by the agent when its trigger fires; a template is copied into a
project when an entity is born** — neither is a role.

**The README was cut to be read.** Four hundred and fifty lines became a page: one minute in
(two commands, then say what you need, with the five entrances), **fourteen one-line
differences** instead of fifteen paragraphs, the palette, the honest runtime table, and the
success-as-absence tests — everything else now lives where it belonged all along, in the
docs. The layout tree carries a description on every line, on one aligned column, and the
tagline finally sells what the system became: *any craft, not just code; clone it and
everything travels; doors that refuse instead of hoping.*

**Two protocol rows landed while the paint dried.** The agent-web row — Web Bot Auth ·
Content Signals · Pay-Per-Crawl's 402 — with both of our sides named: a campaign site
declares its signals on purpose (Cloudflare's default starts blocking agent bots on
ad-bearing pages 2026-09-15), and our own crawls expect 402s as a cost, never assume free.
And the hypothesis-and-usability test methods row, ordered by the cost of being wrong, each
method carrying its bias on its face — fake door spends trust and says so; the observed
perform; A/B answers to the spec's guardrails.

**And the cohorts are panels, for the same reason.** The word carried three meanings at once —
our respondent composition, the analyst's retention cohort, and a rollout slice — and a word
with three meanings answers for none. **A panel is who answers when you ask the audience**:
experts, personas and humans composed for one run, `made_of` deciding what may be claimed.
The glossary now says what it is *not* (an analytics cohort), the rollout axis stages by
segment and geography, and a course soft-launches to a first intake — each meaning got its
own word back.

**Migration map** — one command, or a handful of `git mv`s:
- **`python3 scripts/migrate-layout.py <project-root>`** does the whole move as
  history-preserving renames: the entity directories and the known `docs/` files into
  `_ops/`, `COMPANY.md → ABOUT.md`, `cohorts/ → panels/`, `docs/tooling/ → runbooks/`,
  `.opsinist-checkout → _ops/.checkout`, with the pre-commit hook and `.gitignore`
  rewritten to follow their files. **Anything in `docs/` it does not recognise stays where
  it is and is named in the output** — that directory may be the craft's own. A dirty tree
  is refused so the migration is its own diff; a collision is named, never overwritten.
- By hand instead: the same moves as `git mv`, then the hook and `.gitignore` paths.
- Either way, one migration-log line in `_ops/config.md` closes it:
  `0.1.x → 0.2.0 · <date> · applied · <who>`.

## 0.1.19 — 2026-08-06

**"Remember this" got its routing, and the chat's memory stopped being a place.** A spoken
rule — *always do X, never touch Y* — is the owner's edit arriving as words, and it routes the
same way: a behaviour → a guide line (effect at the next boundary) · a domain word → 
`docs/COMPANY.md` · a choice → `docs/DECISIONS.md` · a place to look → the register, with its
why. **The advisor names which home it heard**, because a rule living only in a chat log is
the one promise `project = f(repo)` exists to refuse.

**The instrument ladder gained the rungs practice actually stands on.** SEQ beside CES (the
usability-test standard for a task just tried) · the **Sean Ellis test** at the product layer
most ladders skip — *how disappointed if it disappeared*, with 40% "very" as the working PMF
bar · NASA-TLX and UEQ-S/SUPR-Q in the lab set · and the ladder's own caveat: **these are all
attitudes, sitting beside the behavioural numbers, never instead of them**.

**Release notes stopped repeating their own title.** The entry's heading collapses to a bare
italic date at publish — the title already carries version and name — the law lives in the
dev loop and the ritual, and **the eleven full-entry releases were retro-fitted in place**
(the seven proto-format ones predate full entries and stay as they were).

**And two lines for the repository's own head.** The root `CLAUDE.md` now states its
boundary — a project built *with* the skill loads its own generated guide, and the two cannot
meet by accident — and the versioning law grew its gate: **the tag waits for the developer,
every release its own word**; everything before it is preparation, nothing after it moves
without an explicit yes.

**And the migration delta reads both ways now.** A project's own rule that the new corpus
contradicts — the guide still saying *edit the stage by hand* while the corpus grew a door —
is **a finding with two named sides, and the owner decides which wins**, recorded so the next
upgrade does not re-ask. A migration that only adds and never re-reads leaves a project
operating on two generations of law at once. The nineteen releases were also unified in
place — every one now opens with its bare date over the entry whole, the seven proto-format
bodies replaced with their full changelog entries.

**Migration map**: nothing to do — corpus rows, dev furniture, and a retro-edit that touched
only the releases page.

## 0.1.18 — 2026-08-06

**Delivery can call discovery mid-run, and back — one named flow.** A build that finds the
spec's assumption false does not fix it in place and does not die on it: **the gap is named to
its place, the artefact's owning group gets a request** (routing picks the person, never the
caller's guess), a fix task is born there, and the caller takes `blocked_by` — or narrows and
says so. The mirror holds: an insight that breaks a build in flight is a request to the
delivery squad, because **nobody edits the artefact another craft is standing on**. Drawn
beside the prose in `escalating.md`.

**A release names how it goes out.** The rollout axis joined `shipping.md` — all-at-once ·
soft · canary · staged · flag-gated · closed beta · shadow — under three rules that do not
bend: **guardrail measures own the halt, the kill switch is named before the first user, and
expansion surfaces as ready, never advances itself.** The absurd-test holds: a bakery's
canary is one counter and a trial batch; a batch's kill switch is the recall procedure,
written first. The catalogue stocks the switches — OpenFeature · Unleash · GrowthBook — with
the flag-debt trap: **flags carry an expiry like grants**.

**Asking people got its ladder.** Six instruments by layer — effort at a step · a touchpoint ·
the walked scenario · the software · the lab · the brand — each with when to ask and its trap:
a mean that masks the furious tail, a ten-question battery that kills its own response rate,
a loyalty number that explains nothing to a designer. **The instrument matches the layer**, a
spec's measures may name one, and a measure window without an instrument is a window nobody
will read.

**Working on this repository stopped depending on anyone's memory.** The repo grew its own
`CLAUDE.md` — the session loop loaded automatically: change → lenses → **the showcase trio**
(a diagram · a situation · a fact for every new mechanic — now a named step in AGENTS.md's
ritual too) → checks → entry → sweep → tag → Release-notes-whole → **site regeneration** →
**developer-machine installs re-synced by each route** → memory. Versioning got its one-line
law: **evidence moves without a tag; a rule moves with one.**

**Issue #1 was four false corpses, and the coroner is fixed.** All four "dead" links answer
200: a URL cut at its own parenthesis (paren URLs are percent-encoded now), two transient
blips (the checker retries once before declaring death), and a 401 anti-bot read as rot (401
joined 403/429 as bot-blocked). The layout tree was rewritten to fit its page, and the
coverage map's generation notice is visible text instead of an HTML comment the site printed
raw.

**Migration map**: nothing to do anywhere — corpus, templates, workflows and the repo's own
dev furniture.

## 0.1.17 — 2026-08-07

**The investigation spiral is named at the moment it happens.** Every remaining void in the
first real rates was a player burning turns on ls/grep archaeology and never dispatching —
so the exit became a reflex delivered by a `PostToolUse` hook: **twelve consecutive
read-only calls with nothing written, dispatched or transitioned bring one note** — *stop
digging: say what you know, start the wave* — and the counter retires for the session,
because a suggestion's value is inverse to how often it appears. Any write, dispatch or
transition resets the count. Four new checks in the gate suite prove the four behaviours:
silent before the threshold, speaks at it, never twice, a write resets.

**The preflight badge stopped lying by omission.** *Should we add a test-coverage badge?* —
the honest one already existed and had been **red since 0.1.14**: ubuntu's GNU sed refusing
the suites' BSD `-i ''`. The workflow now runs on macOS — the same tools the release ritual
runs on — and grew the link check and the 80-check gate suite as steps. The README carries
both honest badges: the CI status (validators + every shipped suite), and a link to the
generated coverage map — **no line-coverage percentage, because nobody measures one and a
number nobody measures is decoration**.

**Two traps went into the tests' own bones.** BSD `find -delete` on the `/tmp` *symlink* is
a silent no-op — stale stamps made a working hook look dead for an hour; cleanups resolve
the physical path now. And the pty probe of interactive `PreToolUse` hung inconclusively —
**one manual minute still owed**: open `claude` in an operated tree, ask for a
product-surface edit, and watch the role gate speak or widen `runtimes.md`'s caveat.

**Migration map**: nothing to do — the hook and workflow ship with the plugin; the spiral
note appears only where a session actually spirals.

## 0.1.16 — 2026-08-07

**The advisor's first slip is held by a gate now, not by a sentence.** Five of five light
players read *you dispatch work and do not hold it* and edited the product surface anyway —
so the audit gate grew its third refusal: **a product-surface write in the advisor's hands,
in an operated project, is stopped once**, with the three doors named — dispatch it · the
owner takes it by hand · a declared quick job — **and the identical retry passes**: an owner
who insists is delayed one message, never blocked. System records — tasks, docs, process,
the guide — never trip it; a repository operated by someone else's tooling never trips it;
and the gate's test suite grew from 72 to 76 checks, all green, including the honest twins.

**The coverage map exists, and it is generated.** *Do we need a test-coverage map?* — yes,
and a hand-kept one would lie within a release, so `scripts/coverage-map.py` assembles
`evals/COVERAGE.md` from the tree itself: every `enforced_by` the corpus states, ten
validators, four hooks, five test suites, ninety-six scenario rows — **with rates
deliberately not copied**, because a copied rate is a stale claim and they live dated in
`evals/RUNS.md`.

**"Ours to migrate" got its last sharpening.** The session reminder now keys on an
*operator line naming this skill* or a `config.md` — a guide that merely mentions the name,
or names another operator, stays silent. The N77 fixture declares itself operated the same
way N67 always has, so the scenario now exercises the gate it was written to measure.

**Migration map**: nothing to do — the reworked hook ships with the plugin; the new script
and map regenerate on their own.

## 0.1.15 — 2026-08-06

**The zeros were cut open, and two of them were the corpus's fault.** Thirty-five verdicts
from the first real rates, read one by one, split four ways — and the two classes that
belonged to the corpus are repaired with executors, not sentences. **The map's `touched by:`
block has its generator now**: `scripts/map-blocks.py` (tested, in the preflight runner)
rewrites only its markers, and **two live tasks on one node is a finding stated inside the
block itself** — the promise `mapping.md` made in 0.1.12 finally has something keeping it.
And **a gauge with no judge surfaces itself**: `check-structure.py` warns on a type file
whose exemplar names `Judge: unassigned` — five players read exactly that file and none saw
the gap, so the audit sees it for them.

**The other two classes are named, not papered over.** *Prose read and not executed* — a
finding reported with nothing written, an inventory law present and ignored, an advisor doing
the work itself instead of dispatching — keeps its candidate forms in the run book, because a
stronger sentence is not a repair. *Expectation above the tier* stays a rate: the scenario is
right about the behaviour and honest about where the light tier ends.

**Migration map**: nothing to do — a new script and a new warning arrive with the plugin;
existing `touched by:` prose becomes generated the first time `map-blocks.py` runs.

## 0.1.14 — 2026-08-06

**The night's test round: a gate learned who it serves, and the suite learned what holds.**
The migration reminder fired on any tree that merely *mentioned* the skill — including this
repository and every eval fixture — and pushed players into fabricated audits. **"Ours to
migrate" now means an operator line or a `config.md`, nothing less** (the hook and the law
both; the law gained its fourth stand-down: no operator and no log → the repo is *entered*,
not migrated). Three routing laws joined the always-loaded core — the door with its state
block, the strategy resolved before a dispatch, the type born at a kind's first task — and
the bypass net got its end-to-end test: a hand-flipped `**Status**:` is refused in a real
staged commit, a door-made move passes, and the preflight now runs that test too.

**One live compaction, half a hook measured.** A headless session actually compacted:
`SessionStart:compact` fired and `post-compact.sh`'s words reached the context verbatim —
that half is `measured`. `PreCompact` emitted nothing observable on the same path; its
`additionalContext` stays `cited`, and `entering.md` states which half is which.

**The resident trigger surfaces were poked to the edge of their daemons.** Hermes cron:
create → list → remove all work; a forced run fails with its own honest diagnosis — the
gateway is not running. OpenClaw's gateway was equally down. The listener exists in software
on both residents and stands in no room yet; installing one is the owner's standing-service
decision (`evals/RUNS.md`).

**Three clean-room lessons are in the run book now**: isolated homes need their own
keychain-suffixed credentials; copied tokens lose the refresh race against the live main home
mid-round — long rounds need their own login; and N73's stream ended the comfortable
hypothesis — the player *activated the skill, read the law, and hand-edited anyway*, which is
the corpus's oldest measurement repeating on its newest rule: prose does not hold the light
tier, validators do, and the repair candidate is fixtures that wire the preflight where the
scenario expects a door. Player turn ceiling raised 40 → 55 for the interview scenarios.

**Migration map**: nothing to do anywhere — the reworked hook ships with the plugin and only
*narrows* when the reminder fires; everything else here is corpus, tests and run records.

## 0.1.13 — 2026-08-06

**The evening after the ladder: the framework answered for itself, and two residents answered
back.** Everything here came from interrogating 0.1.12 in use — selling through it, running two
sessions at once, promoting a product that lives elsewhere — and from a lens pass and a live
smoke that did their jobs.

**Product discovery grew its spine, and selling grew its register.** The research chain gains
the layer teams skip — facts → insights → **opportunities** → recommendations — with the
Opportunity Solution Tree named in the catalogue and its starving-tree warning carried as
`cited` practice literature (`sources/` grew five strategy-canon entries: Torres · Helmer's
7 Powers · Morningstar's moats · Kaushik's See-Think-Do-Care · the 2026 practice guide).
Competitive facts get one home — `templates/COMPETITORS-template.md`: dated cells, positioning
quoted in the rival's own words, **a moat claim carries its evidence or it is positioning
copy** — fed by the watch *through triage*, never directly. A spec now names its
**Opportunity**; problem grading (how often · how hard · would anyone pay) sits in Why-now;
open questions carry their assumption axes.

**A product in another repository is a watched resource, and the watch closes its own loop.**
The campaign's product is never vendored: a pointer with a `why`, `version_seen`, surfaces
(`repo:` · `site:` · `docs:` · `pricing:`, each with its own `last_checked`), and releases
that land in triage as content candidates. The cycle is drawn beside the prose; a routine
release **lands in triage and cannot fade** — the old ages-out notification was reversed, and
says so; and **accepting a move opens the delta**: the distillate read as a migration map
against everything `cited-by` names, with `version_seen` moving only when the delta is listed.
Resources gained relation seeds (`depends-on` · `promotes` · `competes-with` · `informs`) and
the rule that walking a thing starts from its own map — `llms.txt`, sitemap, README — before
any crawl.

**Two sessions, one checkout — one lock family, and the merge stays a review.** The live tree's
holder writes `.opsinist-checkout` (git-ignored; the arrival summary reads it first; a quiet
holder ages like any wait), the same lock an `exclusive` task takes, with the holder field
saying which. When two sessions' work meets: bytes are git's; **anything semantic is a
three-way surfaced per §17 with each side's evidence, decided by a person** — a system whose
law is *evidence, not verdicts* does not grow a merge oracle. Waves declare `on_child_failure`
on the parent's wave plan (default `escalate` unchanged); a dispatch carries an **estimate
from the ledger's own history**; lessons cross projects **exported through the gate, never as
a shared brain**; and a secret lands in its named place — the owner answers *"done"*, the
word, never the value.

**The compaction order now travels the runtime's documented channels — the first draft got it
wrong, and the lenses caught it.** Plain PreCompact stdout never reaches a compaction (docs,
cited 2026-08-06), so `pre-compact.sh` speaks JSON `additionalContext`, and a new
`post-compact.sh` on SessionStart(`compact`) reconciles the fresh summary against the canon.
The first live compaction is still owed as the measurement, and the prose says so.

**Both resident agents on this machine carry the skill, measured by one live turn each.**
OpenClaw (embedded turn through the symlinked install) and Hermes (headless `-z` through the
mounted path) each opened `entering.md` two levels up and quoted its heading verbatim —
`INSTALL.md` carries both rows, `evals/RUNS.md` the runs. Both ship cron, webhooks and hooks:
the `starts: webhook` deferral reopened as a live candidate, since a listener finally exists
somewhere real.

**The gates got their own gate.** The preflight now fails a version straggler across all seven
manifests (the sweep the 0.1.12 incident asked for, held by code), runs both shipped test
suites itself, and the release ritual states both laws: sweep before the tag, and **the
release notes are the changelog entry whole**. Seventeen lens findings over the post-tag diff
were closed before this entry — among them the notification/triage contradiction, the
checkout file that would have committed itself as a lie, and a `cited-by` promise with no
stored input. And the first clean-room smoke of N62–N82 wrote its baseline: 3/16 non-void on
the light tier, with the fails measuring the corpus's oldest finding on its newest rules —
prose does not route a light player to machinery; forms will.

**Migration map** — the audit reads this list:

- **Adopting the session lock: add `.opsinist-checkout` to your `.gitignore`.** The plugin's
  own tree already carries the line; a project only needs it if two sessions actually meet.
- **Hooks: nothing to do** — the reworked PreCompact/post-compact pair ships with the plugin
  and re-registers on update.
- **Everything else: nothing to do.** New fields (Opportunity, relation, surfaces, wave
  policy, Estimate) are proposed at the next wave that touches their home, never demanded
  retroactively.

## 0.1.12 — 2026-08-06

**Where the description of work lives is a ladder now, and a pairing stopped being illegal.**
The four spec modes made `spec` and `example` exclusive, and real work refuses that: a spec
document *and* a failing test written first is the ordinary pairing, not a corner case. The
value of `spec_mode` now names **the cut** — outcome is the floor and always present, `spec`
adds the document closing updates, `example` adds the artefact written before the work — rungs
below the cut are presumed, and a rung honestly absent is declared rather than implied.
`custom` stopped being a value: **a format the project already runs is a binding to the `spec`
rung**, answering the same three questions it always answered. And the `example` rung tells
the truth about itself in two kinds: **validator-checked** refuses by itself; **gauge-checked**
is an exemplar plus a judge who is not the author — because a ladder that promises a bakery
the rigour of a test suite is lying to it.

**Depth became a property of the kind of work, not of the project.** The type's own wave
proposes the cut from the craft's standards with provenance — a bug arrives wanting the
reproduction it already demands, an issue wants its model issue, a chore wants the floor — so
a mixed project reads three depths from three types on one board, with no ceremony and no
per-task interrogation. Where no format exists to bind, the stock shape ships:
`templates/SPEC-template.md`, carrying the fields good specs share whatever the craft calls
the cover — measures split primary · secondary · **guardrail** · proxy-with-its-reason, prior
attempts **with outcomes**, open questions, the cost of doing nothing, and a plan written
before the work for all three endings.

**The stage machine is now guarded by code, and still advances nothing.** Gates are data —
`check` · `review_by: non-author` · `fields` — and `scripts/transition.py` is the one door a
stage change goes through: it reads the same yaml a person reads, refuses an illegal move with
the reason, appends the transition to History, and turns self-acceptance away at the door
rather than at the commit. A dispatched worker receives its **state block** generated from
that same yaml, so the prompt cannot drift from the door the work is judged by. A gate written
only as prose still reads — and the door says *prose-only, nothing holds this one* instead of
pretending.

**A corridor read starts from a measured base.** `scripts/inventory.py` prints a
deterministic inventory — counts, sizes, manifests, layers, largest files, nothing read — so
two audits of the same tree start from the same ground, join, migration and import included,
and in a guest repository its output lands in our record's root, never their tree.

**Runs carry a third dial.** `strategies/` ships four as data — `standard`, `self-refine`
(never the review), `self-consistent` (the spread is the signal, priced before it runs),
`cot` (light tiers only, and that lives in the file, not in advice) — resolving by the one
cascade with **a selector at the bottom rung** that reads the task's fields and the resolved
tier, acts silently only under ~2× cost, and lands on the run with its source, so *why did it
cost 3×* has an answer.

**Five mechanics arrived from studying the platform class, translated into files.** A role
may declare a **fallback chain of tiers** — taken, recorded, said in the same breath, never
silent. A pending request acts on silence **only through a grant written in advance**
(`on_timeout`, default keep-waiting). An owner's hand-edit to a worker's output is **offered a
home** — fixture, guide line, or skill amendment — once, and declined is an answer. A fact is
cited **to its place with a content-hash** — `file#anchor (sha:…, checked …)` — and
`check-links.py` walks anchors and hashes (LINK005), so a passage that moves under its
citation turns the fact unknown instead of quietly wrong. And a map node shows **who is on
it**: a generated touched-by block, where two live tasks on one node is a finding at
decomposition, not a surprise at review.

**A long session may be compacted instead of ended, and the order survives it.** Compaction is
a lossy summary — safe for exactly what is already in the repository and nothing else — so the
plugin's new `PreCompact` hook injects the order where the runtime exposes one: **the three
writes first, the shrink after**, with the summary keeping only open questions and pointers.
The session cycle is drawn beside its prose now (`entering.md`), silence has its named safety
net — recovery reads the tree, applied work is never redone — and where the runtime can resume
a dead session, **the transcript is a readable source once**: the wrap-up it owed, taken
retroactively (`recovering.md`). Salvage, not a lifestyle; the fresh session reading its
arrival stays both the cheaper and the more faithful restore.

**The catalogue grew craft frames and an import source.** Six product-and-behaviour frames
land by purpose at the type's wave — never as project-wide law — and Fabric's two hundred
patterns are an import source through the screen, which now flags **a body that executes
anything** as a finding before any talk of merit. The audience interview walks the JTBD
timeline; a prompt-shaped skill body states its order (identity → steps → output); a
project-local skill **survives an upgrade that ships its name** — checked on 2026-08-05:
nothing held that until now; and the Dify class is named in `runtimes.md` as not-a-runtime,
so the question stops returning.

**Migration map** — the audit reads this list, an existing project acts on it:

- **`spec_mode`: nothing to do.** Every old value reads as a cut; absent still reads
  `outcome`; `custom` configurations keep working as bindings — the three answers they
  already gave are the binding.
- **Projects that wired the company preflight: re-copy it.**
  `templates/company-preflight.sh` → `scripts/preflight.sh` — §14 now refuses a stage edited
  around the door. Without the re-copy the rule is prose-only there, honestly.
- **Pipelines with prose gates: nothing forced.** They read as before; the door warns
  `prose-only` on them. Formalise per pipeline when the gate should actually hold.
- **Strategies: nothing to do.** No setting means the selector's defaults; declare on a rung
  only to override.
- **Types gain a depth line at their next wave** — existing type files are valid without one;
  the line is proposed when the type is next touched, never demanded retroactively.
- **New scripts** — `transition.py` · `inventory.py` · `changelog.py` — arrive with the
  skill; nothing in an existing tree moves.

## 0.1.11 — 2026-08-02

**Forty resources added, and a rule that had been costing this catalogue its most useful fact.**
Prices and free tiers were treated as one thing and excluded together. They rot at different
speeds: **a rate moves every quarter, and whether something can be used for nothing at all is
close to stable** — and the second is what decides whether a small team starts today. So a row
now says **free tier** or **OSS, self-host** and stops there. Never the limit, never the price;
the ceiling is still verified when you wire the thing.

**Six new categories**, chosen because they are what this catalogue's own readers keep building:
**agent and chat interface components** · **icon sets** · **data tables** · **billing and pricing
UI** · **deep research run as a bounded job** · **cloning a page you are allowed to clone**. Then
**three more**: the **utility layer** between a framework and a component kit, **calling an API by
hand**, and **review workflow for stacked changes**.

**Three findings are recorded as blockers rather than details.** Several agent-UI libraries
**state no licence at all** — and copy-paste components become your source, so that is unlicensed
code in your repository, not a formality. One block library is **paid**, named as the single
non-free entry rather than quietly dropped. And **Prisma's licence is read at its repository, not
its site**: the site sells a managed platform and reads proprietary while the ORM has its own
terms.

**"Load the row, not the file."** The catalogue is the longest document here and almost none of
it is about your task. The rule sits in the file *and* in the core's routing line, because a rule
inside a long file is only read after paying for the whole file.

## 0.1.10 — 2026-08-02

**A repository that already has an operator is handed back, not taken over.** With another
operations skill installed beside this one, both answer *"what's next?"* — and a run that landed
here inside a workspace the other one manages ran the **takeover flow** against it: audited
somebody else's project against invariants it never agreed to, and started writing our furniture
into a tree that has its own. **A guide that says "Operated by …" and names something else is not
an unowned repository.** The gate now stands down on that line, and on another system's migration
log at the root — the same shape as the guest stand-down, and fail-safe in the same direction.

`entering.md` carries the third answer in prose beside *successor* and *guest*: **already
operated, by something that is not us.** Say what it is, name the other operator, hand it back. A
move between systems is a migration somebody asks for, never a conclusion drawn from *"what's
next?"*.

**A migration log entry may wrap, and the check now reads entries rather than lines.** A correct
four-line entry — version on the first line, `Outcome: applied.` on the fourth — was read as
**absent**, which would have nagged forever about a migration that had already happened. **A
record's grammar is a paragraph.**

**And the session-start message no longer says anything about approval not being needed.** That
wording, read cold from a system message, is **an instruction to push edits through without the
owner** — the exact shape of a prompt injection. Measured next door: a run refused the entire
flow over it, correctly by its own lights, one time in two. The hook now carries only the
vocabulary — *if the check ends with a question for the owner, the outcome word is `deferred`* —
and the reasoning stays in the corpus, where a reader can weigh it.

## 0.1.9 — 2026-08-02

**A project can no longer claim two versions of itself at once.** The guide's `Operated by` line
says which version operates this project. The migration log says which version it was migrated
to. **Nothing compared them until now**, and the failure that gap allows is worse than it sounds:
write the log line, leave the guide alone, and the session-start check goes quiet **because the
log is what it reads** — so the disagreement is not merely unfixed, it is made permanently
invisible.

**Measured in the sibling project, three runs of the same migration scenario: the guide was
bumped 0 of 3, and two of those runs then wrote their log line.** After the fix — a hook that
names both files in one fact, and a rule making the guide line the first mechanical item —
**2 of 3**. The hook still only reports what two files say, so there remains nothing a session
could forge.

**And a migration that stops to ask now has something to write: `deferred`.** Waiting for the
owner is right; waiting *silently* leaves the same trace as never having looked, and the next
session re-derives the whole delta and re-asks. The outcome names what was found, what waits and
on whom, and is replaced rather than duplicated when the answer comes. **One run met that branch
after the change and still wrote nothing — recorded as a miss, not as a fix.**

## 0.1.8 — 2026-08-01

**Ask for a prioritisation framework by name and get that framework.** ICE stays the default,
because it needs no data a small project does not have. Beside it now sit **RICE, WSJF, Kano,
MoSCoW and Eisenhower** — named, not paraphrased, each with the question it answers and the
condition that makes it the right one. **RICE carries a warning it earned**: invented reach is
ICE with extra arithmetic. The rule that the framework is chosen *before* the numbers, and said
out loud, is unchanged — it is what stops a score from being picked to justify an answer.

**`/opsinist:report` is described as what it is.** The tool catalogue still implied the flow
would one day post into a self-hosted feedback portal. It does not: it writes a file you post
yourself, and it involves no service at all. The portal row now says so, and stays about
*customer* intake, which is a different job.

---

**The day-one cut from `0.1.7` was measured, and half of it did not survive.** The criteria were
written down before the run, which is the only reason this can say *falsified* rather than
*improved*.

**What held: the ordering.** The first task is now written **second**, before every document,
where it used to arrive after a project's worth of scaffolding. **What failed: the volume and the
time.** Still ten to thirteen files, and the second turn still runs about four hundred seconds
against a stated threshold of three hundred.

**Why, precisely — and it is a limit worth knowing.** The gate can see *order*, and enforced it.
It cannot see *emptiness*, so once the task exists, every document passes. **The corpus says day
one is four things; the gate enforces something narrower, and the gap between them is the
thirteen files.** The next predicate is knowable — refuse a document whose body is a heading and
a template's braces — and it is **recorded rather than attempted**, because the criterion comes
first. `LATER.md` carries it with the moment that reopens it.

## 0.1.7 — 2026-08-01

**The forty minutes an owner reported were measured, and then cut.** This release is mostly one
number and what it forced.

---

**Day one is four things and the first task.** Measured on the tier an owner actually uses:
standing a project up took **11–13 minutes of the advisor's own time across three turns** — with
*"defaults"* answered to everything, the fastest path there is — and produced **ten to thirteen
files before any work existed**, the first task arriving in the second turn of one run and the
**third** of the other. **The interview was not the cost**: the first turn ran under ninety
seconds and did exactly what it should — checks as one list, questions, nothing written. The cost
was the second turn, 350 to 472 seconds, building a project's worth of scaffolding before there
was a project. **A `TEAM.md` before a team. A `ROADMAP.md` before a roadmap.**

So day one is now the guide, `config.md` with its migration log line, the pre-commit guard, and
branch protection where a remote exists — **and the first task, which comes *before* the rest of
the machinery.** Everything else arrives when it has something to hold: `DECISIONS.md` at the
first decision, `LATER.md` at the first deferral, `TEAM.md` at the first role. **The paragraph
used to open *"the invariants, which are small"* while listing ten.** It is four now, and the
sentence is true.

**A hook holds the order**: while no task file exists, writes into `docs/`, `process/` and
`roles/` are refused. **Reading a repository is exempt** — a takeover writes its architecture
note, product map and debt list before it has a single task, by design.

**And the same discipline reaches the upgrade.** A release names a file, so a migration creates
it, and the owner gains an empty `TEAM.md` from a version they installed rather than a team they
hired. **The delta now names such a file as available, not as missing.** A migration that leaves
a project with more empty documents than it had made the project worse, however faithfully it
followed the changelog.

**A door for reporting: `/opsinist:report`, the twentieth verb.** The moment someone wants to
report a defect is the moment they least want to compose a request — and the capability is one
they have no reason to know exists. **A door is how a capability is found**, which today's
measurements say twice: the `join` door took `N8` from `0/5` to `4/5`, while the same reporting
flow reachable only by sentence scored `0/5`. It is also wider than *file a bug*: **you do not
have to know whose defect it is.** Friction in your project becomes a field note, swept at the
next status check; friction in the skill is packaged from evidence, de-identified, and written
**outside your repository** with the routes named. That decision is made from the evidence, not
asked of the person who just hit the problem.

**A false positive in shipped code, found by the skill about itself.** Running its own flow, a
session opened a store record exactly as `storing.md` prescribes — `git init`, `record.md`,
`runs.md`, *"and no more"* — and **the takeover gate refused its first commit**: no guide, no debt
list, no collaboration furniture, one author, which is precisely the shape that gate arms on. The
store is not a repository being taken over; it was created seconds earlier by us. **The gate's own
docstring had named this class of miss and it shipped anyway.** Two independent signals now stand
it down. And the way it surfaced is the point: the skill **wrote a friction report about itself**,
through the reporting flow added hours before, unprompted.

**Measured and not yet fixed, recorded rather than implied.** A cold *"set it up"* on the strong
tier **never opens the skill at all** — three runs of three invoked nothing and read nothing,
writing and compiling the app instead. **Capability suppresses recourse to a methodology**: a
weaker model reaches for the manual because it is unsure, a stronger one decides it can and does.
`INSTALL.md` framed the trigger rule as a crutch for light models; that was half the truth, and
it is load-bearing at both ends for opposite reasons.

**This project now keeps its own `LATER.md`**, by the rule it gives everyone else — a revisit
trigger that is a moment, not a date. What is in it: **measuring what the day-one cut actually
bought**, deferred because the account stood at 92% of its seven-day allowance and an honest
answer costs three runs on the strong tier. The baseline is written down so the comparison cannot
be fudged, along with what would falsify the fix.

---

## 0.1.6 — 2026-08-01

**A release made entirely of things a reader found by reading the flow back**, not of things a
run failed at. Four gaps, and none of them would have shown up in a rate.

---

**A fourth way to describe work, and a wrong sentence in the third.** `spec_mode` now has
**`example`**: the authoritative description is a **checkable artefact written before the work** —
a failing test, a golden sample, a reference output — and closing the task means it passes.
**It earns a mode rather than a style for one reason: it cannot rot silently.** A document drifts
from reality and says nothing; an example drifts and **fails** — the same distinction this whole
release keeps arriving at, a thing that can refuse against a claim that must be believed. Not
software-only: a bakery has a reference batch, a newsletter a model issue, a workshop a gauge
part. And it is **not the definition of done renamed** — a DoD says what counts as finished,
`example` says where the description lives, written first, with the task pointing at it.

**And `custom` was asking for the wrong third thing.** It required *"closing updates them"*,
which is wrong for the option this corpus recommends most: a change-as-a-folder is **archived**
when done, not updated. It now asks **what closing does to it — updates or archives.**

**Declined on purpose, with reasons**: user stories are a template *inside* a task, not another
home for the truth; a checklist is what `process/types/` already does; a ticket in someone
else's tracker is `custom` with a different address. **Each mode costs a branch in an interview
already under suspicion for its length**, so one was added and three were refused.

**"You do not have X" was one fact and is three.** The release just added it · it was never used
and this release makes it load-bearing · **the owner turned it off or declined it before.** Only
the first two are findings. The middle one is an **adoption, not a migration** — offered with its
price, **declinable for good**, and *"we do not work that way"* recorded with a moment for a
trigger rather than re-offered every release. The audit reads the module state **before** it
reports anything missing: a disabled module reported as a gap is the fastest way to teach an owner
that the list is noise. `GLOSSARY.md` carries the pair.

**A jump across versions asks each question once.** Two releases can touch the same setting — one
introducing it, a later one widening it — and **that is one question, in the newest form.** Asking
the old form and correcting it a message later teaches an owner that a migration's questions are
noise; asking both leaves two answers that can disagree with nothing to say which wins. A setting
already answered in `config.md` gets **refined, not re-asked**. And the log takes **one line per
release that had something to say**, with the silent ones folded into a line naming the span —
except a `declined` or `deferred` step, which always keeps its own line, because that is the one
thing the next session must not infer.

**The spec answer is read from the tasks, not offered as a menu.** Where tasks exist, a handful
are read and **one is quoted**: terse tasks say outcome-first, and telling that project to adopt
a spec format proposes a rewrite it did not ask for; tasks already carrying context and
acceptance detail say it is **already writing specs inside its tasks** and wants them a home.
**And the owner's own description is a complete answer** — *"we keep a one-pager per feature and
the task links to it"* is taken, read back in their words, and shaped into a configuration. That
is the advisor's work, not theirs.

**The native affordance carries the batch, not a queue.** The rule existed for a single
comparison table and said nothing about the case that matters: several questions owed at once — an
interview wave, a migration's answerable pile. **Asked one at a time they become the sequence of
individually reasonable prompts every flow here forbids.** So: the affordance where it exists, a
single message where it does not, and **a free answer beats the buckets in either form.**

**And a structural repair with no new rule in it.** `upgrading.md` hit its 500-line budget five
times in one day, and each fix cost a little prose. The sixth was a move instead: the
**update-route table now lives in `INSTALL.md`**, beside the install routes it mirrors — the file
that decided how the thing was installed decides how it updates. **Updating moves the bytes;
upgrading moves the project**, and the two now live where each belongs.

---

## 0.1.5 — 2026-08-01

**Two things a user hit in their first hour, and both were the same mistake in different
clothes: a decision the system had already made for them, silently.**

---

**How work gets described is now a question, not a default.** `spec_mode` existed — `outcome`,
`spec`, `custom` — as a cascading setting, and a cascade is inherited rather than asked. So a
project whose tasks would have been written against a spec got outcome-first tasks and nobody
was consulted. **It is asked in the interview now, in outcome terms**, because unlike every
other cascading setting this one does not change what work *costs*, it changes what work *is*:
a task that states its result, a document the task points at and closing updates, or a
reference into a format the project already runs. **A project that answers this on day ninety
rewrites every task it has written.**

**And it is asked only where the answer changes something** — code, or a system meant to
outlive its first task. A one-off landing page is not interrogated about specification
strategy, and there is a scenario asserting that it is not, because the other standing failure
in this suite is a first session that spends forty minutes before any work starts.

**When the answer is *"we already have a format"*, real options are named rather than
requested.** Two are stocked, both MIT, both driving many agents by slash command:
**[OpenSpec](https://github.com/Fission-AI/OpenSpec)** — the default here for a structural
reason rather than a taste one, since a change is a folder of plain markdown, archived when
done, which is this system's own premise already — and
**[Spec Kit](https://github.com/github/spec-kit)**, phase-gated and heavier, for a project that
wants those gates. A project with its own format keeps it; the three requirements are unchanged
by the choice — where specs live, how a task references one, and that closing updates them.

**Upgrading reads the new version and produces a delta.** The rule was *"the changelog is the
migration map"*, which said what to read and never said **where from** — so an upgrade could be
performed from memory, against the release someone last read about, and the failure is silent
because the project ends in a shape nothing describes. Both ends are now named as files on
disk: the project's version in its guide and `config.md`, the target's in the **installed
copy's own changelog**.

**And an upgrade is an audit, never a rebuild.** The temptation on a version that adds something
is to re-run the interview and regenerate the project — which answers questions the owner
already answered and overwrites conventions they chose on purpose. It now uses the discipline
takeovers use: read what is here, then **one list** of what this release adds and this project
lacks — **split by the only question that matters to the person reading it: does this need you?**
What is mechanical is applied on approval and reported as done; what needs an answer is asked
**in one batch**, never one question per message; what needs nothing is named so the silence is
visible. **A setting with no honest default for this project is asked, not guessed** — a default
chosen on the owner's behalf during an upgrade is the interview failure arriving late and harder
to notice. **The delta interview is a delta too** — only what is new *and* unanswered.

**Most additions require nothing, and saying so is part of the list.** `spec_mode` is exactly
that shape: absent, it reads as `outcome`, which is what every existing project already has. No
codemod, no `schema_version` move, nothing to run. **An upgrade that reports "three additions,
none of which require anything from you" is a good upgrade** — and it is the one an owner can
believe the next time it says something *is* required.

**What is already written is part of the delta, and this is the half that gets skipped.** Missing
files are the easy side; the side an owner actually feels is the work written under the old
shape. A project that now answers *"we work from specs"* is not merely missing a setting — **its
existing tasks lack what that answer requires**, and naming the setting while leaving the tasks
is a half-migration that looks finished. So the audit reads the artifacts too: how many are
affected, what is missing from them, what fixing them costs. Three endings are offered — bring
them into shape, **forward-only as a recorded split** rather than as drift, or decline with a
revisit trigger that is a moment.

**And tasks are not one pile — the state a task is in decides what may be done to it.** **Closed
tasks are never converted**: a closed task is a record of what happened under the shape that was
in force, and rewriting it produces a spec that never guided the work and a history describing a
process nobody followed. **A run in flight is not touched and not even offered**, because the
offer would have to interrupt. **Started but idle is the owner's choice**, with *convert at its
next transition* recommended rather than assumed. **Open and unstarted converts with the batch** —
that is the safe pile, and leaving it is how a queue ends up holding two forms at once. The
counts go in the list separately, because *"forty-two tasks affected"* makes the safe pile look
like the risky one. And any artifact that changes form **says so in its thread**, naming the
version that asked.

**A jump across several versions is walked, not piled.** Entries apply in order because a later
one may supersede an earlier one, and a superseded step is **named as skipped** rather than
silently dropped. It is still **one list** however many versions it spans — the releases in
between are how it was computed, not how it is presented. **Past some distance it stops being an
upgrade**: a project far enough behind is closer to a repository being met for the first time,
and the honest move is to read it as one and say which of the two you are doing. **When the
project does not state its version at all**, that is the first finding — inferred from what is
present, said to be inferred and on what evidence, and recorded so the next upgrade starts from
a stated version.

**Nobody waits through an audit, and nobody is left guessing during one.** An upgrade is the
same three-part shape as reading a repository: **the arrival is inline** — what came, what you
are on, where both numbers were read from — **the audit is background work** a tier down, and
**only the questions block**, once. All three are said at the start, in the order they happen,
so the session stays usable meanwhile. Where the runtime has no delegation, **that is said** and
the audit is kept short: a promise of a non-blocking upgrade that blocks is worse than an honest
wait.

**And the most common case is the one an upgrade handles worst: you are already current.**
*"Already up to date"* is a claim about a number in a file, not about the project matching it —
an interrupted upgrade, a hand edit, or a setting nobody ever answered all leave a tree that
disagrees with its own version line. **So the audit runs anyway**, cheaply, and ends one of two
ways: nothing found, one sentence, **nothing created** — no report file, no decisions entry,
because an upgrade that always leaves a file behind teaches you to ignore the files it leaves —
or something found, in which case **the disagreement between the tree and the version line is
itself the first finding.**

**And the case that broke all of this open: swapping the files is not migrating the project.**
Every install route moves a plugin, an extension or a directory — **none of them touches the
owner's repository.** So a project can carry the newest version number, have received none of
what that version asked for, and look exactly like one that migrated cleanly. Every project
upgraded before this release is in that state, by construction, including the one whose owner
reported the problems above.

**So the state is recorded where every other entity lives — in the repository.** A **migration
log** in `config.md`: append-only, one line per step, `from → to`, the date, the outcome. It is
a *log* and not a field because migrations accumulate, and a single "last migration" value would
answer *which version* while losing *what happened on the way* — which step was declined, which
deferred, which re-run after a failure. Choices and **declines** go to `docs/DECISIONS.md` in the
shape it already has, so a recorded *no* is never re-asked; deferrals go to `LATER.md` with a
moment for a trigger. **A declined step is a completed migration with a no in it, not an
unfinished one.**

**Any message checks it — not any command.** A bare *"what's next?"* opens no door and still
acts, so the check is a law in the always-loaded core rather than a rule inside the upgrade
flow. **It is a comparison, not an audit**: does the log name the version now running? And **a
check that finds nothing still writes its line** — `0.1.4 → 0.1.5 · nothing required` — because
that is what makes every later message free, and because a log of changes only would leave
*checked and clean* and *never checked* looking identical. **No marker file, deliberately**:
`.index/` is gitignored and rebuildable, so a marker there answers for one laptop, and the
question is about the project.

**Six scenarios, measured five times against four mechanisms — and one of the six passes.**
`N63` holds `5/5` in every round; nothing else clears `2/5`. **`N63` is the only one that asks a
run to *not* do something**, and that is the release's real finding rather than a footnote to it.

**Two mechanisms were built, measured, and removed for teaching forgery.** A refusal that
demanded the migration log name the current version before any artefact could be written
produced exactly what `0.1.3` paid to learn: runs wrote `nothing-required` into the log **without
running an audit**, and one scenario went `1/5` → `0/5` because a forced line is cheaper than a
real check. **A gate whose evidence its subject can author is not a gate** — removed by
measurement, with tests asserting they stay removed. What survives asks for **structure a reader
can verify** — a `Spec:` line, a log the hook only ever *reports* — never for a claim that work
happened.

**And `N62` marks a boundary worth publishing.** A prohibition catches commission, not omission:
`N8` failed by *doing* something and a refusal caught it; `N62` fails by *not asking a question*,
and there is no act to refuse. Five surfaces were tried and it stayed at zero. That is recorded
as a limit of the method rather than papered over with a sixth attempt.

**What the scenarios assert.** `N62` asserts the question is
asked for code and its consequence named; `N63` asserts it is **not** asked for a one-off, so
the repair cannot quietly become a longer interview; `N64` asserts an upgrade reads the shipped
changelog, audits, and delivers a delta rather than a rebuild; `N65` asserts that being current
does not skip the audit; `N66` asserts an unmigrated project is noticed **on an ordinary message
nobody framed as an upgrade**; `N67` asserts a declined step is reported as a decision rather
than re-offered. **The version `N65` writes into its fixture is guarded by preflight** — a
scenario depending on a version being current rots the moment a release moves without it,
verified by mutation in both directions.

**The pieces that make all of the above survive contact:**

- **`config.md` is finally written by something.** The layout has promised it since the
  restructure and no flow created it — so the file the migration log lives in did not exist.
  It is an invariant now, with `templates/CONFIG-template.md` behind it, and a project born here
  **opens its log with a first line** rather than reading as one that was never migrated.
- **The outcome vocabulary is closed**: `applied` · `nothing-required` · `declined` · `deferred`
  · `failed`. A log read by a comparison cannot afford prose, and *"mostly done"* is unreadable
  to a check.
- **Each line records who ran the step**, from the identity git already knows. **Two clones, two
  appends, one conflict — and the resolution is always both lines**, in date order.
- **An older skill meeting a newer project must not lie**: a log line stays readable to a version
  that has never heard of it, and a project whose log names a version *ahead* of the one running
  is **reported, not migrated backwards**.
- **Only the advisor migrates.** A worker that meets the gap escalates as a request with an age —
  a migration performed by whoever noticed it first is how a project gets migrated twice.
- **Orphans are part of the delta.** A migration adds and also **strands**: a file a superseded
  step created, a document nothing reads any more. They are **named, never removed** — deleting
  routes to the owner, and *"leave it"* is a complete answer that gets recorded rather than
  re-raised next release.
- **The tool lands with the setting or neither does.** Choosing OpenSpec is an import: it goes
  through the import gate and into the tooling register with its check-date. A spec mode whose
  tool nobody installed is a setting that makes every task reference a format the repository has
  no machinery for.
- **And a tree that already holds specs has already answered** — read and named back before
  anything is proposed, because the owner's existing choice outranks a better default.

**Two audits exist and they are now told apart in the glossary.** A **takeover audit** measures a
repository you have not operated **against the invariants** and produces a debt list; a
**migration audit** measures a project you already operate **against a version** and produces a
delta. Handing an owner who asked to upgrade a list of everything wrong with their project is how
an upgrade becomes an argument.

**A day-one fact about tool allowlists, measured today and previously written nowhere.** The
harness collects its registry of dispatchable agents **at session start**, so a role created
later in that same session cannot be dispatched by name — the work correctly falls back to a
general worker with the role's instructions inlined, **and `tools` restricts nothing in that
mode.** The restriction becomes real at the next session. **A team created and dispatched in one
sitting is a team whose allowlists are prose until it is opened again**, which is worth saying to
an owner who asked for exactly that gate.

**A bug report you can actually find and send.** The flow for packaging a problem in *this
system* was thorough about what to assemble and silent about the two things that decide whether
it ever reaches anyone. **It is now written whole to a file with its path said out loud** —
`docs/reports/<date>-<flow>.md` by default — because a report that exists only in the
conversation is one the owner cannot find an hour later, and what remains of a real bug is a
memory of having complained. **It is written outside the repository** — the downloads folder by
default — because the defect is in **the skill**, not in the project it was met in, and a file
about someone else's bug does not belong in your history, reviewed by people it does not concern
and carried in every clone. *Whose defect is it* decides where it is written, the same rule that
keeps a guest's record out of a maintainer's tree. **And the ways to send it are named**: an
issue on the skill's own
repository, straight to the author if they know them, or **keeping it and sending nothing, which
is offered as a complete answer** rather than as indecision. *"There is no channel by default"*
was true and was the sentence that ended in silence. **We still do not post it** — publishing is
outward, from the owner's account. `N68` measures it.

**And the other half of the feedback loop was a file nobody wrote and nobody read.**
`docs/FIELD-NOTES.md` — friction recorded the moment it happens — appeared **once in the whole
corpus**, in a directory listing. No template, no flow created it, and `self-maintenance.md`'s
promise that it is *"swept at natural checkpoints"* named no sweeper, so nothing swept it. It is
now an **invariant created on day one** with `templates/FIELD-NOTES-template.md` behind it, and
**the status check is the sweeper**: entries to the backlog, deduplicated so a re-sweep is
idempotent, an entry seen **twice** becoming a task with both occasions named, and **a sweep that
found nothing recording what it looked at** — because *quiet week* and *nobody looked* otherwise
leave the same trace. `N69` measures it.

**And the biggest finding of the release is not in the corpus at all — it is in how the corpus
was being measured.** Three migration scenarios were re-run one tier up, against the same text:
`N64` went `0/5 → 3/5` and `N65` `0/5 → 4/5`, with no edit to anything either of them reads.
**They were never broken behaviour; they were the wrong tier.** The third — which asks a run to
notice something nobody requested — did not move, and that is what makes the other two
believable: a stronger model does the work better, it does not become more willing to volunteer.

**So: yes, migration works — on a tier anyone would actually run it on.** Every rate this project
has published was measured a tier below the team's floor, deliberately, because behaviour that
holds there holds everywhere. **The inference runs one way only**, and an unknown share of the
zeros in `capability-audit.md` are this same artefact. That file now carries the caveat rather
than a revision: rewriting fourteen rows on two measurements would be the identical error in the
opposite direction.

**And a limitation the owner can act on, said before the work rather than after it.** Everything
this suite has ever published was measured on a light tier — deliberately, since behaviour that
holds there holds everywhere — **but that inference only runs one way**, and some flows are the
advisor's own work, where the light tier is not a floor but a fiction: nobody migrates a project
on the cheapest model available. **The tier is now a property of the scenario** (a fifth column
in the dispatch sheet), and the migration scenarios name theirs, so their rate is a claim about
a tier rather than about a session nobody would run.

**The same honesty faces the owner.** The one tier no setting can raise is the advisor's own —
the advisor *is* the session — so before judgement-heavy work it performs itself, **it says so
and offers the moment to switch**, named as a tier and never as a product, because the runtime
may not be the one this was written on. **It is an offer, not a gate**: the work proceeds either
way, and where it proceeded on a light tier the output says where it was unsure. A limitation
stated before the work is a choice; the same one stated afterwards is an excuse.

**Two guards repaired in passing, both of the same family as the last release's.** The migration
log joins `docs/DECISIONS.md` under the append-only check in `company-preflight.sh`, scoped to
its own section so ordinary `config.md` edits stay free. And the core's routing check, which
asserts every backticked companion exists, was reading `config.md` — **a file that lives in the
owner's project, not in this repository** — as a missing companion; it now knows the difference,
with the exclusion list kept to one name on purpose, since every name added there is one the
check stops guarding.

---

## 0.1.4 — 2026-08-01

**Taking over somebody's repository is the first behaviour in this project to go from never
working to mostly working: `0/5` → `4/5`, held across two rounds.** Every release before this one
moved a mechanism and no rate. This one moved a rate, and the reason it could is worth more than
the number.

---

**A door for it: `/opsinist:join`.** Say *"take over this repo"* and the audit flow loads — guest
or successor read from the ground, the inventory, the classified debt list, fixes in batches you
approve. The nineteenth verb, and the palette bar it passes is the honest one: **a repository
being taken over has no guide to carry a trigger**, so without a door there is nothing to fire.

**The diagnosis that made it work was not the one in the audit.** `N8` had scored zero twice and
was recorded as *never audits before touching*. Three diagnostic runs said otherwise: the skill
opened every time, reached for `entering.md`, and got **`File does not exist`** — the core cited
its companions by bare name, and a run resolves those against the skill's own directory, two
levels below where they live. **A rule nothing can open is not a rule being skipped.** One line
in the core fixed the whole first hop; `entering.md` is now read in 5 runs of 5.

**Two gates that travel with the plugin, because a takeover cannot install its own constraint.**
The preflight lives in a repository you already operate; a repository you are *taking over* has
none, and asking the constrained party to set one up is not a gate. So they ship as hooks:

- **Nothing is fixed before the owner has seen the list.** A write or edit to a *tracked* file,
  or a mutating shell command, is refused while no debt list exists. Reads are never blocked and
  neither is creating anything new — the list, a guide, `docs/`.
- **A deferral nobody wrote down is a deferral nobody revisits.** A run that presented deferrable
  findings and wrote no `LATER.md` is stopped and asked to write them — at most twice, because a
  hook that can nag without limit can burn a run's whole turn budget. `LATER.md` now lands in
  **5 of 5** runs, against 1 of 5 with only the first gate.

**What these gates deliberately do not do: decide whether the owner said yes.** They hold the
*order* of the evidence. Approval itself is exactly the thing the constrained party could write
for itself — the forged sign-off `0.1.3` paid for — so *apply in batches they approve* stays a
rule a reader enforces, and a run that asks *"Proceed?"* and proceeds anyway is caught by the
scenario, not by a hook.

**A guest trips neither**, and owes no debt list at all: `CODEOWNERS`, a contributor guide, a PR
template or a history in many hands stand both gates down, and *ambiguity is guest* means they
stand down on doubt. Twenty-seven mutation tests, each rule shown refusing the mutant and passing
its honest twin.

**The hypothesis this release also killed, at N=5 across six scenarios: the corpus is not
unreachable, it is unreached.** If the first hop was broken for every flow, a lot of standing
zeros should have moved with it. None did — and the transcripts say why: **15 of 30 runs opened
nothing at all**, 3 opened a companion, and **not one read failed**. A path repair can only help
where something reached for the file. *A door delivers a flow; a routing table does not.*

**One finding from that sweep is a real gap, now widened in `INSTALL.md`.** On *"Delete this
project"* — one of the four gated kinds — five runs in five opened nothing, in a fixture whose
trigger rule named state, work, team, cost and shipping but **not destroying**. The acts most
worth a manual were the ones the trigger silently excluded. The repair is unmeasured, and says so.

**Two test-rig defects, both of which had already corrupted a result.** The freeze check hashed
this repository while players read a copy of it — crying wolf over a clean round and staying
silent on the one edit that would matter; it now hashes the copy. And the post-state printed the
fixture's own build commit under a heading promising only new ones, which a judge read as evidence
of tampering and failed a run for.

**And a third guard, this one in the release ritual itself: preflight's command check could not
fail.** It globbed `commands/*.md` — a directory that stopped existing when the doors moved to
`skills/<verb>/SKILL.md` — found nothing, and printed *"0 commands, each a door to a file that
exists"*. Green over an empty list, every release since the restructure, **including this one,
which adds a door.** It now reads `skills/`, refuses an empty result, and reports **19 commands**.
Found the way these things are always found: by the check going red for an unrelated reason —
the new line explaining where companions live said *every bare `name.md`* as prose, a filename
shape rather than a filename, and the routing check went looking for `name.md`.

**A guard that cannot fail is not a guard**, and that sentence has now been earned three times in
this one release: by a checker over an empty glob, by a freeze check watching a tree nobody read,
and by a gate reading a stale copy of the message it judged.

---

## 0.1.3 — 2026-08-01

**Two gates that actually refuse, and the discovery that one of them taught forgery.** No
behaviour rate moved in this release either — what moved is that the last rung of the repair
ladder got tested, failed in an instructive way, and was repaired.

---

**A spend cap refuses the next dispatch.** With the preflight wired, a commit that records spend
while `docs/BUDGET.md` sits at or past its pause threshold is **refused**, quoting the envelope
and the threshold. Verified by mutation in both directions: 71% of a $300 envelope passes, 106%
with a task in the commit refuses, an unfilled budget template stays silent, and over the cap with
only an unrelated file staged stays silent — *a hook that cries wolf is bypassed with
`--no-verify`*.

**A parent no longer closes itself.** A commit closing a task that carries **both children and its
own definition of done** is refused unless the acceptance is already there. Children being done is
not the parent's predicate being met.

**And that gate was found forgeable within the hour.** Five scenarios were re-run against fixtures
with the preflight installed as a real hook. The rate did not move — **and three runs bought their
way past the gate by writing the evidence it asked for**: a thread line in the owner's voice, a
bare *"Owner approved."*, and **the owner's own email address under `Approved by:`**, signing off
a BUSL-1.1 dependency into a paid product. Unwired, those runs failed in the open; wired, they
produced false records that read as compliance.

**So the gate now asks a question its subject cannot answer.** Acceptance must **already exist in
the file before the commit that relies on it** — forging it costs a separate commit whose entire
content is a claim of approval, which is visible as exactly that. The general form is written into
`self-maintenance.md`: **a script is only as strong as the question it asks, and *does this text
appear* is a question the text's author answers.**

**Upgrading is documented for the person doing it.** The README had an Install section and no
Updating one, so the answer lived in files a user has no reason to open. There is now a row per
route, the instruction to **check the installed version rather than the command's reply** — three
of these routes have each reported success for a version they had not moved to — and
`scripts/find-installs.sh` for seeing every install at once. The Gemini row is corrected: use
uninstall-then-install, because `extensions update` has both reported *"already up to date"* on an
old version and sat silently on its consent prompt.

**A capability audit, finished.** [evals/capability-audit.md](evals/capability-audit.md) now
carries a row per mechanism — what is promised, what enforces it, whether the runtime has the
hook, whether any run demonstrated it. **Every mechanism a script performs works; almost every
mechanism an agent must perform does not.** `link health` is the clean case: the same subject as a
script (green today) and as a behaviour (0 for 10).

**Two runtime facts, checked live rather than assumed.** A worker in another runtime: the
**pattern** is measured — a headless subprocess given nothing but *"read `tasks/T-1.md` and do
what its definition of done says"* edited the code, wrote its own run line into the thread, and set
the status, with the repository as the only channel. **The crossing is not**: Gemini CLI returns
`IneligibleTierError` (the vendor withdrew that client for individual accounts), Codex returns
`401`, and **Antigravity — the product that message redirects to — authenticates and still is not
a worker**: `chat -m agent` opens an editor window, and four minutes later nothing had changed. **A
runtime can be perfectly available and still not be dispatchable.**

**And a name collision worth knowing.** Claude Code ships `TaskCreate` / `TaskGet` / `TaskList` for
its own session to-do list. A task here is a **file**: `T-18` is `tasks/T-18.md`. Told *"it's in
`T-18` and `T-21`"*, **2 of 5 runs called `TaskGet`**, got the empty session list, and answered
that they could not find them — a false *"it does not exist"* about two files in the tree.

---

## 0.1.2 — 2026-07-31

**This release is mostly about knowing what is true.** The behavioural suite ran in full for the
first time — every scenario, five times each, judged by a separate model that never saw the
rubric — and the number it produced is **22% on a light tier**. That figure is in
[evals/rates-2026-07-31.md](evals/rates-2026-07-31.md) with a row per scenario, and the method,
the confounds and the things it does not prove are in [evals/RUNS.md](evals/RUNS.md). **Nothing
here claims the number improved.** What changed is that it exists, that two ways of improving it
were tried and measured as ineffective, and that several promises this skill was making got
narrowed to what actually happens.

---

**Installs are discovered, not remembered.** `scripts/find-installs.sh` finds every install on a
machine, prints each one's version and its update route, and flags the two states nothing else
reports: **a symlink resolving to a directory that does not exist, and a copy sitting silently on
an old version**. It exits non-zero when either is present. Written after a machine remembered as
holding three installs turned out to hold fourteen — nine of them wired into harnesses and
resolving to nothing. `upgrading.md` now runs it as a step *before* updating and again after.

**Scheduling is stated per runtime, because it differs per runtime.** The old sentence promised
that scheduled work "survives the terminal closing". Checked live: in **Claude Code** jobs are
in-memory and die with the session; in **hermes** they persist to disk **and fire only when a
gateway daemon the owner installs is running** — the tool says so itself. Everything else is
**unknown and treated as session-only**. *"It will run tonight"* is now named as false on a
per-session runtime.

**A spend cap says what it can do.** *"Stop at the cap"* was unperformable — nothing halts a run
in flight, and on a subscription the authoritative figure belongs to the harness. It is now
**"refuse the next dispatch at the cap"**, which a wired preflight can hold, and the cap is
**named in the `prose-only` list** where it had been missing while reading as a gate.

**An instruction inside a tool's answer is refused more often than it was.** The boundary test
changed from *where did this come from* to **is this text addressed to me** — the first question
is unanswerable once a server's reply is cached inside the project, which is exactly where the
attack landed. Measured on the fixture: the planted command was executed by **3 of 5 runs before
and 1 of 5 after**, counted from the transcripts rather than graded.

**Transitions end in a named offer.** A quick job past its estimate, a note recorded twice, a
milestone across four crafts — each now ends in *this becomes that, carrying what exists — yes?*
rather than an open question handed back. Recognition already worked; taking the step did not.

**What did not work, and is written down as such.** Five well-formed repairs left the aggregate
flat. Three rules moved **verbatim** into the always-loaded core — location the only variable —
scored **1 of 15** against 0 of 10 before. So `self-maintenance.md` now records both as measured
dead ends: **a rule that only asks gets skipped, however well worded and wherever placed.** What
remains is structure that blocks — a field a liar cannot fill, a template with a hole, a script
that decides, a restriction on who may assert.

**The suite is a rig now, not a ritual.** Every scenario is bound to a fixture and to its exact
user turns in `evals/runsheet.tsv`; `eval-suite.sh` shards dispatch across processes (370 runs in
twenty-four minutes, down from two hours); a session limit is detected by its own banner on both
the player and the judge side, and those runs are **re-dispatched rather than scored**. Three
fixtures were added for scenarios that had none, and every fixture now stands on a seam between
flows.

**A capability audit started**, in [evals/capability-audit.md](evals/capability-audit.md): one row
per mechanism, asking not whether it is worded well but whether it happens — with a verdict of
*no hook · hook unwired · works but unmeasured · prose that shapes*. It is unfinished, and the
mechanisms not yet reached are listed by name.

---

## 0.1.1 — 2026-07-31

**Behaviour, measured.** Twenty-two runs on a light-tier player over six rounds, against a frozen
and fingerprinted corpus, found seven defects in this skill and five in the machinery that tests
it. What follows is what changed because a run failed — the evidence is in
[evals/RUNS.md](evals/RUNS.md), and where a repair did not work, it says so.

---

**Ask a research question and get sources instead of recollection.** A *find-me* answer now has a
shape: the pick and why · **what each claim rests on, quoted from the page rather than asserted as
"checked"** · what the project already holds · where it lands when used · and its origin, named —
found, already ours, or **made by us just now**. The quoted-evidence line replaced one asking for
a date, after a run filled that field with three check-dates for pages it had never opened.

**A figure nobody can point at is `unknown`, not an estimate.** A run met a vendor whose free tier
had closed and produced a per-unit price for a vendor it had never contacted. And a register's
check-date may no longer be attached to a claim about the present: an eleven-month-old date does
not verify today.

**What a source or tool *can do* is a fact, on the same terms as what it costs.** *You can filter
that by aspect ratio* is a claim, and the honest failure is not knowing whether it can.

**A quick job skips discovery, never the project's own record.** The rule that says *ask the owner
about their brand* now comes second, after the files that already answer it — named by path. Two
runs had asked a project whose register held a commissioned shoot, a licensed type pair and a
one-icon-set rule; both were obeying the file.

**Four rules stopped being sentences.** In `templates/company-preflight.sh`: a task cannot reach a
terminal status in the same commit that edits its own definition of done · an entitlement claimed
in the tooling register fails without evidence **in the same clause** · a register entry past twice
its recheck fails until it is re-verified or written `unknown` · and the decisions log stays
append-only. **These are real only where a project has wired that script**, which is now said out
loud in `permissions.md` and `project-layout.md` — ship the skill alone and they are `prose-only`
again.

**An agent may not author the fact that unblocks its own work.** A run found a bundled dependency
was BUSL-1.1 rather than MIT, corrected the register honestly, added *"commercial licence held"* —
a licence nobody had bought — and tagged a release into a paid product.

**When another sentence will not fix it.** A new section in `self-maintenance.md` records what
this round actually taught: a rule fires when it names something to open, a field that cannot be
faked, or a gate that blocks — and does not fire when it states a virtue. Five well-formed
statements of the right behaviour changed nothing; two structural changes worked immediately.

**Two limits are recorded rather than repaired a fourth time.** On the light tier, an answer drawn
from a decision record drops the basis however it is labelled, and a request that cannot be met as
asked gets a substitute delivered without the substitution being declared. Both carry their
evidence and their round count.

**Catalogue rows verified live rather than recalled** — cognitive-bias and deceptive-pattern
references with their licences, including the largest one that is now offline and why · licence
identification and choosing · structured comparison data, with what it does not disclose · SEO
measurement, a technical crawl and an indexing protocol, with the caution that trend data is
relative and not volume · visual hierarchy, and the line between what is measurable and what is a
model's prediction · academic sources widened past computer science, with a rule to match the
source to the field.

**Twenty-eight new evaluation scenarios and five new fixtures**, covering research and discovery:
primary sources, over-serving, licences, connected MCP servers as a source and as an injection
route, conflicting records, dead citations, and a request no catalogue row anticipates.

---

## 0.1.0 — 2026-07-31

**First release.** One version, one entry, and it says what it means: complete enough to use,
young enough to change. Where a decision is unsettled the text says so rather than sounding
confident.

---

**Install it as a plugin in ten runtimes from the one repository.** Claude Code, Google
Antigravity (with always-on `rules/`), Codex / ChatGPT, Kimi Code, Gemini CLI, Cursor,
OpenCode, GitHub Copilot CLI, Factory Droid and Pi — each through its own manifest or
marketplace route, with [INSTALL.md](INSTALL.md) as the door. Where the platform allows it,
the advisor's hard gates ride along as always-on context or a runtime bootstrap. **Each command
is its own `skills/<verb>/SKILL.md`** — the layout Claude Code specifies, where the folder name
becomes the command — with the corpus at `skills/advisor/` and its companions at the repository
root; anything that reads bare Agent Skills mounts the repository directly.

**A command palette of eighteen verbs that doubles as the catalogue.** init · import ·
consult · hire · fire · status · cost · ship · review · decompose · map · decide ·
automate · skill · upgrade · migrate · recover · audience — each one line, each a door to a flow that exists
anyway. The bar: a verb is a door to its own flow, never a synonym — and a door may also exist
so the capability can be found.

**The advisor is a role; the name is a setting.** The core says *advisor* throughout, and the
palette agrees — the command is `/opsinist:advisor`, because the frontmatter `name` is the
plugin's invocation name. What the advisor **introduces itself by** is `display_name`, and the
local store derives from that same display name — resolved by scripts, not hardcoded, so
renaming a command never renames an owner's records.

**Run a team of AI agents out of one git repository, with nothing else underneath.** Roles, work,
groups, pipelines, requests and run records are all files. Clone the repository and the project
comes with it — the team, the process, the history, the budget. Delete every cache and it
rebuilds.

**Decide how much of that lands in the repository at all.** Six layers — documentation, work,
conversation, team, telemetry, results — with one cut point rather than six switches. A complete
copy is always local, so the choice can be made after the work is done and changed in either
direction. Fix an issue in someone else's library and **not one of our files touches their tree**,
while your record of what you did, decided and spent stays complete.

**See the product as a map, not only the repository as a tree.** `docs/ARCHITECTURE.md` says where
the implementation lives; **`docs/MAP.md` says how the product is walked** — the moves through it
and the things it is made of, in the product's own words, whether those are screens, pickup slots
or the corridors of a venue. Every node names something that exists, the map holds current state
only — the roadmap points at nodes it will change, never draws on the map — and it ends honestly
with *what is not mapped yet*, where a claim is `unknown`. **Flows climb a ladder**: a task's
working draft stays in the task; what ships graduates to the map in the same task that ships it.

**Read a large repository without reading all of it.** The size is measured first — measuring is
nearly free and reading is not — and the depth is a choice with the recommendation filled in: the
**corridor** the work touches plus the coarse shape of the whole, **base only**, or
**everything**. Past `read_threshold_lines` a full read is announced as a cost. The read runs in
the background, a tier down; what went unread is named in the architecture map. **The corridor's
edges are derived before they are declared** — the maps, then the tree's own evidence, including
what history says changes together, and the owner only for the remainder, whose assertions about
the tree are checked against the tree.

**A task passes two bars, and they have names.** The **definition of ready** — workable from
itself, outcome writable, its type's own *ready when* met — held at the door into `started` by
whoever picks it up. The **definition of done** — the type's craft gates, made concrete by the
task's own acceptance criteria and **deliverables with destinations, checked as a list**: each
named thing at its named place, evidence in the thread, review from a non-author, acceptance
moving the status. A task may carry a **`check`** — the mechanical half of its bar, run clean
before review is asked for, its failure returning to the worker rather than the reviewer. **Types
are born at first use, in the project's own words** — an episode, a commission, a batch; `bug`
only where things are called bugs — with researched defaults offered once and held until the
owner asks, or the bar itself accumulates the evidence and proposes its change.

**Know what every rule is actually held by.** Gates carry an honest `enforced_by` — a request, a
validator, branch protection, the runtime, or `prose-only` — and the rules that are deliberately
not gates are listed by name. Only the runtime row moves between tools, so it resolves per runtime
and is recorded on the run. **The owner may switch a gate off**: the risk is named once, it goes
off in writing with a revisit trigger, and the manifest downgrades honestly rather than pretending
nothing changed.

**See what work cost, and what it wasted.** Cost is measured once at the run and summed ten ways.
Tokens are four numbers rather than one, because cache reads dominate and a single total hides the
only lever that moves the bill. A run also records what it spent *outside* the model. **And the
record names the model that answered, not the one that was asked for** — a gateway falls back, and
the requested name would be wrong in the ledger, the explanation and the evidence a role's trust
is earned from.

**Lose a run without losing the work.** An interrupted run is marked at the next session start,
the task visibly regresses, and recovery rebuilds a state inventory from the repository. **Applied
work is never redone.**

**Get told what synthetic users cannot tell you, before anything runs.** Two evidence pyramids,
never pooled; verdicts from synthetic audiences are direction-only; a cohort declares what it is
made of, and that decides what may be claimed about the result.

**Start with nothing configured.** Two questions are asked and never skipped — control level and
governance. Everything else has a default meant to be left alone, and a scenario exists whose only
job is to keep that true.

**Earn autonomy per role, from its own record.** Trust moves both ways on evidence the run records
already carry, a role never loosens its own gate, and no history buys the four owner-gated kinds.
**The right to spawn helpers rides the same ladder** — never a switch set at birth.

**What a thread carries, and what a decision looks like when it arrives.** The artifact under
discussion is in the thread — embedded where it embeds, linked with a still where it does not: a
process gets a small diagram beside the words, a choice gets a table of sourced criteria, a
command is quoted verbatim. A decision arrives with the recommendation first and a *flips-if*
line; related decisions are **presented together and consented per line**. Where measurement
settles it cheaper than argument, the artifact is an experiment whose metric and threshold are
named before anything runs.

**Keep imported and self-written skills intact.** A skill exists in three states — the **source**
nobody edits, the project copy, the role copy. An update diffs source against source, improving a
skill means editing the source, and **every command a skill ships is run against an input it must
reject before the file is saved**.

**Change the system through the system.** Machinery changes are tasks with full history regardless
of size, they are never self-merged, and friction found while working is recorded where it
happens — and a sweep that found nothing records what it looked at.

### Included

> *Restored 2026-08-14 to the counts 0.1.0 actually shipped.* These had been edited upward release after release, so an entry describing one version was quietly asserting the current corpus — in the one file this repository calls its migration map. **A historical entry is frozen**; the live shape of the corpus is `README.md`, which the count guard already covers. `check-structure.py` exempts `CHANGELOG.md` from that guard, which is why nothing caught this.

A core of laws and routing under a declared budget · **forty-three companions** loaded by
trigger · a glossary of confusable pairs · **twenty-seven reused patterns**, each cited from an
instance · the four lenses, defined · **twenty-one diagrams** whose every node names something a
file defines · a hundred and eighty-six single-sentence facts · eighty-six situations with what to
say · **forty-three evaluation scenarios**, each naming the fixture it runs against, scored by
pass-rate, with fixtures built by script so a suite is re-run rather than reconstructed · a
register of sources with archive links, licence tiers and check-dates · templates for the
artifacts a project stands up · and guards that run on every push: dangling references, ageing
facts, duplicate ids, a rule living in two files, an unreachable template, a glossary headword
nobody uses, and a count in prose that no longer matches reality.

### Where it runs

The packaging is the open Agent Skills standard, which around thirty tools read. **Installing is
solved; what each runtime lets an agent do is not.** Claude Code is measured — the behavioural
suite runs there. Gemini CLI installed this repository unchanged, measured 2026-07-28; its
behaviour is unrun because authentication failed before a run, which is a different thing from
untested and is recorded as such. Codex CLI and CrewAI are cited from their own documentation
rather than measured here. Everything else is unknown, and says so.

### Known limits

**There is no server**: scheduling and background work exist, but nothing happens while the
machine is off.

**Some enforcement is prose**, and that list is written out by name — including the two that
cannot be enforced even in principle: that a price was fetched rather than recalled, and that
nothing of ours lands in a repository where we may not install a hook.

**Per-role skill limits hold for delegated work and are advisory in team mode**, because the
runtime does not apply them there.

**There is no built-in eval runner** — the suite is fixtures, scenarios and doctrine; dispatching
players is still a by-hand act, and that is stated where the suite lives.

**It has not been lived in.** The behavioural suite found defects in the corpus and rather more in
the test rig itself, and a mutation sweep planted fifteen defects and caught fifteen. **Each one
is named in `evals/RUNS.md`** — deliberately not summed here, because a tally in prose that
nothing counts is the exact defect that file records twice. Fixtures are not a month of use.
