//
//  UpdateChecker.swift
//  LivesportClaude
//

import Foundation
import Sparkle

@MainActor
class UpdateChecker: ObservableObject {
    static let shared = UpdateChecker()

    private let updaterController: SPUStandardUpdaterController

    @Published var canCheckForUpdates = false
    @Published var updateCheckInProgress = false

    init() {
        // Initialize Sparkle updater
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        // Configure updater
        updaterController.updater.automaticallyChecksForUpdates = true
        updaterController.updater.automaticallyDownloadsUpdates = false
        updaterController.updater.updateCheckInterval = 86400 // 24 hours

        // Set feed URL from configuration
        if let feedURL = URL(string: UpdateConfiguration.appcastFeedURL) {
            updaterController.updater.setFeedURL(feedURL)
            print("✅ Sparkle configured with feed URL: \(feedURL)")
        } else {
            print("⚠️ Invalid appcast feed URL: \(UpdateConfiguration.appcastFeedURL)")
            print("   Please update UpdateConfiguration.appcastFeedURL with your Google Drive link")
        }

        // Monitor state
        canCheckForUpdates = updaterController.updater.canCheckForUpdates
    }

    func checkForUpdates() {
        guard canCheckForUpdates else {
            print("Cannot check for updates at this time")
            return
        }

        updateCheckInProgress = true
        updaterController.checkForUpdates(nil)

        // Reset flag after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.updateCheckInProgress = false
        }
    }

    var lastUpdateCheckDate: Date? {
        updaterController.updater.lastUpdateCheckDate
    }

    var feedURL: URL? {
        updaterController.updater.feedURL
    }
}
