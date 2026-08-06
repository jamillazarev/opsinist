#!/usr/bin/env python3
"""The one door a stage change goes through (pipelines.md).

A transition is checked against the pipeline's own yaml block — the same data a person
reads — so the declaration and the enforcement cannot drift apart: there is nothing to
drift between. The machine guards; it never advances. Refusing and recording is all it
does — starting the next step stays a person's or the dispatcher's act, which is how
"nothing transitions itself" survives mechanisation untouched.

  transition.py <task-file> <to-stage> --by <name>   perform the move, or refuse with reasons
  transition.py <task-file> <to-stage> --check-only  validate only, write nothing
  transition.py <task-file> --brief                  the state block for a dispatch prompt

Stdlib only, like every script here. Exit 0 clean · 1 refused · 2 cannot even check.
"""

import os
import re
import subprocess
import sys
from datetime import date
from pathlib import Path

STOCK = {"name": "default", "stages": ["build", "review", "accept"],
         "terminal": ["accept"], "gates": {}, "prose_gates": {}}


def root_of(p: Path) -> Path:
    try:
        out = subprocess.run(["git", "rev-parse", "--show-toplevel"], cwd=p.parent,
                             capture_output=True, text=True, timeout=10)
        if out.returncode == 0:
            return Path(out.stdout.strip())
    except Exception:
        pass
    return Path.cwd()


def field(text: str, *names):
    """A task field, wherever the template put it: `**Stage**: x`, `stage: x`, inline after `·`."""
    for n in names:
        m = re.search(r"\*\*" + n + r"\*\*\s*:\s*([^·|\n]+)", text, re.I)
        if not m:
            m = re.search(r"^[ \t]*" + n + r"\s*:\s*(.+)$", text, re.I | re.M)
        if m:
            v = m.group(1).strip()
            if v and "{{" not in v:
                return v, m
    return None, None


def parse_pipeline(text: str):
    """The yaml block of a pipeline file — parsed by hand because the format is ours and
    small, and a dependency for it would be the heavier thing to carry."""
    body = text
    fence = re.search(r"```ya?ml\n(.*?)```", text, re.S)
    if fence:
        body = fence.group(1)
    p = {"name": None, "stages": [], "terminal": [], "gates": {}, "prose_gates": {}}
    in_gates, edge = False, None
    for raw in body.split("\n"):
        # The corpus writes edges with its own glyph — `draft → review` — and the door
        # itself writes that glyph into History; a parser that only reads ASCII `->`
        # silently drops those gates (found by the lenses). Normalise before matching.
        line = raw.replace("→", "->").rstrip()
        if not line.strip() or line.strip().startswith("#"):
            continue
        indent = len(line) - len(line.lstrip())
        s = line.strip()
        if indent == 0:
            in_gates = s.startswith("gates:")
            edge = None
            m = re.match(r"(name|stages|terminal|default_for|starts)\s*:\s*(.*)$", s)
            if m:
                k, v = m.group(1), m.group(2).strip()
                if k in ("stages", "terminal"):
                    p[k] = [x.strip() for x in v.strip("[]").split(",") if x.strip()]
                elif k == "name":
                    p["name"] = v
            continue
        if in_gates and indent == 2:
            m = re.match(r"([\w-]+\s*->\s*[\w-]+)\s*:\s*(.*)$", s)
            if m:
                edge = re.sub(r"\s*->\s*", "->", m.group(1))
                p["gates"][edge] = {}
                rest = m.group(2).strip()
                if rest:  # legacy one-liner prose gate on an edge
                    p["prose_gates"][edge] = rest.strip("\"'")
                continue
            m = re.match(r"([\w-]+)\s*:\s*(.+)$", s)
            if m:  # legacy `review: "prose"` — a stage-keyed prose gate, honestly prose-only
                p["prose_gates"][m.group(1)] = m.group(2).strip().strip("\"'")
                edge = None
            continue
        if in_gates and indent >= 4 and edge:
            m = re.match(r"(check|review_by|fields)\s*:\s*(.+)$", s)
            if m:
                k, v = m.group(1), m.group(2).strip()
                if k == "fields":
                    v = [x.strip() for x in v.strip("[]").split(",") if x.strip()]
                else:
                    v = v.strip("\"'")
                p["gates"][edge][k] = v
    # an inline ladder — `build -> review -> accept` — is a pipeline too (type files hold these)
    if not p["stages"]:
        m = re.search(r"^([\w-]+(?:\s*->\s*[\w-]+)+)\s*$", body, re.M)
        if m:
            p["stages"] = [x.strip() for x in re.split(r"->", m.group(1))]
    if p["stages"] and not p["terminal"]:
        p["terminal"] = [p["stages"][-1]]  # the last stage, unless the file says otherwise
    return p if p["stages"] else None


def _mdir(root: Path, *parts: str) -> Path:
    """The machinery lives under `_ops/` since 0.2.0; a flat root is read as the transitional
    fallback so a not-yet-migrated project fails toward the migration notice, not a stack."""
    nested = root.joinpath("_ops", *parts)
    if nested.exists():
        return nested
    flat = root.joinpath(*parts)
    return flat if flat.exists() else nested


def resolve_pipeline(root: Path, task_text: str):
    """task override → the type's file → _ops/pipelines/ by name → stock. Say which was taken."""
    name, _ = field(task_text, "pipeline")
    if not name:
        tname, _ = field(task_text, "type")
        if tname:
            tf = _mdir(root, "process", "types") / (tname.lower().replace(" ", "-") + ".md")
            if tf.is_file():
                got = parse_pipeline(tf.read_text(encoding="utf-8"))
                if got:
                    return got, f"type {tname}"
                m = re.search(r"^pipeline\s*:\s*(\S+)", tf.read_text(encoding="utf-8"),
                              re.I | re.M)
                if m:
                    name = m.group(1)
    if name:
        pdir = _mdir(root, "pipelines")
        for cand in [pdir / f"{name}.md", pdir / f"{name}.yaml"]:
            if cand.is_file():
                got = parse_pipeline(cand.read_text(encoding="utf-8"))
                if got:
                    return got, f"pipeline {name}"
        if pdir.is_dir():
            for f_ in sorted(pdir.glob("*.md")):
                got = parse_pipeline(f_.read_text(encoding="utf-8"))
                if got and got.get("name") == name:
                    return got, f"pipeline {name}"
        return None, f"pipeline `{name}` is named and no file defines it"
    default = _mdir(root, "process", "types") / "default.md"
    if default.is_file():
        got = parse_pipeline(default.read_text(encoding="utf-8"))
        if got:
            return got, "type default"
    return dict(STOCK), "stock default"


def review_by_other(task_text: str, worker: str) -> bool:
    """Only History counts. A requirement in the body — "needs approval by legal" — reads
    exactly like a sign-off to a whole-file search; the record section is where acts live."""
    m = re.search(r"^## History\s*$", task_text, re.M)
    history = task_text[m.end():] if m else ""
    for m in re.finditer(r"(?:reviewed|approved|accepted)\s+by[:\s]+@?([\w.@-]+)",
                         history, re.I):
        if not worker or m.group(1).lower() != worker.lower():
            return True
    return False


def gate_reasons(root: Path, task_text: str, gates: dict, edge: str, worker: str):
    """Every unmet condition on the edge, each with what would satisfy it —
    failure returns to the worker with the output, never to the reviewer."""
    reasons = []
    g = gates.get(edge, {})
    if "check" in g:
        try:
            r = subprocess.run(g["check"], shell=True, cwd=root, capture_output=True,
                               text=True, timeout=300)
        except subprocess.TimeoutExpired:
            reasons.append(f"check `{g['check']}` timed out after 300s")
        else:
            if r.returncode != 0:
                tail = "\n    ".join(((r.stdout or "") + (r.stderr or ""))
                                     .strip().split("\n")[-5:])
                reasons.append(f"check `{g['check']}` exited {r.returncode}:\n    {tail}")
    if g.get("review_by") == "non-author" and not review_by_other(task_text, worker):
        reasons.append("no review in the file from someone who is not the worker"
                       + (f" (worker: {worker})" if worker else ""))
    for f_ in g.get("fields", []):
        v, _ = field(task_text, f_)
        if not v:
            reasons.append(f"field `{f_}` is absent or empty")
    return reasons


def brief(task: Path, text: str, pipe: dict, via: str, stage: str, worker: str):
    stages = pipe["stages"]
    print(f"stage: {stage} ({' → '.join(stages)}; via {via})")
    if stage not in stages:
        print(f"✗ stage `{stage}` is not on this ladder — fix the field before dispatch")
        return 1
    i = stages.index(stage)
    if i + 1 < len(stages):
        nxt = stages[i + 1]
        edge = f"{stage}->{nxt}"
        needs = []
        g = pipe["gates"].get(edge, {})
        if "check" in g:
            needs.append(f"check `{g['check']}` clean")
        if g.get("review_by") == "non-author":
            needs.append("a review from a non-author in the file")
        for f_ in g.get("fields", []):
            needs.append(f"field `{f_}` present")
        for k, v in pipe["prose_gates"].items():
            if k in (edge, nxt):
                needs.append(f'prose-only gate: "{v}" — nothing holds this one')
        line = f"legal: → {nxt}"
        if needs:
            line += " — needs: " + " · ".join(needs)
        print(line)
    for back in stages[:i]:
        print(f"legal: → {back} (return)")
    for t in pipe["terminal"]:
        print(f"not yours: {t} is terminal — acceptance belongs to whoever owns it, "
              f"never the worker; the door requires --by, and --by is not "
              f"{worker or 'the assignee'}")
    print("the door: scripts/transition.py — a stage edited by hand is a bypass the "
          "preflight refuses")
    return 0


def main(argv):
    args = [a for a in argv if not a.startswith("--")]
    flags = {a for a in argv if a.startswith("--") and "=" not in a}
    by = None
    for j, a in enumerate(argv):
        if a == "--by" and j + 1 < len(argv):
            by = argv[j + 1]
            args = [x for x in args if x != by]
    if not args:
        print(__doc__.strip())
        return 2
    task = Path(args[0])
    if not task.is_file():
        print(f"✗ no file at {task} — an id resolves to a path, and to nothing else")
        return 2
    text = task.read_text(encoding="utf-8")
    root = root_of(task.resolve())
    stage, mstage = field(text, "stage", "status")
    worker = (field(text, "assignee", "assigned", "author", "worker")[0] or "").split("(")[0].strip()
    pipe, via = resolve_pipeline(root, text)
    if pipe is None:
        print(f"✗ {via}")
        return 2
    if "--brief" in flags:
        return brief(task, text, pipe, via, stage or "(unset)", worker)

    if len(args) < 2:
        print("✗ name the target stage, or ask for --brief")
        return 2
    to = args[1]
    stages = pipe["stages"]
    reasons = []
    if stage not in stages:
        reasons.append(f"current stage `{stage}` is not on this ladder ({' → '.join(stages)})")
    if to not in stages:
        reasons.append(f"`{to}` is not a stage of this pipeline ({' → '.join(stages)}; via {via})")
    if not reasons:
        i, j = stages.index(stage), stages.index(to)
        if j == i:
            reasons.append(f"already at `{stage}` — a no-op transition records nothing")
        elif j > i + 1:
            reasons.append(f"stages are linear — `{stage}` → `{to}` skips "
                           f"`{stages[i + 1]}`; no branches, no jumps")
        if j > i:  # gates hold the way forward; a return to an earlier stage is always open
            reasons += gate_reasons(root, text, pipe["gates"], f"{stage}->{to}", worker)
        if to in pipe["terminal"]:
            if not by:
                reasons.append("a terminal stage needs --by: acceptance is a deliberate act "
                               "by a named someone, never a side effect")
            elif worker and by.lower() == worker.lower():
                reasons.append(f"--by {by} is the worker — whoever did the work does not "
                               "move it to done; meeting the bar earns the review, not the status")
    for k, v in pipe["prose_gates"].items():
        if k in (f"{stage}->{to}", to):
            print(f'! gate on `{k}` is prose-only — "{v}" — the validator cannot hold it')
    if reasons:
        print(f"✗ {task.name}: {stage} → {to} refused")
        for r in reasons:
            print(f"  ✗ {r}")
        return 1
    if "--check-only" in flags:
        print(f"✓ {stage} → {to} would pass (via {via})")
        return 0
    if not by:
        print("✗ every recorded act carries who performed it — pass --by")
        return 2
    s, e = mstage.span(1)
    text = text[:s] + to + text[e:]
    line = f"- {date.today().isoformat()} — transition {stage} → {to}, by {by}"
    if re.search(r"^## History\s*$", text, re.M):
        text = re.sub(r"(^## History\s*\n)", r"\1" + line + "\n", text, count=1, flags=re.M)
    else:
        text = text.rstrip() + f"\n\n## History\n{line}\n"
    # The write is the only copy of the canon — a truncate-then-die leaves half a task.
    tmp = task.with_suffix(task.suffix + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    os.replace(tmp, task)
    print(f"✓ {task.name}: {stage} → {to}, by {by} (via {via}) — recorded")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
