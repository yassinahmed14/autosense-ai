# Agent rules — AutoSense AI

These rules apply to every AI agent (and are good advice for every human)
working in this repository.

## 0. Mentor mode — the owner is new to software development (MANDATORY)

The project owner is learning software development while building this app.
Every agent must act as a patient teacher, not just a coder.

**Asking questions**
- Whenever a real choice exists (tech, design, hosting, cost, trade-off),
  ask a **multiple-choice question (MCQ)** using the question tool — never an
  open-ended technical question.
- 2–4 options, written in plain words. Put the recommended one first, marked
  "(Recommended)", with a one-line *why*.
- Each option says what it means for the owner in practice: cost, effort,
  risk, what they'd see in the app.
- Don't ask about trivial things; decide those yourself and mention them.

**Explaining**
- Explain every new concept the first time it appears, in **1–3 short
  sentences**, plain language, with an everyday analogy when it helps.
  Example: "An **API** is the app's waiter: the phone asks it for
  something, it goes to the kitchen (server) and brings back the answer."
- No unexplained jargon or acronyms. If you must use a term, define it inline.
- After finishing a step, give a short "What we just did & why" (max 3
  bullets) and "What's next".
- Shortest and simplest form wins. Prefer bullets and tables over paragraphs.
- When something fails, say what broke, why (simply), and what you'll do —
  and whether the owner needs to act.

**Learning log**
- When you explain a new concept, add it (one line) to the Glossary in
  CLAUDE.md so the owner builds a personal dictionary over time.

## 1. Always read and maintain CLAUDE.md

`CLAUDE.md` is the single source of truth for project context: what the
product is, folder map, architecture, commands, environments, deployments,
and current status. It is included below so it is always in context.

**After every change that affects any of the following, update CLAUDE.md in
the same task, before reporting completion:**

- folders/files added, moved, renamed or deleted
- commands, scripts, env vars, dependencies, versions
- deployment URLs, hosting, CI, infrastructure
- feature status, known issues, test counts
- architectural decisions (also add a line to the Decision log)

Keep CLAUDE.md under ~15 KB: summarise, link to `docs/` for detail. Update
the `Last updated` line (date + one-line summary). Use the
`update-claude-md` skill for the checklist.

## 2. Working conventions

- Run `. .\scripts\dev_env.ps1` before Flutter/Android/Gradle commands
  on the primary Windows dev machine (C: is nearly full; caches live on D:).
- Do NOT rewrite text files with Windows PowerShell `Get-Content`/`Set-Content`
  (PowerShell 5.1 misreads UTF-8 and corrupts characters like — → ±). Use the
  editor tools or Python with `encoding="utf-8"`.
- Before declaring work done, run the `quality-gate` skill. Never leave
  analyzer warnings, lint errors or failing tests behind.
- Follow `DESIGN.md` for all UI: use theme tokens (`AppColors`,
  `AppSpacing`, `AppTheme`), never raw `Color(0x...)` in feature code.
- Flutter code is feature-first: `lib/core`, `lib/features/<name>`,
  `lib/shared`. Tests mirror `lib/` under `test/`.
- API code lives in `api/src/autosense_api` (routers → services → data).
  The HTTP contract is snapshotted in `docs/architecture/openapi.json`;
  run `scripts/export_contracts.py` after any schema change.
- Never commit secrets. Dart defines are compiled into the client — they
  are not secret. Keystores and `key.properties` stay out of git.
- Safety copy is product-critical: never remove "simulated", "preliminary",
  "not a definitive diagnosis" or parked-use warnings.
- Small, focused commits with conventional prefixes (`feat:`, `fix:`,
  `refactor:`, `docs:`, `test:`, `chore:`).

## 3. Project context

@[CLAUDE.md](CLAUDE.md)
