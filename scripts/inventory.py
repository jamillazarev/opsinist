#!/usr/bin/env python3
"""A deterministic inventory of a tree — the map of the territory, never the territory.

The mechanical half of a corridor read (entering.md): join, migration and import all start
on ground with no declarations, and a model sent to wander it reads a different subset every
run. This script reads none of the contents — it counts, sizes, sorts and names — so two runs
over the same tree produce byte-identical output, and an audit built on it starts from a
measured base instead of a remembered walk.

  inventory.py [root] [--out FILE]

Prints markdown to stdout. It writes into the tree only when --out says so — which is what
keeps it guest-safe by construction: in someone else's repository the record's root is
elsewhere, and the caller points --out there (permissions.md). No dates in the output: the
inventory is a function of the tree; when it was taken belongs to the thread that took it.

Stdlib only. Exit 0; 2 when the root cannot be read.
"""

import hashlib
import subprocess
import sys
from pathlib import Path

SKIP_DIRS = {".git", "node_modules", "dist", "build", "vendor", "__pycache__",
             ".venv", "target", ".next", ".cache"}
MANIFESTS = ["README.md", "README.rst", "LICENSE", "LICENSE.md", "CLAUDE.md", "AGENTS.md",
             "GEMINI.md", "config.md", "package.json", "pyproject.toml", "requirements.txt",
             "Cargo.toml", "go.mod", "Gemfile", "composer.json", "Makefile", "Dockerfile",
             "docker-compose.yml", "docker-compose.yaml", ".pre-commit-config.yaml"]
LAYERS = ["tasks", "roles", "docs", "process", "pipelines", "runs", "skills", "sources",
          "templates"]


def git(root, *args):
    try:
        r = subprocess.run(["git", "-C", str(root), *args], capture_output=True,
                           text=True, timeout=30)
        return r.stdout.strip() if r.returncode == 0 else None
    except Exception:
        return None


def walk(root: Path):
    """Every regular file under root, skipping the heavy dirs — sorted, symlinks not
    followed, sizes from stat. Nothing here opens a file."""
    files, skipped = [], set()
    stack = [root]
    while stack:
        d = stack.pop()
        try:
            entries = sorted(d.iterdir())
        except OSError:
            continue
        for e in entries:
            rel = e.relative_to(root)
            if e.is_symlink():
                continue
            if e.is_dir():
                if e.name in SKIP_DIRS:
                    skipped.add(e.name)
                else:
                    stack.append(e)
            elif e.is_file():
                try:
                    files.append((str(rel), e.stat().st_size))
                except OSError:
                    pass
    return sorted(files), sorted(skipped)


def human(n):
    for u in ("B", "KB", "MB", "GB"):
        if n < 1024 or u == "GB":
            return f"{n:.0f}{u}" if u == "B" else f"{n / 1.0:.1f}{u}"
        n /= 1024
    return f"{n}B"


def main(argv):
    out_path = None
    if "--out" in argv:
        i = argv.index("--out")
        out_path = Path(argv[i + 1]) if i + 1 < len(argv) else None
        argv = argv[:i] + argv[i + 2:]
    root = Path(argv[0]).resolve() if argv else Path.cwd()
    if not root.is_dir():
        print(f"✗ {root} is not a directory")
        return 2

    tracked = git(root, "ls-files")
    if tracked is not None:
        pairs = []
        for rel in sorted(tracked.split("\n")):
            if not rel:
                continue
            p = root / rel
            if p.is_file() and not p.is_symlink():
                try:
                    pairs.append((rel, p.stat().st_size))
                except OSError:
                    pass
        files, skipped, source = pairs, [], "git ls-files"
    else:
        files, skipped = walk(root)
        source = "filesystem walk (not a git repository)"

    total = sum(s for _, s in files)
    by_ext, by_top, biggest = {}, {}, sorted(files, key=lambda x: (-x[1], x[0]))[:10]
    for rel, size in files:
        ext = Path(rel).suffix.lower() or "(none)"
        c, s = by_ext.get(ext, (0, 0))
        by_ext[ext] = (c + 1, s + size)
        top = rel.split("/")[0] if "/" in rel else "(root)"
        by_top[top] = by_top.get(top, 0) + 1

    lines = [f"# Inventory — {root.name}", "",
             "The map of the territory, not the territory: counted and sized, nothing read.",
             f"Source: {source}.", ""]
    if skipped:
        lines += [f"Skipped by name: {', '.join(skipped)}.", ""]

    lines += [f"## Shape", "", f"- files: {len(files)} · total {human(total)}"]
    branch = git(root, "rev-parse", "--abbrev-ref", "HEAD")
    if branch:
        n = git(root, "rev-list", "--count", "HEAD") or "?"
        first = (git(root, "log", "--reverse", "--format=%as") or "?").split("\n")[0]
        last = git(root, "log", "-1", "--format=%as") or "?"
        lines += [f"- git: branch `{branch}` · {n} commits · {first} → {last}"]
        remotes = git(root, "remote")
        lines += [f"- remotes: {', '.join(remotes.split()) if remotes else 'none'}"]
    lines += [""]

    lines += ["## Top-level directories", ""]
    for top, c in sorted(by_top.items(), key=lambda x: (-x[1], x[0])):
        lines += [f"- `{top}/` — {c} files" if top != "(root)" else f"- (root) — {c} files"]
    lines += ["", "## By extension", ""]
    for ext, (c, s) in sorted(by_ext.items(), key=lambda x: (-x[1][0], x[0]))[:15]:
        lines += [f"- `{ext}` — {c} files · {human(s)}"]
    lines += ["", "## Largest files", ""]
    for rel, size in biggest:
        lines += [f"- `{rel}` — {human(size)}"]

    present = [m for m in MANIFESTS if (root / m).is_file()]
    lines += ["", "## Manifests and entry points", ""]
    lines += [f"- `{m}`" for m in present] or ["- none of the usual names"]
    wf = root / ".github" / "workflows"
    if wf.is_dir():
        lines += [f"- `.github/workflows/` — {len(list(wf.glob('*.y*ml')))} workflow(s)"]

    layer_lines = []
    for d in LAYERS:
        p = root / d
        if p.is_dir():
            layer_lines.append(f"- `{d}/` — {sum(1 for _ in p.rglob('*.md'))} md files")
    lines += ["", "## Layers this methodology would look for", ""]
    lines += layer_lines or ["- none — bare ground, which is an answer, not a blank"]

    digest = hashlib.sha256("\n".join(lines).encode()).hexdigest()[:16]
    lines += ["", f"`inventory-hash: {digest}` — two runs over the same tree print the same "
                  "hash, or one of them is broken.", ""]
    text = "\n".join(lines)
    if out_path:
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(text, encoding="utf-8")
        print(f"✓ inventory written to {out_path} (hash {digest})")
    else:
        print(text)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
