//
//  PromptTemplatePicker.swift
//  LivesportClaude
//

import SwiftUI

struct PromptTemplatePicker: View {
    @ObservedObject var templateStorage: PromptTemplateStorage
    let onSelect: (PromptTemplate) -> Void

    @State private var selectedCategory: String = "All"
    @State private var searchText: String = ""

    var filteredTemplates: [PromptTemplate] {
        var templates = selectedCategory == "All" ?
            templateStorage.templates :
            templateStorage.templates(in: selectedCategory)

        if !searchText.isEmpty {
            templates = templates.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }

        return templates
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("Select Template")
                .font(.headline)

            // Search
            TextField("Search templates...", text: $searchText)
                .textFieldStyle(.roundedBorder)

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
                VStack(spacing: 12) {
                    Image(systemName: searchText.isEmpty ? "doc.text" : "magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)

                    Text(searchText.isEmpty ? "No templates available" : "No matching templates")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(filteredTemplates) { template in
                            TemplatePickerRow(template: template) {
                                onSelect(template)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }
}

struct TemplatePickerRow: View {
    let template: PromptTemplate
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(template.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Text(template.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(8)
                }

                Text(template.preview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PromptTemplatePicker(templateStorage: PromptTemplateStorage()) { template in
        print("Selected: \(template.title)")
    }
}
