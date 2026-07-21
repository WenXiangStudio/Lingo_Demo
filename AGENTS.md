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

## Flutter Tooling Rule

- On this machine, `flutter.bat` / `dart.bat` wrapper commands often hang inside the sandbox while trying to access tool state outside the workspace.
- For Flutter wrapper operations, prefer running outside the sandbox with approval instead of waiting for a long timeout:
  - `flutter --version`
  - `flutter analyze`
  - `flutter build`
  - `flutter test`
  - `dart format` when invoked through `flutter\bin\dart.bat`
- Always set D-drive environment variables before invoking Flutter/Dart tools:
  - `APPDATA=D:\LingoDemo\.dart_appdata`
  - `LOCALAPPDATA=D:\LingoDemo\.dart_localappdata`
  - `PUB_CACHE=D:\PubCache`
  - `PUB_HOSTED_URL=https://pub.flutter-io.cn` when package resolution/download may occur.
- Direct Dart SDK calls can run in the sandbox if these env vars are set:
  - `D:\FlutterSDK\flutter\bin\cache\dart-sdk\bin\dart.exe format ...`
  - `D:\FlutterSDK\flutter\bin\cache\dart-sdk\bin\dart.exe analyze ...`
- If a Flutter wrapper command is needed and no approved prefix exists yet, request escalation immediately with a concise justification; do not first spend several minutes waiting for sandbox timeout.

## Analyzer Troubleshooting

If `flutter analyze` / `dart analyze` times out on this project:

1. Assume it is a cold-start/tooling cost first, not a code regression. This repo has a large dependency graph (145 packages and roughly 9k dependency Dart files), so the analyzer often spends most of its time loading Flutter/analyzer/Drift/Riverpod/serialization summaries.
2. Do not keep rerunning full analysis. Switch to targeted checks on the changed files only, from `D:\LingoDemo\lingo_app`, and keep `--no-pub` when possible.
3. If the change is UI/runtime-only, validate by rebuilding the target (`flutter build windows --debug`) instead of waiting on a full analyzer pass.
4. Only treat a full-project analyzer run as a final gate when time allows; it is not a reliable fast feedback loop on this machine.

<!-- BEGIN AGENT-CONTEXT -->
## Agent Task Context

This project uses `agent-mem` and `.agents/` for compact cross-window and cross-agent project memory.

- `AGENTS.md` is stable project guidance and may be loaded automatically.
- `.agents/project-state.md` stores durable cross-task facts and is injected when `.agents/context-mode` is `auto`.
- `.agents/tasks/<task>/state.md` is the authoritative task state and is injected only when `.agents/context-mode` is `auto`.
- `.agents/events/*.jsonl` stores structured memory events; user-level SQLite FTS5 indexing lives under `~/.agent-mem/` when writable.
- `.agents/tasks/<task>/handoffs/` stores historical handoff notes. Do not read all handoffs by default.
- `.\agent-mem.ps1 task new <task-name>` carries forward useful sections from the previously active task state.
- `.\agent-mem.ps1 enter <tool>` prepares state, validates it, and launches supported terminal tools.
- `.\agent-mem.ps1 prompt <resume|handoff|new-task>` prints copyable in-agent prompt templates.
- `.\am.ps1` is a short wrapper for `.\agent-mem.ps1`.
- `.\agent-task.ps1` remains as a compatibility wrapper for older commands.
- Before switching windows, compacting context, or changing agents, update the active task state.
- Validate state structure with `.\agent-mem.ps1 validate` after manual edits.

Use:

```powershell
.\agent-mem.ps1 status
.\agent-mem.ps1 enter codex
.\agent-mem.ps1 prompt handoff --to claude-code --copy
.\agent-mem.ps1 task use <task-name>
.\agent-mem.ps1 task new <task-name>
.\agent-mem.ps1 task off
.\agent-mem.ps1 handoff --summary "handoff summary"
.\agent-mem.ps1 remember "durable project fact"
.\agent-mem.ps1 remember --global "durable user fact"
.\agent-mem.ps1 search "query"
.\agent-mem.ps1 validate

# Legacy wrapper:
.\agent-task.ps1 status
.\agent-task.ps1 use <task-name>
.\agent-task.ps1 new <task-name>
.\agent-task.ps1 off
.\agent-task.ps1 handoff
.\agent-task.ps1 remember "durable project fact"
```
<!-- END AGENT-CONTEXT -->
