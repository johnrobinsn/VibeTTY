# VibeTTY Play Store Launch Guide

## What's Already Done
- [x] applicationId changed to `com.vibetty.app`
- [x] Privacy policy created (`PRIVACY_POLICY.md`)
- [x] 512x512 app icon (`playstore/icon_512.png`)
- [x] 1024x500 feature graphic (`playstore/feature_graphic.png`)
- [x] Store listing text (`playstore/store_listing.md`)

## Remaining Steps

### 1. Generate Signing Keystore

Create an upload keystore for signing releases:

```bash
keytool -genkey -v -keystore vibetty-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vibetty
```

You'll be prompted for:
- Keystore password
- Your name, organization, location
- Key password (can be same as keystore password)

**Important:** Store this keystore file securely. If lost, you cannot update your app.

### 2. Configure Gradle Signing

Create `~/.gradle/gradle.properties` (NOT in the repo):

```properties
keystoreFile=/path/to/vibetty-upload.jks
keystorePassword=<your-password>
keystoreAlias=vibetty
```

### 3. Build Release AAB

```bash
./gradlew bundleGoogleRelease
```

Output: `app/build/outputs/bundle/googleRelease/app-google-release.aab`

### 4. Create Git Tag for Release

```bash
git tag -a v1.10.0 -m "First VibeTTY Play Store release"
git push fork v1.10.0
```

The app-versioning plugin will automatically generate version code/name from this tag.

### 5. Capture Screenshots

Capture 4-8 screenshots on phone or emulator showing:
1. Host list screen
2. Terminal session
3. Settings screen
4. Port forward list
5. ADB discovery dialog
6. Keyboard panel / VibeBar
7. Font picker
8. Profile editor

### 6. Create Play Console Developer Account

1. Go to https://play.google.com/console
2. Pay $25 one-time registration fee
3. Complete identity verification

### 7. Create App in Play Console

1. Click "Create app"
2. App name: **VibeTTY**
3. Default language: English (US)
4. App type: Application
5. Free or paid: Free
6. Accept declarations

### 8. Complete Store Listing

Upload:
- App icon (512x512)
- Feature graphic (1024x500)
- Screenshots (minimum 2)

Enter:
- Short description (from `playstore/store_listing.md`)
- Full description (from `playstore/store_listing.md`)
- Category: Tools
- Contact email

### 9. Set Up App Signing

Play Console → Setup → App signing

Choose "Let Google manage and protect your app signing key (recommended)"

Upload your AAB - Google will handle the rest.

### 10. Add Privacy Policy

Play Console → Policy → App content → Privacy policy

Enter URL: `https://github.com/johnrobinsn/VibeTTY/blob/main/PRIVACY_POLICY.md`

Or host via GitHub Pages for a cleaner URL.

### 11. Complete Content Rating

Play Console → Policy → App content → Content rating

Answer the questionnaire:
- Category: Utility / Productivity
- No violence, gambling, or mature content
- Interactive elements: Users interact (SSH to servers)
- Data sharing: None

### 12. Testing Tracks

**Internal Testing (Start Here)**
- Up to 100 testers
- Instant availability after upload
- Good for initial validation

**Open Testing (Before Production)**
- Anyone can join via link
- Helps catch issues at scale

### 13. Production Release

1. Promote from testing track to production
2. Consider staged rollout (10% → 25% → 50% → 100%)
3. Monitor Play Console for crashes/ANRs
4. Respond to user reviews

## Verification Checklist

Before submitting:
- [ ] Release build installs and runs correctly
- [ ] All features work as expected
- [ ] Privacy policy URL is accessible
- [ ] Screenshots are clear and representative
- [ ] Descriptions are accurate and compelling
- [ ] Content rating is complete
- [ ] All required declarations are filled

## Regenerating Graphics

If you need to regenerate the Play Store graphics:

```bash
python3 playstore/generate_icon.py
python3 playstore/generate_feature_graphic.py
```
