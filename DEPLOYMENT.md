# Deployment Guide

Quick reference for deploying new versions of LivesportClaude.

## Prerequisites

- Access to Google Drive
- GitHub Actions running successfully
- Appcast.xml FILE_ID configured in `UpdateConfiguration.swift`

## Version Release Process

### 1. Prepare Release

Update version in these files:
- `LivesportClaude/LivesportClaude/Info.plist` → `CFBundleShortVersionString`
- `LivesportClaude/LivesportClaude/Models/UpdateConfiguration.swift` → `currentVersion`
- `.github/workflows/ci.yml` → `VERSION` variable (line ~326)

### 2. Commit and Push

```bash
git add .
git commit -m "Release version 1.0.1"
git push origin main  # or claude/** branch
```

### 3. Wait for CI/CD

GitHub Actions will build and create artifacts:
- ✅ Tests pass
- ✅ Build succeeds
- ✅ Packages created

### 4. Download Artifacts

From GitHub Actions run, download:
- `LivesportClaude-dmg` → Contains `LivesportClaude-X.X.X.dmg`
- `appcast` → Contains `appcast.xml`
- `checksums` → Contains SHA256 checksums

### 5. Upload to Google Drive

**New DMG:**
1. Upload `LivesportClaude-X.X.X.dmg` to Google Drive
2. Share → "Anyone with the link can view"
3. Copy FILE_ID from URL

**Update Appcast:**
1. Download current `appcast.xml` from Google Drive
2. Add new `<item>` entry at the top
3. Update DMG URL with new FILE_ID
4. Update version, date, size
5. Upload back to Google Drive (replaces old file)

## Example Appcast Update

```xml
<item>
  <title>Version 1.0.1</title>
  <description><![CDATA[
    <h2>LivesportClaude 1.0.1</h2>
    <h3>New Features</h3>
    <ul>
      <li>Your new feature here</li>
    </ul>
  ]]></description>
  <pubDate>Thu, 26 Dec 2024 14:30:00 +0000</pubDate>
  <sparkle:version>1.0.1</sparkle:version>
  <sparkle:shortVersionString>1.0.1</sparkle:shortVersionString>
  <enclosure
    url="https://drive.google.com/uc?export=download&id=NEW_DMG_FILE_ID"
    length="12345678"
    type="application/octet-stream" />
  <sparkle:minimumSystemVersion>14.0</sparkle:minimumSystemVersion>
</item>
```

## Testing

1. Install previous version
2. Run app
3. `LivesportClaude` menu → `Check for Updates...`
4. Verify update prompt appears
5. Test installation

## Rollback

If update has issues:

1. Download previous working `appcast.xml` backup
2. Upload to Google Drive (replaces current)
3. Users will stop seeing the bad update

## Distribution

Share with employees:
1. Send Google Drive link to latest DMG
2. Instructions: "Drag to Applications folder"
3. Auto-updates will work from there

## Quick Checklist

- [ ] Version numbers updated in code
- [ ] Committed and pushed to main
- [ ] CI/CD passed
- [ ] Downloaded artifacts
- [ ] DMG uploaded to Google Drive
- [ ] Appcast.xml updated
- [ ] Appcast.xml uploaded to Google Drive
- [ ] Tested update flow
- [ ] Notified users (optional)

## Google Drive Links

Store these for reference:

```
Appcast XML: https://drive.google.com/uc?export=download&id=YOUR_APPCAST_FILE_ID
Latest DMG:  https://drive.google.com/uc?export=download&id=LATEST_DMG_FILE_ID
```

## Versioning

Follow semantic versioning:
- `1.0.0` → `1.0.1` (patch: bug fixes)
- `1.0.0` → `1.1.0` (minor: new features)
- `1.0.0` → `2.0.0` (major: breaking changes)

---

For detailed setup, see `AUTOUPDATE_SETUP.md`
