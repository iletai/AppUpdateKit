import Foundation

/// Core engine for checking and evaluating app update status.
public enum AppUpdateChecker {
    /// Retrieves current installed app version from bundle info dictionary.
    public static func currentInstalledVersion(bundle: Bundle = .main) -> AppVersion {
        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return AppVersion(version)
    }

    /// Evaluates pure business logic using standard or custom evaluator.
    public static func evaluate(
        currentVersion: AppVersion,
        config: AppUpdateConfig,
        defaultStoreURL: URL? = nil,
        evaluator: AppUpdateEvaluator = DefaultAppUpdateEvaluator()
    ) -> AppUpdateAction {
        return evaluator.evaluate(
            currentVersion: currentVersion,
            config: config,
            defaultStoreURL: defaultStoreURL
        )
    }

    /// Asynchronously fetches update configuration and returns update action.
    /// Fail-safe: handles any network error, timeout, or decoding failure by returning `.none`.
    public static func check(
        currentVersion: AppVersion = currentInstalledVersion(),
        defaultStoreURL: URL? = nil,
        evaluator: AppUpdateEvaluator = DefaultAppUpdateEvaluator(),
        onEvent: (@Sendable (AppUpdateEvent) -> Void)? = nil,
        fetcher: () async throws -> AppUpdateConfig
    ) async -> AppUpdateAction {
        onEvent?(.checkStarted)
        do {
            let config = try await fetcher()
            onEvent?(.configFetched(config: config))

            let action = evaluate(
                currentVersion: currentVersion,
                config: config,
                defaultStoreURL: defaultStoreURL,
                evaluator: evaluator
            )
            onEvent?(.evaluated(action: action))
            return action
        } catch {
            onEvent?(.checkFailed(reason: error.localizedDescription))
            return .none
        }
    }
}
