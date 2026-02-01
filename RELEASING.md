# Releasing VibeTTY

This document describes how to create a new release of VibeTTY.

## Prerequisites

- `keystore.properties` file with signing credentials (not committed to git)
- Android SDK with build tools installed
- Git access to push tags

## Release Workflow

### 1. Ensure code is ready

```bash
# Make sure you're on main and up to date
git checkout main
git pull origin main

# Run tests
./gradlew test
```

### 2. Build signed APK

```bash
./gradlew assembleGoogleRelease

# APK location:
# app/build/outputs/apk/google/release/app-google-release.apk
```

### 3. Verify the APK

```bash
# Check it's signed
$ANDROID_HOME/build-tools/*/apksigner verify --print-certs \
  app/build/outputs/apk/google/release/app-google-release.apk

# Optionally install and test
adb install app/build/outputs/apk/google/release/app-google-release.apk
```

### 4. Tag the release

```bash
# Format: vMAJOR.MINOR.PATCH
git tag -a v1.11.0 -m "VibeTTY v1.11.0 - Description of release"
git push origin v1.11.0
```

### 5. Create GitHub Release

1. Go to: https://github.com/johnrobinsn/VibeTTY/releases/new
2. **Choose a tag**: Select your tag (e.g., `v1.11.0`)
3. **Release title**: `VibeTTY v1.11.0`
4. **Description**: Write release notes (see template below)
5. **Attach files**: Upload the APK (rename to `VibeTTY-v1.11.0.apk` for clarity)
6. **Pre-release**: Leave unchecked for stable releases
7. Click **Publish release**

### Release Notes Template

```markdown
## What's New
- Feature 1
- Feature 2
- Bug fix 1

## Installation
1. Download `VibeTTY-vX.Y.Z.apk` below
2. Enable "Install from unknown sources" if prompted
3. Install the APK

## Requirements
- Android 5.0 (API 21) or higher
```

## Version Numbering

The app uses semantic versioning via git tags:
- Format: `vMAJOR.MINOR.PATCH` (e.g., `v1.11.0`)
- Version code is auto-generated: `major*10000000 + minor*100000 + patch*1000`
- Dev builds show: `git-v1.11.0-5-gabcdef` (5 commits since tag)

## Product Flavors

- **google**: Uses Google Play Services for crypto provider updates (recommended)
- **oss**: Uses bundled Conscrypt library, fully open-source, larger APK

For GitHub releases, use the `google` flavor: `assembleGoogleRelease`
