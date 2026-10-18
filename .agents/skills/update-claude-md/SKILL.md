---
name: update-claude-md
description: >-
  Checklist for keeping CLAUDE.md (the project context file) accurate. Use this
  skill at the end of any task that changed files, folders, commands, env vars,
  dependencies, deployments, feature status or test counts in AutoSense AI.
---

# Update CLAUDE.md

1. List what changed in this task: `git status --short` and `git diff --stat`.
2. For each CLAUDE.md section, ask "is this still true?":
   - **Status at a glance** – versions, live URLs, test counts.
   - **Repository map** – any added/moved/removed folder or key file.
   - **Commands** – any new/changed script or flag.
   - **Environments & config** – env vars, dart-defines, hosts.
   - **Known issues / next steps** – add new ones, delete resolved ones.
   - **Decision log** – append `YYYY-MM-DD — decision — why` for any
     architectural choice.
3. Update `Last updated:` with today's date and a one-line summary.
4. Verify links still resolve:
   `python scripts/check_docs_links.py` (exits non-zero on broken links).
5. Keep the file concise (< 15 KB). Move long explanations to `docs/` and link.
