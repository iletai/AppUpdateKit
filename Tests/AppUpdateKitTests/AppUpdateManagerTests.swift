import XCTest
@testable import AppUpdateKit

@MainActor
final class AppUpdateManagerTests: XCTestCase {
    let testURL = URL(string: "https://apps.apple.com/app/id123456789")!

    func testManagerCheckAndEvents() async {
        let suiteName = "AppUpdateManagerTests_\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let manager = AppUpdateManager(userDefaults: defaults)

        final class EventBox: @unchecked Sendable {
            var events: [AppUpdateEvent] = []
        }
        let box = EventBox()

        let onEvent: @Sendable (AppUpdateEvent) -> Void = { event in
            box.events.append(event)
        }

        let config = AppUpdateConfig(
            minimumVersion: "1.0.0",
            latestVersion: "2.0.0",
            storeURL: testURL
        )

        let action = await manager.check(
            policy: .always,
            currentVersion: "1.5.0",
            onEvent: onEvent
        ) {
            return config
        }

        XCTAssertEqual(action, .optionalUpdate(
            title: "Update Available",
            message: "A new version of the app is available. Would you like to update now?",
            storeURL: testURL
        ))
        XCTAssertEqual(manager.currentAction, action)
        XCTAssertFalse(manager.isChecking)
        XCTAssertNotNil(manager.lastCheckDate)

        XCTAssertTrue(box.events.contains(where: { $0 == .checkStarted }))
        XCTAssertTrue(box.events.contains(where: { $0 == .configFetched(config: config) }))

        // Test handle user choice
        manager.handleUserChoice(.remindLater, onEvent: onEvent)
        XCTAssertEqual(manager.currentAction, .none)
        XCTAssertTrue(box.events.contains(where: {
            if case .userAction(_, let choice) = $0, choice == .remindLater {
                return true
            }
            return false
        }))
    }

    func testManagerPolicyOncePerSession() async {
        let suiteName = "AppUpdateManagerTests_\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let manager = AppUpdateManager(userDefaults: defaults)

        let config = AppUpdateConfig(minimumVersion: "2.0.0", storeURL: testURL)
        var fetchCount = 0

        _ = await manager.check(policy: .oncePerSession, currentVersion: "1.0.0") {
            fetchCount += 1
            return config
        }
        XCTAssertEqual(fetchCount, 1)

        // Second check with oncePerSession policy should not invoke fetcher
        _ = await manager.check(policy: .oncePerSession, currentVersion: "1.0.0") {
            fetchCount += 1
            return config
        }
        XCTAssertEqual(fetchCount, 1)
    }
}
