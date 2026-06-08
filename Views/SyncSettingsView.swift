import SwiftUI

struct SyncSettingsView: View {
    private let report = SyncReadinessService.evaluate(.projectDefault)

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(
                title: "Sincronizacion",
                subtitle: "Preparacion para CloudKit e iCloud",
                systemImage: "icloud.fill"
            )
            .padding([.horizontal, .top])

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.pageSpacing) {
                    AppPanel(title: "Estado", systemImage: "checklist") {
                        StatusPill(
                            title: report.statusTitle,
                            systemImage: report.canEnableCloudKit ? "checkmark.circle" : "exclamationmark.triangle",
                            color: report.canEnableCloudKit ? AppTheme.incomeColor : AppTheme.budgetColor
                        )

                        if report.canEnableCloudKit {
                            Text("La configuracion base esta lista para activar SwiftData con CloudKit.")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("La app sigue usando persistencia local hasta completar estos requisitos.")
                                .foregroundStyle(.secondary)
                        }
                    }

                    AppPanel(title: "Requisitos", systemImage: "list.bullet.clipboard") {
                        ForEach(report.issues) { issue in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(issue.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(issue.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Divider()
                        }

                        if report.issues.isEmpty {
                            Text("No hay requisitos pendientes.")
                                .foregroundStyle(.secondary)
                        }
                    }

                    AppPanel(title: "Estrategia", systemImage: "arrow.triangle.merge") {
                        Text("La sincronizacion debe usar la base privada de CloudKit. Para conflictos, gana la edicion mas reciente por registro y los movimientos generados por recurrencia se conservan como pendientes hasta confirmacion.")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Sincronizacion")
    }
}
