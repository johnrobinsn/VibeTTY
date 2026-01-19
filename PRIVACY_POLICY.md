# VibeTTY Privacy Policy

**Last Updated:** January 19, 2025

## Overview

VibeTTY is an open-source SSH client for Android. We are committed to protecting your privacy. This policy explains what data VibeTTY collects, how it's used, and your rights.

## Data Collection

**VibeTTY does NOT collect, transmit, or share any personal data.**

All data you enter into VibeTTY (server addresses, usernames, SSH keys, port forwarding configurations) is stored **locally on your device only**. We have no servers, no analytics, and no tracking.

## Data Stored Locally

VibeTTY stores the following data on your device:

- **Host configurations**: Server addresses, ports, usernames, and connection preferences
- **SSH keys**: Public/private key pairs you generate or import for authentication
- **Known hosts**: Server fingerprints for security verification
- **Port forwarding rules**: Your SSH tunnel configurations
- **Profiles**: Saved terminal appearance and behavior preferences
- **App settings**: Your preferences for keyboard behavior, colors, fonts, etc.

This data never leaves your device except:
1. When you explicitly connect to an SSH server (connection data sent to that server)
2. If you enable Android Backup (see below)

## Android Backup (Optional)

If you enable Android Backup in your device settings, VibeTTY data may be included in your device backup to Google Drive. This is controlled by your Android system settings, not by VibeTTY.

- SSH private keys are **excluded** from backup by default for security
- You can control backup behavior in Android Settings → System → Backup

## Network Connections

VibeTTY only makes network connections when you explicitly initiate them:

- **SSH connections**: To servers you configure
- **Telnet connections**: To servers you configure
- **ADB discovery**: Local network scanning (when you use the ADB port discovery feature)

VibeTTY does not connect to any Anthropic, VibeTTY, or third-party servers.

## Third-Party Services

**Google Play flavor only**: The Google Play version of VibeTTY uses Google Play Services to:
- Update the device's cryptographic security provider
- Download fonts (if you use downloadable fonts)

This is standard Android functionality and is subject to [Google's Privacy Policy](https://policies.google.com/privacy).

**OSS flavor**: The open-source (F-Droid) version uses no Google services.

## Permissions

VibeTTY requests the following Android permissions:

- **Internet**: Required to establish SSH/Telnet connections
- **Vibrate**: For haptic feedback on key presses (optional)
- **Wake Lock**: To keep connections alive while the screen is off
- **Foreground Service**: To maintain connections in the background
- **Post Notifications**: To show connection status notifications

## Data Security

- SSH private keys are stored in Android's secure storage
- You can protect keys with biometric authentication or device credentials
- Connections use industry-standard SSH encryption

## Children's Privacy

VibeTTY is not designed for or directed at children under 13. We do not knowingly collect any information from children.

## Changes to This Policy

We may update this privacy policy from time to time. Changes will be posted to the VibeTTY GitHub repository and noted with an updated "Last Updated" date.

## Disclaimer

VibeTTY is provided as open-source software under the Apache 2.0 License. While we strive to implement and maintain the practices described in this policy, this software is provided "as is" without warranty of any kind.

As with any software, bugs, defects, or unforeseen interactions with your device or other applications may occur that could affect the behavior described in this policy. We make reasonable efforts to identify and address such issues, but cannot guarantee that all aspects of this policy will be perfectly upheld at all times.

By using VibeTTY, you acknowledge that:
- The developers are not liable for any unintended data exposure resulting from software defects
- You are responsible for maintaining the security of your device and credentials
- You should keep the app updated to receive security fixes

If you discover any behavior that contradicts this policy, please report it as a security issue on our GitHub repository so we can address it promptly.

## Open Source

VibeTTY is open-source software. You can review the complete source code at:
https://github.com/johnrobinsn/VibeTTY

## Contact

For privacy questions or concerns, please open an issue on our GitHub repository:
https://github.com/johnrobinsn/VibeTTY/issues

Or contact: [Add your contact email here]

---

*VibeTTY is based on ConnectBot, originally developed by Kenny Root and Jeffrey Sharkey. This privacy policy applies to VibeTTY specifically.*
