#!/bin/bash
# verify-shift-enter-tmux.sh - Test Shift+Enter inside tmux session
# Tests that tmux correctly passes modifier keys when 'extended-keys always' is set
#
# Usage: ./verify-shift-enter-tmux.sh [--no-extended-keys]
#
# Expected behavior:
#   With extended-keys: Shift+Enter produces ^[[13;2u (converted by tmux)
#   Without extended-keys: Shift+Enter produces ^M (modifier lost - FAILURE)

set -e

RESULT_FILE="/tmp/key-test-result.txt"
SESSION_NAME="vibetty-keytest"
USE_EXTENDED_KEYS=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-extended-keys)
            USE_EXTENDED_KEYS=false
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Kill any existing test session
tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true

echo "=== Shift+Enter tmux Verification Test ===" | tee "$RESULT_FILE"

if $USE_EXTENDED_KEYS; then
    echo "Mode: extended-keys ENABLED (expect success)" | tee -a "$RESULT_FILE"
    # Verify tmux.conf has extended-keys
    if ! grep -q "extended-keys" ~/.tmux.conf 2>/dev/null; then
        echo "WARNING: ~/.tmux.conf may not have 'extended-keys always' set" | tee -a "$RESULT_FILE"
    fi
else
    echo "Mode: extended-keys DISABLED (expect failure)" | tee -a "$RESULT_FILE"
    # Temporarily disable extended-keys for this test
    # We'll create a temporary tmux config
    TEMP_CONF=$(mktemp)
    grep -v "extended-keys" ~/.tmux.conf > "$TEMP_CONF" 2>/dev/null || true
    export TMUX_CONF="-f $TEMP_CONF"
fi

echo "" | tee -a "$RESULT_FILE"
echo "Starting tmux session with key capture..." | tee -a "$RESULT_FILE"
echo "Press Shift+Enter inside tmux when prompted." | tee -a "$RESULT_FILE"
echo "" | tee -a "$RESULT_FILE"

# Create a script to run inside tmux that captures keys
INNER_SCRIPT=$(mktemp)
cat > "$INNER_SCRIPT" << 'INNER_EOF'
#!/bin/bash
RESULT_FILE="/tmp/key-test-result.txt"

echo "=== Inside tmux ===" | tee -a "$RESULT_FILE"
echo "Waiting for Shift+Enter..." | tee -a "$RESULT_FILE"
echo "(Press Shift+Enter now)" | tee -a "$RESULT_FILE"

# Set raw mode
stty raw -echo

# Capture input (30 second timeout)
INPUT=$(timeout 30 dd bs=1 count=20 2>/dev/null | cat -v) || true

# Restore terminal
stty sane

echo "" | tee -a "$RESULT_FILE"
echo "Received inside tmux: $INPUT" | tee -a "$RESULT_FILE"

# Check patterns
EXPECTED_KITTY='\^\[\[13;2u'
EXPECTED_MOK='\^\[\[27;2;13~'
PLAIN_ENTER='\^M'

if echo "$INPUT" | grep -qE "$EXPECTED_KITTY"; then
    echo "SUCCESS: Kitty sequence in tmux (^[[13;2u)" | tee -a "$RESULT_FILE"
    echo "RESULT=PASS_TMUX_KITTY" >> "$RESULT_FILE"
    exit 0
elif echo "$INPUT" | grep -qE "$EXPECTED_MOK"; then
    echo "SUCCESS: modifyOtherKeys sequence in tmux (^[[27;2;13~)" | tee -a "$RESULT_FILE"
    echo "RESULT=PASS_TMUX_MOK" >> "$RESULT_FILE"
    exit 0
elif echo "$INPUT" | grep -qE "$PLAIN_ENTER"; then
    echo "FAILURE: Plain Enter in tmux - extended-keys not working!" | tee -a "$RESULT_FILE"
    echo "RESULT=FAIL_TMUX_NO_MODIFIER" >> "$RESULT_FILE"
    exit 1
elif [[ -z "$INPUT" ]]; then
    echo "FAILURE: No input received (timeout)" | tee -a "$RESULT_FILE"
    echo "RESULT=FAIL_TIMEOUT" >> "$RESULT_FILE"
    exit 1
else
    echo "FAILURE: Unexpected sequence" | tee -a "$RESULT_FILE"
    echo "RESULT=FAIL_UNKNOWN" >> "$RESULT_FILE"
    exit 1
fi
INNER_EOF
chmod +x "$INNER_SCRIPT"

# Start tmux session running the inner script
if $USE_EXTENDED_KEYS; then
    tmux new-session -s "$SESSION_NAME" "bash $INNER_SCRIPT; echo 'Press Enter to exit'; read"
else
    tmux $TMUX_CONF new-session -s "$SESSION_NAME" "bash $INNER_SCRIPT; echo 'Press Enter to exit'; read"
    rm -f "$TEMP_CONF"
fi

# Clean up
rm -f "$INNER_SCRIPT"

# Get result from file
if grep -q "RESULT=PASS" "$RESULT_FILE"; then
    exit 0
else
    exit 1
fi
