#!/bin/bash
# tmux-test.sh - Test tmux integration with extended keys
# Requires tmux to be configured with: set -g extended-keys always

echo "=== tmux Extended Keys Test ==="
echo ""

# Check if tmux is available
if ! command -v tmux &> /dev/null; then
    echo "ERROR: tmux is not installed"
    exit 1
fi

# Check tmux config
if ! grep -q "extended-keys" ~/.tmux.conf 2>/dev/null; then
    echo "WARNING: ~/.tmux.conf may not have 'extended-keys always' set"
fi

echo "Starting tmux session with cat -v..."
echo "Press Shift+Enter inside tmux - should show: ^[[13;2u"
echo "Press Ctrl+D or type 'exit' to leave tmux."
echo ""

# Kill any existing test session
tmux kill-session -t vibetty-test 2>/dev/null

# Create new session running cat -v
tmux new-session -s vibetty-test "echo 'Inside tmux - press Shift+Enter:'; cat -v; exec bash"
