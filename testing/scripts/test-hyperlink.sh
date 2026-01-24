#!/bin/bash
# Test OSC 8 hyperlink rendering in VibeTTY
#
# Usage: ./test-hyperlink.sh
#
# If running in tmux, ensure you have this in ~/.tmux.conf:
#   set -g allow-passthrough on
#   set -ga terminal-features ",*:hyperlinks"

echo "=== Test A: All links together, no echo between ==="
printf '\033]8;;https://google.com\033\\Google\033]8;;\033\\\n'
printf '\033]8;;https://github.com\033\\GitHub\033]8;;\033\\\n'
printf '\033]8;;https://example.com\033\\Example\033]8;;\033\\\n'

echo ""
echo "=== Test B: Same links with echo before each ==="
echo "B1:"
printf '\033]8;;https://google.com\033\\Google\033]8;;\033\\\n'
echo "B2:"
printf '\033]8;;https://github.com\033\\GitHub\033]8;;\033\\\n'
echo "B3:"
printf '\033]8;;https://example.com\033\\Example\033]8;;\033\\\n'

echo ""
echo "=== Test C: Link with id param ==="
printf '\033]8;id=myid;https://github.com\033\\GitHub with ID\033]8;;\033\\\n'
printf '\033]8;;https://github.com\033\\GitHub no ID\033]8;;\033\\\n'

echo ""
echo "Which work? (A: all 3? B1/B2/B3? C: with-id/no-id?)"
