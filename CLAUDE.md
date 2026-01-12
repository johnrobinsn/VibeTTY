# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
