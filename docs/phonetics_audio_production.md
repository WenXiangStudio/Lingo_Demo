# British phoneme audio production

Status: 44 Cambridge British English phoneme recordings are integrated and
validated.

## Active source and mapping

The source delivery is archived outside Git at:

`D:\LingoDemoData\source_archives\cambridge_ipa_44.zip`

Archive SHA-256:

`ABB37535A8B8592C8C741720E7CDD9727153B6D6DC47622C4C185A9B2A39ECB5`

The source contains 44 stereo Opus files. Each file was matched to the Dart
catalog by its IPA symbol rather than by relying on directory order. The final
names use the stable `id` values in
`lingo_app/lib/features/phonetics/data/british_phoneme_catalog.dart`.

## Runtime contract

Final files live in `lingo_app/assets/phonetics/british/` and must be:

- RIFF/WAVE;
- mono;
- signed 16-bit PCM;
- 44.1 kHz or 48 kHz;
- non-empty and not completely silent;
- named `<phoneme-id>.wav` for every catalog entry.

The current delivery is mono PCM16 at 48 kHz. It is bundled by `pubspec.yaml`,
played from memory by the phonetics screen, and never falls back to cloud TTS.

## Reproduction

FFmpeg is available at `D:\yt_dlp\ffmpeg.exe`. Extract the archived source to a
temporary directory on the D drive, preserve the IPA-to-ID mapping, and convert
each selected source file with the equivalent of:

```powershell
D:\yt_dlp\ffmpeg.exe -i <source.opus> -ac 1 -ar 48000 -c:a pcm_s16le <phoneme-id.wav>
```

Do not overwrite reviewed app assets solely because a conversion command
succeeds. The IPA mapping and audible result must both be checked.

## Validation

From the repository root:

```powershell
python scripts\validate_phoneme_assets.py
```

From `lingo_app/`:

```powershell
$env:PUB_CACHE='D:\PubCache'
$env:APPDATA='D:\LingoDemo\.dart_appdata'
$env:LOCALAPPDATA='D:\LingoDemo\.dart_localappdata'
flutter test --no-pub test\phoneme_catalog_test.dart test\phonetics_screen_test.dart
```

The validator checks catalog coverage and WAV structure. Automated checks do
not replace a listening pass; in particular, unusually long cues should be
reviewed for retained word material.
