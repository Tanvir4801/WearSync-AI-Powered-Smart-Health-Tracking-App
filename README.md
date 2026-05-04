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

Run with API key via dart-define:

```bash
flutter pub get
flutter run --dart-define=HF_API_KEY=YOUR_HF_API_KEY
```

### One-Time Local Setup (No Long Command Each Run)

1. Copy `.vscode/hf.local.json.example` to `.vscode/hf.local.json`.
2. Put your key in `HF_API_KEY`.
3. Run from VS Code launch config: **Flutter (Hugging Face Direct)**.

After this, you can run from the play button without retyping the API argument.
