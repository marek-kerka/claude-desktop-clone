//
//  PromptTemplateManagementView.swift
//  LivesportClaude
//

import SwiftUI

struct PromptTemplateManagementView: View {
    @ObservedObject var templateStorage: PromptTemplateStorage

    @State private var showingAddTemplate = false
    @State private var editingTemplate: PromptTemplate?
    @State private var selectedCategory: String = "All"

    var filteredTemplates: [PromptTemplate] {
        if selectedCategory == "All" {
            return templateStorage.templates
        }
        return templateStorage.templates(in: selectedCategory)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Prompt Templates")
                    .font(.headline)

                Spacer()

                Button(action: { showingAddTemplate = true }) {
                    Label("New Template", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            }

            // Category filter
            if !templateStorage.categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryButton(
                            name: "All",
                            count: templateStorage.templates.count,
                            isSelected: selectedCategory == "All"
                        ) {
                            selectedCategory = "All"
                        }

                        ForEach(templateStorage.categories, id: \.self) { category in
                            CategoryButton(
                                name: category,
                                count: templateStorage.templates(in: category).count,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                }
            }

            Divider()

            // Templates list
            if filteredTemplates.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(selectedCategory == "All" ? "No templates yet" : "No templates in this category")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Create a template to get started")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredTemplates) { template in
                            PromptTemplateCard(
                                template: template,
                                onEdit: {
                                    editingTemplate = template
                                    showingAddTemplate = true
                                },
                                onDelete: {
                                    templateStorage.deleteTemplate(template)
                                }
                            )
                        }
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingAddTemplate, onDismiss: {
            editingTemplate = nil
        }) {
            PromptTemplateEditorView(
                templateStorage: templateStorage,
                editingTemplate: editingTemplate
            )
        }
    }
}

struct CategoryButton: View {
    let name: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(name)
                    .font(.caption)

                Text("\(count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct PromptTemplateCard: View {
    let template: PromptTemplate
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.title)
                        .font(.headline)

                    Text(template.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(8)
                }

                Spacer()

                Button(action: onEdit) {
                    Image(systemName: "pencil.circle")
                        .font(.title3)
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    Image(systemName: "trash.circle")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }

            Text(template.preview)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)

            Text("Updated \(template.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct PromptTemplateEditorView: View {
    @ObservedObject var templateStorage: PromptTemplateStorage
    let editingTemplate: PromptTemplate?

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var category: String = "General"
    @State private var customCategory: String = ""
    @State private var showCustomCategory: Bool = false

    @Environment(\.dismiss) private var dismiss

    var isEditing: Bool {
        editingTemplate != nil
    }

    var existingCategories: [String] {
        templateStorage.categories
    }

    var selectedCategoryValue: String {
        showCustomCategory ? customCategory : category
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(isEditing ? "Edit Template" : "New Template")
                .font(.title2)
                .fontWeight(.semibold)

            Form {
                Section("Details") {
                    TextField("Template Title", text: $title)
                        .textFieldStyle(.roundedBorder)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.subheadline)

                        Picker("Category", selection: $category) {
                            ForEach(existingCategories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                            Text("Custom...").tag("__custom__")
                        }
                        .pickerStyle(.menu)

                        if category == "__custom__" {
                            TextField("Custom Category", text: $customCategory)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: customCategory) { _ in
                                    showCustomCategory = true
                                }
                        }
                    }
                }

                Section("Content") {
                    TextEditor(text: $content)
                        .font(.body)
                        .frame(minHeight: 200)
                        .border(Color.secondary.opacity(0.2), width: 1)
                }
            }
            .formStyle(.grouped)

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button(isEditing ? "Update" : "Create") {
                    saveTemplate()
                }
                .keyboardShortcut(.return)
                .disabled(title.isEmpty || content.isEmpty)
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 600, height: 500)
        .onAppear {
            if let template = editingTemplate {
                title = template.title
                content = template.content
                category = template.category
            } else if let firstCategory = existingCategories.first {
                category = firstCategory
            }
        }
    }

    private func saveTemplate() {
        let finalCategory = category == "__custom__" ? customCategory : category

        if let existing = editingTemplate {
            var updated = existing
            updated.title = title
            updated.content = content
            updated.category = finalCategory
            templateStorage.updateTemplate(updated)
        } else {
            templateStorage.createTemplate(title: title, content: content, category: finalCategory)
        }

        dismiss()
    }
}

#Preview {
    PromptTemplateManagementView(templateStorage: PromptTemplateStorage())
        .frame(width: 700, height: 600)
}
