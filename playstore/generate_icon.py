#!/usr/bin/env python3
"""
Generate 512x512 Play Store icon for VibeTTY.
Recreates the adaptive icon design: >_ terminal prompt on dark background.
"""

from PIL import Image, ImageDraw

# Icon dimensions for Play Store
SIZE = 512

# Colors from the vector drawables
BG_COLOR = (25, 28, 27)       # #191C1B - Dark teal-tinted background
CHEVRON_COLOR = (0, 137, 123) # #00897B - Teal 600
CURSOR_COLOR = (100, 255, 218) # #64FFDA - Bright mint
CURSOR_GLOW = (100, 255, 218, 64)  # 25% opacity glow

# Scale factor from 108dp viewport to 512px
SCALE = SIZE / 108

def main():
    # Create image with alpha channel for the glow
    img = Image.new('RGBA', (SIZE, SIZE), BG_COLOR + (255,))
    draw = ImageDraw.Draw(img)

    # Convert coordinates from 108dp viewport to 512px
    def scale_point(x, y):
        return (x * SCALE, y * SCALE)

    def scale_width(w):
        return w * SCALE

    # Draw chevron > symbol
    # Path: M36,40 L54,54 L36,68
    chevron_points = [
        scale_point(36, 40),
        scale_point(54, 54),
        scale_point(36, 68),
    ]
    chevron_width = scale_width(7)

    # Draw chevron as two line segments with round caps
    draw.line([chevron_points[0], chevron_points[1]],
              fill=CHEVRON_COLOR, width=int(chevron_width))
    draw.line([chevron_points[1], chevron_points[2]],
              fill=CHEVRON_COLOR, width=int(chevron_width))

    # Draw round caps at corners
    cap_radius = chevron_width / 2
    for point in chevron_points:
        draw.ellipse([
            point[0] - cap_radius, point[1] - cap_radius,
            point[0] + cap_radius, point[1] + cap_radius
        ], fill=CHEVRON_COLOR)

    # Draw cursor glow (wider, semi-transparent)
    # Path: M58,66 L74,66 with width 12 and 25% opacity
    cursor_start = scale_point(58, 66)
    cursor_end = scale_point(74, 66)
    glow_width = scale_width(12)

    # Create a separate layer for the glow
    glow_layer = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_layer)
    glow_draw.line([cursor_start, cursor_end],
                   fill=CURSOR_GLOW, width=int(glow_width))
    # Round caps for glow
    glow_cap = glow_width / 2
    glow_draw.ellipse([
        cursor_start[0] - glow_cap, cursor_start[1] - glow_cap,
        cursor_start[0] + glow_cap, cursor_start[1] + glow_cap
    ], fill=CURSOR_GLOW)
    glow_draw.ellipse([
        cursor_end[0] - glow_cap, cursor_end[1] - glow_cap,
        cursor_end[0] + glow_cap, cursor_end[1] + glow_cap
    ], fill=CURSOR_GLOW)

    # Composite glow onto main image
    img = Image.alpha_composite(img, glow_layer)
    draw = ImageDraw.Draw(img)

    # Draw cursor underscore
    # Path: M58,66 L74,66 with width 6
    cursor_width = scale_width(6)
    draw.line([cursor_start, cursor_end],
              fill=CURSOR_COLOR + (255,), width=int(cursor_width))

    # Round caps for cursor
    cursor_cap = cursor_width / 2
    draw.ellipse([
        cursor_start[0] - cursor_cap, cursor_start[1] - cursor_cap,
        cursor_start[0] + cursor_cap, cursor_start[1] + cursor_cap
    ], fill=CURSOR_COLOR + (255,))
    draw.ellipse([
        cursor_end[0] - cursor_cap, cursor_end[1] - cursor_cap,
        cursor_end[0] + cursor_cap, cursor_end[1] + cursor_cap
    ], fill=CURSOR_COLOR + (255,))

    # Convert to RGB (Play Store requires no transparency in icon)
    final = Image.new('RGB', (SIZE, SIZE), BG_COLOR)
    final.paste(img, mask=img.split()[3])

    # Save
    output_path = '/mntc/code/connectbot/playstore/icon_512.png'
    final.save(output_path, 'PNG')
    print(f'Icon saved to: {output_path}')

if __name__ == '__main__':
    main()
