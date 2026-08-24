# LingoDemo

LingoDemo is a Flutter vocabulary-learning application for Windows, Android,
and iOS. The current desktop workflow combines built-in word books, spaced
practice, AI-assisted exercises, speaking practice, bilingual UI, cloud TTS
production tools, static word/example audio, and a 44-phoneme Cambridge
British English IPA screen.

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

Do not commit API keys, cloud credentials, SSH private keys, generated audio
packages, local databases, or Flutter build output. Deployment details and
credential boundaries are documented in
`docs/lighthouse_word_audio_development.md`.

## Phoneme assets

The 44 app-owned WAV files are in
`lingo_app/assets/phonetics/british/`. Validate their catalog coverage and WAV
format from the repository root:

```powershell
python scripts\validate_phoneme_assets.py
```

See `docs/phonetics_audio_production.md` for source provenance and the asset
contract.
