# GameOn

Find sports partners and fill team spots. Built with Flutter + Supabase.

## Prerequisites

- Flutter SDK (stable channel, ≥ 3.3)
- Xcode 15+ (for iOS builds)
- Android Studio / Android SDK (for Android builds)
- A Supabase project with the migrations applied

## Environment variables

The app uses `--dart-define` to inject secrets at build time:

| Variable | Description |
|---|---|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Your Supabase anon/public key |
| `GOOGLE_PLACES_KEY` | Google Places API key (location autocomplete) |

## Run locally

```bash
flutter pub get

flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ... \
  --dart-define=GOOGLE_PLACES_KEY=AIza...
```

Or use the convenience script (secrets hardcoded for dev):

```bash
./scripts/run_device.sh
```

## Build for release

### Android APK

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=GOOGLE_PLACES_KEY=$GOOGLE_PLACES_KEY
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=GOOGLE_PLACES_KEY=$GOOGLE_PLACES_KEY
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS IPA (requires macOS + Xcode)

```bash
# 1. Install CocoaPods dependencies
cd ios && pod install && cd ..

# 2. Build the IPA
flutter build ipa --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=GOOGLE_PLACES_KEY=$GOOGLE_PLACES_KEY

# 3. Open in Xcode to archive & upload to App Store Connect
open build/ios/archive/Runner.xcarchive
```

Output: `build/ios/ipa/game_on.ipa`

> **Note:** iOS builds cannot run in CI on Linux. Use a Mac for IPA builds and App Store submissions.

## Tests

```bash
flutter test
```

## Static analysis

```bash
flutter analyze
```

## CI/CD

GitHub Actions runs on every push/PR to `main`:

1. **analyze-and-test** — `flutter analyze` + `flutter test`
2. **build-apk** — builds a release APK (artifact uploaded)

Required GitHub secrets: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_PLACES_KEY`.

## Project structure

```
lib/
  models/       – Data classes (Match, Profile, Group, etc.)
  providers/    – State management (ChangeNotifier + Provider)
  screens/      – UI screens
  services/     – Supabase client, API services
  widgets/      – Reusable components
  utils/        – Helpers (error mapping, etc.)
  l10n/         – Localizations (EN, FR, ES)
  legal/        – Terms of service, privacy policy

supabase/
  migrations/   – SQL migrations (001–021)
```
