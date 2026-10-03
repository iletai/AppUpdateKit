import Foundation

/// Semantic version model with integer component normalization and metadata stripping.
public struct AppVersion: Comparable, Hashable, Sendable, CustomStringConvertible, ExpressibleByStringLiteral, RawRepresentable, Codable {
    public let raw: String
    public let components: [Int]

    public var rawValue: String {
        return raw
    }

    public init(rawValue: String) {
        self.init(rawValue)
    }

    public init(_ raw: String) {
        self.raw = raw
        let withoutPrerelease = raw.split(separator: "-").first.map(String.init) ?? ""
        let clean = withoutPrerelease.split(separator: "+").first.map(String.init) ?? ""
        self.components = clean
            .split(separator: ".")
            .compactMap { Int($0) }
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public var description: String {
        return raw
    }

    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        let count = max(lhs.components.count, rhs.components.count)
        for i in 0..<count {
            let l = i < lhs.components.count ? lhs.components[i] : 0
            let r = i < rhs.components.count ? rhs.components[i] : 0
            if l != r {
                return l < r
            }
        }
        return false
    }

    public static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
        let count = max(lhs.components.count, rhs.components.count)
        for i in 0..<count {
            let l = i < lhs.components.count ? lhs.components[i] : 0
            let r = i < rhs.components.count ? rhs.components[i] : 0
            if l != r {
                return false
            }
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        // Hash normalized components so 1.2 and 1.2.0 hash identically
        var normalized = components
        while let last = normalized.last, last == 0 {
            normalized.removeLast()
        }
        hasher.combine(normalized)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        self.init(rawString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(raw)
    }
}
