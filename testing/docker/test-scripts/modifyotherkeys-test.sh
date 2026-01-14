#!/bin/bash
# modifyotherkeys-test.sh - Test xterm modifyOtherKeys protocol
# This is what tmux uses for extended key support
# Expected output when pressing Shift+Enter: ^[[27;2;13~ (ESC[27;2;13~)

echo "=== xterm modifyOtherKeys Protocol Test ==="
echo ""
echo "This test enables modifyOtherKeys mode 2 and shows key sequences."
echo "Press Shift+Enter - should show: ^[[27;2;13~"
echo "Press Ctrl+Enter  - should show: ^[[27;5;13~"
echo "Press Ctrl+C to exit."
echo ""

# Enable modifyOtherKeys mode 2
printf '\e[>4;2m'

echo "Protocol enabled. Press keys:"
cat -v

# Cleanup: disable modifyOtherKeys on exit
trap 'printf "\e[>4;0m"; echo ""; echo "Protocol disabled."' EXIT
