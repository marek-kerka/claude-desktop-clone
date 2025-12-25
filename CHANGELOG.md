# Changelog

All notable changes to Livesport Claude Desktop will be documented in this file.

## [1.1.0] - 2024-12-25

### Added

#### 🔍 Advanced Search
- Full-text search across all conversations and messages
- Real-time search results with context preview
- Quick navigation to specific conversations from search results
- Search in conversation titles and message content

#### 📤 Export Functionality
- **PDF Export**: Export conversations to professionally formatted PDF documents
  - Includes conversation metadata (title, model, timestamps)
  - Formatted message bubbles with role indicators
  - Pagination support for long conversations
- **Markdown Export**: Export to markdown format
  - Clean, readable format
  - Preserves message structure and timestamps
  - Perfect for documentation and archiving

#### 🎯 Custom System Prompts
- Manage multiple system prompts for different use cases
- **6 Built-in Presets:**
  1. **Default Assistant** - General-purpose AI assistant
  2. **Code Expert** - Specialized for software development
     - Web development (React, TypeScript, Node.js)
     - Backend systems (Python, Java, microservices)
     - Database optimization
  3. **Data Analyst** - Sports data and statistics expert
     - Statistical analysis
     - SQL optimization
     - Python data tools (pandas, numpy)
  4. **Product Manager** - Product strategy and planning
     - User stories and requirements
     - Feature prioritization
     - Market analysis
  5. **Technical Writer** - Documentation specialist
     - API documentation
     - User guides
     - Architecture explanations
  6. **DevOps Engineer** - Infrastructure and deployment
     - CI/CD pipelines
     - Cloud platforms (AWS, GCP, Azure)
     - Kubernetes and Docker
- Create, edit, and manage custom prompts
- Select active prompt for all new conversations
- Prompt templates saved locally

#### 🎨 Code Syntax Highlighting
- Automatic detection of code blocks in responses
- **Language Support:**
  - Swift (keywords, strings, comments)
  - Python (with # comment support)
  - JavaScript/TypeScript
  - SQL (with -- comment support)
  - JSON
- Copy-to-clipboard functionality for code blocks
- Syntax-aware formatting with monospace font
- Language indicator badges on code blocks

### Improved

#### UI/UX Enhancements
- **Tabbed Settings Interface**
  - General settings tab
  - System Prompts management tab
  - About tab with app information
- **Enhanced Chat Header**
  - Export menu with quick access
  - Editable conversation titles (auto-saved)
  - Model indicator
- **Search Integration**
  - Dedicated search button in toolbar
  - Full-screen search modal
  - Empty states for better UX
- **Message Display**
  - Code blocks with syntax highlighting in assistant messages
  - Better text selection and copying
  - Improved visual hierarchy

#### Code Architecture
- **New Services:**
  - `ExportService`: Handles PDF and Markdown generation
  - `SearchService`: Manages conversation search
  - `SystemPromptStorage`: Persistent prompt management
- **New Models:**
  - `SystemPrompt`: Represents custom prompts
  - `SearchResult`: Search result data structure
- **New Views:**
  - `CodeBlockView`: Code display with highlighting
  - `SearchView`: Search interface
  - `SystemPromptsView`: Prompt management UI
  - `AboutView`: App information

### Technical Details

#### File Structure Changes
```
New files:
- Models/SystemPrompt.swift
- Services/ExportService.swift
- Services/SearchService.swift
- Services/SystemPromptStorage.swift
- Views/CodeBlockView.swift
- Views/SearchView.swift
- Views/SystemPromptsView.swift

Modified files:
- Views/ContentView.swift (added search, prompt storage)
- Views/ChatView.swift (integrated system prompts, export)
- Views/MessageBubbleView.swift (code highlighting)
- Views/SettingsView.swift (tabbed interface)
- README.md (updated features)
- SETUP.md (added advanced features guide)
```

#### Dependencies
- PDFKit (for PDF export)
- AppKit (for file dialogs and pasteboard)
- SwiftUI (enhanced views)

### Data Storage

All new features use local storage:
- **System Prompts**: `~/Library/Application Support/LivesportClaude/system_prompts.json`
- **Conversations**: `~/Library/Application Support/LivesportClaude/conversations.json`

No cloud sync or external dependencies.

---

## [1.0.0] - 2024-12-25

### Initial Release

#### Core Features
- Native macOS app built with SwiftUI
- Chat with Claude AI (Sonnet 4.5 & Opus 4.5)
- Multiple conversation management
- File attachments (images: PNG, JPEG, GIF, WebP)
- Streaming responses from Claude API
- Dark/Light mode support
- Local conversation persistence
- Conversation history
- Settings panel

#### Architecture
- Clean MVVM architecture
- Separate services for API and storage
- Reactive UI with SwiftUI
- Type-safe models

---

## Future Roadmap

### Planned Features
- [ ] Individual API keys per employee
- [ ] Conversation sharing between team members
- [ ] Advanced filtering and sorting
- [ ] Conversation tags and categories
- [ ] Voice input support
- [ ] Multi-language support
