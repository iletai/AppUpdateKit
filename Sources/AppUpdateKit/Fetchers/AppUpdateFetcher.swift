import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Factory methods for creating asynchronous configuration fetchers.
public enum AppUpdateFetcher {
    /// Creates a fetcher for microCMS endpoints with API key authentication.
    public static func microCMS(
        endpoint: URL,
        apiKey: String,
        session: URLSession = .shared
    ) -> @Sendable () async throws -> AppUpdateConfig {
        return {
            var request = URLRequest(url: endpoint)
            request.setValue(apiKey, forHTTPHeaderField: "X-MICROCMS-API-KEY")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "GET"

            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }

            return try JSONDecoder().decode(AppUpdateConfig.self, from: data)
        }
    }

    /// Creates a fetcher for generic JSON endpoints.
    public static func json(
        url: URL,
        session: URLSession = .shared
    ) -> @Sendable () async throws -> AppUpdateConfig {
        return {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "GET"

            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }

            return try JSONDecoder().decode(AppUpdateConfig.self, from: data)
        }
    }
}
