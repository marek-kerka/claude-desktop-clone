# GitHub Actions Workflows

This directory contains CI/CD workflows for Livesport Claude Desktop.

## Workflows

### `ci.yml` - Continuous Integration

**Triggers:**
- Push to `main`, `develop`, `claude/**` branches
- Pull requests to `main`, `develop`

**Jobs:**

1. **Test** (macOS 13, Xcode 15)
   - Runs all unit tests
   - Generates code coverage reports
   - Comments coverage on PRs
   - Fails if coverage < 70%
   - Uploads coverage artifacts

2. **Build** (macOS 13, Xcode 15)
   - Builds release configuration
   - Verifies no compilation errors
   - Runs after tests pass

3. **Lint** (macOS 13)
   - Runs SwiftLint
   - Reports code style violations

**Coverage Threshold:** 70%

## Adding Badges to README

Add these badges to your main README.md:

```markdown
![CI](https://github.com/YOUR_ORG/claude-desktop-clone/actions/workflows/ci.yml/badge.svg)
![Coverage](https://img.shields.io/badge/coverage-70%25-green)
![Platform](https://img.shields.io/badge/platform-macOS%2013.0+-blue)
![Swift](https://img.shields.io/badge/swift-5.9-orange)
```

## Local Testing

Before pushing, run tests locally:

```bash
cd LivesportClaude
./run_tests.sh
```

## Secrets

No secrets required - the app uses embedded API key for now.

Future: Add `ANTHROPIC_API_KEY` to GitHub Secrets when implementing individual keys.
