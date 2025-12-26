//
//  SystemPromptStorage.swift
//  LivesportClaude
//

import Foundation

@MainActor
class SystemPromptStorage: ObservableObject {
    @Published var systemPrompts: [SystemPrompt] = []
    @Published var selectedPromptId: UUID?

    private let fileManager = FileManager.default
    private let customStorageURL: URL?

    private var storageURL: URL {
        if let customURL = customStorageURL {
            return customURL
        }

        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("LivesportClaude", isDirectory: true)

        if !fileManager.fileExists(atPath: appFolder.path) {
            try? fileManager.createDirectory(at: appFolder, withIntermediateDirectories: true)
        }

        return appFolder.appendingPathComponent("system_prompts.json")
    }

    init(storageURL: URL? = nil) {
        self.customStorageURL = storageURL
        loadPrompts()
    }

    func loadPrompts() {
        if fileManager.fileExists(atPath: storageURL.path) {
            do {
                let data = try Data(contentsOf: storageURL)
                let decoded = try JSONDecoder().decode(SavedPromptsData.self, from: data)
                systemPrompts = decoded.prompts
                selectedPromptId = decoded.selectedPromptId
            } catch {
                print("Failed to load system prompts: \(error)")
                loadDefaultPrompts()
            }
        } else {
            loadDefaultPrompts()
        }
    }

    private func loadDefaultPrompts() {
        systemPrompts = SystemPrompt.builtInPrompts
        selectedPromptId = systemPrompts.first?.id
        savePrompts()
    }

    func savePrompts() {
        do {
            let data = SavedPromptsData(prompts: systemPrompts, selectedPromptId: selectedPromptId)
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: storageURL)
        } catch {
            print("Failed to save system prompts: \(error)")
        }
    }

    func addPrompt(_ prompt: SystemPrompt) {
        systemPrompts.append(prompt)
        savePrompts()
    }

    func updatePrompt(_ prompt: SystemPrompt) {
        if let index = systemPrompts.firstIndex(where: { $0.id == prompt.id }) {
            systemPrompts[index] = prompt
            savePrompts()
        }
    }

    func deletePrompt(_ prompt: SystemPrompt) {
        systemPrompts.removeAll { $0.id == prompt.id }
        if selectedPromptId == prompt.id {
            selectedPromptId = systemPrompts.first?.id
        }
        savePrompts()
    }

    func getSelectedPrompt() -> SystemPrompt? {
        if let id = selectedPromptId {
            return systemPrompts.first { $0.id == id }
        }
        return systemPrompts.first
    }

    func selectPrompt(_ prompt: SystemPrompt) {
        selectedPromptId = prompt.id
        savePrompts()
    }

    struct SavedPromptsData: Codable {
        let prompts: [SystemPrompt]
        let selectedPromptId: UUID?
    }
}
