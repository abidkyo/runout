# Runout

A billiard scoring app built with Flutter. Runs on Android, iOS, web,
Linux, macOS, and Windows.

## Overview

Runout consists of two apps:

- **Client app** — used by players and referees to score matches.
- **Manager app** — used to organize matches and tournaments, and view results.

Supported match types:

- 1v1
- 2v2 (doubles)
- 1v1v1 (three players)
- Tournament mode

Supported game types:

- 8-ball
- 9-ball
- 10-ball
- Straight pool (14.1)

## Requirements

- Flutter SDK (stable channel)
- Dart SDK (bundled with Flutter)

## Getting Started

Clone the repository and fetch dependencies:

```bash
flutter pub get
```

## Build and Run

Run on a connected device or emulator:

```bash
flutter run
```

## Build a release version:

```bash
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
flutter build linux      # Linux
flutter build macos      # macOS
flutter build windows    # Windows
```

## Project Structure

```text
lib/
├── core/        # constants, theme
├── data/        # repositories
├── domain/      # models, enums
├── features/    # screens and their widgets/providers
└── shared/      # reusable widgets
docs/specs/      # architecture, domain, scoring, UI, conventions, testing
```

## Documentation

- [`AGENTS.md`](AGENTS.md) — rules, commands, and the spec index.
- [`docs/specs/`](docs/specs/) — specifications.

## Status

Early development. Roadmap and open questions:
[`docs/specs/product.md`](docs/specs/product.md).
