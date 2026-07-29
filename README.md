# Coffee Card

A Flutter app for saving personal coffee tasting cards with photos, notes, and ratings. Accounts and data are stored locally on the device using SQLite; each user only sees their own cards.

## Features

- **Register and sign in** — local accounts with hashed passwords and persisted sessions
- **Coffee cards** — title, description, optional gallery image, 1–5 star rating, created/updated dates
- **CRUD** — add, edit, and delete cards from an adaptive home grid
- **Responsive UI** — Material 3 coffee theme; layouts adapt for phone and wider windows (e.g. Windows desktop)

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) with Dart **3.12+**
- Targets used in development: **Android**, **iOS**, and **Windows**

On Windows, plugin builds may require [Developer Mode](https://learn.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development) so Flutter can create symlinks.

## Getting started

From the project root:

```sh
flutter pub get
dart run build_runner build
flutter run
```

After changing Drift tables in `lib/data/services/app_database.dart`, regenerate code:

```sh
dart run build_runner build
```

## Development commands

```sh
dart format .
flutter analyze
flutter test
```

## Architecture

The app uses a layered MVVM style:

| Layer | Role |
| --- | --- |
| **UI** (`lib/ui/`) | Views and `ChangeNotifier` view models |
| **Data** (`lib/data/`) | Repositories and services (Drift DB, image storage) |
| **Domain** (`lib/domain/`) | Models and auth-related exceptions |
| **Routing** (`lib/routing/`) | `go_router` configuration and route paths |

Bootstrap and dependency wiring live in `lib/main.dart` and `lib/app.dart`.

### Local data

- **SQLite (Drift)** — `users`, `coffee_cards`, `app_sessions`
- **Images** — copied into app support storage, not kept on temporary picker paths only
- **Auth** — bcrypt password hashes; emails normalized to lowercase; session restored on launch

Authentication is **device-local only** (no remote API). Do not use for production security scenarios without a real backend.

## Project layout

```text
lib/
├── main.dart
├── app.dart
├── data/
│   ├── repositories/
│   └── services/
├── domain/
│   └── models/
├── routing/
└── ui/
    ├── core/
    └── features/
        ├── auth/
        ├── cards/
        └── splash/
test/
```

## Tests

Unit and widget tests cover registration/login, session restore, card CRUD, per-user isolation, and basic navigation. Run:

```sh
flutter test
```

## CI/CD and GitHub Releases

GitHub Actions builds the app on every push/PR to `main` (or `master`) and publishes installable files when you push a **version tag**.

### Continuous integration

Workflow: [`.github/workflows/ci.yml`](.github/workflows/ci.yml)

- Runs `flutter analyze` and `flutter test` after Drift code generation.

### Release builds

Workflow: [`.github/workflows/release.yml`](.github/workflows/release.yml)

| Asset | Platform | Notes |
| --- | --- | --- |
| `coffee_card-android.apk` | Android | Sideload on devices/emulators |
| `coffee_card-android.aab` | Android | Play Store upload format |
| `coffee_card-windows-x64.zip` | Windows | Unzip and run `coffee_card.exe` |
| `coffee_card-macos.zip` | macOS | Unzip `coffee_card.app` → open on Mac |
| `coffee_card-ios.ipa` | iOS | Ad-hoc IPA when signing secrets are configured (see below) |

**How to publish a release**

1. Commit and push your changes to GitHub.
2. Create and push a tag (must start with `v`):

```sh
git tag v1.0.0
git push origin v1.0.0
```

3. Open the repo on GitHub → **Actions** → wait for **Release** to finish.
4. Open **Releases** — the tag appears with the APK, AAB, and Windows zip attached.

You can also run **Release** manually from the Actions tab (**Run workflow**). That run still produces **workflow artifacts** (APK/AAB/zip), but a GitHub **Release** page entry is created only when the workflow is triggered by pushing a `v*` tag.

### Android signing (optional, for production)

Release builds currently use the **debug signing** config in `android/app/build.gradle.kts` (fine for testing and GitHub downloads). For Play Store production, add a upload keystore and GitHub secrets, then wire `signingConfigs` in Gradle. See [Flutter Android deployment](https://docs.flutter.dev/deployment/android).

### iOS signing (required for `.ipa` on Releases)

iOS builds run on **macOS** GitHub runners. The workflow always compiles iOS; a downloadable **`coffee_card-ios.ipa`** is attached to the GitHub Release only when these repository secrets are set:

| Secret | Description |
| --- | --- |
| `IOS_BUILD_CERTIFICATE_BASE64` | Base64-encoded `.p12` distribution (or development) certificate |
| `IOS_BUILD_CERTIFICATE_PASSWORD` | Password for the `.p12` file |
| `IOS_BUILD_PROVISION_PROFILE_BASE64` | Base64-encoded `.mobileprovision` (Ad Hoc profile matching `com.example.coffeeCard`) |
| `IOS_KEYCHAIN_PASSWORD` | Any strong random string (temporary CI keychain) |
| `IOS_APPLE_TEAM_ID` | 10-character Apple Team ID |

**One-time setup (summary)**

1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/) if you plan to install on physical iPhones.
2. In [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources), create an App ID for `com.example.coffeeCard`, an **Ad Hoc** provisioning profile, and an **Apple Distribution** certificate (export as `.p12`).
3. Base64-encode the files (examples):

```sh
base64 -i Certificates.p12 | pbcopy          # paste into IOS_BUILD_CERTIFICATE_BASE64
base64 -i CoffeeCard.mobileprovision | pbcopy # paste into IOS_BUILD_PROVISION_PROFILE_BASE64
```

4. Add the secrets under GitHub → **Settings** → **Secrets and variables** → **Actions**.
5. Register test devices in the Ad Hoc profile, then push a `v*` tag.

Export uses [`ios/ExportOptions.plist`](ios/ExportOptions.plist) with method **ad-hoc** (install on registered devices). For App Store / TestFlight, change `method` to `app-store` and use an App Store provisioning profile.

Without secrets, the iOS job still runs `flutter build ios --release --no-codesign` as a compile check; no IPA is published.

### macOS

The **macOS** job builds a release `.app` and zips it. Users may need to allow the app in **System Settings → Privacy & Security** the first time (unsigned/not notarized builds).

## Troubleshooting

### Android: `Could not close incremental caches` / `Storage is already registered`

This is a corrupted Kotlin incremental compile cache (often under `build/image_picker_android/...` on Windows).

1. Stop any running `flutter run` / Gradle builds.
2. From the project root:

```sh
flutter clean
cd android && ./gradlew --stop && cd ..
flutter pub get
flutter run
```

3. If it still fails, delete the `build` folder manually, then run `flutter run` again.

The repo sets `kotlin.incremental=false` and in-process Kotlin compilation in [`android/gradle.properties`](android/gradle.properties) to reduce how often this happens. Close duplicate IDE/terminal builds so only one Gradle job touches the cache at a time.

### Windows: symlink / Developer Mode

If `flutter pub get` or plugin builds complain about symlinks, enable **Developer Mode** in Windows settings (`start ms-settings:developers`).

## License

Private learning project (`publish_to: 'none'` in `pubspec.yaml`).
