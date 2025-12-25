# Testing Guide

Comprehensive testing documentation for Livesport Claude Desktop.

## Overview

The project uses **XCTest** for unit testing with comprehensive coverage of models and services.

### Test Coverage Goals

- **Target:** 70%+ code coverage
- **Current Status:** Check GitHub Actions for latest coverage
- **Coverage Reports:** Available in CI/CD pipeline

## Running Tests

### Option 1: Xcode (Recommended)

1. Open `LivesportClaude.xcodeproj` in Xcode
2. Select `Product > Test` or press `⌘U`
3. View results in Test Navigator (⌘6)

### Option 2: Command Line

```bash
cd LivesportClaude
./run_tests.sh
```

This script will:
- Clean build folder
- Run all tests
- Generate coverage reports
- Display coverage summary
- Verify coverage meets threshold (70%)

### Option 3: xcodebuild

```bash
cd LivesportClaude
xcodebuild test \
  -project LivesportClaude.xcodeproj \
  -scheme LivesportClaude \
  -destination 'platform=macOS' \
  -enableCodeCoverage YES
```

## Test Structure

```
LivesportClaudeTests/
├── Models/
│   ├── ClaudeModelTests.swift
│   ├── MessageTests.swift
│   ├── ConversationTests.swift
│   └── SystemPromptTests.swift
├── Services/
│   ├── ConversationStorageTests.swift
│   ├── SystemPromptStorageTests.swift
│   ├── SearchServiceTests.swift
│   └── ExportServiceTests.swift
└── Info.plist
```

## Test Coverage by Component

### Models (100% coverage target)

#### ClaudeModelTests
- ✅ Model properties (rawValue, displayName, description)
- ✅ Max tokens configuration
- ✅ Codable conformance
- ✅ Identifiable conformance
- ✅ AllCases enumeration

#### MessageTests
- ✅ Message initialization
- ✅ Content blocks (text, image)
- ✅ Text content extraction
- ✅ API message conversion
- ✅ Role handling
- ✅ Codable conformance
- ✅ Equality checks

#### ConversationTests
- ✅ Conversation initialization
- ✅ Add/update messages
- ✅ Auto-generate titles
- ✅ Preview generation
- ✅ Last message time tracking
- ✅ Codable conformance

#### SystemPromptTests
- ✅ Prompt initialization
- ✅ Built-in prompts (6 presets)
- ✅ Default prompt selection
- ✅ Codable conformance
- ✅ Content validation

### Services (80% coverage target)

#### ConversationStorageTests
- ✅ Create conversations
- ✅ Update conversations
- ✅ Delete conversations
- ✅ Sorting by recency
- ✅ Persistence (mocked)

#### SystemPromptStorageTests
- ✅ Load built-in prompts
- ✅ Add/update/delete prompts
- ✅ Select prompt
- ✅ Get selected prompt
- ✅ Persistence (mocked)

#### SearchServiceTests
- ✅ Search by title
- ✅ Search by content
- ✅ Case-insensitive search
- ✅ Empty/whitespace queries
- ✅ Multiple results
- ✅ Context extraction
- ✅ Clear search

#### ExportServiceTests
- ✅ Markdown export
- ✅ Metadata inclusion
- ✅ User/assistant messages
- ✅ Image attachments
- ✅ Filename sanitization
- ✅ Empty conversations

## Coverage Reports

### Viewing Coverage in Xcode

1. Run tests with coverage (`⌘U`)
2. Open Report Navigator (`⌘9`)
3. Select latest test run
4. Click "Coverage" tab
5. Explore file-by-file coverage

### Command Line Coverage

```bash
cd LivesportClaude

# Generate coverage report
xcrun xccov view --report TestResults.xcresult

# JSON format
xcrun xccov view --report --json TestResults.xcresult > coverage.json

# Detailed file coverage
xcrun xccov view --file <path-to-file> TestResults.xcresult
```

## CI/CD Integration

### GitHub Actions

Every push and PR triggers:

1. **Test Job**
   - Runs all unit tests
   - Generates coverage reports
   - Comments coverage on PRs
   - Fails if coverage < 70%

2. **Build Job**
   - Builds release configuration
   - Verifies compilation

3. **Lint Job**
   - Runs SwiftLint
   - Reports code style issues

### Coverage Badges

Add to your README.md:

```markdown
![Tests](https://github.com/livesport/claude-desktop-clone/actions/workflows/ci.yml/badge.svg)
```

### Coverage Threshold

Current threshold: **70%**

To change threshold, edit `.github/workflows/ci.yml`:

```yaml
THRESHOLD=70  # Change this value
```

## Writing Tests

### Test Naming Convention

```swift
func test<ComponentName><Behavior>() {
    // Arrange
    // Act
    // Assert
}
```

Example:
```swift
func testConversationAddMessage() {
    // Arrange
    var conversation = Conversation()
    let message = Message(role: .user, text: "Hello")

    // Act
    conversation.addMessage(message)

    // Assert
    XCTAssertEqual(conversation.messages.count, 1)
}
```

### Test Organization

1. **Setup** - Initialize test data in `setUp()`
2. **Teardown** - Clean up in `tearDown()`
3. **One assertion per test** - Keep tests focused
4. **Use descriptive names** - Test names should explain what they verify

### Best Practices

✅ **DO:**
- Test public interfaces
- Test edge cases (empty, nil, boundary values)
- Use meaningful test data
- Keep tests independent
- Use `XCTAssert` family of assertions

❌ **DON'T:**
- Test private methods directly
- Create test dependencies
- Use real file system (use mocks)
- Make network calls in tests
- Share state between tests

## Mocking

### ConversationStorage Mock

Tests use temporary directories for file operations:

```swift
override func setUp() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    testFileURL = tempDir.appendingPathComponent("test.json")
}
```

### API Mocking

For API tests, we don't test the actual Claude API:
- Mock responses
- Test request formatting
- Verify error handling

## Continuous Integration

### Local Pre-commit Check

```bash
# Run before committing
cd LivesportClaude
./run_tests.sh
```

### GitHub Actions Workflow

Located at `.github/workflows/ci.yml`

**Triggers:**
- Push to `main`, `develop`, `claude/**` branches
- Pull requests to `main`, `develop`

**macOS Version:** macOS 13
**Xcode Version:** 15.0

## Troubleshooting

### Tests Fail to Build

```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clean build folder
xcodebuild clean -project LivesportClaude.xcodeproj
```

### Coverage Not Generated

Ensure code coverage is enabled:
1. Xcode: Edit Scheme → Test → Options → Code Coverage ✓
2. Command line: Use `-enableCodeCoverage YES`

### Tests Timeout

Increase timeout in test:

```swift
func testLongRunning() {
    let expectation = XCTestExpectation()
    expectation.expectedFulfillmentCount = 1

    // ... async work ...

    wait(for: [expectation], timeout: 10.0) // Increase timeout
}
```

## Coverage Metrics

### What We Measure

- **Line Coverage**: % of lines executed
- **Function Coverage**: % of functions called
- **Branch Coverage**: % of conditional branches taken

### Excluded from Coverage

- UI Views (tested manually)
- App delegate
- Third-party code
- Generated code

## Future Improvements

- [ ] UI Tests with XCUITest
- [ ] Performance tests
- [ ] Integration tests with mock API
- [ ] Snapshot tests for views
- [ ] Mutation testing

## Resources

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Code Coverage in Xcode](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/07-code_coverage.html)
- [Swift Testing Best Practices](https://www.swift.org/documentation/testing/)

---

**Last Updated:** 2024-12-25
**Maintainer:** Livesport Development Team
