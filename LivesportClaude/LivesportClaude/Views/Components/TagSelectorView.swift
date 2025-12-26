//
//  TagSelectorView.swift
//  LivesportClaude
//

import SwiftUI

struct TagSelectorView: View {
    @ObservedObject var tagStorage: TagStorage
    @Binding var selectedTags: [Tag]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Tags")
                .font(.headline)

            if tagStorage.tags.isEmpty {
                VStack(spacing: 8) {
                    Text("No tags available")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Create tags in Settings to organize your conversations")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(tagStorage.tags) { tag in
                            let isSelected = selectedTags.contains(where: { $0.id == tag.id })

                            Button(action: {
                                if isSelected {
                                    selectedTags.removeAll { $0.id == tag.id }
                                } else {
                                    selectedTags.append(tag)
                                }
                            }) {
                                HStack {
                                    Circle()
                                        .fill(tag.color.color)
                                        .frame(width: 12, height: 12)

                                    Text(tag.name)
                                        .foregroundColor(.primary)

                                    Spacer()

                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.accentColor)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(8)
                                .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                                .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: 300, height: 400)
    }
}

#Preview {
    TagSelectorView(
        tagStorage: TagStorage(),
        selectedTags: .constant([])
    )
}
