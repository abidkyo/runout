# Runout

A billiard scoring app for 8-ball, 9-ball, 10-ball, and straight pool.

**Runout** keeps score for singles, doubles, and three-player matches with live
scoring, undo/redo, a match timer, and match history. It runs on the web and
builds for Android, iOS, Linux, macOS, and Windows. It works offline after the
first load.

**Version 0.1.0** · [Changelog](CHANGELOG.md)

## Features

- Singles (1 vs 1), doubles (2 vs 2), and three-player (1 vs 1 vs 1) matches.
- 8-ball, 9-ball, 10-ball, and straight pool.
- Live scoring with breaker selection, straight-pool points and fouls,
  including undo and redo.
- Show match duration that excludes pauses.
- Continue in-progress matches and browse finished ones.
- Pick existing players or create new ones.
- Light and dark themes, blue and green color presets, and 100–150% text size.
- Everything is stored locally. No account, analytics, or backend.

## Requirements

Flutter 3.50 or newer. Web is the primary target.

## Run locally

```bash
flutter pub get
flutter run -d chrome
```

## Build

### Web

```bash
flutter build web --release --wasm --no-web-resources-cdn
```

`--no-web-resources-cdn` self-hosts Flutter's web runtime, so the app works
offline after the first load. The build is written to `build/web`. Deploy it to
any static host over HTTPS. If the app is hosted under a subpath, pass it as the
base href:

```bash
flutter build web --release --wasm --no-web-resources-cdn --base-href /runout/
```

### Other platforms

```bash
flutter build apk
flutter build ios
flutter build linux
flutter build macos
flutter build windows
```

Apple builds require macOS and Xcode; not tested.

## Status

0.1.0 is the first public release and ships the web build. Android, iOS, Linux,
macOS, and Windows builds are available from source.

## Data and privacy

**Runout** has no account, analytics, or backend. Matches, players, and settings
stay in the browser or app storage on your device. Clearing site data removes
them. There is no sync or backup.

## License

All rights reserved. No license is granted for reuse, modification, or
distribution.
