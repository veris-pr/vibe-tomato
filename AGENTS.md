# AGENTS.md

This repository contains `Tomato`, a macOS-only menubar Pomodoro app built with SwiftUI.

## Project shape

- App entry: `Tomato/App/TomatoApp.swift`
- Timer/state logic: `Tomato/Models/PomodoroTimer.swift`
- Persistence/stats: `Tomato/Models/SessionStore.swift`
- Settings: `Tomato/Models/AppSettings.swift`
- Menu UI: `Tomato/Views/MenuContentView.swift`
- Charts: `Tomato/Views/StatsChartView.swift`

## Build workflow

- Project file is generated from `project.yml` via XcodeGen.
- If files are added, removed, or moved, run:
  - `xcodegen generate`
- Build with:
  - `xcodebuild -project Tomato.xcodeproj -scheme Tomato -configuration Debug -destination 'platform=macOS' build`

## Product behavior

- The app is menubar-only and should stay macOS-only.
- The timer is always on by default when the app launches.
- Break state is the primary signal:
  - working -> black/default dot
  - onBreak -> orange dot
  - paused -> subdued/neutral
- Clicking the menubar item during break acknowledges the break.
- Metrics currently tracked:
  - `tracked`
  - `missed`
  - `paused`

## UI guardrails

- Keep the UI minimal.
- Avoid introducing color except when it carries product meaning.
- The orange break indicator is intentional and should remain distinct.
- Prefer stable view sizing in `MenuBarExtra`; avoid layouts that swap between differently sized branches.
- Avoid state mutations during initial menu layout. Deferred actions are safer than immediate `onAppear` mutations.

## Persistence guardrails

- Break history is stored at `~/Library/Application Support/Tomato/sessions.json`.
- Preserve backward compatibility when changing persisted models.
- If `BreakRecord` changes, add a migration path rather than assuming a fresh file.

## When editing

- Reuse the existing structure before adding new models or managers.
- Keep timer transitions explicit and easy to audit.
- Be careful with pause/break interactions; they affect analytics semantics.
- If you add assets or source files, regenerate the Xcode project before building.
- Update `README.md` when product behavior changes.

## Good next improvements

- Add tests for timer state transitions and persistence decoding.
- Add migration support for older `sessions.json` formats.
- Consider a clearer month aggregation model if weekly buckets are not desired.
