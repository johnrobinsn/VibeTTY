#!/bin/bash
# adb-helpers.sh - Reusable ADB automation functions for VibeTTY testing
#
# Usage: source this file in your test scripts
#   source "$(dirname "$0")/lib/adb-helpers.sh"
#
# Features:
#   - UI dump caching for faster element lookups
#   - Terminal I/O log capture
#   - Key combination support (Shift+Enter, Ctrl+C, etc.)
#   - High-level workflow functions

set -o pipefail

# Configuration
ADB="${ADB:-/home/jr/Android/Sdk/platform-tools/adb}"
PACKAGE="${PACKAGE:-org.connectbot.debug}"
UI_DUMP_FILE="/sdcard/ui.xml"
LOCAL_UI_CACHE="/tmp/vibetty_ui_cache.xml"
LOG_CAPTURE_FILE="/tmp/vibetty_terminal_io.log"

# Cache control
_UI_CACHE_VALID=false
_UI_CACHE_CONTENT=""

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

#=============================================================================
# LOGGING
#=============================================================================

log_info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_pass()  { echo -e "${GREEN}[PASS]${NC} $*"; }
log_fail()  { echo -e "${RED}[FAIL]${NC} $*"; }
log_debug() { [[ -n "$DEBUG" ]] && echo -e "${CYAN}[DEBUG]${NC} $*" || true; }

#=============================================================================
# ADB BASICS
#=============================================================================

check_adb() {
    if [[ ! -x "$ADB" ]]; then
        log_error "ADB not found at: $ADB"
        return 1
    fi
    if ! $ADB devices | grep -q "device$"; then
        log_error "No Android device/emulator connected"
        return 1
    fi
    return 0
}

#=============================================================================
# UI DUMP CACHING
# - Avoids repeated slow UI dumps when checking multiple elements
# - Call invalidate_ui_cache after actions that change the UI
#=============================================================================

invalidate_ui_cache() {
    _UI_CACHE_VALID=false
    _UI_CACHE_CONTENT=""
    log_debug "UI cache invalidated"
}

# Get UI dump (uses cache if valid)
get_ui_dump() {
    if [[ "$_UI_CACHE_VALID" == "true" && -n "$_UI_CACHE_CONTENT" ]]; then
        log_debug "Using cached UI dump"
        echo "$_UI_CACHE_CONTENT"
        return 0
    fi

    log_debug "Fetching fresh UI dump"
    $ADB shell uiautomator dump "$UI_DUMP_FILE" >/dev/null 2>&1
    _UI_CACHE_CONTENT=$($ADB shell cat "$UI_DUMP_FILE" 2>/dev/null)
    _UI_CACHE_VALID=true
    echo "$_UI_CACHE_CONTENT"
}

# Force fresh dump (invalidates cache and fetches new)
refresh_ui() {
    invalidate_ui_cache
    get_ui_dump >/dev/null
}

#=============================================================================
# ELEMENT FINDING
#=============================================================================

# Find element bounds by testTag (resource-id)
find_bounds_by_tag() {
    local tag="$1"
    get_ui_dump | tr '><' '\n\n' | \
        grep "resource-id=\"$tag\"" | \
        grep -oP 'bounds="\[\d+,\d+\]\[\d+,\d+\]"' | \
        grep -oP '\[\d+,\d+\]\[\d+,\d+\]' | head -1
}

# Find element bounds by text content
find_bounds_by_text() {
    local text="$1"
    get_ui_dump | tr '><' '\n\n' | \
        grep "text=\"$text\"" | \
        grep -oP 'bounds="\[\d+,\d+\]\[\d+,\d+\]"' | \
        grep -oP '\[\d+,\d+\]\[\d+,\d+\]' | head -1
}

# Find element bounds by content-desc
find_bounds_by_desc() {
    local desc="$1"
    get_ui_dump | tr '><' '\n\n' | \
        grep "content-desc=\"$desc\"" | \
        grep -oP 'bounds="\[\d+,\d+\]\[\d+,\d+\]"' | \
        grep -oP '\[\d+,\d+\]\[\d+,\d+\]' | head -1
}

# Calculate center point from bounds string "[x1,y1][x2,y2]"
bounds_to_center() {
    local bounds="$1"
    local x1 y1 x2 y2

    x1=$(echo "$bounds" | grep -oP '^\[\K\d+')
    y1=$(echo "$bounds" | grep -oP '^\[\d+,\K\d+')
    x2=$(echo "$bounds" | grep -oP '\]\[\K\d+')
    y2=$(echo "$bounds" | grep -oP '\]\[\d+,\K\d+')

    [[ -z "$x1" || -z "$y1" || -z "$x2" || -z "$y2" ]] && return 1

    echo "$(( (x1 + x2) / 2 )) $(( (y1 + y2) / 2 ))"
}

# Check if element exists (by testTag)
element_exists() {
    local tag="$1"
    [[ -n $(find_bounds_by_tag "$tag") ]]
}

# Get all visible text on screen
get_visible_text() {
    get_ui_dump | grep -oP 'text="[^"]*"' | sed 's/text="//g; s/"$//g' | grep -v '^$'
}

#=============================================================================
# TAPPING
#=============================================================================

# Tap at coordinates
tap_at() {
    local x="$1" y="$2"
    $ADB shell input tap "$x" "$y"
    invalidate_ui_cache
}

# Tap element by testTag
tap_by_tag() {
    local tag="$1"
    local bounds center

    bounds=$(find_bounds_by_tag "$tag")
    if [[ -z "$bounds" ]]; then
        log_error "Element not found: $tag"
        return 1
    fi

    center=$(bounds_to_center "$bounds")
    local cx=${center% *} cy=${center#* }

    log_info "Tap $tag ($cx,$cy)"
    tap_at "$cx" "$cy"
}

# Tap element by text
tap_by_text() {
    local text="$1"
    local bounds center

    bounds=$(find_bounds_by_text "$text")
    if [[ -z "$bounds" ]]; then
        log_error "Text not found: $text"
        return 1
    fi

    center=$(bounds_to_center "$bounds")
    local cx=${center% *} cy=${center#* }

    log_info "Tap '$text' ($cx,$cy)"
    tap_at "$cx" "$cy"
}

# Tap element by content-desc
tap_by_desc() {
    local desc="$1"
    local bounds center

    bounds=$(find_bounds_by_desc "$desc")
    if [[ -z "$bounds" ]]; then
        log_error "Element not found with desc: $desc"
        return 1
    fi

    center=$(bounds_to_center "$bounds")
    local cx=${center% *} cy=${center#* }

    log_info "Tap desc='$desc' ($cx,$cy)"
    tap_at "$cx" "$cy"
}

#=============================================================================
# WAITING
#=============================================================================

# Wait for element to appear (by testTag)
wait_for_tag() {
    local tag="$1"
    local timeout="${2:-10}"
    local start=$SECONDS

    log_debug "Waiting for: $tag (${timeout}s)"

    while (( SECONDS - start < timeout )); do
        invalidate_ui_cache
        if element_exists "$tag"; then
            log_debug "Found: $tag"
            return 0
        fi
        sleep 0.3
    done

    log_error "Timeout waiting for: $tag"
    return 1
}

# Wait for element to disappear
wait_for_gone() {
    local tag="$1"
    local timeout="${2:-10}"
    local start=$SECONDS

    log_debug "Waiting for gone: $tag"

    while (( SECONDS - start < timeout )); do
        invalidate_ui_cache
        if ! element_exists "$tag"; then
            log_debug "Gone: $tag"
            return 0
        fi
        sleep 0.3
    done

    log_error "Still present: $tag"
    return 1
}

# Wait for any of multiple elements
wait_for_any() {
    local timeout="${1:-10}"
    shift
    local tags=("$@")
    local start=$SECONDS

    while (( SECONDS - start < timeout )); do
        invalidate_ui_cache
        for tag in "${tags[@]}"; do
            if element_exists "$tag"; then
                echo "$tag"
                return 0
            fi
        done
        sleep 0.3
    done

    return 1
}

#=============================================================================
# KEYBOARD INPUT
#=============================================================================

# Type text (printable characters only)
type_text() {
    local text="$1"
    log_debug "Type: $text"
    $ADB shell input text "$text"
}

# Send single key event
send_key() {
    local key="$1"
    log_debug "Key: $key"
    $ADB shell input keyevent "$key"
    invalidate_ui_cache
}

# Send key combination using keycombination (Android 12+)
# Example: send_key_combo KEYCODE_SHIFT_LEFT KEYCODE_ENTER
send_key_combo() {
    local keys="$*"
    log_info "Key combo: $keys"
    $ADB shell input keycombination $keys
    invalidate_ui_cache
}

# Common key shortcuts
press_enter()      { send_key KEYCODE_ENTER; }
press_back()       { send_key KEYCODE_BACK; }
press_escape()     { send_key KEYCODE_ESCAPE; }
press_tab()        { send_key KEYCODE_TAB; }
send_shift_enter() { send_key_combo KEYCODE_SHIFT_LEFT KEYCODE_ENTER; }
send_ctrl_c()      { send_key_combo KEYCODE_CTRL_LEFT KEYCODE_C; }
send_ctrl_d()      { send_key_combo KEYCODE_CTRL_LEFT KEYCODE_D; }
send_ctrl_l()      { send_key_combo KEYCODE_CTRL_LEFT KEYCODE_L; }  # Clear screen

# Type text directly to terminal (requires terminal to have focus)
# Taps terminal area first to ensure ImeInputView has focus, then uses input text
# Note: Spaces must be encoded as %s for ADB input text
type_to_terminal() {
    local text="$1"
    # Tap terminal to ensure focus (center of typical terminal area)
    $ADB shell input tap 640 1500
    sleep 0.1
    # Replace spaces with %s for ADB
    local escaped="${text// /%s}"
    log_debug "Type to terminal: $escaped"
    $ADB shell input text "$escaped"
    invalidate_ui_cache
}

#=============================================================================
# TERMINAL I/O LOG CAPTURE
#=============================================================================

# Enable terminal I/O logging
enable_terminal_logging() {
    $ADB shell setprop debug.vibetty.terminal_io true
    log_info "Terminal I/O logging enabled"
}

# Disable terminal I/O logging
disable_terminal_logging() {
    $ADB shell setprop debug.vibetty.terminal_io false
    log_info "Terminal I/O logging disabled"
}

# Start capturing terminal I/O logs
# Usage: start_log_capture
start_log_capture() {
    $ADB logcat -c
    log_debug "Log capture started"
}

# Get captured terminal I/O logs since start_log_capture
# Returns SEND/RECV lines from TerminalIO tag
get_captured_logs() {
    $ADB logcat -d | grep "TerminalIO" | grep -E "(SEND|RECV)"
}

# Get only SEND logs (what the app sent)
get_send_logs() {
    get_captured_logs | grep "SEND"
}

# Get only RECV logs (what the app received)
get_recv_logs() {
    get_captured_logs | grep "RECV"
}

# Check if a specific sequence was sent
# Usage: was_sequence_sent "ESC[13;2u"
was_sequence_sent() {
    local expected="$1"
    get_send_logs | grep -q "$expected"
}

# Capture logs during an action
# Usage: logs=$(capture_during "send_shift_enter")
capture_during() {
    local action="$1"
    start_log_capture
    eval "$action"
    sleep 0.5
    get_captured_logs
}

#=============================================================================
# APP CONTROL
#=============================================================================

launch_app() {
    log_info "Launching $PACKAGE"
    $ADB shell am start -n "$PACKAGE/org.connectbot.ui.MainActivity" >/dev/null 2>&1
    sleep 1
    invalidate_ui_cache
}

stop_app() {
    log_info "Stopping $PACKAGE"
    $ADB shell am force-stop "$PACKAGE"
    invalidate_ui_cache
}

restart_app() {
    stop_app
    sleep 0.5
    launch_app
}

is_app_foreground() {
    $ADB shell dumpsys activity activities 2>/dev/null | grep -q "mResumedActivity.*$PACKAGE"
}

#=============================================================================
# HIGH-LEVEL WORKFLOWS
#=============================================================================

# Ensure app is running and on host list
ensure_on_hostlist() {
    if ! is_app_foreground; then
        launch_app
        sleep 1
    fi

    # If on console, go back
    invalidate_ui_cache
    if element_exists "console_button_back"; then
        tap_by_tag "console_button_back"
        sleep 1
        invalidate_ui_cache
    fi

    # Wait for host list (don't fail if timeout - caller can handle)
    wait_for_tag "hostlist_fab_add" 5 || return 1
    return 0
}

# Connect to a host by tag, handling prompts
# Usage: connect_to_host "hostlist_item_1" "password"
connect_to_host() {
    local host_tag="$1"
    local password="$2"

    log_info "Connecting to $host_tag"

    # Tap host
    tap_by_tag "$host_tag" || return 1
    sleep 1

    # Handle host key prompt if it appears
    if wait_for_tag "prompt_button_yes" 3; then
        log_info "Accepting host key"
        tap_by_tag "prompt_button_yes"
        sleep 1
    fi

    # Handle password prompt if it appears
    if wait_for_tag "prompt_field_password" 3; then
        log_info "Entering password"
        type_text "$password"
        sleep 0.3
        tap_by_tag "prompt_button_ok"
        sleep 2
    fi

    # Verify we're on console
    if wait_for_tag "console_button_input" 5; then
        log_pass "Connected successfully"
        return 0
    else
        log_fail "Connection failed"
        return 1
    fi
}

# Send a command to the terminal via the text input dialog
# Usage: send_terminal_command "ls -la"
send_terminal_command() {
    local cmd="$1"

    # Open text input dialog
    tap_by_tag "console_button_input" || return 1
    sleep 0.5

    # Type command (replace spaces with %s for ADB)
    local escaped_cmd="${cmd// /%s}"
    type_text "$escaped_cmd"
    sleep 0.3

    # Tap Send button
    tap_by_desc "Send" || return 1
    sleep 0.5

    invalidate_ui_cache
    return 0
}

# Disconnect from current session
disconnect() {
    if element_exists "console_button_back"; then
        tap_by_tag "console_button_back"
        sleep 1
        invalidate_ui_cache
    fi
}

#=============================================================================
# TEST ASSERTIONS
#=============================================================================

assert_element_exists() {
    local tag="$1"
    local msg="${2:-Element exists: $tag}"

    if element_exists "$tag"; then
        log_pass "$msg"
        return 0
    else
        log_fail "$msg"
        return 1
    fi
}

assert_text_visible() {
    local text="$1"
    local msg="${2:-Text visible: $text}"

    if get_visible_text | grep -qF "$text"; then
        log_pass "$msg"
        return 0
    else
        log_fail "$msg"
        return 1
    fi
}

assert_sequence_sent() {
    local expected="$1"
    local msg="${2:-Sequence sent: $expected}"

    if was_sequence_sent "$expected"; then
        log_pass "$msg"
        return 0
    else
        log_fail "$msg"
        get_send_logs | tail -5
        return 1
    fi
}

#=============================================================================
# INITIALIZATION
#=============================================================================

# Verify ADB is working
if ! check_adb 2>/dev/null; then
    log_warn "ADB check failed - some functions may not work"
fi

log_debug "ADB helpers loaded (PACKAGE=$PACKAGE)"
