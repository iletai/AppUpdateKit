import Foundation

/// Events emitted during app update evaluation and user interactions.
public enum AppUpdateEvent: Sendable, Equatable {
    /// Update check process initiated.
    case checkStarted

    /// Configuration successfully fetched from remote endpoint.
    case configFetched(config: AppUpdateConfig)

    /// Update action evaluated against current app version.
    case evaluated(action: AppUpdateAction)

    /// Update prompt presented to user.
    case presented(action: AppUpdateAction)

    /// User interacted with the update prompt.
    case userAction(action: AppUpdateAction, choice: AppUpdateUserChoice)

    /// An error occurred during check or network fetch.
    case checkFailed(reason: String)

    public static func == (lhs: AppUpdateEvent, rhs: AppUpdateEvent) -> Bool {
        switch (lhs, rhs) {
        case (.checkStarted, .checkStarted):
            return true
        case (.configFetched(let c1), .configFetched(let c2)):
            return c1 == c2
        case (.evaluated(let a1), .evaluated(let a2)):
            return a1 == a2
        case (.presented(let a1), .presented(let a2)):
            return a1 == a2
        case (.userAction(let a1, let c1), .userAction(let a2, let c2)):
            return a1 == a2 && c1 == c2
        case (.checkFailed(let r1), .checkFailed(let r2)):
            return r1 == r2
        default:
            return false
        }
    }
}
