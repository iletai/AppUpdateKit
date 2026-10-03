import Foundation

/// Protocol for custom version evaluation strategies.
public protocol AppUpdateEvaluator: Sendable {
    /// Evaluates version policy and returns corresponding update action.
    func evaluate(
        currentVersion: AppVersion,
        config: AppUpdateConfig,
        defaultStoreURL: URL?
    ) -> AppUpdateAction
}

/// Default standard evaluation engine.
public struct DefaultAppUpdateEvaluator: AppUpdateEvaluator {
    public init() {}

    public func evaluate(
        currentVersion: AppVersion,
        config: AppUpdateConfig,
        defaultStoreURL: URL? = nil
    ) -> AppUpdateAction {
        let title = config.title?.trimmingCharacters(in: .whitespacesAndNewlines)
        let message = config.message?.trimmingCharacters(in: .whitespacesAndNewlines)

        if config.isMaintenance {
            return .maintenance(
                title: (title?.isEmpty == false) ? title! : "Maintenance",
                message: (message?.isEmpty == false) ? message! : "The service is currently undergoing maintenance. Please try again later.",
                metadata: config.metadata
            )
        }

        let storeURL = config.storeURL ?? defaultStoreURL

        if let minVerStr = config.minimumVersion,
           !minVerStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let minVersion = AppVersion(minVerStr)
            if currentVersion < minVersion, let storeURL = storeURL {
                return .forceUpdate(
                    title: (title?.isEmpty == false) ? title! : "Update Required",
                    message: (message?.isEmpty == false) ? message! : "A new version of the app is available. Please update to continue.",
                    storeURL: storeURL,
                    version: config.latestAppVersion ?? minVersion,
                    releaseNotes: config.releaseNotes,
                    metadata: config.metadata
                )
            }
        }

        if let latestVerStr = config.latestVersion,
           !latestVerStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let latestVersion = AppVersion(latestVerStr)
            if currentVersion < latestVersion, let storeURL = storeURL {
                return .optionalUpdate(
                    title: (title?.isEmpty == false) ? title! : "Update Available",
                    message: (message?.isEmpty == false) ? message! : "A new version of the app is available. Would you like to update now?",
                    storeURL: storeURL,
                    version: latestVersion,
                    releaseNotes: config.releaseNotes,
                    metadata: config.metadata
                )
            }
        }

        return .none
    }
}
