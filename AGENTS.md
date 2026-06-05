# Agent Instructions

## Project

`LingoDemo` is the current project. Before making changes, read the local README, package metadata, and relevant source files.

## Working Rules

- Read current files before changing behavior.
- Do not revert user changes or unrelated generated files.
- Keep edits scoped to the requested task.
- Prefer existing project patterns over new abstractions.
- Do not add large generated artifacts to git unless explicitly requested.

## D Drive Rule

- **ALL project-related files MUST go on the D drive**, never on C.
  - Database: `D:\LingoDemoData\lingo.db`
  - TTS cache: `D:\LingoDemoData\lingo_tts_cache\`
  - TTS models: `D:\LingoDemoData\lingo_tts_models\`
  - Any future generated data, downloads, or caches go under `D:\LingoDemoData\`
- **The app uses `getLingoDataDir()`** (`lib/core/data_dir.dart`) which resolves to `D:\LingoDemoData` on Windows and the platform document directory on Android/iOS.
- **Flutter/Dart pub cache**: Set `PUB_CACHE=D:\PubCache` in the environment so packages are downloaded to D drive.
- Do NOT use `getApplicationDocumentsDirectory()` directly — use `getLingoDataDir()` from `lib/core/data_dir.dart`.

## i18n Rules

- **All user-visible strings MUST be translated** using `AppStrings.get(key, lang)`. Never hardcode English strings in widgets.
- **Add new strings to the dictionary** at `lib/core/i18n/app_strings.dart` with both `en` and `zh` entries.
- **Default language is English (`'en'`)**. Users can switch to Chinese (`'zh'`) in Settings → Language.
- **String keys use lowercase underscore format** (e.g., `'start_practice'`, `'no_words_yet'`).
- **For dynamic strings**, use `{key}` interpolation: `AppStrings.get('n_words', lang, params: {'count': n.toString()})`.
- **Language state** is managed by `languageProvider` (StateNotifierProvider) and persisted to Drift `settings` table via `SettingsRepository`.
- **Every screen** must `ref.watch(languageProvider)` at the top of its `build()` method.
- **AI provider display names** and the app title "LingoDemo" remain in English (proper nouns/brand names).

## Commands

Project commands:

```powershell
cd lingo_app
$env:PUB_CACHE='D:\PubCache'; $env:APPDATA='D:\LingoDemo\.dart_appdata'; $env:LOCALAPPDATA='D:\LingoDemo\.dart_localappdata'
flutter build windows --debug
```

## Analyzer Troubleshooting

If `flutter analyze` / `dart analyze` times out on this project:

1. Assume it is a cold-start/tooling cost first, not a code regression. This repo has a large dependency graph (145 packages and roughly 9k dependency Dart files), so the analyzer often spends most of its time loading Flutter/analyzer/Drift/Riverpod/serialization summaries.
2. Do not keep rerunning full analysis. Switch to targeted checks on the changed files only, from `D:\LingoDemo\lingo_app`, and keep `--no-pub` when possible.
3. If the change is UI/runtime-only, validate by rebuilding the target (`flutter build windows --debug`) instead of waiting on a full analyzer pass.
4. Only treat a full-project analyzer run as a final gate when time allows; it is not a reliable fast feedback loop on this machine.

<!-- BEGIN AGENT-CONTEXT -->
## Agent Task Context

This project uses `.agents/` for compact cross-window and cross-agent handoff state.

- `AGENTS.md` is stable project guidance and may be loaded automatically.
- `.agents/project-state.md` stores durable cross-task facts and is injected when `.agents/context-mode` is `auto`.
- `.agents/tasks/<task>/state.md` is task state and is injected only when `.agents/context-mode` is `auto`.
- `.agents/tasks/<task>/handoffs/` stores historical handoff notes. Do not read all handoffs by default.
- `.\agent-task.ps1 new <task-name>` carries forward useful sections from the previously active task state.
- Before switching windows, compacting context, or changing agents, update the active task state and durable project state when facts should carry across tasks.

Use:

```powershell
.\agent-task.ps1 status
.\agent-task.ps1 use <task-name>
.\agent-task.ps1 new <task-name>
.\agent-task.ps1 off
.\agent-task.ps1 handoff
.\agent-task.ps1 remember "durable project fact"
```
<!-- END AGENT-CONTEXT -->
