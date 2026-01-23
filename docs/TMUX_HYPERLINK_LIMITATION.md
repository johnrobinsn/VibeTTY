# tmux Hyperlink Segment Persistence Limitation

## Summary

When using OSC 8 hyperlinks inside tmux, hyperlink segments can become stale or misaligned when tmux redraws the screen (e.g., during scrollback navigation).

## Symptoms

- Hyperlink underlines may appear on the wrong text after scrolling in tmux
- The "B3:" label might be underlined instead of "Example" after scrolling up/down
- Links may appear to "jump" between different text when scrolling

## Root Cause

VibeTTY stores hyperlink segments by row index in `TerminalLine.semanticSegments`. When tmux scrolls its viewport, it redraws the screen with different content at each row, but VibeTTY has no way to distinguish between:

1. **Same content, different row** (tmux scroll) - should clear old segments
2. **Same row, same content** (cursor movement, attribute change) - should preserve segments

The OSC 8 sequence flow:
1. OSC 8 start arrives → save cursor position
2. Text is drawn → line update callback
3. OSC 8 end arrives → create segment via `addSemanticSegment()`

If we clear segments on every line update, step 3's segment gets cleared by subsequent redraws. If we preserve segments, they persist incorrectly after tmux scrolls.

## Attempted Fixes

### 1. Never preserve segments
**Result:** Broke all hyperlinks - segments cleared before rendering completes

### 2. Compare text content before clearing
**Result:** False positives - cells differ in attributes (colors) even when text matches, causing segments to be incorrectly cleared

### 3. Always preserve segments (current)
**Result:** Works for most cases, but stale segments appear when tmux scrolls

## Why tmux Is Special

tmux acts as a terminal multiplexer that:
- Maintains its own scrollback buffer
- Redraws the entire visible screen when scrolling
- Doesn't re-emit OSC 8 sequences when redrawing cached content
- Uses its own hyperlink IDs (`id=tmux1E;...`) when passing through OSC 8

Without tmux, hyperlinks work correctly because:
- Direct output maintains proper OSC 8 sequence timing
- Scrollback is handled by VibeTTY's native scrollback buffer
- Segments stay aligned with their content

## Potential Future Solutions

### Option A: Content hashing
Hash the visible text content of each line and clear segments when the hash changes. Would need to ignore attribute differences.

### Option B: Timestamp-based expiry
Add timestamps to segments and expire them after a short period. Re-emit from tmux would refresh them.

### Option C: tmux passthrough mode detection
Detect when running inside tmux and use different segment handling logic.

### Option D: Row content signature
Store a signature of the text content when creating a segment, clear segment if content no longer matches.

## Current Workaround

Users can avoid the issue by:
- Testing hyperlinks outside of tmux first
- Not scrolling in tmux when hyperlinks are visible
- Using `tmux clear-history` to reset state if segments become misaligned

## Related Files

- `termlib/.../TerminalEmulator.kt` - Line update and segment storage
- `termlib/.../OscParser.kt` - OSC 8 parsing and segment creation
- `termlib/.../TerminalLine.kt` - Segment storage in lines
- `termlib/.../SemanticType.kt` - SemanticSegment data class

## References

- [OSC 8 Hyperlink Spec](https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda)
- tmux hyperlinks: Requires `set -ga terminal-features ",*:hyperlinks"` in tmux 3.4+
