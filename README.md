# LingoDemo

LingoDemo is a Flutter vocabulary-learning application for Windows, Android,
and iOS. The current desktop workflow combines built-in word books, spaced
practice, AI-assisted exercises, speaking practice, bilingual UI, cloud TTS
production tools, static word/example audio, a 44-phoneme Cambridge British
English IPA screen, and guided English narration with a learning library,
review queue, and progress tracking.

## Repository layout

- `lingo_app/`: Flutter application, bundled assets, and automated tests.
- `word_books/`: source CSV workspace. Runtime copies are under
  `lingo_app/assets/word_books/`.
- `deploy/lighthouse/`: reviewed scripts and templates for publishing static
  word and example WAV files.
- `docs/`: production notes and operational reference material.
- `scripts/`: read-only or bounded project validation utilities.

Generated databases, TTS caches, release packages, model downloads, and source
archives are kept outside Git under `D:\LingoDemoData\`. On Windows, application
data is resolved through `getLingoDataDir()` and stored in that directory.

## Development

Prerequisites:

- Flutter stable with Windows desktop support
- Visual Studio C++ desktop tooling for Windows builds
- PowerShell 7

From `D:\LingoDemo\lingo_app`:

```powershell
$env:APPDATA='D:\LingoDemo\.dart_appdata'
$env:LOCALAPPDATA='D:\LingoDemo\.dart_localappdata'
$env:PUB_CACHE='D:\PubCache'
$env:PUB_HOSTED_URL='https://pub.flutter-io.cn'

flutter pub get
flutter test --no-pub
flutter build windows --debug
```

Database schema changes must include the corresponding generated Drift code
in `lingo_app/lib/data/database/app_database.g.dart`. Regenerate it from
`lingo_app/` with the same environment variables before running validation:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Do not commit API keys, cloud credentials, SSH private keys, generated audio
packages, local databases, or Flutter build output. Deployment details and
credential boundaries are documented in
`docs/lighthouse_word_audio_development.md`.

## Narration practice

Open Narration from the home screen to record speech or enter a transcript.
The flow preserves the original transcript, asks the learner to confirm a
Chinese translation and a target English expression, then produces error
analysis, collected words, knowledge points, and corrected expressions.
Confirming the final expression saves learning items for later review and
progress tracking. AI settings include a reasoning toggle, with a separate
override for each narration session.

Narration records use the existing local database. Retained recordings are
encrypted under `D:\LingoDemoData\lingo_narration_audio\`, and JSON exports go
under `D:\LingoDemoData\narration_exports\`. Encryption keys use platform secure
storage. Application data paths are resolved through `getLingoDataDir()` on
every platform.

The [narration learning design](docs/narration_learning_design.md) describes
the intended workflow and learning rules.

## Documentation

- [Narration learning design](docs/narration_learning_design.md)
- [Phonetics audio production](docs/phonetics_audio_production.md)
- [Lighthouse word audio development](docs/lighthouse_word_audio_development.md)
- [TTS model evaluation samples](docs/tts_model_evaluation_samples.md)

## Phoneme assets

The 44 app-owned WAV files are in
`lingo_app/assets/phonetics/british/`. Validate their catalog coverage and WAV
format from the repository root:

```powershell
python scripts\validate_phoneme_assets.py
```

See `docs/phonetics_audio_production.md` for source provenance and the asset
contract.
