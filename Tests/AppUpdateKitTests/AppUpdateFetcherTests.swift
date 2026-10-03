import XCTest
@testable import AppUpdateKit

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class AppUpdateFetcherTests: XCTestCase {
    func testDecodeCamelCaseJSON() throws {
        let json = """
        {
            "minimumVersion": "1.0.0",
            "latestVersion": "2.1.0",
            "storeURL": "https://apps.apple.com/app/id12345",
            "isMaintenance": false,
            "title": "New Update",
            "message": "Performance improvements"
        }
        """.data(using: .utf8)!

        let config = try JSONDecoder().decode(AppUpdateConfig.self, from: json)
        XCTAssertEqual(config.minimumVersion, "1.0.0")
        XCTAssertEqual(config.latestVersion, "2.1.0")
        XCTAssertEqual(config.storeURL, URL(string: "https://apps.apple.com/app/id12345"))
        XCTAssertFalse(config.isMaintenance)
        XCTAssertEqual(config.title, "New Update")
        XCTAssertEqual(config.message, "Performance improvements")
    }

    func testDecodeSnakeCaseJSON() throws {
        let json = """
        {
            "minimum_version": "1.2.0",
            "latest_version": "2.0.0",
            "store_url": "https://apps.apple.com/app/id67890",
            "is_maintenance": true,
            "title": "Maintenance Mode",
            "message": "Under scheduled maintenance"
        }
        """.data(using: .utf8)!

        let config = try JSONDecoder().decode(AppUpdateConfig.self, from: json)
        XCTAssertEqual(config.minimumVersion, "1.2.0")
        XCTAssertEqual(config.latestVersion, "2.0.0")
        XCTAssertEqual(config.storeURL, URL(string: "https://apps.apple.com/app/id67890"))
        XCTAssertTrue(config.isMaintenance)
        XCTAssertEqual(config.title, "Maintenance Mode")
        XCTAssertEqual(config.message, "Under scheduled maintenance")
    }

    func testDecodeMinimalAndPartialJSON() throws {
        let json = """
        {
            "latest_version": "1.5.0"
        }
        """.data(using: .utf8)!

        let config = try JSONDecoder().decode(AppUpdateConfig.self, from: json)
        XCTAssertNil(config.minimumVersion)
        XCTAssertEqual(config.latestVersion, "1.5.0")
        XCTAssertNil(config.storeURL)
        XCTAssertFalse(config.isMaintenance)
        XCTAssertNil(config.title)
        XCTAssertNil(config.message)
    }

    func testEncodeAndDecodeRoundtrip() throws {
        let original = AppUpdateConfig(
            minimumVersion: "1.1.0",
            latestVersion: "2.2.0",
            storeURL: URL(string: "https://example.com"),
            isMaintenance: false,
            title: "Roundtrip",
            message: "Test"
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AppUpdateConfig.self, from: encoded)

        XCTAssertEqual(original, decoded)
    }

    func testCustomURLProtocolFetcherMock() async throws {
        final class MockURLProtocol: URLProtocol {
            static var mockResponseData: Data?
            static var mockStatusCode: Int = 200
            static var lastRequest: URLRequest?

            override class func canInit(with request: URLRequest) -> Bool {
                true
            }

            override class func canonicalRequest(for request: URLRequest) -> URLRequest {
                request
            }

            override func startLoading() {
                MockURLProtocol.lastRequest = request
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: MockURLProtocol.mockStatusCode,
                    httpVersion: nil,
                    headerFields: nil
                )!
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                if let data = MockURLProtocol.mockResponseData {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            }

            override func stopLoading() {}
        }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        let mockJSON = """
        {
            "minimum_version": "1.0.0",
            "latest_version": "1.5.0",
            "store_url": "https://apps.apple.com/app/id111"
        }
        """.data(using: .utf8)!

        MockURLProtocol.mockResponseData = mockJSON
        MockURLProtocol.mockStatusCode = 200

        let endpoint = URL(string: "https://api.microcms.io/v1/app-config")!
        let fetcher = AppUpdateFetcher.microCMS(endpoint: endpoint, apiKey: "secret-key", session: session)

        let result = try await fetcher()
        XCTAssertEqual(result.minimumVersion, "1.0.0")
        XCTAssertEqual(result.latestVersion, "1.5.0")
        XCTAssertEqual(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-MICROCMS-API-KEY"), "secret-key")
    }
}
