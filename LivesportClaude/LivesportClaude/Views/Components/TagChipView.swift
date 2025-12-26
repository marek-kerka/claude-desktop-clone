//
//  TagChipView.swift
//  LivesportClaude
//

import SwiftUI

struct TagChipView: View {
    let tag: Tag
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 4) {
            Text(tag.name)
                .font(.caption)
                .lineLimit(1)

            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tag.color.color.opacity(0.2))
        .foregroundColor(tag.color.color)
        .cornerRadius(12)
    }
}

#Preview {
    HStack {
        TagChipView(tag: Tag(name: "Work", color: .blue))
        TagChipView(tag: Tag(name: "Important", color: .red)) {
            print("Delete tapped")
        }
    }
    .padding()
}
