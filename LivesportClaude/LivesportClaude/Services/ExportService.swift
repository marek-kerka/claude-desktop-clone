//
//  ExportService.swift
//  LivesportClaude
//

import Foundation
import AppKit
import PDFKit

@MainActor
class ExportService {

    // MARK: - Markdown Export

    static func exportToMarkdown(conversation: Conversation) -> String {
        var markdown = """
        # \(conversation.title)

        **Model:** \(conversation.model.displayName)
        **Created:** \(conversation.createdAt.formatted(date: .long, time: .shortened))
        **Messages:** \(conversation.messages.count)

        ---


        """

        for message in conversation.messages {
            let role = message.role == .user ? "👤 User" : "🤖 Claude"
            let timestamp = message.timestamp.formatted(date: .abbreviated, time: .shortened)

            markdown += "## \(role)\n"
            markdown += "*\(timestamp)*\n\n"

            for block in message.content {
                switch block {
                case .text(let text):
                    markdown += text + "\n\n"
                case .image:
                    markdown += "*[Image attachment]*\n\n"
                }
            }

            markdown += "---\n\n"
        }

        markdown += """

        ---
        *Exported from Livesport Claude on \(Date().formatted(date: .long, time: .shortened))*
        """

        return markdown
    }

    static func saveMarkdownFile(conversation: Conversation) {
        let markdown = exportToMarkdown(conversation: conversation)

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "\(sanitizeFilename(conversation.title)).md"
        panel.message = "Export conversation to Markdown"

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try markdown.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                showError("Failed to save Markdown file: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - PDF Export

    static func exportToPDF(conversation: Conversation) {
        let pdfDocument = createPDFDocument(conversation: conversation)

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "\(sanitizeFilename(conversation.title)).pdf"
        panel.message = "Export conversation to PDF"

        if panel.runModal() == .OK, let url = panel.url {
            if pdfDocument.write(to: url) {
                // Success
            } else {
                showError("Failed to save PDF file")
            }
        }
    }

    private static func createPDFDocument(conversation: Conversation) -> PDFDocument {
        let pdfMetadata = [
            kCGPDFContextTitle: conversation.title,
            kCGPDFContextAuthor: "Livesport Claude",
            kCGPDFContextCreator: "Livesport Claude Desktop"
        ] as [CFString: Any]

        var pageSize = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 size
        let pdfData = NSMutableData()

        guard let pdfConsumer = CGDataConsumer(data: pdfData),
              let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: nil, pdfMetadata as CFDictionary) else {
            return PDFDocument()
        }

        // Header info
        var yPosition: CGFloat = 792 // Start from top

        pdfContext.beginPage(mediaBox: &pageSize)

        // Draw header
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: NSColor.black
        ]

        let title = conversation.title as NSString
        title.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: headerAttributes)
        yPosition -= 40

        // Metadata
        let metaAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10),
            .foregroundColor: NSColor.gray
        ]

        let createdDate = conversation.createdAt.formatted(date: .abbreviated, time: .shortened)
        let meta = "Model: \(conversation.model.displayName) | Created: \(createdDate)" as NSString
        meta.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: metaAttributes)
        yPosition -= 30

        // Draw separator
        pdfContext.setStrokeColor(NSColor.gray.cgColor)
        pdfContext.setLineWidth(1)
        pdfContext.move(to: CGPoint(x: 50, y: yPosition))
        pdfContext.addLine(to: CGPoint(x: 545, y: yPosition))
        pdfContext.strokePath()
        yPosition -= 20

        // Messages
        for message in conversation.messages {
            // Check if we need a new page
            if yPosition < 100 {
                pdfContext.endPage()
                yPosition = 792
                pdfContext.beginPage(mediaBox: &pageSize)
            }

            let roleAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: message.role == .user ? NSColor.blue : NSColor.purple
            ]

            let roleText = (message.role == .user ? "User" : "Claude") as NSString
            roleText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: roleAttributes)
            yPosition -= 20

            let timestampAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 9),
                .foregroundColor: NSColor.gray
            ]

            let timestamp = message.timestamp.formatted(date: .abbreviated, time: .shortened) as NSString
            timestamp.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: timestampAttributes)
            yPosition -= 25

            // Message content
            let contentAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 11),
                .foregroundColor: NSColor.black
            ]

            let contentText = message.textContent as NSString
            let maxWidth: CGFloat = 495
            let actualSize = contentText.boundingRect(
                with: CGSize(width: maxWidth, height: .infinity),
                options: [.usesLineFragmentOrigin],
                attributes: contentAttributes
            )

            contentText.draw(
                in: CGRect(x: 50, y: yPosition - actualSize.height, width: maxWidth, height: actualSize.height),
                withAttributes: contentAttributes
            )

            yPosition -= actualSize.height + 30
        }

        pdfContext.endPage()
        pdfContext.closePDF()

        return PDFDocument(data: pdfData as Data) ?? PDFDocument()
    }

    // MARK: - Helpers

    private static func sanitizeFilename(_ filename: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return filename.components(separatedBy: invalidCharacters).joined(separator: "-")
    }

    private static func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Export Error"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}
