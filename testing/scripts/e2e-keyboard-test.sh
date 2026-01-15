#!/bin/bash
# e2e-keyboard-test.sh - End-to-end keyboard protocol testing
#
# This script automates the full flow:
# 1. Launch VibeTTY app
# 2. Connect to Docker SSH test server
# 3. Handle prompts (host key, password)
# 4. Start verification script (direct or tmux)
# 5. Send Shift+Enter via ADB
# 6. Verify correct sequence was received
#
# Prerequisites:
# - Android emulator running
# - Docker test container running (docker compose up -d)
# - VibeTTY app installed with a host configured for Docker SSH
#
# Usage:
#   ./e2e-keyboard-test.sh [OPTIONS]
#
# Options:
#   --direct        Test direct SSH (no tmux)
#   --tmux          Test inside tmux session
#   --all           Run all test scenarios (default)
#   --host-id ID    Host ID to connect to (default: auto-detect)
#   --skip-connect  Skip connection, assume already connected
#   --verbose       Enable verbose output

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/adb-helpers.sh"

# Test configuration
DOCKER_CONTAINER="vibetty-test"
SSH_PASSWORD="testpass"
TEST_MODE="all"
HOST_ID=""
SKIP_CONNECT=false
VERBOSE=false

# Test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --direct)
            TEST_MODE="direct"
            shift
            ;;
        --tmux)
            TEST_MODE="tmux"
            shift
            ;;
        --all)
            TEST_MODE="all"
            shift
            ;;
        --host-id)
            HOST_ID="$2"
            shift 2
            ;;
        --skip-connect)
            SKIP_CONNECT=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--direct|--tmux|--all] [--host-id ID] [--skip-connect] [--verbose]"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check ADB
    if ! check_adb; then
        log_error "ADB check failed"
        return 1
    fi

    # Check Docker container
    if ! docker ps --format '{{.Names}}' | grep -q "^${DOCKER_CONTAINER}$"; then
        log_error "Docker container not running: $DOCKER_CONTAINER"
        log_info "Start it with: cd testing/docker && docker compose up -d"
        return 1
    fi

    # Check app is installed
    if ! $ADB shell pm list packages | grep -q "$PACKAGE"; then
        log_error "App not installed: $PACKAGE"
        return 1
    fi

    log_pass "All prerequisites met"
    return 0
}

# Find host item in list (auto-detect if not specified)
find_host_id() {
    if [[ -n "$HOST_ID" ]]; then
        echo "$HOST_ID"
        return
    fi

    # Look for any hostlist_item_* in the UI
    local dump
    dump=$(get_ui_dump)

    local id
    id=$(echo "$dump" | grep -oP 'resource-id="hostlist_item_\K\d+' | head -1)

    if [[ -n "$id" ]]; then
        echo "$id"
    else
        log_error "No host found in list"
        return 1
    fi
}

# Connect to SSH host
connect_to_host() {
    log_info "Connecting to SSH host..."

    # Launch app if needed
    if ! is_app_foreground; then
        launch_app
        sleep 2
    fi

    # Find and tap host
    local host_id
    host_id=$(find_host_id) || return 1
    log_info "Found host ID: $host_id"

    tap_by_tag "hostlist_item_$host_id" || return 1
    sleep 2

    # Handle host key verification if it appears
    if element_exists "prompt_button_yes"; then
        log_info "Host key verification prompt detected"
        tap_by_tag "prompt_button_yes"
        sleep 1
    fi

    # Handle password prompt
    if wait_for_tag "prompt_field_password" 5; then
        log_info "Password prompt detected"

        # Tap password field to focus
        tap_by_tag "prompt_field_password"
        sleep 0.3

        # Enter password
        type_text "$SSH_PASSWORD"
        sleep 0.3

        # Tap OK
        tap_by_tag "prompt_button_ok"
        sleep 2
    fi

    # Verify we're on console screen
    if wait_for_tag "console_button_input" 5; then
        log_pass "Connected to SSH host"
        return 0
    else
        log_fail "Failed to connect - console not visible"
        return 1
    fi
}

# Send command to terminal via text input dialog
send_terminal_command() {
    local cmd="$1"

    log_info "Sending command: $cmd"

    # Tap input button
    tap_by_tag "console_button_input" || return 1
    sleep 1

    # Type command
    type_text "$cmd"
    sleep 0.3

    # Find and tap send button (it's a clickable view after the text field)
    # We'll use the text field bounds to find nearby clickable element
    local dump
    dump=$(get_ui_dump)

    # Look for clickable view with bounds near 1100,1130 area (send button)
    local send_bounds
    send_bounds=$(echo "$dump" | tr '><' '\n\n' | \
        grep 'clickable="true"' | \
        grep 'bounds="\[10' | \
        grep -oP 'bounds="\[\d+,\d+\]\[\d+,\d+\]"' | \
        tail -1 | \
        grep -oP '\[\d+,\d+\]\[\d+,\d+\]')

    if [[ -n "$send_bounds" ]]; then
        local center cx cy
        center=$(bounds_to_center "$send_bounds")
        cx=$(echo "$center" | cut -d' ' -f1)
        cy=$(echo "$center" | cut -d' ' -f2)
        $ADB shell input tap "$cx" "$cy"
    else
        # Fallback: press Enter
        press_enter
    fi

    sleep 1
    return 0
}

# Run direct SSH test (no tmux)
test_direct_ssh() {
    log_info "=== Test: Direct SSH Shift+Enter ==="
    ((TESTS_RUN++))

    if ! $SKIP_CONNECT; then
        connect_to_host || { ((TESTS_FAILED++)); return 1; }
    fi

    # Start verification script
    send_terminal_command "~/test-scripts/verify-shift-enter.sh --timeout 15"
    sleep 2

    # Send Shift+Enter
    log_info "Sending Shift+Enter via ADB..."
    send_key_combo "KEYCODE_SHIFT_LEFT" "KEYCODE_ENTER"
    sleep 3

    # Check result from Docker
    local result
    result=$(docker exec "$DOCKER_CONTAINER" cat /tmp/key-test-result.txt 2>/dev/null | grep "^RESULT=" | cut -d= -f2)

    if [[ "$result" == PASS_* ]]; then
        log_pass "Direct SSH Shift+Enter: $result"
        ((TESTS_PASSED++))
        return 0
    else
        log_fail "Direct SSH Shift+Enter: ${result:-UNKNOWN}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Run tmux test
test_tmux() {
    log_info "=== Test: tmux Shift+Enter ==="
    ((TESTS_RUN++))

    if ! $SKIP_CONNECT; then
        connect_to_host || { ((TESTS_FAILED++)); return 1; }
    fi

    # Start tmux with verification script
    send_terminal_command "~/test-scripts/verify-shift-enter-tmux.sh"
    sleep 3

    # Send Shift+Enter
    log_info "Sending Shift+Enter via ADB (inside tmux)..."
    send_key_combo "KEYCODE_SHIFT_LEFT" "KEYCODE_ENTER"
    sleep 3

    # Check result from Docker
    local result
    result=$(docker exec "$DOCKER_CONTAINER" cat /tmp/key-test-result.txt 2>/dev/null | grep "^RESULT=" | tail -1 | cut -d= -f2)

    if [[ "$result" == PASS_* ]]; then
        log_pass "tmux Shift+Enter: $result"
        ((TESTS_PASSED++))
        return 0
    else
        log_fail "tmux Shift+Enter: ${result:-UNKNOWN}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Print test summary
print_summary() {
    echo ""
    echo "========================================"
    echo "Test Summary"
    echo "========================================"
    echo "Tests run:    $TESTS_RUN"
    echo "Tests passed: $TESTS_PASSED"
    echo "Tests failed: $TESTS_FAILED"
    echo "========================================"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        log_fail "Some tests failed"
        return 1
    else
        log_pass "All tests passed"
        return 0
    fi
}

# Main
main() {
    echo "========================================"
    echo "VibeTTY E2E Keyboard Test"
    echo "========================================"
    echo ""

    check_prerequisites || exit 1

    case $TEST_MODE in
        direct)
            test_direct_ssh
            ;;
        tmux)
            test_tmux
            ;;
        all)
            test_direct_ssh
            echo ""
            # Disconnect and reconnect for tmux test
            press_back
            sleep 1
            test_tmux
            ;;
    esac

    print_summary
}

main "$@"
