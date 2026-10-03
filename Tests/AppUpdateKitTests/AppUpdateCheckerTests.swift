import XCTest
@testable import AppUpdateKit

final class AppUpdateCheckerTests: XCTestCase {
    let testURL = URL(string: "https://apps.apple.com/app/id123456789")!

    func testEvaluateMaintenanceTakesPrecedence() {
        let config = AppUpdateConfig(
            minimumVersion: "2.0.0",
            latestVersion: "3.0.0",
            storeURL: testURL,
            isMaintenance: true,
            title: "Server Down",
            message: "We will be back shortly."
        )

        let action = AppUpdateChecker.evaluate(currentVersion: "1.0.0", config: config)
        XCTAssertEqual(action, .maintenance(title: "Server Down", message: "We will be back shortly."))
    }

    func testEvaluateMaintenanceWithDefaultMessages() {
        let config = AppUpdateConfig(isMaintenance: true)
        let action = AppUpdateChecker.evaluate(currentVersion: "1.0.0", config: config)

        if case .maintenance(let title, let message, _) = action {
            XCTAssertFalse(title.isEmpty)
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected maintenance action")
        }
    }

    func testEvaluateForceUpdate() {
        let config = AppUpdateConfig(
            minimumVersion: "2.0.0",
            latestVersion: "2.5.0",
            storeURL: testURL,
            isMaintenance: false,
            title: "Required Update",
            message: "Please upgrade"
        )

        let action = AppUpdateChecker.evaluate(currentVersion: "1.9.0", config: config)
        XCTAssertEqual(action, .forceUpdate(
            title: "Required Update",
            message: "Please upgrade",
            storeURL: testURL,
            version: AppVersion("2.5.0")
        ))
    }

    func testEvaluateOptionalUpdate() {
        let config = AppUpdateConfig(
            minimumVersion: "1.0.0",
            latestVersion: "2.0.0",
            storeURL: testURL,
            isMaintenance: false,
            title: "New Features",
            message: "Check out version 2.0"
        )

        let action = AppUpdateChecker.evaluate(currentVersion: "1.5.0", config: config)
        XCTAssertEqual(action, .optionalUpdate(
            title: "New Features",
            message: "Check out version 2.0",
            storeURL: testURL,
            version: AppVersion("2.0.0")
        ))
    }

    func testEvaluateUpToDateReturnsNone() {
        let config = AppUpdateConfig(
            minimumVersion: "1.0.0",
            latestVersion: "2.0.0",
            storeURL: testURL,
            isMaintenance: false
        )

        let action = AppUpdateChecker.evaluate(currentVersion: "2.0.0", config: config)
        XCTAssertEqual(action, .none)

        let actionNewer = AppUpdateChecker.evaluate(currentVersion: "2.1.0", config: config)
        XCTAssertEqual(actionNewer, .none)
    }

    func testEvaluateFallbackToDefaultStoreURL() {
        let fallbackURL = URL(string: "https://example.com/fallback")!
        let config = AppUpdateConfig(
            minimumVersion: "2.0.0",
            storeURL: nil
        )

        let action = AppUpdateChecker.evaluate(
            currentVersion: "1.0.0",
            config: config,
            defaultStoreURL: fallbackURL
        )

        XCTAssertEqual(action, .forceUpdate(
            title: "Update Required",
            message: "A new version of the app is available. Please update to continue.",
            storeURL: fallbackURL,
            version: AppVersion("2.0.0")
        ))
    }

    func testEvaluateWithoutStoreURLReturnsNone() {
        let config = AppUpdateConfig(minimumVersion: "2.0.0", storeURL: nil)
        let action = AppUpdateChecker.evaluate(currentVersion: "1.0.0", config: config)
        XCTAssertEqual(action, .none)
    }

    func testAsyncCheckSuccess() async {
        let config = AppUpdateConfig(minimumVersion: "2.0.0", storeURL: testURL)
        let action = await AppUpdateChecker.check(currentVersion: "1.0.0") {
            return config
        }
        XCTAssertEqual(action, .forceUpdate(
            title: "Update Required",
            message: "A new version of the app is available. Please update to continue.",
            storeURL: testURL,
            version: AppVersion("2.0.0")
        ))
    }

    func testAsyncCheckFailSafeOnNetworkError() async {
        enum MockError: Error {
            case networkTimeout
        }

        let action = await AppUpdateChecker.check(currentVersion: "1.0.0") {
            throw MockError.networkTimeout
        }

        XCTAssertEqual(action, .none)
    }
}
