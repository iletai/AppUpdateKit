import Foundation

/// Represents a semantic version with integer component normalization.
public struct AppVersion: Comparable, Sendable, Equatable, Hashable, CustomStringConvertible, ExpressibleByStringLiteral {
    public let rawValue: String
    public let components: [Int]

    public init(_ rawValue: String) {
        self.rawValue = rawValue
        // Strip prerelease (-...) and build metadata (+...)
        let base = rawValue
            .components(separatedBy: CharacterSet(charactersIn: "-+"))
            .first ?? ""

        let parsed = base
            .split(separator: ".")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }

        // Trim trailing zeros for normalization: [1, 2, 0, 0] -> [1, 2]
        var normalized = parsed
        while let last = normalized.last, last == 0 {
            normalized.removeLast()
        }
        self.components = normalized
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public var description: String {
        rawValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(components)
    }

    public static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
        lhs.components == rhs.components
    }

    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        let maxCount = max(lhs.components.count, rhs.components.count)
        for index in 0..<maxCount {
            let left = index < lhs.components.count ? lhs.components[index] : 0
            let right = index < rhs.components.count ? rhs.components[index] : 0
            if left != right {
                return left < right
            }
        }
        return false
    }
}
