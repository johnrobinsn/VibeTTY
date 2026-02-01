# VibeTTY

VibeTTY is an experimental fork of [ConnectBot](https://github.com/connectbot/connectbot), a powerful open-source SSH client for Android.

## About This Fork

VibeTTY builds upon ConnectBot's excellent foundation, adding enhancements focused on modern terminal workflows and "vibe coding" - AI-assisted development where you need a capable terminal experience on mobile devices.

### Key Features

- **Kitty Keyboard Protocol**: Full support for the [Kitty keyboard protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/) enabling Shift+Enter, Ctrl+Enter, and other modifier combinations in modern CLI tools like Claude Code
- **Virtual Terminal Width** *(experimental)*: Render the terminal wider than the physical screen (e.g., 100+ columns on a narrow phone) with single-finger horizontal panning
- **ADB Port Discovery**: Automatically find your device's wireless debugging port and generate `adb connect` commands
- **Font Picker with Live Preview**: Browse fonts with each name rendered in that font, plus editable sample text
- **VibeBar** *(experimental)*: Alternate keyboard panel with programming symbols, arrow keys, and modifiers
- **Backtick Sends Escape** *(experimental)*: Optional remapping for vim users on hardware keyboards
- **Keyboard Navigation**: Press Escape to go back from any screen
- **Improved Keyboard Handling**: Better detection of connected vs. paired Bluetooth keyboards
- **Force Software Keyboard Option** *(experimental)*: Show soft keyboard even when hardware keyboard is detected
- **Toggle Keyboard/Title Bar**: Tap the terminal to toggle UI visibility
- **Per-orientation Font Sizes**: Remember different font sizes for portrait and landscape
- **Google Voice Keyboard Support**: Dictate commands hands-free using Google's voice input

*Features marked (experimental) are disabled by default. Enable them in Settings.*

See [NEW_FEATURES.md](NEW_FEATURES.md) for implementation details, [FAQ.md](FAQ.md) for common questions, and [docs/](docs/) for technical documentation.

## Installation

### GitHub Releases (Recommended)
Download the latest APK from [GitHub Releases](https://github.com/johnrobinsn/VibeTTY/releases).

To install:
1. Download the APK to your Android device
2. Enable "Install from unknown sources" if prompted
3. Open the APK to install

### Google Play Store
*Coming soon*

## Why VibeTTY?

Traditional terminal emulators on Android were designed for basic SSH access. VibeTTY is optimized for:

- **AI-assisted coding sessions** - Full keyboard protocol support means tools like Claude Code work properly with multi-line input (Shift+Enter creates newlines, Enter submits)
- **Wide terminal content** - Many CLI tools assume 80+ columns; virtual width lets you view them properly on narrow screens
- **Modern TUI applications** - Improved scroll/pan handling for apps that produce continuous output

## Recommended Keyboard

For the best terminal experience, we recommend pairing VibeTTY with [Unexpected Keyboard](https://github.com/Julow/Unexpected-Keyboard) - a lightweight virtual keyboard originally designed for programmers using Termux.

**Why Unexpected Keyboard?**
- **Corner-swipe gestures**: Access additional characters by swiping keys toward corners, perfect for programming symbols
- **Privacy-focused**: No ads, no network requests, fully open-source
- **Compact yet powerful**: Type special characters without cluttering the screen or switching layouts

Available on [F-Droid](https://f-droid.org/packages/juloo.keyboard2/) and [Google Play](https://play.google.com/store/apps/details?id=juloo.keyboard2).

## Credits

VibeTTY is built on top of **ConnectBot**, created by Kenny Root and the ConnectBot contributors. We are grateful for their years of work creating such a solid SSH client foundation.

- **Original Project**: [ConnectBot](https://github.com/connectbot/connectbot)
- **License**: Apache License 2.0

## Building

```sh
# Build the app
./gradlew build

# Build debug APK
./gradlew assembleGoogleDebug
```

### Product Flavors

- **google**: Uses Google Play Services for crypto provider updates
- **oss**: Uses bundled Conscrypt library, fully open-source

## Documentation

- [NEW_FEATURES.md](NEW_FEATURES.md) - Feature details and implementation notes
- [docs/KITTY_KEYBOARD_PROTOCOL.md](docs/KITTY_KEYBOARD_PROTOCOL.md) - Kitty keyboard protocol technical documentation

## License & Disclaimer

VibeTTY is licensed under the Apache License 2.0. This software is provided "as is" without warranty of any kind. While we strive to maintain security and reliability, bugs may occur. See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for details on data handling and our full disclaimer.

## Original ConnectBot

For the original ConnectBot app:
- [Google Play Store](https://play.google.com/store/apps/details?id=org.connectbot)
- [GitHub Releases](https://github.com/connectbot/connectbot/releases)
