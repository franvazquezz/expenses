import XCTest
@testable import expenses

final class SyncReadinessServiceTests: XCTestCase {
    func testReportsProjectDefaultBlockers() {
        let report = SyncReadinessService.evaluate(
            SyncReadinessInput(
                bundleIdentifier: "com.local.expenses",
                developmentTeam: "",
                cloudKitContainerIdentifier: nil,
                isCloudKitCapabilityEnabled: false
            )
        )

        XCTAssertFalse(report.canEnableCloudKit)
        XCTAssertTrue(report.issues.contains(.localBundleIdentifier))
        XCTAssertTrue(report.issues.contains(.missingDevelopmentTeam))
        XCTAssertTrue(report.issues.contains(.missingCloudKitContainer))
        XCTAssertTrue(report.issues.contains(.missingCloudKitCapability))
    }

    func testAllowsCloudKitWhenRequirementsArePresent() {
        let report = SyncReadinessService.evaluate(
            SyncReadinessInput(
                bundleIdentifier: "com.pancho.expenses",
                developmentTeam: "ABCDE12345",
                cloudKitContainerIdentifier: "iCloud.com.pancho.expenses",
                isCloudKitCapabilityEnabled: true
            )
        )

        XCTAssertTrue(report.canEnableCloudKit)
        XCTAssertTrue(report.issues.isEmpty)
    }
}
