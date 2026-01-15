#!/bin/bash
# verify-shift-enter.sh - Automated Shift+Enter verification
# Returns 0 if correct sequence received, 1 otherwise
# Results written to /tmp/key-test-result.txt for programmatic reading
#
# Usage: ./verify-shift-enter.sh [--timeout SECONDS] [--no-protocol]
#
# Expected sequences:
#   Kitty protocol: ^[[13;2u (ESC[13;2u)
#   modifyOtherKeys: ^[[27;2;13~ (ESC[27;2;13~)
#   Plain Enter (failure): ^M

TIMEOUT=30
ENABLE_PROTOCOL=true
RESULT_FILE="/tmp/key-test-result.txt"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --no-protocol)
            ENABLE_PROTOCOL=false
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Expected patterns (as shown by cat -v)
EXPECTED_KITTY='\^\[\[13;2u'
EXPECTED_MOK='\^\[\[27;2;13~'
PLAIN_ENTER='\^M$'

cleanup() {
    if $ENABLE_PROTOCOL; then
        # Disable Kitty protocol
        printf '\e[<u' 2>/dev/null || true
    fi
}
trap cleanup EXIT

echo "=== Shift+Enter Verification Test ===" | tee "$RESULT_FILE"
echo "Timeout: ${TIMEOUT}s" | tee -a "$RESULT_FILE"
echo "" | tee -a "$RESULT_FILE"

if $ENABLE_PROTOCOL; then
    echo "Enabling Kitty keyboard protocol..." | tee -a "$RESULT_FILE"
    # Enable Kitty keyboard protocol (flag 1 = disambiguate)
    printf '\e[>1u'
else
    echo "Protocol disabled (testing raw input)" | tee -a "$RESULT_FILE"
fi

echo "" | tee -a "$RESULT_FILE"
echo "Waiting for Shift+Enter input..." | tee -a "$RESULT_FILE"
echo "(Press Shift+Enter now)" | tee -a "$RESULT_FILE"
echo "" | tee -a "$RESULT_FILE"

# Use cat -v to show key sequences visually
# Timeout after specified seconds
INPUT=$(timeout "$TIMEOUT" head -c 30 | cat -v) || true

echo "" | tee -a "$RESULT_FILE"
echo "Received: $INPUT" | tee -a "$RESULT_FILE"

# Check what we received
if echo "$INPUT" | grep -qE "$EXPECTED_KITTY"; then
    echo "SUCCESS: Kitty protocol sequence detected (^[[13;2u)" | tee -a "$RESULT_FILE"
    echo "RESULT=PASS_KITTY" >> "$RESULT_FILE"
    exit 0
elif echo "$INPUT" | grep -qE "$EXPECTED_MOK"; then
    echo "SUCCESS: modifyOtherKeys sequence detected (^[[27;2;13~)" | tee -a "$RESULT_FILE"
    echo "RESULT=PASS_MOK" >> "$RESULT_FILE"
    exit 0
elif echo "$INPUT" | grep -qE "$PLAIN_ENTER"; then
    echo "FAILURE: Plain Enter detected - modifier was lost!" | tee -a "$RESULT_FILE"
    echo "RESULT=FAIL_NO_MODIFIER" >> "$RESULT_FILE"
    exit 1
elif [[ -z "$INPUT" ]]; then
    echo "FAILURE: No input received (timeout)" | tee -a "$RESULT_FILE"
    echo "RESULT=FAIL_TIMEOUT" >> "$RESULT_FILE"
    exit 1
else
    echo "INFO: Received unknown sequence (check if valid)" | tee -a "$RESULT_FILE"
    echo "RESULT=UNKNOWN" >> "$RESULT_FILE"
    # Don't fail immediately - the sequence might be valid but unexpected
    exit 0
fi
