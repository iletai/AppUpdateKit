import Foundation

/// Action to take based on app update evaluation.
public enum AppUpdateAction: Sendable, Equatable {
    case `none`
    case optionalUpdate(title: String, message: String, storeURL: URL)
    case forceUpdate(title: String, message: String, storeURL: URL)
    case maintenance(title: String, message: String)
}
