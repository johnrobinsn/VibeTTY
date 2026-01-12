# Claude Session Notes

Last updated: 2026-01-12

## Repository Structure
- **connectbot**: `/mntc/code/connectbot` - Main app (johnrobinsn fork)
- **termlib**: `/mntc/code/termlib` - Terminal library (johnrobinsn fork)

## Git Remotes
Both repos use `fork` remote for pushing (not `origin` which points to upstream):
```bash
git push fork main
```

## Recent Work Summary

### Virtual Terminal Width Feature
Allows terminal to render wider than physical screen (e.g., 120 columns on narrow phone) with single-finger horizontal panning.

**Key files:**
- `termlib/lib/src/main/java/org/connectbot/terminal/Terminal.kt` - Main terminal composable
- `connectbot/app/src/main/java/org/connectbot/ui/screens/settings/SettingsScreen.kt` - Virtual width settings

### Scroll/Pan Gesture Fixes (Latest Session)

**Problems solved:**
1. **Race condition with long-press detection** - Replaced `launch{}` coroutine with time-based detection in event loop
2. **Stale fling completions** - Added `scrollGestureGeneration` counter to prevent old flings from clearing `isUserScrolling`
3. **Mid-gesture maxScroll changes** - Capture `gestureMaxScroll` when entering scroll mode, not at gesture start
4. **Horizontal pan affecting scroll** - Added 0.5px threshold for vertical movement
5. **LaunchedEffect re-running on gesture end** - Removed `isUserScrolling` from effect keys

**Horizontal auto-pan disabled** - TUI applications (like claude code) often park cursor at column 0 while rendering input elsewhere, making cursor-based auto-pan unreliable. Users pan manually instead.

### Key Code Patterns in Terminal.kt

**Gesture generation tracking:**
```kotlin
var scrollGestureGeneration by remember { mutableStateOf(0) }

// In gesture handler:
scrollGestureGeneration++
thisGestureGeneration = scrollGestureGeneration
gestureMaxScroll = screenState.snapshot.scrollback.size * baseCharHeight

// In fling completion:
if (gestureGen == scrollGestureGeneration) {
    isUserScrolling = false
}
```

**Time-based long-press detection:**
```kotlin
val longPressStartTime = System.currentTimeMillis()
val longPressTimeoutMs = viewConfiguration.longPressTimeoutMillis

// In event loop:
val elapsedTime = System.currentTimeMillis() - longPressStartTime
if (elapsedTime >= longPressTimeoutMs && ...) {
    // Start selection
}
```

## Debug Logging
Debug logging is currently enabled in Terminal.kt (grep for `Log.d("Terminal"`). Can be removed when no longer needed.

## Build & Deploy
```bash
./gradlew installOssDebug  # Builds and installs to connected devices
```

## Documentation
- `NEW_FEATURES.md` - Documents virtual width feature and scroll/pan implementation lessons
- `README.md` files have experimental fork notices

## TODO
- Remove debug logging when stable
- Test edge cases: rapid scrolling, zoom gestures, orientation changes
