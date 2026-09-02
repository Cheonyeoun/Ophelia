# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Before any structural change** (new top-level `lib/` folder, moving code between layers, adding a dependency between layers, changing the DI/composition root) — read [Docs/Architecture.md](Docs/Architecture.md) first. It is the single source of truth for how this app is engineered and takes precedence over ad hoc decisions made in a session.

## What this is

Ophelia is a Flutter music player built as a hexagonal (ports & adapters) architecture. Dependencies point inward: `core/domain` and `core/usecases` know nothing about Flutter, SQL, HTTP, or `just_audio` — everything external is plugged in through an interface (port) the domain defines and infrastructure implements. See Docs/Architecture.md §2–3 for the full reasoning.

As of now this is a skeleton: folder structure and the architectural lint rule are in place, but no business logic, ports, adapters, or use cases have been written yet.

## Commands

```bash
flutter pub get              # install dependencies
flutter analyze              # static analysis + architecture lint (see below)
dart run import_lint         # architecture lint only, same checks as flutter analyze
flutter test                 # run all tests
flutter test test/widget_test.dart   # run a single test file
flutter run                  # run the app on a connected device/emulator
```

## Architecture lint (import direction)

`analysis_options.yaml` registers the `import_lint` analyzer plugin (§4 of Docs/Architecture.md) with rules forbidding `lib/core/domain/**` and `lib/core/usecases/**` from importing anything under `lib/data/**`, `lib/playback/**`, or `lib/features/**`. Violations are reported as `severity: error` and fail both `flutter analyze` and `dart run import_lint` (non-zero exit). After editing the `plugins:`/`import_lint:` section of `analysis_options.yaml`, restart the Dart Analysis Server for IDE diagnostics to pick up the change.

## `lib/` layout (feature-first, per Docs/Architecture.md §4)

```
lib/
  core/
    domain/      # entities + ports (interfaces) — no Flutter imports, no dependency on data/playback/features
    usecases/    # application layer — one class per user-meaningful action, depends only on ports
    error/       # Failure types, Result<T> wrapper
  data/          # adapters implementing ports: media_source/, local_db/, downloads/, export_import/
  playback/
    engine/      # JustAudioPlaybackAdapter, audio_service handler
  features/      # presentation (Flutter + Riverpod): home/, library/, profile/, playback_ui/, settings/, search/
  app/           # composition root: router.dart, theme.dart, providers.dart
```

Only `data/`, `playback/`, and `features/` are allowed to import packages directly (each adapter is the only place that knows its underlying package, per §3.3). Screens call use cases through Riverpod providers — they never call adapters directly (§3.4).
