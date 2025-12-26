# GitHub Actions Workflow Information

## ✅ Updated for Modern macOS Runners

### Changes Made

**Previous:** `runs-on: macos-13` (deprecated)
**Current:** `runs-on: macos-latest` (Apple Silicon, recommended)

### Dual Build System Support

The workflow now supports **both** build systems:

#### 1. Xcode Project (Preferred) ✅
The Xcode project `LivesportClaude.xcodeproj` is now available:
```bash
xcodebuild test -project LivesportClaude.xcodeproj
```

#### 2. Swift Package Manager (Fallback)
If Xcode is not available:
```bash
swift build
swift test --enable-code-coverage
```

### macOS Runner Versions

| Runner | Architecture | Status | Xcode Version |
|--------|--------------|--------|---------------|
| `macos-latest` | Apple Silicon (M1/M2) | ✅ Active | Latest stable |
| `macos-14` | Apple Silicon | ✅ Active | Xcode 15.x |
| `macos-15` | Apple Silicon | ✅ Active | Xcode 16.x |
| `macos-15-intel` | Intel x86_64 | ⚠️ Last Intel | Xcode 16.x |
| `macos-13` | Intel x86_64 | ❌ Deprecated | Xcode 15.x |

**Migration Timeline:**
- macOS 13 runners: Deprecated Dec 2024
- Last Intel runners: `macos-15-intel` (planned sunset 2025)

### Current Setup

**Runner:** `macos-latest` (Apple Silicon)
**Xcode:** Latest stable (auto-selected)
**Action:** `maxim-lobanov/setup-xcode@v1`

### Workflow Features

✅ **Automatic Detection**
- Checks for `.xcodeproj` presence
- Falls back to Swift Package Manager if needed

✅ **Code Coverage**
- Xcode: Full coverage reports via `xccov`
- SPM: LCOV format coverage

✅ **Platform Support**
- Native Apple Silicon builds
- Faster build times
- Modern toolchain

### Testing Locally

**With Xcode Project (recommended):**
```bash
cd LivesportClaude
./run_tests.sh
```

**With Swift Package Manager (alternative):**
```bash
swift build
swift test
```

### Xcode Project ✅

The Xcode project is now available and committed to the repository:

- **Location:** `LivesportClaude/LivesportClaude.xcodeproj`
- **Bundle ID:** `cz.livesport.LivesportClaude`
- **Deployment Target:** macOS 13.0
- **Scheme:** LivesportClaude (with code coverage enabled)
- **Targets:** App target and test target

See [SETUP.md](../SETUP.md) for detailed instructions.

### Troubleshooting

**Issue:** Workflow fails on GitHub
**Cause:** Build configuration issues
**Solution:** Workflow will automatically fall back to Swift Package Manager if Xcode build fails

**Issue:** Coverage calculation fails
**Cause:** Coverage reporting requires specific Xcode configuration
**Solution:** The Xcode project is configured with code coverage enabled; verify scheme settings

**Issue:** Build timeout
**Cause:** First build on Apple Silicon may take longer
**Solution:** Normal, subsequent builds will be cached

### References

- [GitHub Actions macOS runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners)
- [macOS 13 deprecation notice](https://github.blog/changelog/2024-12-03-github-actions-macos-13-sonoma-is-now-deprecated/)
- [Swift Package Manager](https://swift.org/package-manager/)

---

**Last Updated:** 2024-12-25
**Status:** ✅ Ready for production
