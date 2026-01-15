#!/bin/bash
# adb-helpers.sh - Reusable ADB automation functions for VibeTTY testing
#
# Usage: source this file in your test scripts
#   source "$(dirname "$0")/lib/adb-helpers.sh"
#
# Required environment:
#   ADB - Path to adb binary (default: /home/jr/Android/Sdk/platform-tools/adb)
#   PACKAGE - App package name (default: org.connectbot.debug)

# Configuration
ADB="${ADB:-/home/jr/Android/Sdk/platform-tools/adb}"
PACKAGE="${PACKAGE:-org.connectbot.debug}"
UI_DUMP_FILE="/sdcard/ui.xml"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $*"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $*"; }

# Check if ADB is available and device is connected
check_adb() {
    if [[ ! -x "$ADB" ]]; then
        log_error "ADB not found at: $ADB"
        return 1
    fi

    if ! $ADB devices | grep -q "device$"; then
        log_error "No Android device/emulator connected"
        return 1
    fi

    log_info "ADB connected to device"
    return 0
}

# Dump UI hierarchy and return path to dump file
dump_ui() {
    $ADB shell uiautomator dump "$UI_DUMP_FILE" >/dev/null 2>&1
    echo "$UI_DUMP_FILE"
}

# Get UI dump content
get_ui_dump() {
    dump_ui >/dev/null
    $ADB shell cat "$UI_DUMP_FILE"
}

# Find element bounds by testTag (resource-id)
# Returns bounds string like "[100,200][300,400]" or empty if not found
find_bounds_by_tag() {
    local tag="$1"
    local dump
    dump=$(get_ui_dump)

    echo "$dump" | tr '><' '\n\n' | \
        grep "resource-id=\"$tag\"" | \
        grep -oP 'bounds="\[\d+,\d+\]\[\d+,\d+\]"' | \
        grep -oP '\[\d+,\d+\]\[\d+,\d+\]'
}

# Find element bounds by text content
find_bounds_by_text() {
    local text="$1"
    local dump
    dump=$(get_ui_dump)

    echo "$dump" | tr '><' '\n\n' | \
        grep "text=\"$text\"" | \
        grep -oP 'bounds="\[\d+,\d+\]\[\d+,\d+\]"' | \
        grep -oP '\[\d+,\d+\]\[\d+,\d+\]' | \
        head -1
}

# Calculate center point from bounds string "[x1,y1][x2,y2]"
bounds_to_center() {
    local bounds="$1"
    local x1 y1 x2 y2

    # Parse bounds format [x1,y1][x2,y2]
    x1=$(echo "$bounds" | grep -oP '^\[\K\d+')
    y1=$(echo "$bounds" | grep -oP '^\[\d+,\K\d+')
    x2=$(echo "$bounds" | grep -oP '\]\[\K\d+')
    y2=$(echo "$bounds" | grep -oP '\]\[\d+,\K\d+')

    if [[ -z "$x1" || -z "$y1" || -z "$x2" || -z "$y2" ]]; then
        return 1
    fi

    local cx=$(( (x1 + x2) / 2 ))
    local cy=$(( (y1 + y2) / 2 ))

    echo "$cx $cy"
}

# Tap on an element by testTag
# Returns 0 on success, 1 if element not found
tap_by_tag() {
    local tag="$1"
    local bounds center cx cy

    bounds=$(find_bounds_by_tag "$tag")
    if [[ -z "$bounds" ]]; then
        log_error "Element not found: $tag"
        return 1
    fi

    center=$(bounds_to_center "$bounds")
    cx=$(echo "$center" | cut -d' ' -f1)
    cy=$(echo "$center" | cut -d' ' -f2)

    log_info "Tapping $tag at ($cx, $cy)"
    $ADB shell input tap "$cx" "$cy"
    return 0
}

# Tap on an element by text content
tap_by_text() {
    local text="$1"
    local bounds center cx cy

    bounds=$(find_bounds_by_text "$text")
    if [[ -z "$bounds" ]]; then
        log_error "Element not found with text: $text"
        return 1
    fi

    center=$(bounds_to_center "$bounds")
    cx=$(echo "$center" | cut -d' ' -f1)
    cy=$(echo "$center" | cut -d' ' -f2)

    log_info "Tapping '$text' at ($cx, $cy)"
    $ADB shell input tap "$cx" "$cy"
    return 0
}

# Wait for an element to appear (by testTag)
# Returns 0 when found, 1 on timeout
wait_for_tag() {
    local tag="$1"
    local timeout="${2:-10}"
    local interval="${3:-0.5}"
    local elapsed=0

    log_info "Waiting for element: $tag (timeout: ${timeout}s)"

    while (( $(echo "$elapsed < $timeout" | bc -l) )); do
        if [[ -n $(find_bounds_by_tag "$tag") ]]; then
            log_info "Found element: $tag"
            return 0
        fi
        sleep "$interval"
        elapsed=$(echo "$elapsed + $interval" | bc -l)
    done

    log_error "Timeout waiting for: $tag"
    return 1
}

# Wait for an element to disappear (by testTag)
wait_for_tag_gone() {
    local tag="$1"
    local timeout="${2:-10}"
    local interval="${3:-0.5}"
    local elapsed=0

    log_info "Waiting for element to disappear: $tag"

    while (( $(echo "$elapsed < $timeout" | bc -l) )); do
        if [[ -z $(find_bounds_by_tag "$tag") ]]; then
            log_info "Element gone: $tag"
            return 0
        fi
        sleep "$interval"
        elapsed=$(echo "$elapsed + $interval" | bc -l)
    done

    log_error "Element still present: $tag"
    return 1
}

# Check if element exists (by testTag)
element_exists() {
    local tag="$1"
    [[ -n $(find_bounds_by_tag "$tag") ]]
}

# Type text into focused field
type_text() {
    local text="$1"
    log_info "Typing: $text"
    $ADB shell input text "$text"
}

# Send key event
send_key() {
    local key="$1"
    log_info "Sending key: $key"
    $ADB shell input keyevent "$key"
}

# Send key combination (e.g., Shift+Enter)
# Note: This uses keyevent which may not work exactly like physical keyboard
send_key_combo() {
    local modifier="$1"
    local key="$2"
    log_info "Sending key combo: $modifier + $key"
    $ADB shell input keyevent --longpress "$modifier" "$key"
}

# Press Enter key
press_enter() {
    send_key KEYCODE_ENTER
}

# Press Back button
press_back() {
    send_key KEYCODE_BACK
}

# Launch app
launch_app() {
    log_info "Launching $PACKAGE"
    $ADB shell monkey -p "$PACKAGE" -c android.intent.category.LAUNCHER 1 2>/dev/null
    sleep 2
}

# Force stop app
stop_app() {
    log_info "Stopping $PACKAGE"
    $ADB shell am force-stop "$PACKAGE"
}

# Get current activity
get_current_activity() {
    $ADB shell dumpsys activity activities | grep -i "mResumedActivity" | head -1
}

# Take screenshot
take_screenshot() {
    local output="${1:-/tmp/screenshot.png}"
    $ADB shell screencap -p /sdcard/screenshot.png
    $ADB pull /sdcard/screenshot.png "$output" 2>/dev/null
    log_info "Screenshot saved: $output"
}

# Check if app is in foreground
is_app_foreground() {
    get_current_activity | grep -q "$PACKAGE"
}

# Get text content of all visible elements
get_visible_text() {
    get_ui_dump | grep -oP 'text="[^"]*"' | sed 's/text="//g; s/"$//g' | grep -v '^$'
}

# Assert element exists (for tests)
assert_element_exists() {
    local tag="$1"
    local msg="${2:-Element should exist: $tag}"

    if element_exists "$tag"; then
        log_pass "$msg"
        return 0
    else
        log_fail "$msg"
        return 1
    fi
}

# Assert text visible on screen
assert_text_visible() {
    local text="$1"
    local msg="${2:-Text should be visible: $text}"

    if get_visible_text | grep -qF "$text"; then
        log_pass "$msg"
        return 0
    else
        log_fail "$msg"
        return 1
    fi
}

log_info "ADB helpers loaded (ADB=$ADB, PACKAGE=$PACKAGE)"
