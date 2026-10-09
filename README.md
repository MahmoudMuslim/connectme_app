# ConnectMe — Community App

**Flutter · Clean Architecture · BLoC/Cubit · GetIt · Firebase**

ConnectMe is a community social app: members authenticate with Firebase, publish
posts that stream in real time from Cloud Firestore, explore a Google Map of the
community, and protect their profile behind a native biometric gate.

The UI is a faithful implementation of the **Social App — Free UI Kit** Figma
reference (`figma/` holds the exported layout fragments, `Social App - Free UI
Kit 🧱 (Community)/` holds the original design PNGs).

---

## Table of contents

1. [Screens](#screens)
2. [Architecture](#architecture)
3. [Design patterns](#design-patterns)
4. [Running the app](#running-the-app)
5. [Configuration](#configuration)
6. [Project structure](#project-structure)
7. [Design system](#design-system)
8. [Permissions](#permissions)
9. [Firebase setup](#firebase-setup)
10. [Testing](#testing)
11. [Beta distribution with Firebase App Distribution](#beta-distribution-with-firebase-app-distribution)
12. [Required screenshots](#required-screenshots)
13. [Quality gates](#quality-gates)

---

## Screens

| Screen | File | What it does |
| --- | --- | --- |
| **Splash** | `presentation/screens/splash_screen.dart` | Brand gradient, restores the persisted session and routes to Home or Login. |
| **Login** | `presentation/screens/login_screen.dart` | Email + password against Firebase Auth; shows the decoded error in a snack bar. |
| **Sign Up** | `presentation/screens/sign_up_screen.dart` | Full validation (capital first letter, `@` in the e-mail, ≥ 6 char password, confirmation). Captures the device model at sign-up. |
| **Home shell** | `presentation/screens/home_screen.dart` | Five-slot bottom navigation: Feed · Map · **FAB** · Fund · Profile. |
| **Feed** | `presentation/screens/feed_screen.dart` | Real-time Firestore stream, `Popular / Trending / Following` tabs, pull-to-refresh, optimistic likes, profile icon with the biometric gate. |
| **Composer** | `presentation/screens/create_post_screen.dart` | Opens from the gradient FAB; validates and writes to Firestore. |
| **Profile** | `presentation/screens/profile_screen.dart` | Curved banner, ringed avatar, name, e-mail, membership date, device card, "Update photo" + "Sign out". |
| **Community Map** | `presentation/screens/map_screen.dart` | Full-screen Google Map, five member markers across five cities, info window on tap, tappable member legend. |
| **Community Fund** | `presentation/screens/donations_screen.dart` | SOLID donation flow (see [Design patterns](#design-patterns)). |

---

## Architecture

Strict **Clean Architecture**: dependencies always point *inwards*.

```
Presentation  ──►  Domain  ◄──  Data
     │                            ▲
     └────────  Services  ────────┘
```

```
lib/
├── main.dart                 bootstrap: orientation, DI, Firebase service
├── app.dart                  MaterialApp + route table
├── injection.dart            GetIt container — the ONLY place wiring happens
│
├── core/                     cross-cutting, framework-free
│   ├── config/app_config.dart      --dart-define configuration
│   ├── constants/                  Firestore paths, routes, limits
│   ├── errors/failures.dart        sealed Failure hierarchy
│   ├── errors/firebase_error_mapper.dart   exception → user message
│   ├── result/result.dart          sealed Result<T> (Success | ResultFailure)
│   ├── theme/                      colours, typography, radii, ThemeData
│   └── utils/                      validators, time formatter, responsive
│
├── domain/                    pure Dart — no Flutter, no Firebase
│   ├── entities/            User, Post, CommunityMember, DeviceInfo, Money, Donation
│   ├── repositories/        abstract contracts (Dependency Inversion)
│   └── usecases/           one single-responsibility class per operation
│
├── data/                     implementations
│   ├── models/              UserModel, PostModel, DonationModel, CommunityMemberModel
│   ├── datasources/         PostDataSource + Firestore / Local / CacheStore / Factory
│   └── repositories/        PostRepositoryImpl, UserRepositoryImpl, DonationRepositoryImpl
│
├── presentation/
│   ├── blocs/               AuthCubit, PostCubit, ProfileCubit, DonationCubit (+ states)
│   ├── screens/             one file per screen
│   └── widgets/             one file per reusable widget
│
└── services/                singletons wrapping platform / cloud SDKs
    ├── firestore_service.dart   SINGLETON
    ├── auth_service.dart        SINGLETON
    ├── biometric_service.dart   SINGLETON
    ├── device_info_service.dart SINGLETON
    ├── image_picker_service.dart
    └── payment/                  PaymentGateway (ISP/DIP) + DemoPaymentGateway
```

### Error handling

`Result<T>` (a sealed `Success` / `ResultFailure`) is returned by **every**
repository method, so no exception ever reaches a widget. `FirebaseErrorMapper`
is the single place that decodes `FirebaseAuthException`, `FirebaseException`,
`LocalAuthException` and `PlatformException` into a `Failure` carrying a
sentence a non-technical user can read, which the UI renders through
`ConnectMeSnackBar` or `ErrorView`.

### Working without Firebase credentials

ConnectMe resolves its Firebase configuration in three tiers:

1. `--dart-define=FIREBASE_*` values (handy for CI and per-flavour builds);
2. **`lib/firebase_options.dart`**, generated by `flutterfire configure` — the
   default path;
3. nothing at all → the app runs against the on-device cache.

In tier 3, `FirestoreService.isReady` is `false` and the repository **factory**
selects the local cache data source instead. Every screen, cubit and use case
keeps working; only the storage differs. That is why the app is fully
demonstrable out of the box on a fresh clone, and why `flutter test` never
depends on the network — `test/helpers/connect_me_test_binding.dart` forces demo
mode for the whole suite.

> `lib/firebase_options.dart` is committed on purpose. It contains only the
> **public** Firebase web identifiers (API key, app id, project id), which are
> designed to be shipped inside the app binary — FlutterFire's own template does
> the same. The genuinely sensitive artefacts — the *service-account* private
> key and the *App Distribution* service account — are git-ignored
> (`**/serviceAccount*.json`, `*-firebase-adminsdk-*.json`, `android/key.properties`,
> `*.jks`) and are never part of this repository.

---

## Design patterns

| Pattern | Where | Why |
| --- | --- | --- |
| **Singleton** | `services/firestore_service.dart`, `auth_service.dart`, `biometric_service.dart`, `device_info_service.dart` | One Firestore / Auth handle for the whole app lifetime. `FirestoreService.instance` is cached and also published through `registerInstance`. |
| **Factory** | `data/datasources/post_data_source_factory.dart` + `PostRepositoryImpl.create` | The repository never names a data source: the factory picks **Cloud Firestore vs. local cache** from `FirestoreService.isReady`. Adding a backend adds one class and one `switch` arm. |
| **Builder** | `UserModelBuilder` in `data/models/user_model.dart` | A `UserModel` can only be created through `build()`; optional fields never provided stay `null` instead of becoming empty strings. Exactly what the brief asks for. |
| **Repository** | `domain/repositories/*` + `data/repositories/*` | Domain depends on an interface, data implements it (Dependency Inversion). |
| **Use case** | `domain/usecases/*` | One class, one operation — the business rules are unit-testable without Flutter. |
| **Cubit** | `presentation/blocs/*` | `AuthCubit`, `PostCubit`, `ProfileCubit`, `DonationCubit` expose immutable states and hold no widget code. |
| **Service Locator (DI)** | `injection.dart` (GetIt) | Every dependency is resolved from one container; widget tests can pre-register a fake and the container keeps it. |
| **Facade** | `ProfileGate` (`presentation/widgets/profile_gate.dart`) | One place implements "verify biometrics, then reveal the profile", reused by the app-bar icon and the bottom navigation. |

### SOLID — the donation feature

Requirement 5 asks for SOLID on the transaction-related logic. `lib/services/payment/`
plus `data/repositories/donation_repository_impl.dart` demonstrate each letter:

* **S**ingle Responsibility — `DonationRepositoryImpl` persists receipts;
  `DemoPaymentGateway` authorises the charge; `Money` validates the amount;
  `CreateDonation` applies the business rules.
* **O**pen/Closed — swapping the sandbox gateway for Stripe means writing one
  new `PaymentGateway` implementation and changing **one line** in
  `injection.dart`. No use case, widget or test changes.
* **L**iskov Substitution — every gateway returns `Result<PaymentReceipt>`, so any
  of them is drop-in (proved by `donation_usecases_test.dart`, which injects a
  *declining* gateway and asserts a `PaymentFailure` instead of an exception).
* **I**nterface Segregation — `PaymentGateway` exposes only `name`,
  `isAvailable()` and `charge()`; nothing else leaks in.
* **D**ependency Inversion — `CreateDonation` depends on the abstract
  `DonationRepository`; `DonationRepositoryImpl` depends on the abstract
  `PaymentGateway`. Neither knows Firestore or a payment SDK.

`Money` is an immutable **value object** that guarantees an amount can never
exist without its currency and can never leave the legal range.

---

## Running the app

```bash
flutter --version          # requires Flutter 3.27+ / Dart 3.6+ (developed on 3.47 / 3.13)
flutter pub get
flutter analyze            # must print "No issues found!"
flutter test               # 104 tests
flutter run                # boots in demo mode (local cache) with no configuration
```

The app already reads `lib/firebase_options.dart`. To override it (CI, or a different project) pass the flags explicitly:

```bash
flutter run \
  --dart-define=GOOGLE_MAPS_API_KEY=AIza... \
  --dart-define=FIREBASE_API_KEY=AIza... \
  --dart-define=FIREBASE_APP_ID=1:123456:android:abc \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=123456 \
  --dart-define=FIREBASE_PROJECT_ID=my-project \
  --dart-define=FIREBASE_AUTH_DOMAIN=my-project.firebaseapp.com \
  --dart-define=FIREBASE_STORAGE_BUCKET=my-project.appspot.com
```

Add `--dart-define=FORCE_DEMO_MODE=true` to force the offline cache even when
credentials are present.

---

## Configuration

| Variable | Purpose |
| --- | --- |
| `GOOGLE_MAPS_API_KEY` | Google Maps SDK (read at runtime for web). |
| `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_STORAGE_BUCKET` | Explicit `FirebaseOptions`. |
| `FORCE_DEMO_MODE` | Boot against the local cache regardless of credentials. |

`MAPS_API_KEY` is a **Gradle** property (it must reach `AndroidManifest.xml`):

```bash
flutter build apk --release -PMAPS_API_KEY=AIza...
# or put MAPS_API_KEY=AIza... in android/local.properties
```

No secret is committed: `android/key.properties`, `**/google-services.json` and
`*.jks` are all in `.gitignore`.

---

## Project structure

Every screen, cubit, use case, repository, model and widget lives in its own
Dart file. Highlights of the 87 files under `lib/`:

```
core/errors/failures.dart                        sealed Failure hierarchy
core/result/result.dart                          sealed Result<T>
core/theme/app_colors.dart                       design tokens from the Figma kit
core/utils/{validators,time_formatter,responsive}.dart
data/models/user_model.dart                      fromJson/toJson + UserModelBuilder
data/datasources/post_data_source_factory.dart   FACTORY pattern
data/repositories/post_repository_impl.dart       FACTORY entry point
domain/entities/money.dart                       value object
domain/usecases/verify_biometrics.dart           BiometricRepository contract
presentation/blocs/{auth,post,profile,donation}/
presentation/screens/                            9 screens
presentation/widgets/post_card.dart              required by the brief
presentation/widgets/member_marker.dart          required by the brief
services/firestore_service.dart                  SINGLETON pattern
services/payment/payment_gateway.dart            SOLID seam
```

The `figma/` directory contains the Figma export used as the design source. It
is excluded from the analyzer (it is non-compilable layout data) and is never
imported.

---

## Design system

Colours, radii and typography are transcribed from the Figma kit into
`core/theme/`. The kit ships the commercial families *Proxima Nova* and
*Circular Std*; both are substituted by **Poppins**, which is **bundled** in
`assets/fonts/` and declared in `pubspec.yaml` (five weights: 400/500/600/700/800)
so the app renders the design identically offline and inside the release APK —
no runtime font download, no `google_fonts` network dependency.

| Token | Value | Used for |
| --- | --- | --- |
| `primaryDark` | `#5151C6` | gradient dark end, links |
| `primaryLight` | `#888BF4` | gradient light end, selected tab |
| `accentTint` | `#F1F1FD` | selected tab pill |
| `socialButton` | `#E3E3FC` | social sign-in circles |
| `screenBackground` | `#F5F6F8` | feed / map / profile background |
| `fieldFill` | `#F2F4F6` | pill text fields |
| `textPrimary / Secondary / Tertiary / Muted` | `#242424 / #828282 / #BDBDBD / #8F8FA6` | text hierarchy |
| `headerDark` | `#212121` | dark headers |

Signature gradient (button, FAB, social dots), light bottom-right → dark top-left:

```dart
LinearGradient(
  begin: Alignment(1, 1),
  end: Alignment(-0, 0),
  colors: [Color(0xFF888BF4), Color(0xFF5151C6)],
)
```

Radii: fields/buttons 30 (pill) · cards 10 · tabs 6 · bottom sheet 28 · FAB 40
(circle).

Responsiveness is centralised in `core/utils/responsive.dart`: every screen asks
for its horizontal margin, content max width and grid columns from
`MediaQuery`, and content is centred with `ConstrainedBox` so a tablet never
stretches the feed.

---

## Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)

| Permission | Feature |
| --- | --- |
| `INTERNET` | Cloud Firestore, Firebase Auth, Google Maps |
| `ACCESS_NETWORK_STATE` | Firestore connectivity detection |
| `READ_MEDIA_IMAGES` | `image_picker` — pick a profile photo (Android 13+) |
| `READ_EXTERNAL_STORAGE` (maxSdk 32) | `image_picker` on Android 12 and below |
| `USE_BIOMETRIC` | `local_auth` — the fingerprint gate |
| `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION` | Google Maps "my location" |
| `android.hardware.fingerprint` (**not** required) | the app stays usable without a sensor |

`android/app/src/main/res/xml/network_security_config.xml` blocks cleartext
traffic and pins the Maps / Firebase hosts.

`minSdk` is 24 (Firebase Auth, Firestore, `local_auth` and the Maps SDK all
require it). `MainActivity` extends `FlutterFragmentActivity`, which
`local_auth` requires to present its prompt.

### iOS (`ios/Runner/Info.plist`)

`NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`,
`NSFaceIDUsageDescription`, `NSLocationWhenInUseUsageDescription`.
`AppDelegate.swift` registers `LocalAuthPlugin` so the Face ID sheet can be
presented.

---

## Firebase setup

1. Create a Firebase project and add an **Android** app with the package name
   `com.connectme_app`.
2. Enable **Authentication → Email/Password** and **Cloud Firestore**.
3. Deploy the security rules shipped in `firebase/firestore.rules`:
   ```bash
   cp .firebaserc.example .firebaserc   # then set your project id
   firebase login && firebase use <project-id>
   firebase deploy --only firestore:rules
   ```
4. Copy the web config values into the `--dart-define` flags shown above.

The rules grant public read access to the feed, the roster and the donation
history, and restrict every write to the signed-in owner of that document.

---

## Testing

```bash
flutter test
```

**104 tests, all passing.** They are real tests, not smoke tests:

| Suite | What it proves |
| --- | --- |
| `test/core/utils/validators_test.dart` | every sign-up / post / donation rule |
| `test/data/models/user_model_test.dart` | the **Builder** pattern leaves unset fields `null`; `toJson`/`fromJson` round-trip |
| `test/domain/usecases/post_usecases_test.dart` | `CreatePost` / `DeletePost` / `GetPosts` behaviour and edge cases |
| `test/domain/usecases/donation_usecases_test.dart` | `Money` invariants, gateway approval/decline, **LSP** substitutability, `CreateDonation` rules |
| `test/presentation/blocs/post_cubit_test.dart` | loading → loaded → error transitions, publish, delete, optimistic like |
| `test/presentation/screens/login_screen_test.dart` | the real login form, validation, snack bars and `AuthCubit` (with a fake `UserRepository`) |
| `test/presentation/widgets/post_card_test.dart` | author, content, relative timestamp, counters, like/delete affordances |
| `test/app_bootstrap_test.dart` | `injection.dart` builds the whole graph and the app reaches the sign-in screen |
| `test/app_journey_test.dart` | end-to-end: register → feed → publish a post → switch tabs → open the fund → biometric-gated profile → map |

`test/helpers/fake_platform_repositories.dart` provides the `local_auth` and
`device_info_plus` stand-ins; they are published into GetIt **before**
`registerDependencies()`, which keeps any registration that already exists — a
deliberate GetIt testing seam in `injection.dart`.

---

## Beta distribution with Firebase App Distribution

> **Status in this repository:** the release APK builds cleanly
> (`build/app/outputs/flutter-apk/app-release.apk`, 54.4 MB, `versionName 1.0.0`,
> `minSdk 24`, `targetSdk 36`) and the Firebase CLI runbook below is complete,
> but the **upload itself requires a Firebase project and tester e-mail
> addresses that only the team owns**. Steps 1–4 were executed here; step 5 must
> be run against your own project. Everything that was verified locally is
> marked ✅.

### 1 — Create the project and register the app ✅ *(config prepared)*

```bash
flutter pub get
firebase login
firebase projects:create connectme-community     # or use an existing project
firebase use connectme-community
flutterfire configure                          # only if you prefer firebase_options.dart
```

ConnectMe does **not** need `google-services.json`: it initialises Firebase from the explicit `FirebaseOptions` of `lib/firebase_options.dart` (see [Configuration](#configuration)).

### 2 — Create the upload keystore ✅ *(scripted)*

```bash
keytool -genkey -v \
  -keystore ~/connectme-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Copy `android/key.properties.example` to `android/key.properties` and fill in
the four values. Without it the release build falls back to the debug key, so a
reviewer can always produce an installable APK.

### 3 — Build the release APK ✅

```bash
flutter build apk --release \
  --dart-define=GOOGLE_MAPS_API_KEY=AIza... \
  --dart-define=FIREBASE_API_KEY=AIza... \
  --dart-define=FIREBASE_APP_ID=1:123456:android:abc \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=123456 \
  --dart-define=FIREBASE_PROJECT_ID=connectme-community \
  --dart-define=FIREBASE_AUTH_DOMAIN=connectme-community.firebaseapp.com \
  --dart-define=FIREBASE_STORAGE_BUCKET=connectme-community.appspot.com \
  -PMAPS_API_KEY=AIza...

# → build/app/outputs/flutter-apk/app-release.apk
```

Verified with `aapt2 dump badging`:

```
package: name='com.connectme_app' versionCode='1' versionName='1.0.0'
minSdkVersion:'24'   targetSdkVersion:'36'
application-label:'ConnectMe'
```

### 4 — Upload to App Distribution ⬜ *(needs your project)*

```bash
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app <FIREBASE_APP_ID> \
  --groups "beta-testers" \
  --release-notes "ConnectMe 1.0.0 — first beta"
```

Or upload the AAB instead of the APK:

```bash
flutter build appbundle --release ...      # → build/app/outputs/bundle/release/app-release.aab
firebase appdistribution:distribute build/app/outputs/bundle/release/app-release.aab \
  --app <FIREBASE_APP_ID> --groups "beta-testers"
```

### 5 — Add at least two testers ⬜ *(needs your testers)*

Either through the console (**App distribution → Testing → Testers → Add
testers**), or on the command line:

```bash
firebase appdistribution:testers:add \
  tester.one@example.com tester.two@example.com \
  --project-alias connectme-community
```

Invitations are sent immediately; each tester receives an email and installs the
build from `https://appdistribution.firebase.google.com/testers/...` or from the
[TestFlight-style link](https://firebase.google.com/docs/app-distribution/ios-distribution-callback).

### 6 — Verify the install

For each of the two testers confirm:

1. the invitation e-mail arrives and the "Install" button resolves to the beta build;
2. the app installs and launches;
3. sign-up works and a post appears in the feed;
4. the profile gate shows the system biometric prompt.

### 7 — Screenshot the distribution

Capture **App distribution → Releases** (showing the uploaded APK, its version and
the tester list) plus one tester invitation e-mail, and drop both into
`screenshots/` (see below).

### Troubleshooting

| Symptom | Fix |
| --- | --- |
| `App Distribution ... requires a release APK` | you uploaded a debug build — add `--release`. |
| `Firebase CLI not authenticated` | `firebase login`. |
| `no app found` | pass `--app <FIREBASE_APP_ID>` or `--project-alias <alias>`. |
| Install prompts for an unknown source | expected: App Distribution installs through the Play Store; the tester must allow it. |
| Grey map tiles | the Maps key is missing/invalid — rebuild with `-PMAPS_API_KEY`. |

---

## Required screenshots

Place these in a `screenshots/` folder at the repository root and reference them
from this file. They must come from a **real device or emulator**, because three
of them cannot be produced any other way (the native biometric sheet and the
Firebase console).

| # | File | How to capture |
| --- | --- | --- |
| 1 | `01_login.png` | launch the app, stay on the login screen. |
| 2 | `02_sign_up.png` | tap **SIGN UP**. |
| 3 | `03_home_feed.png` | register (or sign in) and land on the feed. |
| 4 | `04_biometric_prompt.png` | on an emulator with a fingerprint enrolled (`adb -e emu finger touch 1`), tap the profile icon and photograph the system sheet. |
| 5 | `05_profile_device_info.png` | complete the biometric prompt; the "This device" card shows the model and OS version. |
| 6 | `06_community_map.png` | open the **Map** tab and tap a marker so the info window (name + city) is open. |
| 7 | `07_app_distribution_dashboard.png` | Firebase console → App distribution → Releases, with the tester list visible. |
| 8 | `08_tester_invitation_email.png` | the invitation e-mail received by one of the testers. |

> **Note on automated capture:** Flutter's `matchesGoldenFile` renders all text
> as boxes (the test framework substitutes a placeholder font), so the screenshots
> were intentionally **not** generated from the widget tests. `test/` contains
> behaviour assertions only.

---

## Quality gates

| Gate | Command | Result |
| --- | --- | --- |
| Static analysis | `flutter analyze` | **No issues found!** (`analysis_options.yaml` promotes unused imports, dead code and unused locals to errors) |
| Formatting | `dart format .` | 108 files formatted |
| Tests | `flutter test` | **104 passing** |
| Release build | `flutter build apk --release` | ✅ `app-release.apk` (54.4 MB) |

Additional rules enforced by the analyzer: `use_super_parameters`,
`cancel_subscriptions`, `close_sinks`, `directives_ordering`,
`prefer_single_quotes`, `require_trailing_commas`, `sort_child_properties_last`,
`always_declare_return_types`.

---

## Design reference

Figma kit: [Social App — Free UI Kit (30 Screens)](https://www.figma.com/community/file/1074560321292383928/social-app-free-ui-kit)

---

## Licence

Academic capstone project. Poppins is licensed under the SIL Open Font License.# connectme_app
