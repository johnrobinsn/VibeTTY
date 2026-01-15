#!/bin/bash
# monitor-terminal-io.sh - Enable and monitor terminal I/O logging
#
# This script enables debug logging for terminal I/O and displays it.
# Useful for debugging keyboard protocol issues and automated testing.
#
# Usage:
#   ./monitor-terminal-io.sh          # Enable logging and show output
#   ./monitor-terminal-io.sh --off    # Disable logging
#   ./monitor-terminal-io.sh --status # Check if logging is enabled

set -e

ADB="${ADB:-/home/jr/Android/Sdk/platform-tools/adb}"
PROP_NAME="debug.vibetty.terminal_io"
LOG_TAG="TerminalIO"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

case "${1:-}" in
    --off)
        echo -e "${YELLOW}Disabling terminal I/O logging...${NC}"
        $ADB shell setprop "$PROP_NAME" false
        echo -e "${GREEN}Logging disabled${NC}"
        exit 0
        ;;
    --status)
        value=$($ADB shell getprop "$PROP_NAME")
        if [[ "$value" == "true" ]]; then
            echo -e "${GREEN}Terminal I/O logging is ENABLED${NC}"
        else
            echo -e "${YELLOW}Terminal I/O logging is DISABLED${NC}"
        fi
        exit 0
        ;;
    --help|-h)
        echo "Usage: $0 [--off|--status|--help]"
        echo ""
        echo "Options:"
        echo "  (none)    Enable logging and show output (Ctrl+C to stop)"
        echo "  --off     Disable logging"
        echo "  --status  Check if logging is enabled"
        echo ""
        echo "Log format:"
        echo "  SEND - Data sent from keyboard to server"
        echo "  RECV - Data received from server to terminal"
        echo ""
        echo "Example output:"
        echo "  SEND [7 bytes]: 1b 5b 31 33 3b 32 75"
        echo "  SEND readable: ESC[13;2u"
        echo ""
        echo "This represents Shift+Enter in Kitty keyboard protocol format."
        exit 0
        ;;
esac

# Enable logging
echo -e "${CYAN}Enabling terminal I/O logging...${NC}"
$ADB shell setprop "$PROP_NAME" true

# Note: The app needs to be restarted or reconnected for the property change to take effect
echo -e "${YELLOW}Note: Restart the SSH connection for logging to take effect${NC}"
echo ""
echo -e "${GREEN}Monitoring terminal I/O (Ctrl+C to stop)${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Clear logcat buffer and start monitoring
$ADB logcat -c
$ADB logcat -v time "$LOG_TAG:V" "*:S" | while read line; do
    # Color-code the output
    if [[ "$line" == *"SEND"* ]]; then
        echo -e "${GREEN}$line${NC}"
    elif [[ "$line" == *"RECV"* ]]; then
        echo -e "${CYAN}$line${NC}"
    elif [[ "$line" == *"KEY:"* ]]; then
        echo -e "${YELLOW}$line${NC}"
    else
        echo "$line"
    fi
done
