//
//  SystemPromptsView.swift
//  LivesportClaude
//

import SwiftUI

struct SystemPromptsView: View {
    @ObservedObject var promptStorage: SystemPromptStorage
    @State private var showingNewPrompt = false
    @State private var editingPrompt: SystemPrompt?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("System Prompts")
                    .font(.headline)

                Spacer()

                Button(action: { showingNewPrompt = true }, label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                })
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Prompts list
            List {
                ForEach(promptStorage.systemPrompts) { prompt in
                    SystemPromptRow(
                        prompt: prompt,
                        isSelected: promptStorage.selectedPromptId == prompt.id,
                        onSelect: {
                            promptStorage.selectPrompt(prompt)
                        },
                        onEdit: {
                            editingPrompt = prompt
                        },
                        onDelete: {
                            promptStorage.deletePrompt(prompt)
                        }
                    )
                }
            }
            .listStyle(.inset)
        }
        .sheet(isPresented: $showingNewPrompt) {
            SystemPromptEditor(
                prompt: nil,
                promptStorage: promptStorage,
                onSave: { newPrompt in
                    promptStorage.addPrompt(newPrompt)
                    showingNewPrompt = false
                }
            )
        }
        .sheet(item: $editingPrompt) { prompt in
            SystemPromptEditor(
                prompt: prompt,
                promptStorage: promptStorage,
                onSave: { updatedPrompt in
                    promptStorage.updatePrompt(updatedPrompt)
                    editingPrompt = nil
                }
            )
        }
    }
}

struct SystemPromptRow: View {
    let prompt: SystemPrompt
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Selection indicator
            Button(action: onSelect) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(prompt.name)
                        .font(.headline)

                    if prompt.isDefault {
                        Text("Built-in")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(4)
                    }
                }

                Text(prompt.prompt)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            // Actions
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.plain)

                if !prompt.isDefault {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct SystemPromptEditor: View {
    let prompt: SystemPrompt?
    let promptStorage: SystemPromptStorage
    let onSave: (SystemPrompt) -> Void

    @State private var name: String
    @State private var promptText: String
    @Environment(\.dismiss) var dismiss

    init(prompt: SystemPrompt?, promptStorage: SystemPromptStorage, onSave: @escaping (SystemPrompt) -> Void) {
        self.prompt = prompt
        self.promptStorage = promptStorage
        self.onSave = onSave

        _name = State(initialValue: prompt?.name ?? "")
        _promptText = State(initialValue: prompt?.prompt ?? "")
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(prompt == nil ? "New System Prompt" : "Edit System Prompt")
                    .font(.headline)

                Spacer()

                Button("Cancel") {
                    dismiss()
                }

                Button("Save") {
                    save()
                }
                .disabled(name.isEmpty || promptText.isEmpty)
                .keyboardShortcut(.return, modifiers: .command)
            }
            .padding()

            Divider()

            // Form
            Form {
                Section("Name") {
                    TextField("e.g., Code Expert", text: $name)
                        .textFieldStyle(.roundedBorder)
                }

                Section("Prompt") {
                    TextEditor(text: $promptText)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 200)
                }

                Section("Tips") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Be specific about the assistant's role and expertise", systemImage: "lightbulb")
                        Label("Include relevant context about Livesport if needed", systemImage: "building.2")
                        Label("Specify output format or style preferences", systemImage: "text.alignleft")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 600, height: 500)
    }

    private func save() {
        let newPrompt = SystemPrompt(
            id: prompt?.id ?? UUID(),
            name: name,
            prompt: promptText,
            createdAt: prompt?.createdAt ?? Date(),
            isDefault: false
        )
        onSave(newPrompt)
    }
}
