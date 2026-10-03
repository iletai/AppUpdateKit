import XCTest
@testable import AppUpdateKit

final class AppUpdateEventTests: XCTestCase {
    let testURL = URL(string: "https://apps.apple.com/app/id123456789")!

    func testActionProperties() {
        let optionalAction = AppUpdateAction.optionalUpdate(
            title: "New Update",
            message: "Exciting features!",
            storeURL: testURL,
            releaseNotes: ["Feature A", "Bug fixes"]
        )

        XCTAssertFalse(optionalAction.isBlocking)
        XCTAssertTrue(optionalAction.isUpdateAvailable)
        XCTAssertFalse(optionalAction.isRequired)
        XCTAssertFalse(optionalAction.isMaintenance)
        XCTAssertEqual(optionalAction.title, "New Update")
        XCTAssertEqual(optionalAction.message, "Exciting features!")
        XCTAssertEqual(optionalAction.storeURL, testURL)
        XCTAssertEqual(optionalAction.releaseNotes, ["Feature A", "Bug fixes"])

        let forceAction = AppUpdateAction.forceUpdate(
            title: "Important Update",
            message: "Must upgrade",
            storeURL: testURL,
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

        let noneAction = AppUpdateAction.none
        XCTAssertFalse(noneAction.isBlocking)
        XCTAssertFalse(noneAction.isUpdateAvailable)
        XCTAssertNil(noneAction.title)
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

    func testConfigWithReleaseNotesDecoding() throws {
        let json = """
        {
            "minimum_version": "1.0.0",
            "latest_version": "2.1.0",
            "store_url": "https://apps.apple.com/app/id123",
            "release_notes": [
                "✨ Added dark mode support",
                "⚡️ Performance improvements",
                "🐛 Fixed crash on launch"
            ]
        }
        """.data(using: .utf8)!

        let config = try JSONDecoder().decode(AppUpdateConfig.self, from: json)
        XCTAssertEqual(config.releaseNotes?.count, 3)
        XCTAssertEqual(config.releaseNotes?.first, "✨ Added dark mode support")

        let action = AppUpdateChecker.evaluate(currentVersion: "2.0.0", config: config)
        XCTAssertEqual(action.releaseNotes?.count, 3)
    }

    func testConfigWithMultilineStringReleaseNotesDecoding() throws {
        let json = """
        {
            "minimum_version": "1.0.0",
            "latest_version": "2.1.0",
            "store_url": "https://apps.apple.com/app/id123",
            "release_notes": "Added dark mode\\nPerformance improvements"
        }
        """.data(using: .utf8)!

        let config = try JSONDecoder().decode(AppUpdateConfig.self, from: json)
        XCTAssertEqual(config.releaseNotes?.count, 2)
        XCTAssertEqual(config.releaseNotes?[0], "Added dark mode")
        XCTAssertEqual(config.releaseNotes?[1], "Performance improvements")
    }
}
