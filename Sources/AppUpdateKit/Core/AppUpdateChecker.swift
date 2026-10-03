import Foundation

/// Core engine for checking and evaluating app update status.
public enum AppUpdateChecker {
    /// Retrieves current installed app version from bundle info dictionary.
    public static func currentInstalledVersion(bundle: Bundle = .main) -> AppVersion {
        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return AppVersion(version)
    }

    /// Evaluates pure business logic to determine update action.
    public static func evaluate(
        currentVersion: AppVersion,
        config: AppUpdateConfig,
        defaultStoreURL: URL? = nil
    ) -> AppUpdateAction {
        let title = config.title?.trimmingCharacters(in: .whitespacesAndNewlines)
        let message = config.message?.trimmingCharacters(in: .whitespacesAndNewlines)

        if config.isMaintenance {
            return .maintenance(
                title: (title?.isEmpty == false) ? title! : "Maintenance",
                message: (message?.isEmpty == false) ? message! : "The service is currently undergoing maintenance. Please try again later."
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
                    storeURL: storeURL
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
                    storeURL: storeURL
                )
            }
        }

        return .none
    }

    /// Asynchronously fetches update configuration and returns update action.
    /// Fail-safe: handles any network error, timeout, or decoding failure by returning `.none`.
    public static func check(
        currentVersion: AppVersion = currentInstalledVersion(),
        defaultStoreURL: URL? = nil,
        fetcher: () async throws -> AppUpdateConfig
    ) async -> AppUpdateAction {
        do {
            let config = try await fetcher()
            return evaluate(
                currentVersion: currentVersion,
                config: config,
                defaultStoreURL: defaultStoreURL
            )
        } catch {
            return .none
        }
    }
}
