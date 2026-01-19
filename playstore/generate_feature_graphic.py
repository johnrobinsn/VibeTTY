#!/usr/bin/env python3
"""
Generate 1024x500 Play Store feature graphic for VibeTTY.
Shows app name and terminal aesthetic.
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Feature graphic dimensions
WIDTH = 1024
HEIGHT = 500

# Colors
BG_COLOR = (25, 28, 27)       # #191C1B - Dark teal-tinted background
CHEVRON_COLOR = (0, 137, 123) # #00897B - Teal 600
CURSOR_COLOR = (100, 255, 218) # #64FFDA - Bright mint
TEXT_COLOR = (200, 230, 225)   # Light teal-tinted white
SUBTEXT_COLOR = (120, 140, 135) # Muted teal-gray

def main():
    img = Image.new('RGB', (WIDTH, HEIGHT), BG_COLOR)
    draw = ImageDraw.Draw(img)

    # Try to load a monospace font, fallback to default
    font_paths = [
        '/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf',
        '/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf',
        '/usr/share/fonts/truetype/ubuntu/UbuntuMono-Bold.ttf',
        '/usr/share/fonts/TTF/DejaVuSansMono-Bold.ttf',
    ]

    title_font = None
    sub_font = None
    prompt_font = None

    for path in font_paths:
        if os.path.exists(path):
            try:
                title_font = ImageFont.truetype(path, 80)
                sub_font = ImageFont.truetype(path, 28)
                prompt_font = ImageFont.truetype(path, 120)
                break
            except:
                continue

    if title_font is None:
        title_font = ImageFont.load_default()
        sub_font = ImageFont.load_default()
        prompt_font = ImageFont.load_default()

    # Draw the >_ prompt on the left side
    prompt_x = 80
    prompt_y = HEIGHT // 2 - 40

    # Chevron
    chevron_points = [
        (prompt_x, prompt_y - 40),
        (prompt_x + 60, prompt_y + 10),
        (prompt_x, prompt_y + 60),
    ]
    draw.line([chevron_points[0], chevron_points[1]],
              fill=CHEVRON_COLOR, width=18)
    draw.line([chevron_points[1], chevron_points[2]],
              fill=CHEVRON_COLOR, width=18)
    # Round caps
    for point in chevron_points:
        draw.ellipse([point[0]-9, point[1]-9, point[0]+9, point[1]+9],
                     fill=CHEVRON_COLOR)

    # Cursor underscore
    cursor_x = prompt_x + 90
    cursor_y = prompt_y + 50
    cursor_width = 60
    draw.line([(cursor_x, cursor_y), (cursor_x + cursor_width, cursor_y)],
              fill=CURSOR_COLOR, width=14)
    draw.ellipse([cursor_x-7, cursor_y-7, cursor_x+7, cursor_y+7],
                 fill=CURSOR_COLOR)
    draw.ellipse([cursor_x+cursor_width-7, cursor_y-7, cursor_x+cursor_width+7, cursor_y+7],
                 fill=CURSOR_COLOR)

    # Draw glow behind cursor
    glow_img = Image.new('RGBA', (WIDTH, HEIGHT), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_img)
    glow_draw.line([(cursor_x, cursor_y), (cursor_x + cursor_width, cursor_y)],
                   fill=CURSOR_COLOR + (40,), width=30)

    # App name - "VibeTTY"
    title_x = 280
    title_y = HEIGHT // 2 - 60

    # Draw title with slight shadow for depth
    draw.text((title_x + 2, title_y + 2), "VibeTTY", font=title_font, fill=(10, 12, 11))
    draw.text((title_x, title_y), "VibeTTY", font=title_font, fill=TEXT_COLOR)

    # Tagline
    tagline = "SSH client for vibe coding"
    tagline_y = title_y + 100
    draw.text((title_x, tagline_y), tagline, font=sub_font, fill=SUBTEXT_COLOR)

    # Add some terminal-style decorative elements on the right
    # Simulated terminal lines
    line_x = 700
    line_y = 140
    line_spacing = 40
    line_colors = [SUBTEXT_COLOR, (80, 100, 95), (60, 80, 75)]

    for i, color in enumerate(line_colors):
        y = line_y + i * line_spacing
        # Varying line lengths for visual interest
        lengths = [200, 150, 180]
        draw.line([(line_x, y), (line_x + lengths[i], y)],
                  fill=color, width=3)

    # Bottom decorative lines
    line_y = 320
    for i, color in enumerate(line_colors):
        y = line_y + i * line_spacing
        lengths = [160, 220, 140]
        draw.line([(line_x, y), (line_x + lengths[i], y)],
                  fill=color, width=3)

    # Save
    output_path = '/mntc/code/connectbot/playstore/feature_graphic.png'
    img.save(output_path, 'PNG')
    print(f'Feature graphic saved to: {output_path}')

if __name__ == '__main__':
    main()
