//
//  SearchService.swift
//  LivesportClaude
//

import Foundation

struct SearchResult: Identifiable {
    let id = UUID()
    let conversation: Conversation
    let messageIndex: Int
    let message: Message
    let matchedText: String
    let context: String
}

@MainActor
class SearchService: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching = false

    func search(in conversations: [Conversation], query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        searchResults = []

        let lowercasedQuery = query.lowercased()

        for conversation in conversations {
            // Search in conversation title
            if conversation.title.lowercased().contains(lowercasedQuery) {
                // Add first message as result if title matches
                if let firstMessage = conversation.messages.first {
                    let result = SearchResult(
                        conversation: conversation,
                        messageIndex: 0,
                        message: firstMessage,
                        matchedText: conversation.title,
                        context: "Title: \(conversation.title)"
                    )
                    searchResults.append(result)
                }
            }

            // Search in messages
            for (index, message) in conversation.messages.enumerated() {
                let messageText = message.textContent
                if messageText.lowercased().contains(lowercasedQuery) {
                    let result = SearchResult(
                        conversation: conversation,
                        messageIndex: index,
                        message: message,
                        matchedText: extractMatch(from: messageText, query: query),
                        context: extractContext(from: messageText, query: query)
                    )
                    searchResults.append(result)
                }
            }
        }

        isSearching = false
    }

    private func extractMatch(from text: String, query: String) -> String {
        guard let range = text.range(of: query, options: .caseInsensitive) else {
            return query
        }

        let startOffset = text.index(range.lowerBound, offsetBy: -20, limitedBy: text.startIndex)
        let start = max(range.lowerBound, startOffset ?? text.startIndex)

        let endOffset = text.index(range.upperBound, offsetBy: 20, limitedBy: text.endIndex)
        let end = min(range.upperBound, endOffset ?? text.endIndex)

        var match = String(text[start..<end])
        if start > text.startIndex {
            match = "..." + match
        }
        if end < text.endIndex {
            match = match + "..."
        }

        return match
    }

    private func extractContext(from text: String, query: String, contextLength: Int = 100) -> String {
        guard let range = text.range(of: query, options: .caseInsensitive) else {
            return String(text.prefix(contextLength))
        }

        let start = max(
            range.lowerBound,
            text.index(range.lowerBound, offsetBy: -contextLength / 2, limitedBy: text.startIndex) ?? text.startIndex
        )
        let end = min(
            range.upperBound,
            text.index(range.upperBound, offsetBy: contextLength / 2, limitedBy: text.endIndex) ?? text.endIndex
        )

        var context = String(text[start..<end])
        if start > text.startIndex {
            context = "..." + context
        }
        if end < text.endIndex {
            context = context + "..."
        }

        return context
    }

    func clearSearch() {
        searchQuery = ""
        searchResults = []
    }
}
