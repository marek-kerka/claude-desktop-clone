//
//  CodeBlockView.swift
//  LivesportClaude
//

import SwiftUI
import AppKit

struct CodeBlock: Identifiable {
    let id = UUID()
    let language: String
    let code: String
}

struct MessageContentView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(parseContent(text)) { element in
                switch element {
                case .text(let content):
                    Text(content)
                        .textSelection(.enabled)

                case .code(let codeBlock):
                    CodeBlockView(codeBlock: codeBlock)
                }
            }
        }
    }

    private func parseContent(_ text: String) -> [ContentElement] {
        var elements: [ContentElement] = []
        var currentText = ""
        var isInCodeBlock = false
        var currentLanguage = ""
        var currentCode = ""

        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            // Check for code block start
            if line.hasPrefix("```") {
                if isInCodeBlock {
                    // End of code block
                    if !currentCode.isEmpty {
                        let trimmedCode = currentCode.trimmingCharacters(in: .newlines)
                        elements.append(.code(CodeBlock(language: currentLanguage, code: trimmedCode)))
                    }
                    currentCode = ""
                    currentLanguage = ""
                    isInCodeBlock = false
                } else {
                    // Start of code block
                    if !currentText.isEmpty {
                        elements.append(.text(currentText))
                        currentText = ""
                    }
                    currentLanguage = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                    isInCodeBlock = true
                }
            } else {
                if isInCodeBlock {
                    currentCode += line + "\n"
                } else {
                    currentText += line + "\n"
                }
            }
        }

        // Add remaining text
        if !currentText.isEmpty {
            elements.append(.text(currentText.trimmingCharacters(in: .newlines)))
        }

        // Handle unclosed code block
        if isInCodeBlock && !currentCode.isEmpty {
            let trimmedCode = currentCode.trimmingCharacters(in: .newlines)
            elements.append(.code(CodeBlock(language: currentLanguage, code: trimmedCode)))
        }

        return elements
    }

    enum ContentElement: Identifiable {
        case text(String)
        case code(CodeBlock)

        var id: String {
            switch self {
            case .text(let content):
                return "text_\(content.prefix(50))"
            case .code(let block):
                return "code_\(block.id)"
            }
        }
    }
}

struct CodeBlockView: View {
    let codeBlock: CodeBlock
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with language and copy button
            HStack {
                Text(codeBlock.language.isEmpty ? "code" : codeBlock.language)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.lowercase)

                Spacer()

                Button(action: copyCode) {
                    HStack(spacing: 4) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        Text(copied ? "Copied!" : "Copy")
                    }
                    .font(.caption)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))

            Divider()

            // Code content
            ScrollView(.horizontal, showsIndicators: true) {
                SyntaxHighlightedText(code: codeBlock.code, language: codeBlock.language)
                    .textSelection(.enabled)
                    .padding(12)
            }
            .background(Color(nsColor: .textBackgroundColor))
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
        )
    }

    private func copyCode() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(codeBlock.code, forType: .string)
        copied = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }
}

struct SyntaxHighlightedText: View {
    let code: String
    let language: String

    var body: some View {
        Text(highlightedCode())
            .font(.system(.body, design: .monospaced))
    }

    private func highlightedCode() -> AttributedString {
        var attributedString = AttributedString(code)

        // Basic syntax highlighting for common languages
        switch language.lowercased() {
        case "swift":
            highlightSwift(&attributedString)
        case "python", "py":
            highlightPython(&attributedString)
        case "javascript", "js", "typescript", "ts":
            highlightJavaScript(&attributedString)
        case "json":
            highlightJSON(&attributedString)
        case "sql":
            highlightSQL(&attributedString)
        default:
            // No specific highlighting, use default monospace
            break
        }

        return attributedString
    }

    private func highlightSwift(_ text: inout AttributedString) {
        let keywords = ["func", "let", "var", "class", "struct", "enum", "protocol", "extension",
                       "import", "if", "else", "guard", "for", "while", "return", "throw", "try",
                       "catch", "switch", "case", "break", "continue", "init", "self", "super",
                       "private", "public", "internal", "fileprivate", "static", "final", "override"]

        highlightKeywords(in: &text, keywords: keywords, color: .purple)
        highlightStrings(in: &text, color: .red)
        highlightComments(in: &text, color: .green)
    }

    private func highlightPython(_ text: inout AttributedString) {
        let keywords = ["def", "class", "if", "elif", "else", "for", "while", "return", "import",
                       "from", "try", "except", "finally", "with", "as", "lambda", "yield",
                       "True", "False", "None", "and", "or", "not", "in", "is"]

        highlightKeywords(in: &text, keywords: keywords, color: .purple)
        highlightStrings(in: &text, color: .red)
        highlightComments(in: &text, color: .green, commentPrefix: "#")
    }

    private func highlightJavaScript(_ text: inout AttributedString) {
        let keywords = ["function", "const", "let", "var", "class", "if", "else", "for", "while",
                       "return", "import", "export", "default", "async", "await", "try", "catch",
                       "throw", "new", "this", "typeof", "instanceof", "extends", "super"]

        highlightKeywords(in: &text, keywords: keywords, color: .purple)
        highlightStrings(in: &text, color: .red)
        highlightComments(in: &text, color: .green)
    }

    private func highlightJSON(_ text: inout AttributedString) {
        highlightStrings(in: &text, color: .red)
        // Highlight keys (strings followed by :)
        if let range = text.range(of: "\"[^\"]+\"(?=\\s*:)", options: .regularExpression) {
            text[range].foregroundColor = .blue
        }
    }

    private func highlightSQL(_ text: inout AttributedString) {
        let keywords = ["SELECT", "FROM", "WHERE", "INSERT", "UPDATE", "DELETE", "JOIN", "LEFT",
                       "RIGHT", "INNER", "OUTER", "ON", "AND", "OR", "ORDER", "BY", "GROUP",
                       "HAVING", "AS", "CREATE", "TABLE", "INDEX", "DROP", "ALTER"]

        highlightKeywords(in: &text, keywords: keywords, color: .purple)
        highlightStrings(in: &text, color: .red)
        highlightComments(in: &text, color: .green, commentPrefix: "--")
    }

    private func highlightKeywords(in text: inout AttributedString, keywords: [String], color: Color) {
        for keyword in keywords {
            let pattern = "\\b\(keyword)\\b"
            var searchRange = text.startIndex..<text.endIndex

            while let range = text[searchRange].range(of: pattern, options: .regularExpression) {
                text[range].foregroundColor = color
                text[range].font = .system(.body, design: .monospaced).bold()

                guard range.upperBound < text.endIndex else { break }
                searchRange = range.upperBound..<text.endIndex
            }
        }
    }

    private func highlightStrings(in text: inout AttributedString, color: Color) {
        let pattern = "\"[^\"]*\"|'[^']*'"
        var searchRange = text.startIndex..<text.endIndex

        while let range = text[searchRange].range(of: pattern, options: .regularExpression) {
            text[range].foregroundColor = color

            guard range.upperBound < text.endIndex else { break }
            searchRange = range.upperBound..<text.endIndex
        }
    }

    private func highlightComments(in text: inout AttributedString, color: Color, commentPrefix: String = "//") {
        let pattern = "\(NSRegularExpression.escapedPattern(for: commentPrefix)).*$"
        var searchRange = text.startIndex..<text.endIndex

        while let range = text[searchRange].range(of: pattern, options: [.regularExpression]) {
            text[range].foregroundColor = color
            text[range].font = .system(.body, design: .monospaced).italic()

            guard range.upperBound < text.endIndex else { break }
            searchRange = range.upperBound..<text.endIndex
        }
    }
}
