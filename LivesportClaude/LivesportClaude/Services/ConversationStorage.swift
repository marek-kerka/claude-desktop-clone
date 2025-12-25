//
//  ConversationStorage.swift
//  LivesportClaude
//

import Foundation

@MainActor
class ConversationStorage: ObservableObject {
    @Published var conversations: [Conversation] = []

    private let fileManager = FileManager.default
    private var storageURL: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("LivesportClaude", isDirectory: true)

        if !fileManager.fileExists(atPath: appFolder.path) {
            try? fileManager.createDirectory(at: appFolder, withIntermediateDirectories: true)
        }

        return appFolder.appendingPathComponent("conversations.json")
    }

    init() {
        loadConversations()
    }

    func loadConversations() {
        guard fileManager.fileExists(atPath: storageURL.path) else {
            conversations = []
            return
        }

        do {
            let data = try Data(contentsOf: storageURL)
            conversations = try JSONDecoder().decode([Conversation].self, from: data)
            // Sort by most recent
            conversations.sort { $0.lastMessageTime > $1.lastMessageTime }
        } catch {
            print("Failed to load conversations: \(error)")
            conversations = []
        }
    }

    func saveConversations() {
        do {
            let data = try JSONEncoder().encode(conversations)
            try data.write(to: storageURL)
        } catch {
            print("Failed to save conversations: \(error)")
        }
    }

    func createConversation(model: ClaudeModel = .sonnet) -> Conversation {
        let conversation = Conversation(model: model)
        conversations.insert(conversation, at: 0)
        saveConversations()
        return conversation
    }

    func updateConversation(_ conversation: Conversation) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index] = conversation
            // Move to top
            let updated = conversations.remove(at: index)
            conversations.insert(updated, at: 0)
            saveConversations()
        }
    }

    func deleteConversation(_ conversation: Conversation) {
        conversations.removeAll { $0.id == conversation.id }
        saveConversations()
    }

    func deleteAllConversations() {
        conversations.removeAll()
        saveConversations()
    }
}
