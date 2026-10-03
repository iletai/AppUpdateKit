import XCTest
@testable import AppUpdateKit

final class AppUpdateEventTests: XCTestCase {
    let testURL = URL(string: "https://apps.apple.com/app/id123456789")!

    func testAppVersionCodable() throws {
        let version = AppVersion("2.1.0")
        let data = try JSONEncoder().encode(version)
        let decoded = try JSONDecoder().decode(AppVersion.self, from: data)
        XCTAssertEqual(decoded, version)
        XCTAssertEqual(decoded.description, "2.1.0")
    }

    func testActionProperties() {
        let optionalAction = AppUpdateAction.optionalUpdate(
            title: "New Update",
            message: "Exciting features!",
            storeURL: testURL,
            version: AppVersion("2.1.0"),
            releaseNotes: ["Feature A", "Bug fixes"],
            metadata: ["banner_url": "https://example.com/banner.png"]
        )

        XCTAssertFalse(optionalAction.isBlocking)
        XCTAssertTrue(optionalAction.isUpdateAvailable)
        XCTAssertFalse(optionalAction.isRequired)
        XCTAssertFalse(optionalAction.isMaintenance)
        XCTAssertEqual(optionalAction.title, "New Update")
        XCTAssertEqual(optionalAction.message, "Exciting features!")
        XCTAssertEqual(optionalAction.storeURL, testURL)
        XCTAssertEqual(optionalAction.version, AppVersion("2.1.0"))
        XCTAssertEqual(optionalAction.releaseNotes, ["Feature A", "Bug fixes"])
        XCTAssertEqual(optionalAction.metadata?["banner_url"], "https://example.com/banner.png")

        let forceAction = AppUpdateAction.forceUpdate(
            title: "Important Update",
            message: "Must upgrade",
            storeURL: testURL,
            version: AppVersion("3.0.0"),
            releaseNotes: ["Security patch"]
        )

        XCTAssertTrue(forceAction.isBlocking)
        XCTAssertTrue(forceAction.isRequired)
        XCTAssertTrue(forceAction.isUpdateAvailable)
        XCTAssertFalse(forceAction.isMaintenance)

        let maintenanceAction = AppUpdateAction.maintenance(
            title: "Under Maintenance",
            message: "Back at 5 PM"
        )

        XCTAssertTrue(maintenanceAction.isBlocking)
        XCTAssertFalse(maintenanceAction.isRequired)
        XCTAssertFalse(maintenanceAction.isUpdateAvailable)
        XCTAssertTrue(maintenanceAction.isMaintenance)
        XCTAssertNil(maintenanceAction.storeURL)
        XCTAssertNil(maintenanceAction.releaseNotes)

        let customAction = AppUpdateAction.custom(
            id: "mdm_enterprise",
            title: "Enterprise Sync",
            message: "Custom prompt"
        )
        XCTAssertTrue(customAction.isCustom)
        XCTAssertEqual(customAction.customID, "mdm_enterprise")

        let noneAction = AppUpdateAction.none
        XCTAssertFalse(noneAction.isBlocking)
        XCTAssertFalse(noneAction.isUpdateAvailable)
        XCTAssertNil(noneAction.title)
    }

    func testActionCodable() throws {
        let action = AppUpdateAction.optionalUpdate(
            title: "Update",
            message: "New version available",
            storeURL: testURL,
            version: AppVersion("2.0.0"),
            releaseNotes: ["Item 1"]
        )

        let data = try JSONEncoder().encode(action)
        let decoded = try JSONDecoder().decode(AppUpdateAction.self, from: data)
        XCTAssertEqual(decoded, action)
    }

    func testEventEquality() {
        let action = AppUpdateAction.optionalUpdate(
            title: "Update",
            message: "Details",
            storeURL: testURL
        )

        let event1 = AppUpdateEvent.userAction(action: action, choice: .update(url: testURL))
        let event2 = AppUpdateEvent.userAction(action: action, choice: .update(url: testURL))
        let event3 = AppUpdateEvent.userAction(action: action, choice: .remindLater)

        XCTAssertEqual(event1, event2)
        XCTAssertNotEqual(event1, event3)
    }

    func testConfigWithMetadataAndReleaseNotes() throws {
        let json = """
        {
            "minimum_version": "1.0.0",
            "latest_version": "2.1.0",
            "store_url": "https://apps.apple.com/app/id123",
            "is_maintenance": "false",
            "release_notes": [
                "✨ Added dark mode support",
                "⚡️ Performance improvements"
            ],
            "metadata": {
                "min_ios": "16.0",
                "campaign_id": "summer_2026"
            }
        }
        """.data(using: .utf8)!

        let config = try JSONDecoder().decode(AppUpdateConfig.self, from: json)
        XCTAssertEqual(config.releaseNotes?.count, 2)
        XCTAssertEqual(config.metadata?["min_ios"], "16.0")
        XCTAssertEqual(config.latestAppVersion, AppVersion("2.1.0"))

        let action = AppUpdateChecker.evaluate(currentVersion: "2.0.0", config: config)
        XCTAssertEqual(action.releaseNotes?.count, 2)
        XCTAssertEqual(action.version, AppVersion("2.1.0"))
        XCTAssertEqual(action.metadata?["campaign_id"], "summer_2026")
    }

    func testCustomEvaluator() {
        struct GracePeriodEvaluator: AppUpdateEvaluator {
            func evaluate(currentVersion: AppVersion, config: AppUpdateConfig, defaultStoreURL: URL?) -> AppUpdateAction {
                // If maintenance, ignore and force optional update for VIP test
                return .optionalUpdate(
                    title: "VIP Update",
                    message: "Exclusive build",
                    storeURL: config.storeURL ?? defaultStoreURL!
                )
            }
        }

        let config = AppUpdateConfig(storeURL: testURL, isMaintenance: true)
        let action = AppUpdateChecker.evaluate(
            currentVersion: "1.0.0",
            config: config,
            evaluator: GracePeriodEvaluator()
        )

        XCTAssertEqual(action.title, "VIP Update")
    }
}
