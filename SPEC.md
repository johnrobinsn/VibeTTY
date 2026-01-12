# Virtual Terminal Width Feature Specification

## Overview

Add support for a virtual terminal width that allows the terminal to render at a wider column count than the physical screen can display. This enables TUI applications that require 80-120+ columns to function properly on narrow mobile screens. Users can pan horizontally to view the full terminal width.

## Goals

- Enable TUI applications (htop, btop, vim, tmux, etc.) that assume minimum 80-120 column widths to work correctly on mobile
- Provide intuitive horizontal panning via two-finger gestures
- Auto-pan to keep the cursor visible as users type or navigate
- Maintain the existing vertical scrollback buffer behavior

## Feature Details

### Virtual Width Configuration

- **Scope**: Global default setting (applies to all connections)
- **Default value**: 80 columns
- **Options**: Preset values (80, 120, 160) plus custom numeric input
- **Behavior**: If physical screen width (in columns at current font size) exceeds the configured virtual width, use the physical width instead (max of the two)
- **Storage**: New fields in settings, separate from existing `force_size_columns`/`force_size_rows` profile fields
- **PTY reporting**: Report the virtual width to the remote server via SIGWINCH/pty size so applications can utilize the full width

### Viewport and Panning

- **Initial position**: Left-aligned (column 0) when connection establishes
- **Vertical scrollback**: Unchanged - vertical scrolling operates independently as it does today
- **Horizontal panning**: Two-finger horizontal drag gesture to pan left/right within the virtual width
- **Gesture handling**: Two-finger horizontal-only movement triggers pan; pinch-to-zoom for font size remains unchanged
- **Pan bounds**: Viewport cannot pan beyond column 0 on the left or (virtual_width - physical_width) on the right

### Auto-Pan (Cursor Following)

- **Trigger**: Edge-triggered panning when cursor approaches viewport edge
- **Margin**: Fixed margin of 5 columns from viewport edge
- **Behavior**: When cursor moves within 5 columns of the left or right edge of the visible viewport, automatically pan to keep the cursor visible with the margin preserved
- **Selection**: Auto-pan during text selection when dragging to viewport edges

### Visual Indicator

- **Type**: Thin horizontal scrollbar at the bottom of the terminal
- **Visibility**: Always visible when virtual width exceeds physical width
- **Position**: Shows current horizontal position within the full virtual width
- **Appearance**: Minimal, non-intrusive design consistent with app theme

### Orientation Changes

- When device rotates, recalculate physical column count based on new screen width
- Virtual width setting remains unchanged
- Viewport pan position adjusts proportionally
- If new physical width >= virtual width, panning is effectively disabled (no scrollbar shown)

## Technical Implementation

### Database Schema

Add new preference fields (SharedPreferences or global settings table):
- `virtual_width_enabled`: Boolean
- `virtual_width_columns`: Integer (default 80)

### Component Changes

1. **TerminalBridge/Relay**:
   - Report virtual width (or max of virtual/physical) to PTY
   - Track viewport offset for rendering

2. **Terminal Rendering (ConsoleScreen/ConsoleViewModel)**:
   - Render full virtual width buffer
   - Apply viewport offset to determine visible region
   - Draw horizontal scrollbar indicator

3. **Gesture Handling**:
   - Detect two-finger horizontal drag vs pinch
   - Update viewport offset based on pan gesture
   - Implement momentum/fling scrolling (optional enhancement)

4. **Cursor Tracking**:
   - Monitor cursor position changes
   - Trigger viewport pan when cursor within 5 columns of edge
   - Handle selection drag auto-panning

### Settings UI

Add to Settings screen:
- Toggle: "Virtual terminal width"
- When enabled, show width selector:
  - Preset buttons: 80, 120, 160
  - Custom input field for arbitrary column count

## Testing Strategy

### Unit Tests

1. **Cursor tracking + pan logic**:
   - Cursor at column 0, viewport at 0 - no pan needed
   - Cursor moves to right edge minus margin - verify pan triggers
   - Cursor moves left to margin - verify pan adjusts
   - Cursor jumps to arbitrary position - verify viewport centers appropriately

2. **Viewport bounds**:
   - Cannot pan left past column 0
   - Cannot pan right past (virtual_width - physical_width)
   - Virtual width < physical width - panning disabled

3. **Width calculation**:
   - Virtual width 120, physical 40 - use 120
   - Virtual width 80, physical 100 - use 100
   - Orientation change recalculates correctly

### Instrumented Tests

1. **Gesture recognition**:
   - Two-finger horizontal drag triggers pan
   - Two-finger pinch triggers zoom (not pan)
   - Mixed gestures handled correctly

2. **Rendering accuracy**:
   - Terminal content renders correctly at various virtual widths
   - Scrollbar position matches viewport offset
   - Text selection spans correctly across pan boundaries

3. **Integration with TUI apps**:
   - Connect to test server running htop/btop at 120 columns
   - Verify app renders full width, pan reveals all content
   - Verify cursor following works during navigation

### Test Coverage

- Target line coverage: 80%+ for new virtual width code paths
- Branch coverage for edge cases (bounds checking, orientation changes)
- Integration test coverage for gesture handling

### Manual Testing Checklist

- [ ] Enable virtual width, connect to SSH server
- [ ] Run htop - verify full width renders, pan works
- [ ] Type commands - verify cursor auto-follows
- [ ] Rotate device - verify behavior
- [ ] Select text spanning beyond viewport - verify auto-pan
- [ ] Pinch to zoom - verify font size changes, virtual width recalculates columns

## Future Considerations

- Virtual height (for apps assuming 24+ rows) - design width feature to allow extension
- Keyboard shortcuts for quick navigation (Home/End for horizontal) - defer based on user feedback
- Per-profile or per-host virtual width overrides

## Non-Goals (Explicit Exclusions)

- Virtual height in this implementation
- 2D free-form canvas scrolling (vertical remains independent)
- Minimap overlay (using simple scrollbar instead)
