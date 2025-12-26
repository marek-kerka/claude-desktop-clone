# Livesport Claude Desktop

Native macOS application for Livesport employees to interact with Claude AI using Anthropic's API.

## Features

### Core Functionality
- 💬 **Chat with Claude** - Sonnet 4.5 & Opus 4.5 models
- 📝 **Conversation Management** - Multiple chats with persistent history
- 📎 **File Attachments** - Support for images (PNG, JPEG, GIF, WebP)
- 🌓 **Dark/Light Mode** - Automatic theme support

### Advanced Features
- 🔍 **Advanced Search** - Search across all conversations and messages
- 📤 **Export Conversations** - Export to PDF or Markdown format
- 🎯 **Custom System Prompts** - Pre-configured prompts for different use cases:
  - Default Assistant
  - Code Expert (web dev, backend, databases)
  - Data Analyst (sports data, statistics)
  - Product Manager
  - Technical Writer
  - DevOps Engineer
- 🎨 **Code Syntax Highlighting** - Automatic highlighting for:
  - Swift, Python, JavaScript/TypeScript
  - SQL, JSON
  - And more
- 💾 **Local Persistence** - All conversations saved locally

## Tech Stack

- **Platform:** macOS 13.0+
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **API:** Anthropic Claude API

## Project Structure

```
LivesportClaude/
├── LivesportClaude.xcodeproj
├── LivesportClaude/
│   ├── App/
│   │   ├── LivesportClaudeApp.swift
│   │   └── AppConfiguration.swift
│   ├── Models/
│   │   ├── Conversation.swift
│   │   ├── Message.swift
│   │   ├── ClaudeModel.swift
│   │   └── SystemPrompt.swift
│   ├── Services/
│   │   ├── ClaudeAPIClient.swift
│   │   ├── ConversationStorage.swift
│   │   ├── SystemPromptStorage.swift
│   │   ├── SearchService.swift
│   │   └── ExportService.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── ChatView.swift
│   │   ├── ConversationListView.swift
│   │   ├── MessageBubbleView.swift
│   │   ├── CodeBlockView.swift
│   │   ├── SearchView.swift
│   │   ├── SystemPromptsView.swift
│   │   └── SettingsView.swift
│   ├── Resources/
│   │   └── Assets.xcassets
│   └── Info.plist
└── README.md
```

## Setup

1. Open `LivesportClaude.xcodeproj` in Xcode 15+
2. Build and run (⌘R)
3. The API key is currently embedded in the app

For detailed setup instructions, see [SETUP.md](SETUP.md).

## Testing

The project includes comprehensive unit tests with 70%+ code coverage.

**With Xcode (recommended):**
```bash
cd LivesportClaude
./run_tests.sh
```

**With Swift Package Manager (alternative):**
```bash
swift build
swift test --enable-code-coverage
```

See [TESTING.md](TESTING.md) for detailed testing documentation.

### Test Coverage

- ✅ Models: 100% coverage target
- ✅ Services: 80%+ coverage target
- ✅ Automated CI/CD with GitHub Actions (Apple Silicon)
- ✅ Dual build system support (Xcode + SPM)
- ✅ 77 unit tests across 8 test files

## Development

### API Models

- **Claude Opus 4.5:** `claude-opus-4-5-20251101`
- **Claude Sonnet 4.5:** `claude-sonnet-4-5-20250929`

### Building

```bash
xcodebuild -scheme LivesportClaude -configuration Release
```

## Feature Status

### Completed ✅
- [x] Basic chat interface with streaming responses
- [x] Multiple conversations with persistent history
- [x] File attachments (images)
- [x] Advanced conversation search
- [x] Export conversations (PDF & Markdown)
- [x] Custom system prompts with presets
- [x] Code syntax highlighting
- [x] Dark/Light mode support

### Planned 🚧
- [ ] Individual API keys per employee
- [ ] Conversation sharing between employees

## License

Internal use for Livesport employees only.
