//
//  PromptTemplateStorage.swift
//  LivesportClaude
//

import Foundation

@MainActor
class PromptTemplateStorage: ObservableObject {
    static let shared = PromptTemplateStorage()

    @Published var templates: [PromptTemplate] = []

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

        return appFolder.appendingPathComponent("prompt_templates.json")
    }

    init(storageURL: URL? = nil) {
        self.customStorageURL = storageURL
        loadTemplates()
    }

    func loadTemplates() {
        guard fileManager.fileExists(atPath: storageURL.path) else {
            // Create default templates
            templates = createDefaultTemplates()
            saveTemplates()
            return
        }

        do {
            let data = try Data(contentsOf: storageURL)
            templates = try JSONDecoder().decode([PromptTemplate].self, from: data)
            templates.sort { $0.updatedAt > $1.updatedAt }
        } catch {
            print("Failed to load prompt templates: \(error)")
            templates = createDefaultTemplates()
        }
    }

    func saveTemplates() {
        do {
            let data = try JSONEncoder().encode(templates)
            try data.write(to: storageURL)
        } catch {
            print("Failed to save prompt templates: \(error)")
        }
    }

    func createTemplate(title: String, content: String, category: String) -> PromptTemplate {
        let template = PromptTemplate(title: title, content: content, category: category)
        templates.insert(template, at: 0)
        saveTemplates()
        return template
    }

    func updateTemplate(_ template: PromptTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            var updated = template
            updated.updatedAt = Date()
            templates[index] = updated

            // Move to top
            let moved = templates.remove(at: index)
            templates.insert(moved, at: 0)
            saveTemplates()
        }
    }

    func deleteTemplate(_ template: PromptTemplate) {
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }

    func deleteAllTemplates() {
        templates.removeAll()
        saveTemplates()
    }

    var categories: [String] {
        let unique = Set(templates.map { $0.category })
        return Array(unique).sorted()
    }

    func templates(in category: String) -> [PromptTemplate] {
        templates.filter { $0.category == category }
    }

    private func createDefaultTemplates() -> [PromptTemplate] {
        [
            PromptTemplate(
                title: "Code Review",
                content: "Please review this code and provide feedback on:\n1. Code quality and best practices\n2. Potential bugs or issues\n3. Performance improvements\n4. Readability and maintainability\n\n```\n[paste code here]\n```",
                category: "Development"
            ),
            PromptTemplate(
                title: "Explain Code",
                content: "Please explain what this code does in simple terms:\n\n```\n[paste code here]\n```\n\nInclude:\n- Overall purpose\n- How it works step by step\n- Any important details",
                category: "Development"
            ),
            PromptTemplate(
                title: "Write Unit Tests",
                content: "Please write comprehensive unit tests for this code:\n\n```\n[paste code here]\n```\n\nInclude tests for:\n- Normal cases\n- Edge cases\n- Error handling",
                category: "Development"
            ),
            PromptTemplate(
                title: "Summarize Text",
                content: "Please provide a concise summary of the following text:\n\n[paste text here]\n\nInclude:\n- Main points\n- Key takeaways\n- Important details",
                category: "Writing"
            ),
            PromptTemplate(
                title: "Improve Writing",
                content: "Please improve this text for clarity, grammar, and style:\n\n[paste text here]\n\nFocus on:\n- Grammar and spelling\n- Sentence structure\n- Tone and readability",
                category: "Writing"
            ),
            PromptTemplate(
                title: "Brainstorm Ideas",
                content: "Please help me brainstorm ideas for: [topic]\n\nProvide:\n- 10 creative ideas\n- Brief explanation for each\n- Potential challenges",
                category: "Creative"
            )
        ]
    }
}
