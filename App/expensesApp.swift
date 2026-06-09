import SwiftData
import SwiftUI

@main
struct expensesApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try AppPersistenceService.makeModelContainer()
        } catch {
            fatalError("No se pudo inicializar la persistencia: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
        .modelContainer(modelContainer)
    }
}
