import Foundation

/// Configuration model representing app update policies and remote settings.
public struct AppUpdateConfig: Codable, Sendable, Equatable {
    public let minimumVersion: String?
    public let latestVersion: String?
    public let storeURL: URL?
    public let isMaintenance: Bool
    public let title: String?
    public let message: String?

    public init(
        minimumVersion: String? = nil,
        latestVersion: String? = nil,
        storeURL: URL? = nil,
        isMaintenance: Bool = false,
        title: String? = nil,
        message: String? = nil
    ) {
        self.minimumVersion = minimumVersion
        self.latestVersion = latestVersion
        self.storeURL = storeURL
        self.isMaintenance = isMaintenance
        self.title = title
        self.message = message
    }

    private enum CodingKeys: String, CodingKey {
        case minimumVersion
        case minimumVersionSnake = "minimum_version"
        case latestVersion
        case latestVersionSnake = "latest_version"
        case storeURL
        case storeUrlCamel = "storeUrl"
        case storeURLSnake = "store_url"
        case isMaintenance
        case isMaintenanceSnake = "is_maintenance"
        case title
        case message
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.minimumVersion = try container.decodeIfPresent(String.self, forKey: .minimumVersion)
            ?? container.decodeIfPresent(String.self, forKey: .minimumVersionSnake)

        self.latestVersion = try container.decodeIfPresent(String.self, forKey: .latestVersion)
            ?? container.decodeIfPresent(String.self, forKey: .latestVersionSnake)

        if let directURL = try container.decodeIfPresent(URL.self, forKey: .storeURL)
            ?? container.decodeIfPresent(URL.self, forKey: .storeUrlCamel)
            ?? container.decodeIfPresent(URL.self, forKey: .storeURLSnake) {
            self.storeURL = directURL
        } else if let urlString = try container.decodeIfPresent(String.self, forKey: .storeURL)
            ?? container.decodeIfPresent(String.self, forKey: .storeUrlCamel)
            ?? container.decodeIfPresent(String.self, forKey: .storeURLSnake) {
            self.storeURL = URL(string: urlString)
        } else {
            self.storeURL = nil
        }

        self.isMaintenance = try container.decodeIfPresent(Bool.self, forKey: .isMaintenance)
            ?? container.decodeIfPresent(Bool.self, forKey: .isMaintenanceSnake)
            ?? false

        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(minimumVersion, forKey: .minimumVersion)
        try container.encodeIfPresent(latestVersion, forKey: .latestVersion)
        try container.encodeIfPresent(storeURL, forKey: .storeURL)
        try container.encode(isMaintenance, forKey: .isMaintenance)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(message, forKey: .message)
    }
}
