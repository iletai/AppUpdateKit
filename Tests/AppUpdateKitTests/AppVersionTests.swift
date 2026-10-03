import XCTest
@testable import AppUpdateKit

final class AppVersionTests: XCTestCase {
    func testNormalizationAndEquality() {
        XCTAssertEqual(AppVersion("1.2"), AppVersion("1.2.0"))
        XCTAssertEqual(AppVersion("1.2.0"), AppVersion("1.2.0.0"))
        XCTAssertEqual(AppVersion("1.2.0.0"), AppVersion("1.2"))
        XCTAssertEqual(AppVersion("0.0.0"), AppVersion("0"))
        XCTAssertEqual(AppVersion("1"), AppVersion("1.0.0"))
    }

    func testComparison() {
        XCTAssertGreaterThan(AppVersion("1.10.0"), AppVersion("1.2.0"))
        XCTAssertGreaterThan(AppVersion("2.0.0"), AppVersion("1.99.99"))
        XCTAssertGreaterThan(AppVersion("1.0.1"), AppVersion("1.0.0"))
        XCTAssertLessThan(AppVersion("1.0.0"), AppVersion("1.0.1"))
        XCTAssertLessThan(AppVersion("0.1.0"), AppVersion("0.2.0"))
        XCTAssertLessThan(AppVersion("1.2"), AppVersion("1.2.1"))
        XCTAssertFalse(AppVersion("1.2.0") < AppVersion("1.2"))
        XCTAssertFalse(AppVersion("1.2") < AppVersion("1.2.0"))
    }

    func testPrereleaseAndBuildMetadataStripping() {
        XCTAssertEqual(AppVersion("1.2.0-beta.1"), AppVersion("1.2.0"))
        XCTAssertEqual(AppVersion("1.2.0+20260101"), AppVersion("1.2.0"))
        XCTAssertEqual(AppVersion("2.0.0-rc.3+build.456"), AppVersion("2.0.0"))
        XCTAssertGreaterThan(AppVersion("1.3.0-alpha"), AppVersion("1.2.0"))
    }

    func testStringLiteralAndDescription() {
        let literalVersion: AppVersion = "3.4.5"
        XCTAssertEqual(literalVersion.rawValue, "3.4.5")
        XCTAssertEqual(literalVersion.description, "3.4.5")
        XCTAssertEqual(literalVersion.components, [3, 4, 5])
    }

    func testHashableAndSetMembership() {
        let set: Set<AppVersion> = [AppVersion("1.2"), AppVersion("1.2.0")]
        XCTAssertEqual(set.count, 1)
    }

    func testEdgeCases() {
        let emptyVersion = AppVersion("")
        XCTAssertEqual(emptyVersion.components, [])
        XCTAssertEqual(emptyVersion, AppVersion("0.0.0"))

        let malformed = AppVersion("1.a.2")
        XCTAssertEqual(malformed.components, [1, 2])
    }
}
