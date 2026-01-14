#!/bin/bash
# disconnect-test.sh - Test disconnect/reconnect functionality
# This script will disconnect after a countdown, allowing testing of the reconnect dialog

echo "=== Disconnect Test ==="
echo ""
echo "This will forcibly close the SSH connection in 5 seconds."
echo "Use this to test the Reconnect dialog in VibeTTY."
echo ""

for i in 5 4 3 2 1; do
    echo "Disconnecting in $i..."
    sleep 1
done

echo "Disconnecting now!"
# Kill our own parent SSH process
kill -9 $PPID
