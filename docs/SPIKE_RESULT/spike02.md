# Uangku — Technical Spike 02

**Status: PASSED — build, automated tests, and physical-device end-to-end
success flow are verified.**

The Go package, gomobile AAR, Kotlin bridge, Flutter UI, automated tests, and
debug APK build are implemented and verified. The user reported successful
runtime results on Android SDK 31 for both the retained Kotlin ping and the Go
finance summary, and subsequently confirmed both still succeed after a hot
restart. Invalid-input behavior is covered by Go unit tests and Flutter
error-state widget tests. The sample UI does not expose a way to enter an
invalid transaction payload, so invalid input was not manually injected on the
device.

## Tujuan

Validate a local-only call path from Flutter through the existing Kotlin
MethodChannel to Go compiled as an Android library by gomobile. The Go sample
calculates integer-rupiah income, expense, and net-balance totals; this is a
technical fixture, not a production finance module.

## Arsitektur yang Diimplementasikan

```text
Flutter UI
  -> MethodChannel id.uangku/spike01, method summarize
  -> MainActivity Kotlin
  -> generated id.uangku.finance.Finance binding
  -> Go finance.CalculateSummary(JSON)
  -> JSON result -> Kotlin map -> Flutter
```

The original `ping` method remains on the same channel and returns its
Spike 01 response. Unknown methods still call `notImplemented()`. Go work is
run on a single-thread executor; method results are posted back to Android's
main thread. Input errors are returned as safe platform errors.

## Toolchain

| Component | Observed version/configuration |
|---|---|
| OS / architecture | Ubuntu 26.04.1 LTS / x86_64 |
| Flutter / Dart | 3.47.8 / 3.13.7 |
| Go | go1.27.4 |
| gomobile | Built from `golang.org/x/mobile@v0.0.0-20261117202452-47699113848a` |
| Java | OpenJDK 17.0.21.1 |
| Android SDK / platform | 36 / `android-36` |
| Android Build Tools | 36.0.0 |
| Android NDK | 28.2.13676358 |
| App ID / namespace | `id.uangku.app` |
| App min / target / compile SDK | 29 / 36 / 36 |
| gomobile binding API | 29 |
| Device attached to ADB during implementation | None |

`gomobile version` did not report a version from the app module because it
tries to resolve the gomobile command as a dependency of the current module.
The installed binary version was identified with `go version -m`, and the
binding itself was successfully built using that binary.

## Structure and Implementation

- `native/finance/go.mod`: standalone module `id.uangku.finance`; requires Go
  1.26 for the installed `x/mobile` version and declares its `gobind` tool.
- `native/finance/finance.go`: exported `CalculateSummary` accepts a JSON array
  of `{type, amount}` transactions and returns JSON totals.
- `native/finance/finance_test.go`: 16 Go test cases, including zero, malformed
  input, negative amounts, unknown types/fields, int64 boundary, and overflow.
- `android/app/libs/finance.aar`: generated Android library for
  `armeabi-v7a`, `arm64-v8a`, `x86`, and `x86_64`. Its manifest declares
  `minSdkVersion=29`.
- `android/app/build.gradle.kts`: links the AAR and sets app `minSdk=29`.
  The existing `targetSdk` and `compileSdk` declarations were not changed.
- `MainActivity.kt`: keeps `ping`, adds `summarize`, validates arguments,
  invokes Go off the main thread, and translates errors to safe responses.
- `lib/features/technical_spike/data/finance_bridge.dart` and
  `domain/models/`: typed Flutter request/response and bridge handling.
- `presentation/`: a Go connection status card, totals, loading/error states,
  and a button for sample calculation.
- `test/features/technical_spike/presentation/spike_home_page_test.dart`:
  retains Spike 01 widget tests and adds tests for the Go request, displayed
  totals, and safe invalid-input error.

### Min SDK decision

During integration, the existing Flutter app defaulted to minSdk 24, while the
gomobile AAR built with `-androidapi=29` declares minSdk 29. This is a real
Gradle manifest merge conflict. The user explicitly approved raising the app
minSdk to 29 to align with the PRD baseline and AAR. `targetSdk` and `compileSdk`
remain unchanged at their existing Flutter-provided values. This decision is
recorded here; no separate `TECHNICAL_DECISIONS.md` was present during audit.

## Build the Go AAR

From the repository root, with the documented Android SDK/NDK environment set:

```bash
cd native/finance
gomobile bind -v -target=android -androidapi=29 \
  -javapkg=id.uangku \
  -o ../../android/app/libs/finance.aar .
```

The package can be independently checked with:

```bash
cd native/finance
go test ./...
go vet ./...
```

Then run the Flutter/Android commands from the repository root:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Validation Results

| Validation | Result | Evidence |
|---|---|---|
| `go test ./...` | **PASS** | All 16 calculation/validation subtests pass. |
| `go vet ./...` | **PASS** | No diagnostics. |
| gomobile Android binding | **PASS** | `finance.aar` produced; contains generated Java binding and four ABI libraries. |
| AAR minimum API | **PASS** | AAR manifest reports `minSdkVersion=29`. |
| Kotlin integration compile | **PASS** | Included in successful Android Gradle debug build. |
| `flutter pub get` | **PASS** | Dependencies resolved; no new Flutter package was added. |
| `flutter analyze` | **PASS** | No issues found. |
| `flutter test` | **PASS** | Seven widget tests pass, including retained Spike 01 behavior and Go bridge mocked response/error paths. |
| `flutter build apk --debug` | **PASS** | `build/app/outputs/flutter-apk/app-debug.apk` generated. |
| APK identity and SDK metadata | **PASS** | APK metadata: package `id.uangku.app`, min SDK 29, target SDK 36, compile SDK 36. |
| Go native library packaged in APK | **PASS** | APK contains `libgojni.so` for arm64-v8a, armeabi-v7a, and x86_64 (AAR also includes x86). |
| Physical-device `ping` | **PASS — user-reported** | Message `Pong dari Kotlin!`, platform `Android Native`, Android SDK `31`. |
| Physical-device Go calculation | **PASS — user-reported** | Income `Rp 175000`, expense `Rp 25000`, net balance `Rp 150000`. |
| Physical-device hot-restart recheck | **PASS — user-reported** | User confirmed both ping and Go summary continued to succeed after hot restart. |
| Invalid-input validation | **PASS — automated** | Go unit tests reject malformed/negative/unsupported data; Flutter widget test verifies safe error display. The sample device UI does not provide direct invalid-payload input. |

The APK build emitted an Android SDK XML compatibility warning (the SDK
processor understands XML through version 3 while an installed SDK file uses
version 4); Gradle nevertheless completed successfully. No SDK, Gradle, Kotlin,
Go, or global environment version was changed as part of this spike.

## Physical Device Validation (User-Reported)

On the Samsung Galaxy S10 (or provide the actual device model used), enable USB
debugging, accept the computer authorization prompt, and run:

```bash
adb devices -l
flutter devices
flutter install -d <device-id>
```

The user reported that opening Uangku and tapping **Test Native Connection**
returned the following, and confirmed it continued to work after hot restart:

- Message: `Pong dari Kotlin!`
- Platform: `Android Native`
- Android SDK: `31`

The user also reported successful **Test Go Finance Summary** output, both
before and after hot restart:

- Total income: `Rp 175000`
- Total expense: `Rp 25000`
- Net balance: `Rp 150000`

The user reported no runtime errors and successful results after hot restart.
Invalid-input payload injection is not exposed by this spike's sample UI; its
controlled error path is verified by Go and Flutter automated tests.

## Kendala dan Kesimpulan

- Initial gomobile invocation required `golang.org/x/mobile` to be included in
  the finance module dependency graph. The matching installed pseudo-version
  was added as a Go tool dependency; Go 1.27.4 supports its Go 1.26 minimum.
- The NDK only supports Android API levels 21–35, so binding used API 29; the
  installed SDK platform 36 is used by the app build.
- The app's previous minSdk 24 conflicted with the AAR's minSdk 29. This was
  resolved using the user-approved application minSdk 29.
- No Android device was visible to ADB during implementation. The user
  subsequently reported successful ping and Go calculation on SDK 31 and
  confirmed both still work after hot restart.

The integration is build- and test-validated; both primary calls are
user-reported as successful on Android SDK 31, including after hot restart.
**Spike 02: PASSED.** Physical-device invalid-payload injection was not
performed because the sample UI does not expose arbitrary transaction input;
Go and Flutter automated tests cover that error path. Spike 03 was not started.
