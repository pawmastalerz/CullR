# CullR

CullR is a Flutter app for cleaning up your photo library fast. You swipe
through items, review what you chose, and only then commit deletions.
The app is fully open source and does not collect any data.

## What it does

- Swipe right to keep, left to delete
- Undo recent swipes
- Review "Keep" and "Delete" queues before taking action
- Preview photos, GIFs, and videos in fullscreen
- Fast loading via batching + caching
- Multilingual UI

## How the flow works

1. The app loads batches of photos and videos from the device gallery.
2. You swipe cards to classify items as keep or delete.
3. The status button opens a preview sheet with two tabs: Delete and Keep.
4. You can remove items from either list or confirm a bulk delete/review.
5. Deletions are only committed after a confirmation dialog.

## Project layout (at a glance)

- `lib/main.dart`: app entry point and theme
- `lib/core/config/app_config.dart`: tuning knobs for batching, buffer sizes, and cache limits
- `lib/core`: shared services, models, utilities, widgets
- `lib/features/swipe`: swipe flow controllers, models, and UI
- `lib/styles`: color, spacing, typography tokens
- `lib/l10n`: ARB translations + generated localizations
- `test`: unit and widget tests

## Requirements

- Flutter SDK 3.10+
- iOS or Android device/emulator with gallery access

## Run locally

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

## Scripts (Windows)

Batch helpers live in `scripts/`:

- `scripts/start_dev.bat`: starts the app on a connected Android device
- `scripts/install_prod.bat`: builds a release APK and installs to Android
- `scripts/check.bat`: formatting, l10n generation, analysis, tests

## Permissions

CullR uses `photo_manager` to access your device gallery. On first launch the
app requests permission. If access is denied or limited, the settings menu
provides a shortcut to open system permissions.

## Localization

Strings live in `lib/l10n/*.arb` and are generated via `flutter gen-l10n`.
Add a new locale by creating a new `.arb` file and re-running the generator.

## Support

The app includes a Buy Me a Coffee link in the top app bar.
