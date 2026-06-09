import Foundation
import SwiftData

enum AppPersistenceMode: Equatable {
    case inMemory
    case local
    case cloudKit(containerIdentifier: String)

    var title: String {
        switch self {
        case .inMemory:
            "Memoria"
        case .local:
            "Local"
        case .cloudKit:
            "iCloud"
        }
    }
}

enum AppPersistenceService {
    static func makeModelContainer(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        readinessInput: SyncReadinessInput = .projectDefault
    ) throws -> ModelContainer {
        try makeModelContainer(for: resolveMode(environment: environment, readinessInput: readinessInput))
    }

    static func makeModelContainer(for mode: AppPersistenceMode) throws -> ModelContainer {
        let schema = makeSchema()
        let configuration: ModelConfiguration

        switch mode {
        case .inMemory:
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        case .local:
            configuration = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        case .cloudKit(let containerIdentifier):
            configuration = ModelConfiguration(schema: schema, cloudKitDatabase: .private(containerIdentifier))
        }

        return try ModelContainer(
            for: schema,
            migrationPlan: ExpensesMigrationPlan.self,
            configurations: [configuration]
        )
    }

    static func resolveMode(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        readinessInput: SyncReadinessInput = .projectDefault
    ) -> AppPersistenceMode {
        if environment["EXPENSES_UI_TESTING"] == "1" {
            return .inMemory
        }

        let report = SyncReadinessService.evaluate(readinessInput)
        if report.canEnableCloudKit,
           let containerIdentifier = readinessInput.normalizedCloudKitContainerIdentifier {
            return .cloudKit(containerIdentifier: containerIdentifier)
        }

        return .local
    }

    static func makeSchema() -> Schema {
        Schema(versionedSchema: ExpensesSchemaV1.self)
    }
}
