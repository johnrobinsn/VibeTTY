# VibeTTY Test Scripts

These scripts are designed to test various terminal features in VibeTTY.

## Scripts

| Script | Purpose |
|--------|---------|
| `echo-keys.sh` | Display raw key escape sequences |
| `shift-enter-test.sh` | Test Kitty keyboard protocol (CSI u) |
| `modifyotherkeys-test.sh` | Test xterm modifyOtherKeys protocol |
| `wide-output.sh` | Test virtual terminal width / horizontal panning |
| `tmux-test.sh` | Test tmux integration with extended keys |
| `disconnect-test.sh` | Test disconnect/reconnect dialog |

## Expected Results

### Shift+Enter
- **Kitty protocol**: `^[[13;2u` (ESC[13;2u)
- **modifyOtherKeys**: `^[[27;2;13~` (ESC[27;2;13~)
- **In tmux**: `^[[13;2u` (tmux converts to CSI u format)

### Ctrl+Enter
- **Kitty protocol**: `^[[13;5u`
- **modifyOtherKeys**: `^[[27;5;13~`

## Usage

```bash
# From VibeTTY, connect to the test server then run:
~/test-scripts/echo-keys.sh
~/test-scripts/shift-enter-test.sh
# etc.
```
