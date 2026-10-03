import Foundation

/// User choices during update prompts.
public enum AppUpdateUserChoice: Sendable, Equatable {
    case update(url: URL)
    case remindLater
    case dismiss
}

/// Action to take based on app update evaluation.
public enum AppUpdateAction: Sendable, Equatable {
    case `none`
    case optionalUpdate(title: String, message: String, storeURL: URL, releaseNotes: [String]? = nil)
    case forceUpdate(title: String, message: String, storeURL: URL, releaseNotes: [String]? = nil)
    case maintenance(title: String, message: String)

    /// Returns `true` if the update requires blocking user interaction (force update or maintenance).
    public var isBlocking: Bool {
        switch self {
        case .forceUpdate, .maintenance:
            return true
        case .none, .optionalUpdate:
            return false
        }
    }

    /// Returns `true` if a new version is available (optional or force update).
    public var isUpdateAvailable: Bool {
        switch self {
        case .optionalUpdate, .forceUpdate:
            return true
        case .none, .maintenance:
            return false
        }
    }

    /// Returns `true` if an update is mandatory.
    public var isRequired: Bool {
        switch self {
        case .forceUpdate:
            return true
        case .none, .optionalUpdate, .maintenance:
            return false
        }
    }

    /// Returns `true` if the service is in maintenance mode.
    public var isMaintenance: Bool {
        switch self {
        case .maintenance:
            return true
        case .none, .optionalUpdate, .forceUpdate:
            return false
        }
    }

    /// Extracted title of the action if applicable.
    public var title: String? {
        switch self {
        case .none:
            return nil
        case .optionalUpdate(let title, _, _, _),
             .forceUpdate(let title, _, _, _),
             .maintenance(let title, _):
            return title
        }
    }

    /// Extracted message of the action if applicable.
    public var message: String? {
        switch self {
        case .none:
            return nil
        case .optionalUpdate(_, let message, _, _),
             .forceUpdate(_, let message, _, _),
             .maintenance(_, let message):
            return message
        }
    }

    /// Target App Store or download URL if applicable.
    public var storeURL: URL? {
        switch self {
        case .optionalUpdate(_, _, let url, _),
             .forceUpdate(_, _, let url, _):
            return url
        case .none, .maintenance:
            return nil
        }
    }

    /// Optional changelog or release notes bullet points.
    public var releaseNotes: [String]? {
        switch self {
        case .optionalUpdate(_, _, _, let notes),
             .forceUpdate(_, _, _, let notes):
            return notes
        case .none, .maintenance:
            return nil
        }
    }
}
