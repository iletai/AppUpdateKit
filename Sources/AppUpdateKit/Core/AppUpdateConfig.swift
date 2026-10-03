import Foundation

/// Configuration model representing app update policies, remote settings, and custom metadata.
public struct AppUpdateConfig: Codable, Sendable, Equatable {
    public let minimumVersion: String?
    public let latestVersion: String?
    public let storeURL: URL?
    public let isMaintenance: Bool
    public let title: String?
    public let message: String?
    public let releaseNotes: [String]?
    public let metadata: [String: String]?

    public var latestAppVersion: AppVersion? {
        latestVersion.map { AppVersion($0) }
    }

    public var minimumAppVersion: AppVersion? {
        minimumVersion.map { AppVersion($0) }
    }

    public init(
        minimumVersion: String? = nil,
        latestVersion: String? = nil,
        storeURL: URL? = nil,
        isMaintenance: Bool = false,
        title: String? = nil,
        message: String? = nil,
        releaseNotes: [String]? = nil,
        metadata: [String: String]? = nil
    ) {
        self.minimumVersion = minimumVersion
        self.latestVersion = latestVersion
        self.storeURL = storeURL
        self.isMaintenance = isMaintenance
        self.title = title
        self.message = message
        self.releaseNotes = releaseNotes
        self.metadata = metadata
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
        case releaseNotes
        case releaseNotesSnake = "release_notes"
        case changelog
        case metadata
        case customPayload = "custom_payload"
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

        // Support bool or string-boolean ("true" / "1")
        if let boolVal = try? container.decodeIfPresent(Bool.self, forKey: .isMaintenance) {
            self.isMaintenance = boolVal
        } else if let boolValSnake = try? container.decodeIfPresent(Bool.self, forKey: .isMaintenanceSnake) {
            self.isMaintenance = boolValSnake
        } else if let strVal = try? container.decodeIfPresent(String.self, forKey: .isMaintenance) {
            self.isMaintenance = (strVal.lowercased() == "true" || strVal == "1")
        } else if let strValSnake = try? container.decodeIfPresent(String.self, forKey: .isMaintenanceSnake) {
            self.isMaintenance = (strValSnake.lowercased() == "true" || strValSnake == "1")
        } else {
            self.isMaintenance = false
        }

        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)

        // Robust decoding of releaseNotes as either [String] or multiline String
        if let notesArray = (try? container.decodeIfPresent([String].self, forKey: .releaseNotes))
            ?? (try? container.decodeIfPresent([String].self, forKey: .releaseNotesSnake))
            ?? (try? container.decodeIfPresent([String].self, forKey: .changelog)) {
            self.releaseNotes = notesArray
        } else if let singleString = (try? container.decodeIfPresent(String.self, forKey: .releaseNotes))
            ?? (try? container.decodeIfPresent(String.self, forKey: .releaseNotesSnake))
            ?? (try? container.decodeIfPresent(String.self, forKey: .changelog)) {
            let items = singleString
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            self.releaseNotes = items.isEmpty ? nil : items
        } else {
            self.releaseNotes = nil
        }

        self.metadata = (try? container.decodeIfPresent([String: String].self, forKey: .metadata))
            ?? (try? container.decodeIfPresent([String: String].self, forKey: .customPayload))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(minimumVersion, forKey: .minimumVersion)
        try container.encodeIfPresent(latestVersion, forKey: .latestVersion)
        try container.encodeIfPresent(storeURL, forKey: .storeURL)
        try container.encode(isMaintenance, forKey: .isMaintenance)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(releaseNotes, forKey: .releaseNotes)
        try container.encodeIfPresent(metadata, forKey: .metadata)
    }
}
