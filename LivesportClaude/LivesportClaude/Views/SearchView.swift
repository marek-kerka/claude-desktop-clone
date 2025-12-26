//
//  SearchView.swift
//  LivesportClaude
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var searchService: SearchService
    @ObservedObject var storage: ConversationStorage
    @Binding var selectedConversation: Conversation?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Search header
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search conversations...", text: $searchService.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .onChange(of: searchService.searchQuery) { query in
                        searchService.search(in: storage.conversations, query: query)
                    }

                if !searchService.searchQuery.isEmpty {
                    Button(action: {
                        searchService.clearSearch()
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    })
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Results
            if searchService.searchQuery.isEmpty {
                SearchEmptyState(type: .initial)
            } else if searchService.searchResults.isEmpty {
                SearchEmptyState(type: .noResults(query: searchService.searchQuery))
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(searchService.searchResults) { result in
                            SearchResultRow(result: result) {
                                selectedConversation = result.conversation
                                dismiss()
                            }
                            Divider()
                        }
                    }
                }
            }
        }
        .frame(width: 600, height: 500)
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(result.conversation.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    // Model badge
                    Text(result.conversation.model == .opus ? "Opus" : "Sonnet")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(result.conversation.model == .opus ? Color.purple : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)

                    Text(result.message.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: result.message.role == .user ? "person.fill" : "cpu")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(result.message.role == .user ? "User" : "Claude")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(result.context)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
        .contentShape(Rectangle())
    }
}

struct SearchEmptyState: View {
    enum EmptyType {
        case initial
        case noResults(query: String)
    }

    let type: EmptyType

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var iconName: String {
        switch type {
        case .initial:
            return "magnifyingglass"
        case .noResults:
            return "doc.text.magnifyingglass"
        }
    }

    private var title: String {
        switch type {
        case .initial:
            return "Search Conversations"
        case .noResults:
            return "No Results Found"
        }
    }

    private var subtitle: String {
        switch type {
        case .initial:
            return "Type to search through all your conversations"
        case .noResults(let query):
            return "No messages or conversations found for \"\(query)\""
        }
    }
}
