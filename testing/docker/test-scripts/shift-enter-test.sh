#!/bin/bash
# shift-enter-test.sh - Test Kitty keyboard protocol (Shift+Enter)
# Expected output when pressing Shift+Enter: ^[[13;2u (ESC[13;2u)

echo "=== Kitty Keyboard Protocol Test ==="
echo ""
echo "This test enables Kitty keyboard protocol and shows key sequences."
echo "Press Shift+Enter - should show: ^[[13;2u"
echo "Press Ctrl+Enter  - should show: ^[[13;5u"
echo "Press Ctrl+C to exit."
echo ""

# Enable Kitty keyboard protocol (flag 1 = disambiguate)
printf '\e[>1u'

echo "Protocol enabled. Press keys:"
cat -v

# Cleanup: disable Kitty protocol on exit
trap 'printf "\e[<u"; echo ""; echo "Protocol disabled."' EXIT
