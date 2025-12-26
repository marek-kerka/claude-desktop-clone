//
//  TagManagementView.swift
//  LivesportClaude
//

import SwiftUI

struct TagManagementView: View {
    @ObservedObject var tagStorage: TagStorage

    @State private var showingAddTag = false
    @State private var newTagName = ""
    @State private var selectedColor: TagColor = .blue
    @State private var editingTag: Tag?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tags")
                    .font(.headline)

                Spacer()

                Button(action: { showingAddTag = true }) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.plain)
            }

            if tagStorage.tags.isEmpty {
                Text("No tags yet. Create one to get started.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(tagStorage.tags) { tag in
                            TagRowView(
                                tag: tag,
                                onEdit: {
                                    editingTag = tag
                                    newTagName = tag.name
                                    selectedColor = tag.color
                                    showingAddTag = true
                                },
                                onDelete: {
                                    tagStorage.deleteTag(tag)
                                }
                            )
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTag, onDismiss: {
            editingTag = nil
            newTagName = ""
            selectedColor = .blue
        }) {
            TagEditorView(
                tagName: $newTagName,
                selectedColor: $selectedColor,
                isEditing: editingTag != nil,
                onSave: {
                    if let existingTag = editingTag {
                        var updated = existingTag
                        updated.name = newTagName
                        updated.color = selectedColor
                        tagStorage.updateTag(updated)
                    } else {
                        tagStorage.createTag(name: newTagName, color: selectedColor)
                    }
                    showingAddTag = false
                },
                onCancel: {
                    showingAddTag = false
                }
            )
        }
    }
}

struct TagRowView: View {
    let tag: Tag
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Circle()
                .fill(tag.color.color)
                .frame(width: 12, height: 12)

            Text(tag.name)
                .font(.body)

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.caption)
            }
            .buttonStyle(.plain)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
    }
}

struct TagEditorView: View {
    @Binding var tagName: String
    @Binding var selectedColor: TagColor
    let isEditing: Bool
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(isEditing ? "Edit Tag" : "New Tag")
                .font(.headline)

            TextField("Tag name", text: $tagName)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 8) {
                Text("Color")
                    .font(.subheadline)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(TagColor.allCases, id: \.self) { color in
                        Button(action: { selectedColor = color }) {
                            Circle()
                                .fill(color.color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.escape)

                Spacer()

                Button(isEditing ? "Save" : "Create", action: onSave)
                    .keyboardShortcut(.return)
                    .disabled(tagName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

#Preview {
    TagManagementView(tagStorage: TagStorage())
        .padding()
        .frame(width: 400, height: 300)
}
