# VibeTTY Docker Test Environment

This directory contains a Docker-based test environment for VibeTTY testing.

## Quick Start

```bash
# Start the Docker container
docker compose up -d

# Check status
docker compose ps

# Stop the container
docker compose down
```

## SSH Connection Details

- **Host**: `10.0.2.2` (from Android emulator)
- **Port**: `2222`
- **Username**: `testuser`
- **Password**: `testpass`

The container exposes SSH on port 2222 which maps to the host's localhost:2222. From an Android emulator, connect to `10.0.2.2:2222`.

## Test Scripts

### Server-Side Scripts (in container)

Located in `/home/testuser/test-scripts/` inside the container:

#### `verify-shift-enter.sh`
Verifies that Shift+Enter is encoded correctly by the terminal client.

```bash
# Run inside Docker container
~/test-scripts/verify-shift-enter.sh

# Expected success: ESC[13;2u (Kitty) or ESC[27;2;13~ (modifyOtherKeys)
# Failure: Plain Enter (^M) - modifier was lost
```

#### `verify-shift-enter-tmux.sh`
Same test but running inside a tmux session to verify tmux extended-keys handling.

```bash
~/test-scripts/verify-shift-enter-tmux.sh
```

### Client-Side Scripts (on host)

Located in `testing/scripts/`:

#### `monitor-terminal-io.sh`
Enable and monitor terminal I/O logging from VibeTTY app.

```bash
# Enable logging and start monitoring
./testing/scripts/monitor-terminal-io.sh

# Disable logging
./testing/scripts/monitor-terminal-io.sh --off

# Check status
./testing/scripts/monitor-terminal-io.sh --status
```

#### `lib/adb-helpers.sh`
Reusable ADB automation functions for UI testing.

```bash
source testing/scripts/lib/adb-helpers.sh

# Functions available:
tap_by_tag "hostlist_item_1"     # Tap element by testTag
wait_for_tag "prompt_button_ok"  # Wait for element to appear
type_text "hello world"          # Enter text via ADB
element_exists "console_button_input"  # Check if element present
```

## Terminal I/O Logging

VibeTTY includes a debug logging feature for terminal I/O that can be enabled at runtime:

```bash
# Enable logging
adb shell setprop debug.vibetty.terminal_io true

# Restart the SSH connection (or app) for the change to take effect

# Monitor logs
adb logcat -s TerminalIO:V
```

Log output shows:
- `SEND [N bytes]: xx xx xx` - Data sent from keyboard to server (hex)
- `SEND readable: ...` - Human-readable version with ESC, ^M, etc.
- `RECV [N bytes]: xx xx xx` - Data received from server (hex)
- `RECV readable: ...` - Human-readable version

### Example Output

```
SEND [7 bytes]: 1b 5b 31 33 3b 32 75
SEND readable: ESC[13;2u

RECV [680 bytes]: 57 65 6c 63 6f 6d 65 ...
RECV readable: Welcome to Ubuntu...
```

## TestTags for UI Automation

VibeTTY exposes testTags for UI automation via UIAutomator:

### Host List Screen
- `hostlist_item_N` - Host items (N = 1, 2, ...)
- `hostlist_item_N_menu` - Host item menu button
- `hostlist_fab_add` - Add host FAB
- `hostlist_menu_options` - Options menu

### Host Editor Screen
- `hosteditor_field_quickconnect` - Quick connect input field
- `hosteditor_button_save` - Save/Add host button

### Console Screen
- `console_button_back` - Back/disconnect button
- `console_button_input` - Text input dialog button
- `console_button_paste` - Paste button
- `console_button_menu` - Menu button

### Prompts
- `prompt_button_yes` / `prompt_button_no` - Host key verification
- `prompt_button_ok` / `prompt_button_cancel` - Password/input prompts
- `prompt_field_password` - Password input field
- `prompt_field_response` - General response input field

## ADB Keyboard Input

### Sending Key Combinations

Use `input keycombination` (Android 12+) to send modifier key combinations:

```bash
# Send Shift+Enter
adb shell input keycombination KEYCODE_SHIFT_LEFT KEYCODE_ENTER

# Send Ctrl+C
adb shell input keycombination KEYCODE_CTRL_LEFT KEYCODE_C
```

This works correctly with VibeTTY - Shift+Enter sends `ESC[13;2u` (Kitty protocol).

### Other Input Methods

- **`input keyevent`**: Individual key events only
- **`input text`**: Printable characters only, no control characters

### Automated Shift+Enter Testing

```bash
# 1. Enable terminal I/O logging
adb shell setprop debug.vibetty.terminal_io true

# 2. Connect to SSH and run cat -v
# 3. Send Shift+Enter via ADB
adb shell input keycombination KEYCODE_SHIFT_LEFT KEYCODE_ENTER

# 4. Check logcat for the sequence sent
adb logcat -s TerminalIO:V
# Expected: SEND readable: ESC[13;2u
```
