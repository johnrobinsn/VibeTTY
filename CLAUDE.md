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

### ADB Test Infrastructure

For automated E2E testing of terminal features, use the scripts in `testing/scripts/`.

**When to use**: Testing keyboard input, terminal I/O, UI automation, or anything requiring real app interaction on emulator/device.

**Setup requirements**:
- Android emulator or device connected via ADB
- Docker SSH server running: `cd testing/docker && docker compose up -d`
- App installed with debug build

**Key files**:
- `testing/scripts/lib/adb-helpers.sh` - Reusable ADB automation functions
- `testing/scripts/test-shift-enter.sh` - Example test script

**Usage**:
```bash
# Source the helpers
source testing/scripts/lib/adb-helpers.sh

# Type text directly to terminal (taps to focus, then input text)
type_to_terminal "cat -v"
press_enter

# Send key combinations (Android 12+ keycombination)
send_ctrl_c      # Ctrl+C
send_ctrl_l      # Ctrl+L (clear)
send_shift_enter # Shift+Enter

# Capture and verify terminal I/O
start_log_capture
send_shift_enter
sleep 0.3
get_send_logs    # What app sent to SSH
get_recv_logs    # What server echoed back

# UI automation
tap_by_tag "hostlist_item_1"
wait_for_tag "console_button_input" 5
connect_to_host "hostlist_item_1" "password"
```

**Key discovery**: `adb shell input text` works with the terminal when `ImeInputView` has focus. The `type_to_terminal()` function taps the terminal area first to ensure focus.

**Terminal I/O logging**: Enable with `adb shell setprop debug.vibetty.terminal_io true`. Logs show exact bytes sent/received via TerminalIO tag in logcat.

## Code Style

Spotless enforces formatting:
- Java: Google Java Format with import ordering
- Kotlin: ktlint with Android Studio code style
- Gradle files: ktlint
- Ratchet from `origin/main` (only changed files are checked)

## VibeTTY Fork Notes

This is **VibeTTY**, johnrobinsn's experimental fork of ConnectBot focused on "vibe coding" - AI-assisted development on mobile.

### Git Remotes
```bash
# Push to VibeTTY repo (NOT origin which points to upstream ConnectBot)
git push fork main

# Remote URLs:
# fork  -> https://github.com/johnrobinsn/VibeTTY.git
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
- **App name**: "VibeTTY" (defined in `res/values/notrans.xml`)
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

#### Disconnect Dialog Reconnect Option
- **Feature**: Added "Reconnect" button to disconnect prompt (Close/Reconnect/Stay)
- **Files**: `PromptManager.kt` (DisconnectPrompt, DisconnectAction), `TerminalBridgePrompts.kt`, `InlinePrompt.kt`, `TerminalBridge.kt`

#### Disconnect Prompt Styling
- Made disconnect prompt fully opaque with white top border for visibility against dark terminal
- **File**: `InlinePrompt.kt` - `DisconnectPromptContent()`

#### Horizontal Flick Gestures
- **Feature**: Flick right → jump to leftmost position, flick left → jump to rightmost position
- Requires velocity > 1500 px/sec and horizontal velocity 2x greater than vertical
- **File**: `termlib/.../Terminal.kt` - scroll gesture end handler (~line 1042)

#### Scroll Indicator Position Fix
- **Problem**: Horizontal scroll indicator floated too high when "Special keys always visible" enabled
- **Cause**: Double-offsetting (Terminal padding + indicator offset both applied)
- **Fix**: Removed redundant `horizontalScrollIndicatorBottomOffset`, Terminal padding handles positioning
- **File**: `ConsoleScreen.kt` line 474

### Extended Keyboard Protocols (Jan 2025)
Enables Shift+Enter, Ctrl+Enter, and other modifier combinations for modern CLI tools like Claude Code.

**Two protocols supported:**
1. **Kitty Keyboard Protocol** (CSI u) - For modern apps, requires user preference
2. **xterm modifyOtherKeys** (CSI 27) - For tmux compatibility, auto-enabled

**Key files:**
- `termlib/.../KittyKeyboardProtocol.kt` - Kitty protocol state, mode stack, key encoding
- `termlib/.../ModifyOtherKeysProtocol.kt` - modifyOtherKeys state and encoding
- `termlib/.../TerminalEmulator.kt` - CSI sequence handling, `dispatchKey()` integration
- `app/.../TerminalKeyListener.kt` - Passes modifiers for Enter/Tab keys

**tmux configuration required:**
```bash
set -g extended-keys always
```

**Documentation:** `docs/KITTY_KEYBOARD_PROTOCOL.md`

### Documentation
- `docs/` - Technical documentation folder
- `docs/KITTY_KEYBOARD_PROTOCOL.md` - Kitty keyboard protocol implementation details
- `NEW_FEATURES.md` - Detailed implementation notes and lessons learned
- `CLAUDE_NOTES.md` - Additional session notes
- `README.md` - VibeTTY overview with ConnectBot attribution
