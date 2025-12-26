//
//  AppConfiguration.swift
//  LivesportClaude
//

import Foundation

struct AppConfiguration {
    // MARK: - API Configuration
    // Note: API key is currently embedded. Future versions will use secure storage.
    static let claudeAPIKey = "YOUR_ANTHROPIC_API_KEY_HERE"

    // MARK: - App Settings
    static let appName = "Livesport Claude"
    static let defaultModel: ClaudeModel = .sonnet

    // MARK: - System Prompts
    static let defaultSystemPrompt = """
    You are Claude, an AI assistant developed by Anthropic. You are helping Livesport employees with their work.
    Be helpful, harmless, and honest. Provide clear and concise responses.
    """
}
