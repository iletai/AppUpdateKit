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

    /// Custom lifecycle or developer-defined tracking event.
    case custom(name: String, payload: [String: String]? = nil)
}
