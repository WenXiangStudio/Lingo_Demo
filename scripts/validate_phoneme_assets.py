#!/usr/bin/env python3
"""Validate the project-owned British phoneme WAV asset contract.

This is intentionally a local, read-only gate. It never downloads, synthesizes,
uploads, or rewrites an audio file. The expected IDs are read from the Dart
catalog so the validator cannot silently drift from the application.
"""

from __future__ import annotations

import argparse
import re
import sys
import wave
from pathlib import Path


EXPECTED_SAMPLE_RATES = {44_100, 48_000}
ID_PATTERN = re.compile(r"\bid:\s*'([^']+)'")


def project_root() -> Path:
    return Path(__file__).resolve().parents[1]


def parse_catalog_ids(catalog_path: Path) -> list[str]:
    source = catalog_path.read_text(encoding="utf-8")
    ids = ID_PATTERN.findall(source)
    if not ids:
        raise ValueError(f"No phoneme IDs found in {catalog_path}")
    duplicates = sorted({phoneme_id for phoneme_id in ids if ids.count(phoneme_id) > 1})
    if duplicates:
        raise ValueError(f"Duplicate phoneme IDs in catalog: {', '.join(duplicates)}")
    return ids


def inspect_wav(path: Path) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    try:
        with wave.open(str(path), "rb") as audio:
            channels = audio.getnchannels()
            sample_width = audio.getsampwidth()
            sample_rate = audio.getframerate()
            frame_count = audio.getnframes()
            compression = audio.getcomptype()
            payload = audio.readframes(frame_count)
    except (EOFError, OSError, wave.Error) as error:
        return [f"{path.name}: cannot read WAV ({error})"], warnings

    if compression != "NONE":
        errors.append(f"{path.name}: compression must be PCM (got {compression})")
    if channels != 1:
        errors.append(f"{path.name}: channels must be 1 (got {channels})")
    if sample_width != 2:
        errors.append(f"{path.name}: sample width must be 16-bit (got {sample_width * 8})")
    if sample_rate not in EXPECTED_SAMPLE_RATES:
        errors.append(
            f"{path.name}: sample rate must be 44100 or 48000 Hz (got {sample_rate})"
        )
    if frame_count <= 0 or not payload:
        errors.append(f"{path.name}: audio data is empty")
    elif not any(payload):
        errors.append(f"{path.name}: audio data is completely silent")

    if sample_rate > 0 and frame_count > 0:
        duration_ms = frame_count * 1000 / sample_rate
        if duration_ms < 80:
            warnings.append(f"{path.name}: very short ({duration_ms:.0f} ms); audition carefully")
        elif duration_ms > 2500:
            warnings.append(f"{path.name}: long ({duration_ms:.0f} ms); check for a retained word")

    return errors, warnings


def validate(asset_dir: Path, catalog_path: Path) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    expected_ids = parse_catalog_ids(catalog_path)
    expected = set(expected_ids)

    if not asset_dir.is_dir():
        return [f"Asset directory does not exist: {asset_dir}"], warnings

    wav_paths = {
        path.stem: path
        for path in asset_dir.iterdir()
        if path.is_file() and path.suffix.lower() == ".wav"
    }
    found = set(wav_paths)
    missing = sorted(expected - found)
    extra = sorted(found - expected)
    if missing:
        errors.append(f"Missing {len(missing)} required WAV files: {', '.join(missing)}")
    if extra:
        errors.append(f"Unexpected WAV files: {', '.join(extra)}")

    for phoneme_id in expected_ids:
        path = wav_paths.get(phoneme_id)
        if path is None:
            continue
        file_errors, file_warnings = inspect_wav(path)
        errors.extend(file_errors)
        warnings.extend(file_warnings)

    return errors, warnings


def main() -> int:
    root = project_root()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--asset-dir",
        type=Path,
        default=root / "lingo_app" / "assets" / "phonetics" / "british",
        help="Directory containing the 44 final WAV files.",
    )
    parser.add_argument(
        "--catalog",
        type=Path,
        default=root
        / "lingo_app"
        / "lib"
        / "features"
        / "phonetics"
        / "data"
        / "british_phoneme_catalog.dart",
        help="Dart catalog from which required IDs are read.",
    )
    args = parser.parse_args()

    asset_dir = args.asset_dir.resolve()
    catalog_path = args.catalog.resolve()
    try:
        errors, warnings = validate(asset_dir, catalog_path)
    except (OSError, ValueError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1

    print(f"Asset directory: {asset_dir}")
    print(f"Catalog: {catalog_path}")
    for warning in warnings:
        print(f"WARNING: {warning}")
    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        print("Phoneme asset validation failed.", file=sys.stderr)
        return 1

    print("All 44 British phoneme WAV assets satisfy the format contract.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
