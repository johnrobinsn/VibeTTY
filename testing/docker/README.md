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

## Known Limitations

### ADB Keyboard Input

ADB keyboard input has limitations with modifier keys:

1. **`input keyevent`**: Sends individual key events but modifiers don't combine properly with other keys.

2. **`input keycombination`**: Available on Android 12+ but doesn't reliably send key combinations through the soft keyboard to apps.

3. **`input text`**: Only works for printable characters, cannot send control characters or escape sequences.

**Workaround**: For testing keyboard protocol features like Shift+Enter:
- Use manual testing with the soft keyboard
- Write UIAutomator instrumented tests that can inject proper KeyEvents with modifiers
- Use the terminal I/O logging to verify correct sequences are sent

### Testing Shift+Enter

To manually test Shift+Enter:

1. Enable terminal I/O logging: `adb shell setprop debug.vibetty.terminal_io true`
2. Connect to an SSH session
3. Run `cat -v` or `~/test-scripts/verify-shift-enter.sh`
4. Press Shift+Enter on the soft keyboard
5. Check logcat for the sequence sent:
   - Correct (Kitty): `ESC[13;2u`
   - Correct (modifyOtherKeys): `ESC[27;2;13~`
   - Failure: Just `^M` (Enter without modifier)
