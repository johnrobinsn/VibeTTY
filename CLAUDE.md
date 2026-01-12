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

## Experimental Fork Notes

This is johnrobinsn's experimental fork with virtual terminal width support.

### Git Remotes
Both connectbot and termlib repos use `fork` remote for pushing:
```bash
git push fork main  # NOT origin (which points to upstream)
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

### Documentation
- `NEW_FEATURES.md` - Detailed implementation notes and lessons learned
- `CLAUDE_NOTES.md` - Additional session notes
