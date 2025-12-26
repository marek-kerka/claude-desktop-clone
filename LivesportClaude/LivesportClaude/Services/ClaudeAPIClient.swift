//
//  ClaudeAPIClient.swift
//  LivesportClaude
//

import Foundation

struct APIUsage {
    let inputTokens: Int
    let outputTokens: Int
}

@MainActor
class ClaudeAPIClient: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1"
    private let apiVersion = "2023-06-01"

    @Published var isLoading = false
    @Published var error: Error?
    @Published var lastUsage: APIUsage?

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // Streaming response
    func sendMessage(
        messages: [Message],
        model: ClaudeModel,
        systemPrompt: String? = nil,
        onChunk: @escaping (String) -> Void
    ) async throws -> String {
        isLoading = true
        defer { isLoading = false }

        let url = URL(string: "\(baseURL)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(apiVersion, forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        // Build request body
        var body: [String: Any] = [
            "model": model.rawValue,
            "max_tokens": model.maxTokens,
            "messages": messages.map { $0.toAPIMessage() },
            "stream": true
        ]

        if let systemPrompt = systemPrompt {
            body["system"] = systemPrompt
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (bytes, response) = try await URLSession.shared.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        var fullResponse = ""
        var inputTokens = 0
        var outputTokens = 0

        for try await line in bytes.lines {
            // Skip empty lines
            guard !line.isEmpty else { continue }

            // Parse SSE format
            if line.hasPrefix("data: ") {
                let jsonString = String(line.dropFirst(6))

                // Check for stream end
                if jsonString == "[DONE]" {
                    break
                }

                guard let data = jsonString.data(using: .utf8) else { continue }

                do {
                    let event = try JSONDecoder().decode(StreamEvent.self, from: data)

                    switch event.type {
                    case "message_start":
                        if let usage = event.message?.usage {
                            inputTokens = usage.inputTokens ?? 0
                        }
                    case "content_block_delta":
                        if let delta = event.delta,
                           let text = delta.text {
                            fullResponse += text
                            onChunk(text)
                        }
                    case "message_delta":
                        if let usage = event.usage {
                            outputTokens = usage.outputTokens ?? 0
                        }
                    case "message_stop":
                        break
                    default:
                        break
                    }
                } catch {
                    // Skip parsing errors for individual chunks
                    continue
                }
            }
        }

        lastUsage = APIUsage(inputTokens: inputTokens, outputTokens: outputTokens)
        return fullResponse
    }

    // Non-streaming response (for simpler use cases)
    func sendMessageSync(
        messages: [Message],
        model: ClaudeModel,
        systemPrompt: String? = nil
    ) async throws -> String {
        isLoading = true
        defer { isLoading = false }

        let url = URL(string: "\(baseURL)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(apiVersion, forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        var body: [String: Any] = [
            "model": model.rawValue,
            "max_tokens": model.maxTokens,
            "messages": messages.map { $0.toAPIMessage() }
        ]

        if let systemPrompt = systemPrompt {
            body["system"] = systemPrompt
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.apiError(message: errorResponse.error.message)
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let messageResponse = try JSONDecoder().decode(MessageResponse.self, from: data)

        if let usage = messageResponse.usage {
            lastUsage = APIUsage(inputTokens: usage.inputTokens, outputTokens: usage.outputTokens)
        }

        guard let textContent = messageResponse.content.first?.text else {
            throw APIError.invalidResponse
        }

        return textContent
    }
}

// MARK: - API Models

extension ClaudeAPIClient {
    struct StreamEvent: Codable {
        let type: String
        let delta: Delta?
        let message: MessageData?
        let usage: UsageData?

        struct Delta: Codable {
            let type: String?
            let text: String?
        }

        struct MessageData: Codable {
            let usage: UsageData?
        }

        struct UsageData: Codable {
            let inputTokens: Int?
            let outputTokens: Int?

            enum CodingKeys: String, CodingKey {
                case inputTokens = "input_tokens"
                case outputTokens = "output_tokens"
            }
        }
    }

    struct MessageResponse: Codable {
        let id: String
        let type: String
        let role: String
        let content: [Content]
        let model: String
        let stopReason: String?
        let usage: Usage?

        enum CodingKeys: String, CodingKey {
            case id, type, role, content, model, usage
            case stopReason = "stop_reason"
        }

        struct Content: Codable {
            let type: String
            let text: String?
        }

        struct Usage: Codable {
            let inputTokens: Int
            let outputTokens: Int

            enum CodingKeys: String, CodingKey {
                case inputTokens = "input_tokens"
                case outputTokens = "output_tokens"
            }
        }
    }

    struct ErrorResponse: Codable {
        let error: ErrorDetail

        struct ErrorDetail: Codable {
            let type: String
            let message: String
        }
    }

    enum APIError: LocalizedError {
        case invalidResponse
        case httpError(statusCode: Int)
        case apiError(message: String)

        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Invalid response from server"
            case .httpError(let code):
                return "HTTP error: \(code)"
            case .apiError(let message):
                return message
            }
        }
    }
}
