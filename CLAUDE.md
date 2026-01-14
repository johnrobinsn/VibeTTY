# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Environment

```bash
# Android SDK location
ANDROID_HOME=/home/jr/Android/Sdk

# ADB path (for deploying to devices)
ADB=/home/jr/Android/Sdk/platform-tools/adb

# Deploy debug APK to Samsung device
$ADB -s R5CW11Z9QEK install -r app/build/outputs/apk/google/debug/app-google-debug.apk
```

## Build Commands

```bash
# Build the app (includes lint, tests, and APK generation)
./gradlew build

# Build and create Android App Bundle
./gradlew build bundle

# Run unit tests only
./gradlew test

# Run a specific test class
./gradlew testGoogleDebugUnitTest --tests "org.connectbot.data.dao.HostDaoTest"

# Run instrumented tests (requires emulator or device)
./gradlew connectedCheck

# Format code with Spotless
./gradlew spotlessApply

# Check formatting without applying
./gradlew spotlessCheck
```

## Product Flavors

The app has two product flavors in the `license` dimension:
- **google**: Uses Google Play Services for crypto provider updates and downloadable fonts
- **oss**: Uses bundled Conscrypt library, fully open-source, larger APK size

Build variant examples: `googleDebug`, `googleRelease`, `ossDebug`, `ossRelease`

## Architecture Overview

### Data Layer (`org.connectbot.data`)
- **Room Database** (`ConnectBotDatabase.kt`): Single database with entities for hosts, pubkeys, port forwards, known hosts, color schemes, and profiles
- **Entities** (`data/entity/`): Data classes for Host, Pubkey, PortForward, KnownHost, ColorScheme, ColorPalette, Profile
- **DAOs** (`data/dao/`): Room DAOs with Flow-based reactive queries
- **Repositories**: HostRepository, PubkeyRepository, ColorSchemeRepository, ProfileRepository wrap DAOs with business logic

### Transport Layer (`org.connectbot.transport`)
- **Transport** (sealed class): Type-safe transport types (SSH, Telnet, Local)
- **AbsTransport**: Abstract base for transport implementations
- **SSH/Telnet/Local**: Concrete transport implementations
- **TransportFactory**: Factory for creating transport instances from protocols/URIs

### Service Layer (`org.connectbot.service`)
- **TerminalManager**: Bound service managing active SSH connections (bridges)
- **TerminalBridge**: Represents a single terminal connection
- **Relay**: Handles I/O between terminal and transport
- **TerminalKeyListener**: Processes keyboard input for terminals

### UI Layer (`org.connectbot.ui`)
- **Jetpack Compose** UI with Navigation Component
- **Screens** (`ui/screens/`): Feature screens (HostList, Console, HostEditor, PubkeyList, etc.)
- **Components** (`ui/components/`): Reusable Compose components
- **ViewModels**: Per-screen ViewModels with Hilt injection
- **Navigation** (`ui/navigation/`): NavGraph.kt defines navigation routes

### Dependency Injection
- **Hilt** for DI throughout the app
- Modules in `di/`: AppModule, DatabaseModule, DispatcherModule, MigrationModule, LoggingModule

### Product Flavor Differences
The `ProviderLoader.kt` differs between flavors:
- `google/`: Uses Google Play Services ProviderInstaller
- `oss/`: Uses Conscrypt directly

## Testing

- Unit tests use Robolectric for Android framework simulation
- Room DAO tests use in-memory databases with `allowMainThreadQueries()`
- Use `runTest` coroutine test scope for suspend functions
- AssertJ assertions preferred over JUnit assertions
- Instrumented tests use Hilt test runner (`HiltTestRunner`)

## Code Style

Spotless enforces formatting:
- Java: Google Java Format with import ordering
- Kotlin: ktlint with Android Studio code style
- Gradle files: ktlint
- Ratchet from `origin/main` (only changed files are checked)

## VibeDroid Fork Notes

This is **VibeDroid**, johnrobinsn's fork of ConnectBot focused on "vibe coding" - AI-assisted development on mobile.

### Git Remotes
```bash
# Push to VibeDroid repo (NOT origin which points to upstream ConnectBot)
git push fork main

# Remote URLs:
# fork  -> https://github.com/johnrobinsn/VibeDroid.git
# origin -> https://github.com/connectbot/connectbot.git (upstream)
```

### termlib Composite Build
The termlib library is at `/mntc/code/termlib` and included via composite build in `settings.gradle.kts`.

### Virtual Terminal Width Feature
Allows terminal to render wider than physical screen with horizontal panning.

**Key file:** `termlib/lib/src/main/java/org/connectbot/terminal/Terminal.kt`
- Gesture handling: ~lines 790-1100
- `virtualWidthColumns` parameter enables wider rendering
- `horizontalPanOffset` state for pan position
- `scrollGestureGeneration` tracks gesture lifecycle to prevent race conditions

### Scroll Gesture Stability (Latest Fixes)
Problems solved for TUI apps producing continuous output:
1. **Generation tracking** - `scrollGestureGeneration` counter prevents stale fling completions
2. **Capture maxScroll at scroll mode entry** - Prevents mid-gesture changes from TUI output
3. **Vertical movement threshold** - 0.5px threshold prevents horizontal pan from affecting scroll
4. **Horizontal auto-pan disabled** - TUIs park cursor at col 0, making cursor-based auto-pan unreliable

### Debug Logging
Terminal.kt has debug logging enabled (grep `Log.d("Terminal"`). Remove when stable.

### App Branding
- **App name**: "VibeDroid" (defined in `res/values/notrans.xml`)
- **Icon**: Cyan "V" with vibe waves + pink cursor on dark background
  - Vector drawables in `res/drawable/ic_launcher_*.xml`
  - Adaptive icon in `res/mipmap-anydpi-v26/icon.xml`
  - **Note**: easylauncher plugin caches icons - use `--no-build-cache` and delete `app/build/` if icon changes don't appear
- **PNG fallbacks** in `res/mipmap-*/icon.png` are still old ConnectBot icons (only used on Android 7.1 and below)

### Recent Fixes (Jan 2025)

#### Hardware Keyboard Detection
- **Problem**: Paired but not connected Bluetooth keyboards were detected as "connected"
- **Fix**: Check `configuration.hardKeyboardHidden` in addition to `configuration.keyboard`
- **File**: `ConsoleScreen.kt` - `rememberHasHardwareKeyboard()`

#### Force Soft Keyboard Option
- **Setting**: Settings → Keyboard → "Force software keyboard"
- **Purpose**: Show soft keyboard even when hardware keyboard is detected
- **Files**: `PreferenceConstants.kt`, `SettingsViewModel.kt`, `SettingsScreen.kt`, `ConsoleScreen.kt`

#### IME Visibility on Connect
- **Problem**: Soft keyboard wasn't showing when connecting to host
- **Cause**: LaunchedEffect was resetting `showSoftwareKeyboard` to false on initial load before IME could appear
- **Fix**: Track `wasImeVisible` state to only reset when IME was actually dismissed by user
- **File**: `ConsoleScreen.kt` lines ~245-256

#### Modifier Panel Auto-hide During Scroll
- **Problem**: Modifier panel disappeared while user was scrolling it horizontally
- **Fix**: Added LaunchedEffect to call `onInteraction()` when `scrollState.isScrollInProgress`
- **File**: `TerminalKeyboard.kt` lines ~181-186

### Documentation
- `NEW_FEATURES.md` - Detailed implementation notes and lessons learned
- `CLAUDE_NOTES.md` - Additional session notes
- `README.md` - VibeDroid overview with ConnectBot attribution
