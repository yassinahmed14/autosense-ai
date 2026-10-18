"""Check that relative Markdown links in the repo point at existing files.

Usage: python scripts/check_docs_links.py   (exit code 1 if any link is broken)
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SKIP_DIRS = {".git", ".venv", "build", ".dart_tool", "node_modules", ".gradle"}
LINK = re.compile(r"\]\(([^)\s]+)\)")


def main() -> int:
    broken = []
    for md in ROOT.rglob("*.md"):
        if SKIP_DIRS & set(md.relative_to(ROOT).parts):
            continue
        for target in LINK.findall(md.read_text(encoding="utf-8", errors="replace")):
            if re.match(r"^(https?:|mailto:|#|file:)", target):
                continue
            path = target.split("#", 1)[0]
            if path and not (md.parent / path).exists():
                broken.append(f"{md.relative_to(ROOT)} -> {target}")
    print("\n".join(broken) or "All relative links OK")
    return 1 if broken else 0


if __name__ == "__main__":
    sys.exit(main())
