import XCTest
@testable import expenses

final class AppPersistenceServiceTests: XCTestCase {
    func testUsesInMemoryModeDuringUITests() {
        let mode = AppPersistenceService.resolveMode(
            environment: ["EXPENSES_UI_TESTING": "1"],
            readinessInput: readyCloudKitInput()
        )

        XCTAssertEqual(mode, .inMemory)
    }

    func testUsesLocalModeWhenCloudKitRequirementsAreIncomplete() {
        let mode = AppPersistenceService.resolveMode(
            environment: [:],
            readinessInput: SyncReadinessInput(
                bundleIdentifier: "com.local.expenses",
                developmentTeam: "",
                cloudKitContainerIdentifier: nil,
                isCloudKitCapabilityEnabled: false
            )
        )

        XCTAssertEqual(mode, .local)
    }

    func testUsesCloudKitModeWhenRequirementsAreComplete() {
        let mode = AppPersistenceService.resolveMode(
            environment: [:],
            readinessInput: readyCloudKitInput()
        )

        XCTAssertEqual(mode, .cloudKit(containerIdentifier: "iCloud.com.pancho.expenses"))
    }

    private func readyCloudKitInput() -> SyncReadinessInput {
        SyncReadinessInput(
            bundleIdentifier: "com.pancho.expenses",
            developmentTeam: "ABCDE12345",
            cloudKitContainerIdentifier: " iCloud.com.pancho.expenses ",
            isCloudKitCapabilityEnabled: true
        )
    }
}
