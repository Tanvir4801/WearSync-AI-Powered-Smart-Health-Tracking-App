# smartwear_ai

A new Flutter project.

## Firebase Android Setup

1. Add your Android app in Firebase Console using the package name in [android/app/build.gradle.kts](android/app/build.gradle.kts).
1. Download `google-services.json` from Firebase Console and place it at `android/app/google-services.json`.
1. Register the debug SHA-1 fingerprint in Firebase Console (Project settings -> Your apps -> Add fingerprint).

Debug SHA-1 command:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

1. Ensure Google Services plugin is configured.
1. Confirm it is declared in [android/settings.gradle.kts](android/settings.gradle.kts).
1. Confirm it is applied in [android/app/build.gradle.kts](android/app/build.gradle.kts).

## AI Chat Setup (Direct Hugging Face)

Chat now calls Hugging Face directly from Flutter via `getAIResponse(String message)`.

Add your Hugging Face API key to a `.env` file (do NOT commit it). You can
use `.env.example` as a template.

```bash
cp .env.example .env
# edit .env and set HF_API_KEY
flutter pub get
flutter run
```

Alternatively you can still use `--dart-define` or the VS Code launch config,
but `.env` is the recommended approach for local development.
