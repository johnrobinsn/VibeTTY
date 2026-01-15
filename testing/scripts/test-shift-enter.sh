#!/bin/bash
# test-shift-enter.sh - Automated Shift+Enter keyboard protocol test
#
# Tests that VibeTTY correctly sends ESC[13;2u for Shift+Enter
# (Kitty keyboard protocol)
#
# Usage:
#   ./test-shift-enter.sh              # Run test
#   ./test-shift-enter.sh --restart    # Restart app first (needed if property changed)
#   DEBUG=1 ./test-shift-enter.sh      # Run with debug output
#
# Prerequisites:
#   - Android emulator/device connected
#   - Docker SSH server running (docker compose up -d)
#   - VibeTTY app installed with TerminalIOLogger support

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/adb-helpers.sh"

#=============================================================================
# TEST CONFIGURATION
#=============================================================================

HOST_TAG="hostlist_item_1"
HOST_PASSWORD="testpass"
EXPECTED_SEQUENCE="ESC\[13;2u"

#=============================================================================
# MAIN TEST
#=============================================================================

main() {
    local do_restart=false
    [[ "${1:-}" == "--restart" ]] && do_restart=true

    echo "========================================"
    echo " Shift+Enter Keyboard Protocol Test"
    echo "========================================"
    echo ""

    # Step 1: Enable terminal I/O logging
    log_info "Step 1: Enable terminal I/O logging"
    enable_terminal_logging

    # Step 2: Restart app if requested (needed for property to take effect)
    if $do_restart; then
        log_info "Step 2: Restarting app"
        restart_app
        sleep 2
    fi

    # Step 3: Ensure app is running and go to hostlist
    log_info "Step 3: Ensure app is on host list"
    ensure_on_hostlist || {
        log_warn "Could not reach host list, launching app"
        launch_app
        sleep 2
    }

    # Step 4: Connect to SSH host
    log_info "Step 4: Connect to SSH host"
    invalidate_ui_cache
    if ! element_exists "console_button_input"; then
        connect_to_host "$HOST_TAG" "$HOST_PASSWORD" || {
            log_fail "Could not connect to SSH host"
            exit 1
        }
    else
        log_info "Already connected"
    fi

    # Step 5: Clean up any previous cat -v and clear screen
    log_info "Step 5: Clean up terminal and start cat -v"
    send_ctrl_c  # Exit any running command
    sleep 0.3
    send_ctrl_l  # Clear screen
    sleep 0.3
    # Type directly to terminal (no dialog needed)
    type_to_terminal "cat -v"
    press_enter
    sleep 0.5

    # Step 6: Clear logs and send Shift+Enter
    log_info "Step 6: Send Shift+Enter and capture logs"
    start_log_capture
    send_shift_enter
    sleep 0.5

    # Step 7: Verify the sequence was sent AND echoed by cat -v
    log_info "Step 7: Verify sequence sent and received"
    echo ""
    echo "--- SEND logs (what app sent) ---"
    get_send_logs | tail -5
    echo ""
    echo "--- RECV logs (cat -v echo) ---"
    get_recv_logs | tail -5
    echo "---------------------------------"
    echo ""

    # Check both: app sent correct sequence AND server echoed it back
    local send_ok=false
    local recv_ok=false

    if was_sequence_sent "$EXPECTED_SEQUENCE"; then
        send_ok=true
        log_pass "App sent correct sequence: ESC[13;2u"
    else
        log_fail "App did NOT send expected sequence"
    fi

    # cat -v displays ESC as ^[ so we look for ^[[13;2u in RECV
    # Use fixed string match to avoid regex escaping issues
    if get_recv_logs | grep -qF '^[[13;2u'; then
        recv_ok=true
        log_pass "Server echoed: ^[[13;2u (cat -v output)"
    else
        log_fail "Server did NOT echo expected sequence"
    fi

    echo ""
    if $send_ok && $recv_ok; then
        echo "========================================"
        log_pass "TEST PASSED: Full round-trip verified"
        echo "========================================"
        exit 0
    else
        echo "========================================"
        log_fail "TEST FAILED: Round-trip incomplete"
        echo "========================================"
        exit 1
    fi
}

# Run main
main "$@"
