# Development & Contribution Guide

This file is for developers and contributors who want to run, test, or extend
CullR.

## Requirements

- Flutter SDK 3.10+
- iOS or Android device/emulator with gallery access

## Project layout

- `lib/main.dart`: app entry point and theme
- `lib/core/config/app_config.dart`: batching, buffer sizes, and cache limits
- `lib/core`: shared services, models, utilities, widgets
- `lib/features/swipe`: swipe flow controllers, models, and UI
- `lib/styles`: color, spacing, typography tokens
- `lib/l10n`: ARB translations + generated localizations
- `test`: unit and widget tests

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

## Localization

Strings live in `lib/l10n/*.arb` and are generated via `flutter gen-l10n`.
Add a new locale by creating a new `.arb` file and re-running the generator.

## Permissions

Android permissions in `android/app/src/main/AndroidManifest.xml`:

- `android.permission.READ_MEDIA_IMAGES`
- `android.permission.READ_MEDIA_VIDEO`
- `android.permission.READ_EXTERNAL_STORAGE` (legacy, maxSdkVersion 32)

iOS permissions in `ios/Runner/Info.plist`:

- `NSPhotoLibraryUsageDescription`

## Data handling

CullR is offline-only and does not collect or transmit user data. The privacy
policy for users is maintained in `README.md`.
