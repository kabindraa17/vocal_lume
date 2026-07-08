# VocaLume

A Flutter podcast app for iOS and Android. Browse and search shows via the [Podcast Index API](https://api.podcastindex.org), play episodes in-app, follow podcasts, and keep listening progress on device.

## Features

- **Explore** — trending podcasts
- **Search** — find shows by name
- **Playback** — in-app player with mini player, lock-screen controls, and background audio
- **Library** — followed podcasts and recent listening history (stored locally)
- **Profile** — guest-mode listening stats from on-device data

## Prerequisites

- [FVM](https://fvm.app) (Flutter Version Management)
- Xcode (for iOS) and/or Android Studio (for Android)
- A free [Podcast Index API](https://api.podcastindex.org) key and secret

This project pins **Flutter 3.44.4** (Dart 3.12.x) via `.fvmrc`. Use `fvm flutter` / `fvm dart` instead of global `flutter` / `dart`.

## Setup

1. **Clone and install dependencies**

   ```bash
   git clone <your-repo-url>
   cd vocal_lume
   fvm install
   fvm flutter pub get
   ```

2. **Add API credentials**

   Copy the example config and add your Podcast Index credentials:

   ```bash
   cp dart_defines.example.json dart_defines.json
   ```

   Edit `dart_defines.json`:

   ```json
   {
     "PODCAST_INDEX_API_KEY": "your_api_key_here",
     "PODCAST_INDEX_API_SECRET": "your_api_secret_here"
   }
   ```

   `dart_defines.json` is gitignored. Never commit API keys.

3. **Generate Drift database code** (first time, or after schema changes)

   ```bash
   fvm dart run build_runner build --delete-conflicting-outputs
   ```

   Only needed for Drift (`app_database.g.dart`). Re-run after changing `lib/src/core/database/`.

## Run the app

**CLI**

```bash
fvm flutter run --dart-define-from-file=dart_defines.json
```

**VS Code / Cursor**

Use the `vocal_lume` launch configuration in `.vscode/launch.json`. It passes `--dart-define-from-file=dart_defines.json` automatically.

**Release builds**

```bash
fvm flutter build apk --dart-define-from-file=dart_defines.json
fvm flutter build ios --dart-define-from-file=dart_defines.json
```

## Tests & analysis

```bash
fvm flutter test
fvm dart analyze lib
```

## Project structure

```
lib/
├── main.dart                          # App entry, audio service init
└── src/
    ├── core/                          # Routing, theme, network, database
    └── features/
        ├── discover/                  # Trending feed
        ├── search/
        ├── podcast/                   # Show & episode detail
        ├── player/                    # Playback UI + audio handler
        ├── library/                   # Follows & listening history
        └── profile/                   # Guest stats
```

## Configuration reference

| File | Purpose |
|------|---------|
| `dart_defines.json` | Podcast Index API key/secret (local, not committed) |
| `dart_defines.example.json` | Template for `dart_defines.json` |
| `.vscode/launch.json` | Debug config with dart-defines |

Credentials are read at compile time via `String.fromEnvironment` in `PodcastIndexConfig.fromEnvironment()`.

## Platform notes

- **Background audio** uses `audio_service` + `just_audio`. Android requires the foreground service entries in `AndroidManifest.xml`; iOS requires the `audio` background mode in `Info.plist` (both are already configured).
- **Local storage** uses Drift (SQLite) for subscriptions and playback progress. Data stays on device until account sync is added.

## Not implemented yet

- User accounts / Supabase sync
- Offline downloads
- Push notifications
- Share

## Troubleshooting

| Problem | What to check |
|---------|----------------|
| Empty explore/search results | `dart_defines.json` exists and keys are valid |
| `app_database.g.dart` missing | Run `fvm dart run build_runner build --delete-conflicting-outputs` |
| Wrong Flutter/Dart version | Run `fvm install` then use `fvm flutter` (not global `flutter`) |
| Playback fails immediately | Network connection; episode has a valid `enclosureUrl` |
| iOS build issues after pulling | `cd ios && pod install` |

## License

Private project — not published to pub.dev (`publish_to: 'none'`).
