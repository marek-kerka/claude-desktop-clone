//
//  TagStorage.swift
//  LivesportClaude
//

import Foundation

@MainActor
class TagStorage: ObservableObject {
    static let shared = TagStorage()

    @Published var tags: [Tag] = []

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

        return appFolder.appendingPathComponent("tags.json")
    }

    init(storageURL: URL? = nil) {
        self.customStorageURL = storageURL
        loadTags()
    }

    func loadTags() {
        guard fileManager.fileExists(atPath: storageURL.path) else {
            // Create default tags
            tags = [
                Tag(name: "Work", color: .blue),
                Tag(name: "Personal", color: .green),
                Tag(name: "Important", color: .red)
            ]
            saveTags()
            return
        }

        do {
            let data = try Data(contentsOf: storageURL)
            tags = try JSONDecoder().decode([Tag].self, from: data)
        } catch {
            print("Failed to load tags: \(error)")
            tags = []
        }
    }

    func saveTags() {
        do {
            let data = try JSONEncoder().encode(tags)
            try data.write(to: storageURL)
        } catch {
            print("Failed to save tags: \(error)")
        }
    }

    func createTag(name: String, color: TagColor) -> Tag {
        let tag = Tag(name: name, color: color)
        tags.append(tag)
        saveTags()
        return tag
    }

    func updateTag(_ tag: Tag) {
        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            tags[index] = tag
            saveTags()
        }
    }

    func deleteTag(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
        saveTags()
    }
}
