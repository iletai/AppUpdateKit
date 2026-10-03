import Foundation

/// User choices during update prompts.
public enum AppUpdateUserChoice: Sendable, Equatable, Codable {
    case update(url: URL)
    case remindLater
    case dismiss
    case custom(id: String)
}

/// Action to take based on app update evaluation.
public enum AppUpdateAction: Sendable, Equatable, Codable {
    case `none`
    case optionalUpdate(title: String, message: String, storeURL: URL, version: AppVersion? = nil, releaseNotes: [String]? = nil, metadata: [String: String]? = nil)
    case forceUpdate(title: String, message: String, storeURL: URL, version: AppVersion? = nil, releaseNotes: [String]? = nil, metadata: [String: String]? = nil)
    case maintenance(title: String, message: String, metadata: [String: String]? = nil)
    case custom(id: String, title: String? = nil, message: String? = nil, storeURL: URL? = nil, version: AppVersion? = nil, releaseNotes: [String]? = nil, metadata: [String: String]? = nil)

    /// Returns `true` if the update requires blocking user interaction (force update or maintenance).
    public var isBlocking: Bool {
        switch self {
        case .forceUpdate, .maintenance:
            return true
        case .none, .optionalUpdate, .custom:
            return false
        }
    }

    /// Returns `true` if a new version is available (optional or force update).
    public var isUpdateAvailable: Bool {
        switch self {
        case .optionalUpdate, .forceUpdate:
            return true
        case .none, .maintenance, .custom:
            return false
        }
    }

    /// Returns `true` if an update is mandatory.
    public var isRequired: Bool {
        switch self {
        case .forceUpdate:
            return true
        case .none, .optionalUpdate, .maintenance, .custom:
            return false
        }
    }

    /// Returns `true` if the service is in maintenance mode.
    public var isMaintenance: Bool {
        switch self {
        case .maintenance:
            return true
        case .none, .optionalUpdate, .forceUpdate, .custom:
            return false
        }
    }

    /// Returns `true` if this is a custom action.
    public var isCustom: Bool {
        if case .custom = self { return true }
        return false
    }

    /// Custom action ID if applicable.
    public var customID: String? {
        if case .custom(let id, _, _, _, _, _, _) = self { return id }
        return nil
    }

    /// Extracted title of the action if applicable.
    public var title: String? {
        switch self {
        case .none:
            return nil
        case .optionalUpdate(let title, _, _, _, _, _),
             .forceUpdate(let title, _, _, _, _, _),
             .maintenance(let title, _, _):
            return title
        case .custom(_, let title, _, _, _, _, _):
            return title
        }
    }

    /// Extracted message of the action if applicable.
    public var message: String? {
        switch self {
        case .none:
            return nil
        case .optionalUpdate(_, let message, _, _, _, _),
             .forceUpdate(_, let message, _, _, _, _),
             .maintenance(_, let message, _):
            return message
        case .custom(_, _, let message, _, _, _, _):
            return message
        }
    }

    /// Target App Store or download URL if applicable.
    public var storeURL: URL? {
        switch self {
        case .optionalUpdate(_, _, let url, _, _, _),
             .forceUpdate(_, _, let url, _, _, _):
            return url
        case .custom(_, _, _, let url, _, _, _):
            return url
        case .none, .maintenance:
            return nil
        }
    }

    /// Target new version if provided by configuration.
    public var version: AppVersion? {
        switch self {
        case .optionalUpdate(_, _, _, let ver, _, _),
             .forceUpdate(_, _, _, let ver, _, _),
             .custom(_, _, _, _, let ver, _, _):
            return ver
        case .none, .maintenance:
            return nil
        }
    }

    /// Optional changelog or release notes bullet points.
    public var releaseNotes: [String]? {
        switch self {
        case .optionalUpdate(_, _, _, _, let notes, _),
             .forceUpdate(_, _, _, _, let notes, _),
             .custom(_, _, _, _, _, let notes, _):
            return notes
        case .none, .maintenance:
            return nil
        }
    }

    /// Extra custom metadata dictionary from backend payload.
    public var metadata: [String: String]? {
        switch self {
        case .optionalUpdate(_, _, _, _, _, let meta),
             .forceUpdate(_, _, _, _, _, let meta),
             .maintenance(_, _, let meta),
             .custom(_, _, _, _, _, _, let meta):
            return meta
        case .none:
            return nil
        }
    }
}
