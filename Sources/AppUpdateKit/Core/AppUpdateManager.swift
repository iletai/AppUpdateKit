import Foundation
#if canImport(Combine)
import Combine
#endif

/// Policy for throttling or scheduling update checks.
public enum AppUpdateCheckPolicy: Sendable, Equatable {
    /// Check every time `check()` is invoked.
    case always
    /// Check only once during the lifetime of the application session.
    case oncePerSession
    /// Check at most once within the specified time interval (in seconds).
    case interval(TimeInterval)
}

#if canImport(Combine)
/// Central state manager for checking, caching, and presenting update actions.
@MainActor
public final class AppUpdateManager: ObservableObject {
    public static let shared = AppUpdateManager()

    @Published public private(set) var currentAction: AppUpdateAction = .none
    @Published public private(set) var latestConfig: AppUpdateConfig? = nil
    @Published public private(set) var isChecking: Bool = false
    @Published public private(set) var lastCheckDate: Date? = nil

    private var activeTask: Task<AppUpdateAction, Never>?
    private var hasCheckedThisSession = false
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let timestamp = userDefaults.object(forKey: "AppUpdateKit.lastCheckDate") as? Date {
            self.lastCheckDate = timestamp
        }
    }

    /// Performs update check according to the given policy, evaluator, and fetcher.
    @discardableResult
    public func check(
        policy: AppUpdateCheckPolicy = .always,
        currentVersion: AppVersion = AppUpdateChecker.currentInstalledVersion(),
        defaultStoreURL: URL? = nil,
        evaluator: AppUpdateEvaluator = DefaultAppUpdateEvaluator(),
        onEvent: (@Sendable (AppUpdateEvent) -> Void)? = nil,
        fetcher: @Sendable @escaping () async throws -> AppUpdateConfig
    ) async -> AppUpdateAction {
        switch policy {
        case .oncePerSession:
            if hasCheckedThisSession { return currentAction }
        case .interval(let seconds):
            if let lastDate = lastCheckDate, Date().timeIntervalSince(lastDate) < seconds {
                return currentAction
            }
        case .always:
            break
        }

        if let activeTask = activeTask {
            return await activeTask.value
        }

        isChecking = true

        final class ConfigBox: @unchecked Sendable {
            var config: AppUpdateConfig?
        }
        let box = ConfigBox()

        let task = Task<AppUpdateAction, Never> { @MainActor [weak self] in
            defer {
                self?.activeTask = nil
                self?.isChecking = false
            }

            let action = await AppUpdateChecker.check(
                currentVersion: currentVersion,
                defaultStoreURL: defaultStoreURL,
                evaluator: evaluator,
                onEvent: { event in
                    if case .configFetched(let config) = event {
                        box.config = config
                    }
                    onEvent?(event)
                },
                fetcher: fetcher
            )

            self?.latestConfig = box.config
            self?.currentAction = action
            self?.hasCheckedThisSession = true
            let now = Date()
            self?.lastCheckDate = now
            self?.userDefaults.set(now, forKey: "AppUpdateKit.lastCheckDate")

            return action
        }

        self.activeTask = task
        return await task.value
    }

    /// Handles user choice (update, remind later, dismiss, custom) and updates state.
    public func handleUserChoice(_ choice: AppUpdateUserChoice, onEvent: (@Sendable (AppUpdateEvent) -> Void)? = nil) {
        let action = currentAction
        onEvent?(.userAction(action: action, choice: choice))

        switch choice {
        case .update:
            if !action.isBlocking {
                currentAction = .none
            }
        case .remindLater, .dismiss:
            if !action.isRequired {
                currentAction = .none
            }
        case .custom:
            currentAction = .none
        }
    }

    /// Resets the cached check status.
    public func reset() {
        currentAction = .none
        latestConfig = nil
        hasCheckedThisSession = false
        lastCheckDate = nil
        userDefaults.removeObject(forKey: "AppUpdateKit.lastCheckDate")
    }
}
#else
/// Central state manager for checking, caching, and presenting update actions.
@MainActor
public final class AppUpdateManager {
    public static let shared = AppUpdateManager()

    public private(set) var currentAction: AppUpdateAction = .none
    public private(set) var latestConfig: AppUpdateConfig? = nil
    public private(set) var isChecking: Bool = false
    public private(set) var lastCheckDate: Date? = nil

    private var activeTask: Task<AppUpdateAction, Never>?
    private var hasCheckedThisSession = false
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let timestamp = userDefaults.object(forKey: "AppUpdateKit.lastCheckDate") as? Date {
            self.lastCheckDate = timestamp
        }
    }

    /// Performs update check according to the given policy, evaluator, and fetcher.
    @discardableResult
    public func check(
        policy: AppUpdateCheckPolicy = .always,
        currentVersion: AppVersion = AppUpdateChecker.currentInstalledVersion(),
        defaultStoreURL: URL? = nil,
        evaluator: AppUpdateEvaluator = DefaultAppUpdateEvaluator(),
        onEvent: (@Sendable (AppUpdateEvent) -> Void)? = nil,
        fetcher: @Sendable @escaping () async throws -> AppUpdateConfig
    ) async -> AppUpdateAction {
        switch policy {
        case .oncePerSession:
            if hasCheckedThisSession { return currentAction }
        case .interval(let seconds):
            if let lastDate = lastCheckDate, Date().timeIntervalSince(lastDate) < seconds {
                return currentAction
            }
        case .always:
            break
        }

        if let activeTask = activeTask {
            return await activeTask.value
        }

        isChecking = true

        final class ConfigBox: @unchecked Sendable {
            var config: AppUpdateConfig?
        }
        let box = ConfigBox()

        let task = Task<AppUpdateAction, Never> { @MainActor [weak self] in
            defer {
                self?.activeTask = nil
                self?.isChecking = false
            }

            let action = await AppUpdateChecker.check(
                currentVersion: currentVersion,
                defaultStoreURL: defaultStoreURL,
                evaluator: evaluator,
                onEvent: { event in
                    if case .configFetched(let config) = event {
                        box.config = config
                    }
                    onEvent?(event)
                },
                fetcher: fetcher
            )

            self?.latestConfig = box.config
            self?.currentAction = action
            self?.hasCheckedThisSession = true
            let now = Date()
            self?.lastCheckDate = now
            self?.userDefaults.set(now, forKey: "AppUpdateKit.lastCheckDate")

            return action
        }

        self.activeTask = task
        return await task.value
    }

    /// Handles user choice (update, remind later, dismiss, custom) and updates state.
    public func handleUserChoice(_ choice: AppUpdateUserChoice, onEvent: (@Sendable (AppUpdateEvent) -> Void)? = nil) {
        let action = currentAction
        onEvent?(.userAction(action: action, choice: choice))

        switch choice {
        case .update:
            if !action.isBlocking {
                currentAction = .none
            }
        case .remindLater, .dismiss:
            if !action.isRequired {
                currentAction = .none
            }
        case .custom:
            currentAction = .none
        }
    }

    /// Resets the cached check status.
    public func reset() {
        currentAction = .none
        latestConfig = nil
        hasCheckedThisSession = false
        lastCheckDate = nil
        userDefaults.removeObject(forKey: "AppUpdateKit.lastCheckDate")
    }
}
#endif
