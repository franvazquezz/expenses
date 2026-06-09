import Foundation

struct SyncReadinessInput {
    let bundleIdentifier: String
    let developmentTeam: String
    let cloudKitContainerIdentifier: String?
    let isCloudKitCapabilityEnabled: Bool

    static var projectDefault: SyncReadinessInput {
        let infoDictionary = Bundle.main.infoDictionary ?? [:]

        return SyncReadinessInput(
            bundleIdentifier: Bundle.main.bundleIdentifier ?? "com.local.expenses",
            developmentTeam: infoDictionary.stringValue(for: "EXPENSESDevelopmentTeam"),
            cloudKitContainerIdentifier: infoDictionary.stringValue(for: "EXPENSESCloudKitContainerIdentifier"),
            isCloudKitCapabilityEnabled: infoDictionary.boolValue(for: "EXPENSESCloudKitEnabled")
        )
    }

    var normalizedCloudKitContainerIdentifier: String? {
        let trimmed = cloudKitContainerIdentifier?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}

enum SyncReadinessIssue: String, Identifiable {
    case localBundleIdentifier
    case missingDevelopmentTeam
    case missingCloudKitContainer
    case missingCloudKitCapability

    var id: String { rawValue }

    var title: String {
        switch self {
        case .localBundleIdentifier:
            "Bundle ID local"
        case .missingDevelopmentTeam:
            "Equipo de desarrollo pendiente"
        case .missingCloudKitContainer:
            "Contenedor CloudKit pendiente"
        case .missingCloudKitCapability:
            "Capability de iCloud pendiente"
        }
    }

    var detail: String {
        switch self {
        case .localBundleIdentifier:
            "Usar un Bundle ID estable antes de crear el contenedor iCloud."
        case .missingDevelopmentTeam:
            "Asignar un Apple Developer Team para firmar con iCloud."
        case .missingCloudKitContainer:
            "Crear o seleccionar un contenedor privado de CloudKit."
        case .missingCloudKitCapability:
            "Activar iCloud con CloudKit en Signing & Capabilities."
        }
    }
}

struct SyncReadinessReport {
    let issues: [SyncReadinessIssue]

    var canEnableCloudKit: Bool {
        issues.isEmpty
    }

    var statusTitle: String {
        canEnableCloudKit ? "Lista para CloudKit" : "Configuracion pendiente"
    }
}

enum SyncReadinessService {
    static func evaluate(_ input: SyncReadinessInput) -> SyncReadinessReport {
        var issues: [SyncReadinessIssue] = []

        if input.bundleIdentifier.hasPrefix("com.local.") {
            issues.append(.localBundleIdentifier)
        }

        if input.developmentTeam.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(.missingDevelopmentTeam)
        }

        if input.normalizedCloudKitContainerIdentifier == nil {
            issues.append(.missingCloudKitContainer)
        }

        if !input.isCloudKitCapabilityEnabled {
            issues.append(.missingCloudKitCapability)
        }

        return SyncReadinessReport(issues: issues)
    }
}

private extension [String: Any] {
    func stringValue(for key: String) -> String {
        self[key] as? String ?? ""
    }

    func boolValue(for key: String) -> Bool {
        if let value = self[key] as? Bool {
            return value
        }

        guard let value = self[key] as? String else {
            return false
        }

        return ["1", "YES", "TRUE", "true", "yes"].contains(value)
    }
}
