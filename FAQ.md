# VibeTTY FAQ

## Background Connections & Port Forwarding

### Why do my connections drop when VibeTTY goes to the background?

Android kills background apps to save battery. To keep connections alive:

1. **Enable "Persist connections"** in VibeTTY Settings
2. **Grant notification permission** when prompted (required on Android 13+)
3. **Disable battery optimization** for VibeTTY in Android Settings → Apps → VibeTTY → Battery → "Unrestricted"

When working correctly, you'll see a "VibeTTY is running" notification while connections are active in the background.

### What is a Wake Lock?

A wake lock prevents the Android device from entering deep sleep. There are different types:

| Type | What it does | Battery impact |
|------|--------------|----------------|
| **Partial Wake Lock** | Keeps CPU running even with screen off | Medium |
| **WiFi Lock** | Keeps WiFi radio active | Low-Medium |
| **Foreground Service** | Tells Android not to kill the app | Low |

VibeTTY uses a **foreground service** and **WiFi lock** to maintain connections. This should be sufficient for most use cases.

**Further reading:**
- [Android Wake Locks Guide](https://developer.android.com/develop/background-work/background-tasks/scheduling/wakelock)
- [Keep the CPU On](https://developer.android.com/training/scheduling/wakelock)

### What is a Foreground Service?

A foreground service is an Android service that shows a persistent notification. This tells the system the app is doing important work the user is aware of, so Android won't kill it to reclaim resources.

**Further reading:**
- [Foreground Services Overview](https://developer.android.com/develop/background-work/services/foreground-services)

## Port Forwarding

### What's the difference between Local and Remote port forwarding?

| Type | Direction | Use case |
|------|-----------|----------|
| **Local** | Your device → Remote server | Access a service on the remote network from your device |
| **Remote** | Remote server → Your device | Allow the remote server to access a service on your device |
| **Dynamic** | SOCKS proxy | Route any traffic through the SSH tunnel |

**Example - Local:** Forward local port 3306 to access MySQL on a remote server
```
Local port 3306 → remote-db-server:3306
```

**Example - Remote:** Let your computer connect to ADB on your phone via SSH
```
Remote port 5550 → localhost:37123 (phone's ADB port)
```

**Further reading:**
- [SSH Port Forwarding Explained](https://www.ssh.com/academy/ssh/tunneling-example)

## ADB & Wireless Debugging

### How do I find my wireless ADB port?

Use the **+ADB** button in the Port Forwards screen. It scans localhost ports 30000-44000 to find the active ADB debugging port and displays the `adb connect` command.

### Why does the ADB port change?

Android's wireless debugging uses dynamic ports for security. The port changes when:
- You toggle wireless debugging off/on
- The device restarts
- Sometimes after extended periods

## Keyboard & Input

### How do I send Escape key on a hardware keyboard?

Enable **"Backtick sends Escape"** in Settings → Keyboard. Then:
- Short press backtick (`) → sends Escape
- Long press backtick → sends backtick character
- Shift+backtick → sends tilde (~)

### Why doesn't my Bluetooth keyboard show the soft keyboard?

VibeTTY hides the soft keyboard when a hardware keyboard is detected. To override this:
- Enable **"Force software keyboard"** in Settings → Keyboard
