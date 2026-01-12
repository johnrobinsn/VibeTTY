# New Features

This document tracks new features added to ConnectBot.

## Virtual Terminal Width

**Status:** Working (needs testing)
**Files Modified:**
- `termlib/lib/src/main/java/org/connectbot/terminal/Terminal.kt`
- `app/src/main/java/org/connectbot/ui/screens/console/ConsoleScreen.kt`
- `app/src/main/java/org/connectbot/ui/screens/settings/SettingsScreen.kt`

**Description:**
Allows the terminal to render wider than the physical screen width (e.g., 120 columns on a narrow phone). Users can pan horizontally with single-finger drag to view content beyond the viewport.

**Features:**
- Configurable column width (80-200 columns) in Settings
- Single-finger drag for both vertical scroll and horizontal pan
- Thin scroll indicator at bottom shows horizontal position
- Background extends to full virtual width
- Font size changes automatically adjust terminal width

**Known Issues:**
- None currently known

---

## Toggle Keyboard/Title Bar on Tap

**Status:** Complete
**Files Modified:**
- `app/src/main/java/org/connectbot/ui/screens/console/ConsoleScreen.kt`

**Description:**
Tapping the terminal now toggles the keyboard bar and title bar visibility instead of only showing them. This allows users to quickly dismiss the UI overlay by tapping again rather than waiting for the 3-second auto-hide timeout.

**Behavior:**
- First tap: Shows keyboard bar and title bar (if auto-hide enabled)
- Second tap: Hides keyboard bar and title bar immediately
- Interacting with keyboard buttons resets the auto-hide timer without toggling

---

## JitPack/Composite Build for termlib

**Status:** Complete
**Files Modified:**
- `build.gradle.kts`
- `gradle/libs.versions.toml`
- `settings.gradle.kts`

**Description:**
ConnectBot now uses the `johnrobinsn/termlib` fork via JitPack for distribution. For local development, a composite build automatically uses the local `../termlib` directory if present.

**For other developers:**
- Clone connectbot
- Run `./gradlew build`
- Gradle pulls termlib from JitPack automatically

**For local development:**
- Clone both connectbot and termlib side by side
- Changes to termlib are picked up immediately without publishing

---

# Development Notes

## Scroll/Pan Gesture Implementation - Lessons Learned

### The Problem
Implementing combined vertical scroll + horizontal pan with a single finger drag had multiple issues:
1. Vertical dragging didn't track the finger (jumped to top/bottom)
2. Horizontal panning while scrolled to top caused jump to bottom
3. Fling worked but drag didn't

### Root Cause Analysis

**Issue 1: Race condition with multiple state variables**

The original approach used multiple state variables that could get out of sync:
- `dragScrollOffset` (local Float) - tracking during drag
- `scrollOffset` (Animatable) - for fling animation
- `screenState.scrollbackPosition` (Int) - terminal buffer position
- `lastScrolledLines` (Int) - tracking integer line changes

When calling `screenState.scrollBy()`, it updates `scrollbackPosition`, which could trigger LaunchedEffects that sync `scrollOffset`, creating feedback loops.

**Issue 2: Async issues with Animatable**

Using `coroutineScope.launch { scrollOffset.snapTo() }` is async. Reading `scrollOffset.value` on the next event might get the OLD value before snapTo completed.

**Issue 3: Initial offset calculation**

Adding `totalOffset.y` when entering scroll mode, then also running the scroll handler (which adds `dragAmount.y`) caused double-counting or incorrect initial position.

### The Solution

1. **Use a local variable for drag tracking** - `currentScrollOffset` tracks position during drag, avoiding async Animatable issues

2. **Initialize from current position only** - When entering scroll mode:
   ```kotlin
   currentScrollOffset = (screenState.scrollbackPosition * baseCharHeight).toFloat()
   ```
   Don't add `totalOffset.y` - let the scroll handler add `dragAmount.y` naturally.

3. **Don't use `continue`** - Let the scroll handler run on the same event that triggers scroll mode.

4. **Sync to Animatable only at gesture end** - Before fling:
   ```kotlin
   scrollOffset.snapTo(currentScrollOffset)
   ```

5. **Add `isUserScrolling` checks to ALL LaunchedEffects** - Prevents auto-scroll and sync effects from interfering during user interaction.

6. **Single coroutine for fling** - Snap and animateDecay in same coroutine to avoid race conditions.

### Key Code Patterns

**Scroll mode entry (simplified):**
```kotlin
if (gestureType == GestureType.Undetermined && !longPressDetected) {
    val totalOffset = change.position - down.position
    if (totalOffset.getDistanceSquared() > touchSlopSquared) {
        gestureType = GestureType.Scroll
        isUserScrolling = true
        // Initialize from current position ONLY
        currentScrollOffset = (screenState.scrollbackPosition * baseCharHeight).toFloat()
        // Apply horizontal offset
        if (isHorizontalPanEnabled) {
            horizontalPanOffset = (horizontalPanOffset - totalOffset.x).coerceIn(0f, maxHorizontalPan)
        }
        // DON'T continue - let scroll handler run
    }
}
```

**Scroll handler:**
```kotlin
GestureType.Scroll -> {
    isUserScrolling = true
    currentScrollOffset = (currentScrollOffset + dragAmount.y).coerceIn(0f, maxScroll)
    val scrolledLines = (currentScrollOffset / baseCharHeight).toInt()
    if (scrolledLines != screenState.scrollbackPosition) {
        screenState.scrollBy(scrolledLines - screenState.scrollbackPosition)
    }
    // Horizontal pan...
}
```

**Fling (gesture end):**
```kotlin
coroutineScope.launch {
    scrollOffset.snapTo(currentScrollOffset)  // Sync first
    var targetValue = currentScrollOffset
    scrollOffset.animateDecay(initialVelocity = velocity.y, ...) {
        targetValue = value
        val scrolledLines = (value / baseCharHeight).toInt()
        screenState.scrollBy(scrolledLines - screenState.scrollbackPosition)
    }
    // Clamp and cleanup...
    isUserScrolling = false
}
```

### Things That DIDN'T Work

1. **Using `scrollOffset.value` during drag** - Async updates caused stale reads
2. **Adding `totalOffset.y` at scroll mode entry** - Caused position jumps
3. **Using `continue` after scroll mode entry** - Skipped necessary scroll handler
4. **Multiple coroutines for snap + fling** - Race condition reading targetValue
5. **Tracking `lastScrolledLines` separately** - Added complexity, prone to drift

---

# Current State (January 2025)

## Repository Structure
- **connectbot**: `/mntc/code/connectbot` - Main app (johnrobinsn fork)
- **termlib**: `/mntc/code/termlib` - Terminal library (johnrobinsn fork)

## Key Files for Virtual Width Feature

### termlib
- `lib/src/main/java/org/connectbot/terminal/Terminal.kt`
  - Lines ~788-1060: Gesture handling (scroll/pan)
  - Lines ~733-755: LaunchedEffects for auto-scroll and sync
  - Lines ~422: `isUserScrolling` state variable
  - Lines ~543: `maxScroll` calculation
  - `virtualWidthColumns` parameter enables wider-than-screen rendering
  - `horizontalPanOffset` state for pan position
  - `HorizontalScrollIndicator` composable at end of file

### connectbot
- `app/src/main/java/org/connectbot/ui/screens/console/ConsoleScreen.kt`
  - Lines ~301-317: `handleTerminalTap()` and `handleKeyboardInteraction()`
  - Lines ~438: Terminal composable with `virtualWidthColumns` parameter
- `app/src/main/java/org/connectbot/ui/screens/settings/SettingsScreen.kt`
  - Virtual width toggle and column selector

## TODO
1. Test edge cases: rapid scrolling, zoom gestures, orientation changes
2. Remove debug logging from Terminal.kt when stable

---

# TUI Scroll Stability Fixes (January 2026)

## Problem
When running TUI applications (like claude code) that produce continuous output, horizontal panning while scrolled up in the buffer would cause the view to jump to the bottom.

## Root Causes Identified

1. **Stale fling completions** - Previous gesture's fling animation could complete during a new gesture, clearing `isUserScrolling` flag
2. **Mid-gesture maxScroll changes** - TUI output changing scrollback size would cause `maxScroll` to change, and `coerceIn(0f, maxScroll)` would force scroll position to 0
3. **LaunchedEffect re-triggering** - Effects keyed on `isUserScrolling` would re-run when gesture ended

## Solutions Implemented

### 1. Generation Tracking
```kotlin
var scrollGestureGeneration by remember { mutableStateOf(0) }

// Increment when starting new scroll gesture
scrollGestureGeneration++
thisGestureGeneration = scrollGestureGeneration

// Only clear flag if this is still current gesture
if (gestureGen == scrollGestureGeneration) {
    isUserScrolling = false
}
```

### 2. Capture maxScroll at Scroll Mode Entry
```kotlin
// Capture when entering scroll mode (not at gesture start)
gestureMaxScroll = screenState.snapshot.scrollback.size * baseCharHeight

// Use throughout gesture
currentScrollOffset = (currentScrollOffset + dragAmount.y).coerceIn(0f, gestureMaxScroll)
```

### 3. Vertical Movement Threshold
```kotlin
// Only update vertical scroll if meaningful movement
if (kotlin.math.abs(dragAmount.y) > 0.5f) {
    currentScrollOffset = ...
}
```

### 4. Remove isUserScrolling from LaunchedEffect Keys
Changed from:
```kotlin
LaunchedEffect(screenState.scrollbackPosition, isUserScrolling) { ... }
```
To:
```kotlin
LaunchedEffect(screenState.scrollbackPosition) { ... }
```

## Horizontal Auto-Pan Disabled
TUI applications often park the terminal cursor at a fixed position (column 0) while rendering input text elsewhere using escape sequences. This makes cursor-based horizontal auto-pan unreliable. Users must manually pan horizontally using single-finger drag.
