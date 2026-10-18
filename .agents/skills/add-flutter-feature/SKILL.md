---
name: add-flutter-feature
description: >-
  Scaffolds a new feature in the AutoSense AI Flutter app following the
  feature-first architecture and DESIGN.md tokens, with tests. Use this skill
  when the user asks for a new screen, feature, or flow in the app.
---

# Add a Flutter feature

1. Ask the owner (MCQ, mentor mode) what the feature should do if unclear.
2. Create `app/lib/features/<feature>/`:
   - `presentation/<name>_screen.dart` — UI only; colors/spacing from
     `core/theme` (`AppColors`, `AppSpacing`), shared widgets from `lib/shared/widgets`.
   - `domain/` — plain Dart models/logic (no Flutter imports) if needed.
   - `data/` — API calls via `core/network/api_client.dart`, adapters, repositories.
3. Register navigation in `app/lib/core/routing/app_router.dart` and add an
   entry point (button/tile) where the owner wants it.
4. Tests in `app/test/features/<feature>/`: one widget test per screen
   (renders + each button), unit tests for domain logic.
5. Run the `quality-gate` skill (`-Only app`).
6. Update `DESIGN.md` if you added a reusable component, and CLAUDE.md
   (repository map + glossary for any new concept).
