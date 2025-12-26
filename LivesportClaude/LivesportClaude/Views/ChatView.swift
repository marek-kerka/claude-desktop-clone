//
//  ChatView.swift
//  LivesportClaude
//

import SwiftUI
import UniformTypeIdentifiers

struct ChatView: View {
    @Binding var conversation: Conversation
    @StateObject private var apiClient: ClaudeAPIClient
    @ObservedObject var storage: ConversationStorage
    @ObservedObject var promptStorage: SystemPromptStorage
    @ObservedObject var usageStorage: UsageStorage

    @State private var inputText = ""
    @State private var isStreaming = false
    @State private var streamingResponse = ""
    @State private var selectedImages: [ImageAttachment] = []

    init(
        conversation: Binding<Conversation>,
        storage: ConversationStorage,
        promptStorage: SystemPromptStorage,
        usageStorage: UsageStorage
    ) {
        self._conversation = conversation
        self.storage = storage
        self.promptStorage = promptStorage
        self.usageStorage = usageStorage
        self._apiClient = StateObject(wrappedValue: ClaudeAPIClient(apiKey: AppConfiguration.claudeAPIKey))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ChatHeaderView(conversation: $conversation, storage: storage)

            Divider()

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(conversation.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }

                        // Streaming response
                        if isStreaming && !streamingResponse.isEmpty {
                            MessageBubbleView(
                                message: Message(
                                    role: .assistant,
                                    text: streamingResponse
                                )
                            )
                            .id("streaming")
                        }
                    }
                    .padding(.vertical, 12)
                }
                .onChange(of: conversation.messages.count) { _ in
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: streamingResponse) { _ in
                    scrollToBottom(proxy: proxy)
                }
            }

            Divider()

            // Input area
            ChatInputView(
                inputText: $inputText,
                selectedImages: $selectedImages,
                isStreaming: isStreaming,
                onSend: sendMessage
            )
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if isStreaming {
            withAnimation {
                proxy.scrollTo("streaming", anchor: .bottom)
            }
        } else if let lastMessage = conversation.messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }

    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !selectedImages.isEmpty else {
            return
        }

        // Create content blocks
        var contentBlocks: [Message.ContentBlock] = []

        // Add text if present
        if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            contentBlocks.append(.text(inputText))
        }

        // Add images if present
        for attachment in selectedImages {
            contentBlocks.append(.image(
                Message.ImageContent(
                    data: attachment.data,
                    mediaType: attachment.mediaType
                )
            ))
        }

        let userMessage = Message(role: .user, content: contentBlocks)
        conversation.addMessage(userMessage)
        storage.updateConversation(conversation)

        // Clear input
        let currentInput = inputText
        inputText = ""
        selectedImages.removeAll()

        // Send to API
        Task {
            isStreaming = true
            streamingResponse = ""

            do {
                let systemPrompt = promptStorage.getSelectedPrompt()?.prompt ?? AppConfiguration.defaultSystemPrompt
                let response = try await apiClient.sendMessage(
                    messages: conversation.messages,
                    model: conversation.model,
                    systemPrompt: systemPrompt
                ) { chunk in
                    streamingResponse += chunk
                }

                let assistantMessage = Message(role: .assistant, text: response)
                conversation.addMessage(assistantMessage)
                storage.updateConversation(conversation)

                // Track usage
                if let usage = apiClient.lastUsage {
                    usageStorage.addRecord(
                        model: conversation.model,
                        inputTokens: usage.inputTokens,
                        outputTokens: usage.outputTokens
                    )
                }

                streamingResponse = ""
                isStreaming = false
            } catch {
                // Revert input on error
                inputText = currentInput
                streamingResponse = ""
                isStreaming = false

                // Show error as assistant message
                let errorMessage = Message(
                    role: .assistant,
                    text: "Error: \(error.localizedDescription)"
                )
                conversation.addMessage(errorMessage)
                storage.updateConversation(conversation)
            }
        }
    }
}

// MARK: - Chat Header

struct ChatHeaderView: View {
    @Binding var conversation: Conversation
    @ObservedObject var storage: ConversationStorage

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                TextField("Conversation Title", text: $conversation.title)
                    .textFieldStyle(.plain)
                    .font(.headline)
                    .onChange(of: conversation.title) { _ in
                        storage.updateConversation(conversation)
                    }

                Text(conversation.model.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Export menu
            Menu {
                Button(action: { ExportService.saveMarkdownFile(conversation: conversation) }, label: {
                    Label("Export as Markdown", systemImage: "doc.text")
                })

                Button(action: { ExportService.exportToPDF(conversation: conversation) }, label: {
                    Label("Export as PDF", systemImage: "doc.richtext")
                })
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16))
            }
            .menuStyle(.borderlessButton)
        }
        .padding()
    }
}

// MARK: - Chat Input

struct ChatInputView: View {
    @Binding var inputText: String
    @Binding var selectedImages: [ImageAttachment]
    let isStreaming: Bool
    let onSend: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            // Image attachments preview
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedImages) { attachment in
                            ImageAttachmentPreview(attachment: attachment) {
                                selectedImages.removeAll { $0.id == attachment.id }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 80)
            }

            HStack(alignment: .bottom, spacing: 12) {
                // Attach button
                Button(action: attachImage) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)
                .disabled(isStreaming)

                // Text input
                TextEditor(text: $inputText)
                    .frame(minHeight: 36, maxHeight: 120)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                    .disabled(isStreaming)
                    .onSubmit {
                        if !inputText.contains("\n") {
                            onSend()
                        }
                    }

                // Send button
                Button(action: onSend) {
                    Image(systemName: isStreaming ? "stop.circle.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImages.isEmpty)
            }
            .padding()
        }
    }

    private func attachImage() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.png, .jpeg, .gif, .webP]

        if panel.runModal() == .OK {
            for url in panel.urls {
                if let data = try? Data(contentsOf: url),
                   let image = NSImage(data: data) {
                    let mediaType = url.pathExtension.lowercased() == "png" ? "image/png" : "image/jpeg"
                    let attachment = ImageAttachment(data: data, mediaType: mediaType, preview: image)
                    selectedImages.append(attachment)
                }
            }
        }
    }
}

// MARK: - Image Attachment

struct ImageAttachment: Identifiable {
    let id = UUID()
    let data: Data
    let mediaType: String
    let preview: NSImage
}

struct ImageAttachmentPreview: View {
    let attachment: ImageAttachment
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(nsImage: attachment.preview)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.6)))
            }
            .buttonStyle(.plain)
            .offset(x: 4, y: -4)
        }
    }
}
