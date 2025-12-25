# Livesport Claude Desktop

Native macOS application for Livesport employees to interact with Claude AI using Anthropic's API.

## Features

- 💬 Chat with Claude (Sonnet 4.5 & Opus 4.5)
- 📝 Conversation management (multiple chats, history)
- 📎 File attachments support
- 🌓 Dark/Light mode
- 💾 Local conversation persistence

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
│   │   └── ClaudeModel.swift
│   ├── Services/
│   │   ├── ClaudeAPIClient.swift
│   │   └── ConversationStorage.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── ChatView.swift
│   │   ├── ConversationListView.swift
│   │   ├── MessageBubbleView.swift
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

## Development

### API Models

- **Claude Opus 4.5:** `claude-opus-4-5-20251101`
- **Claude Sonnet 4.5:** `claude-sonnet-4-5-20250929`

### Building

```bash
xcodebuild -scheme LivesportClaude -configuration Release
```

## Roadmap

- [x] Basic chat interface
- [x] Multiple conversations
- [x] File attachments
- [ ] Individual API keys per employee
- [ ] Advanced conversation search
- [ ] Export conversations
- [ ] Custom system prompts

## License

Internal use for Livesport employees only.
