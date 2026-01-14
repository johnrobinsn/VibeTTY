#!/bin/bash
# wide-output.sh - Generate wide output to test virtual terminal width
# This helps verify horizontal scrolling/panning works correctly

echo "=== Virtual Width Test ==="
echo ""
echo "The following line is 150 characters wide (numbered markers):"
echo ""

# Generate a 150-character wide line with markers every 10 chars
for i in $(seq -w 10 10 150); do
    printf "=====%s" "$i"
done
echo ""

echo ""
echo "If virtual width is enabled (100+ columns), you should be able to"
echo "pan horizontally to see the entire line."
echo ""

# Also show column ruler
echo "Column ruler (every 10):"
printf "         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15\n"
printf "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890\n"
