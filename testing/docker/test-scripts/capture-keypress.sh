#!/bin/bash
# capture-keypress.sh - Simple key capture for automated testing
# Writes received bytes to /tmp/keypress.log in hex format
#
# Usage: ./capture-keypress.sh
# Then press keys. The raw bytes are logged.
# Check with: cat /tmp/keypress.log

LOG_FILE="/tmp/keypress.log"
RESULT_FILE="/tmp/key-test-result.txt"

echo "=== Key Capture Started ===" | tee "$RESULT_FILE"
echo "Press any key. Raw bytes will be logged to $LOG_FILE" | tee -a "$RESULT_FILE"
echo "Press Ctrl+C to stop." | tee -a "$RESULT_FILE"
echo "" | tee -a "$RESULT_FILE"

# Clear log
> "$LOG_FILE"

# Read and log bytes
while IFS= read -r -n1 -d '' char; do
    # Get hex value of character
    printf '%s' "$char" | xxd -p >> "$LOG_FILE"

    # Also show in terminal
    printf '%s' "$char" | cat -v

    # Check for common patterns
    content=$(cat "$LOG_FILE" | tr -d '\n')

    # ESC[13;2u = 1b5b31333b3275
    if [[ "$content" == *"1b5b31333b3275"* ]]; then
        echo "" | tee -a "$RESULT_FILE"
        echo "DETECTED: Kitty Shift+Enter (ESC[13;2u)" | tee -a "$RESULT_FILE"
        echo "RESULT=PASS_KITTY" >> "$RESULT_FILE"
    fi

    # ESC[27;2;13~ = 1b5b32373b323b31337e
    if [[ "$content" == *"1b5b32373b323b31337e"* ]]; then
        echo "" | tee -a "$RESULT_FILE"
        echo "DETECTED: modifyOtherKeys Shift+Enter (ESC[27;2;13~)" | tee -a "$RESULT_FILE"
        echo "RESULT=PASS_MOK" >> "$RESULT_FILE"
    fi

    # Plain Enter = 0d
    if [[ "$content" == "0d" ]] || [[ "$content" == *"0d" && ${#content} -le 4 ]]; then
        echo "" | tee -a "$RESULT_FILE"
        echo "DETECTED: Plain Enter (no modifier)" | tee -a "$RESULT_FILE"
        # Don't mark as result yet, might be part of longer sequence
    fi
done

echo "" | tee -a "$RESULT_FILE"
echo "Capture stopped." | tee -a "$RESULT_FILE"
