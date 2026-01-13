# CullR

CullR is a focused Flutter app for speed-sorting your photo library. Swipe
right to keep, left to delete, and review what you marked before committing.

## Features

- Swipe-first review flow with undo
- Review "Keep" and "Delete" queues before action
- Fullscreen preview for photos, GIFs, and videos
- Batched loading with thumbnail caching for smoother browsing
- Multilingual UI (via Flutter localization)

## Requirements

- Flutter SDK (3.10+)
- iOS or Android device/emulator with gallery access

## Run locally

```bash
flutter pub get
flutter run
```

## Scripts

Windows batch helpers live in `scripts/`:

- `scripts/start_dev.bat` starts the app on a connected Android device (clears
  app data first).
- `scripts/install_prod.bat` builds a release APK and installs it on a connected
  Android device.
- `scripts/check.bat` runs formatting, localization generation, diagnostics,
  analysis, and tests.

## Permissions

CullR uses `photo_manager` to access the device gallery. On first launch, the
app will request permission. If access is denied or limited, the settings menu
offers a shortcut to re-open the system permissions screen.

## Localization

Strings live in `lib/l10n/*.arb` and are generated via `flutter gen-l10n`. Add
translations by creating a new `.arb` file and rerun the generator.

## Contributing

- Keep UI changes consistent with the existing dark theme styles in
  `lib/styles`.
- Prefer small, testable changes and update localization strings when adding UI.

## Support

If you want to support the project, the app links to a Buy Me a Coffee page from
the top app bar.
